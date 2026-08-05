# 📚 Diccionario de Comandos del Sistema

Esta enciclopedia de bolsillo te servirá para entender "qué estás escribiendo" a lo largo de todas las fases del proyecto BoochanV1. Un administrador copia y pega; **un ingeniero entiende la sintaxis**.

> [!info] Sobre este documento
> Los comandos de Linux y Samba son exactamente los mismos que en BoochanV2 (Azure) y BoochanV3 (AWS) — `samba-tool`, `ufw`, `setfacl`, `wg`, etc. no cambian según dónde viva el servidor. Lo único adaptado aquí son los nombres de dominio y las IPs de ejemplo, que en BoochanV1 son `BOOCHANLAB.LOCAL` y `10.10.10.10` (en vez de `BOOCHAN.SPACE` y una IP pública/privada de nube). Para los comandos propios de la capa de virtualización local (crear VMs, redes host-only, snapshots), consulta [[Comandos_y_Atajos_VirtualBox]].

---

## ⚙️ 1. Gestión de Servicios (Systemd)

Systemd es el gestor central de Linux. Es el que arranca programas en segundo plano y vigila que sigan vivos.

### `systemctl` (System Control)
> **Descripción:** Te permite iniciar, detener, reiniciar y revisar la "salud" de los servicios invisibles de tu servidor.
> **Sintaxis:** `sudo systemctl [accion] [servicio]`

> [!example] Ejemplos de uso (Fase 2, Fase 4, Fase 7):
> - `sudo systemctl stop smbd nmbd`: Detiene de golpe los servicios antiguos de Samba.
> - `sudo systemctl restart samba-ad-dc`: Tras tocar la configuración de la Fase 7, este comando fuerza al "demonio" a leer de nuevo los permisos.
> - `sudo systemctl status samba-ad-dc`: Te muestra en color verde (si todo va bien) que Samba está corriendo.
> - `sudo systemctl enable wg-quick@wg0`: Obliga a Linux a arrancar la VPN de WireGuard siempre que el servidor se reinicie.

### `hostname`
> **Descripción:** Permite ver o cambiar la identidad (el nombre) de tu máquina.
> **Sintaxis:** `hostname [-modificador]`

> [!example] Ejemplos de uso:
> - `hostname -f`: Muestra el FQDN "Fully Qualified Domain Name" (el nombre largo completo, ej: `UbuntuServer.BOOCHANLAB.LOCAL`).
> - `hostname -I`: Muestra las Direcciones IP que tiene el servidor. En BoochanV1 verás **dos**: la de la Red Solo Anfitrión (`10.10.10.10`, fija) y la del adaptador NAT (dinámica, tipo `10.0.2.15`).

---

## 📦 2. Gestión de Paquetes y Software

### `apt` y `apt-get` (Advanced Package Tool)
> **Descripción:** Es la "App Store" de la terminal. Permite instalar, desinstalar y actualizar programas directamente desde los servidores oficiales de Ubuntu.
> **Sintaxis:** `sudo apt/apt-get [acción] [paquetes]`

> [!example] Ejemplos de uso (Fase 2 y 4):
> - `sudo apt update`: No instala nada. Sólo contacta con los servidores de Ubuntu para preguntar si hay nuevas actualizaciones. **Requiere que el adaptador NAT de la VM esté activo** — la Red Solo Anfitrión no da salida a internet.
> - `sudo apt install samba winbind -y`: Descarga e instala esos dos programas de red. El `-y` responde "Sí" automáticamente a todo.
> - `sudo apt-get purge samba*`: Elimina y desintegra radicalmente un paquete y todos los archivos residuales de configuración.
> - `sudo apt-get autoremove`: Borra paquetes de la basura que se instalaron como "ayudantes" pero que ya no sirven.

---

## 📁 3. Archivos, Permisos y Almacenamiento

### `mkdir` (Make Directory)
> **Descripción:** Crea carpetas nuevas en el sistema.
> **Sintaxis:** `mkdir [-modificadores] [rutas]`

> [!example] Ejemplos de uso (Fase 6):
> - `sudo mkdir -p /srv/samba/departamentos/comercial`: Crea la carpeta `comercial`. El modificador `-p` (parents) asegura que si `/srv/samba` no existe, también se creará automáticamente sin dar error.

### `cp` (Copy)
> **Descripción:** Sirve para copiar archivos o directorios de un lugar a otro.
> **Sintaxis:** `cp [origen] [destino]`

> [!example] Ejemplos de uso (Fase 4):
> - `sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf`: Copia el archivo generado por Samba a la carpeta general del sistema `/etc/` para que las herramientas de red lo encuentren.

### `rm` (Remove)
> **Descripción:** Comando letal para borrar archivos. No hay papelera de reciclaje en el terminal; lo que borras, se evapora para siempre.
> **Sintaxis:** `rm [-modificadores] [archivo/carpeta]`

