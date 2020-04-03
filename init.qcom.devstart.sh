#!/vendor/bin/sh

echo 1 > /sys/kernel/boot_adsp/boot
setprop vendor.qcom.devup 1
