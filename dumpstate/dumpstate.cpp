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

#include <dumpstate.h>

void dumpstate_board()
{
    Dumpstate& ds = Dumpstate::GetInstance();

    ds.DumpFile("INTERRUPTS", "/proc/interrupts");
    ds.DumpFile("RPM Stats", "/d/rpm_stats");
    ds.DumpFile("Power Management Stats", "/d/rpm_master_stats");
    ds.RunCommand("SUBSYSTEM TOMBSTONES", {"ls", "-l", "/data/tombstones/ramdump"}, CommandOptions::AS_ROOT_5);
    ds.DumpFile("BAM DMUX Log", "/d/ipc_logging/bam_dmux/log");
    ds.DumpFile("SMD Log", "/d/ipc_logging/smd/log");
    ds.DumpFile("SMD PKT Log", "/d/ipc_logging/smd_pkt/log");
    ds.DumpFile("IPC Router Log", "/d/ipc_logging/ipc_router/log");
    ds.DumpFile("Enabled Clocks", "/d/clk/enabled_clocks");
    ds.DumpFile("wlan", "/sys/module/bcmdhd/parameters/info_string");
    ds.RunCommand("ION HEAPS", {"/system/bin/sh", "-c", "for d in $(ls -d /d/ion/*); do for f in $(ls $d); do echo --- $d/$f; cat $d/$f; done; done"}, CommandOptions::AS_ROOT_5);
    ds.RunCommand("Temperatures", {"/system/bin/sh", "-c", "for f in die_temp emmc_therm msm_therm pa_therm1 quiet_therm ; do echo -n \"$f : \" ; cat /sys/class/hwmon/hwmon1/device/$f ; done ; for f in `ls /sys/class/thermal` ; do type=`cat /sys/class/thermal/$f/type` ; temp=`cat /sys/class/thermal/$f/temp` ; echo \"$type: $temp\" ; done"}, CommandOptions::AS_ROOT_5);
    ds.DumpFile("dmesg-ramoops-0", "/sys/fs/pstore/dmesg-ramoops-0");
    ds.DumpFile("dmesg-ramoops-1", "/sys/fs/pstore/dmesg-ramoops-1");
    ds.DumpFile("LITTLE cluster time-in-state", "/sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state");
    ds.RunCommand("LITTLE cluster cpuidle", {"/system/bin/sh", "-c", "for d in $(ls -d /sys/devices/system/cpu/cpu0/cpuidle/state*); do echo \"$d: `cat $d/name` `cat $d/desc` `cat $d/time` `cat $d/usage`\"; done"}, CommandOptions::AS_ROOT_5);
    ds.DumpFile("big cluster time-in-state", "/sys/devices/system/cpu/cpu4/cpufreq/stats/time_in_state");
    ds.RunCommand("big cluster cpuidle", {"/system/bin/sh", "-c", "for d in $(ls -d /sys/devices/system/cpu/cpu4/cpuidle/state*); do echo \"$d: `cat $d/name` `cat $d/desc` `cat $d/time` `cat $d/usage`\"; done"}, CommandOptions::AS_ROOT_5);
    ds.DumpFile("Battery:", "/sys/class/power_supply/bms/uevent");
    ds.RunCommand("Battery:", {"/system/bin/sh", "-c", "for f in 1 2 3 4 5 6 7 8; do echo $f > /sys/class/power_supply/bms/cycle_count_id; echo \"$f: `cat /sys/class/power_supply/bms/cycle_count`\"; done"}, CommandOptions::AS_ROOT_5);
};
