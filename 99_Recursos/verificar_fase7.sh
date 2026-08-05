#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 7 (Seguridad Avanzada: ACLs y ABE)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba las ACL de las carpetas, su herencia, y que Samba publica
#           los recursos con la invisibilidad (ABE) activada.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase7.sh
#   sudo ./verificar_fase7.sh
#
# El informe se guarda en verificacion-fase-7.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-7.txt"
FALLOS=0
AVISOS=0
CARPETA="/srv/samba/prueba3"

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase7.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 7 - BoochanV1"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LAS FASES 5 Y 6
# =============================================================================
# Una ACL se da a un grupo y se pone sobre una carpeta montada. Si el grupo no
# se ve o la carpeta no esta montada, la ACL se aplica a la nada.
echo "" | tee -a "$INFORME"
echo "--- A. La base de las fases 5 y 6 ---" | tee -a "$INFORME"

if getent group policia >/dev/null 2>&1; then
    ok "A1. El grupo 'policia' es visible (GID $(getent group policia | cut -d: -f3))"
else
    fallo "A1. El grupo 'policia' NO se ve - las ACL no pueden apuntar a el"
    info "     Problema de la Fase 5. Arreglalo alli antes de seguir."
fi

if mountpoint -q "$CARPETA"; then
    ok "A2. $CARPETA esta montado"
else
    fallo "A2. $CARPETA NO esta montado - estarias poniendo ACL en la carpeta equivocada"
    info "     Problema de la Fase 6. Arreglo: sudo mount -a"
fi

GRUPO_CARPETA=$(stat -c %G "$CARPETA" 2>/dev/null)
if [ "$GRUPO_CARPETA" = "policia" ]; then
    ok "A3. $CARPETA pertenece al grupo 'policia'"
else
    fallo "A3. $CARPETA pertenece a '$GRUPO_CARPETA', deberia ser 'policia'"
    info "     Problema de la Fase 6 (caso E6). Sin esto la proteccion no filtra nada."
fi

# =============================================================================
# BLOQUE B - LAS ACL DE LA CARPETA
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. Listas de control de acceso ---" | tee -a "$INFORME"

if ! command -v getfacl >/dev/null 2>&1; then
    fallo "B0. No esta instalado 'acl' - no se pueden leer las ACL"
    info "     Instalalo: sudo apt install -y acl"
else
    ACL=$(getfacl -p "$CARPETA" 2>/dev/null)

    # B1. El permiso al grupo tiene que estar puesto.
    if echo "$ACL" | grep -qE "^group:policia:rwx"; then
        ok "B1. ACL: el grupo 'policia' tiene rwx sobre la carpeta"
    else
        fallo "B1. ACL: falta el permiso rwx del grupo 'policia'"
        info "     Arreglo: sudo setfacl -m g:policia:rwx $CARPETA"
    fi

    # B2. LA MASCARA. Este es el fallo sutil de las ACL: el permiso figura en
    #     la lista pero la mascara lo recorta, y getfacl lo marca #effective.
    if echo "$ACL" | grep -qE "^group:policia:rwx.*#effective:"; then
        fallo "B2. La MASCARA esta recortando el permiso del grupo"
        info "     $(echo "$ACL" | grep '^group:policia' | head -1)"
        info "     El permiso figura en la lista pero NO se aplica. Caso E6 del apartado 7."
        info "     Arreglo: sudo setfacl -m m::rwx $CARPETA"
    else
        ok "B2. La mascara no recorta el permiso del grupo (permiso efectivo)"
    fi

    # B3. La ACL POR DEFECTO ('-d'): sin ella, lo que se cree manana no hereda.
    if echo "$ACL" | grep -qE "^default:group:policia:rwx"; then
        ok "B3. ACL por defecto: los ficheros nuevos heredaran el permiso"
    else
        fallo "B3. NO hay ACL por defecto - lo que se cree a partir de ahora no la hereda"
        info "     Funciona con lo que ya existe y falla con lo nuevo."
        info "     Arreglo: sudo setfacl -d -m g:policia:rwx $CARPETA"
    fi
fi

# =============================================================================
# BLOQUE C - SAMBA PUBLICA LAS CARPETAS
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Publicacion en Samba ---" | tee -a "$INFORME"

