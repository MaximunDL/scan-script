# Network and Port Scanner Script

Este proyecto es un script en Bash que automatiza el proceso de escaneo de redes y puertos utilizando nmap y convierte los resultados a un formato HTML con xsltproc para una visualización más fácil.

## Características

- **Escaneo de redes**: permite identificar dispositivos activos en un rango de IP especificado por el usuario.
- **Selección de IP**: una vez identificadas las IPs activas en la red, el usuario puede seleccionar una IP específica para realizar un escaneo detallado de puertos.
- **Escaneo de puertos**: escanea todos los puertos abiertos en la IP seleccionada e identifica los servicios y versiones de los mismos.
- **Exportación de resultados**: guarda el resultado del escaneo en un archivo `.xml` y genera un archivo `.html` para facilitar su visualización en un navegador.

## Requisitos

- [Nmap](https://nmap.org/) - Para realizar los escaneos de red y puertos.
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html) - Para convertir el archivo `.xml` de Nmap a `.html`.

### Instalación en sistemas basados en Debian/Ubuntu
``` bash
sudo apt update
sudo apt install nmap xsltproc

Instalación en sistemas basados en Arch Linux
sudo pacman -S nmap xsltproc
```
Clonar el repositorio:
``` bash
git clone https://github.com/MaximunDL/scan-script.git

cd scan-script

Dar permisos de ejecución al script

chmod +x scan-nmap-1.0.x.sh

Ejecutar el script

sudo ./scan-nmap-1.0.3.sh
```
Nota: Este script debe ejecutarse con permisos de superusuario para realizar escaneos completos de red y puertos.

Sigue las instrucciones del script:

Ingresa la IP o rango de IP inicial (ejemplo: 192.168.1.0/24) para realizar un escaneo de la red.

Selecciona una de las IPs encontradas para realizar un escaneo de puertos detallado.

Los resultados se guardarán en un directorio con el nombre scan\_results\_<timestamp>, donde <timestamp> es la fecha y hora del escaneo, para una fácil organización.

Ejemplo de salida

bash

## Directorio de salida: scan_results_20240101_103000/
### Archivos generados:
### ├── network_scan.xml      # Resultados del escaneo de red en XML
### ├── network_scan.nmap     # Resultados del escaneo de red en formato Nmap
### ├── network_scan.gnmap    # Resultados del escaneo de red en formato Greppable
### ├── port_scan_<IP>.xml    # Resultados detallados del escaneo de puertos en XML
### ├── port_scan_<IP>.html   # Archivo HTML generado desde el XML para visualización


Detalles del Código

Funciones principales

check\_dependencies: verifica si nmap y xsltproc están instalados en el sistema.

validate\_ip: valida el formato de la IP ingresada.

setup\_output\_dir: crea un directorio de salida único para guardar los resultados.

network\_scan: realiza un escaneo de red para encontrar dispositivos activos.

port\_scan: realiza un escaneo de puertos en la IP seleccionada y convierte el resultado en un archivo HTML.

Formato y colores

El script utiliza colores en la terminal para una visualización más clara de los mensajes de error, advertencias y confirmaciones:

Rojo: errores críticos

Amarillo: pasos en proceso

Verde: pasos completados con éxito

Contribuciones

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar el script o encuentras errores, no dudes en enviar un pull.

Este README proporciona una explicación completa de cómo utilizar el script, los requisitos, y el propósito de cada función principal.