> [!example] Ejemplos de ejecución (Fase 2):
> - `sudo rm -rf /etc/samba/`: El modificador `-r` borra carpetas e hijos (recursivo). El `-f` significa "force" (no me preguntes si estoy seguro, hazlo). Peligro máximo.

### `chown` (Change Owner) y `chmod` (Change Mode)
> **Descripción:** Son los comandos básicos de seguridad en Linux. `chown` cambia el propietario de un archivo o carpeta. `chmod` cambia sus permisos básicos (lectura, escritura, ejecución).

> [!example] Ejemplos de uso (Fases 4 y 6):
> - `sudo chmod +x provision_boochan.sh`: Añade el permiso de eXecución al script (Fase 4).
> - `sudo chown root:facturacion /srv/samba/departamentos/facturacion`: Cambia el dueño a `root` y el grupo propietario a `facturacion` (Fase 6).
> - `sudo chmod 2770 /srv/samba/departamentos/facturacion`: Da permisos totales (77) al propietario y al grupo, nada al resto (0), y aplica el bit setgid (2) para que los archivos hereden el grupo (Fase 6).

### `chattr` (Change Attribute)
> **Descripción:** Modifica atributos especiales a bajo nivel en sistemas de archivos Linux.
> **Sintaxis:** `chattr [+|-atributo] [archivo]`

> [!example] Ejemplo teórico y práctico (Fase 4):
> - `sudo chattr +i /etc/resolv.conf`: Hace el archivo inmutable (`+i`), ni siquiera el administrador puede borrarlo. Para poder editarlo de nuevo se usa `sudo chattr -i`. En BoochanV1 esto es igual de necesario que en la nube: aunque no haya un proveedor cloud inyectando DNS, `systemd-resolved` puede reescribir el archivo igualmente en cada arranque de la VM.

### Comando `dd` (Data Duplicator)
> **Descripción:** Trabaja a un nivel muy bajo (ceros y unos). En nuestro proyecto lo usamos para "inflar" un archivo hasta que tiene el tamaño de un disco duro (Loop Device).
> **Sintaxis:** `sudo dd if=[origen] of=[destino] bs=[bloque] count=[cantidad]`

> [!example] Ejemplo de uso (Fase 6):
> - `sudo dd if=/dev/zero of=/samba_p1.img bs=1M count=5120`: Coge datos de una "fábrica infinita de ceros" y los suelta dentro de `samba_p1.img` en trozos de 1 Megabyte, repitiéndolo 5120 veces (5 Gigabytes exactos). Recuerda que este archivo se guarda dentro del **disco virtual VDI** de la VM en VirtualBox — comprueba antes con `df -h /` que el disco de la VM tiene espacio libre suficiente.

### `mkfs.ext4` y `mount`
> **Descripción:** Antes de meter archivos en un disco duro (o disco virtual .img), hay que crear un "Índice". Eso es formatear (`mkfs`). Después, hay que pinchar el disco en el sistema (`mount`).

> [!example] Ejemplos de uso (Fase 6):
> - `sudo mkfs.ext4 /samba_p1.img`: Dale formato `ext4` (el estándar de Linux) al archivo virtual, preparándolo para recibir datos.
> - `sudo mount -a`: Lee el archivo de auto-arranque `/etc/fstab` y monta cualquier disco que esté ahí programado.

### Listas de Control `setfacl` y `getfacl`
> **Descripción:** Los cerrojos avanzados de Linux. La ACL permite dar permisos quirúrgicos sobre un archivo (ej: Pedro escribe, Ana lee).
> **Sintaxis:** `setfacl -m [usuario/grupo]:[nombre]:[permisos] [ruta]`

> [!example] Ejemplos de uso (Fase 7):
> - `sudo setfacl -m g:facturacion:rwx /srv/samba/departamentos/facturacion`: Da permiso para Leer (r), Escribir (w) y Ejecutar (x) específicamente al Grupo (g) `facturacion` en esa carpeta.
> - `sudo setfacl -d -m g:facturacion:rwx /srv/samba/departamentos/facturacion`: La `-d` (Default) añade "Herencia" y exige que todos los archivos nuevos hereden esto automáticamente.

---

## 🛡️ 4. Active Directory y Samba (samba-tool)

### `samba-tool`
> **Descripción:** Es la varita mágica del administrador. Si el Dominio de Active Directory fuera un edificio de control de acceso, `samba-tool` es el panel principal de botones.
> **Sintaxis:** `samba-tool [categoría] [acción] [parámetros]`

