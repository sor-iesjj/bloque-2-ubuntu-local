#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 1 (Infraestructura Virtual Local)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba el ESTADO FINAL del servidor y escribe un informe.
#           No modifica NADA. Solo lee.
#
# USO:
#   chmod +x verificar_fase1.sh
#   sudo ./verificar_fase1.sh
#
# El informe se guarda en verificacion-fase-1.txt, en la carpeta actual.
#
# LIMITE IMPORTANTE: este script corre DENTRO de Ubuntu, asi que solo ve lo de
# dentro. No puede comprobar la red solo-anfitrion de VirtualBox, ni las
# instantaneas, ni si el anfitrion llega al servidor. Eso se verifica a mano
# desde el anfitrion. El apartado 8.a te dice como.
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una comprobacion falla queremos seguir con el
# resto. Un verificador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-fase-1.txt"
FALLOS=0
AVISOS=0

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'
ok()    { echo -e "${V}[OK]   ${N} $1"; echo "[OK]    $1" >> "$INFORME"; }
fallo() { echo -e "${R}[FALLO]${N} $1"; echo "[FALLO] $1" >> "$INFORME"; FALLOS=$((FALLOS+1)); }
aviso() { echo -e "${A}[AVISO]${N} $1"; echo "[AVISO] $1" >> "$INFORME"; AVISOS=$((AVISOS+1)); }
info()  { echo "        $1"; echo "        $1" >> "$INFORME"; }

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo   ->   sudo ./verificar_fase1.sh"
    exit 1
fi

{
  echo "============================================================"
  echo " VERIFICACION DE LA FASE 1 - Bloque 2"
  echo " Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
  echo " Servidor: $(hostname)"
  echo "============================================================"
} > "$INFORME"
cat "$INFORME"

# =============================================================================
# BLOQUE A - LA RED DEL LABORATORIO
# =============================================================================
# Es lo que sostiene TODO el bloque. Si la IP 10.10.10.10 no esta, el dominio
# de la Fase 4 y el cliente de la Fase 8 fallaran sin apuntar aqui.
echo "" | tee -a "$INFORME"
echo "--- A. La red del laboratorio ---" | tee -a "$INFORME"

# A1. Primero: existe la tarjeta? Si no, el adaptador 2 no esta puesto en
#     VirtualBox y el problema no es de Ubuntu.
if ip link show enp0s8 >/dev/null 2>&1; then
    ok "A1. La tarjeta enp0s8 existe"
else
    fallo "A1. NO existe enp0s8 - falta el Adaptador 2 en VirtualBox (caso E4)"
    info "     Apaga la VM y revisa Configuracion > Red > Adaptador 2"
fi

# A2. Estado del enlace. Si esta DOWN, la IP no se ve aunque este configurada.
EST=$(ip -brief link show enp0s8 2>/dev/null | awk '{print $2}')
if [ "$EST" = "UP" ]; then
    ok "A2. enp0s8 levantada (estado UP)"
elif echo "$EST" | grep -q "DOWN"; then
    fallo "A2. enp0s8 en estado DOWN - el enlace esta caido, no la configuracion"
    info "     Si ademas ves NO-CARRIER, es el 'Cable conectado' de VirtualBox"
fi

# A3. La IP en caliente: lo que el sistema tiene AHORA.
if ip -4 addr show enp0s8 2>/dev/null | grep -q "10.10.10.10/24"; then
    ok "A3. IP 10.10.10.10/24 activa en enp0s8"
else
    fallo "A3. enp0s8 NO tiene la IP 10.10.10.10/24 (caso E5)"
    info "     Mira /etc/netplan/ y ejecuta: sudo netplan apply"
fi

# A4. La IP en frio: lo que sobrevive a un reinicio. Una IP puesta a mano con
#     'ip addr add' funciona hoy y desaparece manana. Esto lo distingue.
if grep -rq "10.10.10.10/24" /etc/netplan/ 2>/dev/null; then
    ok "A4. La IP esta en /etc/netplan/ (sobrevive al reinicio)"
else
    fallo "A4. La IP no aparece en /etc/netplan/ - se perdera al reiniciar"
    info "     Una IP que no esta en netplan no es configuracion, es un apano"
fi

