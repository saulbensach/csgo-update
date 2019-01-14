#Antes de que el servidor se actualice tenemos que comprobar que si o sí, el servidor esté actualizado
#los servidores SIEMPRE han de estar a la ultima versión
#este update es necesario ya que entre que se lanza la imagen puede haber un update
# si en este instante algún cliente se actualiza no va a poder jugar la partida!

while true; do  
     result=$(./csgoserver details | grep Status | tail -1 | cut -f2 | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g")
     case "$result" in
         OFFLINE) 
            ./csgoserver update
            ./csgoserver start 
            ;;
         ONLINE) break ;;
         *) echo "hola" ;;
     esac
 done
 echo "Server started"
ip=$(./csgoserver details | grep "Server IP:" | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" | cut -c 19-)
test=$(curl http://81.202.122.97:4000/server)
echo $test