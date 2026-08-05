#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 6 (Almacenamiento Virtual y Cuotas)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba que los discos virtuales existen, estan montados, se
#           montaran solos tras reiniciar y tienen los permisos correctos.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase6.sh
#   sudo ./verificar_fase6.sh
#
# El informe se guarda en verificacion-fase-6.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-6.txt"
FALLOS=0
AVISOS=0

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
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LA FASE 5
# =============================================================================
# Los permisos de este apartado se dan al grupo 'policia'. Si el grupo no se ve,
# el chown falla y la carpeta queda a nombre de root SIN QUE NADIE AVISE.
echo "" | tee -a "$INFORME"
echo "--- A. Las identidades de la Fase 5 siguen en pie ---" | tee -a "$INFORME"

if systemctl is-active winbind >/dev/null 2>&1; then
    ok "A1. winbind activo"
else
    fallo "A1. winbind NO esta activo - el sistema no vera el grupo 'policia'"
    info "     Arreglo: sudo systemctl enable --now winbind"
fi

if getent group policia >/dev/null 2>&1; then
    ok "A2. El grupo 'policia' es visible (GID $(getent group policia | cut -d: -f3))"
else
    fallo "A2. El grupo 'policia' NO se ve - el chown de prueba3 no puede funcionar"
    info "     Esto es un problema de la Fase 5. Arreglalo alli antes de seguir."
fi

# =============================================================================
# BLOQUE B - LOS FICHEROS DE DISCO EXISTEN Y TIENEN EL TAMANO CORRECTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. Los discos virtuales ---" | tee -a "$INFORME"

