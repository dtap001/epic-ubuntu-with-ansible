#!/bin/bash
for f in /sys/bus/usb/devices/*/power/wakeup; do
        echo disabled > $f;
done
