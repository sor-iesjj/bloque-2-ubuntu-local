# 🚨 Guía de Errores y Resolución — Proyecto BoochanV1 (VirtualBox)

> [!info] Cómo usar esta guía
> Este documento recoge todos los errores conocidos organizados por fase. Cada error tiene un código único (`Fase.Número`). Si algo no funciona, localiza la fase en la que estás, busca el error que más se parece a lo que ves en pantalla y sigue el procedimiento paso a paso.
>
> A diferencia de BoochanV2/V3 (donde el rescate de un servidor bloqueado pasaba por la consola web de Azure/AWS), en BoochanV1 **siempre tienes la ventana de la VM de VirtualBox como último recurso**: aunque se rompa la red o el SSH, puedes iniciar sesión directamente desde esa ventana con el usuario y contraseña locales. Es la gran ventaja de trabajar en local.

---

## 🧯 Sección 0 — Problemas Transversales de VirtualBox (léela primero si algo no arranca)

Estos tres problemas pueden aparecer en cualquier fase porque son de la capa de virtualización, no de una fase concreta. Consúltalos primero si la VM ni siquiera enciende bien.

### Error 0.1 — La virtualización por hardware (VT-x/AMD-V) está desactivada en la BIOS

> [!bug] Cuándo se produce
> Al intentar arrancar por primera vez cualquier VM (servidor o cliente Windows 11). VirtualBox muestra un error de tipo "VT-x is not available" o la VM se queda en pantalla negra sin arrancar el instalador, especialmente notable con VMs de 64 bits o con TPM/Secure Boot activados (Windows 11, Fase 8).

> [!caution] ¿Hay que preocuparse?
> **Sí.** Sin virtualización por hardware activada, VirtualBox no puede ejecutar VMs de 64 bits con normalidad (o directamente no arrancan).

> [!example] Resolución
> 1. Reinicia el ordenador físico y entra en la **BIOS/UEFI** (normalmente `Supr`, `F2` o `F10` al arrancar, según fabricante).
> 2. Busca una opción llamada **Intel VT-x**, **AMD-V**, **SVM Mode** o genéricamente "Virtualization Technology" y actívala.
> 3. Guarda los cambios y reinicia.
> 4. Si el equipo es del aula y **no tienes acceso a la BIOS** (bloqueada por gestión centralizada del centro), esto **no lo puedes resolver tú**: avisa al profesor. La solución pasa por que el departamento de informática del centro la active de antemano en la imagen de los equipos del aula.
> 5. Comprobación alternativa en Windows: abre el **Administrador de tareas → pestaña Rendimiento → CPU** — debe indicar "Virtualización: Habilitada".

---

### Error 0.2 — La Red Solo Anfitrión (Host-Only) no conecta servidor, cliente y host entre sí

> [!bug] Cuándo se produce
> Cualquier `ping` entre servidor (`10.10.10.10`), cliente Windows (`10.10.10.20`) y host (`10.10.10.1`) falla, en cualquier fase a partir de la 1.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Sin esta red, ninguna fase posterior funciona: ni SSH, ni el dominio, ni WireGuard, ni la unión de Windows.

> [!example] Resolución — Comprueba en este orden
> [!danger] 🧭 REGLA DE ORO: identifica la red por su IP, nunca por su nombre
> El nombre de la red sólo-anfitrión **cambia según el sistema operativo de tu ordenador**:
> - **Mac y Linux:** `vboxnet0`, `vboxnet1`…
> - **Windows:** `VirtualBox Host-Only Ethernet Adapter`, y si ya existía una, `#2`, `#3`…
>
> Además, si el equipo ya tenía VirtualBox, **es muy probable que haya más de una red sólo-anfitrión** (la de fábrica en `192.168.56.1` y la del laboratorio en `10.10.10.1`). Se parecen tanto que conectar una VM a la equivocada es facilísimo, y el fallo no se nota hasta que un ping no responde con todo aparentemente bien configurado.
>
> **La nuestra es siempre la que tiene el adaptador en `10.10.10.1` con máscara `255.255.255.0`.** Compruébalo en `ipconfig` (Windows) o `ifconfig` (Mac/Linux) antes de dar nada por bueno.
>
> ⚠️ **Ojo también a la máscara:** VirtualBox crea la red con `255.255.0.0` por defecto. Hay que cambiarla a `255.255.255.0` a mano, y verificar después que se guardó.

