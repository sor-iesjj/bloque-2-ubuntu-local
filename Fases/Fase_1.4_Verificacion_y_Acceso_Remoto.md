## ✅ Fase 1.4: Verificación y Acceso Remoto

### Dejar de creer y empezar a comprobar

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~45 min
> **Requisitos:** [[Fase_1.3_Instalar_Ubuntu_Server]] terminada, servidor arrancado

---

> [!abstract] 📋 Qué se te evalúa en esta sub-fase
> **Resultado de Aprendizaje — `RA.01`** *(35 % del módulo · UD1-UD4)*
> *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | Los tres `ping` del Paso 1 y la conexión SSH del Paso 2 |
> | `CE.01.e` | Se han seleccionado los componentes a instalar. | Comprobar que OpenSSH está presente y escuchando, y saber qué hacer si no |
>
> Este `CE.01.i` es, de los nueve del `RA.01`, el que más directamente se comprueba: **o responde el ping, o no responde.**

---

> [!important] 📹 Obligaciones de grabación
> 1. **Sin grabar:** léete el procedimiento y **crea vacía** la entrada `v1-fase-1-4-verificacion-y-acceso-remoto.md`.
> 2. **Arranca OBS y preséntate**, mostrando algo que demuestre que eres tú.
> 3. **Graba todo**, incluidas las pantallas de tu ordenador anfitrión, no solo la VM.
> 4. **Timestamps** en la descripción.
> 5. Vídeo: `V1 · Fase 1.4 — Verificación y Acceso Remoto`, playlist **`B2_Ubuntu_Local`** (No listado). **~8-10 min.**
> 6. El enlace del vídeo va **dentro** de tu entrada de apuntes.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de la 1.3
> Tienes Ubuntu Server instalado y arrancando. Has tomado una docena de decisiones en el instalador y **crees** que todas se aplicaron.

> [!warning] El problema
> Creer no es saber. Un servidor puede arrancar perfectamente y tener la red mal, el servicio caído o una tarjeta que no existe. **Nada de eso se ve mirando la pantalla de login.** Y si no lo detectas ahora, lo detectarás tres fases más adelante, cuando el dominio no arranque y no sepas por qué.

> [!success] Objetivo de esta sub-fase
> Comprobar, **con pruebas y no con confianza**, que el servidor tiene sus dos tarjetas bien, sale a Internet y es alcanzable desde tu ordenador. Y dar el salto que cambia cómo trabajas el resto del curso: **administrarlo por SSH desde tu propia terminal.**

> [!tip] Hoja de ruta
> 1. Las tres comprobaciones de red
> 2. Entrar por SSH
> 3. Anotar el dominio del proyecto
> 4. Ejercicio: verificar tu red desde fuera con APIs
>
> **Siguiente:** Fase 2 — Purga y Preparación del Entorno.

---

### 📚 Fundamento Teórico

> [!abstract] 1. Verificar desde dentro vale menos que verificar desde fuera
> Un servidor te dirá siempre lo que **él cree** de sí mismo. Si su configuración está mal, te mentirá con toda la convicción del mundo. Por eso las comprobaciones que valen son las que se hacen **desde el otro lado**: desde el cliente, desde el host, desde un servicio externo.
>
> Es la diferencia entre *"el panel dice que está conectado"* y *"le he hecho ping y contesta"*.

> [!important] 2. Por qué SSH y no la ventana de VirtualBox
> La consola de VirtualBox es una **pantalla de emergencia**. Sirve cuando la red está caída y no hay otra forma de entrar. Para trabajar a diario es pésima: no se copia ni se pega bien, la letra es diminuta —sobre todo en pantallas 4K—, y solo tienes una.
>
> **Con SSH trabajas desde la terminal de tu propio ordenador**: tu fuente, tu tamaño, varias pestañas, copiar y pegar de verdad, y el historial de comandos a mano. Es como se administran los servidores en el mundo real, donde además el servidor está a cientos de kilómetros y no hay ninguna ventana que mirar.

> [!note] 3. Qué es una API y por qué la usa un administrador
> Una **API** es una web hecha para que la consulte un programa en vez de una persona: en lugar de una página con colores, devuelve **datos limpios** en formato JSON.
>
> ¿Para qué la quiere un administrador? Para **comprobar desde fuera lo que desde dentro no puede ver**. Y esa diferencia, cuando aparece, es justo donde está el problema que llevas dos horas buscando. Se consultan con `curl`, sin programar y sin instalar nada.

### 📖 Diccionario

> [!quote] Cinco palabras
> - **`ip a`:** comando que lista las interfaces de red y sus direcciones.
> - **ICMP:** el protocolo que usa `ping`. Comprueba alcance, no servicios.
> - **SSH (Secure Shell):** protocolo para abrir una sesión de terminal cifrada en una máquina remota. Puerto 22.
> - **Huella del servidor (fingerprint):** identificador criptográfico que tu cliente guarda la primera vez, para detectar suplantaciones después.
> - **API:** interfaz pensada para ser consultada por programas, que devuelve datos estructurados.

