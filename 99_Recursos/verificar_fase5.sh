#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 5 (Gestion de Identidades)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba que los 6 departamentos y los 12 trabajadores de
#           Boochan S.L. existen y que el servidor Linux los reconoce con los
#           numeros EXACTOS del escenario. No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase5.sh
#   sudo ./verificar_fase5.sh
#
# El informe se guarda en verificacion-fase-5.txt, en la carpeta actual.
# Escenario completo: 99_Recursos/Escenario_Boochan_SL.md
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-5.txt"
FALLOS=0
AVISOS=0

# --- El escenario, en dos listas. Fuente de verdad: Escenario_Boochan_SL.md ---
GRUPOS="facturacion:3001 contabilidad:3002 comercial:3003 logistica:3004 rrhh:3005 becarios:3006"
USUARIOS="hiroshi.nohara:10001:3001:facturacion
nene.sakurada:10002:3001:facturacion
misae.nohara:10003:3002:contabilidad
toru.kazama:10004:3002:contabilidad
masao.sato:10005:3003:comercial
ai.suotome:10006:3003:comercial
bo.suzuki:10007:3004:logistica
midori.yoshinaga:10008:3004:logistica
ume.matsuzaka:10009:3005:rrhh
bunta.takakura:10010:3005:rrhh
shinnosuke.nohara:10011:3006:becarios
himawari.nohara:10012:3006:becarios"

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
  echo " Escenario: Boochan S.L. - 6 departamentos, 12 trabajadores"
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

# A3. Sin --use-rfc2307 el dominio NO puede guardar uidNumber/gidNumber.
if grep -qi "rfc2307" /etc/samba/smb.conf 2>/dev/null; then
    ok "A3. El dominio tiene rfc2307 (necesario para dar identidad Unix)"
else
    fallo "A3. No se ve rfc2307 en smb.conf - los UID/GID no se pueden guardar en AD"
    info "     El dominio se aprovisiono sin --use-rfc2307. Caso E5 del apartado 7."
fi

# =============================================================================
# BLOQUE B - EL TRADUCTOR: WINBIND
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. El traductor (winbind) ---" | tee -a "$INFORME"

# OJO: en un Samba AD DC, winbindd va DENTRO del proceso 'samba'. El servicio
# 'winbind' de systemd es el del Samba CLASICO y debe estar INACTIVO (asi lo
# comprueba tambien la Fase 4). Por eso aqui NO se mira el servicio: se mira
# si winbind RESPONDE, que es lo unico que importa.
if command -v wbinfo >/dev/null 2>&1; then
    if wbinfo -p >/dev/null 2>&1; then
        ok "B1. winbind responde (wbinfo -p) - lo sirve el propio samba-ad-dc"
    else
        fallo "B1. winbind NO responde - los 12 usuarios seran invisibles para Linux"
        info "     En un AD DC winbindd va dentro de 'samba'. Revisa samba-ad-dc (bloque A)."
    fi
else
    fallo "B1. 'wbinfo' no esta instalado - no se puede comprobar winbind"
    info "     Instalalo: sudo apt install -y winbind"
fi

# B2. El servicio winbind de systemd tiene que estar APAGADO: es el del Samba
#     clasico y se pelea con el AD DC por los mismos recursos.
if systemctl is-active winbind >/dev/null 2>&1; then
    aviso "B2. El servicio 'winbind' de systemd esta ACTIVO"
    info "     En un AD DC deberia estar apagado: winbindd ya corre dentro de samba."
    info "     No suele romper nada, pero es el Samba clasico asomando."
else
    ok "B2. El servicio 'winbind' de systemd esta apagado (correcto en un AD DC)"
fi

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

# B5. La prueba de fuego: que el sistema resuelva un usuario por la via normal.
if getent passwd hiroshi.nohara >/dev/null 2>&1; then
    ok "B5. El sistema resuelve usuarios del dominio (getent passwd)"
else
    fallo "B5. 'getent passwd' no encuentra a los usuarios del dominio"
    info "     Si wbinfo -u SI los lista, el fallo esta en nsswitch (B3/B4)."
fi

# =============================================================================
# BLOQUE C - LOS SEIS DEPARTAMENTOS
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Los 6 departamentos (grupos) ---" | tee -a "$INFORME"

N=0
for ENTRADA in $GRUPOS; do
    N=$((N+1))
    NOMBRE="${ENTRADA%:*}"
    GID_ESPERADO="${ENTRADA#*:}"

    if ! samba-tool group list 2>/dev/null | grep -qx "$NOMBRE"; then
        fallo "C$N. El departamento '$NOMBRE' NO existe en el dominio"
        info "     Arreglo: sudo samba-tool group add $NOMBRE"
        continue
    fi

    GID_REAL=$(getent group "$NOMBRE" 2>/dev/null | cut -d: -f3)
    if [ -z "$GID_REAL" ]; then
        fallo "C$N. '$NOMBRE' existe en el dominio pero Linux NO lo ve"
        info "     Falta la identidad Unix o el traductor esta parado."
        info "     Arreglo: sudo samba-tool group addunixattrs $NOMBRE $GID_ESPERADO"
    elif [ "$GID_REAL" = "$GID_ESPERADO" ]; then
        ok "C$N. Departamento '$NOMBRE' con GID $GID_ESPERADO"
    else
        fallo "C$N. '$NOMBRE' tiene GID $GID_REAL, deberia ser $GID_ESPERADO"
        info "     Con el GID cambiado, los permisos de la Fase 7 no cuadraran."
    fi