> **1. ¿Existe la red del laboratorio (`10.10.10.0/24`) y tiene la IP correcta?**
> `Herramientas → Redes → Redes solo-anfitrión` en el VirtualBox Manager. Debe existir la red del laboratorio, con IP `10.10.10.1/24` y el DHCP **desactivado** (ver Fase 1, Paso 4). Si no existe, créala con el botón `+`.
>
> **2. ¿Todas las VMs implicadas apuntan a la misma red host-only?**
> En cada VM: `Configuración → Red → Adaptador [el de Solo Anfitrión] → Nombre`. Debe apuntar a la red que tiene la IP `10.10.10.1` en **todas** — servidor y cliente Windows. Es muy fácil acabar con dos redes host-only y que cada máquina esté en una; **compruébalo por su IP, no por su nombre.**
>
> **3. ¿La IP dentro de la VM es la correcta?**
> Dentro del servidor: `hostname -I` o `ip a` debe mostrar `10.10.10.10` en la interfaz correspondiente. Dentro de Windows: `ipconfig` debe mostrar `10.10.10.20` en el adaptador de Red Solo Anfitrión.
>
> **4. ¿El firewall del propio ordenador (host) bloquea el ICMP?**
> Si el `ping` desde el servidor/cliente hacia el host (`10.10.10.1`) falla pero el resto de tráfico funciona, el firewall de Windows o macOS del equipo físico puede estar bloqueando el ping entrante en redes clasificadas como "públicas". Revisa la configuración de firewall del sistema operativo anfitrión.

---

### Error 0.3 — RAM insuficiente / el portátil se congela con la VM encendida

> [!bug] Cuándo se produce
> El equipo del aula se ralentiza mucho o se congela al encender una o varias VMs, especialmente a partir de la Fase 4 (Samba AD DC) o la Fase 8 (con dos VMs encendidas a la vez: servidor + cliente Windows 11).

> [!warning] ¿Hay que preocuparse?
> Depende. No es un error de configuración sino de recursos físicos limitados — muy habitual en portátiles de aula de 8 GB compartidos entre varios alumnos y turnos.

> [!example] Resolución
> 1. Cierra aplicaciones innecesarias del **host** (navegador con muchas pestañas, editores, etc.) antes de encender la VM.
> 2. Comprueba cuánta RAM tiene asignada la VM: `Configuración → Sistema → Placa base` (VM apagada). No subas de golpe a 4096 MB si no lo necesitas todavía — sigue la recomendación de cada fase (2048 MB en Fases 1-3, 3072-4096 MB a partir de la Fase 4).
> 3. Si necesitas trabajar con las dos VMs a la vez (Fase 8) y el equipo no da más de sí, considera apagar por completo (no solo pausar) la VM que no estés usando en ese momento: `Cerrar → Enviar señal de apagado`.
> 4. Como referencia: un portátil de 8 GB totales, con el sistema operativo anfitrión ya consumiendo 2-3 GB, deja un margen ajustado pero viable para una VM de 4 GB. Dos VMs de 4 GB simultáneas en un equipo de 8 GB es, casi siempre, demasiado — súbelo con tu profesor si es tu caso.

---

## Fase 1 — Infraestructura Virtual Local (VirtualBox)

---

### Error 1.1 — El instalador no arranca / pantalla negra o error de arranque

> [!bug] Cuándo se produce
> Al encender la VM `UbuntuServer` por primera vez tras crearla.

> [!warning] ¿Hay que preocuparse?
> Depende de la causa: puede ser tan simple como una ISO mal montada, o tan de fondo como la virtualización desactivada en la BIOS (ver Error 0.1).

> [!example] Resolución
> 1. Revisa que en `Configuración → Almacenamiento` la ISO de Ubuntu Server esté montada en la unidad óptica virtual (icono de CD bajo el controlador).
> 2. Si la ISO está bien montada y sigue sin arrancar, revisa el **Error 0.1** (virtualización BIOS).

---

### Error 1.2 — No hay ping a `10.10.10.10` desde el ordenador (host)

> [!bug] Cuándo se produce
> Al ejecutar el Paso 7 de verificación de la Fase 1, tras instalar Ubuntu Server.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Sin esta conexión no podrás usar SSH en las fases siguientes.

> [!example] Resolución
> Consulta el procedimiento completo en el **Error 0.2** de esta guía (Problemas Transversales de VirtualBox).

---

### Error 1.3 — La VM no tiene Internet (`ping google.com` falla) pero sí tiene `10.10.10.10`

> [!bug] Cuándo se produce
> Al verificar la conectividad en el Paso 7 de la Fase 1: la Red Solo Anfitrión funciona (responde a `10.10.10.10`) pero no hay salida a internet.

> [!info] ¿Hay que preocuparse?
> No es grave — el problema está aislado al **Adaptador 1 (NAT)**, no afecta a la Red Solo Anfitrión que ya verificaste.

> [!example] Resolución
> 1. Con la VM apagada o encendida, revisa en `Configuración → Red → Adaptador 1` que está habilitado y en modo `NAT`.
> 2. Si estaba mal configurado, corrígelo y reinicia la interfaz de red dentro de la VM:
>    ```bash
>    sudo netplan apply
>    ```
> 3. Si sigue sin funcionar, comprueba también que el propio ordenador anfitrión tiene salida a internet — sin conexión en el host, el NAT tampoco puede tenerla.

