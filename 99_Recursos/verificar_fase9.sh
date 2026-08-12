#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 9 (Integracion del Cliente Ubuntu Desktop)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba desde el CLIENTE UBUNTU DESKTOP que la union al dominio
#           funciona, que la hora y el DNS estan bien, y que el cliente llega
#           al servidor. No modifica NADA. Solo lee.
#
# USO (en el cliente Ubuntu Desktop):
#   chmod +x verificar_fase9.sh
#   sudo ./verificar_fase9.sh
#
# IMPORTANTE: este script corre DENTRO del cliente Ubuntu, asi que solo ve lo
#             de dentro. No puede comprobar lo que se ve desde el servidor
#             (que la matriz se respeta) ni las instantaneas. Eso es del 8.a.
#
# El informe se guarda en verificacion-fase-9.txt, en la carpeta actual.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-9.txt"
FALLOS=0
AVISOS=0

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

# --- Datos del escenario (se cambian AQUI si cambia algo) ---------------------
SERVIDOR_IP="10.10.10.10"
DOMINIO="BOOCHANLAB.LOCAL"
USUARIO_PRUEBA="masao.sato"
UID_ESPERADO="10005"
ZONA_HORARIA="Europe/Madrid"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase9.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 9 - BoochanV1 (cliente Ubuntu Desktop)"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Equipo:   $(hostname)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - RED: EL CLIENTE LLEGA AL SERVIDOR
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- A. Red del laboratorio ---" | tee -a "$INFORME"

IP_LOCAL=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | tr '\n' ' ')
info "     IPs del cliente: ${IP_LOCAL:-ninguna}"

if echo "$IP_LOCAL" | grep -q "10.10.10."; then
    ok "A1. El cliente tiene una IP de la red del laboratorio (10.10.10.0/24)"
else
    fallo "A1. El cliente NO tiene IP de la red 10.10.10.0/24"
    info "     Tiene: ${IP_LOCAL:-ninguna} - comprueba el adaptador de red (Paso 2)"
fi

if ping -c 2 -W 2 "$SERVIDOR_IP" >/dev/null 2>&1; then
    ok "A2. El servidor $SERVIDOR_IP responde al ping"
else
    fallo "A2. El servidor $SERVIDOR_IP NO responde"
    info "     Sin red no hay dominio. Comprueba la Red Solo Anfitrion."
fi

# =============================================================================
# BLOQUE B - DNS: EL CLIENTE RESUELVE EL DOMINIO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. DNS ---" | tee -a "$INFORME"

DNS_ACTUAL=$(cat /etc/resolv.conf 2>/dev/null | grep -E "nameserver" | awk '{print $2}' | tr '\n' ' ')
info "     DNS configurado: ${DNS_ACTUAL:-ninguno}"

if getent hosts "$DOMINIO" >/dev/null 2>&1; then
    RESOL=$(getent hosts "$DOMINIO" | head -1 | awk '{print $1}')
    if [ "$RESOL" = "$SERVIDOR_IP" ]; then
        ok "B1. $DOMINIO resuelve a $SERVIDOR_IP"
    else
        fallo "B1. $DOMINIO resuelve a $RESOL, deberia ser $SERVIDOR_IP"
        info "     El dominio se anuncio en otra IP - viene de la Fase 4."
    fi
else
    fallo "B1. No se puede resolver $DOMINIO"
    info "     El DNS del cliente no apunta a $SERVIDOR_IP. Paso 5 del procedimiento."
fi

# =============================================================================
# BLOQUE C - LA UNION AL DOMINIO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Union al dominio ---" | tee -a "$INFORME"

if command -v realm >/dev/null 2>&1; then
    if realm list 2>/dev/null | grep -qi "$DOMINIO"; then
        ok "C1. El equipo esta unido al dominio $DOMINIO"
        MODE=$(realm list 2>/dev/null | grep -i "login-formats\|configured" | head -2)
        info "     $MODE"
    else
        fallo "C1. El equipo NO esta unido a $DOMINIO"
        info "     Ejecuta: sudo realm join --user=Administrator $DOMINIO (Paso 7)"
    fi
else
    fallo "C1. No se encuentra el comando 'realm'"
    info "     Instala realmd: sudo apt install realmd sssd sssd-tools (Paso 6)"
fi

# =============================================================================
# BLOQUE D - LA HORA (el fallo n.1)
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- D. Hora y zona horaria ---" | tee -a "$INFORME"

ZONA_ACTUAL=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
if [ "$ZONA_ACTUAL" = "$ZONA_HORARIA" ]; then
    ok "D1. Zona horaria correcta: $ZONA_ACTUAL"
else
    fallo "D1. Zona horaria '$ZONA_ACTUAL', deberia ser '$ZONA_HORARIA'"
    info "     Kerberos rechaza el desfase. Ejecuta: sudo timedatectl set-timezone Europe/Madrid"
fi

# Ubuntu Desktop sincroniza por defecto con systemd-timesyncd (no con chrony).
# Se comprueba que HAY sincronizacion (con la herramienta que sea) y se avisa
# solo si NO hay ninguna.
SYNC_OK=0
if command -v chronyc >/dev/null 2>&1 && chronyc tracking 2>/dev/null | grep -qi "leap.*normal\|System clock"; then
    ok "D2. Sincronizacion de hora funcionando (chrony)"
    SYNC_OK=1
elif timedatectl 2>/dev/null | grep -qi "systemd-timesyncd.*active\|NTP service: active"; then
    ok "D2. Sincronizacion de hora funcionando (systemd-timesyncd)"
    SYNC_OK=1
fi
if [ "$SYNC_OK" -eq 0 ]; then
    aviso "D2. No se detecta sincronizacion de hora activa"
    info "     Comprueba 'timedatectl' - la zona horaria (D1) es lo critico."
fi

# =============================================================================
# BLOQUE E - EL USUARIO DEL DOMINIO SE RESUELVE
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- E. Identidades del dominio ---" | tee -a "$INFORME"

SALIDA=$(getent passwd "$USUARIO_PRUEBA" 2>/dev/null)
if [ -n "$SALIDA" ]; then
    UID_REAL=$(echo "$SALIDA" | cut -d: -f3)
    if [ "$UID_REAL" = "$UID_ESPERADO" ]; then
        ok "E1. $USUARIO_PRUEBA resuelve con uid=$UID_REAL (el del escenario)"
    else
        fallo "E1. $USUARIO_PRUEBA resuelve con uid=$UID_REAL, deberia ser $UID_ESPERADO"
        info "     La traduccion SSSD no da el UID correcto. Revisa la Fase 5."
    fi
else
    fallo "E1. '$USUARIO_PRUEBA' no resuelve como usuario del dominio"
    info "     SSSD no traduce las identidades. Comprueba la union (C1) y la hora (D1)."
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 9 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 9 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no es un fallo: es algo que TU tienes que justificar." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 9 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso en Fase_9.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO:"
  echo "  - Que las carpetas sean INVISIBLES de verdad desde Nautilus"
  echo "  - Que un usuario sin permiso no pueda entrar de verdad"
  echo "  - Que existan las instantaneas 'Fase 9 terminada' ni la copia .ova"
  echo ""
  echo "OJO: la prueba REAL de esta fase se hace desde el cliente, iniciando"
  echo "sesion con usuarios distintos (las 7 pruebas del 8.a)."
  echo "Aqui solo se comprueba que el cliente esta bien unido y llega al servidor."
} | tee -a "$INFORME"

if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