comprueba_img() {
    local IMG="$1"
    local ETIQUETA="$2"

    if [ ! -f "$IMG" ]; then
        fallo "$ETIQUETA. No existe $IMG"
        info "     Arreglo: repite el Paso 2 del procedimiento (dd)"
        return
    fi

    local MB
    MB=$(( $(stat -c %s "$IMG") / 1024 / 1024 ))
    if [ "$MB" -ge 5000 ] && [ "$MB" -le 5240 ]; then
        ok "$ETIQUETA. $IMG existe y mide ${MB} MB (~5 GB)"
    else
        fallo "$ETIQUETA. $IMG mide ${MB} MB, deberian ser ~5120"
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

comprueba_img "/samba_p1.img" "B1"
comprueba_img "/samba_p3.img" "B2"

# =============================================================================
# BLOQUE C - MONTAJE: AHORA Y TRAS REINICIAR
# =============================================================================
# 'Montado' y 'se montara solo' son dos preguntas distintas. Un disco montado a
# mano desaparece en el proximo arranque y los datos parecen borrados.
echo "" | tee -a "$INFORME"
echo "--- C. Montaje ---" | tee -a "$INFORME"

comprueba_montaje() {
    local PUNTO="$1"
    local IMG="$2"
    local ETIQUETA="$3"

    if [ ! -d "$PUNTO" ]; then
        fallo "$ETIQUETA. No existe el punto de montaje $PUNTO"
        return
    fi

    if mountpoint -q "$PUNTO"; then
        ok "$ETIQUETA. $PUNTO esta montado AHORA"
    else
        fallo "$ETIQUETA. $PUNTO NO esta montado - es una carpeta normal del sistema"
        info "     Lo que escribas ahi NO va al disco virtual. Arreglo: sudo mount -a"
    fi

    # La linea del fstab es lo unico que hace persistente el montaje.
    if grep -q "^[^#]*$IMG[[:space:]]\+$PUNTO" /etc/fstab 2>/dev/null; then
        ok "$ETIQUETA-bis. $PUNTO tiene su linea en /etc/fstab (sobrevive al reinicio)"

        # Sin la opcion 'loop', el arranque puede quedarse colgado.
        if grep "^[^#]*$IMG[[:space:]]\+$PUNTO" /etc/fstab | grep -q "loop"; then
            ok "$ETIQUETA-ter. La linea lleva la opcion 'loop'"
        else
            fallo "$ETIQUETA-ter. La linea de $PUNTO NO lleva 'loop'"
            info "     Sin 'loop' Linux trata el fichero como un disco fisico."
            info "     NO REINICIES hasta arreglarlo. Mira el caso E1 del apartado 7."
        fi
    else
        fallo "$ETIQUETA-bis. $PUNTO no aparece en /etc/fstab - hoy funciona, manana no"
    fi
}

comprueba_montaje "/srv/samba/prueba1" "/samba_p1.img" "C1"
comprueba_montaje "/srv/samba/prueba3" "/samba_p3.img" "C2"

# C3. El paracaidas: 'mount -a' en seco. Si esto falla, el arranque tambien.
if mount -a --fake >/dev/null 2>&1; then
    ok "C3. /etc/fstab no tiene errores de sintaxis (mount -a --fake)"
else
    fallo "C3. /etc/fstab TIENE ERRORES - el servidor podria no arrancar"
    info "     NO REINICIES. Corrigelo y vuelve a pasar el verificador."
fi

# =============================================================================
# BLOQUE D - PERMISOS: DONDE ESTA EL FALLO SILENCIOSO DE ESTA FASE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- D. Permisos de las carpetas ---" | tee -a "$INFORME"

# D1. prueba1: abierta a todos los usuarios del dominio.
if [ -d /srv/samba/prueba1 ]; then
    PERM1=$(stat -c %a /srv/samba/prueba1)
    if [ "$PERM1" = "777" ]; then
        ok "D1. /srv/samba/prueba1 con permisos 777"
    else
        fallo "D1. /srv/samba/prueba1 tiene permisos $PERM1, deberian ser 777"
    fi
fi

# D2. EL MAS IMPORTANTE DE LA FASE. Si winbind no veia el grupo cuando se
#     ejecuto el chown, la carpeta quedo a nombre de root. No da ningun error
#     y la Fase 7 no podra proteger nada.
if [ -d /srv/samba/prueba3 ]; then
    GRUPO3=$(stat -c %G /srv/samba/prueba3)
    if [ "$GRUPO3" = "policia" ]; then
        ok "D2. /srv/samba/prueba3 pertenece al grupo 'policia'"
    else
        fallo "D2. /srv/samba/prueba3 pertenece a '$GRUPO3', deberia ser 'policia'"
        info "     El chown fallo (probablemente winbind estaba parado) y nadie aviso."
        info "     FUNCIONA HOY y ROMPERA LA FASE 7. Mira el caso E6 del apartado 7."
    fi

    # D3. El bit setgid (el '2' de 2770) hace que lo que se cree dentro herede
    #     el grupo. Sin el, cada fichero nuevo sale con el grupo de su autor.
    PERM3=$(stat -c %a /srv/samba/prueba3)
    if [ "$PERM3" = "2770" ]; then
        ok "D3. /srv/samba/prueba3 con permisos 2770 (setgid puesto)"
    elif [ "$PERM3" = "770" ]; then
        fallo "D3. /srv/samba/prueba3 tiene 770: FALTA EL BIT SETGID"
        info "     Los ficheros nuevos no heredaran el grupo 'policia'."
        info "     Arreglo: sudo chmod 2770 /srv/samba/prueba3"
    else
        fallo "D3. /srv/samba/prueba3 tiene permisos $PERM3, deberian ser 2770"
    fi
fi

# =============================================================================
# BLOQUE E - LA CUOTA HACE SU TRABAJO
# =============================================================================
# El objetivo de la fase: que cada carpeta tenga un limite propio de 5 GB
# INDEPENDIENTE del disco del servidor.
echo "" | tee -a "$INFORME"
echo "--- E. El limite de cada carpeta ---" | tee -a "$INFORME"

for P in /srv/samba/prueba1 /srv/samba/prueba3; do
    if mountpoint -q "$P"; then
        TAM=$(df -BM --output=size "$P" 2>/dev/null | tail -1 | tr -dc '0-9')
        if [ -n "$TAM" ] && [ "$TAM" -ge 4500 ] && [ "$TAM" -le 5240 ]; then
            ok "E. $P tiene su propio limite de ~5 GB"
        else
            aviso "E. $P declara ${TAM} MB - revisa que sea el disco virtual y no el del sistema"
        fi
    fi
done

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
  echo "  - Que el limite de 5 GB frene de verdad (hay que llenarlo)"
  echo "  - Que exista la instantanea 'Fase 6 terminada'"
  echo "  - Que exista la copia .ova en tu disco externo"
  echo "Esas tres se verifican A MANO. Las tienes en el apartado 8.a."
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
