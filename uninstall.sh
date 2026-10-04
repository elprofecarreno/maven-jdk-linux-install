#!/bin/bash

remove_env_vars_from_bashrc() {
    local bashrc_file="$HOME/.bashrc"

    if [ ! -f "$bashrc_file" ]; then
        echo "No existe $bashrc_file. Nada que limpiar."
        return 0
    fi

    local backup_file="$bashrc_file.backup-before-uninstall"
    cp "$bashrc_file" "$backup_file"

    sed -i '/^# Configuración de Java y Maven$/d' "$bashrc_file"
    sed -i '/^export JAVA_HOME=/d' "$bashrc_file"
    sed -i '/^export M2_HOME=/d' "$bashrc_file"
    sed -i '/^export PATH=.*JAVA_HOME.*M2_HOME.*$/d' "$bashrc_file"

    echo "Se limpió la configuración de JAVA_HOME y M2_HOME en $bashrc_file"
    echo "Se creó una copia de seguridad en $backup_file"
}

remove_installed_directories() {
    local maven_dir="$HOME/apache-maven"

    if [ -d "$maven_dir" ]; then
        rm -rf "$maven_dir"
        echo "Se eliminó $maven_dir"
    else
        echo "No existe $maven_dir. Se omite."
    fi
}

unset_java_and_maven_vars() {
    unset JAVA_HOME
    unset M2_HOME
    export PATH="$(echo "$PATH" | sed 's#'$HOME'/apache-maven/bin:##; s#'$HOME'/apache-maven/bin##; s#'$HOME'/apache-maven/:##; s#'$HOME'/apache-maven##')"
    echo "Variables del entorno actual limpiadas."
}

main() {
    echo "Iniciando desinstalación de Java y Maven..."

    remove_env_vars_from_bashrc
    remove_installed_directories
    unset_java_and_maven_vars

    echo "Desinstalación completada."
    echo "Recuerda recargar tu shell con: source ~/.bashrc"
}

main "$@"
