#!/bin/bash

# ==============================================================================
# SCRIPT: AnalisisUsoDisco.sh
# DESCRIPCION: Conecta a servidores Linux remotos, analiza el espacio en disco
#              de la particion raiz y envia un informe por correo electronico.
# FECHA: 10 de junio de 2025
# Version: 20250611.2
# Autor: Lorenzo Zotano (lorenzo@zotano.com) 
# https://github.com/LorenzoZotano
# Asistente Gemini
# Licencia: Apache 2.0
# ==============================================================================
# Actualizaciones:
# 20250610.1 - Primera version del script
# 20250611.1 - Añadido indicacion de puerto SSH en la lista de servidores
# 20250611.2 - Añadido soporte para especificar tipo de ejecucion, diaria o 
#              periodica
# ==============================================================================
# Programacion en /etc/crontab:
# 0 *     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh continuo
# 0 8     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh diario
# ==============================================================================

# --- DETERMINAR TIPO DE EJECUCION SEGUN PARAMETRO ---
#     Acepta los parametros:
#     - DIARIO:   Ejecuta el script una vez al dia, a la hora especificada en el cron.
#                 Siempre envia correo electronico, haya o no alertas o errores.
#     - CONTINUO: Ejecuta el script de forma continua, cada cierto intervalo de tiempo.
#                 Solo envia correo electronico si hay alertas o errores.

# Variable que almacenará el tipo de ejecución
TIPO_EJECUCION=""

# Verificamos si se ha proporcionado un parámetro
if [ -z "$1" ]; then
    echo "Error: No se ha especificado ningún parámetro."
    echo "Uso: $0 [Diario|Continuo]"
    exit 1 # Salimos con un código de error
fi

# Convertimos el parámetro a minúsculas para hacerlo insensible a mayúsculas/minúsculas
PARAMETRO_MINUSCULAS=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Evaluamos el valor del parámetro
case "$PARAMETRO_MINUSCULAS" in
    "diario")
        TIPO_EJECUCION="DIARIO"
        ;;
    "continuo")
        TIPO_EJECUCION="CONTINUO"
        ;;
    *)
        echo "Error: Parámetro incorrecto. Solo se acepta 'Diario' o 'Continuo'."
        echo "Uso: $0 [Diario|Continuo]"
        exit 1 # Salimos con un código de error
        ;;
esac

echo "El script está funcionando en modo: $TIPO_EJECUCION"


# =======================
# --- CONFIGURACION ---
# =======================

# VARIABLES ENVIO CORREO
SENDMAIL_FOLDER="/usr/sbin"
EMAIL_RECIPIENT="tu@correo.com"
EMAIL_CC=''
EMAIL_SUBJECT="Analisis de uso de discos"
EMAIL_FROM='correo@remitente.com'
EMAIL_FROM_NAME='Servicio Alertas <'$EMAIL_FROM'>'

# Fichero de log donde se guardaran los resultados del analisis
LOG_FILE="/home/scripts/AnalisisUsoDisco.log"

# Lista de servidores a analizar. Cada entrada debe tener el formato:
# "Nombre Servidor|IP Servidor|Port SSH|Usuario Root|Contraseña Root|Espacio Disco (umbral en %)"
# ¡IMPORTANTE!: Las contraseñas en texto plano no son seguras.
# Para entornos de produccion, considera usar autenticacion por clave SSH sin contraseña.
# Si las contraseñas contienen caracteres especiales, como '$', deben escaparse con '\$' para evitar problemas de interpretación en el script.

SERVERS=(
    "ServidorCorreo|192.168.1.1|22|root|*************|80"
    "ServidorWWW|192.168.1.2|22|root|*************|80"
    "OtroServidor|192.168.1.3|22|root|*************|80"
)


# =============================
# --- FIN DE CONFIGURACION ---
# =============================


# Determinar si se enviará un correo electrónico, dependiendo del tipo de ejecución

