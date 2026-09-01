#!/usr/bin/env python3
"""
fix-bc250-patch-location.py v2
Mueve el bloque bc250 CU unlock al lugar correcto en gfx_v10_0_get_cu_info().
Enfoque linea por linea para evitar problemas con tabs/espacios/UTF-8.
"""
import sys, shutil

GFXFILE = '/usr/src/linux-cachyos/drivers/gpu/drm/amd/amdgpu/gfx_v10_0.c'
BACKUP  = GFXFILE + '.bc250-orig-backup'

def die(msg):
    print(f"[ERROR] {msg}", file=sys.stderr)
    sys.exit(1)

def info(msg):
    print(f"[+] {msg}")

# ── 1. Leer archivo línea por línea ──────────────────────────────────────────
with open(GFXFILE, 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

shutil.copy2(GFXFILE, BACKUP)
info(f"Backup: {BACKUP}")
info(f"Total lineas: {len(lines)}")

# ── 2. Encontrar el bloque bc250 (en el lugar equivocado) ────────────────────
# Buscar el comentario usando .strip() para evitar problemas de tabs/espacios
bc250_start = None
for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith('/* BC-250: unlock harvested CUs'):
        bc250_start = i
        info(f"Comentario bc250 encontrado en linea {i+1}: {stripped[:60]!r}")
        break

if bc250_start is None:
    die("No se encontro el comentario /* BC-250: unlock harvested CUs")

# Incluir la linea en blanco anterior si existe
block_first = bc250_start
if bc250_start > 0 and lines[bc250_start - 1].strip() == '':
    block_first = bc250_start - 1

# Encontrar el final del bloque: buscar gfx_v10_0_select_se_sh seguido de la
# linea de cierre de la if (que es solo '}' al mismo nivel de indentacion)
bc250_end = None
select_found = False
for i in range(bc250_start, min(bc250_start + 70, len(lines))):
    stripped = lines[i].strip()
    if 'gfx_v10_0_select_se_sh(adev, 0xffffffff, 0xffffffff, 0xffffffff, 0)' in stripped:
        select_found = True
    if select_found and stripped == '}':
        bc250_end = i
        break

if bc250_end is None:
    die("No se encontro el final del bloque bc250 (gfx_v10_0_select_se_sh + })")

info(f"Bloque bc250: lineas {block_first+1} a {bc250_end+1} ({bc250_end - block_first + 1} lineas)")

# Extraer el bloque (sin la linea en blanco previa, la agregaremos en insercion)
bc250_block = lines[bc250_start:bc250_end + 1]  # sin blank line previa

# ── 3. Eliminar bloque del lugar incorrecto ──────────────────────────────────
lines_clean = lines[:block_first] + lines[bc250_end + 1:]

# Verificacion
bc250_still_there = any(
    '/* BC-250: unlock harvested CUs' in l.strip() for l in lines_clean
)
if bc250_still_there:
    die("El bloque bc250 sigue en el archivo despues de eliminarlo (hay dos copias?)")

info("Bloque bc250 eliminado del lugar incorrecto")

# ── 4. Encontrar la definicion de gfx_v10_0_get_cu_info ──────────────────────
# Buscar la ULTIMA ocurrencia (hay un prototipo antes y la definicion despues)
func_line = None
for i, line in enumerate(lines_clean):
    if 'static int gfx_v10_0_get_cu_info(' in line:
        func_line = i  # la ultima encontrada es la definicion real

if func_line is None:
    die("No se encontro gfx_v10_0_get_cu_info en el archivo")

info(f"gfx_v10_0_get_cu_info definicion en linea {func_line+1}")

# ── 5. Encontrar mutex_lock(&adev->grbm_idx_mutex) DENTRO de esa funcion ─────
insert_after = None
for i in range(func_line, min(func_line + 80, len(lines_clean))):
    if 'mutex_lock(&adev->grbm_idx_mutex)' in lines_clean[i]:
        insert_after = i
        break

if insert_after is None:
    die("No se encontro mutex_lock(&adev->grbm_idx_mutex) en gfx_v10_0_get_cu_info")

info(f"Punto de insercion (mutex_lock): linea {insert_after+1}")
info(f"  Contenido: {lines_clean[insert_after].rstrip()!r}")

# Verificar que la linea siguiente es el for loop
next_line = lines_clean[insert_after + 1].strip() if insert_after + 1 < len(lines_clean) else ''
if not next_line.startswith('for (i = 0'):
    info(f"  ADVERTENCIA: la siguiente linea no es el for loop esperado: {next_line!r}")
    info("  Continuando de todas formas...")

# ── 6. Insertar el bloque en el lugar correcto ───────────────────────────────
# Insertar despues del mutex_lock: blank line + bloque + blank line
insert_block = ['\n'] + bc250_block + ['\n']
lines_final = (lines_clean[:insert_after + 1] +
               insert_block +
               lines_clean[insert_after + 1:])

# ── 7. Verificacion final ────────────────────────────────────────────────────
ok = False
for i, line in enumerate(lines_final):
    if '/* BC-250: unlock harvested CUs' in line.strip():
        info(f"Verificacion OK: bloque bc250 en linea {i+1}")
        ok = True
        break

if not ok:
    die("El bloque bc250 no se encontro en el archivo final")

# ── 8. Escribir archivo ──────────────────────────────────────────────────────
with open(GFXFILE, 'w', encoding='utf-8') as f:
    f.writelines(lines_final)

info("Archivo escrito exitosamente.")
info("")
info("Verifica con:")
info("  sudo grep -n 'bc250' /usr/src/linux-cachyos/drivers/gpu/drm/amd/amdgpu/gfx_v10_0.c")
