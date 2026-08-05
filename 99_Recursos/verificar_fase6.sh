#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 6 (Almacenamiento Virtual y Cuotas)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba que los dos discos virtuales existen, estan montados, se
#           montaran solos tras reiniciar, y que las 7 carpetas de Boochan S.L.
#           tienen los permisos correctos. No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase6.sh
#   sudo ./verificar_fase6.sh
#
# El informe se guarda en verificacion-fase-6.txt, en la carpeta actual.
# Escenario completo: 99_Recursos/Escenario_Boochan_SL.md
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-6.txt"
FALLOS=0
AVISOS=0

BASE="/srv/samba/departamentos"
COMUN="/srv/samba/comun"
IMG_DEPTOS="/samba_deptos.img"
IMG_COMUN="/samba_comun.img"
DEPARTAMENTOS="facturacion contabilidad comercial logistica rrhh becarios"

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase6.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 6 - BoochanV1"
  echo " Escenario: Boochan S.L. - 6 carpetas de departamento + comun"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LA FASE 5
# =============================================================================
# Los permisos de este apartado se dan a los grupos de departamento. Si un
# grupo no se ve, el chown falla y la carpeta queda a nombre de root SIN AVISO.
echo "" | tee -a "$INFORME"
echo "--- A. Los departamentos de la Fase 5 ---" | tee -a "$INFORME"

# En un AD DC winbindd va DENTRO de 'samba': el servicio de systemd esta
# apagado a proposito. Lo que importa es que RESPONDA, no que corra aparte.
if wbinfo -p >/dev/null 2>&1; then
    ok "A1. winbind responde - los grupos del dominio son visibles"
else
    fallo "A1. winbind NO responde - el sistema no vera los grupos de departamento"
    info "     En un AD DC lo sirve samba-ad-dc. Revisa que este activo."
fi

FALTAN=""
for d in $DEPARTAMENTOS; do
    getent group "$d" >/dev/null 2>&1 || FALTAN="$FALTAN $d"
done
if [ -z "$FALTAN" ]; then
    ok "A2. Los 6 grupos de departamento son visibles"
else
    fallo "A2. No se ven estos grupos:$FALTAN"
    info "     Problema de la Fase 5. Arreglalo alli antes de seguir."
fi

# =============================================================================
# BLOQUE B - LOS DOS DISCOS VIRTUALES
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. Los discos virtuales ---" | tee -a "$INFORME"

comprueba_img() {
    local IMG="$1" MB_MIN="$2" MB_MAX="$3" ETIQUETA="$4"

    if [ ! -f "$IMG" ]; then
        fallo "$ETIQUETA. No existe $IMG"
        info "     Arreglo: repite el Paso 2 del procedimiento (dd)"
        return
    fi

    local MB
    MB=$(( $(stat -c %s "$IMG") / 1024 / 1024 ))
    if [ "$MB" -ge "$MB_MIN" ] && [ "$MB" -le "$MB_MAX" ]; then
        ok "$ETIQUETA. $IMG existe y mide ${MB} MB"
    else
        fallo "$ETIQUETA. $IMG mide ${MB} MB, fuera del rango esperado ($MB_MIN-$MB_MAX)"
        info "     El 'dd' se corto a medias. Mira el caso E4 del apartado 7."
    fi

    # Un .img sin formatear no se puede montar: 'wrong fs type'.
    if blkid "$IMG" 2>/dev/null | grep -q 'TYPE="ext4"'; then
        ok "$ETIQUETA-bis. $IMG tiene sistema de ficheros ext4"
    else
        fallo "$ETIQUETA-bis. $IMG NO esta formateado como ext4"
        info "     Arreglo: sudo mkfs.ext4 $IMG"
    fi
}

comprueba_img "$IMG_DEPTOS" 8000 8400 "B1"
comprueba_img "$IMG_COMUN"  2000 2150 "B2"

# =============================================================================
# BLOQUE C - MONTAJE: AHORA Y TRAS REINICIAR
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Montaje ---" | tee -a "$INFORME"

comprueba_montaje() {
    local PUNTO="$1" IMG="$2" ETIQUETA="$3"

    if mountpoint -q "$PUNTO"; then
        ok "$ETIQUETA. $PUNTO esta montado AHORA"
    else
        fallo "$ETIQUETA. $PUNTO NO esta montado - es una carpeta normal del sistema"
        info "     Lo que escribas ahi NO va al disco virtual. Arreglo: sudo mount -a"
    fi

    if grep -q "^[^#]*$IMG[[:space:]]\+$PUNTO" /etc/fstab 2>/dev/null; then
        ok "$ETIQUETA-bis. $PUNTO tiene su linea en /etc/fstab (sobrevive al reinicio)"
        if grep "^[^#]*$IMG[[:space:]]\+$PUNTO" /etc/fstab | grep -q "loop"; then
            ok "$ETIQUETA-ter. La linea lleva la opcion 'loop'"
        else
            fallo "$ETIQUETA-ter. La linea de $PUNTO NO lleva 'loop'"
            info "     NO REINICIES hasta arreglarlo. Caso E1 del apartado 7."
        fi
    else
        fallo "$ETIQUETA-bis. $PUNTO no aparece en /etc/fstab - hoy funciona, manana no"
    fi
}

comprueba_montaje "$BASE"  "$IMG_DEPTOS" "C1"
comprueba_montaje "$COMUN" "$IMG_COMUN"  "C2"

# C3. El paracaidas: 'mount -a' en seco. Si esto falla, el arranque tambien.
if mount -a --fake >/dev/null 2>&1; then
    ok "C3. /etc/fstab no tiene errores de sintaxis (mount -a --fake)"
