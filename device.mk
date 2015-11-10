#
# Copyright (C) 2015 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file includes all definitions that apply to ALL angler devices, and
# are also specific to angler devices
#
# Everything in this directory will become public

PRODUCT_COPY_FILES += \
    device/huawei/angler/init.angler.rc:root/init.angler.rc \
    device/huawei/angler/init.angler.sensorhub.rc:root/init.angler.sensorhub.rc \
    device/huawei/angler/init.angler.usb.rc:root/init.angler.usb.rc \
    device/huawei/angler/fstab.angler:root/fstab.angler \
    device/huawei/angler/ueventd.angler.rc:root/ueventd.angler.rc \
    device/huawei/angler/init.angler.power.sh:system/bin/init.angler.power.sh


PRODUCT_COPY_FILES += \
    device/huawei/angler/init.mcfg.sh:system/bin/init.mcfg.sh

# Thermal configuration
PRODUCT_COPY_FILES += \
    device/huawei/angler/thermal-engine-angler.conf:system/etc/thermal-engine.conf

# Media
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    device/huawei/angler/media_codecs.xml:system/etc/media_codecs.xml \
    device/huawei/angler/media_codecs_performance.xml:system/etc/media_codecs_performance.xml \
    device/huawei/angler/media_profiles.xml:system/etc/media_profiles.xml

# Audio
PRODUCT_COPY_FILES += \
    device/huawei/angler/audio_output_policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_output_policy.conf \
    device/huawei/angler/audio_effects.conf:system/etc/audio_effects_vendor.conf \
    device/huawei/angler/mixer_paths.xml:system/etc/mixer_paths.xml \
    device/huawei/angler/audio_platform_info_i2s.xml:system/etc/audio_platform_info_i2s.xml \
    device/huawei/angler/sound_trigger_mixer_paths.xml:system/etc/sound_trigger_mixer_paths.xml \
    device/huawei/angler/sound_trigger_platform_info.xml:system/etc/sound_trigger_platform_info.xml \
    device/huawei/angler/audio_policy.conf:system/etc/audio_policy.conf \
    device/huawei/angler/audio_platform_info.xml:system/etc/audio_platform_info.xml \

# Input device files
PRODUCT_COPY_FILES += \
    device/huawei/angler/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
    device/huawei/angler/qpnp_pon.kl:system/usr/keylayout/qpnp_pon.kl \
    device/huawei/angler/synaptics_dsx.idc:system/usr/idc/synaptics_dsx.idc

# for launcher layout
#PRODUCT_PACKAGES += \
#    AnglerLayout

# Delegation for OEM customization
PRODUCT_OEM_PROPERTIES := \
    ro.config.ringtone \
    ro.config.notification_sound \
    ro.config.alarm_alert \
    ro.config.wallpaper \
    ro.config.wallpaper_component \
    ro.oem.* \
    oem.*

PRODUCT_COPY_FILES += \
    device/huawei/angler/sec_config:system/etc/sec_config

# Wifi
PRODUCT_COPY_FILES += \
    device/huawei/angler/bcmdhd.cal:system/etc/wifi/bcmdhd.cal \
    device/huawei/angler/bcmdhd-pme.cal:system/etc/wifi/bcmdhd-pme.cal \
    device/huawei/angler/bcmdhd-high.cal:system/etc/wifi/bcmdhd-high.cal \
    device/huawei/angler/bcmdhd-low.cal:system/etc/wifi/bcmdhd-low.cal

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:system/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:system/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:system/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:system/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:system/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:system/etc/permissions/android.hardware.sensor.hifi_sensors.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:system/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:system/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:system/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:system/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.software.midi.xml:system/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:system/etc/permissions/android.software.verified_boot.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:system/etc/permissions/com.nxp.mifare.xml


# MSM IRQ Balancer configuration file
PRODUCT_COPY_FILES += \
    device/huawei/angler/msm_irqbalance.conf:system/etc/msm_irqbalance.conf

PRODUCT_TAGS += dalvik.gc.type-precise

# This device is 560dpi.  However the platform doesn't
# currently contain all of the bitmaps at 560dpi density so
# we do this little trick to fall back to the xxhdpi version
# if the 560dpi doesn't exist.
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := 560dpi
# A list of dpis to select prebuilt apk, in precedence order.
PRODUCT_AAPT_PREBUILT_DPI := xxxhdpi xxhdpi xhdpi hdpi