---

### Error 1.4 — El instalador solo deja configurar una tarjeta de red

> [!bug] Cuándo se produce
> Durante el Paso 5 (instalación de Ubuntu Server), el asistente Subiquity solo detecta una interfaz de red en lugar de dos.

> [!warning] ¿Hay que preocuparse?
> Sí, hay que corregirlo antes de continuar la instalación — sin el segundo adaptador no podrás fijar la IP `10.10.10.10`.

> [!example] Resolución
> 1. Apaga la VM (fuerza el apagado desde `Máquina → Cerrar → Apagar la máquina` si el instalador no responde).
> 2. Revisa el Paso 4 de la Fase 1: el **Adaptador 2** debe estar habilitado y en modo `Red Solo Anfitrión` **antes** de encender la VM. VirtualBox no añade tarjetas de red "en caliente" al instalador ya arrancado.
> 3. Vuelve a arrancar el instalador desde cero (o usa la opción "Reconfigurar red" si el instalador la ofrece).

---

## Fase 2 — Purga y Preparación del Entorno

---

### Error 2.1 — `apt purge` no encuentra Samba

> [!bug] Cuándo se produce
> Al ejecutar el Paso 1 de limpieza, si Samba no venía preinstalado en esa ISO concreta de Ubuntu Server o ya se había purgado en un intento anterior.

> [!info] ¿Hay que preocuparse?
> No. Verifica que efectivamente no queda nada instalado:
> ```bash
> dpkg -l | grep samba
> ```
> Si la salida está vacía, todo correcto — continúa con el Paso 2.

---

### Error 2.2 — El nombre del servidor es incorrecto (`hostname -f` no devuelve el FQDN esperado)

> [!bug] Cuándo se produce
> Tras el Paso 3, al verificar la identidad del servidor.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Si el FQDN no es exactamente `UbuntuServer.BOOCHANLAB.LOCAL`, Kerberos rechazará tickets en la Fase 4.

> [!example] Resolución
> 1. Revisa el contenido exacto de ambos archivos:
>    ```bash
>    cat /etc/hostname
>    cat /etc/hosts
>    ```
> 2. `/etc/hostname` debe contener únicamente `UbuntuServer` (sin dominio, sin espacios extra).
> 3. `/etc/hosts` debe tener la línea exacta:
>    ```
>    10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer
>    ```
> 4. Corrige lo que falte con `sudo nano` y vuelve a comprobar con `hostname -f`.

---

### Error 2.3 — La pantalla azul de configuración de Kerberos no aparece

> [!bug] Cuándo se produce
> Durante la instalación de dependencias del Paso 2, si Kerberos ya estaba configurado de un intento anterior.

> [!info] ¿Hay que preocuparse?
> No. Puedes reconfigurarlo manualmente en cualquier momento:
> ```bash
> sudo dpkg-reconfigure krb5-config
> ```
> Escribe `BOOCHANLAB.LOCAL` **en mayúsculas** cuando te lo pida.

---

### Error 2.4 — `apt update` no descarga nada / sin internet

> [!bug] Cuándo se produce
> Al ejecutar el Paso 2 de instalación de dependencias.

> [!warning] ¿Hay que preocuparse?
> Sí, bloquea toda la instalación de paquetes necesarios para las fases siguientes.

> [!example] Resolución
> 1. Comprueba en `Configuración de la VM → Red → Adaptador 1` que está habilitado y en modo `NAT`.
> 2. Verifica conectividad desde dentro de la VM:
>    ```bash
>    ping -c 4 8.8.8.8
>    ```
> 3. Si no hay respuesta, reinicia la VM tras corregir el adaptador.

---

### Error 2.5 — `hostname -I` no muestra `10.10.10.10`

> [!bug] Cuándo se produce
> Al comprobar la IP en el Paso 3, si la configuración estática de netplan de la Fase 1 no se aplicó correctamente o se perdió tras un reinicio.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Sin esta IP fija, el dominio de la Fase 4 no se levantará de forma estable.

> [!example] Resolución
> 1. Revisa el archivo de configuración de red:
>    ```bash
>    cat /etc/netplan/*.yaml
>    ```
> 2. Confirma que la interfaz de la Red Solo Anfitrión tiene la IP `10.10.10.10/24` fija (no DHCP).
> 3. Aplica de nuevo la configuración:
>    ```bash
>    sudo netplan apply
>    ```

---

## Fase 3 — Conectividad VPN (WireGuard)

---

### Error 3.1 — `Address already in use` al levantar el túnel

> [!bug] Cuándo se produce
> Al ejecutar `sudo wg-quick up wg0` cuando ya hay una interfaz `wg0` activa de un intento anterior.

> [!info] ¿Hay que preocuparse?
> No. Es un error sencillo y no ha causado ningún daño.

> [!example] Resolución
> ```bash
> sudo wg-quick down wg0
> sudo wg-quick up wg0
> ```

