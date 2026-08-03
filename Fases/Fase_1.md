---
Práctica: V1.F1
Bloque: 02_Ubuntu_Local
Version: BoochanV1
RA: RA1
CE: CE.01.a, CE.01.b, CE.01.c, CE.01.e, CE.01.g, CE.01.i
Playlist: B2_Ubuntu_Local
Vídeo: V1 · Fase 1 — Infraestructura Virtual Local (VirtualBox)
---

## 🏗️ Fase 1: Infraestructura Virtual Local (VirtualBox)

### Infraestructura de Servidores en tu propio ordenador

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 - 2 horas (descarga de la ISO incluida, teoría + práctica + troubleshooting)
> **Requisitos:** VirtualBox instalado en el equipo · ~2 GB de RAM libres · ~20 GB de disco libres · ISO de Ubuntu Server 26.04 LTS

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA1`:** *Instala sistemas operativos en red, describiendo sus características e interpretando la documentación técnica.*
>
> Esta fase toca **6 de los 9 criterios** del RA1. Estos son, y dónde se demuestra cada uno:
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.a` | Se ha realizado el estudio de compatibilidad del sistema informático. | Paso 3: dimensionar RAM/CPU/disco según el equipo real del aula, y comprobar la virtualización (VT-x/AMD-V) |
> | `CE.01.b` | Se han diferenciado los modos de instalación. | Paso 3: decidir entre **instalación desatendida** (la que VirtualBox ofrece) e **instalación manual**, y justificar por qué eliges la manual |
> | `CE.01.c` | Se ha planificado y realizado el particionado del disco del servidor. | Paso 5.7: `Use an entire disk` con LVM sobre el disco virtual de 20 GB |
> | `CE.01.e` | Se han seleccionado los componentes a instalar. | Paso 5.4 y 5.9-5.10: `Ubuntu Server` frente a la versión *minimized*, marcar OpenSSH, no instalar snaps |
> | `CE.01.g` | Se han aplicado preferencias en la configuración del entorno personal. | Paso 5.1-5.3 y 5.8: idioma, teclado español, hostname y perfil de usuario |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | Pasos 7 y 8: `ping` a Internet, `ping 10.10.10.10` desde tu host y verificación con APIs externas |
>
> **Los 3 que NO se evalúan aquí** (para que sepas que no se te han olvidado): `CE.01.d` sistemas de archivos y `CE.01.h` actualización del sistema se trabajan en la **Fase 2**; `CE.01.f` automatización de instalaciones tiene práctica propia en el **Bloque 1 (B1.12, autoinstall)**.
>
> > [!note] 🎓 ¿Y esto para qué me lo cuentas?
> > Porque tienes derecho a saber **por qué se te evalúa lo que se te evalúa**. Estos códigos no me los invento: salen de la programación didáctica del módulo, que a su vez desarrolla el **Real Decreto 1691/2007** y la **Orden de 29 de julio de 2009**. Un RA se aprueba demostrando **más del 50 % de sus criterios**, y todos pesan igual.
> > Traducido: si haces la fase entera pero te saltas el `ping` del Paso 7, no es que "pierdas puntos" — es que hay un criterio concreto, con nombre y código, que no has demostrado.

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-1-infraestructura-virtual-local-virtualbox.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 1 de Boochan V1 — Infraestructura Virtual Local (VirtualBox)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 1 — Infraestructura Virtual Local (VirtualBox)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 Objetivos de la fase

Al terminar esta fase serás capaz de:

- [ ] Explicar la diferencia entre virtualizar en la nube (BoochanV2/V3) y virtualizar en local con VirtualBox.
- [ ] Instalar o verificar VirtualBox en tu equipo del aula.
- [ ] Crear una máquina virtual dimensionada de forma realista para un portátil compartido.
- [ ] Configurar **dos adaptadores de red** distintos en la VM y explicar para qué sirve cada uno.
- [ ] Instalar Ubuntu Server 26.04 LTS desde cero, incluyendo una **IP estática** en la red interna.
- [ ] Conocer el nombre de dominio (`BOOCHANLAB.LOCAL`) que usará todo el proyecto BoochanV1.
- [ ] Verificar que la VM arranca, tiene red y responde a `ping` desde tu propio ordenador (el host).

---

### 🎯 ¿Dónde Estamos?

> [!info] El Punto de Partida
> No vienes de una fase anterior — esta es la base. En BoochanV2 y BoochanV3 alquilabas un servidor en la nube (Azure/AWS). En **BoochanV1** vas a construir el mismo servidor, pero **dentro de tu propio ordenador**, usando un programa llamado VirtualBox que crea "ordenadores dentro del ordenador".

> [!warning] El Problema
> No siempre hay presupuesto (ni conexión a Internet fiable en el aula) para tener una cuenta cloud por alumno. Además, entender cómo funciona la virtualización *local* — la que corre en tu propio hardware — es la base sobre la que luego se entiende la virtualización *en la nube*. Antes de "alquilar" un ordenador virtual a Microsoft o Amazon, tienes que entender cómo se crea uno tú mismo.

> [!success] Objetivo de esta Fase
> Crear una **máquina virtual en VirtualBox** que aloje Ubuntu Server 26.04 LTS, con dos tarjetas de red (una para salir a Internet, otra para hablar con la futura VM cliente de Windows 11) y una dirección IP fija en `10.10.10.10`. Este servidor será, en las próximas fases, tu controlador de dominio Active Directory.

