## 🔒 Fase 3: Conectividad VPN (WireGuard)

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 9: Gestión remota e Integración en Red]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM VirtualBox con Red Solo Anfitrión operativa | Cliente WireGuard | SSH

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> Montar un túnel cifrado toca **tres** resultados de aprendizaje, porque es a la vez conectividad, seguridad de acceso e integración entre máquinas distintas:
>
> **`RA.01`** *(35 % del módulo · UD1-UD4)* — *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
> **`RA.04`** *(12 % del módulo · UD7)* — *Gestiona los recursos compartidos del sistema, interpretando especificaciones y determinando niveles de seguridad.*
> **`RA.06`** *(12 % del módulo · UD7)* — *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | El `ping` a través del túnel `10.20.20.0/24`, que es una conectividad distinta de la del Paso 7 de la Fase 1 |
> | `CE.04.f` | Se han establecido niveles de seguridad para controlar el acceso del cliente a los recursos compartidos. | El túnel **es** un nivel de seguridad: decide quién puede llegar al servidor y quién no |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | El cliente WireGuard corre en tu ordenador (Windows/macOS) y el servidor en Ubuntu: dos sistemas distintos hablando |
> | `CE.06.h` | Se han establecido niveles de seguridad para controlar el acceso del usuario a los recursos compartidos. | Claves pública/privada por cliente: cada peer tiene su identidad criptográfica |
>
> > [!info] 🤔 ¿Por qué una VPN no tiene un resultado de aprendizaje propio?
> > Porque el título de SMR es de **2007** y sus resultados de aprendizaje **no contemplan las VPN** — sencillamente no eran lo que son hoy. Por eso esta fase se evalúa por lo que el título sí contempla: conectividad, control de acceso e integración entre sistemas distintos. Que es, exactamente, lo que una VPN hace.

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-3-conectividad-vpn-wireguard.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 3 de Boochan V1 — Conectividad VPN (WireGuard)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 3 — Conectividad VPN (WireGuard)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 2
> Completaste la purga del servidor y le diste identidad de dominio (`UbuntuServer.BOOCHANLAB.LOCAL`). Ahora tienes un servidor limpio, profesional, con identidad, accesible por SSH en `10.10.10.10` a través de la Red Solo Anfitrión de VirtualBox.

> [!warning] El Problema... ¿o no?
> En las versiones cloud de este proyecto (Azure/AWS), esta fase resuelve un problema real: el servidor tiene una IP pública expuesta a todo internet, y sin VPN cualquier bot podría intentar entrar por fuerza bruta al puerto 22. **Aquí, en tu laboratorio local, ese problema físicamente no existe:** tu servidor vive dentro de una Red Solo Anfitrión de VirtualBox, aislada de internet y de la red del instituto por diseño — nadie fuera de tu propio PC puede ni siquiera verla, y mucho menos atacarla desde internet.

> [!success] Objetivo de esta Fase (y por qué la hacemos igualmente)
> Vamos a instalar **WireGuard** igualmente, aunque no exista una amenaza real de internet que blindar. ¿Por qué? Porque el objetivo pedagógico de esta fase no es "protegerte de internet" sino **aprender a construir y verificar un túnel VPN cifrado punto a punto** — una habilidad profesional que se necesita tanto si el otro extremo está a un clic (como aquí) como si está a miles de kilómetros (como en las versiones cloud). Cuando más adelante crees la VM cliente Windows 11 en la misma Red Solo Anfitrión, ese cliente se conectará al servidor **a través de este túnel WireGuard**, no directamente por `10.10.10.10` — replicando exactamente el mismo modelo de seguridad "Zero Trust" que usarías en un entorno real, aunque técnicamente pudieras saltártelo por estar en la misma red virtual.

> [!tip] Hoja de Ruta
> 1. Instalar WireGuard en el servidor
> 2. Generar pares de llaves criptográficas (servidor + cliente)
> 3. Crear archivo de configuración `wg0.conf` en el servidor, con el rango de túnel `10.20.20.0/24`
> 4. Preparar la configuración del lado cliente (la usará la futura VM Windows 11, o un cliente de prueba mientras tanto)
> 5. Activar el túnel y verificar con `ping 10.20.20.1` desde el cliente
> 6. Cerrar el acceso SSH directo por `10.10.10.10` y aceptar solo conexiones por el túnel (`10.20.20.1`, puerto 2222)
>
> **Resultado Final:** Servidor accesible solo a través del túnel VPN cifrado. Modelo de seguridad profesional aplicado, aunque el "peligro" real de esta red aislada sea mínimo.
> **Siguiente:** Fase 4 (Dominio) — provisionar el Active Directory. Ahora que hay conexión VPN cifrada, puedes instalar servicios críticos.

