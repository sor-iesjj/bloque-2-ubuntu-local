#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 7 (Seguridad Avanzada: ACLs y ABE)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba que la MATRIZ DE PERMISOS de Boochan S.L. esta aplicada
#           carpeta por carpeta, y que Samba publica los recursos con la
#           invisibilidad (ABE) activada. No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase7.sh
#   sudo ./verificar_fase7.sh
#
# El informe se guarda en verificacion-fase-7.txt, en la carpeta actual.
# Matriz completa: 99_Recursos/Escenario_Boochan_SL.md
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-7.txt"
FALLOS=0
AVISOS=0
BASE="/srv/samba/departamentos"
COMUN="/srv/samba/comun"
DEPARTAMENTOS="facturacion contabilidad comercial logistica rrhh becarios"

# --- LA MATRIZ, en una sola lista: carpeta:grupo:permiso_esperado ------------
# Solo los permisos CRUZADOS (los de cada grupo sobre su propia carpeta vienen
# de los permisos clasicos de la Fase 6, no de una ACL).
CRUCES="facturacion:comercial:r-x
facturacion:contabilidad:rwx
comercial:facturacion:r-x
comercial:contabilidad:r-x
comercial:logistica:r-x
logistica:contabilidad:r-x
logistica:comercial:r-x
becarios:rrhh:r-x"

# --- Y lo que NO debe existir: RRHH y contabilidad son islas ----------------
# Formato CARPETA:GRUPO. Son las 22 casillas vacias de la matriz que viven
# dentro de $BASE. La 23a  --becarios sobre 'comun'--  NO cabe aqui porque
# 'comun' cuelga de /srv/samba y no de /srv/samba/departamentos: la cubre el D3
# comprobando que 'valid users' no incluya a los becarios.
#   CARPETA : GRUPO_QUE_NO_DEBE_TENER_ACL
PROHIBIDOS="facturacion:logistica
facturacion:rrhh
facturacion:becarios
contabilidad:facturacion
contabilidad:comercial
contabilidad:logistica
contabilidad:rrhh
contabilidad:becarios
comercial:rrhh
comercial:becarios
logistica:facturacion
logistica:rrhh
logistica:becarios
rrhh:facturacion
rrhh:contabilidad
rrhh:comercial
rrhh:logistica
rrhh:becarios
becarios:facturacion
becarios:contabilidad
becarios:comercial
becarios:logistica"

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }


# -----------------------------------------------------------------------------
# winbind devuelve los grupos del dominio con su prefijo: BOOCHANLAB\comercial.
# Asi que getfacl escribe "group:BOOCHANLAB\comercial:r-x", no "group:comercial:".
# Esta funcion busca la entrada de un grupo ACEPTANDO ese prefijo o sin el.
#   $1 = salida de getfacl   $2 = nombre corto del grupo   $3 = "default" o vacio
linea_de_grupo() {
    local ACL="$1" GRUPO="$2" TIPO="${3:-}"
    echo "$ACL" | awk -F: -v g="$GRUPO" -v tipo="$TIPO" '
        {
            linea = $0
            if (tipo == "default") { if (linea !~ /^default:group:/) next; campo = $3 }
            else                   { if (linea !~ /^group:/)         next; campo = $2 }
            sub(/.*\\/, "", campo)      # quita "DOMINIO\" si lo lleva
            if (campo == g && campo != "") print linea
        }'
}

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase7.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 7 - BoochanV1"
  echo " Escenario: Boochan S.L. - matriz de permisos por departamento"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LAS FASES 5 Y 6
# =============================================================================
# Una ACL se da a un grupo, sobre una carpeta montada. Si el grupo no se ve o
# la carpeta no esta montada, la ACL se aplica a la nada.
echo "" | tee -a "$INFORME"
echo "--- A. La base de las fases 5 y 6 ---" | tee -a "$INFORME"

