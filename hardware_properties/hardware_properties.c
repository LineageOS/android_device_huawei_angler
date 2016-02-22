/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>

#define LOG_TAG "HardwarePropertiesHAL"
#include <utils/Log.h>

#include <hardware/hardware.h>
#include <hardware/hardware_properties.h>

#define MAX_LENGTH              50

#define CPU_USAGE_FILE          "/proc/stat"
#define TEMPERATURE_FILE_FORMAT "/sys/class/thermal/thermal_zone%d/temp"
#define BATTERY_TEMP_NUM        23
#define GPU_TEMP_NUM            13

const int CPU_SENSORS[] = {8, 9, 10, 11, 14, 15, 16, 7};

#define CPU_NUM                 (sizeof(CPU_SENSORS) / sizeof(int))

static ssize_t get_cpu_temperatures(struct hardware_properties_module *module,
                                    float **temps) {
    FILE *file;
    char file_name[MAX_LENGTH];
    int cpu;
    float temp;
    size_t size = 0;

    *temps = malloc(CPU_NUM * sizeof(float));

    for (cpu = 0; cpu < CPU_NUM; cpu++) {
        sprintf(file_name, TEMPERATURE_FILE_FORMAT, CPU_SENSORS[cpu]);
        file = fopen(file_name, "r");
        if (file == NULL) {
            ALOGE("%s: failed to open: %s", __func__, strerror(errno));
            free(*temps);
            *temps = NULL;
            return -1;
        }
        if (1 != fscanf(file, "%f", &temp)) {
            fclose(file);
            free(*temps);
            *temps = NULL;
            ALOGE("%s: failed to read a float: %s", __func__, strerror(errno));
            return -1;
        }
        // tsens_tz_sensor[7,8,9,10,11,14,15,6]: temperature in Celsius.
        (*temps)[size] = temp;
        size++;
        fclose(file);
    }
    return size;
}

static ssize_t get_battery_temperatures(
        struct hardware_properties_module *module, float **temps) {
    FILE *file;
    char file_name[MAX_LENGTH];
    float temp;

    *temps = malloc(sizeof(float));

    sprintf(file_name, TEMPERATURE_FILE_FORMAT, BATTERY_TEMP_NUM);
    file = fopen(file_name, "r");

    if (file == NULL) {
        ALOGE("%s: failed to open: %s", __func__, strerror(errno));
        free(*temps);
        *temps = NULL;
        return -1;
    }

    if (1 != fscanf(file, "%f", &temp)) {
        fclose(file);
        free(*temps);
        *temps = NULL;
        ALOGE("%s: failed to read a float: %s", __func__, strerror(errno));
        return -1;
    }

    // hwmon sensor: battery: temperature in millidegrees Celsius.
    (*temps)[0] = temp / 1000;
    fclose(file);
    return 1;
}

static ssize_t get_gpu_temperatures(struct hardware_properties_module *module,
                                    float **temps) {
    FILE *file;
    char file_name[MAX_LENGTH];
    float temp;

    *temps = malloc(sizeof(float));

    sprintf(file_name, TEMPERATURE_FILE_FORMAT, GPU_TEMP_NUM);
    file = fopen(file_name, "r");

    if (file == NULL) {
        ALOGE("%s: failed to open: %s", __func__, strerror(errno));
        free(*temps);
        *temps = NULL;
        return -1;
    }

    if (1 != fscanf(file, "%f", &temp)) {
        fclose(file);
        free(*temps);
        *temps = NULL;
        ALOGE("%s: failed to read a float: %s", __func__, strerror(errno));
        return -1;
    }

    // tsens_tz_sensor12: temperature in Celsius.
    (*temps)[0] = temp;
    fclose(file);
    return 1;
}

static ssize_t get_cpu_usages(struct hardware_properties_module *module,
                              int64_t **active_times,
                              int64_t **total_times) {
    int vals, cpu_num;
    ssize_t read;
    uint64_t user, nice, system, idle, active, total;
    char *line = NULL;
    size_t len = 0;
    size_t size = 0;
    FILE *file = fopen(CPU_USAGE_FILE, "r");

    if (file == NULL) {
        ALOGE("%s: failed to open: %s", __func__, strerror(errno));
        return -1;
    }

    *active_times = malloc(CPU_NUM * sizeof(int64_t));
    *total_times = malloc(CPU_NUM * sizeof(int64_t));

    while((read = getline(&line, &len, file)) != -1) {
        // Skip non "cpu[0-9]" lines.
        if (strnlen(line, read) < 4 || strncmp(line, "cpu", 3) != 0
            || !isdigit(line[3])) {
            free(line);
            line = NULL;
            len = 0;
            continue;
        }

        vals = sscanf(line, "cpu%d %" SCNu64 " %" SCNu64 " %" SCNu64 " %"
                      SCNu64, &cpu_num, &user, &nice, &system, &idle);

        if (vals != 5 || size == CPU_NUM) {
            if (vals != 5) {
                ALOGE("%s: failed to read CPU information from file: %s",
                      __func__, strerror(errno));
            } else {
                ALOGE("/proc/stat file has incorrect format.");
            }
            fclose(file);
            free(line);
            free(*active_times);
            free(*total_times);
            *active_times = NULL;
            *total_times = NULL;
            line = NULL;
            len = 0;
            return -1;
        }

        active = user + nice + system;
        total = active + idle;
        (*active_times)[size] = active;
        (*total_times)[size] = total;

        size++;

        free(line);
        line = NULL;
        len = 0;
    }

    if (size != CPU_NUM) {
        ALOGE("/proc/stat file has incorrect format.");
        fclose(file);
        free(*active_times);
        *active_times = NULL;
        free(*total_times);
        *total_times = NULL;
        return -1;
    }

    fclose(file);
    return size;
}

static struct hw_module_methods_t hardware_properties_module_methods = {
    .open = NULL,
};

struct hardware_properties_module HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .module_api_version
            = HARDWARE_PROPERTIES_HARDWARE_MODULE_API_VERSION_0_1,
        .hal_api_version = HARDWARE_HAL_API_VERSION,
        .id = HARDWARE_PROPERTIES_HARDWARE_MODULE_ID,
        .name = "Angler Hardware Properties HAL",
        .author = "The Android Open Source Project",
        .methods = &hardware_properties_module_methods,
    },
    .getCpuTemperatures = get_cpu_temperatures,
    .getGpuTemperatures = get_gpu_temperatures,
    .getBatteryTemperatures = get_battery_temperatures,
    .getCpuUsages = get_cpu_usages,
};
