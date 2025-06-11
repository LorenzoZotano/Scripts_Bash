# ANALISIS DE USO DE DISCO
## Descripcion
Conecta a servidores Linux remotos o locales via SSH, analiza el espacio ocupado en la particion donde este montada la raiz (/) del sistema y activa una alerta por correo electronico en caso de que el espacio ocupado supere el humbral especificado (en %)
## Detalles
Dispone de dos modos de ejecucion:
- ### Modo Diario
  - Pensado para ser ejecutado una o varias veces al dia
  - Siempre enviara correo electronico de alerta, haya o no alertas
  - Pensado para tener un informe diario del espacio ocupado en los servidores
- ### Modo Continuo
  - Pensado para ser ejecutado cada xx minutos o horas
  - Solo enviara correo electronico si detecta una alerta
  - Permite tener alertas rapidas por si un error llena el disco duro del servidor

Ambos modos se pueden lanzar de forma independiente con solo especificar el parametro "Diario" o "Continuo" a la hora de ejecutar el Script  
Permite un listado casi ilimitado de servidores Linux a analizar  

## Instalacion

## Uso

## Contribuciones

## Licencia y contacto

## :closed_lock_with_key: Recuerda, es importante:
El uso de contraseñas y credenciales en texto plano en los Scripts no esta pensado para entornos de produccion. Ten en cuenta que cualquiera que tenga acceso de lectura al Script podra ver las contraseñas almacenadas. Si usas este Script en entornos de produccion __es muy recomendable__ que utilices claves SSH para acceder a los distintos servidores.

## AYUDA MARK DOWN
[Guia completa Emojis](https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md)  
:sparkles: Mi Proyecto Brillante  
:rocket: Cómo Empezar  
:bulb: Ideas Futuras  
:star: (⭐)  
:bulb: (💡)  
:rocket: (🚀)  
:gear: (⚙️)  
:wrench: (🔧)  
:bug: (🐛)  
:white_check_mark: (✅)  
:x: (❌)  
:memo: (📝)  
:computer: (💻)  
:closed_lock_with_key:  
:key:  
:warning:  
:skull_and_crossbones:  
:skull:  
*Cursiva*  
**Negrita**  
| Encabezado 1 | Encabezado 2 |
|--------------|--------------|
| Fila 1 Col 1 | Fila 1 Col 2 |
| Fila 2 Col 1 | Fila 2 Col 2 |  

Esto es un `Texto en modo codigo`  

```
Bloque de codigo
Varias lineas
```



NIVEL DOS

SCRIPT: AnalisisUsoDisco.sh

DESCRIPCION: Conecta a servidores Linux remotos, analiza el espacio en disco  
             de la particion raiz y envia un informe por correo electronico.
             
FECHA: 10 de junio de 2025
Version: 20250611.2
Autor: Lorenzo Zotano (lorenzo@zotano.com) 
https://github.com/LorenzoZotano
Asistente Gemini
Licencia: Apache 2.0

Actualizaciones:
20250610.1 - Primera version del script
20250611.1 - Añadido indicacion de puerto SSH en la lista de servidores
20250611.2 - Añadido soporte para especificar tipo de ejecucion, diaria o 
             periodica

Programacion en /etc/crontab:
0 *     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh continuo
0 8     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh diario

Script en Linux Bash