---

### 📚 Fundamento Teórico

> [!abstract] 1. Seguridad en Profundidad, incluso cuando "no hace falta"
> En una empresa real nunca confías en que una red sea segura solo por estar "dentro de las cuatro paredes". Este principio se llama **Defensa en Profundidad**: cada capa (red aislada, VPN, autenticación, cifrado) protege aunque las demás fallen. Aquí, la Red Solo Anfitrión de VirtualBox ya te da una capa de aislamiento; WireGuard añade una segunda capa de cifrado y autenticación mutua **por si acaso** — y, sobre todo, para que practiques la técnica que usarás en un despliegue real.

> [!info] 2. ¿Qué es WireGuard?
> A diferencia de protocolos antiguos (como OpenVPN), WireGuard funciona al nivel del **Kernel** de Linux. Esto lo hace invisible para los atacantes y extremadamente rápido. Utiliza **criptografía de curva elíptica**, asegurando que los datos viajen por un canal 100% blindado — sea ese canal un cable transatlántico o, como en tu caso, un conmutador virtual dentro de tu propio PC.

> [!important] 3. Intercambio de Llaves
> El servidor y el cliente se reconocen mediante un intercambio de llaves:
> *   **Llave Pública:** Se puede compartir (es como la dirección de tu casa).
> *   **Llave Privada:** Es el secreto absoluto. Solo quien posee la llave privada puede descifrar el tráfico que le llega.

> [!note] 4. Dos redes, dos propósitos: no confundas `10.10.10.0/24` con `10.20.20.0/24`
> En este proyecto conviven dos rangos de IP distintos y no deben mezclarse:
> *   **`10.10.10.0/24`** — la Red Solo Anfitrión "física" de VirtualBox (servidor = `10.10.10.10`). Es el cable de red virtual.
> *   **`10.20.20.0/24`** — la red virtual del **túnel WireGuard** (servidor = `10.20.20.1`, cliente = `10.20.20.2`). Es un cable dentro del cable: una capa de cifrado que viaja encapsulada dentro de la primera.
> Usar rangos claramente distintos es una buena práctica profesional: cuando veas una IP `10.20.20.x` en un log, sabrás al instante que ese tráfico pasó por el túnel cifrado.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología VPN
> - **Cifrado Asimétrico:** Sistema que usa una llave para cerrar (pública) y otra distinta para abrir (privada).
> - **wg0.conf:** El "cerebro" o archivo maestro que define la red virtual y quién puede entrar en ella.
> - **Peer:** Cada uno de los extremos de la conexión (el servidor y la futura VM cliente Windows 11 son "Peers").
> - **Endpoint:** La dirección donde un peer escucha conexiones. En cloud es una IP pública; aquí es la IP de la Red Solo Anfitrión del servidor (`10.10.10.10`).

---

### 🔓 Firewall Local: por qué aquí no hay "Security Group" que configurar

> [!info] Sin NSG, sin Security Group... sin nada que abrir
> En BoochanV2 (Azure) y BoochanV3 (AWS) esta sección se dedicaba a abrir el puerto 51820/UDP en el firewall del proveedor cloud (NSG o Security Group). **En tu laboratorio local no existe ese firewall perimetral**: la Red Solo Anfitrión de VirtualBox no filtra tráfico entre el host y las VMs que la comparten, así que el paquete UDP de WireGuard llega sin obstáculos de un extremo a otro. No tienes ningún portal que abrir.
>
> > [!tip] 💡 Verificación rápida: ¿tiene Ubuntu su propio firewall activo?
> > Ubuntu Server incluye `ufw` (Uncomplicated Firewall), pero **viene desactivado por defecto** tras una instalación limpia. Compruébalo:
> > ```bash
> > sudo ufw status
> > ```
> > Si responde `Status: inactive`, no hay nada que hacer — el tráfico WireGuard pasará sin problema. Si en algún momento activas `ufw` (buena práctica en un servidor real), recuerda permitir el puerto `51820/udp` y el `2222/tcp` con `sudo ufw allow 51820/udp` y `sudo ufw allow 2222/tcp`.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-3-conectividad-vpn-wireguard.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Al terminar: cierra el 22 directo y activa el SSH seguro por el 2222 vía túnel
> Una vez que el túnel VPN funcione y hayas comprobado el `ping 10.20.20.1`, aplica **Zero Trust**: cerramos el acceso SSH directo por la Red Solo Anfitrión y dejamos solo el acceso a través del túnel cifrado.
>
> **En el servidor:** cambia el puerto SSH de 22 a 2222 y haz que solo escuche en la interfaz del túnel:
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> Busca la línea `#Port 22`, elimina el `#` y cámbiala a `Port 2222`. Añade también una línea `ListenAddress 10.20.20.1` para que SSH solo escuche a través del túnel WireGuard (no en `10.10.10.10`). Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y reinicia el servicio:
> ```bash
> sudo systemctl restart ssh
> ```
>
> > [!caution] ⚠️ No cierres tu única puerta antes de verificar
> > No apliques este cambio hasta que hayas comprobado el `ping 10.20.20.1` funcionando desde el cliente. Si cierras el SSH de la Red Solo Anfitrión antes de que el túnel esté probado y operativo, te quedarás sin forma de administrar el servidor remotamente — tendrás que recuperar el acceso desde la propia consola de VirtualBox.
>
> A partir de este momento **todas tus conexiones SSH usarán este comando** (con la IP del túnel, no la de la Red Solo Anfitrión):
> ```bash
> ssh -p 2222 usuario@10.20.20.1
> ```

