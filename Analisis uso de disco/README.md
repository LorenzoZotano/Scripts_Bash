# ANALISIS DE USO DE DISCO
## Descripcion
Conecta a servidores Linux remotos o locales via SSH y analiza el espacio ocupado en la particion donde este montada la raiz (/) del sistema
## Detalles
Dispone de dos modos de ejecucion:
- Modo Diario
  - Pensado para ser ejecutado una o varias veces al dia
  - Siempre enviara correo electronico, haya o no alertas
- Modo Continuo
  - Pensado para ser ejecutado cada xx minutos o horas
  - Solo enviara correo electronico si detecta una alerta

Ambos modos se pueden lanzar de forma independiente con solo especificar el parametro "Diario" o "Continuo" a la hora de ejecutar el Script  
Permite un listado casi ilimitado de servidores Linux a analizar  




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

