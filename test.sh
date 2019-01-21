#!/bin/bash
rootdir="/home/csgoserver/"
serverfiles="${rootdir}/serverfiles"
appid="740"
steamcmddir="${rootdir}/steamcmd"
steamuser="anonymous"
branch="public"
branchname="public"
telegram_token="686844479:AAElYq2toAInYN_DOsFIyDhA0hv8vDVssLk"
group_id="-384348538"

fn_appmanifest_info(){
    appmanifestfile=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf")
    appmanifestfilewc=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf" | wc -l)
}
fn_appmanifest_info
currentbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
if [ -f "${HOME}/Steam/appcache/appinfo.vdf" ]; then
    rm -f "${HOME}/Steam/appcache/appinfo.vdf"
fi
availablebuild=$(./steamcmd.sh +login "${steamuser}" +app_info_update 1 +app_info_print "${appid}" +quit | sed '1,/branches/d' | sed "1,/${branchname}/d" | grep -m 1 buildid | tr -cd '[:digit:]')
l1=$availablebuild | wc -c
l2=$currentbuild | wc -c
if [ "$l1" = "$l2" ]; then
        echo "both equal"
fi
$(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%F0%9F%9A%A8 Updated failed something happened come to me %F0%9F%9A%A8")