---

### Error 3.2 — No hay ping entre `10.20.20.1` y `10.20.20.2`

> [!bug] Cuándo se produce
> El túnel arranca sin errores (`sudo wg-quick up wg0` no da error) pero el `ping 10.20.20.1` desde el cliente no responde.

> [!warning] ¿Hay que preocuparse?
> Sí. El túnel está mal configurado o el cliente no está en la red correcta.

> [!example] Resolución — Comprueba en este orden
> **1. ¿El cliente está en la misma Red Solo Anfitrión que el servidor?**
> A diferencia de la nube, aquí no hay ningún puerto de firewall externo que abrir — el problema casi siempre es que el adaptador de red del cliente (tu PC físico en la Opción A de la Fase 3, o la futura VM Windows) no apunta a la misma red host-only del laboratorio (`10.10.10.0/24`) que el servidor.
>
> **2. ¿Están las claves cruzadas correctamente?**
> - La clave pública del **servidor** debe estar en el fichero de configuración del **cliente**.
> - La clave pública del **cliente** debe estar en el bloque `[Peer]` del `/etc/wireguard/wg0.conf` del **servidor**.
> Comprueba la clave pública real del servidor:
> ```bash
> sudo cat /etc/wireguard/publickey
> ```
>
> **3. ¿Está el túnel activo en el cliente?**
> En la aplicación WireGuard, el botón debe mostrar "Desactivar". Si dice "Activar", el túnel no está conectado.
>
> **4. Verifica el estado del túnel en el servidor:**
> ```bash
> sudo wg show
> ```
> Si aparece el peer con `latest handshake` reciente, el túnel funciona. Si no hay ningún handshake, las claves están mal intercambiadas.

---

### Error 3.3 — La clave pública pegada en `wg0.conf` tiene caracteres invisibles

> [!bug] Cuándo se produce
> Al copiar la clave pública desde la app WireGuard y pegarla en `nano` — especialmente si se hace desde la consola gráfica de VirtualBox en lugar de por SSH (ver nota en la [[Guía_Editor_Nano]]).

> [!caution] ¿Hay que preocuparse?
> **Sí.** WireGuard no muestra ningún error claro; simplemente no habrá conexión.

> [!example] Resolución
> 1. Verifica el contenido real de la clave:
>    ```bash
>    sudo grep PublicKey /etc/wireguard/wg0.conf
>    ```
> 2. Debe ser una sola línea limpia, sin espacios ni caracteres `<` o `>`.
> 3. Si hay algo raro, reescribe la línea desde cero en `nano`, preferiblemente conectado por SSH en vez de la consola gráfica de la VM.
> 4. Reinicia el túnel:
>    ```bash
>    sudo wg-quick down wg0
>    sudo wg-quick up wg0
>    ```

---

### Error 3.4 — El cliente no encuentra el `Endpoint`

> [!bug] Cuándo se produce
> Al intentar levantar el túnel desde el cliente, si el `Endpoint` del fichero de configuración del cliente está mal escrito.

> [!example] Resolución
> Recuerda que en BoochanV1 el `Endpoint` **no** es una IP pública de internet (como en V2/V3), sino la IP de la Red Solo Anfitrión del servidor:
> ```ini
> Endpoint = 10.10.10.10:51820
> ```
> Ejecuta `hostname -I` en el servidor y confirma que `10.10.10.10` sigue asignada.

---

## Fase 4 — Aprovisionamiento del Dominio (Samba AD DC)

---

### Error 4.1 — `git clone` falla porque la URL no fue sustituida

> [!bug] Cuándo se produce
> Al ejecutar el comando de descarga del repositorio en el Paso 1, sin sustituir `URL_DEL_REPOSITORIO` por la URL real proporcionada por el profesor.

> [!info] ¿Hay que preocuparse?
> No. El comando falla al instante sin haber hecho ningún cambio en el servidor.

> [!example] Resolución
> Pide a tu profesor la URL real del repositorio **de BoochanV1 (Local)** — no confundas con la de V2 o V3, que usan un Realm distinto (`BOOCHAN.SPACE` en vez de `BOOCHANLAB.LOCAL`).
> ```bash
> git clone https://la-url-real-de-V1 /opt/boochan
> ```

---

### Error 4.2 — El script `provision_boochan.sh` se detiene sin mostrar el mensaje de éxito

> [!bug] Cuándo se produce
> Cuando el script falla antes de completarse. Nunca aparece la línea `Despliegue de BOOCHANLAB finalizado`.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Si el script no terminó, el dominio no existe o está a medias y no funcionará en las fases siguientes.