PRODUCT_CHARACTERISTICS := nosdcard

PRODUCT_PACKAGES += \
    gralloc.msm8994 \
    hwcomposer.msm8994 \
    libgenlock \
    memtrack.msm8994 \
    lights.angler

PRODUCT_PACKAGES += \
    audio.primary.msm8994 \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    libaudio-resampler \
    dsm_ctrl

# Audio effects
PRODUCT_PACKAGES += \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libqcomvoiceprocessingdescriptors \
    libqcompostprocbundle

PRODUCT_PACKAGES += \
    libc2dcolorconvert \
    libstagefrighthw \
    libOmxCore \
    libmm-omxcore \
    libOmxVdec \
    libOmxVdecHevc \
    libOmxVenc

#CAMERA
PRODUCT_PACKAGES += \
    camera.msm8994 \
    libcamera \
    libmmcamera_interface \
    libmmcamera_interface2 \
    libmmjpeg_interface \
    libqomx_core \
    mm-qcamera-app \
    Snap

PRODUCT_PROPERTY_OVERRIDES += \
    persist.camera.cpp.duplication=false

# Sensor & activity_recognition HAL
PRODUCT_PACKAGES += \
    sensors.angler \
    activity_recognition.angler \
    sensortool.angler \
    nano4x1.bin

# for off charging mode
PRODUCT_PACKAGES += \
    charger_res_images

PRODUCT_PACKAGES += \
    libwpa_client \
    hostapd \
    dhcpcd.conf \
    wlutil \
    wpa_supplicant \
    wpa_supplicant.conf

# NFC
PRODUCT_PACKAGES += \
    com.android.nfc_extras \
    libnfc-nci \
    nfc_nci.angler \
    NfcNci \
    Tag

# Power HAL
PRODUCT_PACKAGES += \
    power.angler

PRODUCT_COPY_FILES += \
    device/huawei/angler/nfc/libnfc-brcm.conf:system/etc/libnfc-brcm.conf \
    device/huawei/angler/nfc/libnfc-nxp.conf:system/etc/libnfc-nxp.conf

DEVICE_PACKAGE_OVERLAYS := \
    device/huawei/angler/overlay

PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=196609

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=560

PRODUCT_PROPERTY_OVERRIDES += \
    persist.hwc.mdpcomp.enable=true \
    persist.data.mode=concurrent

PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.data_no_toggle=1

PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.data_con_rprt=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.ril.force_eri_from_xml=true

# Enable low power video mode for 4K encode
PRODUCT_PROPERTY_OVERRIDES += \
    vidc.debug.perf.mode=2 \
    vidc.enc.dcvs.extra-buff-count=2

# for perfd
PRODUCT_PROPERTY_OVERRIDES += \
    ro.min_freq_0=384000
    ro.min_freq_4=384000

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so

PRODUCT_PROPERTY_OVERRIDES += \
    rild.libpath=/system/vendor/lib64/libril-qc-qmi-1.so

PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.default_cdma_sub=0

# LTE, CDMA, GSM/WCDMA
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.default_network=10 \
    telephony.lteOnCdmaDevice=1 \
    persist.radio.mode_pref_nv10=1 \
    ro.telephony.get_imsi_from_sim=true

PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.apm_sim_not_pwdn=1

# Setup custom emergency number list based on the MCC. This is needed by RIL
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.custom_ecc=1

# Enable Wifi calling
PRODUCT_PROPERTY_OVERRIDES += \
    persist.data.iwlan.enable=true

PRODUCT_PROPERTY_OVERRIDES += \
   ro.frp.pst=/dev/block/platform/soc.0/f9824900.sdhci/by-name/frp

# For SPN display
PRODUCT_COPY_FILES += \
    device/huawei/angler/spn-conf.xml:system/etc/spn-conf.xml

# Request modem to send PLMN name always irrespective
# of display condition in EFSPN.
# RIL uses this property.
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.always_send_plmn=true

# If data_no_toggle is 0 there are no reports if the screen is off.
# If data_no_toggle is 1 then dormancy indications will come with screen off.
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.data_no_toggle=1