FALTAN=""
for d in $DEPARTAMENTOS; do
    getent group "$d" >/dev/null 2>&1 || FALTAN="$FALTAN $d"
done
if [ -z "$FALTAN" ]; then
    ok "A1. Los 6 grupos de departamento son visibles"
else
    fallo "A1. No se ven estos grupos:$FALTAN"
    info "     Problema de la Fase 5. Las ACL apuntarian a la nada."
fi

if mountpoint -q "$BASE" && mountpoint -q "$COMUN"; then
    ok "A2. Los dos volumenes estan montados"
else
    fallo "A2. Algun volumen NO esta montado - estarias poniendo ACL en la carpeta equivocada"
    info "     Problema de la Fase 6. Arreglo: sudo mount -a"
fi

MAL=""
for d in $DEPARTAMENTOS; do
    G=$(stat -c %G "$BASE/$d" 2>/dev/null); G="${G##*\\}"
    [ "$G" = "$d" ] || MAL="$MAL $d"
done
if [ -z "$MAL" ]; then
    ok "A3. Las 6 carpetas pertenecen a su departamento"
else
    fallo "A3. Estas carpetas NO pertenecen a su grupo:$MAL"
    info "     Problema de la Fase 6 (caso E6). Sin esto la proteccion no filtra nada."
fi

if ! command -v getfacl >/dev/null 2>&1; then
    fallo "A4. No esta instalado 'acl' - no se pueden leer las ACL"
    info "     Instalalo: sudo apt install -y acl"
    echo "" | tee -a "$INFORME"
    echo " VEREDICTO: FASE 7 NO SUPERADA - falta el paquete 'acl'" | tee -a "$INFORME"
    exit 1
fi

# --- A5. El MODO de las carpetas de departamento ----------------------------
# La Fase 6 lo comprueba una vez, ANTES de esta fase, y nadie lo vuelve a mirar.
# Un 'chmod 777' hecho durante la Fase 7 dejaria las ACL intactas y la carpeta
# abierta a toda la empresa. Aqui se vuelve a mirar. (becarios va en D1: 2750)
MODOS_MAL=""
for d in facturacion contabilidad comercial logistica rrhh; do
    P=$(stat -c %a "$BASE/$d" 2>/dev/null)
    [ "$P" = "2770" ] || MODOS_MAL="$MODOS_MAL $d($P)"
done
if [ -z "$MODOS_MAL" ]; then
    ok "A5. Las 5 carpetas de departamento siguen en 2770 (setgid y cerradas a otros)"
else
    fallo "A5. Estas carpetas NO estan en 2770:$MODOS_MAL"
    info "     Las ACL pueden estar perfectas y la carpeta abierta igual."
    info "     Arreglo: sudo chmod 2770 $BASE/<carpeta>"
fi

# --- A6. 'other' no entra en ninguna carpeta de departamento ----------------
# Es la comprobacion que ninguna ACL hace: 'other' es quien no es el dueno ni
# esta en ningun grupo con entrada. Si no es '---', sobra medio proyecto.
OTHER_MAL=""
for d in $DEPARTAMENTOS; do
    getfacl -p "$BASE/$d" 2>/dev/null | grep -q "^other::---" || OTHER_MAL="$OTHER_MAL $d"
done
if [ -z "$OTHER_MAL" ]; then
    ok "A6. En las 6 carpetas, quien no es del grupo no entra (other::---)"
else
    fallo "A6. Estas carpetas dejan entrar a 'otros':$OTHER_MAL"
    info "     Cualquier usuario del dominio entra, tenga o no ACL. Los becarios tambien."
fi


# =============================================================================
# BLOQUE B - LOS PERMISOS CRUZADOS DE LA MATRIZ
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. Permisos cruzados (la matriz) ---" | tee -a "$INFORME"