> [!example] Resolución
> Lee el último mensaje de error visible. Los más frecuentes:
>
> **"Failed to set up Domain":** El FQDN no está bien configurado. Vuelve a la Fase 2 y verifica que `hostname -f` devuelve `UbuntuServer.BOOCHANLAB.LOCAL`.
>
> **"Port 445 already in use":** Quedó algún proceso de Samba activo. Límpialo y vuelve a ejecutar el script:
> ```bash
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
> sudo apt-get purge samba* -y
> sudo rm -rf /etc/samba/ /var/lib/samba/ /var/cache/samba/
> sudo ./provision_boochan.sh
> ```
>
> Si el error no está en esta lista, anótalo y muéstraselo a tu profesor antes de continuar.

---

### Error 4.3 — `resolv.conf` no apunta a `127.0.0.1`

> [!bug] Cuándo se produce
> Tras ejecutar el script, al verificar el DNS con `cat /etc/resolv.conf`. El fichero muestra otra cosa (por ejemplo, la IP del DNS del adaptador NAT) en lugar de `nameserver 127.0.0.1`.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Es uno de los errores más críticos del proyecto. Sin el DNS correcto, el dominio no resolverá nombres y ningún cliente podrá unirse. Recuerda: esto ocurre igual en local que en la nube — `systemd-resolved` es el mismo componente en ambos casos (ver Fundamento Teórico de la Fase 4).

> [!example] Resolución — Desactivar `systemd-resolved` y fijar el DNS
> 1. Desactiva y detén el servicio que está interfiriendo:
>    ```bash
>    sudo systemctl disable systemd-resolved --now
>    ```
> 2. Elimina el enlace simbólico que gestiona ese servicio:
>    ```bash
>    sudo rm /etc/resolv.conf
>    ```
> 3. Crea un nuevo fichero con el DNS correcto:
>    ```bash
>    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
>    ```
> 4. Bloquea el fichero para que nada pueda modificarlo:
>    ```bash
>    sudo chattr +i /etc/resolv.conf
>    ```
> 5. Reinicia Samba:
>    ```bash
>    sudo systemctl restart samba-ad-dc
>    ```

---

### Error 4.4 — El script falla en `git clone` por falta de red

> [!bug] Cuándo se produce
> Al ejecutar el Paso 1 de la Fase 4, si el adaptador NAT no está activo o `git` intenta salir por la Red Solo Anfitrión (que no tiene salida a internet por diseño).

> [!example] Resolución
> Comprueba `ping 8.8.8.8` antes de clonar; revisa el adaptador NAT en `Configuración de la VM → Red`.

---

### Error 4.5 — `nslookup: command not found`

> [!bug] Cuándo se produce
> Al ejecutar la verificación del Punto de Control con `nslookup`. En Ubuntu Server mínimo esta herramienta no viene instalada.

> [!info] ¿Hay que preocuparse?
> No. Simplemente falta la herramienta para comprobarlo, no significa que el DNS esté roto.

> [!example] Resolución
> ```bash
> sudo apt install dnsutils -y
> nslookup _kerberos._tcp.BOOCHANLAB.LOCAL 127.0.0.1
> ```

---

## Fase 5 — Gestión de Identidades

---

### Error 5.1 — `id user1` no devuelve nada o dice "no such user"

> [!bug] Cuándo se produce
> Al verificar el Punto de Control, cuando el resultado esperado (`uid=10001`, `gid=3001`) no aparece.

> [!warning] ¿Hay que preocuparse?
> Depende de la causa. El usuario puede existir perfectamente en el dominio pero el sistema no lo "ve" porque el traductor no está activo.

> [!example] Resolución — Comprueba en este orden
> **1. ¿Está winbind corriendo?**
> ```bash
> sudo systemctl status winbind
> ```
> Si no dice `active (running)`, arráncalo:
> ```bash
> sudo systemctl enable winbind --now
> ```
>
> **2. ¿Está winbind en el fichero de búsqueda de usuarios?**
> ```bash
> grep "passwd" /etc/nsswitch.conf
> ```
> La línea debe incluir `winbind` al final:
> ```
> passwd:         files systemd winbind
> group:          files systemd winbind
> ```
>
> **3. ¿El usuario existe en el dominio?**
> ```bash
> sudo samba-tool user list
> ```

---

### Error 5.2 — "Password too weak"

> [!bug] Cuándo se produce
> Al crear un usuario con `samba-tool user create` con una contraseña que no cumple la política de complejidad de Active Directory.

> [!info] ¿Hay que preocuparse?
> No. Usa una contraseña con mayúsculas, minúsculas, números y símbolos, como `P@ssw0rd`.

---

### Error 5.3 — "Group already exists" o "User already exists"

> [!bug] Cuándo se produce
> Al intentar crear un grupo o usuario que ya fue creado en un intento anterior de esta fase.

> [!info] ¿Hay que preocuparse?
> No. Solo hay que eliminar el objeto existente y volver a crearlo.

> [!example] Resolución
> ```bash
> sudo samba-tool group delete policia
> sudo samba-tool group delete bomberos
> sudo samba-tool user delete user1
> sudo samba-tool user delete user2
> ```
> Después vuelve a ejecutar los pasos de creación desde el principio.