# Allow tethering without provisioning app
PRODUCT_PROPERTY_OVERRIDES += \
    net.tethering.noprovisioning=true

# Ril sends only one RIL_UNSOL_CALL_RING, so set call_ring.multiple to false
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.call_ring.multiple=0

# Update 1x signal strength after 2s
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.radio.snapshot_enabled=1 \
    persist.radio.snapshot_timer=2

# Reduce client buffer size for fast audio output tracks
PRODUCT_PROPERTY_OVERRIDES += \
    af.fast_track_multiplier=1

# Low latency audio buffer size in frames
PRODUCT_PROPERTY_OVERRIDES += \
    audio_hal.period_size=192

#for qcom modify fluence type name, here added and enable
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qc.sdk.audio.fluencetype="fluence" \
    persist.audio.fluence.voicecall=true \
    persist.audio.fluence.voicecomm=true \
    persist.audio.product.identify="angler" \
    persist.audio.fluence.speaker=true

# Enable AAC 5.1 output
PRODUCT_PROPERTY_OVERRIDES += \
    media.aac_51_output_enabled=true

#stereo speakers: orientation changes swap L/R channels
PRODUCT_PROPERTY_OVERRIDES += \
    ro.audio.monitorRotation=true

# low audio flinger standby delay to reduce power consumption
PRODUCT_PROPERTY_OVERRIDES += \
    ro.audio.flinger_standbytime_ms=300

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.ssr.restart_level="ALL_ENABLE"

# Enable camera EIS
# eis.enable: enables electronic image stabilization
# is_type: sets image stabilization type
PRODUCT_PROPERTY_OVERRIDES += \
    persist.camera.eis.enable=1 \
    persist.camera.is_type=4

# For android_filesystem_config.h
PRODUCT_PACKAGES += \
   fs_config_files

# For data
PRODUCT_PACKAGES += \
   librmnetctl

# limit dex2oat threads to improve thermals
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.boot-dex2oat-threads=4 \
    dalvik.vm.dex2oat-threads=2 \
    dalvik.vm.image-dex2oat-threads=4

# Modem debugger
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
    QXDMLogger

PRODUCT_COPY_FILES += \
    device/huawei/angler/init.angler.diag.rc.userdebug:root/init.angler.diag.rc

# subsystem ramdump collection
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.ssr.enable_ramdumps=1
else
PRODUCT_COPY_FILES += \
    device/huawei/angler/init.angler.diag.rc.user:root/init.angler.diag.rc
endif

# Incoming number (b/23529711)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.redir_party_num=0

# IO Scheduler
PRODUCT_PROPERTY_OVERRIDES += \
    sys.io.scheduler=bfq

# Dalvik/HWUI
$(call inherit-product, frameworks/native/build/phone-xxxhdpi-3072-dalvik-heap.mk)
$(call inherit-product-if-exists, frameworks/native/build/phone-xxxhdpi-3072-hwui-memory.mk)

# drmservice prop
PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=true

# facelock properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.facelock.black_timeout=400 \
    ro.facelock.det_timeout=1500 \
    ro.facelock.rec_timeout=2500 \
    ro.facelock.lively_timeout=2500 \
    ro.facelock.est_max_time=600 \
    ro.facelock.use_intro_anim=false

$(call inherit-product-if-exists, hardware/qcom/msm8994/msm8994.mk)
$(call inherit-product-if-exists, vendor/qcom/gpu/msm8994/msm8994-gpu-vendor.mk)

# copy wlan firmware
$(call inherit-product-if-exists, hardware/broadcom/wlan/bcmdhd/firmware/bcm4358/device-bcm.mk)

# only include verity on user builds for CM
ifeq ($(TARGET_BUILD_VARIANT),user)
   PRODUCT_COPY_FILES += device/huawei/angler/fstab-verity.angler:root/fstab.angler

  # setup dm-verity configs.
  PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/platform/soc.0/f9824900.sdhci/by-name/system
  # don't check verity on vendor partition as we don't compile it with the boot and system image
  # PRODUCT_VENDOR_VERITY_PARTITION := /dev/block/platform/soc.0/f9824900.sdhci/by-name/vendor
  $(call inherit-product, build/target/product/verity.mk)
endif
