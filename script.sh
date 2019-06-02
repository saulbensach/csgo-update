#!/bin/bash
gcurl="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
is_master=$(curl "$gcurl/is_master" -H "Metadata-Flavor: Google")
if [ $is_master = true ] ; then
        echo "le tengo que notificar al master server que me acabo de encender..."
        sh updater.sh | while IFS= read -r line; do echo "$(date) $line"; done >> log.txt
else
        echo "eres secundario"
        lobby_token=$(curl "$gcurl/lobby_token" -H "Metadata-Flavor: Google")
        node_ip=$(curl "$gcurl/node_ip" -H "Metadata-Flavor: Google")
        node_port=$(curl "$gcurl/node_port" -H "Metadata-Flavor: Google")       
        while true; do  
                result=$(./csgoserver details | grep Status | tail -1 | cut -f2 | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g")
                case "$result" in
                        OFFLINE) ./csgoserver start ;;
                        ONLINE) break ;;
                        *) echo "hola" ;;
                esac
        done

        while true; do
                output=$(curl "http://$node_ip:$node_port/server/$lobby_token" --write '\n%{http_code}\n' --fail --silent)
                return_code=$?
                if [ 0 -eq $return_code ]; then
                        break
                else
                        echo "unable to connect to node: code=$output"
                        sleep 1
                fi
        done
        
        echo "Server started"
        echo "$output" | sed '$d' | jq .
fi