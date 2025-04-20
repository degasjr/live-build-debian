#!/bin/bash

set -e

# Variables
DISTRIBUTION="bookworm" # Debian 12

# Paquetes del núcleo y módulos
KERNEL_PACKAGES="linux-image-amd64 firmware-linux-free firmware-iwlwifi"

# Paquetes del escritorio
DESKTOP_PACKAGES="xfce4 xfce4-terminal xfce4-goodies xfce4-power-manager lightdm network-manager-gnome wireless-tools bluetooth pulseaudio pulseaudio-module-bluetooth fonts-recommended fonts-dejavu fonts-noto-cjk dmz-cursor-theme"

# Paquetes de localización
LANG_PACKAGES="task-spanish"

# Paquetes adicionales
CMD_PACKAGES="bash-completion command-not-found shellcheck shfmt sudo nano git iputils-ping wget whois nmap curl ssh sox flac opus-tools ffmpeg samba smbclient winbind cifs-utils cups printer-driver-all parallel gallery-dl minidlna swh-plugins webp woff2 fatattr powertop adb fastboot chntpw testdisk thermald cpufrequtils btop neofetch"

# Paquetes gráficos adicionales
GUI_PACKAGES="synaptic gnome-disk-utility gparted firefox-esr firefox-esr-l10n-es-mx libreoffice-calc libreoffice-impress libreoffice-writer libreoffice-draw libreoffice-l10n-es libreoffice-gtk3 myspell-es system-config-printer hplip-gui simple-scan gimp inkscape vlc vlc-l10n obs-studio audacity qbittorrent keepassxc metadata-cleaner gnome-font-viewer goldendict goldendict-wordnet"

# Funciones
log_info() {
  echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    log_error "El comando '$1' no está instalado. Por favor, instálalo."
    exit 1
  fi
}

# 1. Verificar dependencias
log_info "Verificando dependencias..."
check_command live-build
check_command sudo
check_command debootstrap
check_command apt-cache
check_command awk

# 2. Crear directorio de trabajo
WORK_DIR="./live-build-bookworm"
if [ -d "$WORK_DIR" ]; then
  log_info "El directorio de trabajo '$WORK_DIR' ya existe. Se eliminará."
  rm -rf "$WORK_DIR"
fi
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 3. Inicializar la configuración de live-build
log_info "Inicializando la configuración de live-build..."
lb config \
  --apt-source-archives false \
  --architecture "amd64" \
  --archive-areas "main non-free-firmware" \
  --backports false \
  --bootappend-live "boot=live components locales=es_VE.UTF-8 keyboard-layouts=es timezone=America/Caracas live-config.username=usuario live-config.user-fullname='Usuario Debian en vivo'" \
  --clean \
  --debian-installer live \
  --debian-installer-distribution "$DISTRIBUTION"\
  --distribution "$DISTRIBUTION" \
  --iso-application "Debian GNU/Linux - En Vivo" \
  --iso-publisher "Alexis Adam; https://github.com/degasjr" \
  --security true \
  --updates false \
  --win32-loader false

# 4. Configurar paquetes
log_info "Configurando paquetes..."
echo "$KERNEL_PACKAGES" >> config/package-lists/kernel.list.chroot
echo "$DESKTOP_PACKAGES" >> config/package-lists/desktop.list.chroot
echo "$LANG_PACKAGES" >> config/package-lists/lang.list.chroot
echo "$CMD_PACKAGES" >> config/package-lists/cmd.list.chroot
echo "$GUI_PACKAGES" >> config/package-lists/gui.list.chroot

# 5. Construir la imagen ISO
log_info "Construyendo la imagen ISO. Esto puede tardar un tiempo..."
sudo lb build

# 6. Finalización
if [ -f "live-image-amd64.hybrid.iso" ]; then
  ISO_PATH=$(find live-image-amd64.hybrid.iso -type f)
  log_info "¡La imagen ISO se ha creado exitosamente en: $ISO_PATH!"
  log_info "Puedes usar esta imagen para crear un USB booteable o una máquina virtual."
else
  log_error "¡Error al construir la imagen ISO!"
fi

cd ..
log_info "Limpiando el directorio de trabajo '$WORK_DIR'..."
# rm -rf "$WORK_DIR" # Descomenta esta línea para eliminar el directorio de trabajo después
log_info "¡Proceso completado!"
