#!/bin/bash
# =============================================================================
# BOOCHAN V1 - Aprovisionamiento de Samba AD DC (VirtualBox, laboratorio local)
# =============================================================================
# Módulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
# Profesor: Pedro Navarro Miralles
#
# USO:
#   sudo ./provision_boochan.sh
#   sudo ./provision_boochan.sh OTRODOMINIO OTRO.REALM OtraContrasena
#
# ANTES DE EJECUTARLO: léelo entero. Nunca ejecutes como root un script que no
# has leído. Esto no es una formalidad: aquí dentro hay comandos que borran
# ficheros del sistema y hacen inmutable /etc/resolv.conf.
# =============================================================================

set -euo pipefail   # Aborta al primer error. Ver nota al final del fichero.

DOMAIN_NAME=${1:-"BOOCHANLAB"}
REALM_NAME=${2:-"BOOCHANLAB.LOCAL"}
ADMIN_PASS=${3:-"P@ssw0rd"}
DNS_FORWARDER="8.8.8.8"
# IP del servidor en la red del laboratorio (adaptador solo-anfitrion).
# IMPRESCINDIBLE: esta VM tiene DOS tarjetas, y si no se le dice cual usar,
# samba-tool elige la primera que encuentra (la NAT, 10.0.2.x). El dominio se
# anunciaria entonces en una IP que nadie puede alcanzar, y la Fase 8 fallaria
# sin dar ninguna pista del motivo.
HOST_IP="10.10.10.10"

echo "=== Despliegue del Reino: $REALM_NAME ==="

# --- 0. COMPROBACIONES PREVIAS --------------------------------------------
# Si algo falta, es mejor parar aquí que a mitad del aprovisionamiento.

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecútalo con sudo."; exit 1
fi

FALTAN=""
for cmd in samba-tool chattr; do
    command -v "$cmd" >/dev/null 2>&1 || FALTAN="$FALTAN $cmd"
done
if [ -n "$FALTAN" ]; then
    echo "ERROR: faltan comandos:$FALTAN"
    echo "       Vuelve al Paso 2 de la Fase 2 e instala los paquetes."
    exit 1
fi

# Ubuntu 24.04+ reparte el AD DC en paquetes separados del paquete 'samba'.
for pkg in samba-ad-dc samba-ad-provision; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "ERROR: falta el paquete '$pkg', imprescindible para el dominio."
        echo "       Instálalo con: sudo apt install -y samba-ad-dc samba-ad-provision"
        exit 1
    fi
done

echo "[OK] Comprobaciones previas superadas."

# --- 1. Aprovisionamiento del Dominio -------------------------------------
# ORDEN IMPORTANTE: esto va ANTES de tocar el DNS. Si el aprovisionamiento
# falla, el servidor conserva su resolucion de nombres y puedes seguir
# instalando paquetes para arreglarlo. Al reves -como estaba antes- un fallo
# aqui te dejaba sin DNS y sin forma de instalar nada: encerrado fuera.
#
# samba-tool se NIEGA a aprovisionar si existe un smb.conf con 'server role =
# standalone server', que es justo el que crea el paquete 'samba' al
# instalarse. Hay que apartarlo: el provision genera el suyo.
# --use-rfc2307 es imprescindible: guarda UID/GID de Unix dentro de Active
# Directory. Sin esto, la Fase 5 (winbind) no puede funcionar.
echo "[1/4] Aprovisionando el dominio (2-3 minutos)..."
if [ -f /etc/samba/smb.conf ]; then
    mv /etc/samba/smb.conf "/etc/samba/smb.conf.bak-$(date +%s)"
fi

samba-tool domain provision \
 --server-role=dc \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --realm="$REALM_NAME" \
 --domain="$DOMAIN_NAME" \
 --adminpass="$ADMIN_PASS" \
 --host-ip="$HOST_IP" \
 --option="dns forwarder = $DNS_FORWARDER"

# --- 2. Configuración Kerberos --------------------------------------------
echo "[2/4] Configurando Kerberos..."
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# --- 3. Activación del Servidor AD DC -------------------------------------
# smbd, nmbd y winbind son los servicios del Samba "clasico" y ocupan los
# puertos que necesita el controlador de dominio. samba-ad-dc los sustituye a
# los tres. Viene enmascarado de fabrica, de ahi el unmask.
# El stub de systemd-resolved se apaga AQUI, justo antes de levantar Samba,
# para que su DNS interno pueda quedarse con el puerto 53.
echo "[3/4] Activando samba-ad-dc..."
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
systemctl disable --now smbd nmbd winbind 2>/dev/null || true
systemctl unmask samba-ad-dc
systemctl enable --now samba-ad-dc

# --- 4. DNS Persistente: apuntar el servidor a si mismo --------------------
# Ultimo paso a proposito. Ahora SI hay un servidor DNS escuchando en
# 127.0.0.1 (el de Samba), asi que apuntar ahi tiene sentido.
# chattr +i lo deja inmutable: ni root puede sobrescribirlo, que es lo que
# systemd-resolved intentaria en cada arranque.
# El 'chattr -i' inicial es lo que permite RELANZAR el script: sin el, el 'rm'
# fallaria con "Operation not permitted" por el candado de la vez anterior.
echo "[4/4] Fijando el DNS del servidor..."
chattr -i /etc/resolv.conf 2>/dev/null || true
rm -f /etc/resolv.conf
printf "nameserver 127.0.0.1\nsearch %s\n" "$REALM_NAME" > /etc/resolv.conf
chattr +i /etc/resolv.conf

# --- VERIFICACIÓN FINAL ----------------------------------------------------
# Un script que dice "finalizado" sin comprobar nada es un script que miente.
echo ""
DNS_OK="no"
if host -t A "$(hostname).$(echo "$REALM_NAME" | tr 'A-Z' 'a-z')" 127.0.0.1 >/dev/null 2>&1; then
    DNS_OK="si"
fi

if systemctl is-active --quiet samba-ad-dc; then
    echo "=========================================================="
    echo " Despliegue de $DOMAIN_NAME finalizado CORRECTAMENTE."
    echo " Realm: $REALM_NAME"
    echo " Comprueba ahora:  sudo samba-tool domain level show"
    echo " Y que el dominio apunta a la IP correcta:"
    echo "   host -t A $(hostname).$(echo $REALM_NAME | tr 'A-Z' 'a-z')"
    echo "   -> debe devolver $HOST_IP , NO una 10.0.2.x"
    if [ "$DNS_OK" = "no" ]; then
        echo ""
        echo " AVISO: el DNS del dominio aun no responde. Suele resolverse solo"
        echo "        en unos segundos. Si persiste: systemctl restart samba-ad-dc"
    fi
    echo "=========================================================="
else
    echo "!!! El servicio samba-ad-dc NO está activo."
    echo "!!! Revisa:  sudo systemctl status samba-ad-dc"
    exit 1
fi

# =============================================================================
# NOTA sobre 'set -euo pipefail' (primera línea del script):
#   -e  aborta en cuanto un comando falla
#   -u  aborta si se usa una variable no definida
#   -o pipefail  detecta fallos dentro de una tubería
# Sin esto, el script seguía adelante con todo roto y terminaba diciendo que
# había ido bien. Un script de administración debe PARAR cuando algo falla:
# es peor un despliegue a medias y silencioso que un error a tiempo.
# =============================================================================
