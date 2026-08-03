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

# --- 1. Gestión DNS Persistente -------------------------------------------
# systemd-resolved ocupa el puerto 53, que Samba necesita para su propio DNS.
# chattr +i deja /etc/resolv.conf inmutable: ni root puede sobrescribirlo, que
# es lo que systemd-resolved intentaría en cada arranque.
# El 'chattr -i' inicial es lo que permite RELANZAR este script: sin él, el
# 'rm' fallaría porque el fichero quedó inmutable en la ejecución anterior.
echo "[1/4] Configurando DNS..."
chattr -i /etc/resolv.conf 2>/dev/null || true
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
rm -f /etc/resolv.conf
printf "nameserver 127.0.0.1\nsearch %s\n" "$REALM_NAME" > /etc/resolv.conf
chattr +i /etc/resolv.conf

# --- 2. Aprovisionamiento Automático (Desatendido) ------------------------
# samba-tool se NIEGA a aprovisionar si existe un smb.conf con 'server role =
# standalone server', que es justo el que crea el paquete 'samba' al
# instalarse. Hay que quitarlo de en medio: el provision genera el suyo.
# --use-rfc2307 es imprescindible: guarda UID/GID de Unix dentro de Active
# Directory. Sin esto, la Fase 5 (winbind) no puede funcionar.
echo "[2/4] Aprovisionando el dominio (2-3 minutos)..."
[ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.bak-$(date +%s)

samba-tool domain provision \
 --server-role=dc \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --realm="$REALM_NAME" \
 --domain="$DOMAIN_NAME" \
 --adminpass="$ADMIN_PASS" \
 --option="dns forwarder = $DNS_FORWARDER"

# --- 3. Configuración Kerberos --------------------------------------------
echo "[3/4] Configurando Kerberos..."
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# --- 4. Activación del Servidor AD DC -------------------------------------
# smbd, nmbd y winbind son los servicios del Samba "clásico" y ocupan los
# puertos que necesita el controlador de dominio. samba-ad-dc los sustituye a
# los tres. Viene enmascarado de fábrica, de ahí el unmask.
echo "[4/4] Activando samba-ad-dc..."
systemctl disable --now smbd nmbd winbind 2>/dev/null || true
systemctl unmask samba-ad-dc
systemctl enable --now samba-ad-dc

# --- VERIFICACIÓN FINAL ----------------------------------------------------
# Un script que dice "finalizado" sin comprobar nada es un script que miente.
echo ""
if systemctl is-active --quiet samba-ad-dc; then
    echo "=========================================================="
    echo " Despliegue de $DOMAIN_NAME finalizado CORRECTAMENTE."
    echo " Realm: $REALM_NAME"
    echo " Comprueba ahora:  sudo samba-tool domain level show"
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