# A5. netplan valida el fichero ANTES de aplicarlo: un YAML mal indentado NO
#     tumba la red, se rechaza y sigue valiendo la configuracion anterior. Por
#     eso hay que buscarlo: funciona hoy y falla en el proximo reinicio.
#
#     OJO AL DETALLE: 'netplan get' IMPRIME el error pero SALE CON CODIGO 0.
#     Comprobado en Ubuntu 26.04. Por eso no se mira '$?', se mira el TEXTO.
#     ('netplan generate' si devuelve 1, pero escribe en /run y este script
#     no modifica nada.)
NPOUT=$(netplan get 2>&1)
if echo "$NPOUT" | grep -qiE "command failed|invalid yaml|error in network definition"; then
    fallo "A5. Los ficheros de netplan tienen un error de sintaxis"
    info "     $(echo "$NPOUT" | head -1)"
    info "     La red funciona AHORA con la configuracion vieja, pero al"
    info "     reiniciar te quedas sin ella. Arreglalo antes de seguir."
else
    ok "A5. Los ficheros de netplan son sintacticamente validos"
fi

# A6. La salida a Internet va por la OTRA tarjeta, la de NAT. Son dos redes
#     distintas resolviendo dos problemas distintos.
if ip -4 addr show enp0s3 2>/dev/null | grep -q "inet "; then
    ok "A6. enp0s3 (NAT) tiene direccion: $(ip -4 -brief addr show enp0s3 | awk '{print $3}')"
else
    fallo "A6. enp0s3 sin direccion - sin ella no hay salida a Internet"
fi

if ip route | grep -q "^default"; then
    ok "A7. Existe ruta por defecto"
else
    fallo "A7. Sin ruta por defecto - el sistema no sabe por donde salir"
fi

# =============================================================================
# BLOQUE B - SALIDA AL EXTERIOR
# =============================================================================
# Se separa el 'llego' del 'resuelvo nombres': fallan por motivos distintos.
echo "" | tee -a "$INFORME"
echo "--- B. Salida a Internet ---" | tee -a "$INFORME"

if ping -c1 -W3 8.8.8.8 >/dev/null 2>&1; then
    ok "B1. Hay conectividad por IP (ping a 8.8.8.8)"
else
    fallo "B1. Sin salida a Internet - revisa que el Adaptador 1 este en NAT"
fi

if getent hosts archive.ubuntu.com >/dev/null 2>&1; then
    ok "B2. La resolucion de nombres funciona (DNS)"
else
    fallo "B2. No se resuelven nombres - hay red pero no DNS"
    info "     Sin DNS, 'apt update' fallara en la Fase 2"
fi

# =============================================================================
# BLOQUE C - IDENTIDAD DEL SERVIDOR
# =============================================================================
echo "" | tee -a "$INFORME"
echo "--- C. Identidad ---" | tee -a "$INFORME"

if [ "$(hostname)" = "UbuntuServer" ]; then
    ok "C1. hostname correcto: UbuntuServer"
else
    fallo "C1. hostname es '$(hostname)', deberia ser UbuntuServer (caso E12)"
    info "     Se cambia en DOS sitios: /etc/hostname y /etc/hosts"
fi

if id boochan >/dev/null 2>&1; then
    ok "C2. El usuario boochan existe"
else
    fallo "C2. No existe el usuario boochan"
fi

# En Ubuntu el poder administrativo lo da pertenecer al grupo 'sudo'.
if id -nG boochan 2>/dev/null | grep -qw sudo; then
    ok "C3. boochan pertenece al grupo sudo"
else
    fallo "C3. boochan NO esta en el grupo sudo - no podra administrar nada"
fi

# =============================================================================
# BLOQUE D - ACCESO REMOTO
# =============================================================================
# Ojo con el orden: instalado / arrancado / escuchando / con claves son cuatro
# cosas distintas, y un servidor puede tener tres de las cuatro.
echo "" | tee -a "$INFORME"
echo "--- D. Acceso remoto (SSH) ---" | tee -a "$INFORME"

if dpkg -s openssh-server >/dev/null 2>&1; then
    ok "D1. openssh-server instalado"
else
    fallo "D1. openssh-server NO instalado - marcalo en el instalador o instalalo ahora"
fi

if systemctl is-active ssh >/dev/null 2>&1 || systemctl is-active ssh.socket >/dev/null 2>&1; then
    ok "D2. El acceso SSH esta activo"
else
    fallo "D2. SSH no esta activo - sin el no puedes administrar el servidor"
fi