---

### 🛠️ Procedimiento

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. Ten a mano **dos ventanas**: la VM y una terminal de tu ordenador.
> 3. Ten OBS listo.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso 1: Las tres comprobaciones
>
> **a) Dentro de la VM — ¿están las dos tarjetas?**
> ```bash
> ip a
> ```
> Tienen que salir **tres** interfaces:
> - `lo` — la de bucle local, `127.0.0.1`
> - `enp0s3` — la NAT, con una IP tipo `10.0.2.15` puesta por DHCP
> - `enp0s8` — la sólo-anfitrión, con **`10.10.10.10`**
>
> **Si solo salen dos**, falta la sólo-anfitrión y hay que arreglarlo antes de seguir → [[Fase_1.E_Cuando_Algo_Falla]].
>
> **b) Dentro de la VM — ¿sale a Internet?**
> ```bash
> ping -c4 google.com
> ```
> Cuatro respuestas sin pérdida. Esto prueba la NAT **y** que la resolución de nombres funciona.
>
> **c) Desde tu ordenador — ¿alcanza al servidor?**
> - **Windows:** `Windows + R` → `cmd`
> - **Mac / Linux:** abre `Terminal`
>
> ```
> ping 10.10.10.10
> ```
>
> > [!warning] ⚠️ Esto se hace en el ordenador que ejecuta VirtualBox. En ningún otro.
> > La red sólo-anfitrión **vive dentro del anfitrión**. No sale por el Wi-Fi, no la ve el router, no existe fuera de esa máquina. Si intentas este ping desde otro ordenador de la misma red, **no va a funcionar nunca**, por muy bien que lo tengas todo.
>
> > [!success] ✅ Si las tres responden, la red está bien de verdad
> > Y no porque un panel lo diga: porque lo has probado desde los dos lados.

> [!example] Paso 2: Entrar por SSH — el salto de esta fase
> Desde la terminal de tu ordenador (el `cmd` de Windows sirve):
>
> ```
> ssh boochan@10.10.10.10
> ```
>
> 1. La primera vez avisa de que no conoce la **huella** del servidor y pregunta si confías. Escribe `yes` y `Enter`. *(Es la misma idea que viste con GitHub en la Fase 0.2.1: tu cliente guarda la huella para detectar si algún día alguien suplanta al servidor.)*
> 2. Escribe la contraseña. **No se ve nada mientras escribes** — es normal, no está colgado.
> 3. Si aparece el prompt `boochan@UbuntuServer:~$`, **estás dentro**.
>
> A partir de aquí, **trabaja siempre así**. La ventana de VirtualBox queda para arrancar la máquina y para emergencias.
>
> > [!bug] Si dice `Connection timed out` o `Connection refused`
> > Casi seguro que OpenSSH no está instalado — la casilla del paso 9 de la 1.3. Compruébalo **en la VM**:
> > ```bash
> > systemctl status ssh
> > ```
> > Si responde `Unit ssh.service could not be found`, ve a [[Fase_1.E_Cuando_Algo_Falla]]: tiene arreglo en dos comandos.

> [!example] Paso 3: El dominio de todo el proyecto
> No hay que ejecutar nada. Es información que debes **anotar en tu entrada**, porque la usarás en la Fase 2 (`/etc/hosts`) y sobre todo en la Fase 4 (creación del dominio):
>
> | Concepto | Valor en BoochanV1 |
> | :--- | :--- |
> | **Nombre NetBIOS** | `BOOCHANLAB` |
> | **Realm (dominio completo)** | `BOOCHANLAB.LOCAL` |
> | **IP del servidor** | `10.10.10.10` |
> | **IP de tu ordenador en esa red** | `10.10.10.1` |
> | **Reservada para el futuro cliente Windows 11** | `10.10.10.20` |
>
> > [!info] ¿Por qué `.LOCAL` y no un dominio real de Internet?
> > En BoochanV2/V3 se usa un dominio real (`BOOCHAN.SPACE`) porque el servidor tiene IP pública. Aquí no: tu servidor vive dentro de tu portátil, en una red invisible desde fuera. Un dominio de Active Directory privado **no necesita ser resoluble en Internet**, y usar terminaciones reservadas como `.LOCAL` es práctica estándar en redes internas de empresa — precisamente para dejar claro que ese nombre nunca debe salir a Internet.

