#!/bin/bash

set -e

# Variables
DISTRIBUTION="bookworm" # Debian 12

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

# Verificar dependencias
log_info "Verificando dependencias..."
check_command live-build
check_command sudo
check_command debootstrap
check_command apt-cache
check_command awk

# Crear directorio de trabajo
WORK_DIR="./live-build-gnome"
if [ -d "$WORK_DIR" ]; then
  log_info "El directorio de trabajo '$WORK_DIR' ya existe. Se eliminará."
  rm -rf "$WORK_DIR"
fi
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Inicializar la configuración de live-build
log_info "Inicializando la configuración de live-build..."
lb config \
  --apt-indices false \
  --apt-recommends false \
  --apt-source-archives false \
  --architecture "amd64" \
  --archive-areas "main non-free-firmware" \
  --backports false \
  --bootappend-live "boot=live components locales=es_VE.UTF-8 keyboard-layouts=es,us timezone=America/Caracas live-config.username=usuario live-config.user-fullname=Usuario" \
  --clean \
  --debian-installer none \
  --debian-installer-distribution "$DISTRIBUTION" \
  --distribution "$DISTRIBUTION" \
  --iso-application "Debian GNU/Linux - En Vivo" \
  --iso-publisher "Alexis Adam; https://github.com/degasjr" \
  --security true \
  --updates false \
  --win32-loader false

# Configurar paquetes
log_info "Configurando paquetes..."

cat > config/package-lists/paquetes.list.chroot << 'EOF'
adb
attr
avahi-daemon
avahi-utils
baobab
bash-completion
bleachbit
bluetooth
btop
ca-certificates
cheese
chntpw
cifs-utils
colord
command-not-found
cpufrequtils
cups
curl
deja-dup
dmz-cursor-theme
dnsmasq-base
dns-root-data
dosfstools
e2fsprogs
eject
eog
epiphany-browser
evince
exfatprogs
fastboot
fatattr
ffmpeg
file-roller
firmware-iwlwifi
firmware-linux-free
flac
foliate
fonts-croscore
fonts-crosextra-caladea
fonts-crosextra-carlito
fonts-dejavu
fonts-droid-fallback
fonts-font-awesome
fonts-freefont-otf
fonts-liberation
fonts-liberation2
fonts-noto-cjk
fonts-noto-color-emoji
fonts-texgyre
fonts-unifont
fonts-urw-base35
gallery-dl
git
gnome-calendar
gnome-chess
gnome-clocks
gnome-color-manager
gnome-core
gnome-firmware
gnome-flashback
gnome-icon-theme
gnome-keyring
gnome-keyring-pkcs11
gnome-power-manager
gnome-screenshot
gnome-session-flashback
gnome-tweaks
gparted
gvfs-backends
hplip
intel-microcode
iputils-ping
keepassxc
libpam-systemd
libreoffice-calc
libreoffice-draw
libreoffice-gnome
libreoffice-gtk3
libreoffice-impress
libreoffice-l10n-es
libreoffice-writer
linux-image-amd64
low-memory-monitor
metadata-cleaner
minidlna
mobile-broadband-provider-info
modemmanager
myspell-es
nano
nautilus
neofetch
network-manager-gnome
nmap
notification-daemon
ntfs-3g
opus-tools
parallel
planner
powertop
printer-driver-all-enforce
samba
samba-ad-provision
samba-dsdb-modules
samba-vfs-modules
shellcheck
shfmt
simple-scan
smartmontools
smbclient
sox
ssh
sudo
synaptic
system-config-printer-common
system-config-printer-udev
task-spanish
testdisk
thermald
usb-modeswitch
user-setup
vlc
vlc-l10n
webp
wget
whois
winbind
wireless-regdb
wireless-tools
woff2
wpasupplicant
wspanish
yelp
EOF

# Construir la imagen ISO
log_info "Construyendo la imagen ISO. Esto puede tardar un tiempo..."
sudo lb build

# Finalización
if [ -f "live-image-amd64.hybrid.iso" ]; then
  log_info "La imagen ISO se ha creado exitosamente en: $(pwd)/live-image-amd64.hybrid.iso"
else
  log_error "¡Error al construir la imagen ISO!"
fi

cd ..
log_info "¡Proceso completado!"
