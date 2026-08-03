## Fase 1 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos de las cuatro partes, con su diccionario.

---

> [!tip] 💡 Cómo usar este apartado
> Está ordenado igual que el procedimiento: **lee el bloque de la parte que vayas a hacer** y sigue. No hace falta leerlo entero de golpe.

---

## Virtualización: el hipervisor y tu hardware

*(necesario para [[Fase_1.6.a_Procedimiento_Maquina_Virtual]])*

> [!abstract] 1. VirtualBox es un hipervisor de Tipo 2
> Un **hipervisor** es el software que reparte los recursos físicos entre varias máquinas virtuales. Hay dos familias:
> - **Tipo 1 ("bare metal"):** se instala directamente sobre el hardware, sin sistema operativo debajo. Es lo que usan Azure y AWS en sus centros de datos.
> - **Tipo 2 ("hosted"):** se instala **como un programa más** dentro de un sistema operativo ya existente. **VirtualBox es de Tipo 2.**
>
> Por eso lo abres y lo cierras como cualquier aplicación, y por eso consume RAM y CPU de tu equipo mientras la VM está encendida.

> [!warning] 2. Tú eres el proveedor
> En la nube, Azure o AWS garantizan la electricidad, la refrigeración y que el hardware no falle. **En local ese proveedor eres tú.** Si el portátil se queda sin batería o cierras la tapa, tu "datacenter" se apaga entero. Detrás de cada nube hay, al final, hardware físico que alguien mantiene encendido.

> [!important] 3. Dimensionar es decidir, no poner el máximo
> Esta VM comparte RAM y CPU con **todo lo demás** que tengas abierto en un portátil de aula, que puede tener 8 GB en total. Ser realista aquí es parte del oficio:
> - No asumas que tienes 16 GB libres solo para la práctica.
> - En la **Fase 4** instalarás Samba AD DC, que por sí solo pide entre 2 y 4 GB para ir con soltura.
> - Vale más una VM modesta que arranca, que una "de lujo" que deja el portátil congelado y no te deja ni escribir el siguiente comando.

### 📖 Diccionario

> [!quote] Cinco palabras
> - **Hipervisor de Tipo 2:** software de virtualización que corre como una aplicación sobre un sistema operativo ya instalado.
> - **Host (anfitrión):** tu ordenador físico, el que ejecuta VirtualBox.
> - **Guest (invitado):** la máquina virtual que corre dentro.
> - **ISO:** un fichero que contiene la copia exacta de un disco de instalación.
> - **Disco de asignación dinámica:** el fichero del disco virtual empieza pequeño y **crece según se usa**, hasta un máximo fijado.

---

---

## Las redes virtuales de VirtualBox

*(necesario para [[Fase_1.6.b_Procedimiento_Red_Laboratorio]])*

> [!note] 1. Los modos de red de VirtualBox
> Cada tarjeta virtual se puede conectar a un "modo" distinto. Usamos dos, y entender la diferencia es el núcleo de esta sub-fase:
>
> | Modo | Qué hace | Analogía |
> | :--- | :--- | :--- |
> | **NAT** | Da salida a Internet compartiendo la conexión de tu ordenador. La VM puede salir; nadie de fuera puede entrar a ella. | La VM llama por teléfono usando tu línea: puede llamar hacia fuera, pero nadie puede llamarla a ella — solo a tu número. |
> | **Sólo anfitrión** *(host-only)* | Crea una red privada **entre tu ordenador y las VMs**, aislada de Internet y de la red del instituto. | Un cable de red que une tu PC y tus máquinas virtuales dentro de una habitación cerrada con llave. Los de fuera no entran; los de dentro se ven perfectamente. |
> | *(Existe también **Red interna**)* | *Conecta VMs entre sí **sin** que el host participe.* | *Un cable entre dos invitados, desenchufado del anfitrión.* **No la usamos**: en la 1.4 necesitamos que tu ordenador haga ping al servidor. |
>
> **Por qué las dos a la vez:** la NAT le da Internet (para `apt`), y la sólo-anfitrión le da una red privada y estable donde más adelante conectarás también el Windows 11. Así servidor y cliente se ven entre sí sin exponer nada a la Wi-Fi del centro.