> [!example] 🔌 Paso 4 — EJERCICIO: comprueba tu red desde fuera
> Hasta aquí has comprobado tu red **con tus propias herramientas**. Ahora vas a contrastarla con fuentes **externas e independientes**, que es como se hace de verdad.
>
> **a) Verifica tu cálculo de subred.** Tu red es `10.10.10.0/24`.
> Primero, **a mano y sin ayuda**, escribe en tu entrada: máscara decimal, dirección de red, broadcast, número de hosts asignables, primero y último. *(Si ya lo hiciste en la 1.2, compara con lo que escribiste entonces.)*
>
> Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.10.10.0/24"
> ```
> Si no coincide, **no borres tu respuesta**: déjala y explica en el vídeo dónde te equivocaste. Eso enseña más que acertar.
>
> **b) La IP pública: aquí cae el NAT.** Desde **dentro de la VM**:
> ```bash
> curl "https://api.ipify.org?format=json"
> ```
> Y ahora lo mismo **desde tu ordenador anfitrión**, en otra terminal.
>
> > [!danger] 🤔 Para y explícalo antes de seguir
> > **Sale la MISMA IP en los dos sitios.** Tu VM y tu ordenador comparten la salida a Internet.
> > ¿Por qué? Porque el adaptador **NAT** que configuraste en la 1.2 hace exactamente eso: la VM sale **disfrazada de tu ordenador**. Para Internet, tu servidor no existe como máquina independiente.
> > **Dilo en voz alta:** ¿podría alguien de fuera conectarse a tu servidor con esa IP? ¿Por qué no?
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Coincidió tu cálculo de subred con el de la API? Si no, ¿en qué fallaste?
> > 2. ¿Cuál es la IP privada de tu servidor y cuál la pública? ¿Por qué no son la misma?
> > 3. ¿Por qué una comprobación hecha **desde el propio servidor** vale menos que una hecha desde fuera?
> > 4. ¿Qué ventaja concreta le has notado a trabajar por SSH frente a la ventana de VirtualBox?
>
> > [!note] 📌 Para saber más
> > La teoría completa está en **B1.9b — Verificar tu red con APIs públicas** del Bloque 1. Aquí lo aplicas a tu servidor de verdad.
> > Y explica por qué en las versiones **cloud** (V2 y V3) cambia todo: allí el servidor **sí** tiene IP pública propia y **sí** se puede alcanzar desde fuera. Con eso vienen las ventajas… y los problemas de seguridad.

---

### 🚩 Preguntas críticas

> [!help] Autoevaluación
> 1. ¿Qué diferencia hay entre un hipervisor de Tipo 1 (Azure, AWS) y uno de Tipo 2 (VirtualBox)?
> 2. ¿Por qué la VM necesita dos adaptadores en lugar de uno?
> 3. Si el Adaptador 2 estuviera en modo **Red interna** en vez de sólo-anfitrión, ¿respondería el `ping` desde tu ordenador? Razónalo.
> 4. ¿Por qué el dominio termina en `.LOCAL` y no en `.COM` o `.ES`?
> 5. 🔬 **Reto:** apaga la VM, entra en `Configuración → Sistema → Placa base` y mira cuánta RAM tiene. Súbela a 3072 MB, arranca y ejecuta `free -h`. Compara con lo que había antes. Vuelve a dejarla en 2048 MB hasta que la Fase 4 lo pida de verdad.

---

### ✅ Checklist de la 1.4

- [ ] `ip a` muestra `lo`, `enp0s3` y `enp0s8` con `10.10.10.10`.
- [ ] `ping google.com` responde desde la VM.
- [ ] `ping 10.10.10.10` responde desde el ordenador anfitrión.
- [ ] Conexión SSH establecida desde la terminal del anfitrión.
- [ ] `BOOCHANLAB` y `BOOCHANLAB.LOCAL` anotados.
- [ ] Ejercicio de las APIs hecho, con el cálculo de subred **escrito antes** de consultarla.
- [ ] Las 5 preguntas críticas respondidas en la entrada.

---

### ✅ Entregables

> [!abstract] Qué tienes que tener al acabar
> | Entregable | Dónde | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `.../v1-fase-1-4-verificacion-y-acceso-remoto.md` | Las comprobaciones + **respuestas a las preguntas del ejercicio y a las 5 críticas** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` | `V1 · Fase 1.4 — Verificación y Acceso Remoto`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes | La entrada subida con `add` → `commit` → `push` |
>
> > [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> > Son la parte que demuestra que has entendido lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**. Una sub-fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.
>
> > [!success] 🎯 Criterio de éxito
> > Abro tu repositorio, encuentro las cuatro entradas de la Fase 1, y en cada una está: qué has hecho, qué has entendido, qué dudas te quedaron y el enlace al vídeo donde se te ve haciéndolo.

> [!summary] 🎓 Qué has aprendido
> A no fiarte de lo que dice un panel, a comprobar desde los dos lados, y a administrar un servidor como se administra de verdad: desde tu terminal, no desde una ventana.
>
> **Siguiente:** Fase 2 — Purga y Preparación del Entorno, donde limpiarás el servidor de software que estorba y le darás su identidad de dominio en `/etc/hosts`.
>
> ¿Algo no ha salido? → [[Fase_1.E_Cuando_Algo_Falla]]
