#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 5 (Gestion de Identidades)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba que los usuarios y grupos del dominio EXISTEN y que el
#           servidor Linux los RECONOCE como propios. Escribe un informe.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase5.sh
#   sudo ./verificar_fase5.sh
#
# El informe se guarda en verificacion-fase-5.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-5.txt"
FALLOS=0
AVISOS=0
REALM="BOOCHANLAB.LOCAL"

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase5.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 5 - BoochanV1"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LA FASE 4
# =============================================================================
# Sin dominio no hay usuarios de dominio. Si esto falla, el resto del informe
# es ruido: el problema esta en la Fase 4, no aqui.
echo "" | tee -a "$INFORME"
echo "--- A. El dominio de la Fase 4 sigue en pie ---" | tee -a "$INFORME"

if systemctl is-active samba-ad-dc >/dev/null 2>&1; then
    ok "A1. samba-ad-dc activo"
else
    fallo "A1. samba-ad-dc NO esta activo - sin dominio no hay usuarios de dominio"
    info "     Esto es un problema de la Fase 4. Arreglalo alli antes de seguir."
fi

if samba-tool domain level show >/dev/null 2>&1; then
    ok "A2. El dominio responde a samba-tool"
else
    fallo "A2. samba-tool no puede consultar el dominio"
fi

# A3. Sin --use-rfc2307 el dominio NO puede guardar uidNumber/gidNumber, y
#     'samba-tool ... addunixattrs' falla con un error de esquema LDAP.
if grep -qi "rfc2307" /etc/samba/smb.conf 2>/dev/null; then
    ok "A3. El dominio tiene rfc2307 (necesario para dar identidad Unix)"
else
    fallo "A3. No se ve rfc2307 en smb.conf - los UID/GID no se pueden guardar en AD"
    info "     El dominio se aprovisiono sin --use-rfc2307. Mira el caso E6 del apartado 7."
fi

# =============================================================================
# BLOQUE B - EL TRADUCTOR: WINBIND
# =============================================================================
# Winbind es quien convierte "usuario del dominio" en "usuario que Linux
# entiende". Si esta parado, los usuarios existen y el sistema no los ve.
echo "" | tee -a "$INFORME"
echo "--- B. El traductor (winbind) ---" | tee -a "$INFORME"

if systemctl is-active winbind >/dev/null 2>&1; then
    ok "B1. winbind activo"
else
    fallo "B1. winbind NO esta activo - 'id user1' devolvera vacio"
    info "     Arreglo: sudo systemctl enable --now winbind"
fi

if systemctl is-enabled winbind >/dev/null 2>&1; then
    ok "B2. winbind habilitado - arranca solo tras reiniciar"
else
    fallo "B2. winbind no arranca solo - los usuarios desapareceran al reiniciar"
    info "     Arreglo: sudo systemctl enable winbind"
fi

# B3/B4. nsswitch.conf es la guia de consulta de Linux. Sin 'winbind' en esas
#        dos lineas, el sistema ni se molesta en preguntar al dominio.
if grep -E "^passwd:" /etc/nsswitch.conf 2>/dev/null | grep -q "winbind"; then
    ok "B3. nsswitch.conf: 'winbind' en la linea passwd"
else
    fallo "B3. Falta 'winbind' en la linea passwd de /etc/nsswitch.conf"
    info "     $(grep -E '^passwd:' /etc/nsswitch.conf 2>/dev/null | head -1)"
fi

if grep -E "^group:" /etc/nsswitch.conf 2>/dev/null | grep -q "winbind"; then
    ok "B4. nsswitch.conf: 'winbind' en la linea group"
else
    fallo "B4. Falta 'winbind' en la linea group de /etc/nsswitch.conf"
    info "     $(grep -E '^group:' /etc/nsswitch.conf 2>/dev/null | head -1)"
fi

# B5. wbinfo pregunta a winbind DIRECTAMENTE, saltandose nsswitch. Sirve para
#     separar "winbind no habla con el dominio" de "nsswitch no le pregunta".
if command -v wbinfo >/dev/null 2>&1; then
    if wbinfo -p >/dev/null 2>&1; then
        ok "B5. winbind responde (wbinfo -p)"
    else
        fallo "B5. winbind no responde a wbinfo - no esta hablando con el dominio"
    fi
else
    aviso "B5. 'wbinfo' no esta instalado - no se puede comprobar winbind a fondo"
    info "     Instalalo: sudo apt install -y winbind"
fi

# =============================================================================
# BLOQUE C - LOS GRUPOS EXISTEN EN EL DOMINIO Y TIENEN GID
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Grupos del dominio ---" | tee -a "$INFORME"

