# ANALISIS DE USO DE DISCO
## :sparkles: Descripción
Conecta a servidores Linux remotos o locales via SSH, analiza el espacio ocupado en la partición donde esté montada la raiz (/) del sistema y activa una alerta por correo electrónico en caso de que el espacio ocupado supere el humbral especificado (en %)
## :star: Historial de versiones

- 20250610.1  
  Primera versión del script
- 20250611.1  
  Añadido indicación de puerto SSH en la lista de servidores
- 20250611.2  
  Añadido soporte para especificar tipo de ejecución, diaria o periódica

## :gear: Detalles
Dispone de dos modos de ejecución:
- ### Modo Diario
  - Pensado para ser ejecutado una o varias veces al dia
  - Siempre enviara correo electrónico de alerta, haya o no alertas
  - Pensado para tener un informe diario del espacio ocupado en los servidores
- ### Modo Continuo
  - Pensado para ser ejecutado cada xx minutos o horas
  - Solo enviara correo electrónico si detecta una alerta
  - Permite tener alertas rápidas por si un error llena el disco duro del servidor

Ambos modos se pueden lanzar de forma independiente con solo especificar el parámetro "Diario" o "Continuo" a la hora de ejecutar el Script  
Permite un listado casi ilimitado de servidores Linux a analizar  
Se considerara que hay una alerta cuando el espacio ocupado en la partición donde esta montada "/" es igual o superior al % indicado en la lista de servidores (independiente para cada servidor).

### Base de datos Servidores:
Se utiliza una lista para almacenar los datos de los servidores que vamos a analizar. Ten en cuenta que almacenamos las contraseñas en texto plano, por lo que si te preocupa la seguridad no uses este script en entornos de producción. En ese caso deberías optar por una autenticación basada en claves SSH.  
```
Formato lista de servidores:
"Nombre Servidor|IP Servidor|Port SSH|Usuario Root|Contraseña Root|Espacio Disco (umbral en %)"

SERVERS=(  
    "ServidorCorreo|192.168.1.1|22|root|*************|80"  
    "ServidorWWW|192.168.1.2|22|root|*************|80"  
    "OtroServidor|192.168.1.3|22|root|*************|80"  
)
```

## :wrench: Instalación y Funcionamiento
### Programación en /etc/crontab:
Añadimos las programaciones que deseemos al Cron de nuestro servidor  
La ejecución continua la pongo cada minuto 15 de cada hora porque algunos servidores tienen programado un reinicio nocturno y si las pongo a las horas en punto ese servidor me da error por no responder.

```
/etc/crontab  
15 *     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh continuo  
0 8     * * *   root    cd /home/scripts/;./AnalisisUsoDisco.sh diario
```  
## :computer: Uso
Este Script esta pensado para ser ejecutado de forma automática según lo indicado en el punto anterior. No obstante podemos ejecutarlo a petición de la siguiente forma, dependiendo del modo de ejecución que deseemos. Los resultados se mostraran por consola ademas de incluir la anotación en el log y de mandar un correo si corresponde:
```
root@linux:/ cd /home/scripts/ && ./AnalisisUsoDisco.sh continuo
root@linux:/ cd /home/scripts/ && ./AnalisisUsoDisco.sh diario  
```

## :memo: Contribuciones
Si tienes algún comentario **constructivo**, quieres contribuir de alguna forma (con algún otro Script, mejorando u optimizando este, etc.) o simplemente tienes una oferta irrechazable puedes ponerte en contacto conmigo como mejor te venga. Échale un vistazo a la sección de Licencia y Contacto para mas detalles.

## :scroll: Licencia y contacto
Autor: Lorenzo Zotano (lorenzo@zotano.com)   
https://github.com/LorenzoZotano  
Asistente Gemini  
Licencia: Apache 2.0  
### Descargo de responsabilidad
El contenido de este repositorio (incluidos todos los scripts, códigos y ejemplos) se proporciona "tal cual", sin garantías de ningún tipo, ya sean explícitas o implícitas. El creador del repositorio no asume ninguna responsabilidad por el uso o la aplicación de los scripts aquí contenidos.

Usted es el único responsable de evaluar la idoneidad, fiabilidad y seguridad de estos scripts para sus propios fines. Se recomienda encarecidamente revisar y comprender completamente el código antes de ejecutarlo en cualquier entorno, especialmente en sistemas de producción donde la pérdida de datos o el daño pueden ser significativos.

Al utilizar cualquier script o información de este repositorio, usted acepta que el creador no será responsable de ningún daño directo, indirecto, incidental, consecuente o especial que surja de o esté relacionado con el uso de estos materiales.

Se aconseja encarecidamente realizar copias de seguridad de sus datos antes de ejecutar cualquier script, así como probar los scripts en un entorno seguro y aislado antes de implementarlos en entornos de producción.

Este repositorio puede contener enlaces a recursos externos. El creador no respalda ni se hace responsable del contenido o las prácticas de privacidad de dichos sitios web.

Al clonar o descargar este repositorio, usted acepta este descargo de responsabilidad en su totalidad.
## :closed_lock_with_key: Recuerda, es importante:
- El uso de contraseñas y credenciales en texto plano en los Scripts no esta pensado para entornos de producción. Ten en cuenta que cualquiera que tenga acceso de lectura al Script podra ver las contraseñas almacenadas. Si usas este Script en entornos de producción __es muy recomendable__ que utilices claves SSH para acceder a los distintos servidores.

