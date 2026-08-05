#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificación de la Fase 3 (Conectividad VPN con WireGuard)
# =============================================================================
# Módulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUÉ HACE: comprueba el ESTADO FINAL del servidor y escribe un informe.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase3.sh
#   sudo ./verificar_fase3.sh
#
# El informe se guarda en verificacion-fase-3.txt, en la carpeta actual.
# Súbelo a tu repositorio junto con la entrada de apuntes.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla, queremos seguir
# comprobando el resto. Un verificador que aborta al primer fallo solo te
# cuenta el primer problema, y normalmente hay mas de uno.

INFORME="verificacion-fase-3.txt"
FALLOS=0
AVISOS=0

# --- Colores para la pantalla. El informe se guarda SIN colores ------------
V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'

# ok / fallo / aviso: escriben a la vez en pantalla (con color) y en el
# fichero (sin color). Asi el alumno ve el resultado y ademas queda registro.
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

# --- Comprobacion previa: hace falta root ----------------------------------
# 'wg show' y 'ss -tlnp' no dan informacion completa sin privilegios.
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase3.sh"
    exit 1
fi

# Cabecera del informe. La fecha importa: permite saber CUANDO se verifico.
{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 3 - BoochanV1"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname) / $(hostname -f 2>/dev/null)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LO QUE VIENE DE FASES ANTERIORES
# =============================================================================
# Se comprueba PRIMERO y a proposito: la Fase 3 se construye encima de la 1 y
# la 2. Si la red o el nombre se rompieron, el tunel puede parecer correcto y
# aun asi la Fase 4 fallara. Diagnosticar de abajo hacia arriba.
echo "" | tee -a "$INFORME"
echo "--- A. Base de las fases anteriores ---" | tee -a "$INFORME"

# A1. IP fija de la Fase 1 en la tarjeta solo-anfitrion
if ip -4 addr show | grep -q "10.10.10.10/24"; then
    ok "A1. IP 10.10.10.10 presente (Fase 1)"
else
    fallo "A1. NO existe la IP 10.10.10.10 - revisa /etc/netplan/ (Fase 1, caso E5)"
fi

# A2. Nombre completo de la Fase 2. Sin FQDN, la Fase 4 aprovisiona mal.
FQDN=$(hostname -f 2>/dev/null)
if [ "$FQDN" = "UbuntuServer.BOOCHANLAB.LOCAL" ]; then
    ok "A2. FQDN correcto: $FQDN (Fase 2)"
else
    fallo "A2. FQDN incorrecto: '$FQDN' - revisa /etc/hosts (Fase 2, casos E6 y E7)"
fi

# A3. Paquetes del dominio. Se instalan en la Fase 2 y hacen falta en la 4.
FALTAN=""
for p in samba-ad-dc samba-ad-provision; do
    dpkg -s "$p" >/dev/null 2>&1 || FALTAN="$FALTAN $p"
done
if [ -z "$FALTAN" ]; then
    ok "A3. Paquetes del dominio instalados (Fase 2)"
else
    fallo "A3. Faltan paquetes:$FALTAN - la Fase 4 sera imposible"
fi

# =============================================================================
# BLOQUE B - EL TUNEL (el nucleo de esta fase)
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- B. El tunel WireGuard ---" | tee -a "$INFORME"

# B1. La interfaz virtual tiene que existir Y tener la IP del tunel.
if ip -4 addr show wg0 2>/dev/null | grep -q "10.20.20.1/24"; then
    ok "B1. Interfaz wg0 levantada con 10.20.20.1/24"
else
    fallo "B1. wg0 no existe o no tiene 10.20.20.1/24 - el tunel no esta levantado"
fi

# B2. EL HANDSHAKE: la unica prueba real de que los dos extremos se reconocen.
# 'latest-handshakes' devuelve el momento del ultimo saludo en formato epoch.
# Un 0 significa que NUNCA se han saludado.
HS=$(wg show wg0 latest-handshakes 2>/dev/null | awk '{print $2}' | sort -rn | head -1)
if [ -z "$HS" ]; then
    fallo "B2. No hay ningun peer configurado - falta el bloque [Peer] en wg0.conf"
elif [ "$HS" = "0" ]; then
    fallo "B2. Hay peer pero NUNCA hubo handshake - llaves mal cruzadas (caso E3)"
else
    EDAD=$(( $(date +%s) - HS ))
    if [ "$EDAD" -lt 300 ]; then
        ok "B2. Handshake correcto (hace ${EDAD}s) - los dos extremos se reconocen"
    else
        aviso "B2. Ultimo handshake hace ${EDAD}s - el cliente no esta conectado ahora"
        info "     No es un fallo si el tunel funciono: activalo y repite."
    fi
fi

# B3. Trafico en AMBOS sentidos. Solo enviar y no recibir es el sintoma
# clasico de que el servidor no reconoce al cliente y lo ignora en silencio.
TRANSFER=$(wg show wg0 transfer 2>/dev/null | head -1)
RX=$(echo "$TRANSFER" | awk '{print $2}')
TX=$(echo "$TRANSFER" | awk '{print $3}')
if [ -n "$RX" ] && [ "$RX" -gt 0 ] 2>/dev/null && [ "$TX" -gt 0 ] 2>/dev/null; then
    ok "B3. Trafico bidireccional: ${RX}B recibidos / ${TX}B enviados"
else
    aviso "B3. Trafico incompleto (rx=${RX:-0} tx=${TX:-0}) - normal si el cliente esta desconectado"
fi

# B4. WireGuard es UDP. Buscarlo con 'ss -tlnp' (TCP) es un error clasico.
if ss -ulnp 2>/dev/null | grep -q ":51820"; then
    ok "B4. Escuchando en UDP 51820"
else
    fallo "B4. Nadie escucha en UDP 51820 - el tunel no esta activo"
fi

# =============================================================================
# BLOQUE C - CONFIGURACION: LOS ERRORES QUE NO DAN ERROR
# =============================================================================
# Estos tres fallos NO impiden que el tunel levante. Se manifiestan mas tarde,
# de forma intermitente, y entonces ya nadie los relaciona con este fichero.
echo "" | tee -a "$INFORME"
echo "--- C. Configuracion del servidor ---" | tee -a "$INFORME"

CONF="/etc/wireguard/wg0.conf"
if [ ! -f "$CONF" ]; then
    fallo "C0. No existe $CONF"
else
    # C1. 'Endpoint' en el servidor: le estaria diciendo que para hablar con el
    # cliente se envie los paquetes a si mismo.
    if grep -q "^\s*Endpoint" "$CONF"; then
        fallo "C1. El servidor tiene 'Endpoint' - eso va SOLO en el cliente (caso E4)"
    else
        ok "C1. Sin 'Endpoint' en el servidor (correcto)"
    fi

    # C2. AllowedIPs del peer debe ser /32: "este cliente es exactamente esta
    # direccion". Con /24 el servidor no sabe a quien enviar cada paquete.
    if grep -qE "^\s*AllowedIPs\s*=\s*10\.20\.20\.[0-9]+/32" "$CONF"; then
        ok "C2. AllowedIPs del peer con mascara /32 (correcto)"
    else
        fallo "C2. AllowedIPs del peer NO es /32 - enrutado ambiguo"
        info "     Debe ser: AllowedIPs = 10.20.20.2/32"
    fi

    # C3. El fichero contiene la clave privada del servidor: solo root debe leerlo.
    PERMS=$(stat -c "%a" "$CONF")
    if [ "$PERMS" = "600" ] || [ "$PERMS" = "640" ]; then
        ok "C3. Permisos de wg0.conf correctos ($PERMS)"
    else
        aviso "C3. Permisos de wg0.conf demasiado abiertos ($PERMS) - deberian ser 600"
    fi
fi

# =============================================================================
# BLOQUE D - PERSISTENCIA
# =============================================================================
# Lo mas importante de cara a la Auditoria Final: cuando SSH solo escuche en
# la IP del tunel, un tunel que no arranque solo deja el servidor inaccesible.
echo "" | tee -a "$INFORME"
echo "--- D. Persistencia tras reinicio ---" | tee -a "$INFORME"

if systemctl is-enabled wg-quick@wg0 >/dev/null 2>&1; then
    ok "D1. wg-quick@wg0 habilitado - el tunel arranca solo"
else
    fallo "D1. wg-quick@wg0 NO habilitado - al reiniciar NO habra tunel"
    info "     Arreglo: sudo systemctl enable wg-quick@wg0"
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 3 SUPERADA" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 3 SUPERADA CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Los avisos suelen ser el cliente desconectado. Revisalos." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 3 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso (E1-E6) en Fase_3.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"
echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

# Codigo de salida: 0 si todo bien, 1 si hubo fallos. Permite encadenarlo
# con otros comandos o usarlo desde otro script.
[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
