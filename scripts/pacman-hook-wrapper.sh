#!/bin/bash
while read -r path; do
    if [[ "$path" == usr/lib/modules/*/pkgbase ]]; then
        KVER=$(echo "$path" | cut -d/ -f4)
        echo -e "\n========================================================="
        echo " BC-250: Parcheando módulo amdgpu para kernel: $KVER"
        echo "========================================================="
        TARGET_KVER="$KVER" /opt/bc250-40cu-unlock/scripts/bc250-enable-40cu-arch.sh build
    fi
done

