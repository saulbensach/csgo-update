#!/bin/bash
gcurl="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
node_ip=$(curl "$gcurl/node_ip" -H "Metadata-Flavor: Google")
node_port=$(curl "$gcurl/node_port" -H "Metadata-Flavor: Google")
rootdir="/home/csgoserver/"
serverfiles="${rootdir}/serverfiles"
appid="740"
steamcmddir="${rootdir}/steamcmd"
steamuser="anonymous"
branch="public"
branchname="public"
telegram_token=""
group_id="-384348538"

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
            # Esperemos que el tamaño del id no cambie así de rápido porq si no me va a destrozar mucho código
            # Segun steamdc el buildid es incremental 
            if [ "$l1" = "$l2" ]; then
                echo "updated detected!"
                $(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%E2%9A%A0 Server updated detected %E2%9A%A0")
                echo "Currentbuild: $currentbuild"
                echo "Availablebuild: $availablebuild"
                while true; do
                    output=$(curl "http://$node_ip:$node_port/update/start_update" --write '\n%{http_code}\n' --fail --silent)
                    return_code=$?
                    if [ 0 -eq $return_code ]; then
                            break
                    else
                            echo "unable to connect to node: code=$output"
                            sleep 1
                    fi
                done
                cd "${rootdir}" || exit
                ./csgoserver update
                # hacer case si hay algún tipo de error con update etc blablalba
                while true; do
                    output=$(curl "http://$node_ip:$node_port/update/finish_update" --write '\n%{http_code}\n' --fail --silent)
                    return_code=$?
                    if [ 0 -eq $return_code ]; then
                            break
                    else
                            echo "unable to connect to node: code=$output"
                            sleep 1
                    fi
                done
                $(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%E2%98%BA Server update when nice :D %E2%98%BA")
                echo "server updated"
            else 
                #enviar alerta servidores
                #por email
                $(curl -X POST https://maker.ifttt.com/trigger/bad_csgo_update/with/key/cjSF_A32gqR1pfDtfgBqLE)
                $(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%F0%9F%9A%A8 Updated failed something happened come to me %F0%9F%9A%A8")
                echo "something went wrong not updating"
                sleep 0.5
            fi
        else
            echo "no update available"
            sleep 0.5
        fi
    fi
    sleep 7
done