> [!important] 2. Por qué NO usamos el `192.168.56.0/24` que trae VirtualBox
> VirtualBox crea de fábrica una red sólo-anfitrión en el rango `192.168.56.0/24`. **Vamos a usar otro a propósito:** `192.168.x.x` es exactamente el rango que tienen los routers domésticos, y tarde o temprano un alumno se lía entre "la red de mi casa" y "la red de mi laboratorio". Con `10.10.10.0/24` esa confusión no puede ocurrir.

> [!warning] 3. Por qué desactivamos el DHCP
> Un servidor **no puede tener una IP que cambie**. Todo lo que construyas encima — el dominio de la Fase 4, el DNS, los recursos compartidos — apunta a una dirección concreta. Si un DHCP se la cambia un lunes por la mañana, se cae todo y no sabes por qué. Por eso la red del laboratorio va sin DHCP y la IP del servidor se pone a mano.

### 📖 Diccionario

> [!quote] Cinco palabras
> - **NAT (Network Address Translation):** técnica que permite a varias máquinas salir a Internet compartiendo una sola dirección pública.
> - **Adaptador sólo-anfitrión:** tarjeta virtual que crea una red privada entre el host y sus VMs, sin salida a Internet.
> - **DHCP:** servicio que reparte direcciones IP automáticamente. Cómodo para clientes, peligroso para servidores.
> - **Máscara de subred:** define qué parte de la IP identifica la red y cuál el equipo. `255.255.255.0` = `/24`.
> - **Segmento:** conjunto de máquinas que se ven directamente entre sí sin pasar por un router.

---

---

## El instalador y el mapa del teclado

*(necesario para [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]])*

> [!abstract] 1. Un teclado no envía letras
> Envía **números de tecla**. Es el sistema operativo quien decide qué carácter significa cada número, según la *distribución* configurada. Por eso, con la distribución equivocada, las letras y los números salen bien (coinciden en casi todas) pero **los símbolos no**: `@`, `;`, `-`, `/` cambian de sitio.
>
> Guárdate esto: cuando alguien te diga *"se me ha roto el teclado"*, casi nunca es el teclado.

> [!info] 2. Por qué la IP se pone durante la instalación
> El instalador de Ubuntu Server (**Subiquity**) escribe la configuración de red directamente en `/etc/netplan/`. Hacerlo aquí te ahorra editar ficheros nada más arrancar. Si por lo que sea no puedes, se puede hacer después a mano — está explicado en [[Fase_1.7_Resolucion_Problemas]].

> [!important] 3. `Ubuntu Server` frente a `minimized`
> El instalador te ofrece una versión **minimizada**, pensada para contenedores y despliegues automatizados: trae menos herramientas y da problemas cuando luego necesitas diagnosticar algo a mano. **Elige la normal.**

### 📖 Diccionario

> [!quote] Cinco palabras
> - **Subiquity:** el instalador de Ubuntu Server. El de las pantallas azules.
> - **Distribución de teclado:** el mapa que traduce tecla pulsada → carácter.
> - **LVM:** capa que permite redimensionar particiones sin reinstalar.
> - **FQDN / hostname:** el nombre por el que se identifica la máquina en la red.
> - **OpenSSH Server:** el servicio que permite entrar al servidor desde otro ordenador.

---

---

## Verificar desde fuera, y por qué SSH

*(necesario para [[Fase_1.6.d_Procedimiento_Verificacion_SSH]])*

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.4_Donde_Estamos]] | [[Fase_1]] | [[Fase_1.6.a_Procedimiento_Maquina_Virtual]] |
