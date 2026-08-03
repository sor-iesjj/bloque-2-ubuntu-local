## Auditoría Final · Apartado 5 — 🛠️ Procedimiento de hardening

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Auditoría Final y Hardening**
> 🧭 Índice: [[Auditoria_Final]]
>
> **📍 Cuándo se lee:** **Con la VM delante — el trabajo**

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-auditoria-final-hardening-y-cierre-de-seguridad.md`) con su estructura, vacía.
> 2. **Léete los 4 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Revisión del adaptador NAT del servidor
> Antes de tocar el firewall, comprueba en VirtualBox → tu VM de servidor → **Configuración → Red** qué reglas de reenvío de puertos (*Port Forwarding*) tiene configuradas el Adaptador NAT (si usaste alguna en fases anteriores para conectar por SSH desde el host, por ejemplo `anfitrión:2222 → invitado:22`).
>
> > [!warning] ⚠️ El Port Forwarding es tu única "puerta al exterior"
> > **Ojo con los dos campos de la regla:** el `Puerto anfitrión` es el de tu ordenador y el `Puerto invitado` el de la VM. Y la **`IP anfitrión` debe ir VACÍA** — si pusiste `127.0.0.1`, la regla solo aceptaba conexiones del propio anfitrión y no de otros equipos de la red. Compruébalo, porque cambia mucho a quién estabas exponiendo.
> >
> > Si no configuraste ningún reenvío de puertos, el adaptador NAT del servidor es unidireccional (solo permite tráfico saliente) y no hace falta tocar nada ahí. Si sí configuraste alguno para administrar el servidor cómodamente desde el host, anótalo: es exactamente el tipo de "puerta trasera de comodidad" que hay que revisar en una auditoría final, igual que en la nube se revisaba el Security Group.

> [!example] Paso 2: Activar y configurar `ufw` en el servidor
> Conéctate al servidor (por SSH, a través del túnel WireGuard o directamente desde la consola de VirtualBox) y ejecuta:
> ```bash
> # Política por defecto: denegar todo lo entrante, permitir todo lo saliente
> sudo ufw default deny incoming
> sudo ufw default allow outgoing
>
> # El túnel WireGuard debe poder recibir el "primer contacto" desde fuera
> sudo ufw allow 51820/udp
>
> # Servicios de dominio (SMB, DNS, Kerberos, LDAP...) SOLO desde la Red Solo Anfitrión del laboratorio
# SSH NO se incluye aquí: desde la Fase 3 solo escucha en la VPN WireGuard (10.20.20.1), no en la Red Solo Anfitrión
> sudo ufw allow from 10.10.10.0/24
>
> # Y también desde el rango del túnel WireGuard (administración remota ya autenticada)
> sudo ufw allow from 10.20.20.0/24
>
> # Activa el firewall
> sudo ufw enable
> ```
>
> > [!tip] 💡 ¿Por qué permitir "todo" desde esos dos rangos en vez de puerto a puerto?
> > En BoochanV2/V3 (cloud) restringíamos puerto a puerto (SSH y SMB) porque el Security Group ya bloqueaba por defecto cualquier otro puerto no declarado explícitamente. Aquí, al activar `ufw` con política `deny incoming` por defecto, ocurre lo mismo: **todo** queda bloqueado salvo lo que permitamos explícitamente. Autorizar los rangos `10.10.10.0/24` y `10.20.20.0/24` completos es equivalente en espíritu (solo la Red Solo Anfitrión y la VPN pueden hablar con el servidor), y además evita tener que mantener una lista de puertos de dominio (88, 389, 445, 464, 636, 3268...) que es fácil olvidar y que rompería la autenticación si te dejas uno.
>
> > [!note] 💡 El puerto de WireGuard queda abierto "a todos" a propósito
> > El puerto `51820/udp` debe seguir aceptando conexiones desde cualquier origen: es la puerta por la que el túnel VPN establece la conexión inicial. Una vez dentro del túnel, el tráfico ya viaja cifrado y autenticado con clave pública — por eso es seguro dejarlo abierto, a diferencia de SSH o SMB en claro.

> [!example] Paso 3: Verificar las reglas aplicadas
> ```bash
> sudo ufw status verbose
> ```
> Deberías ver algo parecido a:
> ```
> Status: active
> Default: deny (incoming), allow (outgoing), disabled (routed)
>
> To                         Action      From
> --                         ------      ----
> 51820/udp                  ALLOW IN    Anywhere
> Anywhere                   ALLOW IN    10.10.10.0/24
> Anywhere                   ALLOW IN    10.20.20.0/24
> ```
>
> > [!caution] ⚠️ No cierres tu propia sesión SSH sin comprobar antes
> > Si estás conectado por SSH desde una IP que **no** está dentro de `10.10.10.0/24` ni `10.20.20.0/24` (por ejemplo, si te conectaste directamente desde el host sin pasar por la Red Solo Anfitrión ni por el túnel), al ejecutar `sudo ufw enable` te quedarás fuera del servidor. Verifica siempre desde qué IP estás conectado (`who` o `w` en el propio servidor) antes de activar el firewall.

> [!example] Paso 4: Auditoría Local de Servicios
> Ejecuta este comando en la terminal de tu servidor para verificar que no hay "polizontes" o servicios desconocidos escuchando en red:
> ```bash
> # Listar procesos que escuchan en red con su nombre
> sudo ss -tunlp
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`-t -u`:** Muestra puertos TCP y UDP.
> > - **`-n`:** Muestra números de puerto en lugar de nombres de servicio.
> > - **`-l`:** Solo muestra puertos que están en escucha (*listening*).
> > - **`-p`:** Muestra el nombre del proceso (ej. `smbd`, `winbind`, `wg-quick`) que es dueño de ese puerto.
>
> Compara la salida con las reglas de `ufw` del Paso 3: cualquier puerto que aparezca en escucha y no esté cubierto por una regla de `ufw` (o que no reconozcas) merece investigación.

