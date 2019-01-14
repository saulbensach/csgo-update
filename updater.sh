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

echo "===============LOG BEGIN============="

while true
do
    fn_appmanifest_info
    currentbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
    if [ -f "${HOME}/Steam/appcache/appinfo.vdf" ]; then
        rm -f "${HOME}/Steam/appcache/appinfo.vdf"
    fi
    # Set branch for updateinfonano

    # Gets availablebuild info
    cd "${steamcmddir}" || exit
    availablebuild=$(./steamcmd.sh +login "${steamuser}" +app_info_update 1 +app_info_print "${appid}" +quit | sed '1,/branches/d' | sed "1,/${branchname}/d" | grep -m 1 buildid | tr -cd '[:digit:]')

    if ! [ -z $availablebuild ]; then
        if [ "${currentbuild}" != "${availablebuild}" ]; then
            l1=$currentbuild | wc -c
            l2=$availablebuild | wc -c
            if [ "$l1" = "$l2" ]; then
                echo "updated detected!"
                echo "Currentbuild: $currentbuild"
                echo "Availablebuild: $availablebuild"
                call=$(curl http://81.202.122.97:4000/master)
                cd "${rootdir}" || exit
                ./csgoserver update
                # hacer case si hay algún tipo de error con update etc blablalba
                call=$(curl http://81.202.122.97:4000/master/updated)
                echo "server updated"
            fi
        else
            echo "no update available"
            sleep 0.5
        fi
    fi
    sleep 7
done

