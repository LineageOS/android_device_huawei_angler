#!/vendor/bin/sh

# Make modem config folder and copy firmware config to that folder
rm -rf /data/misc/radio/modem_config
mkdir -m 770 /data/misc/radio/modem_config
cp -r /firmware/image/modem_pr/mcfg/configs/* /data/misc/radio/modem_config
echo 1 > /data/misc/radio/copy_complete