---

### Error 5.4 — Error de esquema LDAP al ejecutar `addunixattrs`

> [!bug] Cuándo se produce
> Al ejecutar `sudo samba-tool group addunixattrs policia 3001`, el terminal devuelve un error con palabras como "no such attribute", "schema" o "LDAP".

> [!caution] ¿Hay que preocuparse?
> **Sí.** El dominio fue provisionado sin soporte para atributos Unix (RFC 2307). Hay que reprovisionar.

> [!example] Resolución
> Este proceso borra todos los datos del dominio actual. Informa a tu profesor antes de ejecutarlo:
> 1. Detén Samba:
>    ```bash
>    sudo systemctl stop samba-ad-dc
>    ```
> 2. Elimina la base de datos del dominio:
>    ```bash
>    sudo rm -rf /var/lib/samba/private/
>    sudo rm -rf /var/lib/samba/sysvol/
>    ```
> 3. Vuelve a ejecutar el script de la Fase 4. Verifica con tu profesor que el script incluye el parámetro `--use-rfc2307`.
>
> > [!tip] 💡 Ventaja del snapshot
> > Si tomaste un snapshot de VirtualBox justo después de completar la Fase 4 (ver [[Comandos_y_Atajos_VirtualBox]]), este es el momento de restaurarlo en lugar de reprovisionar a mano — te ahorras los 2-3 minutos del script y cualquier variable que se te haya podido olvidar.

---

## Fase 6 — Almacenamiento Virtual

---

### Error 6.1 — El servidor no arranca tras editar el `fstab`

> [!bug] Cuándo se produce
> Cuando se guarda `/etc/fstab` con un error de sintaxis (por ejemplo, olvidando la palabra `loop`) y se reinicia el servidor sin haber ejecutado `sudo mount -a` para verificarlo primero.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Es el error más grave de esta fase. El servidor entra en modo de emergencia y la conexión SSH deja de responder.

> [!example] Resolución — Acceso de rescate (VirtualBox, sin SSH)
> A diferencia de la nube (donde hacía falta SSM o la Consola Serie), en BoochanV1 el rescate es directo:
> 1. Abre la **ventana de la VM en VirtualBox** (doble clic sobre `UbuntuServer` en el VirtualBox Manager, o `Mostrar` si ya está en marcha).
> 2. Verás la consola en modo emergencia o el prompt de login local. Inicia sesión con el usuario `boochan` y su contraseña.
> 3. Corrige el archivo:
>    ```bash
>    sudo nano /etc/fstab
>    ```
>    Las líneas de los discos virtuales deben tener exactamente este formato:
>    ```
>    /samba_p1.img  /srv/samba/prueba1  ext4  loop,defaults  0  0
>    /samba_p3.img  /srv/samba/prueba3  ext4  loop,defaults  0  0
>    ```
> 4. Antes de reiniciar, verifica que la sintaxis es correcta:
>    ```bash
>    sudo mount -a
>    ```
>    Si el terminal no devuelve ningún texto, la sintaxis es perfecta.
> 5. Reinicia:
>    ```bash
>    sudo reboot
>    ```

---

### Error 6.2 — La conexión SSH se corta al ejecutar `sudo reboot`

> [!bug] Cuándo se produce
> Al reiniciar el servidor para verificar que los discos se montan solos. El terminal muestra `Connection reset by peer` o `Broken pipe`.

> [!info] ¿Hay que preocuparse?
> No. Es completamente normal, el servidor se está reiniciando.

> [!example] Resolución
> 1. Cierra el terminal. No hay nada que recuperar.
> 2. Espera 1-2 minutos (en VirtualBox local suele ser más rápido que en la nube).
> 3. Vuelve a conectarte o abre la ventana de la VM y espera al prompt de login.
> 4. Ejecuta `df -h` para confirmar que los discos de 5 GB aparecen montados.

---

### Error 6.3 — `df -h` no muestra los discos de 5 GB

> [!bug] Cuándo se produce
> Después de editar el `fstab`, si no se ha ejecutado el comando de montaje manual.

> [!example] Resolución
> ```bash
> sudo mount -a
> ```

---

### Error 6.4 — Error "wrong fs type" al montar

> [!bug] Cuándo se produce
> El archivo `.img` no se formateó correctamente antes de intentar montarlo.

> [!example] Resolución
> ```bash
> sudo mkfs.ext4 /samba_p1.img
> sudo mount -a
> ```

---

### Error 6.5 — El comando `dd` falla con "No space left on device"

> [!bug] Cuándo se produce
> Al crear los archivos de disco virtual con `dd`, si el disco VDI de la VM no tiene espacio suficiente para dos archivos de 5 GB.

> [!warning] ¿Hay que preocuparse?
> Sí. No se pueden crear los discos virtuales y la Fase 6 no puede completarse.

