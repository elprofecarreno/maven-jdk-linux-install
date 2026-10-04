# Maven + JDK Installer

This project installs Apache Maven and a JDK on Linux and configures the environment variables `JAVA_HOME` and `M2_HOME` in `.bashrc`.

## Included files

- `install.sh`: downloads and installs Maven and JDK.
- `uninstall.sh`: removes the installation and cleans the environment variables.
- `config.env`: stores the download URLs for Maven and JDK.

## Requirements

- Linux system with internet access.
- `curl` (the script installs it automatically if needed).
- Write permissions in `$HOME` and `sudo` access if required by your system.

## Installation

1. Go to the project folder:

```bash
cd /path/to/project
```

2. Run the installer:

```bash
bash install.sh
```

Or directly:

```bash
./install.sh
```

3. Reload your shell:

```bash
source ~/.bashrc
```

4. Verify the installation:

```bash
java -version
mvn -version
```

## Uninstallation

```bash
bash uninstall.sh
```

Or:

```bash
./uninstall.sh
```

Then reload your shell:

```bash
source ~/.bashrc
```

## Environment variables configured

The script adds entries similar to the following at the end of `.bashrc`:

```bash
export JAVA_HOME="$HOME/apache-maven/jdk-21"
export M2_HOME="$HOME/apache-maven"
export PATH="$JAVA_HOME/bin:$M2_HOME/bin:$PATH"
```

## Download configuration

The file `config.env` contains the download URLs:

```bash
URL_MVN=https://dlcdn.apache.org/maven/maven-3/3.10.0/binaries/apache-maven-3.10.0-bin.tar.gz
URL_JDK=https://download.oracle.com/java/21/archive/jdk-21.0.7_linux-x64_bin.tar.gz
```

You can change these values if you want to use a different version.