> [!example] Ejemplos de uso de Provisiones y Usuarios (Fase 4 y 5):
> - `sudo samba-tool domain provision --use-rfc2307 --realm=BOOCHANLAB.LOCAL --domain=BOOCHANLAB --interactive`: Este comando inicia un "wizard" (asistente interactivo) para convertir un pequeño servidor Linux en el Controlador Maestro del dominio `BOOCHANLAB.LOCAL`. En BoochanV1 se ejecuta automáticamente a través del script `provision_boochan.sh`.
> - `sudo samba-tool group add facturacion`: Da de alta el grupo "facturacion" en el dominio.
> - `sudo samba-tool group addunixattrs facturacion 3001`: Inyecta la traducción (RFC2307) para que Linux asocie el grupo "facturacion" con el número **3001**. Indispensable.
> - `sudo samba-tool user create hiroshi.nohara 'P@ssw0rd' --uid-number=10001 --gid-number=3001`: Crea un empleado y, a la vez, lo casa con el sistema numérico de seguridad interno del Kernel.
> - `sudo samba-tool domain level show`: Te indica si estás emulando la estructura base de un Windows Server 2008 o 2012.
> - `sudo samba-tool user list`: Lista todos los usuarios del dominio, incluidos los que Samba crea automáticamente al provisionar (`Administrator`, `krbtgt`, `Guest`).

---

## 🔐 5. Redes y VPN (WireGuard y Ping)

### `wg` y `wg-quick`
> **Descripción:** Las herramientas de la VPN invisible. WireGuard funciona dentro del núcleo del sistema, por lo que se interactúa con él a bajo nivel.
> **Sintaxis:** `wg [comando] [interfaz]`

> [!example] Ejemplos de uso (Fase 3):
> - `wg genkey | tee privatekey | wg pubkey > publickey`: Combina las tuberías de Linux (`|`) para generar la llave privada e, instantáneamente, calcular la pública a partir de ella.
> - `sudo wg show`: Es tu panel de radar. Te muestra el tráfico y te dice cuándo fue el "Último Apretón de Manos" con tus clientes conectados. Si no hay conexión reciente, el túnel está roto.
> - `sudo wg-quick up wg0`: Es el botón de encendido que aplica toda tu configuración de texto a las tarjetas de red de Linux.

### `ssh` (Secure Shell) y `ping`
> **Descripción:** Herramientas fundamentales de administración y diagnóstico de red. `ssh` permite tomar el control remoto de un servidor de forma encriptada. `ping` lanza pequeños paquetes de datos ("ecos") para comprobar si una IP responde.

> [!example] Ejemplos de uso (Fases 1, 2 y 3):
> - `ssh boochan@10.10.10.10`: Inicia sesión remota en el servidor como el usuario `boochan` (el usuario administrador creado en la instalación de Ubuntu Server, Fase 1), usando la IP fija de la Red Solo Anfitrión de VirtualBox. A diferencia de la nube, aquí **no hace falta ninguna clave `.pem`**: basta con usuario y contraseña, igual que en cualquier servidor Linux local.
> - `ssh -p 2222 boochan@10.20.20.1`: A partir de la Fase 3, una vez cerrado el acceso SSH directo, esta es la forma de conectar — a través del túnel WireGuard, puerto 2222.
> - `ping 10.10.10.10`: Verifica desde el propio ordenador (el host) que la Red Solo Anfitrión de VirtualBox conecta y existe respuesta desde la IP fija del servidor Linux.

---

## 🪟 6. Comandos Críticos Remotos (Windows CMD)

Aunque Linux gobierna BoochanV1, comprobamos el éxito desde la VM cliente Windows 11 en la Fase 8 usando la CMD.

### `w32tm` (Windows Time Service)
> **Descripción:** Un protocolo criptográfico como Kerberos detesta las paradojas temporales. Si pasan 5 minutos diferentes entre un reloj y otro, los tickets de autenticación se rompen. Esto es especialmente fácil que ocurra en VirtualBox cuando una VM ha estado pausada o en estado "Guardado" varios días.
> **Sintaxis:** `w32tm /[acción]`

> [!example]
> - `w32tm /resync /force`: Obliga a tu VM cliente Windows 11 a sincronizar su reloj con el reloj del servidor Samba AD DC (tu Linux disfrazado de controlador de dominio).

### `nslookup` (Name Server Lookup)
> **Descripción:** Si pudieras ser un detective probando a qué le está preguntando tu PC dónde está la web de Google, usarías esto.

> [!example]
> - `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL`: Este es el comando maestro de validación. Fuerza a tu PC Windows a preguntarle al servidor "¿Tienes levantado un servicio Kerberos?". Si devuelve texto verde y resultados (la IP `10.10.10.10`), puedes iniciar sesión.

### `whoami /all`
> **Descripción:** Le pregunta a tu usuario actual, no sólo quién es, sino a qué tribus de red (SIDs de grupos) pertenece al detalle. Imprescindible para cerciorarse de que un usuario Windows ha obtenido los permisos desde Samba.
