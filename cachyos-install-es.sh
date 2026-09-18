#!/usr/bin/env bash
# cachyos-install-es.sh
# Wrapper para instalar el parche de 40 CU de la BC-250 en CachyOS / Arch Linux

set -euo pipefail

echo "================================================="
echo "   BC-250 40 CU Unlocker - CachyOS / Arch Edition"
echo "================================================="

if [ "$EUID" -ne 0 ]; then
  echo "Error: Por favor, ejecuta este script con sudo."
  exit 1
fi

echo "================================================="
echo " IMPORTANTE: Requisitos Previos"
echo "================================================="
echo "Para que este script funcione correctamente, DEBES cumplir con:"
echo " 1. Tener instalado/configurado el bc250-toolkit de redbeard1083."
echo " 2. Tener flasheada la BIOS modificada en tu BC-250."
echo ""
read -p "¿Cumples con ambos requisitos? (Escribe 'y' para continuar, o cualquier otra tecla para cancelar): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Instalación cancelada. Por favor, asegúrate de cumplir los requisitos primero."
    exit 1
fi

echo "[1/4] Instalando dependencias del sistema..."
pacman -S --needed --noconfirm base-devel zstd git

# Detectar dinámicamente el paquete del kernel actual para instalar sus headers
KERNEL_PKG=$(pacman -Qo /usr/lib/modules/$(uname -r)/kernel 2>/dev/null | awk '{print $5}')
if [ -n "$KERNEL_PKG" ]; then
    HEADER_PKG="${KERNEL_PKG}-headers"
    echo "Instalando headers para el kernel actual: $HEADER_PKG"
    pacman -S --needed --noconfirm "$HEADER_PKG"
else
    echo "Advertencia: No se pudo detectar el paquete del kernel dinámicamente."
    echo "Asegúrate de tener instalados los headers correctos (ej. linux-cachyos-headers)."
fi

echo "[2/4] Ejecutando compilación del módulo..."
# Llamar al script original solo para compilar e instalar el módulo
if [ ! -f "./scripts/bc250-enable-40cu-arch.sh" ]; then
    echo "Error: No se encuentra ./scripts/bc250-enable-40cu-arch.sh"
    echo "Asegúrate de ejecutar este script desde la raíz del repositorio."
    exit 1
fi

./scripts/bc250-enable-40cu-arch.sh build

echo "[3/4] Configurando parámetros del kernel (modprobe)..."
CONF40="/etc/modprobe.d/bc250-40cu.conf"
printf '# BC-250 40 CU re-enablement\noptions amdgpu bc250_cc_write_mode=3\n' > "$CONF40"
echo "Archivo modprobe creado: $CONF40"

echo "[4/4] Reconstruyendo initramfs (mkinitcpio)..."
# Vital en Arch/CachyOS para cargar el módulo parcheado de forma temprana en el arranque (KMS)
cp patch/hooks/89-amdgpu-bc250.hook /etc/pacman.d/hooks/
mkinitcpio -P

echo "================================================="
echo "¡Todo listo! El módulo y el initramfs han sido actualizados exitosamente."
echo "IMPORTANTE: Si usas Limine y el sistema te pide confirmar (limine-mkinitcpio), presiona 'Y'."
echo "Para aplicar los cambios y disfrutar de los 40 CUs, reinicia tu sistema:"
echo "   sudo reboot"
echo "================================================="
