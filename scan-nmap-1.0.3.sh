#!/bin/bash

# Colores para mejor visualización
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar dependencias
check_dependencies() {
    local deps=("nmap" "xsltproc")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Error: Faltan las siguientes dependencias:${NC}"
        printf '%s\n' "${missing[@]}"
        echo "Por favor, instálalas antes de continuar."
        exit 1
    fi
}

# Función para validar formato IP
validate_ip() {
    local ip=$1
    local ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$'

    if [[ ! $ip =~ $ip_regex ]]; then
        echo -e "${RED}Error: Formato de IP inválido${NC}"
        echo "Uso correcto: 192.168.1.0/24 o 192.168.1.1"
        exit 1
    fi

    # Validar rangos de números
    IFS='.' read -r -a ip_parts <<< "${ip%/*}"
    for part in "${ip_parts[@]}"; do
        if [ "$part" -gt 255 ] || [ "$part" -lt 0 ]; then
            echo -e "${RED}Error: Los números en la IP deben estar entre 0 y 255${NC}"
            exit 1
        fi
    done
}

# Función para crear directorio de salida
setup_output_dir() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_dir="scan_results_${timestamp}"

    mkdir -p "$output_dir"
    echo "$output_dir"
}

# Función para realizar el escaneo de red
network_scan() {
    local target=$1
    local output_dir=$2

    echo -e "${YELLOW}[+] Iniciando escaneo de red en $target...${NC}"

    if ! nmap -sn "$target" -oA "$output_dir/network_scan"; then
        echo -e "${RED}Error durante el escaneo de red${NC}"
        return 1
    fi

    echo -e "${GREEN}[✓] Escaneo de red completado${NC}"
}

# Función para escaneo de puertos
port_scan() {
    local ip=$1
    local output_dir=$2

    echo -e "${YELLOW}[+] Escaneando puertos en $ip...${NC}"

    if ! nmap -sV -sS -p- -v -n -O -A -T4 --max-retries 2 -oA "$output_dir/port_scan_$ip" "$ip"; then
        echo -e "${RED}Error durante el escaneo de puertos en $ip${NC}"
        return 1
    fi

    # Generar reporte HTML
    if [ -f "$output_dir/port_scan_$ip.xml" ]; then
        xsltproc -o "$output_dir/port_scan_$ip.html" /usr/share/nmap/nmap.xsl "$output_dir/port_scan_$ip.xml"
        echo -e "${GREEN}[✓] Reporte HTML generado para $ip${NC}"
    fi
}

# Función principal
main() {
    # Verificar si se está ejecutando como root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Este script requiere privilegios de root${NC}"
        exit 1
    fi

    # Verificar dependencias
    check_dependencies

    # Crear directorio para resultados
    output_dir=$(setup_output_dir)
    echo -e "${GREEN}[✓] Directorio de salida creado: $output_dir${NC}"

    # Solicitar IP objetivo
    read -p "Ingresa la IP o el rango de IP inicial (ej: 192.168.1.0/24): " initial_ip
    validate_ip "$initial_ip"

    # Realizar escaneo de red
    network_scan "$initial_ip" "$output_dir"

    # Procesar resultados
    if [ -f "$output_dir/network_scan.nmap" ]; then
        mapfile -t ips_found < <(grep -oP 'Nmap scan report for \K[\d.]+' "$output_dir/network_scan.nmap")

        echo -e "\n${GREEN}[✓] IPs encontradas:${NC}"
        for i in "${!ips_found[@]}"; do
            echo "$((i + 1)): ${ips_found[i]}"
        done

        # Permitir al usuario seleccionar una IP
        read -p "Selecciona el número de la IP que deseas escanear: " selection

        if [[ $selection -gt 0 && $selection -le ${#ips_found[@]} ]]; then
            selected_ip=${ips_found[$((selection - 1))]}
            port_scan "$selected_ip" "$output_dir"
        else
            echo -e "${RED}Selección inválida. Saliendo del script.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}No se encontraron resultados del escaneo de red${NC}"
        exit 1
    fi

    echo -e "\n${GREEN}[✓] Proceso completado. Resultados guardados en: $output_dir/${NC}"
}

# Ejecutar script
main
