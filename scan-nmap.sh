#!/bin/bash

# Necesitamos tener instalado nmap y xlstproc

# Pedimos la ip objetivo inicial
read -p "Ingresa la IP o el rango de IP inicial para identificar redes: " initial_ip

# Escaneo inicial para descubrir redes
echo "Escaneando redes en $initial_ip..."
nmap -sn $initial_ip -oA network_scan
echo "Escaneo de redes completado. Resultados guardados en network_scan.*"

# Obtenemos IPs encontradas del archivo de salida de Nmap
ips_found=$(grep -oP 'Nmap scan report for \K[\d.]+' network_scan.nmap)
echo "IPs encontradas:"
echo "$ips_found"

# Para cada IP encontrada, realizamos un escaneo de puertos y guardamos en diferentes formatos
for ip in $ips_found; do
    echo "Escaneando puertos en $ip..."
    nmap -sV -sS -p- -v -n -T4 -oA port_scan_$ip $ip
    echo "Escaneo de puertos completado para $ip. Resultados guardados en port_scan_$ip.*"
    
    # Convertimos el archivo XML a HTML
    if [ -f "port_scan_$ip.xml" ]; then
        xsltproc -o port_scan_$ip.html /usr/share/nmap/nmap.xsl port_scan_$ip.xml
        echo "Archivo HTML generado para $ip en port_scan_$ip.html"
    else
        echo "No se encontró archivo XML para $ip, no se pudo generar HTML."
    fi
done

echo "Proceso completado. Todos los archivos de escaneo están guardados en el directorio actual."