# C1. El paracaidas de esta fase: testparm valida la sintaxis SIN reiniciar.
if testparm -s >/dev/null 2>&1; then
    ok "C1. /etc/samba/smb.conf no tiene errores de sintaxis (testparm)"
else
    fallo "C1. /etc/samba/smb.conf TIENE ERRORES de sintaxis"
    info "     NO reinicies samba-ad-dc: tumbarias el dominio entero."
    info "     Mira que dice: sudo testparm"
fi

comprueba_recurso() {
    local NOMBRE="$1"
    local ETIQUETA="$2"
    if testparm -s 2>/dev/null | grep -q "^\[$NOMBRE\]"; then
        ok "$ETIQUETA. El recurso [$NOMBRE] esta publicado"
    else
        fallo "$ETIQUETA. El recurso [$NOMBRE] NO aparece en la configuracion"
    fi
}

comprueba_recurso "prueba1" "C2"
comprueba_recurso "prueba3" "C3"

# C4. Secciones duplicadas: Samba se queda con la ULTIMA y la primera se
#     ignora en silencio. Es un error dificil de ver leyendo el fichero.
for S in prueba1 prueba3; do
    VECES=$(grep -c "^\[$S\]" /etc/samba/smb.conf 2>/dev/null)
    if [ "${VECES:-0}" -gt 1 ]; then
        fallo "C4. La seccion [$S] aparece $VECES veces en smb.conf"
        info "     Samba usa la ULTIMA y descarta las anteriores sin avisar."
    fi
done

# =============================================================================
# BLOQUE D - LA INVISIBILIDAD (ABE): EL FALLO SILENCIOSO DE ESTA FASE
# =============================================================================
# Sin estas dos opciones el recurso SE VE desde Windows aunque no se pueda
# entrar. La proteccion 'funciona' a medias y no lo sabras hasta la Fase 8.
echo "" | tee -a "$INFORME"
echo "--- D. Invisibilidad basada en acceso (ABE) ---" | tee -a "$INFORME"

CONF_P3=$(testparm -s --section-name=prueba3 2>/dev/null)

if echo "$CONF_P3" | grep -qi "access based share enum *= *yes"; then
    ok "D1. [prueba3] con 'access based share enum = yes'"
else
    fallo "D1. [prueba3] SIN 'access based share enum' - el recurso se vera desde Windows"
    info "     Se puede entrar? No. Se ve? Si. Y eso ya es informacion que regalas."
fi

if echo "$CONF_P3" | grep -qi "hide unreadable *= *yes"; then
    ok "D2. [prueba3] con 'hide unreadable = yes'"
else
    fallo "D2. [prueba3] SIN 'hide unreadable' - se vera el contenido que no se puede abrir"
fi

# D3. acl_xattr es lo que permite que las ACL sobrevivan a Windows.
if echo "$CONF_P3" | grep -qi "vfs objects.*acl_xattr"; then
    ok "D3. [prueba3] con 'vfs objects = acl_xattr'"
else
    fallo "D3. [prueba3] SIN 'acl_xattr' - Windows machacara las ACL al copiar ficheros"
fi

# =============================================================================
# BLOQUE E - EL SERVICIO SIGUE VIVO DESPUES DE TOCAR LA CONFIGURACION
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- E. El dominio despues del cambio ---" | tee -a "$INFORME"

if systemctl is-active samba-ad-dc >/dev/null 2>&1; then
    ok "E1. samba-ad-dc sigue activo tras editar smb.conf"
else
    fallo "E1. samba-ad-dc NO esta activo - probablemente por un error en smb.conf"
    info "     Mira: sudo journalctl -u samba-ad-dc -n 30 --no-pager"
fi

if smbclient -L localhost -N >/dev/null 2>&1; then
    ok "E2. El servidor lista sus recursos compartidos"
else
    aviso "E2. No se han podido listar los recursos con smbclient"
    info "     Puede ser normal segun la configuracion. Compruebalo a mano."
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
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 7 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_7.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que la carpeta sea INVISIBLE de verdad desde Windows (eso es la Fase 8)"
  echo "  - Que exista la instantanea 'Fase 7 terminada'"
  echo "  - Que exista la copia .ova en tu disco externo"
  echo ""
  echo "OJO: la prueba REAL de esta fase se hace desde el cliente Windows."
  echo "Aqui solo se comprueba que el servidor esta bien configurado para ello."
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
