/*
 * Copyright (C) 2017 The LineageOS Project
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

#define LOG_TAG "LightService"

#include <log/log.h>

#include "Light.h"

#include <fstream>

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

#define LEDS            "/sys/class/leds/"

#define LCD_LED         LEDS "lcd-backlight/"
#define RED_LED         LEDS "red/"
#define GREEN_LED       LEDS "green/"
#define BLUE_LED        LEDS "blue/"

#define BRIGHTNESS      "brightness"


/*
 * Write value to path and close file.
 */
static void set(std::string path, std::string value) {
    std::ofstream file(path);
    file << value;
}

static void set(std::string path, int value) {
    set(path, std::to_string(value));
}


static uint32_t rgbToBrightness(const LightState& state) {
    uint32_t color = state.color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0xff)) + (150 * ((color >> 8) & 0xff)) +
            (29 * (color & 0xff))) >> 8;
}

static void handleBacklight(const LightState& state) {
    uint32_t brightness = rgbToBrightness(state);
    set(LCD_LED BRIGHTNESS, brightness);
}

static void handleNotification(const LightState& state) {
    uint32_t redBrightness, greenBrightness, blueBrightness;

    /*
     * Extract brightness from AARRGGBB.
     */
    redBrightness = (state.color >> 16) & 0xFF;
    greenBrightness = (state.color >> 8) & 0xFF;
    blueBrightness = state.color & 0xFF;

    /*
     * Scale RGB brightness
     * There is a seperate gpio per led. Each with a maximum brightness of 20.
     * The normal rgb values are computed on a scale up to 255 so we divide them
     * by 12.75 so that varied brightness per led is spread out evenly per color.
     * The led is only optimal on absolute red, green or blue, and produces artifacts
     * of two different colors appearing at once when more than one is active, but
     * this is very limiting so ultimately we allow the end user full control.
     */
     redBrightness = (redBrightness / 12.75);
     greenBrightness = (greenBrightness / 12.75);
     blueBrightness = (blueBrightness / 12.75);

     set(RED_LED BRIGHTNESS, redBrightness);
     set(GREEN_LED BRIGHTNESS, greenBrightness);
     set(BLUE_LED BRIGHTNESS, blueBrightness);
}


static std::map<Type, std::function<void(const LightState&)>> lights = {
    {Type::BACKLIGHT, handleBacklight},
    {Type::BATTERY, handleNotification},
    {Type::NOTIFICATIONS, handleNotification},
    {Type::ATTENTION, handleNotification},
};

Light::Light() {}

Return<Status> Light::setLight(Type type, const LightState& state) {
    auto it = lights.find(type);

    if (it == lights.end()) {
        return Status::LIGHT_NOT_SUPPORTED;
    }

    /*
     * Lock global mutex until light state is updated.
     */
    std::lock_guard<std::mutex> lock(globalLock);

    it->second(state);

    return Status::SUCCESS;
}

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb) {
    std::vector<Type> types;

    for (auto const& light : lights) types.push_back(light.first);

    _hidl_cb(types);

    return Void();
}

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android
