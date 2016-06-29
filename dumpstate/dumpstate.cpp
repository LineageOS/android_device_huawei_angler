/*
 * Copyright (C) 2015 The Android Open Source Project
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
#include <errno.h>
#include <string>
#include <string.h>

#define LOG_TAG "dumpstate"
#include <cutils/log.h>
#include <dumpstate.h>

/**
 * Dump Wearable node database if present.
 *
 * TODO This function is a temporary solution for Android Wear and should be
 * removed once dumpsys has proper support for adding files to the zip, or
 * moved to a common library.
 */

void dump_wear_nodedb() {
    // we rely on su to workaround selinux permissions in the app data directory
    // so this will only work on userdebug builds
    if (is_user_build()) {
        return;
    }

    std::string tmp_nodedb_path = bugreport_dir + "/wear-nodedb.db";
    std::string wear_nodedb_path = "/data/data/com.google.android.gms/databases/node.db";

    if (run_command("COPY WEAR NODE DB", 600, SU_PATH, "root",
                    "cp", wear_nodedb_path.c_str(), tmp_nodedb_path.c_str(), NULL)) {
        MYLOGE("Wear node.db copy failed\n");
        return;
    }
    if (run_command("CHOWN WEAR NODE DB", 600, SU_PATH, "root",
                    "chown", "shell:shell", tmp_nodedb_path.c_str(), NULL)) {
        MYLOGE("Wear node.db chown failed\n");
        return;
    }
    if (add_zip_entry(ZIP_ROOT_DIR + wear_nodedb_path, tmp_nodedb_path)) {
        MYLOGD("Wear node.db added to zip file\n");
    } else {
        MYLOGE("Unable to add zip for Wear node.db\n");
    }
    // unconditionally remove the db since it's just a copy
    if (remove(tmp_nodedb_path.c_str())) {
        MYLOGE("Error removing Wear node.db file %s: %s\n",
                tmp_nodedb_path.c_str(), strerror(errno));
    }
}

void dumpstate_board()
{
    dump_file("INTERRUPTS", "/proc/interrupts");
    dump_file("RPM Stats", "/d/rpm_stats");
    dump_file("Power Management Stats", "/d/rpm_master_stats");
    run_command("SUBSYSTEM TOMBSTONES", 5, SU_PATH, "root", "ls", "-l", "/data/tombstones/ramdump", NULL);
    dump_file("BAM DMUX Log", "/d/ipc_logging/bam_dmux/log");
    dump_file("SMD Log", "/d/ipc_logging/smd/log");
    dump_file("SMD PKT Log", "/d/ipc_logging/smd_pkt/log");
    dump_file("IPC Router Log", "/d/ipc_logging/ipc_router/log");
    dump_file("Enabled Clocks", "/d/clk/enabled_clocks");
    dump_file("wlan", "/sys/module/bcmdhd/parameters/info_string");
    run_command("ION HEAPS", 5, SU_PATH, "root", "/system/bin/sh", "-c", "for d in $(ls -d /d/ion/*); do for f in $(ls $d); do echo --- $d/$f; cat $d/$f; done; done", NULL);
    run_command("Temperatures", 5, SU_PATH, "root", "/system/bin/sh", "-c", "for f in die_temp emmc_therm msm_therm pa_therm1 quiet_therm ; do echo -n \"$f : \" ; cat /sys/class/hwmon/hwmon1/device/$f ; done ; for f in `ls /sys/class/thermal` ; do type=`cat /sys/class/thermal/$f/type` ; temp=`cat /sys/class/thermal/$f/temp` ; echo \"$type: $temp\" ; done", NULL);
    dump_file("dmesg-ramoops-0", "/sys/fs/pstore/dmesg-ramoops-0");
    dump_file("dmesg-ramoops-1", "/sys/fs/pstore/dmesg-ramoops-1");
    dump_file("LITTLE cluster time-in-state", "/sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state");
    run_command("LITTLE cluster cpuidle", 5, SU_PATH, "root", "/system/bin/sh", "-c", "for d in $(ls -d /sys/devices/system/cpu/cpu0/cpuidle/state*); do echo \"$d: `cat $d/name` `cat $d/desc` `cat $d/time` `cat $d/usage`\"; done", NULL);
    dump_file("big cluster time-in-state", "/sys/devices/system/cpu/cpu4/cpufreq/stats/time_in_state");
    run_command("big cluster cpuidle", 5, SU_PATH, "root", "/system/bin/sh", "-c", "for d in $(ls -d /sys/devices/system/cpu/cpu4/cpuidle/state*); do echo \"$d: `cat $d/name` `cat $d/desc` `cat $d/time` `cat $d/usage`\"; done", NULL);
    dump_file("Battery:", "/sys/class/power_supply/bms/uevent");
    run_command("Battery:", 5, SU_PATH, "root", "/system/bin/sh", "-c", "for f in 1 2 3 4 5 6 7 8; do echo $f > /sys/class/power_supply/bms/cycle_count_id; echo \"$f: `cat /sys/class/power_supply/bms/cycle_count`\"; done", NULL);

    dump_wear_nodedb();
};