if [ "$TIPO_EJECUCION" = "DIARIO" ]; then
    ENVIAR_CORREO="TRUE" # En este modo, siempre se enviará un correo electrónico, independientemente de si hay alertas o errores.
elif [ "$TIPO_EJECUCION" = "CONTINUO" ]; then
    ENVIAR_CORREO="FALSE" # En este modo, solo se enviará un correo electrónico si hay alertas o errores.
fi

NOMBRE_SERVIDOR=$(hostname | tr '[:lower:]' '[:upper:]') # Nombre del servidor donde se ejecuta el script en mayúsculas

# Funcion para obtener el porcentaje de uso de disco en un servidor remoto
# Argumentos: $1 = IP, $2 = Puerto conexion SSH, $3 = Usuario, $4 = Contraseña
# El valor del ECHO es el valor de salida de la funcion, que sera el porcentaje de uso del disco

get_disk_usage() {
    local ip="$1"
    local port="${2:-22}"  # Si no se especifica el puerto, se usa el 22 por defecto
    local user="$3"
    local password="$4"
    local disk_usage=""

    # Usamos sshpass para pasar la contraseña, y ssh para ejecutar el comando remoto

    # ==============================================================================
    # sshpass: Este comando se utiliza para pasar la contraseña a ssh de forma no 
    # interactiva. Debes instalarlo en tu sistema Linux si no lo tienes.
    # En Debian/Ubuntu: sudo apt update && sudo apt install sshpass
    # ==============================================================================

    # La parte 'df -hP / | awk 'NR==2 {gsub("%","",$5); print $5}'' es la que se encarga de obtener
    #   el valor de ocupacion del disco duro donde esta montada la particion /.
    # El '2>/dev/null' redirige los errores de sshpass a /dev/null para no mostrar la contraseña en el log.

    disk_usage=$(
        sshpass -p "${password}" ssh -p "${port}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o LogLevel=QUIET "${user}@${ip}" "df -hP / | awk 'NR==2 {gsub(\"%\", \"\", \$5); print \$5}'" 2>/dev/null
    )

    # Validar si se obtuvo un valor numerico
    if [[ -z "$disk_usage" || ! "$disk_usage" =~ ^[0-9]+$ ]]; then
        echo "ERROR" # Indicar un error si no se pudo obtener el uso del disco
    else
        echo "$disk_usage"
    fi
}

# --- LOGICA PRINCIPAL DEL SCRIPT ---

# Inicializar el cuerpo del correo/log
EMAIL_BODY=""
LOG_BODY=""

# Añadir la fecha y hora actual al inicio del log y del cuerpo del correo
CURRENT_DATETIME=$(date +"%Y%m%d_%H%M%S")

#DIFERENCIAMOS ENTRE EL TEXTO A ALMACENAR PARA ENVIAR POR CORREO Y EL TEXTO A ALMACENAR EN EL LOG
EMAIL_BODY+="--- ANALISIS DE DISCOS (${CURRENT_DATETIME}) ---\n"
EMAIL_BODY+="--- SCRIPT ALOJADO EN: ${NOMBRE_SERVIDOR} ---\n\n"
LOG_BODY+="--- ANALISIS DE DISCOS (${CURRENT_DATETIME}) ---\n"