comprueba_grupo() {
    local NOMBRE="$1"
    local GID_ESPERADO="$2"
    local ETIQUETA="$3"

    if ! samba-tool group list 2>/dev/null | grep -qx "$NOMBRE"; then
        fallo "$ETIQUETA. El grupo '$NOMBRE' NO existe en el dominio"
        info "     Arreglo: sudo samba-tool group add $NOMBRE"
        return
    fi

    local GID_REAL
    GID_REAL=$(getent group "$NOMBRE" 2>/dev/null | cut -d: -f3)
    if [ -z "$GID_REAL" ]; then
        fallo "$ETIQUETA. '$NOMBRE' existe en el dominio pero Linux NO lo ve"
        info "     El grupo esta, falta la identidad Unix o el traductor."
        info "     Arreglo: sudo samba-tool group addunixattrs $NOMBRE $GID_ESPERADO"
    elif [ "$GID_REAL" = "$GID_ESPERADO" ]; then
        ok "$ETIQUETA. Grupo '$NOMBRE' con GID $GID_ESPERADO"
    else
        fallo "$ETIQUETA. '$NOMBRE' tiene GID $GID_REAL, deberia ser $GID_ESPERADO"
        info "     Con el GID cambiado, los permisos de la Fase 7 no cuadraran."
    fi
}

comprueba_grupo "policia"  "3001" "C1"
comprueba_grupo "bomberos" "3002" "C2"

# =============================================================================
# BLOQUE D - LOS USUARIOS Y SU IDENTIDAD UNIX
# =============================================================================
# Este es el corazon de la fase: que 'id user1' devuelva EXACTAMENTE el UID y
# el GID que se pusieron a mano. Un ID que baila rompe la Fase 7 en silencio.
echo "" | tee -a "$INFORME"
echo "--- D. Usuarios y su identidad Unix ---" | tee -a "$INFORME"

comprueba_usuario() {
    local NOMBRE="$1"
    local UID_ESPERADO="$2"
    local GID_ESPERADO="$3"
    local GRUPO="$4"
    local ETIQUETA="$5"

    if ! samba-tool user list 2>/dev/null | grep -qx "$NOMBRE"; then
        fallo "$ETIQUETA. El usuario '$NOMBRE' NO existe en el dominio"
        return
    fi

    local UID_REAL GID_REAL
    UID_REAL=$(id -u "$NOMBRE" 2>/dev/null)
    GID_REAL=$(id -g "$NOMBRE" 2>/dev/null)

    if [ -z "$UID_REAL" ]; then
        fallo "$ETIQUETA. '$NOMBRE' existe en el dominio pero 'id' no lo encuentra"
        info "     Existe y no se ve: el fallo esta en winbind o en nsswitch (bloque B)."
        return
    fi

    if [ "$UID_REAL" = "$UID_ESPERADO" ] && [ "$GID_REAL" = "$GID_ESPERADO" ]; then
        ok "$ETIQUETA. '$NOMBRE' -> uid=$UID_REAL gid=$GID_REAL (correcto)"
    else
        fallo "$ETIQUETA. '$NOMBRE' -> uid=$UID_REAL gid=$GID_REAL; esperado uid=$UID_ESPERADO gid=$GID_ESPERADO"
        info "     Se creo sin --uid-number/--gid-number y el sistema asigno IDs solo."
    fi

    if id -nG "$NOMBRE" 2>/dev/null | tr ' ' '\n' | grep -qx "$GRUPO"; then
        info "     Pertenece a '$GRUPO' (correcto)"
    else
        fallo "$ETIQUETA-bis. '$NOMBRE' NO pertenece al grupo '$GRUPO'"
        info "     Arreglo: sudo samba-tool group addmembers $GRUPO $NOMBRE"
    fi
}

comprueba_usuario "user1" "10001" "3001" "policia"  "D1"
comprueba_usuario "user2" "10002" "3002" "bomberos" "D2"

# D3. Los dos usuarios NO pueden compartir UID: dos identidades con el mismo
#     numero son la MISMA identidad para el sistema de ficheros.
U1=$(id -u user1 2>/dev/null)
U2=$(id -u user2 2>/dev/null)
if [ -n "$U1" ] && [ -n "$U2" ]; then
    if [ "$U1" != "$U2" ]; then
        ok "D3. user1 y user2 tienen UID distintos"
    else
        fallo "D3. user1 y user2 comparten el UID $U1 - son la misma identidad para Linux"
    fi
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 5 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 5 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 5 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_5.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que los usuarios puedan AUTENTICARSE de verdad (pide contrasena)"
  echo "  - Que exista la instantanea 'Fase 5 terminada'"
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