# D3. En Ubuntu 26.04 SSH arranca por ACTIVACION POR SOCKET: systemd escucha en
#     el 22 y arranca sshd cuando alguien llama. Por eso hay que mirar las dos
#     unidades: 'ssh' puede estar parado y el puerto seguir abierto.
if systemctl is-enabled ssh >/dev/null 2>&1 || systemctl is-enabled ssh.socket >/dev/null 2>&1; then
    ok "D3. SSH habilitado al arranque (funcionara tras reiniciar)"
else
    aviso "D3. SSH no arranca solo - funciona hoy, no tras reiniciar"
fi

if ss -tln | grep -q ":22 "; then
    ok "D4. Hay algo escuchando en el puerto 22"
else
    fallo "D4. Nadie escucha en el puerto 22 - el servidor no es alcanzable"
fi

# D5. Sin claves de host, sshd NO ARRANCA. Y no se regeneran solas al
#     reiniciar el servicio: hay que ejecutar 'ssh-keygen -A'.
NCLAVES=$(ls /etc/ssh/ssh_host_*_key 2>/dev/null | wc -l)
if [ "$NCLAVES" -ge 1 ]; then
    ok "D5. Claves de host presentes ($NCLAVES)"
    info "     Huella: $(ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null | awk '{print $2}')"
else
    fallo "D5. No hay claves de host - sshd no puede arrancar"
    info "     Reparacion: sudo ssh-keygen -A  &&  sudo systemctl restart ssh"
fi

# =============================================================================
# BLOQUE E - EL TECLADO
# =============================================================================
# Parece menor y no lo es: una contrasena tecleada con el mapa equivocado se
# guarda con los caracteres equivocados, y el fallo aparece al reiniciar.
echo "" | tee -a "$INFORME"
echo "--- E. Teclado y sistema ---" | tee -a "$INFORME"

if grep -q 'XKBLAYOUT="es"' /etc/default/keyboard 2>/dev/null; then
    ok "E1. Mapa de teclado espanol"
else
    aviso "E1. El teclado NO esta en espanol: $(grep XKBLAYOUT /etc/default/keyboard 2>/dev/null)"
    info "     Compruebalo escribiendo una @ en la consola de VirtualBox (caso E2)"
fi

VER=$(. /etc/os-release 2>/dev/null && echo "$VERSION_ID")
if [ "$VER" = "26.04" ]; then
    ok "E2. Ubuntu Server 26.04"
else
    aviso "E2. La version instalada es $VER, el material esta probado sobre 26.04"
fi

# =============================================================================
# VEREDICTO
# =============================================================================
echo "" | tee -a "$INFORME"
echo "============================================================" | tee -a "$INFORME"
if [ "$FALLOS" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 1 SUPERADA (por dentro)" | tee -a "$INFORME"
elif [ "$FALLOS" -eq 0 ]; then
    echo " VEREDICTO: FASE 1 SUPERADA (por dentro) CON $AVISOS AVISO(S)" | tee -a "$INFORME"
    echo " Un aviso no impide seguir, pero LEELO: mira arriba cual es." | tee -a "$INFORME"
else
    echo " VEREDICTO: FASE 1 NO SUPERADA - $FALLOS FALLO(S)" | tee -a "$INFORME"
    echo " Busca cada caso (E1-E13) en Fase_1.7_Resolucion_Problemas." | tee -a "$INFORME"
fi
echo "============================================================" | tee -a "$INFORME"

# El aviso mas importante del script: lo que NO ha mirado.
{
  echo ""
  echo "ESTE SCRIPT NO HA COMPROBADO (esta fuera de Ubuntu):"
  echo "  - Que la red solo-anfitrion de VirtualBox sea 10.10.10.1/255.255.255.0"
  echo "  - Que el DHCP de esa red este DESACTIVADO"
  echo "  - Que el anfitrion llegue al servidor (ping y ssh desde tu Windows)"
  echo "  - Que existan las instantaneas 'Sistema base' y 'Fase 1 terminada'"
  echo "  - Que exista la copia .ova en tu disco externo"
  echo "Esas cinco se verifican A MANO. Las tienes en el apartado 8.a."
} | tee -a "$INFORME"

# El script corre con sudo: devolvemos el informe a su dueno para que pueda
# subirlo comodamente a su repositorio.
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "$INFORME" 2>/dev/null
fi

echo ""
echo "Informe guardado en: $(pwd)/$INFORME"
echo "Subelo a tu repositorio junto con la entrada de apuntes."

[ "$FALLOS" -eq 0 ] && exit 0 || exit 1