> [!tip] Hoja de Ruta
> 1. Verificar o instalar VirtualBox en tu equipo
> 2. Descargar la ISO de Ubuntu Server 26.04 LTS
> 3. Crear la máquina virtual con RAM, CPU y disco dimensionados para un portátil de aula
> 4. Configurar dos adaptadores de red: NAT (Internet) + Red Solo-Anfitrión (red aislada servidor↔cliente↔host)
> 5. Instalar Ubuntu Server desde la ISO, con IP estática `10.10.10.10/24`
> 6. Conocer el nombre de dominio de todo el proyecto: `BOOCHANLAB.LOCAL`
> 7. Verificar que la VM arranca, tiene red, y responde a `ping` desde tu ordenador
>
> **Resultado Final:** Un servidor virtual local, listo, accesible desde tu equipo, y aislado de la red del instituto.
> **Siguiente:** Fase 2 (Purga y Preparación del Entorno) — limpiaremos el servidor de software innecesario y le daremos su identidad de dominio dentro de `/etc/hosts`.

---

### 📚 Fundamento Teórico Avanzado

> [!info] ¿Por qué ahora en local, si BoochanV2/V3 usaban la nube?
> En la nube "alquilas" una porción de un superordenador de Microsoft o Amazon. En local, **tú eres el superordenador**: tu portátil ejecuta un programa (VirtualBox) que reparte su propia CPU, RAM y disco entre tu sistema operativo normal (el **host**, anfitrión) y uno o varios ordenadores virtuales (los **guest**, invitados). El concepto de "servidor" es exactamente el mismo — solo cambia dónde vive físicamente.

> [!abstract] 1. VirtualBox: un Hipervisor de Tipo 2
> Ya conoces el concepto de **Hipervisor** de las fases cloud: el software que reparte los recursos físicos entre varias máquinas virtuales. Existen dos tipos:
> - **Tipo 1 ("bare metal"):** se instala directamente sobre el hardware, sin sistema operativo por debajo. Es lo que usan Azure y AWS en sus centros de datos — máximo rendimiento.
> - **Tipo 2 ("hosted"):** se instala **como un programa más** dentro de un sistema operativo ya existente (Windows, macOS, Linux). **VirtualBox es de Tipo 2.** Por eso puedes abrirlo y cerrarlo como cualquier otra aplicación, y por eso consume RAM y CPU de tu equipo mientras está encendida la VM.

> [!warning] 2. Tu Responsabilidad como "Administrador de tu propio Datacenter"
> En la nube, el proveedor (Azure/AWS) garantiza la electricidad, la refrigeración y que el hardware físico no falle. **En local, ese proveedor eres tú.** Si tu portátil se queda sin batería, se cuelga, o cierras la tapa, tu "datacenter" se apaga por completo. Es una buena lección: entender que detrás de cada nube hay, en el fondo, hardware físico real que alguien mantiene encendido.

> [!important] 3. Dimensionado Realista: no es tu portátil personal, es un equipo de aula
> A diferencia de un servidor cloud dedicado, esta VM va a compartir RAM y CPU con **el resto de programas abiertos en un portátil de aula** (que puede tener solo 8 GB de RAM total, usado también por otros alumnos en turnos distintos). Hay que ser realista:
> - No asumas que tienes 16 GB libres solo para la práctica.
> - Ten en cuenta que en la **Fase 4** instalarás Samba AD DC, que por sí solo necesita entre 2 y 4 GB de RAM para funcionar con soltura.
> - Es mejor una VM modesta que arranca sin problemas, que una VM "de lujo" que deja el portátil congelado y no puedes ni escribir el siguiente comando.

> [!note] 4. Redes Virtuales de VirtualBox — la parte más nueva para ti
> VirtualBox permite conectar cada tarjeta de red virtual de la VM a distintos "modos". Para este proyecto usamos dos, y es importante que entiendas la diferencia (nadie te lo ha explicado antes, así que vamos con un ejemplo sencillo):
>
> | Modo | ¿Qué hace? | Analogía |
> | :--- | :--- | :--- |
> | **NAT** | Le da a la VM salida a Internet, compartiendo la conexión de tu propio ordenador. La VM puede salir a "hablar" con Internet, pero nadie de fuera puede entrar directamente a la VM. | Es como si la VM llamara por teléfono desde tu casa usando tu línea: puede llamar hacia fuera, pero nadie puede llamarla directamente a ella, solo a tu número (el tuyo, el del host). |
> | **Red Solo Anfitrión (Host-Only)** | Crea una red privada **entre tu ordenador (host) y las VMs**, totalmente aislada de Internet y de la red del instituto. Tu equipo y tus VMs se ven entre sí como si estuvieran conectados por un cable de red directo. | Es como tender un cable de red solo entre tu ordenador y tus máquinas virtuales, dentro de una habitación cerrada con llave: nadie del pasillo (la red del instituto) puede entrar, pero todos los que están dentro de la habitación (tu PC + tus VMs) se ven perfectamente. |
> | *(Existe también "Red Interna"* | *conecta solo VMs entre sí, sin que el host participe. No la usamos aquí porque en el Paso 7 necesitamos que tu propio ordenador pueda hacer ping al servidor.)* | *(Sería como un cable que conecta dos máquinas invitadas, pero desconectado del ordenador anfitrión.)* |
>
> **Por qué usamos las dos a la vez:** la VM necesita **ambas** tarjetas de red simultáneamente. La NAT le da Internet (para hacer `apt update`, descargar paquetes...). La Solo-Anfitrión le da una red privada y estable donde, más adelante, también conectarás la VM cliente de Windows 11 — así servidor y cliente se ven entre sí, sin exponer nada a la red Wi-Fi del instituto.

