# BC-250 40 CU Unlocker (CachyOS / Arch Linux Edition)

[🇪🇸 Leer en Español](#español) | [🇬🇧 Read in English](#english)

---

## 🇬🇧 English

This guide and wrapper scripts provide everything needed to permanently unlock the 40 CUs (Compute Units) of the AMD BC-250 card on systems based on **CachyOS** and **Arch Linux**.

### Why a specific process for CachyOS / Arch?
In Debian/Ubuntu-based distributions, simply compiling the module and updating system dependencies is enough. However, CachyOS and Arch Linux load the video driver early during boot (Early KMS) directly from the `initramfs`.

If we only compile the module, the system will continue to load the original version hosted in the initial ramdisk memory at boot time. Therefore, the key step in these distributions is to package the new module and its configuration using `mkinitcpio`.

### IMPORTANT Prerequisites
1. **Base Toolkit**: You MUST have the base [bc250-toolkit](https://github.com/redbeard1083/bc250-toolkit) installed and configured beforehand.
2. **Modified BIOS**: It is absolutely necessary to have flashed the modified BIOS to your BC-250 so the 40 CU unlock is hardware-possible.
3. An active installation of CachyOS or Arch Linux.
4. Internet connection to download kernel headers and compilation tools (`base-devel`).
5. Administrator (`sudo`) privileges.

### Step-by-Step Instructions

#### 1. Clone the repository
First, download the source code of the project and enter the directory:
```bash
git clone https://github.com/YOUR_USER/bc250-40cu-unlock.git
cd bc250-40cu-unlock
```

#### 2. Run the wrapper script
Run the English installation wrapper with administrator privileges:
```bash
sudo ./cachyos-install-en.sh
```
> **Note for Limine users:** During the final step, if the terminal asks `Do you want to run 'limine-mkinitcpio' now? [Y/n]`, press **Y** and then Enter. This ensures the image is correctly copied to the proper boot directory.

#### 3. Reboot and verify
Reboot your computer for the changes to take effect:
```bash
sudo reboot
```

When the system boots back up, check if the 40 CUs are active by running:
```bash
sudo ./scripts/bc250-enable-40cu.sh status
```
You should see output indicating: `active CUs: 40 (full die)` and your system will be ready to harness its full graphical potential!

---

## 🇪🇸 Español

Esta guía y scripts proporcionan todo lo necesario para desbloquear de forma permanente los 40 CUs (Compute Units) de la tarjeta AMD BC-250 en sistemas basados en **CachyOS** y **Arch Linux**.

### ¿Por qué un proceso específico para CachyOS / Arch?
En distribuciones basadas en Debian/Ubuntu, basta con compilar el módulo y actualizar las dependencias del sistema. Sin embargo, CachyOS y Arch Linux cargan el driver de video de manera temprana durante el arranque (Early KMS) directamente desde el `initramfs`. 

Si solamente compilamos el módulo, el sistema seguirá cargando la versión original alojada en la memoria ramdisk inicial al momento de arrancar. Por ello, el paso clave en estas distribuciones es empaquetar el nuevo módulo y su configuración utilizando `mkinitcpio`.

### Requisitos Previos IMPORTANTES
1. **Toolkit Base**: Debes tener instalado y configurado previamente el entorno base [bc250-toolkit](https://github.com/redbeard1083/bc250-toolkit).
2. **BIOS Modificada**: Es absolutamente necesario haber instalado (flasheado) la BIOS modificada en tu BC-250 para que la habilitación de los 40 CUs sea posible a nivel de hardware.
3. Una instalación activa de CachyOS o Arch Linux.
4. Conexión a internet para descargar las cabeceras del kernel y herramientas de compilación (`base-devel`).
5. Privilegios de administrador (`sudo`).

### Instrucciones Paso a Paso

#### 1. Clonar el repositorio
Primero, descarga el código fuente del proyecto original y entra en el directorio:
```bash
git clone https://github.com/TU_USUARIO/bc250-40cu-unlock.git
cd bc250-40cu-unlock
```

#### 2. Ejecutar el script instalador
Ejecuta la versión en español del script con privilegios de administrador:
```bash
sudo ./cachyos-install-es.sh
```
> **Nota para usuarios de Limine:** Durante el último paso, si la terminal te pregunta `Do you want to run 'limine-mkinitcpio' now? [Y/n]`, presiona **Y** y luego Enter. Esto asegurará que la imagen se copie correctamente al directorio de arranque adecuado.

#### 3. Reiniciar y verificar
Reinicia el equipo para que los cambios surtan efecto:
```bash
sudo reboot
```

Al volver al sistema, puedes comprobar si los 40 CUs están activos ejecutando:
```bash
sudo ./scripts/bc250-enable-40cu.sh status
```
Deberías ver una salida indicando: `active CUs: 40 (full die)` y tu sistema estará listo para aprovechar todo el potencial gráfico.
