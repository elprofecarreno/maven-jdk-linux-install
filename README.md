# Maven + JDK Installer

Este proyecto instala Apache Maven y JDK en Linux, y configura las variables de entorno `JAVA_HOME` y `M2_HOME` en el archivo `.bashrc`.

## Archivos incluidos

- `install.sh`: descarga e instala Maven y JDK.
- `uninstall.sh`: elimina la instalación y limpia las variables de entorno.
- `config.env`: contiene las URLs de descarga de Maven y JDK.

## Requisitos

- Sistema Linux con acceso a internet.
- `curl` (el script lo instala si hace falta).
- Permisos para escribir en `$HOME` y usar `sudo` si es necesario.

## Instalación

1. Asegúrate de estar en la carpeta del proyecto:

```bash
cd /ruta/al/proyecto
```

2. Ejecuta el instalador:

```bash
bash install.sh
```

O directamente:

```bash
./install.sh
```

3. Luego recarga tu shell:

```bash
source ~/.bashrc
```

4. Verifica la instalación:

```bash
java -version
mvn -version
```

## Desinstalación

```bash
bash uninstall.sh
```

O:

```bash
./uninstall.sh
```

Luego recarga tu shell:

```bash
source ~/.bashrc
```

## Variables de entorno configuradas

El script agrega al final de `.bashrc` algo similar a:

```bash
export JAVA_HOME="$HOME/apache-maven/jdk-21"
export M2_HOME="$HOME/apache-maven"
export PATH="$JAVA_HOME/bin:$M2_HOME/bin:$PATH"
```

## Configuración de URLs

El archivo `config.env` tiene las URLs de descarga:

```bash
URL_MVN=https://dlcdn.apache.org/maven/maven-3/3.10.0/binaries/apache-maven-3.10.0-bin.tar.gz
URL_JDK=https://download.oracle.com/java/21/archive/jdk-21.0.7_linux-x64_bin.tar.gz
```

Puedes modificar estas URLs si necesitas otra versión.
