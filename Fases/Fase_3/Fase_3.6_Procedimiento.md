## Fase 3 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] Paso 1: Generación de Llaves Criptográficas del Servidor
> Ejecuta estos comandos en el servidor para generar la identidad digital del servidor.
> *El comando `umask 077` es vital: asegura que nadie más pueda leer tu llave.*
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta de `wg` y repasar otros comandos de Linux, consulta el [[Diccionario_Comandos_Sistema]].
>
> > [!danger] ⚠️ Estos comandos NO se pegan de golpe. Uno a uno.
> > `sudo -i` **abre una shell nueva**. Si pegas el bloque entero, las líneas siguientes llegan antes de que esa shell esté lista para leerlas y **se ejecutan donde no toca**: acabas con las llaves creadas en `/root` en vez de en `/etc/wireguard`, sin ningún mensaje de error que te avise.
> >
> > Es un fallo silencioso y desconcertante: los comandos "funcionan", pero el `cat` posterior te dice `No such file or directory` y no entiendes por qué.
> >
> > **Ejecuta cada línea por separado, y comprueba dónde estás antes de generar nada.**
>
> **1.** Conviértete en administrador. Ejecuta **solo esta línea** y espera a ver el nuevo prompt:
> ```bash
> sudo -i
> ```
>
> **2.** Sitúate en el directorio de WireGuard **y comprueba que estás ahí**:
> ```bash
> cd /etc/wireguard
> pwd
> ```
> El `pwd` tiene que devolver exactamente `/etc/wireguard`. **Si devuelve `/root`, no sigas** — el `cd` no ha funcionado y las llaves acabarían en el sitio equivocado.
>
> > [!tip] 💡 El prompt también te lo dice
> > Fíjate en la línea de comandos: `root@UbuntuServer:~#` significa que estás en `/root` (el `~` es tu carpeta personal). Cuando el `cd` funcione verás `root@UbuntuServer:/etc/wireguard#`. **Acostúmbrate a leer el prompt: te está diciendo dónde estás en todo momento.**
>
> **3.** Ahora sí, genera las llaves:
> ```bash
> umask 077
> wg genkey | tee privatekey | wg pubkey > publickey
> ls -l
> ```
> El `ls -l` debe mostrar `privatekey` y `publickey` con permisos **`-rw-------`**: solo el propietario puede leerlas. Si ves otros permisos, el `umask` no se aplicó.
>
> **4.** Ahora **lee y anota** la llave pública del servidor. La necesitarás cuando configures el cliente en el Paso 3:
> ```bash
> # Muestra la llave PÚBLICA del servidor (esta se comparte con el cliente)
> cat /etc/wireguard/publickey
> ```
> **5.** Cuando hayas copiado el valor, vuelve al usuario normal:
> ```bash
> exit
> ```
>
> > [!bug] 🆘 ¿El `cat` te dice `No such file or directory`?
> > Las llaves se crearon en otro directorio, casi seguro en `/root`, porque el bloque se pegó de golpe. Compruébalo:
> > ```bash
> > ls -l /root/privatekey /root/publickey
> > ```
> > Si están ahí, **bórralas** (son llaves privadas sueltas donde no deben estar) y repite desde el punto 1, línea a línea:
> > ```bash
> > rm -f /root/privatekey /root/publickey
> > ```
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
> **1.** Primero, **saca a pantalla la llave PRIVADA del servidor**, que es la que necesitas ahora. Es el otro fichero que generaste en el Paso 1:
> ```bash
> sudo cat /etc/wireguard/privatekey
> ```
> Cópiala. Es una cadena larga terminada en `=`, parecida a la pública pero **distinta**.
>
> > [!danger] 🔑 No confundas las dos llaves
> > | Fichero | Qué es | Dónde va |
> > | :--- | :--- | :--- |
> > | `privatekey` | El secreto del servidor | **Solo** en el `wg0.conf` del servidor. **No sale de la máquina jamás** |
> > | `publickey` | La identidad pública del servidor | Se le da al **cliente**, en su configuración |
> >
> > Si metes la pública donde va la privada, el túnel no levantará y el error no te dirá que has confundido las llaves. **Compruébalo antes de guardar.**
> >
> > Que la privada aparezca en pantalla mientras grabas es aceptable en un laboratorio aislado. En un servidor real sería un incidente de seguridad — y la primera medida sería regenerar las llaves.
>
> **2.** Ahora crea el fichero:
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
>
> **3.** Escribe **solo esto**, sustituyendo `<TU_PRIVATEKEY>` por lo que acabas de copiar:
> ```ini
> [Interface]
> PrivateKey = <TU_PRIVATEKEY>
> Address = 10.20.20.1/24
> ListenPort = 51820
> ```
>
> Guarda con `Ctrl + O`, `Enter`, `Ctrl + X`.
>
> > [!warning] ⚠️ La sección `[Peer]` todavía NO
> > El túnel tiene dos extremos y aún no existe el segundo: **la llave pública del cliente se genera en el Paso 3.**
> >
> > Podrías escribir el bloque `[Peer]` ahora con un marcador tipo `<LLAVE_DEL_CLIENTE>` y rellenarlo después, pero **no lo hagas**: un `wg0.conf` con un marcador dentro es un fichero **inválido**, y si arrancas WireGuard por error te dará un error de sintaxis críptico que te hará perder el tiempo buscando dónde está el fallo.
> >
> > Mejor un fichero **incompleto pero correcto** que uno completo y roto. Añadirás el `[Peer]` en el Paso 4, cuando tengas la llave de verdad:
> > ```ini
> > [Peer]
> > PublicKey = <la llave pública del cliente>
> > AllowedIPs = 10.20.20.2/32
> > ```
>
> **4.** Comprueba lo que has escrito antes de seguir:
> ```bash
> sudo cat /etc/wireguard/wg0.conf
> ```
> Y verifica que la línea `PrivateKey` coincide **carácter por carácter** con la salida del punto 1. Un solo carácter de más al copiar y pegar, y el túnel no levanta.

