# ANALISIS DE USO DE DISCO
## NIVEL DOS
==============================================================================
SCRIPT: AnalisisUsoDisco.sh
DESCRIPCION: Conecta a servidores Linux remotos, analiza el espacio en disco
             de la particion raiz y envia un informe por correo electronico.
FECHA: 10 de junio de 2025
Version: 20250611.2
Autor: Lorenzo Zotano (lorenzo@zotano.com) 
https://github.com/LorenzoZotano
Asistente Gemini
Licencia: Apache 2.0
==============================================================================
Actualizaciones:
20250610.1 - Primera version del script
20250611.1 - Añadido indicacion de puerto SSH en la lista de servidores
20250611.2 - Añadido soporte para especificar tipo de ejecucion, diaria o 
             periodica
==============================================================================
Programacion en /etc/crontab:
0 *     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh continuo
0 8     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh diario
==============================================================================# Scripts_Bash
Script en Linux Bash