> [!important] 5. ¿Por qué un dominio `.LOCAL` y no un dominio real de Internet?
> En BoochanV2/V3 usabais un dominio real (`BOOCHAN.SPACE`) porque el servidor tenía IP pública y, en teoría, podría ser accedido desde Internet. Aquí no: tu servidor **vive dentro de tu portátil**, en una red privada e invisible desde fuera. Un dominio de Active Directory privado **no necesita ser resoluble en Internet** — de hecho, usar terminaciones reservadas como `.LOCAL` es una práctica estándar en redes internas de empresa, precisamente para dejar claro que ese nombre nunca debe salir a Internet ni intentar registrarse como dominio público. Por eso, en todo el itinerario BoochanV1 usaremos:
> - **Nombre NetBIOS:** `BOOCHANLAB`
> - **Realm (dominio completo):** `BOOCHANLAB.LOCAL`
>
> Guarda estos dos nombres — los usarán todas las fases siguientes, especialmente la Fase 4 (Aprovisionamiento del Dominio).

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología Profesional VirtualBox
> - **Hipervisor de Tipo 2:** Software de virtualización que corre como una aplicación más sobre un sistema operativo ya instalado (a diferencia del Tipo 1, que corre directamente sobre el hardware).
> - **Host:** Tu ordenador físico, el que ejecuta VirtualBox.
> - **Guest (invitado):** La máquina virtual que corre dentro de VirtualBox (en este caso, Ubuntu Server).
> - **ISO:** Un archivo que contiene una copia exacta de un disco de instalación (como un DVD, pero en un solo archivo). Se usa para "meter" el instalador de Ubuntu en la unidad de CD/DVD virtual de la VM.
> - **VDI (Virtual Disk Image):** El formato de disco duro virtual propio de VirtualBox — un archivo en tu disco que la VM ve como si fuera un disco duro físico.
> - **Disco de asignación dinámica:** El fichero del disco virtual empieza pequeño y **crece según se necesita**, hasta un máximo fijado. Así no reservas de golpe todo el espacio si aún no lo usas.
> - **Adaptador de Red Solo Anfitrión (Host-Only Adapter):** Una tarjeta de red virtual que crea una red privada entre el host y sus VMs, sin salida a Internet ni a la red física del instituto.
> - **NetBIOS / Realm:** El "nombre corto" (NetBIOS, máx. 15 caracteres, en mayúsculas) y el "nombre completo" (Realm, tipo dominio de Internet) que identifican a un dominio Active Directory.

---

### 🛠️ Procedimiento Práctico (BoochanV1)

