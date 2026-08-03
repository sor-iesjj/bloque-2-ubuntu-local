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

DOMAIN_NAME=${1:-"BOOCHANLAB"}
REALM_NAME=${2:-"BOOCHANLAB.LOCAL"}
ADMIN_PASS=${3:-"P@ssw0rd"}
DNS_FORWARDER="8.8.8.8"

echo "--- Iniciando el despliegue desatendido del Reino: $REALM_NAME ---"

# --- 1. Gestión DNS Persistente -------------------------------------------
# systemd-resolved ocupa el puerto 53, que Samba necesita para su propio DNS.
# Se desactiva su "stub listener" y se apunta el servidor a sí mismo.
# chattr +i deja /etc/resolv.conf inmutable: ni el propio root puede
# sobrescribirlo, que es justo lo que systemd-resolved intentaría en cada
# arranque o reconfiguración de red.
sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
sudo rm -f /etc/resolv.conf
echo -e "nameserver 127.0.0.1\nsearch $REALM_NAME" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

# --- 2. Aprovisionamiento Automático (Desatendido) ------------------------
# --use-rfc2307 es imprescindible: permite guardar UID/GID de Unix dentro de
# Active Directory. Sin esto, la Fase 5 (winbind) no puede funcionar.
sudo samba-tool domain provision \
 --server-role=dc \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --realm=$REALM_NAME \
 --domain=$DOMAIN_NAME \
 --adminpass=$ADMIN_PASS \
 --option="dns forwarder = $DNS_FORWARDER"

# --- 3. Configuración Kerberos --------------------------------------------
# El provisionamiento genera un krb5.conf a medida del dominio; se copia al
# sitio donde el sistema lo busca.
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# --- 4. Activación del Servidor AD DC -------------------------------------
# smbd, nmbd y winbind son los servicios del Samba "clásico" y ocupan los
# puertos que necesita el controlador de dominio. Se apagan y se levanta
# samba-ad-dc, que los sustituye a los tres.
sudo systemctl disable --now smbd nmbd winbind
sudo systemctl unmask samba-ad-dc
sudo systemctl enable --now samba-ad-dc

echo "--- Despliegue de $DOMAIN_NAME finalizado. ---"