N=0
while IFS= read -r LINEA; do
    [ -z "$LINEA" ] && continue
    N=$((N+1))
    CARPETA=$(echo "$LINEA" | cut -d: -f1)
    GRUPO=$(echo "$LINEA"   | cut -d: -f2)
    PERM=$(echo "$LINEA"    | cut -d: -f3)
    RUTA="$BASE/$CARPETA"

    ACL=$(getfacl -p "$RUTA" 2>/dev/null)

    # ¿Existe la entrada para ese grupo? (con o sin prefijo de dominio)
    LINEA_ACL=$(linea_de_grupo "$ACL" "$GRUPO")
    if [ -z "$LINEA_ACL" ]; then
        fallo "B$N. '$GRUPO' NO tiene permiso sobre '$CARPETA' (deberia ser $PERM)"
        info "     Arreglo: sudo setfacl -m g:$GRUPO:${PERM//-/} $RUTA"
        continue
    fi

    # El permiso es el ultimo campo, y puede llevar "\t#effective:..." detras.
    PERM_REAL=$(echo "$LINEA_ACL" | awk -F: '{print $NF}' | awk '{print $1}')
    if echo "$LINEA_ACL" | grep -q "#effective:"; then
        PERM_REAL=$(echo "$LINEA_ACL" | sed 's/#effective:.*//' | awk -F: '{print $NF}' | awk '{print $1}')
    fi

    # La MASCARA puede recortar el permiso sin borrarlo. getfacl lo marca
    # con #effective, y es el fallo mas fino de la fase.
    if echo "$LINEA_ACL" | grep -q "#effective:"; then
        EFECTIVO=$(echo "$LINEA_ACL" | sed 's/.*#effective://' | tr -d ' \t')
        fallo "B$N. '$GRUPO' sobre '$CARPETA': pone $PERM_REAL pero se aplica $EFECTIVO"
        info "     LA MASCARA lo esta recortando. El permiso figura y NO funciona."
        info "     Arreglo: sudo setfacl -m m::rwx $RUTA"
    elif [ "$PERM_REAL" = "$PERM" ]; then
        ok "B$N. '$GRUPO' sobre '$CARPETA': $PERM (correcto)"
    else
        fallo "B$N. '$GRUPO' sobre '$CARPETA': tiene $PERM_REAL, deberia ser $PERM"
        if [ "$PERM" = "r-x" ] && [ "$PERM_REAL" = "rwx" ]; then
            info "     TIENE ESCRITURA Y NO DEBERIA. Es el permiso mas peligroso de la matriz."
        fi
    fi

    # La ACL por defecto ('-d'): sin ella, lo que se cree manana no hereda.
    if [ -n "$(linea_de_grupo "$ACL" "$GRUPO" default)" ]; then
        ok "B$N-bis. '$GRUPO' sobre '$CARPETA': la herencia esta puesta"
    else
        fallo "B$N-bis. '$GRUPO' sobre '$CARPETA': FALTA la ACL por defecto"
        info "     Funciona con lo que ya existe y falla con lo nuevo."
        info "     Arreglo: sudo setfacl -d -m g:$GRUPO:${PERM//-/} $RUTA"
    fi
done <<< "$CRUCES"

# =============================================================================
# BLOQUE C - LO QUE NO DEBE EXISTIR
# =============================================================================
# Un permiso de MAS es peor que uno de menos: el de menos se nota enseguida,
# el de mas no lo nota nadie hasta que alguien ve lo que no debia.
echo "" | tee -a "$INFORME"
echo "--- C. Accesos que NO deben existir ---" | tee -a "$INFORME"

SOBRAN=0
while IFS= read -r LINEA; do
    [ -z "$LINEA" ] && continue
    CARPETA=$(echo "$LINEA" | cut -d: -f1)
    GRUPO=$(echo "$LINEA"   | cut -d: -f2)
    if [ -n "$(linea_de_grupo "$(getfacl -p "$BASE/$CARPETA" 2>/dev/null)" "$GRUPO")" ]; then
        fallo "C. '$GRUPO' TIENE acceso a '$CARPETA' y NO deberia"
        info "     Segun la matriz, esa casilla esta vacia. Quitalo:"
        info "     sudo setfacl -x g:$GRUPO $BASE/$CARPETA"
        info "     sudo setfacl -d -x g:$GRUPO $BASE/$CARPETA"
        SOBRAN=$((SOBRAN+1))
    fi
