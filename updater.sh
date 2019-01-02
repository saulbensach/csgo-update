#!/bin/bash
rootdir="/home/csgoserver/"
serverfiles="${rootdir}/serverfiles"
appid="740"
steamcmddir="${rootdir}/steamcmd"
steamuser="anonymous"
branch="public"
branchname="public"

fn_appmanifest_info(){
        appmanifestfile=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf")
        appmanifestfilewc=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf" | wc -l)
}

cat > log.txt

while true
do
    fn_appmanifest_info
    currentbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
    if [ -f "${HOME}/Steam/appcache/appinfo.vdf" ]; then
            rm -f "${HOME}/Steam/appcache/appinfo.vdf"
    fi
    # Set branch for updateinfo

    # Gets availablebuild info
    cd "${steamcmddir}" || exit
    availablebuild=$(./steamcmd.sh +login "${steamuser}" +app_info_update 1 +app_info_print "${appid}" +quit | sed '1,/branches/d' | sed "1,/${branchname}/d" | grep -m 1 buildid | tr -cd '[:digit:]')

    if [ "${currentbuild}" != "${availablebuild}" ]; then
        call=$(curl http://81.202.122.97:4000/master)
        echo $call > $1 | tee -a log.txt
        cd "${rootdir}" || exit
        ./csgoserver update
        # hacer case si hay algún tipo de error con update etc blablalba
        call=$(curl http://81.202.122.97:4000/master/updated)
        echo $call > $1 | tee -a log.txt
    else
        echo "no update available" > $1 | tee -a log.txt
    fi

    sleep 10
done