---

### 🛠️ Procedimiento Práctico (BoochanV1)

> [!example] Paso 1: Generación de Llaves Criptográficas del Servidor
> Ejecuta estos comandos en el servidor para generar la identidad digital del servidor.
> *El comando `umask 077` es vital: asegura que nadie más pueda leer tu llave.*
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta de `wg` y repasar otros comandos de Linux, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> sudo -i
> cd /etc/wireguard
> umask 077
> wg genkey | tee privatekey | wg pubkey > publickey
> ```
> Ahora **lee y anota** la llave pública del servidor. La necesitarás cuando configures el cliente en el Paso 3:
> ```bash
> # Muestra la llave PÚBLICA del servidor (esta se comparte con el cliente)
> cat /etc/wireguard/publickey
> ```
> Cuando hayas copiado el valor, vuelve al usuario normal:
> ```bash
> exit
> ```
>
> > [!tip] 💡 ¿Qué hace este comando? (La tubería avanzada)
> > - **El Pipe (`|`):** Imagina que es una tubería. La salida de un comando entra directamente al siguiente.
> > - **El comando `tee`:** Es como una **"T"** en una tubería de agua. Permite que los datos sigan su camino por la tubería pero, al mismo tiempo, guarda una copia en un archivo (`privatekey`).
> > - **`umask 077`:** Es como echar la llave a la habitación antes de escribir un secreto. Asegura que solo tú puedas leer las llaves que vas a generar.

> [!example] Paso 2: Configuración del Túnel en el Servidor (`wg0.conf`)
> Crea el archivo `/etc/wireguard/wg0.conf` con el editor `nano`.
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
>
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
> Escribe este contenido. Sustituye `<CONTENIDO_DE_TU_PRIVATEKEY>` por el valor del archivo `privatekey`:
> ```ini
> [Interface]
> PrivateKey = <CONTENIDO_DE_TU_PRIVATEKEY>
> Address = 10.20.20.1/24
> ListenPort = 51820
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_CLIENTE>
> AllowedIPs = 10.20.20.2/32
> ```
> Guarda con `Ctrl + O`, `Enter`, `Ctrl + X`. Deja el campo `<LLAVE_PÚBLICA_DEL_CLIENTE>` como está por ahora; lo completarás en el Paso 4 una vez que generes las llaves del cliente.

> [!example] Paso 3: Configuración del Lado Cliente
> El túnel VPN necesita dos extremos configurados. En el proyecto final, el "cliente" será la **VM Windows 11** que crearás en una fase posterior de este itinerario. Como esa VM todavía no existe, tienes dos caminos válidos para completar y probar esta fase ahora mismo:
>
> > [!tip] 💡 Opción A (recomendada): usa tu propio PC físico como cliente de prueba
> > Instala temporalmente la aplicación WireGuard en el PC donde corre VirtualBox. Como tu propio ordenador ya forma parte de la Red Solo Anfitrión `vboxnet0` (con IP `10.10.10.1`, configurada en la Fase 1), puedes usarlo directamente como cliente de prueba sin tocar nada más en VirtualBox. Esto te permite verificar el túnel de extremo a extremo *ahora*, sin esperar a tener la VM Windows 11 lista. Cuando más adelante crees esa VM, repetirás estos mismos pasos dentro de ella y usarás su llave pública en lugar de la de tu PC — el resto de la configuración del servidor no cambia.
>
> > [!tip] 💡 Opción B: deja el túnel preparado y sin probar
> > Si prefieres no instalar WireGuard en tu PC físico, puedes completar el archivo `wg0.conf` del servidor con una llave de cliente "provisional" (generada con `wg genkey | wg pubkey`, sin instalarla en ningún sitio todavía) y posponer la verificación del `ping 10.20.20.1` hasta la fase en la que crees la VM Windows 11. Ten en cuenta que en ese caso no podrás completar el Punto de Control de esta fase hasta entonces.
>
> **1. Instala la aplicación WireGuard** (si eliges la Opción A, en tu PC físico; si eliges completarlo más adelante, dentro de la futura VM Windows 11):
> - **Windows:** Ve a `wireguard.com/install`, descarga el instalador `.exe` y ejecútalo.
> - **Mac:** Búscalo en la App Store buscando "WireGuard" o descárgalo desde `wireguard.com/install`.
>
> **2. Crea un nuevo túnel y obtén las llaves del cliente:**
> - Abre la aplicación WireGuard.
> - Haz clic en **"Agregar túnel"** → **"Crear nuevo túnel vacío"** (en Mac: icono `+`).
> - WireGuard genera automáticamente las llaves del cliente. Verás la **Clave Pública** del cliente en la parte superior del cuadro de configuración.
> - **Copia y anota esa Clave Pública**: la necesitarás en el servidor.
>
> **3. Completa el archivo de configuración del cliente** con este contenido:
> ```ini
> [Interface]
> PrivateKey = <SE_RELLENA_AUTOMÁTICAMENTE_por_WireGuard>
> Address = 10.20.20.2/32
> DNS = 10.20.20.1
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_SERVIDOR_del_Paso_1>
> AllowedIPs = 10.20.20.0/24
> Endpoint = 10.10.10.10:51820
> PersistentKeepalive = 25
> ```
>
> > [!important] 💡 ¿Y el `Endpoint`? Aquí es distinto a la versión cloud
> > En BoochanV2/V3 el `Endpoint` era la IP pública del servidor en internet. Aquí, como todo vive dentro de VirtualBox, el `Endpoint` es simplemente la IP de la **Red Solo Anfitrión** del servidor: `10.10.10.10:51820`. El `PersistentKeepalive` sigue siendo una buena práctica a mantener (evita que ciertos firewalls o el propio sistema operativo den por "muerta" una conexión inactiva), aunque en una red local su necesidad real sea menor que atravesando el NAT de un proveedor cloud.

> [!example] Paso 4: Intercambio de Llaves y Activación
> Vuelve a la sesión SSH del servidor y completa el archivo `wg0.conf` con la llave pública del cliente que anotaste en el Paso 3:
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
> Sustituye `<LLAVE_PÚBLICA_DEL_CLIENTE>` por la llave pública real. Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!caution] ⚠️ Atención al Portapapeles (Copia-Pega)
> > Al borrar el texto de ejemplo `<LLAVE...>`, asegúrate de eliminar también los símbolos `<` y `>`. Un espacio extra, un salto de línea invisible o una letra comida arruinará la conexión VPN de forma silenciosa.
> >
> > **Antes de guardar**, verifica que la clave quedó bien pegada ejecutando:
> > ```bash
> > sudo grep PublicKey /etc/wireguard/wg0.conf
> > ```
> > La salida debe ser una sola línea limpia, sin espacios al principio ni al final, parecida a esto:
> > ```
> > PublicKey = aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890abcde=
> > ```
> > Si ves dos líneas, espacios raros o caracteres `<` o `>` sueltos, vuelve a editar el archivo antes de continuar.
>
> Ahora levanta el túnel en el servidor y hazlo persistente:
> ```bash
> # Levantar el túnel
> sudo wg-quick up wg0
> # Hacerlo persistente al reinicio
> sudo systemctl enable wg-quick@wg0
> ```
>
> **En el cliente (tu PC físico, si elegiste la Opción A):** Activa el túnel haciendo clic en el botón **"Activar"** de la aplicación WireGuard.
>
> Verifica que el túnel está activo. En el servidor:
> ```bash
> # Muestra el estado del túnel y los peers conectados
> sudo wg show
> ```
> Y desde el cliente:
> ```bash
> # Si recibes respuestas, el túnel funciona correctamente
> ping 10.20.20.1
> ```
>
> > [!important] 🔒 VPN activa: momento de cerrar el acceso directo
> > El túnel funciona. Ahora es el momento de ejecutar las acciones de seguridad descritas más arriba: cambiar el puerto SSH a 2222 y hacer que solo escuche en `10.20.20.1`.
> >
> > A partir de ese momento, **todas tus conexiones SSH usarán este comando** (con la IP del túnel, no la de la Red Solo Anfitrión):
> > ```bash
> > ssh -p 2222 usuario@10.20.20.1
> > ```

---

> [!example] 🔌 Paso 5 — EJERCICIO DE VERIFICACIÓN: qué hace de verdad tu VPN
> Tienes el túnel levantado y `wg show` dice que hay tráfico. Bien. Pero **¿sabes qué hace exactamente esa VPN, y sobre todo qué NO hace?** Vamos a comprobarlo con fuentes externas.
>
> > [!info] Recordatorio: por qué usamos APIs
> > Una **API** es una web hecha para que la consulte un programa: devuelve **datos limpios** en JSON en vez de una página. Un administrador las usa para **comprobar desde fuera lo que desde dentro no puede ver**. La teoría completa está en la práctica **B1.9b** del Bloque 1.
>
> **a) La red del túnel.** Tu túnel es **`10.20.20.0/24`**. Antes de mirar nada, escribe en tu entrada de apuntes cuántos clientes VPN caben en él. Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.20.20.0/24"
> ```
>
> **b) Y ahora la pregunta buena: ¿por qué el cliente lleva `/32`?**
> Fíjate en tu configuración: el servidor tiene `Address = 10.20.20.1/24` pero el cliente tiene `Address = 10.20.20.2/32`. **No es un error.** Míralo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.20.20.2/32"
> ```
> ```json
> "subnet_mask": "255.255.255.255",   "network_address": "10.20.20.2",
> "broadcast_address": "10.20.20.2",       "assignable_hosts": 0
> ```
>
> > [!success] 🤔 Léelo y explícalo en el vídeo
> > Una máscara `/32` significa **una sola dirección**: red, broadcast y host son la misma. **Cero hosts asignables.**
> > Traducido: *"yo soy exactamente esta IP y ninguna más"*. Por eso WireGuard usa `/32` en los clientes — cada uno declara **su** dirección exacta, y el servidor sabe sin ambigüedad a quién enviar cada paquete. Si pusieras `/24` en el cliente, estarías diciendo *"yo soy toda la red"*, y el enrutado se rompería.
>
> **c) El experimento que desmonta un mito.** Tu servidor no tiene IP pública: sale por el NAT de tu equipo, como comprobaste en la Fase 1.
>
> 1. Con la VPN **desconectada**, en el cliente:
>    ```bash
>    curl "https://api.ipify.org?format=json"
>    ```
>    Anota la IP.
> 2. **Conecta el túnel** y comprueba que funciona: `ping 10.20.20.1`
> 3. Con la VPN **conectada**, repite exactamente el mismo comando.
>
> > [!danger] 🤯 Sale la MISMA IP. Y está bien.
> > Casi todo el mundo cree que "conectarse a una VPN" cambia tu IP pública — es lo que venden los anuncios de NordVPN y compañía. **Tu VPN no hace eso, y es a propósito.**
> >
> > Mira tu configuración: `AllowedIPs = 10.20.20.0/24`. Le has dicho al cliente: *"manda por el túnel **solo** lo que vaya a esa red"*. Todo lo demás —YouTube, Google, ipify— **sigue saliendo por tu conexión normal**. Eso se llama **split tunnel** (túnel partido).
> >
> > | | Qué manda por el túnel | Tu IP pública |
> > | :--- | :--- | :--- |
> > | **Split tunnel** (`AllowedIPs = 10.20.20.0/24`) ← el tuyo | Solo el tráfico hacia el servidor | **No cambia** |
> > | **Full tunnel** (`AllowedIPs = 0.0.0.0/0`) | **Todo** tu tráfico de Internet | Sí: sale la del servidor |
> >
> > **¿Y por qué split y no full?** Porque tu VPN existe para **llegar a tu servidor de forma segura**, no para ocultarte. Si mandaras todo el tráfico por el túnel, cargarías tu servidor con el YouTube de todos los clientes, y si el túnel cae te quedas sin Internet. Un administrador elige *split* salvo que tenga una razón concreta para lo contrario.
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Cuántos clientes VPN caben en tu túnel? ¿Coincidió con tu cálculo?
> > 2. ¿Por qué el cliente lleva `/32` y el servidor `/24`? Explícalo con lo que devolvió la API.
> > 3. Tu IP pública **no cambió** al conectar la VPN. **¿Por qué?** ¿Qué habría que cambiar en la configuración para que sí cambiara?
> > 4. Un compañero dice: *"si uso VPN nadie sabe lo que hago en Internet"*. Con lo que acabas de comprobar, **¿tiene razón?**

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿No hay conexión?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `Address already in use`. | Ya hay otra interfaz VPN activa con esa IP. | Ejecuta `sudo wg-quick down wg0` antes de volver a levantarla. |
> | No hay ping entre `10.20.20.1` y `10.20.20.2`. | El cliente no está en la misma Red Solo Anfitrión que el servidor, o el adaptador de red del cliente está mal seleccionado en VirtualBox. | Comprueba en VirtualBox que el adaptador usado por el cliente apunta a la misma red Solo Anfitrión (`vboxnet0`, la que configuraste en la Fase 1). |
> | WireGuard no conecta pero no hay firewall de por medio. | Las llaves públicas están intercambiadas incorrectamente. | Verifica que la llave pública del cliente en el servidor y la del servidor en el cliente son exactas. |
> | El cliente no encuentra el `Endpoint`. | Escribiste mal la IP `10.10.10.10` o el servidor no tiene esa IP activa. | Ejecuta `hostname -I` en el servidor y confirma que `10.10.10.10` sigue asignada al adaptador de Red Solo Anfitrión. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué la llave privada **NUNCA** debe salir de tu servidor ni enviarse por correo?
> 2. ¿Qué ventaja tiene WireGuard sobre protocolos antiguos en términos de rendimiento?
> 3. ¿Para qué sirve el parámetro `AllowedIPs` en la configuración del Peer?
> 4. Si tu Red Solo Anfitrión de VirtualBox ya está aislada de internet por diseño, ¿qué aporta realmente montar una VPN encima? Argumenta con el concepto de "Defensa en Profundidad".
> 5. 🔬 **Reto práctico:** Con el túnel activo, ejecuta `sudo wg show` en el servidor y localiza la línea `latest handshake`. ¿Hace cuántos segundos fue el último intercambio? Ahora desactiva el túnel desde el cliente y vuelve a ejecutar el comando 30 segundos después. ¿Qué cambió en esa línea? ¿Qué te dice eso sobre el estado de la conexión?
> 6. 🔬 **Reto práctico:** Con el túnel WireGuard **desactivado**, intenta conectarte al servidor por SSH usando la IP `10.10.10.10` (no la `10.20.20.1`). ¿Puedes entrar? ¿Por qué sí o por qué no? Razona tu respuesta mirando la configuración `ListenAddress` de `sshd_config` que aplicaste en esta fase.

---

> [!caution] 🛑 Auditoría y Seguridad (RA.05)
> Las llaves privadas son la **identidad** de tu servidor. Si alguien las copia, podrá entrar en tu red virtual como si fuera él. **Validación:** El alumno debe demostrar el `ping 10.20.20.1` desde el cliente y el `sudo wg show` en el servidor mostrando el peer conectado.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-3-conectividad-vpn-wireguard.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 3 — Conectividad VPN (WireGuard)`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes en GitHub | La entrada, subida con `git add` → `commit` → `push` |
>
> > [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> > Las **Preguntas Críticas** y el **🔬 Reto** de más arriba no son decorativos: son la parte de la fase que demuestra que has entendido lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
> > Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.
>
> > [!info] 🏷️ Por qué el nombre lleva `V1` delante
> > Porque el proyecto Boochan existe en **varias versiones** (VirtualBox, Hyper-V, Azure, AWS…) y algunas comparten bloque y playlist. Sin la etiqueta, la Fase 4 de Azure y la de AWS se llamarían **exactamente igual** y no habría forma de distinguirlas. Con ella, tu carpeta y tu playlist dicen siempre **qué versión hiciste**.
>
> > [!success] 🎯 Criterio de éxito
> > Abro tu repositorio, encuentro la entrada de esta fase, y dentro está: qué has hecho, qué has entendido, qué dudas te han quedado y el enlace al vídeo donde se te ve haciéndolo. Si falta el enlace o faltan las respuestas, la fase **no cuenta como entregada**.
>
> > [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> > **Una fase, una entrada.** No creas un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**, para no perder nunca más de un día de trabajo.
