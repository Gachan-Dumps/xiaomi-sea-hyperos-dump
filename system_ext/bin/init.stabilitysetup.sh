#!/bin/sh

total_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')
scout_enabled=$(getprop persist.sys.miui_scout_enable)

# For device with 6GB+ memory
if [ $total_memory -gt 4194304 ]; then
    # If no explict config, enable scout by default
    if [ -z $scout_enabled ]; then
        setprop persist.sys.miui_scout_enable true
    fi
fi

# For device with less than 4GB memory
# Only allow scout to be enabled during MTBF/UAT
if [ -z $scout_enabled ]; then
    library_test=$(getprop persist.mtbf.test)
    if [ "$library_test" = "1" ] || [ "$library_test" = "true" ]; then
        setprop persist.sys.miui_scout_enable true
    fi
fi

# For all devices, enable scout by default
new_scout_enabled=$(getprop persist.sys.stability.scout.enable)
if [ -z $new_scout_enabled ]; then
    setprop persist.sys.stability.scout.enable true
fi


# For device with 4G RAM, scout will work in lightweight mode. In LW mode
# scout will neither collet backtrace nor do any action that may cause exessive load.
scout_lightweight=$(getprop persist.sys.stability.lightweightscout.enable)
if [ $total_memory -le 6291456 ]; then
    if [ -z $scout_lightweight ]; then
        setprop persist.sys.stability.lightweightscout.enable true
    fi
fi

# For all device, scout will detect UI frozen and report it.
scout_detect_frozen=$(getprop persist.sys.stability.lightweightscout.check_frozen)
if [ -z $scout_detect_frozen ]; then
    setprop persist.sys.stability.lightweightscout.check_frozen true
fi
