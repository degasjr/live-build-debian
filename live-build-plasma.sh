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
WORK_DIR="./live-build-plasma"
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
ark
attr
avahi-daemon
avahi-utils
bash-completion
bluedevil
bluetooth
breeze
breeze-gtk-theme
btop
chntpw
cifs-utils
colord
command-not-found
cpufrequtils
cups
curl
dmz-cursor-theme
dnsmasq-base
dns-root-data
dolphin
dolphin-plugins
fastboot
fatattr
ffmpeg
ffmpegthumbs
filelight
firefox-esr
firefox-esr-l10n-es-mx
firmware-iwlwifi
firmware-linux-free
flac
fonts-dejavu
fonts-droid-fallback
fonts-font-awesome
fonts-liberation2
fonts-noto-cjk
fonts-recommended
fonts-texgyre
gallery-dl
git
gnome-disk-utility
gnome-font-viewer
gparted
gwenview
hplip-gui
intel-microcode
iputils-ping
iso-codes
kate
kcalc
kcharselect
kcolorchooser
kde-config-cron
kde-config-screenlocker
kde-plasma-desktop
kde-spectacle
kdeconnect
kdegraphics-thumbnailers
keepassxc
kfind
kinfocenter
konsole
kruler
kscreen
ksshaskpass
kwin-x11
libreoffice-calc
libreoffice-draw
libreoffice-impress
libreoffice-kf5
libreoffice-l10n-es
libreoffice-plasma
libreoffice-writer
linux-image-amd64
metadata-cleaner
minidlna
mobile-broadband-provider-info
modemmanager
myspell-es
nano
neofetch
nmap
okular
opus-tools
p7zip-full
parallel
plasma-disks
plasma-nm
plasma-pa
plasma-widgets-addons
plasma-workspace-wallpapers
polkit-kde-agent-1
powerdevil
powertop
print-manager
printer-driver-all-enforce
pulseaudio
pulseaudio-module-bluetooth
samba
samba-ad-provision
samba-dsdb-modules
samba-vfs-modules
sddm
sddm-theme-breeze
shellcheck
shfmt
simple-scan
smbclient
sox
ssh
sudo
sweeper
swh-plugins
synaptic
system-config-printer-common
system-config-printer-udev
systemsettings
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