else
    fallo "C3. /etc/fstab TIENE ERRORES - el servidor podria no arrancar"
    info "     NO REINICIES. Corrigelo y vuelve a pasar el verificador."
fi

# =============================================================================
# BLOQUE D - LAS SEIS CARPETAS DE DEPARTAMENTO
# =============================================================================
# Aqui esta el fallo silencioso: si winbind no veia el grupo cuando se ejecuto
# el chown, la carpeta quedo a nombre de root. No da error y rompe la Fase 7.
echo "" | tee -a "$INFORME"
echo "--- D. Carpetas de departamento ---" | tee -a "$INFORME"

N=0
for d in $DEPARTAMENTOS; do
    N=$((N+1))
    RUTA="$BASE/$d"

    if [ ! -d "$RUTA" ]; then
        fallo "D$N. No existe la carpeta $RUTA"
        continue
    fi

    # 'stat %G' devuelve el grupo con el prefijo del dominio (BOOCHANLAB\grupo).
    # Nos quedamos con lo que va detras de la barra para poder compararlo.
    GRUPO=$(stat -c %G "$RUTA")
    GRUPO_CORTO="${GRUPO##*\\}"
    PERM=$(stat -c %a "$RUTA")

    if [ "$GRUPO_CORTO" != "$d" ]; then
        fallo "D$N. $RUTA pertenece al grupo '$GRUPO', deberia ser '$d'"
        info "     El chown fallo (probablemente winbind estaba parado) y nadie aviso."
        info "     FUNCIONA HOY y ROMPERA LA FASE 7. Caso E6 del apartado 7."
    elif [ "$PERM" = "2770" ]; then
        ok "D$N. $d -> grupo '$GRUPO', permisos 2770 (setgid puesto)"
    elif [ "$PERM" = "770" ]; then
        fallo "D$N. $d tiene 770: FALTA EL BIT SETGID"
        info "     Los ficheros nuevos no heredaran el grupo '$d'."
        info "     Arreglo: sudo chmod 2770 $RUTA"
    else
        fallo "D$N. $d tiene permisos $PERM, deberian ser 2770"
    fi
done

# =============================================================================
# BLOQUE E - LA CARPETA COMUN Y SU STICKY BIT
# =============================================================================
# Sin el sticky bit, cualquiera puede borrar el fichero de cualquiera. Es el
# mecanismo de /tmp, y aqui protege el trabajo de seis departamentos.
echo "" | tee -a "$INFORME"
echo "--- E. La carpeta comun ---" | tee -a "$INFORME"

if [ -d "$COMUN" ]; then
    PERM_C=$(stat -c %a "$COMUN")
    if [ "$PERM_C" = "1777" ]; then
        ok "E1. $COMUN con permisos 1777 (sticky bit puesto)"
    elif [ "$PERM_C" = "777" ]; then
        fallo "E1. $COMUN tiene 777: FALTA EL STICKY BIT"
        info "     Cualquiera puede borrar el fichero de cualquiera."
        info "     Arreglo: sudo chmod 1777 $COMUN"
    else
        fallo "E1. $COMUN tiene permisos $PERM_C, deberian ser 1777"
    fi

    # La 't' final es la marca visible del sticky bit en ls -ld.
    if ls -ld "$COMUN" | cut -c1-10 | grep -q "t$"; then
        ok "E2. La 't' del sticky bit se ve en ls -ld"
    else
        fallo "E2. No se ve la 't' en $(ls -ld "$COMUN" | cut -c1-10)"
    fi
else
    fallo "E1. No existe $COMUN"
fi

# =============================================================================
# BLOQUE F - CADA VOLUMEN CON SU LIMITE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- F. Los limites de cada volumen ---" | tee -a "$INFORME"

comprueba_tamano() {
    local PUNTO="$1" MIN="$2" MAX="$3" ETIQUETA="$4" NOMBRE="$5"
    if mountpoint -q "$PUNTO"; then
        local TAM
        TAM=$(df -BM --output=size "$PUNTO" 2>/dev/null | tail -1 | tr -dc '0-9')
        if [ -n "$TAM" ] && [ "$TAM" -ge "$MIN" ] && [ "$TAM" -le "$MAX" ]; then
            ok "$ETIQUETA. $NOMBRE tiene su propio limite (~${TAM} MB)"
        else
            aviso "$ETIQUETA. $NOMBRE declara ${TAM} MB - revisa que sea el disco virtual"
        fi
    fi
}

comprueba_tamano "$BASE"  7000 8400 "F1" "El volumen de departamentos"
comprueba_tamano "$COMUN" 1700 2150 "F2" "La carpeta comun"

# F3. Que sean volumenes DISTINTOS es el objetivo: que llenar uno no afecte
#     al otro. Si comparten dispositivo, la separacion no existe.
if mountpoint -q "$BASE" && mountpoint -q "$COMUN"; then
    DEV1=$(df --output=source "$BASE"  | tail -1)
    DEV2=$(df --output=source "$COMUN" | tail -1)
    if [ "$DEV1" != "$DEV2" ]; then
        ok "F3. Son volumenes distintos: llenar la comun no afecta a los departamentos"
    else
        fallo "F3. Los dos puntos usan el MISMO dispositivo ($DEV1)"
        info "     La separacion no existe: un usuario podria dejar sin sitio a todos."
    fi
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 6 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 6 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 6 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_6.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que el limite frene de verdad (hay que llenarlo con dd)"
  echo "  - Que el sticky bit impida borrar lo ajeno (hay que probarlo)"
  echo "  - Que exista la instantanea 'Fase 6 terminada' ni la copia .ova"
  echo "Esas se verifican A MANO. Las tienes en el apartado 8.a."
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
