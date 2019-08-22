# Aviso
En proceso de traducción y de solución genérica.

# CSGO Updater
Servicio para actualizar el servicio de csgo, iniciando la cadena de cambios en la infraestructura

## ¿ Cómo se usa ?
El servicio se debe de ejecutar al incio del sistema con cron
```
@reboot /rutascript/script.sh
```
Muy importante llamar a script.sh para obtener el log

## ¿ Cómo funciona ?
El objetivo de este repo era realizar la configuración de servidores de CSGO usando google cloud y un backend.
Cada vez que una instancia se inicia ejecuta script.sh, verifica que hay update y se comunica con el servidor maestro.
