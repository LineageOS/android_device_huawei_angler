#!/system/bin/sh

listOfNames=`grep "STM VL6180 proximity sensor" /sys/class/input/event*/device/name`

id="$(cut -d ':' -f 1 <<< "$listOfNames")"
arr=$(echo $id | tr "\/" "\n")
for x in $arr
do
    str=`echo $x | grep "event"`
    if [ ! -z "$str" ] ; then
	echo $str
        `ln -s "/dev/input/$str" /dev/stm_sensor`
         break
    fi
done



