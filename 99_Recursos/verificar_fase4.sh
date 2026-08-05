#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 4 (Aprovisionamiento del Dominio)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba el ESTADO FINAL del dominio y escribe un informe.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase4.sh
#   sudo ./verificar_fase4.sh
#
# El informe se guarda en verificacion-fase-4.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-4.txt"
FALLOS=0
AVISOS=0
REALM="BOOCHANLAB.LOCAL"
REALM_MIN="boochanlab.local"

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase4.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 4 - BoochanV1"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LAS FASES ANTERIORES
# =============================================================================
# El dominio se aprovisiono SOBRE esta base. Si algo de aqui se movio despues,
# el dominio queda apuntando a un sitio que ya no existe.
echo "" | tee -a "$INFORME"
echo "--- A. Base de las fases anteriores ---" | tee -a "$INFORME"

if ip -4 addr show | grep -q "10.10.10.10/24"; then
    ok "A1. IP 10.10.10.10 presente (Fase 1)"
else
    fallo "A1. NO existe la IP 10.10.10.10 - el dominio quedaria inalcanzable"
fi

if [ "$(hostname -f 2>/dev/null)" = "UbuntuServer.$REALM" ]; then
    ok "A2. FQDN correcto: UbuntuServer.$REALM (Fase 2)"
else
    fallo "A2. FQDN incorrecto: '$(hostname -f 2>/dev/null)' - deberia ser UbuntuServer.$REALM"
fi

# =============================================================================
# BLOQUE B - EL CONTROLADOR DE DOMINIO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. El controlador de dominio ---" | tee -a "$INFORME"

if systemctl is-active samba-ad-dc >/dev/null 2>&1; then
    ok "B1. samba-ad-dc activo"
else
    fallo "B1. samba-ad-dc NO esta activo - no hay dominio"
    info "     Arranque: sudo systemctl start samba-ad-dc"
fi

if systemctl is-enabled samba-ad-dc >/dev/null 2>&1; then
    ok "B2. samba-ad-dc habilitado - el dominio arranca solo"
else
    fallo "B2. samba-ad-dc no arranca solo - funciona hoy, no tras reiniciar"
    info "     Arreglo: sudo systemctl enable samba-ad-dc"
fi

# B3. El Samba CLASICO tiene que estar apagado. smbd y samba-ad-dc se pelean
#     por los mismos puertos, y el sintoma no dice que sea eso.
CLASICOS=""
for s in smbd nmbd winbind; do
    systemctl is-active "$s" >/dev/null 2>&1 && CLASICOS="$CLASICOS $s"
done
if [ -z "$CLASICOS" ]; then
    ok "B3. El Samba clasico esta apagado (correcto en un AD DC)"
else
    fallo "B3. Hay servicios del Samba clasico corriendo:$CLASICOS"
    info "     Se pelean con samba-ad-dc por los mismos puertos"
    info "     Arreglo: sudo systemctl disable --now$CLASICOS"
fi

# =============================================================================
# BLOQUE C - EL DOMINIO EXISTE Y RESPONDE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. El dominio responde ---" | tee -a "$INFORME"

if samba-tool domain level show >/dev/null 2>&1; then
    ok "C1. El dominio responde a samba-tool"
    info "     $(samba-tool domain level show 2>/dev/null | grep -i 'domain function level' | head -1)"
else
    fallo "C1. samba-tool no puede consultar el dominio"
fi

# C2. --use-rfc2307 guarda UID/GID de Unix dentro de AD. Sin el, la Fase 5
#     no puede dar identidad Unix a los usuarios del dominio.
if grep -qi "rfc2307" /etc/samba/smb.conf 2>/dev/null; then
    ok "C2. El dominio se aprovisiono con --use-rfc2307 (lo necesita la Fase 5)"
else
    aviso "C2. No se ve rfc2307 en smb.conf - revisalo antes de la Fase 5"
fi