done <<< "$PROHIBIDOS"

if [ "$SOBRAN" -eq 0 ]; then
    ok "C. Ningun grupo tiene acceso de mas: las 22 casillas vacias de la matriz estan vacias"
fi

# =============================================================================
# BLOQUE D - LOS CASOS ESPECIALES DE LA MATRIZ
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- D. Casos especiales ---" | tee -a "$INFORME"

# D1. Los becarios solo LEEN su propia carpeta: es la unica excepcion.
PERM_BEC=$(stat -c %a "$BASE/becarios" 2>/dev/null)
if [ "$PERM_BEC" = "2750" ]; then
    ok "D1. La carpeta de becarios esta en 2750: su grupo lee pero NO escribe"
elif [ "$PERM_BEC" = "2770" ]; then
    fallo "D1. La carpeta de becarios esta en 2770: PUEDEN ESCRIBIR Y BORRAR"
    info "     Segun la matriz, los becarios solo tienen LECTURA sobre lo suyo."
    info "     Arreglo: sudo chmod 2750 $BASE/becarios"
else
    fallo "D1. La carpeta de becarios tiene permisos $PERM_BEC, deberian ser 2750"
fi

# D2. La carpeta comun conserva su sticky bit de la Fase 6.
PERM_COM=$(stat -c %a "$COMUN" 2>/dev/null)
if [ "$PERM_COM" = "1777" ]; then
    ok "D2. La carpeta comun conserva su sticky bit (1777)"
else
    fallo "D2. La carpeta comun tiene permisos $PERM_COM, deberian ser 1777"
    info "     Sin sticky bit, cualquiera puede borrar el fichero de cualquiera."
fi

# D3. comun esta en 1777 (escritura para todos), asi que la puerta que deja
#     fuera a los becarios NO puede ser el permiso: tiene que ser Samba.
if testparm -s --parameter-name="valid users" --section-name=comun 2>/dev/null | grep -qi "becarios"; then
    fallo "D3. El recurso [comun] admite al grupo becarios"
    info "     La matriz dice que los becarios NO tienen comun. Quita @becarios de valid users."
elif testparm -s --parameter-name="valid users" --section-name=comun 2>/dev/null | grep -q "@"; then
    ok "D3. El recurso [comun] limita quien conecta con valid users"
else
    fallo "D3. El recurso [comun] no tiene valid users: entra TODO EL MUNDO"
    info "     Con comun en 1777, sin valid users un becario entra igual."
    info "     Arreglo: valid users = @facturacion,@contabilidad,@comercial,@logistica,@rrhh"
fi

# =============================================================================
# BLOQUE E - SAMBA PUBLICA LAS CARPETAS
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- E. Publicacion en Samba ---" | tee -a "$INFORME"

# E1. El paracaidas de esta fase: testparm valida la sintaxis SIN reiniciar.
if testparm -s >/dev/null 2>&1; then
    ok "E1. /etc/samba/smb.conf no tiene errores de sintaxis (testparm)"
else
    fallo "E1. /etc/samba/smb.conf TIENE ERRORES de sintaxis"
    info "     NO reinicies samba-ad-dc: tumbarias el dominio entero."
    info "     Mira que dice: sudo testparm"
fi

for s in $DEPARTAMENTOS comun; do
    if testparm -s 2>/dev/null | grep -q "^\[$s\]"; then
        ok "E2. El recurso [$s] esta publicado"
    else
        fallo "E2. El recurso [$s] NO aparece en la configuracion"
    fi
    # Secciones duplicadas: Samba usa la ULTIMA y descarta las anteriores.
    VECES=$(grep -c "^\[$s\]" /etc/samba/smb.conf 2>/dev/null)
    if [ "${VECES:-0}" -gt 1 ]; then
        fallo "E2-bis. La seccion [$s] aparece $VECES veces en smb.conf"
        info "     Samba usa la ULTIMA y descarta las anteriores sin avisar."
    fi
