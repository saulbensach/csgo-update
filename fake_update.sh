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
telegram_token="686844479:AAElYq2toAInYN_DOsFIyDhA0hv8vDVssLk"
group_id="-384348538"

fn_appmanifest_info(){
    appmanifestfile=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf")
    appmanifestfilewc=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf" | wc -l)
}

$(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%E2%9A%A0 This is a fake update %E2%9A%A0")
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
$(curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$group_id -d text="%E2%98%BA Server FAKE update when nice :D %E2%98%BA")
echo "server updated"