# Iterar sobre cada servidor en la lista
for server_entry in "${SERVERS[@]}"; do
    # Dividir la cadena de entrada por el delimitador '|'
    IFS='|' read -r server_name server_ip server_port server_user server_password disk_threshold <<< "$server_entry"

    # Obtener el uso del disco del servidor remoto
    DISK_PERCENTAGE=$(get_disk_usage "${server_ip}" "${server_port}" "${server_user}" "${server_password}")

    echo "Analizando ${server_name} (${server_ip})... Uso Disco: ${DISK_PERCENTAGE} %"

    LINE_TO_ADD_LOG=""
    LINE_TO_ADD_EMAIL=""

    if [[ "$DISK_PERCENTAGE" == "ERROR" ]]; then
        LINE_TO_ADD_EMAIL="[ERROR] Sin acceso a ${server_name} (${server_ip})."
        LINE_TO_ADD_LOG="[ERROR] No se pudo obtener el espacio en disco de ${server_name} (${server_ip}). Verifique credenciales o conectividad SSH."
        ENVIAR_CORREO="TRUE" # En caso de error, siempre enviar correo electrónico
    else
        # Comparar el porcentaje de uso con el umbral
        if (( DISK_PERCENTAGE >= disk_threshold )); then
            LINE_TO_ADD_EMAIL="[ALERTA] Servidor ${server_name}, Uso: ${DISK_PERCENTAGE} % (${disk_threshold} %)"
            LINE_TO_ADD_LOG="[ALERTA] Servidor ${server_name}, Uso de disco: ${DISK_PERCENTAGE} % (Umbral: ${disk_threshold} %)"
            ENVIAR_CORREO="TRUE" # En caso de alerta, siempre enviar correo electrónico
        else
            LINE_TO_ADD_EMAIL="Servidor ${server_name}, Uso: ${DISK_PERCENTAGE} %"
            LINE_TO_ADD_LOG="Servidor ${server_name}, Uso de disco: ${DISK_PERCENTAGE} % (Umbral: ${disk_threshold} %)"
        fi
    fi

    # Añadir la linea al cuerpo del correo/log
    EMAIL_BODY+="${LINE_TO_ADD_EMAIL}\n"
    LOG_BODY+="${LINE_TO_ADD_LOG}\n"

done

EMAIL_BODY+="Proceso finalizado.\n"
LOG_BODY+="Proceso finalizado.\n"


if [ "$ENVIAR_CORREO" = "TRUE" ]; then

    # Si se debe enviar el correo, informar en el log
    LOG_BODY+="Se enviara correo electronico a ${EMAIL_RECIPIENT}\n"
    echo "Se enviara correo electronico a ${EMAIL_RECIPIENT}"

    # --- Enviar Correo Electronico ---
    # Para que 'sendmail' funcione, necesitas tener un MTA (Mail Transfer Agent) como Postfix
    # o Sendmail configurado correctamente en tu sistema.
    # sendmail espera que el correo tenga encabezados como "To:", "Subject:", etc., al principio.

    # COMPOSICION Y ENVIO DEL CORREO ELECTRONICO

    echo "Componiendo y enviando el correo electronico."
    echo "Puede tardar unos segundos ..."

    (
    echo "To: ${EMAIL_RECIPIENT}"

    # Logica para añadir CC si EMAIL_CC tiene contenido
    if [[ -n "${EMAIL_CC}" ]]; then
        echo "Cc: ${EMAIL_CC}"
    fi

    echo "From: ${EMAIL_FROM_NAME}"
    echo "Subject: ${EMAIL_SUBJECT}"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/plain; charset=\"UTF-8\""
    echo "" # Linea en blanco para separar los encabezados del cuerpo
    echo -e "$EMAIL_BODY"
    ) | sendmail -f $EMAIL_FROM -t

    echo "Correo enviado a ${EMAIL_RECIPIENT} ..."
    echo "Comprobando envio ..."

    if [ $? -eq 0 ]; then
        echo "Correo electronico enviado a ${EMAIL_RECIPIENT} con el asunto '${EMAIL_SUBJECT}'"
    else
        echo "ERROR: No se pudo enviar el correo electronico con sendmail. Asegurese de que sendmail este configurado correctamente."
    fi

else
    # Si no se envía correo, no añadir la sección de fin del análisis
    LOG_BODY+="No se enviara correo electronico\n"
    echo "No se enviara correo electronico"
fi

# --- Guardar en el LOG ---
echo -e "$LOG_BODY" >> "$LOG_FILE"
echo "Resultados del analisis guardados en: ${LOG_FILE}"

# --- Finalizar ---
echo "Proceso finalizado."