done

# =============================================================================
# BLOQUE F - LA INVISIBILIDAD (ABE): EL FALLO QUE NO SE VE DESDE AQUI
# =============================================================================
# Sin estas opciones el recurso SE VE desde Windows aunque no se pueda entrar.
# Y desde Ubuntu no hay forma de notarlo: es la Fase 8 quien lo destapa.
echo "" | tee -a "$INFORME"
echo "--- F. Invisibilidad basada en acceso (ABE) ---" | tee -a "$INFORME"

for s in $DEPARTAMENTOS; do
    CONF=$(testparm -s --section-name="$s" 2>/dev/null)

    if echo "$CONF" | grep -qi "access based share enum *= *yes"; then
        ok "F. [$s] con 'access based share enum = yes'"
    else
        fallo "F. [$s] SIN 'access based share enum' - se vera desde Windows"
        info "     Se puede entrar? No. Se ve que existe? Si. Y eso ya es informacion."
    fi

    if ! echo "$CONF" | grep -qi "hide unreadable *= *yes"; then
        fallo "F. [$s] SIN 'hide unreadable'"
    fi

    if ! echo "$CONF" | grep -qi "vfs objects.*acl_xattr"; then
        fallo "F. [$s] SIN 'acl_xattr' - Windows machacara las ACL al copiar ficheros"
    fi
done

# --- [comun] tambien lleva ABE, y hasta ago-2026 este bloque no la miraba ---
# El D3 caza que le falte 'valid users', pero un [comun] sin ABE se colaba en verde.
CONF_COMUN=$(testparm -s --section-name="comun" 2>/dev/null)

if echo "$CONF_COMUN" | grep -qi "access based share enum *= *yes"; then
    ok "F. [comun] con 'access based share enum = yes'"
else
    fallo "F. [comun] SIN 'access based share enum' - los becarios la veran en el listado"
    info "     No podran entrar (lo impide valid users), pero sabran que existe."
fi

if ! echo "$CONF_COMUN" | grep -qi "hide unreadable *= *yes"; then
    fallo "F. [comun] SIN 'hide unreadable'"
fi

if ! echo "$CONF_COMUN" | grep -qi "vfs objects.*acl_xattr"; then
    fallo "F. [comun] SIN 'acl_xattr' - Windows machacara las ACL al copiar ficheros"
fi

# =============================================================================
# BLOQUE G - EL DOMINIO SIGUE VIVO DESPUES DE TOCAR LA CONFIGURACION
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- G. El dominio despues del cambio ---" | tee -a "$INFORME"

if systemctl is-active samba-ad-dc >/dev/null 2>&1; then
    ok "G1. samba-ad-dc sigue activo tras editar smb.conf"
else
    fallo "G1. samba-ad-dc NO esta activo - probablemente por un error en smb.conf"
    info "     Mira: sudo journalctl -u samba-ad-dc -n 30 --no-pager"
fi

if id hiroshi.nohara >/dev/null 2>&1; then
    ok "G2. Los usuarios del dominio siguen resolviendose"
else
    fallo "G2. 'id hiroshi.nohara' no responde - revisa winbind (Fase 5)"
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 7 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 7 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 7 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_7.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que las carpetas sean INVISIBLES de verdad desde Windows"
  echo "  - Que un usuario sin permiso no pueda entrar de verdad"
  echo "  - Que exista la instantanea 'Fase 7 terminada' ni la copia .ova"
  echo ""
  echo "OJO: la prueba REAL de esta fase se hace desde el cliente Windows,"
  echo "en la FASE 8, iniciando sesion con usuarios distintos."
  echo "Aqui solo se comprueba que el servidor esta bien configurado para ello."
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
