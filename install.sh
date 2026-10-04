#!/bin/bash
# This script downloads proprietary software from Oracle.
# The user must accept Oracle's terms of use.
# JDK Oracle: https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz

detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        echo "unknown"
    fi
}

install_curl_if_missing() {
    if command -v curl >/dev/null 2>&1; then
        return 0
    fi

    pkg_manager=$(detect_package_manager)

    echo "curl no encontrado. Instalando con: $pkg_manager"

    if [ "$(id -u)" -eq 0 ]; then
        SUDO_CMD=""
    else
        SUDO_CMD="sudo"
    fi

    case "$pkg_manager" in
        apt)
            $SUDO_CMD apt-get update && $SUDO_CMD apt-get install -y curl
            ;;
        dnf)
            $SUDO_CMD dnf install -y curl
            ;;
        yum)
            $SUDO_CMD yum install -y curl
            ;;
        pacman)
            $SUDO_CMD pacman -Sy --noconfirm curl
            ;;
        zypper)
            $SUDO_CMD zypper --non-interactive install curl
            ;;
        apk)
            $SUDO_CMD apk add --no-cache curl
            ;;
        *)
            echo "No se detecto un gestor de paquetes soportado. Instala curl manualmente y vuelve a ejecutar el script."
            return 1
            ;;
    esac

    if ! command -v curl >/dev/null 2>&1; then
        echo "No fue posible instalar curl automaticamente."
        return 1
    fi
}

configure_java_and_maven_env() {
    local java_home="$1"
    local m2_home="$2"
    local bashrc_file="$HOME/.bashrc"

    if [ -z "$java_home" ] || [ -z "$m2_home" ]; then
        echo "No se pudo configurar JAVA_HOME y M2_HOME: rutas invalidas."
        return 1
    fi

    if [ ! -d "$java_home" ]; then
        echo "Advertencia: JAVA_HOME apunta a un directorio inexistente: $java_home"
        return 1
    fi

    if [ ! -d "$m2_home" ]; then
        echo "Advertencia: M2_HOME apunta a un directorio inexistente: $m2_home"
        return 1
    fi

    if [ -f "$bashrc_file" ]; then
        grep -q 'export JAVA_HOME=' "$bashrc_file" && sed -i '/^export JAVA_HOME=/d' "$bashrc_file"
        grep -q 'export M2_HOME=' "$bashrc_file" && sed -i '/^export M2_HOME=/d' "$bashrc_file"
        grep -q 'export PATH=.*JAVA_HOME.*M2_HOME' "$bashrc_file" && sed -i '/^export PATH=.*JAVA_HOME.*M2_HOME/d' "$bashrc_file"
    fi

    cat >> "$bashrc_file" <<EOF

# Configuración de Java y Maven
export JAVA_HOME="$java_home"
export M2_HOME="$m2_home"
export PATH="\$JAVA_HOME/bin:\$M2_HOME/bin:\$PATH"
EOF

    export JAVA_HOME="$java_home"
    export M2_HOME="$m2_home"
    export PATH="$JAVA_HOME/bin:$M2_HOME/bin:$PATH"

    echo "Configuración añadida a $bashrc_file"
    echo "JAVA_HOME=$JAVA_HOME"
    echo "M2_HOME=$M2_HOME"
}

# LOAD CONFIGURATION
if [ -f "./config.env" ]; then
    . ./config.env
else
    echo "ERROR: config.env no encontrado en el directorio actual."
    exit 1
fi

install_curl_if_missing || exit 1

if [ -z "$URL_MVN" ]; then
    echo "ERROR: URL_MVN no esta definida en config.env"
    exit 1
fi

if [ -z "$URL_JDK" ]; then
    echo "ERROR: URL_JDK no esta definida en config.env"
    exit 1
fi

# FIND CURL VERSION
version=$(curl --version | head -n1 | awk '{print $2}')

# VALIDATE CURL
if [ -z "$version" ]; then
    echo "NOT INSTALLING CURL"
else
    echo "CURL OK : $version"
    echo "DELETE tar.gz + URL_MVN"
    rm -rf *.tar.gz
    rm -rf apache-maven*
    rm -rf "$HOME/apache-maven"

    echo "START DOWNLOAD: $URL_MVN"
    curl -O -S "$URL_MVN"
    echo "FINISH DOWNLOAD"

    file=$(ls | grep tar.gz)

    if [ -z "$file" ]; then
        echo "ERROR DOWNLOAD MAVEN"
    else
        echo "DOWNLOAD OK : $file"
        echo "UNZIP FILE"
        tar -xvf apache-*.tar.gz
        rm -rf apache-*.tar.gz
        file=$(ls | grep "apache-maven")

        if [ -z "$file" ]; then
            echo "ERROR UNZIP FILE"
        else
            echo "UNZIP FILE: OK"
            echo "MOVE apache-maven TO $HOME/apache-maven"
            mv "$file" "$HOME/apache-maven"

            echo "START DOWNLOAD JDK: $URL_JDK"
            curl -L -O -S "$URL_JDK"
            echo "FINISH DOWNLOAD JDK"

            jdk_file=$(basename "$URL_JDK")

            if [ -f "$jdk_file" ]; then
                echo "DOWNLOAD OK: $jdk_file"
                echo "EXTRACT JDK"
                tar -xzf "$jdk_file"
                jdk_dir=$(tar -tf "$jdk_file" | head -1 | cut -f1 -d"/")

                if [ -d "$jdk_dir" ]; then
                    echo "MOVE JDK TO $HOME/apache-maven/"
                    mv "$jdk_dir" "$HOME/apache-maven/"
                    echo "JDK COPIED"
                    configure_java_and_maven_env "$HOME/apache-maven/$jdk_dir" "$HOME/apache-maven"
                else
                    echo "ERROR EXTRACTING JDK"
                fi
                echo "CLEANING UP JDK TAR"
                rm -f "$jdk_file"
            else
                echo "ERROR DOWNLOADING JDK"
            fi
        fi
    fi
fi