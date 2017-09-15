/*
 * Copyright (C) 2015 The CyanogenMod Project
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

package org.lineageos.hardware;

import org.lineageos.internal.util.FileUtils;
import java.io.File;

public class VibratorHW {
    private static String LEVEL_PATH_LIGHT  = "/sys/devices/virtual/timed_output/vibrator/vmax_mv_light";
    private static String LEVEL_PATH_STRONG = "/sys/devices/virtual/timed_output/vibrator/vmax_mv_strong";

    public static boolean isSupported() {
        return FileUtils.isFileWritable(LEVEL_PATH_STRONG);
    }

    /* angler kernel min/max and defaults are:
     * #define QPNP_HAP_VMAX_MIN_MV            116
     * #define QPNP_HAP_VMAX_MAX_MV            3596
     * #define QPNP_HAP_VMAX_LIGHT_MV          1500
     * #define QPNP_HAP_VMAX_STRONG_MV         1800
     */

    public static int getMaxIntensity()  {
        return 3000;
    }

    public static int getMinIntensity()  {
        return 600;
    }

    public static int getDefaultIntensity()  {
        return 1800;
    }

    public static int getWarningThreshold()  {
        return -1;
    }

    public static int getCurIntensity()  {
        return Integer.parseInt(FileUtils.readOneLine(LEVEL_PATH_STRONG));
    }

    public static boolean setIntensity(int intensity)  {
        return FileUtils.writeLine(LEVEL_PATH_STRONG, String.valueOf(intensity))
                && FileUtils.writeLine(LEVEL_PATH_LIGHT, String.valueOf(intensity - 300));
    }
}