> [!example] Resolución
> 1. Comprueba el espacio disponible:
>    ```bash
>    df -h /
>    ```
> 2. Si hay archivos `.img` de un intento anterior, elimínalos:
>    ```bash
>    sudo rm -f /samba_p1.img /samba_p3.img
>    ```
> 3. Si aún no hay espacio suficiente (necesitas al menos 11 GB libres), tienes dos opciones en local:
>    - **Ampliar el disco virtual VDI** desde VirtualBox: apaga la VM → `Configuración → Almacenamiento` → selecciona el disco → `Propiedades del atributo` → aumenta el tamaño (solo funciona con discos de asignación dinámica que aún no llegaron a su máximo, y requiere después ampliar la partición dentro de Ubuntu con `growpart`/`resize2fs`).
>    - **Reducir el tamaño de los discos de prueba**: cambia `count=5120` por `count=2048` en los comandos `dd` (generará discos de 2 GB en lugar de 5 GB) — más sencillo para un aula con recursos limitados.

---

### Error 6.6 — `chown root:policia` falla con "invalid group"

> [!bug] Cuándo se produce
> Al ejecutar `sudo chown root:policia /srv/samba/prueba3` con el servicio `winbind` inactivo.

> [!warning] ¿Hay que preocuparse?
> Sí. La carpeta quedará con grupo `root` y los permisos de la Fase 7 no funcionarán correctamente.

> [!example] Resolución
> 1. Arranca winbind:
>    ```bash
>    sudo systemctl enable winbind --now
>    ```
> 2. Verifica que el grupo es reconocible:
>    ```bash
>    getent group policia
>    ```
> 3. Repite el comando:
>    ```bash
>    sudo chown root:policia /srv/samba/prueba3
>    ```

---

## Fase 7 — Seguridad Avanzada (ACLs y ABE)

---

### Error 7.1 — Las ACLs no funcionan (Access Denied a pesar de haberlas aplicado)

> [!bug] Cuándo se produce
> Tras aplicar `setfacl`, el usuario sigue sin poder acceder a la carpeta.

> [!example] Resolución
> Verifica que el sistema de archivos soporta ACLs (en ext4 viene activado por defecto, pero conviene comprobarlo):
> ```bash
> getfacl /srv/samba/prueba3
> ```
> Si el comando falla directamente, revisa que el disco esté montado sin opciones que deshabiliten explícitamente `acl` en el `/etc/fstab`.

---

### Error 7.2 — El usuario ve la carpeta pero no puede entrar

> [!bug] Cuándo se produce
> Después de modificar `smb.conf` o las ACLs, sin haber reiniciado el servicio.

> [!example] Resolución
> ```bash
> sudo systemctl restart samba-ad-dc
> ```

---

### Error 7.3 — `samba-ad-dc` no arranca tras editar `smb.conf`

> [!bug] Cuándo se produce
> Después de añadir los bloques `[prueba1]` y `[prueba3]`, al ejecutar `sudo systemctl restart samba-ad-dc` el servicio queda en estado `failed`.

> [!warning] ¿Hay que preocuparse?
> No es grave. Hay un error de sintaxis en el fichero que Samba identifica con precisión.

> [!example] Resolución
> 1. Pide a Samba que analice el fichero y señale el error:
>    ```bash
>    sudo testparm
>    ```
> 2. Corrige la línea indicada en `/etc/samba/smb.conf` (los errores más frecuentes son espacios inconsistentes, olvidar el `=`, o escribir `Yes` con mayúscula cuando Samba espera `yes`).
> 3. Verifica y reinicia:
>    ```bash
>    sudo testparm
>    sudo systemctl restart samba-ad-dc
>    ```

---

### Error 7.4 — Secciones `[prueba1]` o `[prueba3]` duplicadas en `smb.conf`

> [!bug] Cuándo se produce
> Si el script de la Fase 4 ya había añadido esas secciones y se añaden de nuevo sin comprobarlo primero.

> [!example] Resolución
> ```bash
> sudo grep -n "\[prueba" /etc/samba/smb.conf
> ```
> Si aparece duplicado, edita el fichero y elimina el bloque repetido (conserva el que tenga todos los parámetros completos). Verifica y reinicia con `sudo testparm` y `sudo systemctl restart samba-ad-dc`.

---

## Fase 8 — Integración del Cliente Windows 11

---

### Error 8.1 — "No se encuentra el dominio" al unirse

> [!bug] Cuándo se produce
> Al intentar unir la VM cliente al dominio en el Paso 3.

> [!caution] ¿Hay que preocuparse?
> **Sí.**

> [!example] Resolución
> Revisa el Paso 0.1 de la Fase 8: el **Adaptador 1** de la VM cliente debe estar en modo `Red Solo Anfitrión` con la red del laboratorio (`10.10.10.0/24`) seleccionada, exactamente igual que en el servidor. Consulta también el Error 0.2 de esta guía.