---


> [!example] Paso 5: Cerrar el SSH directo y dejarlo solo por el túnel
> Este es el último cerrojo, y el que de verdad aplica **Zero Trust** a la administración: a partir de aquí, al servidor solo se entra **por el túnel WireGuard** que montaste en la Fase 3.
>
> > [!danger] 🛑 ANTES DE TOCAR NADA: no cierres tu única puerta
> > Este paso deja el servidor accesible **solo** desde el túnel. Si lo aplicas sin comprobarlo, te quedas fuera.
> >
> > **Cuatro condiciones, las cuatro obligatorias:**
> > 1. [ ] El túnel está levantado: `sudo wg show` muestra el peer con `latest handshake`.
> > 2. [ ] El `ping 10.20.20.1` responde desde el cliente.
> > 3. [ ] 💾 Tienes tomada la instantánea de la fase anterior.
> > 4. [ ] Sabes **desde qué máquina** vas a administrar después. Solo podrá hacerlo la que tenga el túnel.
> >
> > Si alguna casilla está sin marcar, **no sigas**.
>
> **1. Edita la configuración de SSH:**
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> Busca la línea `#Port 22`, quítale el `#` y déjala en `Port 2222`. Y añade debajo:
> ```
> ListenAddress 10.20.20.1
> ```
> Guarda con `Ctrl+O`, `Enter`, `Ctrl+X`.
>
> > [!warning] ⚠️ El paso que TODO el mundo se salta: `daemon-reload`
> > Desde **Ubuntu 22.10**, OpenSSH no escucha por sí mismo: lo hace **`ssh.socket`**, una unidad de systemd. Y hay un traductor entre medias, un generador llamado **`sshd-socket-generator`**, que lee tu `sshd_config` y convierte el `Port` y el `ListenAddress` en la configuración de ese socket.
> >
> > **Ese generador solo se ejecuta al arrancar el sistema o con `systemctl daemon-reload`.** Por eso, si editas el fichero y haces únicamente `systemctl restart ssh`, **no pasa absolutamente nada**: el socket sigue con la configuración vieja.
> >
> > Y es un fallo peligroso porque es **silencioso**: crees haber cerrado el servidor y sigue escuchando en el 22 para toda la red. **Un fichero de configuración correcto no sirve de nada si no llega al sitio donde se aplica.**
>
> **2. Aplica el cambio de verdad:**
> ```bash
> sudo systemctl daemon-reload
> sudo systemctl restart ssh.socket
> ```
>
> **3. Verifica ANTES de cerrar nada:**
> ```bash
> sudo ss -tlnp | grep ssh
> ```
> Tiene que salir **`10.20.20.1:2222`** y **ninguna línea con `0.0.0.0:22`**.
>
> Y si quieres ver de dónde sale esa configuración:
> ```bash
> systemctl cat ssh.socket
> ```
> Verás al final el bloque `/run/systemd/generator/ssh.socket.d/addresses.conf`, con el comentario *"Automatically generated by sshd-socket-generator"*. **Ese fichero no lo edites nunca**: se regenera solo a partir de `sshd_config`.
>
> > [!danger] 🔑 Comprueba el acceso nuevo SIN cerrar el actual
> > **Deja tu sesión abierta** y abre **otra terminal** en la máquina que tiene el túnel:
> > ```bash
> > ssh -p 2222 boochan@10.20.20.1
> > ```
> > **Solo cuando esa segunda sesión funcione**, cierra la primera. Si falla, aún estás dentro y puedes deshacerlo.
>
> > [!bug] 🆘 Cómo revertirlo
> > La fuente de verdad es `sshd_config`, así que se deshace ahí — **no** con `systemctl revert`, que no toca nada porque el drop-in lo crea el generador:
> > ```bash
> > sudo nano /etc/ssh/sshd_config
> > ```
> > Comenta las dos líneas (`#Port 2222`, `#ListenAddress 10.20.20.1`) y **vuelve a lanzar el generador**:
> > ```bash
> > sudo systemctl daemon-reload
> > sudo systemctl restart ssh.socket
> > sudo ss -tlnp | grep ssh
> > ```
> > Debe volver a `0.0.0.0:22`.
> >
> > Y si te has quedado fuera del todo: la **consola de VirtualBox** no depende de SSH. Esa es tu puerta de emergencia.
>
> > [!caution] ⚠️ Esto rompe el reenvío de puertos, si lo montaste
> > Si configuraste un reenvío `anfitrión:2222 → VM:22` para administrar desde otro ordenador de la red, **deja de funcionar**: ya no hay nadie en el puerto 22 de la VM, y la NAT no puede alcanzar el `10.20.20.1`.
> >
> > La salida correcta es **meter ese ordenador en la VPN**: generarle su par de llaves y añadirle su `[Peer]` en el servidor con `10.20.20.3/32`. Es además la demostración de que WireGuard admite varios clientes — uno por `[Peer]`, cada uno con su llave y su IP `/32`.
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Por qué `systemctl restart ssh` no basta y hace falta `daemon-reload`?
> > 2. Antes de este paso, ¿desde cuántos sitios se podía administrar el servidor? ¿Y después?
> > 3. ¿Qué pasaría si aplicaras esto **sin** haber verificado el túnel? Contesta con lo que harías para recuperarte.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Auditoria_Final.4_Fundamento_Teorico]] | [[Auditoria_Final]] | [[Auditoria_Final.6_Punto_de_Control]] |