> [!danger] ⚠️ LÉEME ANTES DE EMPEZAR: permisos de administrador en el equipo del aula
> Los equipos del aula normalmente **no os dan permisos de administrador sobre Windows/macOS**. Instalar VirtualBox requiere permisos de administrador del sistema operativo anfitrión (no basta con ser "usuario" del equipo).
> - **Si VirtualBox ya está instalado** en el equipo (pregunta al profesor o comprueba si aparece en el menú de aplicaciones): perfecto, salta directamente al Paso 2.
> - **Si VirtualBox NO está instalado y no tienes permisos de administrador:** esta práctica **no es viable en ese equipo**. No intentes saltarte los permisos ni usar instaladores "portables" no autorizados. Avisa al profesor: la solución pasa por que el departamento de informática del centro lo instale de antemano en las imágenes de los equipos del aula, o que se use un equipo personal con permisos completos.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-1-infraestructura-virtual-local-virtualbox.md`) con su estructura, vacía.
> 2. **Léete los 8 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Descarga e instalación de VirtualBox (solo si NO está ya instalado)
> 1. Desde el navegador, entra en la web oficial: `virtualbox.org` → apartado **Downloads**.
> 2. Descarga el instalador correspondiente a tu sistema operativo (Windows, macOS o Linux).
> 3. Ejecuta el instalador con permisos de administrador y sigue el asistente dejando las opciones por defecto (incluye la instalación del **Extension Pack** si el asistente lo ofrece — añade soporte USB 2.0/3.0 y otras extensiones, aunque no es imprescindible para este proyecto).
> 4. Abre VirtualBox al terminar. Si ves la ventana del "VirtualBox Manager" (una lista vacía de máquinas virtuales), la instalación ha ido bien.
>
> > [!tip] 💡 ¿Qué versión descargar?
> > Usa siempre la versión estable más reciente que ofrezca la web oficial (a fecha de escritura de este manual, la rama 7.x). No hace falta anotar el número de versión exacto para este proyecto.

> [!example] Paso 2: Descarga de la ISO de Ubuntu Server 26.04 LTS
> 1. Entra en `ubuntu.com/download/server`.
> 2. Descarga la imagen **Ubuntu Server 26.04 LTS** (la versión "LTS" — *Long Term Support* — es la que se usa siempre en un entorno de producción o de prácticas serias, porque recibe actualizaciones de seguridad durante años).
> 3. Guarda el archivo `.iso` descargado en una carpeta que recuerdes (por ejemplo, `Descargas` o una carpeta específica del proyecto). Pesa aproximadamente 2-3 GB — la descarga puede tardar según la conexión del aula.
>
> > [!warning] ⚠️ No confundas "Ubuntu Desktop" con "Ubuntu Server"
> > Ubuntu Desktop trae interfaz gráfica y está pensado para uso personal. **Ubuntu Server** es la versión sin escritorio gráfico (headless), pensada para máquinas que dan servicio, como la nuestra. Asegúrate de descargar la palabra "Server" en el nombre del archivo.

> [!example] Paso 3: Creación de la Máquina Virtual
> Con VirtualBox abierto:
> 1. Pulsa **`Nueva`** (o `Machine → New`).
> 2. Rellena el asistente con estos valores:
>
> | Campo | Valor | Por qué |
> | :--- | :--- | :--- |
> | **Nombre** | `UbuntuServer` | Coherencia con V2/V3, facilita seguir el manual |
> | **Carpeta de la máquina** | La que sugiera VirtualBox por defecto | Evita problemas de rutas con espacios o caracteres raros |
> | **Imagen ISO** | Selecciona el `.iso` descargado en el Paso 2 | Es el "disco de instalación" que arrancará la VM |
> | **⚠️ `Omitir instalación desatendida`** | **MARCADA** | **Lee el aviso de abajo. Si no la marcas, esta práctica no te sirve de nada.** |
> | **Tipo** | `Linux` | Familia de sistema operativo del guest |
> | **Versión** | `Ubuntu (64-bit)` | Ubuntu Server 26.04 es de 64 bits |
> | **Memoria base (RAM)** | `2048 MB` (2 GB) | Ver nota de dimensionado abajo |
> | **Procesadores (CPU)** | `2 vCPU` | Suficiente para instalación y prácticas; no bloquea al host |
> | **Tamaño de disco** | `20 GB`, con **`Preasignar tamaño completo` SIN marcar** | 20 GB da margen para sistema, Samba y ficheros de prácticas. Sin preasignar, el fichero crece según se usa |
>
> 3. Antes de crear, revisa el resumen final y pulsa **`Finalizar`**.
>
> > [!danger] ⚠️ MARCA `Omitir instalación desatendida`. Esto es lo que más se falla en esta fase.
> > En cuanto seleccionas la ISO, **VirtualBox 7.x reconoce que es Ubuntu y se ofrece a instalarlo él solo**: te pide un usuario, una contraseña y un nombre de máquina en el propio asistente, y después arranca la VM e instala Ubuntu entero sin que tú toques nada.
> >
> > Suena cómodo. Y para esta práctica es **exactamente lo que no queremos**, por dos motivos:
> > 1. **No aprenderías nada.** Todo el Paso 5 — elegir el teclado, configurar las dos tarjetas de red, poner la IP fija `10.10.10.10`, marcar OpenSSH — lo decidiría VirtualBox por su cuenta, con sus valores. Instalar un sistema operativo en red es literalmente el RA.01 de este módulo: es lo que se evalúa, no se delega.
> > 2. **Te dejaría el servidor mal configurado.** La instalación desatendida deja las **dos** tarjetas en automático (DHCP). Tu servidor se quedaría sin la IP fija `10.10.10.10`, y la Fase 4 (dominio Active Directory) no funciona sin ella.
> >
> > **Dónde está la casilla:** en la primera página del asistente, **`Nombre y sistema operativo`**, justo debajo del selector de la ISO. Se llama `Omitir instalación desatendida` (*Skip Unattended Installation*). **Márcala.** Al hacerlo verás que la página siguiente, la que pedía usuario y contraseña, desaparece del asistente: ya no hace falta, porque esos datos los vas a introducir tú a mano en el Paso 5, dentro del instalador de verdad.
> >
> > 🎥 **Que se te vea marcarla en el vídeo.** Es el detalle que distingue la fase hecha de la fase "instalada sola".
>
> > [!note] 💡 Sobre el disco: ¿y el "VDI de asignación dinámica"?
> > Si has leído otros manuales, verás que hablan de elegir **VDI** y **asignación dinámica**. En el asistente de VirtualBox 7.x **esas dos opciones ya no aparecen**: la página de disco solo te muestra el tamaño y una casilla llamada `Preasignar tamaño completo`. No te has saltado nada — es que VirtualBox ya decide por ti:
> > - **VDI** es el formato por defecto (los otros — VMDK, VHD — solo se eligen si necesitas abrir el disco con VMware o Hyper-V, que no es el caso).
> > - **Dejar `Preasignar tamaño completo` sin marcar ES la asignación dinámica.** Marcarla haría lo contrario: reservar los 20 GB enteros de golpe en tu disco, aunque Ubuntu solo use 6.
> >
> > **🔬 Compruébalo tú, sin fiarte de lo que pone aquí.** Cuando termines de crear la VM (antes de instalar Ubuntu), abre el explorador de archivos de tu ordenador y busca la carpeta de la máquina — es la que te propuso VirtualBox en el primer paso, normalmente `VirtualBox VMs/UbuntuServer/`. Dentro está el fichero `UbuntuServer.vdi`. **Mira lo que ocupa y anótalo en tu entrada.**
> >
> > Dice tener 20 GB. Ocupa unos pocos MB. **Eso es la asignación dinámica**, y lo estás viendo con tus ojos en vez de creértelo.
> >
> > Vuelve a mirar ese mismo fichero **al acabar la fase**, con Ubuntu ya instalado, y anota los dos tamaños. Es la mejor respuesta posible a la pregunta "¿qué es un disco de asignación dinámica?".
> >
> > *(Si además quieres ver el tipo de fichero y el "dinámico vs. fijo" escritos con todas las letras, están en la sección **Herramientas → Medios** del panel izquierdo de la ventana principal de VirtualBox. Ojo: esa parte de la interfaz **cambia de sitio en cada versión** — si no la encuentras donde dice aquí, no te vuelvas loco; el fichero en el explorador te da la misma información y no caduca.)*
>
> > [!important] 💡 Nota de dimensionado: por qué 2 GB de RAM y no más
> > Elegimos **2048 MB** como punto de partida porque es el mínimo cómodo para instalar y usar Ubuntu Server sin servicios adicionales, y porque en un portátil de aula compartido (8 GB totales es habitual) reservar más de golpe puede dejar el equipo sin margen para el resto de aplicaciones del alumno (navegador, editor, la propia VirtualBox...).
> > **Cuando llegues a la Fase 4** (Samba AD DC), es muy probable que necesites subir la RAM de esta VM a **3072-4096 MB**. Podrás hacerlo apagando la VM y editando su configuración (`Configuración → Sistema → Placa base`) — VirtualBox no permite cambiar la RAM base con la VM encendida. Si tu equipo tiene 8 GB de RAM totales o menos, cierra el resto de aplicaciones antes de encenderla en esa fase.

> [!example] Paso 4: Configuración de Red — dos adaptadores
> Con la VM creada pero **aún apagada**, entra en **`Configuración`** (rueda dentada) → pestaña **`Red`**.
>
> **Adaptador 1 (pestaña "Adaptador 1"):**
> 1. Marca **`Habilitar adaptador de red`**.
> 2. En **`Conectado a`**, selecciona **`NAT`**.
> 3. Deja el resto de opciones por defecto.
>
> **Adaptador 2 (pestaña "Adaptador 2"):**
> 1. Marca **`Habilitar adaptador de red`**.
> 2. En **`Conectado a`**, selecciona **`Red Solo Anfitrión`** (*Host-only Adapter*).
> 3. En el desplegable de nombre de red, selecciona la red host-only por defecto que trae VirtualBox (suele llamarse `vboxnet0`) o créala si no existe (ver nota siguiente).
>
> > [!warning] ⚠️ Configura la red Solo-Anfitrión con IP fija y sin DHCP
> > Por defecto, VirtualBox suele crear la red host-only con un rango tipo `192.168.56.0/24` y un servidor DHCP activo. **Vamos a evitar ese rango a propósito**, para que no se confunda nunca con la red Wi-Fi de casa de ningún alumno (que suele ser `192.168.x.x`). Para cambiarlo:
> > 1. Cierra la ventana de Configuración de la VM (o desde el menú principal: `Herramientas → Redes` / `Archivo → Herramientas → Administrador de red` según tu versión de VirtualBox).
> > 2. Entra en **`Redes solo-anfitrión`** (Host-only Networks).
> > 3. Edita la red `vboxnet0` (o créala con `+` si no existe).
> > 4. En la pestaña **Adaptador**, pon:
> >    - **Dirección IPv4:** `10.10.10.1`
> >    - **Máscara de subred:** `255.255.255.0`
> > 5. En la pestaña **Servidor DHCP**, **desmarca "Habilitar servidor"**. Vamos a poner la IP del servidor a mano en el Paso 6, no queremos que un DHCP se la cambie por sorpresa.
> > 6. Guarda los cambios.
> >
> > Con esto, `10.10.10.1` pasa a ser la IP de tu propio ordenador (el host) dentro de esa red privada — la usarás en el Paso 7 para hacer ping al servidor.

> [!example] Paso 5: Instalación de Ubuntu Server 26.04 desde la ISO
> Enciende la VM (`Iniciar`). VirtualBox arrancará el instalador de Ubuntu Server desde la ISO.
>
> 1. **Idioma:** elige `English` o `Español` (el instalador en español a veces tiene menos opciones traducidas; `English` es más estable, pero cualquiera de los dos sirve).
> 2. **Actualizar el instalador:** si te lo ofrece, acepta actualizar a la última versión del instalador.
> 3. **Distribución del teclado:** selecciona `Spanish`.
> 4. **Tipo de instalación:** `Ubuntu Server` (la opción normal, no la mínima "minimized").
> 5. **Configuración de red — aquí está la parte importante:**
>    - El instalador detectará **dos tarjetas de red** (`enp0s3` para el adaptador NAT y `enp0s8` para el Solo-Anfitrión, los nombres exactos pueden variar).
>    - Deja la primera (**NAT**) en modo **automático (DHCP)** — no la toques, así el instalador ya puede descargar actualizaciones durante la instalación.
>    - Entra en la segunda tarjeta (**Solo-Anfitrión**) y configúrala **manualmente**:
>      - **Dirección IP (Subnet):** `10.10.10.10/24`
>      - **Gateway (puerta de enlace):** déjalo **en blanco** (esta tarjeta no da salida a Internet, para eso ya está la NAT).
>      - **Servidores de nombres (DNS):** déjalo en blanco por ahora (se configurará en la Fase 4 al instalar el propio DNS del dominio).
> 6. **Proxy y espejo de Ubuntu:** deja los valores por defecto.
> 7. **Configuración del disco:** elige `Use an entire disk` (usar todo el disco virtual de 20 GB) con la opción de LVM por defecto que propone el instalador.
> 8. **Perfil del usuario — los tres datos que usarás el resto del curso.** El instalador te pide cuatro campos en una sola pantalla; rellénalos **exactamente así**:
>
>    | Campo del instalador | Qué pones | ¿Se puede cambiar? |
>    | :--- | :--- | :--- |
>    | **Your name** (tu nombre) | El que quieras (ej. `Alumno`) | Sí, es solo decorativo |
>    | **Your server's name** (hostname) | `UbuntuServer` | **No.** Las fases siguientes lo usan tal cual |
>    | **Pick a username** | `boochan` | **No.** Todos los comandos del manual asumen este usuario |
>    | **Choose a password** | `P@ssw0rd` | **No.** Es la contraseña de laboratorio de todo el módulo |
>
>    Este usuario `boochan` será tu **administrador del servidor**: el instalador lo mete automáticamente en el grupo `sudo`, así que desde él ejecutarás todos los comandos con `sudo` de las próximas fases. Ubuntu, a diferencia de Windows, **no crea una cuenta `root` con contraseña** — no la busques, no existe.
>
>    > [!important] 🔐 Por qué la contraseña es la misma para toda la clase — y por qué eso sería inaceptable en una empresa
>    > `P@ssw0rd` es la contraseña de **todas** las máquinas de este módulo. No es pereza: en un laboratorio donde vamos a montar y destruir servidores durante todo el curso, que cada uno tenga la suya significa que la mitad de la clase se queda fuera de su propia VM el segundo día, y las horas se van en resetear contraseñas en vez de en administrar sistemas.
>    >
>    > Dicho esto, **quiero que sepas exactamente lo que estás haciendo:** `P@ssw0rd` es una de las contraseñas más comprometidas del mundo. Aparece en las listas de los primeros puestos de cualquier diccionario de ataque, y un atacante la prueba en el primer segundo. Cumple las reglas de complejidad (mayúscula, minúscula, número, símbolo) y aun así es basura — **que una contraseña cumpla la política no significa que sea segura.** Esa es una lección que vale más que la práctica.
>    >
>    > La regla, entonces: **esta contraseña vale porque tu servidor vive dentro de tu portátil, en una red aislada, y no lo ve nadie.** En el momento en que un servidor tenga IP pública (lo verás en las versiones en la nube), esta contraseña deja de ser aceptable. Ahí se usan contraseñas largas y únicas, o directamente **claves SSH** — que es exactamente lo que hiciste en la Fase 0.2.1.
>
>    > [!warning] ⌨️ Ojo con la `@` y el `0`: dos formas de quedarte fuera de tu servidor
>    > La escribes **a ciegas** (no se ven los caracteres), en un instalador donde acabas de elegir el teclado. Dos trampas:
>    > - **La `@`:** en teclado **español** es `AltGr + 2`. En teclado **inglés** es `Shift + 2`. Si en el Paso 3 de esta lista dejaste el teclado en inglés sin querer, tu `AltGr+2` **no escribe una arroba** — y tu contraseña no es la que crees.
>    > - **El `0`:** es un **cero**, no una `o`. `P@ssw0rd`, no `P@ssword`.
>    >
>    > **Truco para no fallar:** escríbela primero en el campo de *nombre de usuario* (ahí sí se ven los caracteres), comprueba con tus ojos que pone `P@ssw0rd`, bórralo, y solo entonces escríbela en los dos campos de contraseña.
> 9. **OpenSSH Server:** marca la casilla **`Install OpenSSH server`**. Te permitirá conectarte por SSH a la VM desde tu propio ordenador en próximas fases, en lugar de trabajar siempre desde la ventana de VirtualBox.
> 10. **Featured Server Snaps:** no instales ninguno (los instalaremos manualmente cuando toque en cada fase).
> 11. Espera a que termine la instalación y pulsa **`Reboot Now`**. Cuando te pida quitar el medio de instalación, pulsa Enter (VirtualBox expulsa la ISO automáticamente).
>
> > [!tip] 💡 ¿Por qué configurar la IP durante la instalación y no después?
> > El instalador de Ubuntu Server (Subiquity) escribe la configuración de red directamente en un fichero de sistema (`/etc/netplan/`). Hacerlo aquí te ahorra tener que editarlo a mano nada más arrancar. Aun así, en fases posteriores aprenderás a modificar este fichero manualmente si algo falla.

> [!example] Paso 6: El dominio de todo el proyecto — `BOOCHANLAB.LOCAL`
> No hace falta ejecutar ningún comando todavía: esta es solo información que debes **anotar y recordar**, porque la usarás en la Fase 2 (`/etc/hosts`) y sobre todo en la Fase 4 (creación real del dominio Active Directory).
>
> | Concepto | Valor en BoochanV1 |
> | :--- | :--- |
> | **Nombre NetBIOS** | `BOOCHANLAB` |
> | **Realm (dominio completo)** | `BOOCHANLAB.LOCAL` |
> | **IP del servidor (red interna)** | `10.10.10.10` |
> | **IP de tu host en esa red** | `10.10.10.1` |
> | **Rango reservado para la futura VM cliente Windows 11** | `10.10.10.20` (se confirmará en la fase correspondiente) |
>
> Recuerda por qué usamos `.LOCAL`: es una zona reservada para redes privadas que nunca debe intentar resolverse en Internet — perfecta para un laboratorio que vive dentro de tu propio ordenador.

> [!example] Paso 7: Verificación Final de la Fase
> Una vez reiniciada la VM tras la instalación:
>
> 1. **Inicia sesión** en la VM con el usuario y contraseña que creaste (directamente en la ventana de VirtualBox).
> 2. **Comprueba las dos tarjetas de red:**
>    ```bash
>    ip a
>    ```
>    Deberías ver (al menos) tres interfaces: `lo` (loopback), una con IP asignada por DHCP (la NAT, algo tipo `10.0.2.15`) y otra con la IP fija que configuraste, `10.10.10.10`.
> 3. **Comprueba la salida a Internet** (usa la tarjeta NAT):
>    ```bash
>    ping -c 4 google.com
>    ```
>    Deberías recibir 4 respuestas sin pérdida de paquetes.
> 4. **Desde tu propio ordenador (el host, fuera de la VM)**, abre una terminal:
>    - **Windows:** `Windows + R` → `cmd` → Enter.
>    - **Mac/Linux:** abre la aplicación `Terminal`.
>
>    Y haz ping a la IP fija del servidor:
>    ```bash
>    ping 10.10.10.10
>    ```
>    Deberías recibir respuesta. Esto confirma que la red **Solo Anfitrión** funciona: tu ordenador y la VM se ven entre sí, de forma aislada de la red del instituto.
>
> > [!success] ✅ Si los tres pings responden, la Fase 1 está completa
> > VM arrancada + IP correcta en las dos tarjetas + salida a Internet + ping desde el host. Ya tienes la base sobre la que se construirá el resto del proyecto BoochanV1.

---

> [!example] 🔌 Paso 8 — EJERCICIO DE VERIFICACIÓN: comprueba tu red desde fuera
> Hasta aquí has configurado la red **y has confiado en que el panel dice la verdad**. Ahora vas a comprobarlo con fuentes **externas e independientes**, que es como se hace de verdad.
>
> > [!info] ¿Qué es una API y por qué la usa un administrador?
> > Una **API** es una web hecha para que la consulte un programa en vez de una persona: en vez de devolverte una página con colores, te devuelve **datos limpios** en formato JSON.
> >
> > ¿Y para qué la quiere un administrador de sistemas? Para **comprobar desde fuera lo que desde dentro no puede ver**. Tu servidor te dirá siempre lo que él cree de sí mismo; un servicio externo te dice **lo que se ve realmente**. Y esa diferencia, cuando aparece, es justo donde está el problema que llevas dos horas buscando.
> >
> > Se consultan con **`curl`**, que ya has usado y que viene instalado en todas partes. Sin programar y sin instalar nada.
>
> **a) Verifica tu cálculo de subred.** Tu red es **`10.10.10.0/24`** (la red Solo-Anfitrión que has creado).
> Primero, **a mano y sin ayuda**, escribe en tu entrada de apuntes: máscara decimal, dirección de red, broadcast, número de hosts asignables, primero y último.
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
> > ¿Por qué? Porque el adaptador **NAT** que configuraste en el Paso 4 hace exactamente eso: la VM sale **disfrazada de tu ordenador**. Para Internet, tu servidor no existe como máquina independiente.
> > **Dilo en voz alta:** ¿podría alguien de fuera conectarse a tu servidor con esa IP? ¿Por qué no?
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Coincidió tu cálculo de subred con el de la API? Si no, ¿en qué fallaste?
> > 2. ¿Cuál es la IP privada de tu servidor y cuál la pública? ¿Por qué no son la misma?
> > 3. ¿Por qué una comprobación hecha **desde el propio servidor** vale menos que una hecha desde fuera?
>
> > [!note] 📌 Para saber más
> > La teoría completa de esto está en la práctica **B1.9b — Verificar tu red con APIs públicas** del Bloque 1. Aquí lo aplicas a tu servidor de verdad.
> > Esto explica por qué en las versiones **en la nube** (V2 y V3) las cosas cambian: allí el servidor **sí** tiene IP pública propia y **sí** se puede alcanzar desde fuera. Con eso vienen las ventajas… y los problemas de seguridad.

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Tabla de Troubleshooting (¿Algo no funciona?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | **La VM se instaló sola: nunca vi el instalador, ni elegí teclado, ni configuré redes. Y el usuario no es `boochan`.** | **No marcaste `Omitir instalación desatendida` en el Paso 3.** VirtualBox instaló Ubuntu por su cuenta con los datos que le diste en el asistente. | No intentes arreglarlo por dentro: la red quedó mal y el hostname también. **Borra la VM entera** (clic derecho → `Eliminar` → `Borrar todos los archivos`) y repite el Paso 3 **marcando la casilla**. Pierdes 15 minutos, no una tarde. |
> | Marqué la casilla pero VirtualBox no me dejó elegir el "VDI de asignación dinámica" del manual. | Ninguno: el asistente de la 7.x ya no muestra esas dos opciones. | Es lo normal. Deja `Preasignar tamaño completo` **sin marcar** — eso ya es la asignación dinámica, y el formato VDI es el que usa por defecto. Ver la nota del Paso 3. |
> | No puedo iniciar sesión: dice `Login incorrect` con la contraseña que puse. | El teclado del instalador no era el español y los símbolos de la contraseña salieron cambiados. | Prueba a escribirla con la distribución **inglesa** en mente (la `-` y la `_`, la `@`, la `ñ`). Si no hay forma, reinstala la VM y usa **solo letras y números** en la contraseña. |
> | El instalador no arranca, VirtualBox muestra pantalla negra o error de arranque. | La ISO no se seleccionó correctamente, o la VM no tiene habilitada la virtualización por hardware en la BIOS del equipo anfitrión. | Revisa que en `Configuración → Almacenamiento` la ISO esté montada en la unidad óptica. Si persiste, consulta con el profesor si la BIOS del equipo tiene la virtualización (VT-x/AMD-V) activada — en equipos de aula puede estar bloqueada por gestión centralizada. |
> | No puedo hacer ping a `10.10.10.10` desde mi ordenador. | La red host-only no se creó bien, o el firewall del sistema operativo anfitrión bloquea el ICMP. | Repasa el Paso 4: comprueba en `Redes solo-anfitrión` que la IP del adaptador es `10.10.10.1/24`. Si el ping sigue sin responder, revisa el firewall de Windows/macOS (puede bloquear ICMP entrante por defecto en redes "públicas"). |
> | La VM no tiene Internet (`ping google.com` falla) pero sí tiene la IP `10.10.10.10`. | El problema está en el Adaptador 1 (NAT), no en el Adaptador 2. | Comprueba en `Configuración → Red → Adaptador 1` que está habilitado y en modo `NAT`. Reinicia la interfaz con `sudo netplan apply`. |
> | VirtualBox va muy lento / el portátil se congela. | RAM insuficiente asignada al host, o demasiados programas abiertos a la vez que la VM. | Cierra aplicaciones innecesarias del anfitrión antes de encender la VM. Si el problema persiste, revisa que no hayas asignado más RAM de la recomendada (2048 MB) en el Paso 3. |
> | El instalador solo me deja configurar una tarjeta de red. | El adaptador 2 no estaba habilitado antes de encender la VM por primera vez. | Apaga la VM, revisa el Paso 4, habilita el Adaptador 2 y vuelve a arrancar el instalador desde cero (o reinicia el proceso "Reconfigurar red" si el instalador lo permite). |

> [!help] Preguntas Críticas (Autoevaluación del alumno)
> 1. ¿Qué diferencia hay entre un hipervisor de Tipo 1 (como los que usan Azure/AWS) y uno de Tipo 2 (como VirtualBox)?
> 2. ¿Por qué la VM necesita dos adaptadores de red en lugar de uno solo?
> 3. Si conectaras el Adaptador 2 en modo "Red Interna" en lugar de "Solo Anfitrión", ¿podrías seguir haciendo `ping` desde tu ordenador a la VM? Razona la respuesta.
> 4. ¿Por qué el dominio del proyecto termina en `.LOCAL` y no en un dominio real como `.COM` o `.ES`?
> 5. 🔬 **Reto práctico:** Apaga la VM, entra en `Configuración → Sistema → Placa base` y comprueba cuánta RAM tiene asignada ahora mismo. Súbela a 3072 MB, enciende la VM y ejecuta `free -h`. Compara el resultado con el que tenías antes. Vuelve a bajarla a 2048 MB para las próximas fases (hasta que la Fase 4 lo requiera de verdad).

---

### ✅ Checklist Final de la Fase 1

- [ ] VirtualBox instalado (o verificado ya instalado) en el equipo del aula.
- [ ] ISO de Ubuntu Server 26.04 LTS descargada.
- [ ] Casilla **`Omitir instalación desatendida`** marcada en el asistente (¡la más importante!).
- [ ] VM `UbuntuServer` creada con 2048 MB RAM, 2 vCPU, disco de 20 GB sin preasignar.
- [ ] Usuario `boochan` creado **por ti** dentro del instalador de Ubuntu, con contraseña anotada fuera del repositorio.
- [ ] Adaptador 1 en modo NAT (Internet) habilitado.
- [ ] Adaptador 2 en modo Red Solo-Anfitrión, red `vboxnet0` con IP `10.10.10.1/24` y DHCP deshabilitado.
- [ ] Ubuntu Server 26.04 instalado, con IP estática `10.10.10.10/24` en el adaptador Solo-Anfitrión.
- [ ] OpenSSH Server instalado durante la instalación.
- [ ] Nombre NetBIOS (`BOOCHANLAB`) y Realm (`BOOCHANLAB.LOCAL`) anotados para las próximas fases.
- [ ] `ping google.com` funciona desde dentro de la VM.
- [ ] `ping 10.10.10.10` funciona desde tu ordenador (host).

> **Siguiente paso:** Fase 2 — Purga y Preparación del Entorno, donde limpiaremos Ubuntu de software preinstalado que entraría en conflicto con Samba, y registraremos el FQDN completo del servidor en `/etc/hosts`.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-1-infraestructura-virtual-local-virtualbox.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 1 — Infraestructura Virtual Local (VirtualBox)`, con presentación, identidad y timestamps |
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
