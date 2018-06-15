/*
 * Copyright 2018 The LineageOS Project
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

#define LOG_TAG "android.hardware.light@2.0-service.angler"

#include <hidl/HidlTransportSupport.h>
#include <utils/Errors.h>

#include "Light.h"

// libhwbinder:
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

// Generated HIDL files
using android::hardware::light::V2_0::ILight;
using android::hardware::light::V2_0::implementation::Light;

const static std::string kLcdBacklightPath = "/sys/class/leds/lcd-backlight/brightness";
const static std::string kLcdMaxBacklightPath = "/sys/class/leds/lcd-backlight/max_brightness";
const static std::string kRedLedPath = "/sys/class/leds/red/brightness";
const static std::string kGreenLedPath = "/sys/class/leds/green/brightness";
const static std::string kBlueLedPath = "/sys/class/leds/blue/brightness";
const static std::string kRedLedTimerPath= "/sys/class/leds/red/on_off_ms";
const static std::string kGreenLedTimerPath = "/sys/class/leds/green/on_off_ms";
const static std::string kBlueLedTimerPath = "/sys/class/leds/blue/on_off_ms";
const static std::string kRgbLockPath = "/sys/class/leds/red/rgb_start";

int main() {
    printf("asdf\n");
    ALOGV("Angler Lights Hal Starting up!");
    uint32_t lcdMaxBrightness = 255;
    std::vector<std::ofstream> buttonBacklight;

    std::ofstream redLed(kRedLedPath);
    if (!redLed) {
        ALOGE("Failed to open %s, error=%d (%s)", kRedLedPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream greenLed(kGreenLedPath);
    if (!greenLed) {
        ALOGE("Failed to open %s, error=%d (%s)", kGreenLedPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream blueLed(kBlueLedPath);
    if (!blueLed) {
        ALOGE("Failed to open %s, error=%d (%s)", kBlueLedPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream redLedTimer(kRedLedTimerPath);
        if (!redLedTimer) {
        ALOGE("Failed to open %s, error=%d (%s)", kRedLedTimerPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream greenLedTimer(kGreenLedTimerPath);
        if (!greenLedTimer) {
        ALOGE("Failed to open %s, error=%d (%s)", kGreenLedTimerPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream blueLedTimer(kBlueLedTimerPath);
        if (!blueLedTimer) {
        ALOGE("Failed to open %s, error=%d (%s)", kBlueLedTimerPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream rgbLock(kRgbLockPath);
        if (!rgbLock) {
        ALOGE("Failed to open %s, error=%d (%s)", kRgbLockPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ofstream lcdBacklight(kLcdBacklightPath);
    if (!lcdBacklight) {
        ALOGE("Failed to open %s, error=%d (%s)", kLcdBacklightPath.c_str(), errno, strerror(errno));
        return -errno;
    }

    std::ifstream lcdMaxBacklight(kLcdMaxBacklightPath);
    if (!lcdMaxBacklight) {
        ALOGE("Failed to open %s, error=%d (%s)", kLcdMaxBacklightPath.c_str(), errno, strerror(errno));
        return -errno;
    } else {
        lcdMaxBacklight >> lcdMaxBrightness;
    }

    android::sp<ILight> service = new Light(
            {std::move(lcdBacklight), lcdMaxBrightness},
            std::move(redLed),
            std::move(greenLed),
            std::move(blueLed),
            std::move(redLedTimer),
            std::move(greenLedTimer),
            std::move(blueLedTimer),
            std::move(rgbLock));
    configureRpcThreadpool(1, true);

    android::status_t status = service->registerAsService();

    if (status != android::OK) {
       ALOGE("Cannot register Light HAL service");
        return 1;
    }

    ALOGI("Light HAL Ready.");
    joinRpcThreadpool();
    // Under normal cases, execution will not reach this line.
    ALOGE("Light HAL failed to join thread pool.");
    return 1;
}