done

# =============================================================================
# BLOQUE D - LOS DOCE TRABAJADORES
# =============================================================================
# El corazon de la fase: que 'id' devuelva EXACTAMENTE los numeros del
# escenario. Un ID que baila rompe la Fase 7 en silencio.
echo "" | tee -a "$INFORME"
echo "--- D. Los 12 trabajadores ---" | tee -a "$INFORME"

N=0
DUPLICADOS=""
while IFS= read -r LINEA; do
    [ -z "$LINEA" ] && continue
    N=$((N+1))
    LOGIN=$(echo "$LINEA"  | cut -d: -f1)
    UID_ESP=$(echo "$LINEA" | cut -d: -f2)
    GID_ESP=$(echo "$LINEA" | cut -d: -f3)
    GRUPO=$(echo "$LINEA"  | cut -d: -f4)

    if ! samba-tool user list 2>/dev/null | grep -qx "$LOGIN"; then
        fallo "D$N. '$LOGIN' NO existe en el dominio"
        continue
    fi

    UID_REAL=$(id -u "$LOGIN" 2>/dev/null)
    GID_REAL=$(id -g "$LOGIN" 2>/dev/null)

    if [ -z "$UID_REAL" ]; then
        fallo "D$N. '$LOGIN' existe en el dominio pero 'id' no lo encuentra"
        info "     Existe y no se ve: el fallo esta en winbind o nsswitch (bloque B)."
        continue
    fi

    DUPLICADOS="$DUPLICADOS $UID_REAL"

    # El UID SI tiene que ser exacto: es lo que se graba en cada fichero.
    if [ "$UID_REAL" != "$UID_ESP" ]; then
        fallo "D$N. $LOGIN -> uid=$UID_REAL, esperado uid=$UID_ESP"
        info "     Se creo sin --uid-number y el sistema asigno el numero solo."
        continue
    fi

    # El GID PRIMARIO en Active Directory es 'Domain Users' para todo el mundo:
    # eso es normal y NO se corrige. Lo que importa es la PERTENENCIA al
    # departamento, que es lo que miran las ACL de la Fase 7. Y el grupo de los
    # ficheros que cree lo decidira el setgid de la carpeta (Fase 6), no este GID.
    # 'id -nG' devuelve los grupos con el prefijo del dominio (BOOCHANLAB\grupo),
    # asi que el patron acepta el nombre con o sin ese prefijo.
    if id -nG "$LOGIN" 2>/dev/null | tr ' ' '\n' | grep -qE "(^|\\\\)$GRUPO\$"; then
        ok "D$N. $LOGIN -> uid=$UID_REAL, en el departamento '$GRUPO'"
        if [ "$GID_REAL" != "$GID_ESP" ]; then
            info "     (gid primario $GID_REAL = Domain Users: normal en AD, no es un fallo)"
        fi
    else
        fallo "D$N. $LOGIN tiene el UID correcto pero NO pertenece a '$GRUPO'"
        info "     Sin la pertenencia, las ACL de la Fase 7 no le alcanzaran."
        info "     Arreglo: sudo samba-tool group addmembers $GRUPO $LOGIN"
    fi

done <<< "$USUARIOS"

# D13. Dos personas NO pueden compartir UID: para el sistema de ficheros serian
#      la misma persona, y ninguna auditoria podria distinguirlas.
REPES=$(echo "$DUPLICADOS" | tr ' ' '\n' | grep -v '^$' | sort | uniq -d)
if [ -z "$REPES" ]; then
    ok "D13. Los 12 UID son distintos entre si"
else
    fallo "D13. Hay UID REPETIDOS: $(echo $REPES | tr '\n' ' ')"
    info "     Dos personas con el mismo numero son la MISMA persona para Linux."
fi

# =============================================================================
# BLOQUE E - CADA DEPARTAMENTO CON SU GENTE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- E. Plantilla por departamento ---" | tee -a "$INFORME"

for ENTRADA in $GRUPOS; do
    NOMBRE="${ENTRADA%:*}"
    MIEMBROS=$(samba-tool group listmembers "$NOMBRE" 2>/dev/null | grep -c .)
    if [ "${MIEMBROS:-0}" -eq 2 ]; then
        ok "E. '$NOMBRE' tiene 2 miembros (correcto)"
    else
        fallo "E. '$NOMBRE' tiene ${MIEMBROS:-0} miembros, deberian ser 2"
        info "     Mira quien falta: sudo samba-tool group listmembers $NOMBRE"
    fi
done

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
  echo ""
  echo "Escenario completo (nombres, UID, GID y matriz de permisos):"
  echo "  99_Recursos/Escenario_Boochan_SL.md"
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