# =============================================================================
# BLOQUE D - DNS: DONDE ESTA EL FALLO SILENCIOSO DE ESTA FASE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- D. DNS del dominio ---" | tee -a "$INFORME"

if grep -q "nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
    ok "D1. El servidor se pregunta a si mismo (nameserver 127.0.0.1)"
else
    fallo "D1. /etc/resolv.conf no apunta a 127.0.0.1"
    info "     Sin esto el servidor no resuelve su propio dominio"
fi

# D2. chattr +i evita que systemd-resolved lo sobrescriba al reiniciar.
if lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then
    ok "D2. /etc/resolv.conf es inmutable - nada lo sobrescribira"
else
    fallo "D2. /etc/resolv.conf NO es inmutable - se perdera al reiniciar"
    info "     Arreglo: sudo chattr +i /etc/resolv.conf"
fi

# D3. EL MAS IMPORTANTE DE LA FASE. Si el dominio se aprovisiono sin
#     --host-ip, Samba elige la tarjeta NAT (10.0.2.x) y se registra ahi.
#     Todo "funciona"... y la Fase 8 falla con "No se encuentra el dominio".
if command -v host >/dev/null 2>&1; then
    IPDOM=$(host -t A "ubuntuserver.$REALM_MIN" 127.0.0.1 2>/dev/null | awk '/has address/{print $NF}' | head -1)
    if [ "$IPDOM" = "10.10.10.10" ]; then
        ok "D3. El dominio se anuncia en 10.10.10.10 (correcto)"
    elif [ -z "$IPDOM" ]; then
        fallo "D3. El dominio no resuelve su propio nombre"
    else
        fallo "D3. El dominio se anuncia en $IPDOM, NO en 10.10.10.10"
        info "     Se aprovisiono sin --host-ip y Samba eligio la tarjeta NAT."
        info "     FUNCIONA HOY y REVENTARA LA FASE 8. Mira el caso del apartado 7."
    fi

    # D4. Los registros SRV son como el cliente Windows encuentra el dominio.
    if host -t SRV "_kerberos._tcp.$REALM_MIN" 127.0.0.1 >/dev/null 2>&1; then
        ok "D4. Registros SRV de Kerberos publicados"
    else
        fallo "D4. No hay registros SRV - un cliente no encontrara el dominio"
    fi
else
    aviso "D3/D4. No esta instalado 'host' - no se puede comprobar el DNS"
    info "     Instalalo: sudo apt install -y dnsutils"
fi

# D5. El forwarder: lo que NO es del dominio tiene que seguir resolviendose.
if getent hosts archive.ubuntu.com >/dev/null 2>&1; then
    ok "D5. Se siguen resolviendo nombres de Internet (forwarder correcto)"
else
    fallo "D5. Se ha perdido la resolucion de Internet - 'apt' fallara"
fi

# =============================================================================
# BLOQUE E - KERBEROS
# =============================================================================
# El reino DEBE ir en MAYUSCULAS. En minusculas la autenticacion falla, y el
# error no menciona las mayusculas por ningun sitio.
echo "" | tee -a "$INFORME"
echo "--- E. Kerberos ---" | tee -a "$INFORME"

if [ -f /etc/krb5.conf ]; then
    if grep -q "default_realm = $REALM" /etc/krb5.conf; then
        ok "E1. /etc/krb5.conf con el reino en MAYUSCULAS"
    elif grep -qi "default_realm" /etc/krb5.conf; then
        fallo "E1. El reino de Kerberos NO esta en mayusculas"
        info "     $(grep -i default_realm /etc/krb5.conf | head -1)"
    else
        fallo "E1. /etc/krb5.conf sin default_realm"
    fi
else
    fallo "E1. No existe /etc/krb5.conf"
    info "     Arreglo: sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf"
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 4 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 4 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 4 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_4.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que puedas autenticarte de verdad (kinit pide contrasena)"
  echo "  - Que exista la instantanea 'Fase 4 terminada'"
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
