#!/vendor/bin/sh

up="`getprop vendor.qcom.devup`"
while [ "$up" != "1" ]
do
    sleep 0.1
    up="`getprop vendor.qcom.devup`"
done
