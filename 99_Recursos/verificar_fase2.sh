#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificación de la Fase 2 (Purga y Preparación del Entorno)
# =============================================================================
# Módulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUÉ HACE: comprueba el ESTADO FINAL del servidor y escribe un informe.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase2.sh
#   sudo ./verificar_fase2.sh
#
# El informe se guarda en verificacion-fase-2.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-2.txt"
FALLOS=0
AVISOS=0

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase2.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 2 - BoochanV1"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE LA FASE 1
# =============================================================================
# Se comprueba primero: la Fase 2 se construye sobre la red de la Fase 1.
echo "" | tee -a "$INFORME"
echo "--- A. Base de la Fase 1 ---" | tee -a "$INFORME"

if ip -4 addr show | grep -q "10.10.10.10/24"; then
    ok "A1. IP 10.10.10.10 presente (Fase 1)"
else
    fallo "A1. NO existe la IP 10.10.10.10 - revisa /etc/netplan/ (Fase 1, caso E5)"
fi

if systemctl is-active ssh >/dev/null 2>&1; then
    ok "A2. Servicio SSH activo"
else
    fallo "A2. SSH no esta activo - sin el no puedes administrar el servidor"
fi

# =============================================================================
# BLOQUE B - IDENTIDAD DEL SERVIDOR (el nucleo de esta fase)
# =============================================================================
# Sobre este nombre se aprovisionara el dominio en la Fase 4. Si esta mal,
# el dominio se levanta mal y el error aparece dos fases mas tarde.
echo "" | tee -a "$INFORME"
echo "--- B. Identidad del servidor ---" | tee -a "$INFORME"

# B1. Nombre corto
if [ "$(hostname)" = "UbuntuServer" ]; then
    ok "B1. hostname corto correcto: UbuntuServer"
else
    fallo "B1. hostname corto es '$(hostname)', deberia ser UbuntuServer (caso E12 de la Fase 1)"
fi

# B2. EL punto clave de la fase: el nombre completo.
FQDN=$(hostname -f 2>/dev/null)
if [ "$FQDN" = "UbuntuServer.BOOCHANLAB.LOCAL" ]; then
    ok "B2. FQDN correcto: $FQDN"
else
    fallo "B2. FQDN incorrecto: '$FQDN' - la Fase 4 aprovisionaria mal el dominio"
    info "     Revisa /etc/hosts (casos E6 y E7). Debe ser: IP  FQDN  nombre_corto"
fi

# B3. El fichero no puede estar vacio: en Ubuntu 26.04 viene asi de fabrica.
if [ ! -s /etc/hosts ]; then
    fallo "B3. /etc/hosts esta VACIO - viene asi de fabrica en Ubuntu 26.04 (caso E6)"
elif grep -qE "^\s*127\.0\.0\.1\s+localhost" /etc/hosts; then
    ok "B3. /etc/hosts tiene la linea de localhost"
else
    fallo "B3. Falta '127.0.0.1 localhost' - el sistema no se encuentra a si mismo"
fi

# B4. La linea 127.0.1.1 gana a la del 10.10.10.10 porque va antes, y deja
# el nombre del servidor apuntando a bucle local. La Fase 4 lo sufriria.
if grep -qE "^\s*127\.0\.1\.1" /etc/hosts; then
    fallo "B4. Existe una linea 127.0.1.1 - hace que hostname -f devuelva el nombre corto"
    info "     Arreglo: sudo sed -i '/^127\.0\.1\.1/d' /etc/hosts"
else
    ok "B4. Sin linea 127.0.1.1 (correcto para un controlador de dominio)"
fi

# B5. Orden de columnas: hostname -f devuelve el SEGUNDO campo.
if grep -qE "^\s*10\.10\.10\.10\s+UbuntuServer\.BOOCHANLAB\.LOCAL\s+UbuntuServer" /etc/hosts; then
    ok "B5. Orden de columnas correcto: IP, FQDN, nombre corto"
else
    aviso "B5. La linea del dominio no sigue el orden IP / FQDN / nombre corto"
    info "     Debe ser: 10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer"
fi

# =============================================================================
# BLOQUE C - PAQUETES DEL DOMINIO
# =============================================================================
# Desde Ubuntu 24.04 el AD DC va en paquetes separados del paquete 'samba'.
echo "" | tee -a "$INFORME"
echo "--- C. Paquetes para la Fase 4 ---" | tee -a "$INFORME"

FALTAN=""
for p in samba samba-ad-dc samba-ad-provision krb5-user winbind acl attr wireguard; do
    dpkg -s "$p" >/dev/null 2>&1 || FALTAN="$FALTAN $p"
done
if [ -z "$FALTAN" ]; then
    ok "C1. Los 8 paquetes necesarios estan instalados"
else
    fallo "C1. Faltan paquetes:$FALTAN"
    info "     Sin samba-ad-dc y samba-ad-provision, la Fase 4 es IMPOSIBLE"
fi

# C2. Kerberos con el reino en MAYUSCULAS. En minusculas falla la autenticacion.
if grep -qi "default_realm.*BOOCHANLAB.LOCAL" /etc/krb5.conf 2>/dev/null; then
    if grep -q "default_realm = BOOCHANLAB.LOCAL" /etc/krb5.conf; then
        ok "C2. Kerberos con el reino en MAYUSCULAS"
    else
        fallo "C2. El reino de Kerberos NO esta en mayusculas - la autenticacion fallara"
    fi
else
    fallo "C2. /etc/krb5.conf sin default_realm = BOOCHANLAB.LOCAL"
fi

# =============================================================================
# BLOQUE D - ACTUALIZACION DEL SISTEMA (CE.01.h)
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- D. Sistema actualizado ---" | tee -a "$INFORME"

PEND=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
if [ "$PEND" -le 5 ]; then
    ok "D1. Sistema actualizado ($PEND paquete(s) pendiente(s))"
else
    aviso "D1. Hay $PEND paquetes sin actualizar - ejecuta sudo apt upgrade -y"
fi

# 'dpkg --audit' vacio = ningun paquete a medio configurar.
if [ -z "$(dpkg --audit 2>/dev/null)" ]; then
    ok "D2. Sin paquetes rotos ni a medio configurar"
else
    fallo "D2. Hay paquetes en mal estado - ejecuta sudo dpkg --configure -a"
fi

if [ -f /var/run/reboot-required ]; then
    aviso "D3. El sistema pide reinicio (kernel nuevo sin usar)"
else
    ok "D3. No hay reinicios pendientes"
fi

# =============================================================================
# BLOQUE E - SERVICIOS
# =============================================================================
# Ojo: que smbd este activo AQUI es CORRECTO. El Paso 2 lo reinstalo a
# proposito. Es el error de diagnostico mas caro de esta fase.
echo "" | tee -a "$INFORME"
echo "--- E. Servicios ---" | tee -a "$INFORME"

if systemctl is-active smbd >/dev/null 2>&1; then
    ok "E1. smbd activo (CORRECTO: el Paso 2 lo reinstala a proposito)"
else
    aviso "E1. smbd no esta activo - no impide seguir, la Fase 4 usa samba-ad-dc"
fi

if systemctl is-enabled smbd >/dev/null 2>&1; then
    ok "E2. smbd habilitado al arranque"
else
    aviso "E2. smbd no arranca solo - funciona hoy, no tras reiniciar"
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 2 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 2 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 2 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso (E1-E12) en Fase_2.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

# El script corre con sudo: devolvemos el informe a su dueno para que pueda
# subirlo comodamente a su repositorio.
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