> [!example] Paso 3: Configuración del Lado Cliente
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"Cerré la ventana y perdí lo escrito"* → [[Fase_3.7_Resolucion_Problemas#E6 · Cerré la ventana y perdí la configuración|caso E6]]
> > · *"Activo la VPN y pierdo internet"* → [[Fase_3.7_Resolucion_Problemas#E5 · Activo la VPN y me quedo sin internet|caso E5]]
> El túnel VPN necesita dos extremos configurados. En el proyecto final, el "cliente" será la **VM Windows 11** que crearás en una fase posterior de este itinerario. Como esa VM todavía no existe, tienes dos caminos válidos para completar y probar esta fase ahora mismo:
>
> > [!tip] 💡 Opción A (recomendada): usa tu propio PC físico como cliente de prueba
> > Instala temporalmente la aplicación WireGuard en el PC donde corre VirtualBox. Como tu propio ordenador ya forma parte de la Red Solo Anfitrión del laboratorio (con IP `10.10.10.1`, configurada en la Fase 1.2), puedes usarlo directamente como cliente de prueba sin tocar nada más en VirtualBox. Esto te permite verificar el túnel de extremo a extremo *ahora*, sin esperar a tener la VM Windows 11 lista. Cuando más adelante crees esa VM, repetirás estos mismos pasos dentro de ella y usarás su llave pública en lugar de la de tu PC — el resto de la configuración del servidor no cambia.
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
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_SERVIDOR_del_Paso_1>
> AllowedIPs = 10.20.20.0/24
> Endpoint = 10.10.10.10:51820
> PersistentKeepalive = 25
> ```
>
> > [!danger] 🛑 Aquí NO va todavía una línea `DNS`
> > Verás en muchos manuales —y en versiones anteriores de esta práctica— una línea `DNS = 10.20.20.1` dentro de `[Interface]`. **Ahora sería un error.**
> >
> > Esa línea le dice a tu ordenador: *"mientras el túnel esté activo, pregunta los nombres al servidor"*. Y tiene todo el sentido… **a partir de la Fase 4**, cuando Samba levante su DNS interno.
> >
> > **Pero hoy, en `10.20.20.1` no hay ningún servidor DNS.** Si la pones y activas el túnel, tu equipo enviará las consultas a un sitio donde no contesta nadie: **dejarás de navegar mientras la VPN esté conectada**. El síntoma es de los que despistan — *"activo la VPN y se me cae internet"* — porque nada apunta al fichero que lo causó.
> >
> > Es el mismo error de orden que evita el script de la Fase 4: **no apuntes el DNS a un servicio que todavía no existe.** La línea se añade en la **Fase 8**, cuando el cliente tenga que resolver nombres del dominio `BOOCHANLAB.LOCAL`.
>
> > [!important] 💾 **4. Pulsa `Guardar`.** Y NO actives el túnel todavía
> > El botón está abajo a la derecha del cuadro de configuración. Sin pulsarlo, **la configuración que acabas de escribir se pierde** al cerrar la ventana.
> >
> > Después de guardar verás el túnel en la lista, con un botón **`Activar`**. **No lo pulses aún.**
> >
> > **¿Por qué no?** Porque un túnel tiene dos extremos y **el servidor todavía no sabe quién eres**: aún no le has dado tu clave pública. Si activas ahora, WireGuard lo intentará, el servidor descartará tus paquetes por venir de un desconocido, y verás un túnel "activo" que no transmite nada — de los fallos más confusos que hay, porque la interfaz dice que todo va bien.
> >
> > Primero el Paso 4 (darle tu llave al servidor). **Activarás al final, y te lo diré.**

> > [!important] 💡 ¿Y el `Endpoint`? Aquí es distinto a la versión cloud
> > En BoochanV2/V3 el `Endpoint` era la IP pública del servidor en internet. Aquí, como todo vive dentro de VirtualBox, el `Endpoint` es simplemente la IP de la **Red Solo Anfitrión** del servidor: `10.10.10.10:51820`. El `PersistentKeepalive` sigue siendo una buena práctica a mantener (evita que ciertos firewalls o el propio sistema operativo den por "muerta" una conexión inactiva), aunque en una red local su necesidad real sea menor que atravesando el NAT de un proveedor cloud.

> [!danger] ⚠️ El error más común de esta fase: copiar el bloque del cliente en el servidor
> Los dos ficheros se parecen muchísimo y es facilísimo pegar el que no es. **No son intercambiables.** Así queda cada uno:
>
> | | **Servidor** (`/etc/wireguard/wg0.conf`) | **Cliente** |
> | :--- | :--- | :--- |
> | `[Interface]` `PrivateKey` | la **privada del servidor** | la **privada del cliente** |
> | `[Interface]` `Address` | `10.20.20.1/24` | `10.20.20.2/24` |
> | `[Interface]` `ListenPort` | `51820` | *(no lleva)* |
> | `[Peer]` `PublicKey` | la **pública del CLIENTE** | la **pública del SERVIDOR** |
> | `[Peer]` `AllowedIPs` | `10.20.20.2/32` *(solo ese cliente)* | `10.20.20.0/24` *(toda la red del túnel)* |
> | `[Peer]` `Endpoint` | ❌ **NUNCA** | ✅ `10.10.10.10:51820` |
> | `[Peer]` `PersistentKeepalive` | ❌ **NUNCA** | ✅ `25` |
>
> **Fíjate en el patrón:** en cada fichero, `[Interface]` habla de **ti mismo** y `[Peer]` habla **del otro**. Si en el servidor pones `Endpoint = 10.10.10.10`, le estás diciendo que para hablar con el cliente envíe los paquetes… **a sí mismo**.
>
> > [!info] 🤔 ¿Y por qué el servidor no necesita `Endpoint`?
> > Porque **lo aprende solo**: en cuanto recibe el primer saludo criptográfico válido del cliente, anota de dónde vino y le responde ahí. Eso permite que el cliente cambie de red, de Wi-Fi o de IP sin tocar nada en el servidor.
> >
> > El cliente sí lo necesita, porque alguien tiene que dar el primer paso y saber a qué puerta llamar.

> [!example] Paso 4: Intercambio de Llaves y Activación
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"`Address already in use`"* → [[Fase_3.7_Resolucion_Problemas#E1 · Address already in use al levantar el túnel|caso E1]]
> > · *"Dice activo pero no pasa nada"* → [[Fase_3.7_Resolucion_Problemas#E3 · El túnel dice activo pero no pasa nada|caso E3]] — **el más traicionero**
> > · *"No hay ping a `10.20.20.1`"* → [[Fase_3.7_Resolucion_Problemas#E2 · No hay ping entre el servidor y el cliente|caso E2]]
> > · *"No encuentra el `Endpoint`"* → [[Fase_3.7_Resolucion_Problemas#E4 · El cliente no encuentra el Endpoint|caso E4]]
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
> [!success] ▶️ **AHORA SÍ: activa el túnel en el cliente**
> Los dos extremos ya se conocen. Ve a la aplicación WireGuard de tu PC físico y pulsa **`Activar`**.
>
> El indicador pasa a **verde** y aparecen contadores de tráfico. Si no cambia nada, revisa el [[Fase_3.7_Resolucion_Problemas]].
>
> **El orden importa y es el mismo siempre:** primero se configuran los dos lados, después se levanta. Un túnel activado a medias no da error — simplemente no pasa nada por él.
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

### 🔒 ¿Y cerrar el acceso directo por `10.10.10.10`?

> [!info] Aquí no. Eso es hardening, y tiene su fase
> El túnel ya funciona y lo has verificado con el `latest handshake`. **Ese era el objetivo de esta fase y está cumplido.**
>
> Cerrar el SSH directo para que solo se pueda entrar por el túnel es **endurecimiento del servidor**, y se hace en la **Auditoría Final**, junto con el firewall `ufw` y el resto del cierre de seguridad. Por tres motivos:
>
> 1. **Vas a necesitar administrar el servidor durante cinco fases más.** Cerrarlo ahora te complica todo el camino que queda.
> 2. **Si pierdes el túnel, te quedas fuera.** Basta con restaurar una instantánea, cambiar de cliente o equivocarte en una llave. Con cinco fases por delante, eso es una tarde perdida.
> 3. **Un servidor se endurece cuando está terminado**, no a mitad de construcción. Igual que no se pone la alarma en una casa a la que todavía le faltan puertas.
>
> Lo verás completo en la Auditoría Final: cómo se hace, cómo se comprueba **antes** de cerrar la sesión actual, y cómo revertirlo si algo sale mal.



---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.5_Fundamento_Teorico]] | [[Fase_3]] | [[Fase_3.7_Resolucion_Problemas]] |