---

### Error 8.2 — "No se encuentra el dominio" aunque la red parece bien

> [!bug] Cuándo se produce
> El adaptador de red está correcto pero el DNS del cliente apunta al adaptador NAT en lugar de al servidor.

> [!example] Resolución
> Comprueba que el DNS preferido del adaptador de Red Solo Anfitrión es `10.10.10.10` (Paso 1 de la Fase 8). Verifica con:
> ```cmd
> nslookup BOOCHANLAB.LOCAL
> ```
> Debe devolver `10.10.10.10`.

---

### Error 8.3 — "Error de relación de confianza" al autenticarse

> [!bug] Cuándo se produce
> Desfase horario (Clock Skew) superior a 5 minutos entre cliente y servidor — muy típico en VirtualBox tras reanudar una VM que estuvo pausada o "guardada" varios días.

> [!warning] ¿Hay que preocuparse?
> Sí. Ningún usuario podrá autenticarse hasta que los relojes estén sincronizados.

> [!example] Resolución
> 1. Abre el **Símbolo del sistema como Administrador**.
> 2. Fuerza la sincronización:
>    ```cmd
>    w32tm /resync /force
>    ```
> 3. Si persiste, comprueba la hora del servidor Linux:
>    ```bash
>    timedatectl
>    ```

---

### Error 8.4 — La unidad de red `Z:` desaparece al reiniciar Windows

> [!bug] Cuándo se produce
> El mapeo de la unidad no se marcó como persistente.

> [!info] ¿Hay que preocuparse?
> No.

> [!example] Resolución
> ```cmd
> net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\prueba1 /user:BOOCHANLAB\user1 /persistent:yes
> ```

---

### Error 8.5 — RSAT no se descarga / se queda "buscando actualizaciones"

> [!bug] Cuándo se produce
> El adaptador NAT de la VM cliente no está activo o no tiene salida a internet.

> [!example] Resolución
> Comprueba que el **Adaptador 2 (NAT)** está conectado en `Configuración → Red` de la VM cliente y que el host tiene internet.

---

### Error 8.6 — Las dos VMs no se ven entre sí aunque ambas tienen "Red Solo Anfitrión"

> [!bug] Cuándo se produce
> El cliente está conectado a una red host-only distinta en lugar de la del laboratorio.

> [!example] Resolución
> Corrígelo en `VirtualBox → Configuración → Red → Adaptador 1 → Nombre`: selecciona la red que tiene la IP `10.10.10.1`, la misma que usa el servidor. Ver también Error 0.2.

---

## Auditoría Final — Hardening

---

### Error F.1 — Te quedas fuera del servidor al ejecutar `sudo ufw enable`

> [!bug] Cuándo se produce
> Si estás conectado por SSH desde una IP que no está dentro de `10.10.10.0/24` ni `10.20.20.0/24` (por ejemplo, si te conectaste directamente desde el host sin pasar por la Red Solo Anfitrión ni por el túnel) y activas `ufw` con la política `deny incoming`.

> [!caution] ¿Hay que preocuparse?
> **Sí**, aunque en BoochanV1 el rescate siempre está disponible: puedes recuperar el acceso abriendo la **ventana de la VM en VirtualBox** e iniciando sesión localmente, sin depender de ningún mecanismo externo.

> [!example] Resolución
> 1. Abre la ventana de la VM `UbuntuServer` en VirtualBox e inicia sesión con el usuario `boochan`.
> 2. Revisa las reglas activas:
>    ```bash
>    sudo ufw status verbose
>    ```
> 3. Añade o corrige la regla que falte, por ejemplo si necesitas permitir tu rango:
>    ```bash
>    sudo ufw allow from 10.10.10.0/24
>    ```
> 4. Antes de volver a intentar `ufw enable`, verifica siempre desde qué IP estás conectado con `who` o `w` en el propio servidor.

---

### Error F.2 — Reenvío de puertos (Port Forwarding) olvidado en el adaptador NAT

> [!bug] Cuándo se produce
> Si en algún momento del proyecto configuraste una regla de Port Forwarding en el Adaptador NAT del servidor (por ejemplo, `127.0.0.1:2222 → 10.10.10.10:22`) para administrar el servidor cómodamente desde el host, y la olvidas revisar en el cierre de seguridad.

> [!warning] ¿Hay que preocuparse?
> Sí, es la única "puerta trasera" real que puede haber quedado abierta en un laboratorio local — el equivalente a una regla mal cerrada en el Security Group de la nube.

> [!example] Resolución
> Revisa en `VirtualBox → tu VM de servidor → Configuración → Red → Adaptador 1 (NAT) → Avanzadas → Reenvío de puertos` qué reglas existen. Elimina cualquiera que ya no necesites, y documenta las que mantengas.

---

*Proyecto BoochanV1 — Curso 2025/2026*
