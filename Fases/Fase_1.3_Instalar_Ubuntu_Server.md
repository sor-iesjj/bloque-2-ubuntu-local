## 💿 Fase 1.3: Instalar Ubuntu Server

### El sistema operativo, decisión a decisión

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1 hora *(de las cuales 15-30 min son la instalación en sí, corriendo sola)*
> **Requisitos:** [[Fase_1.2_La_Red_del_Laboratorio]] terminada y verificada

---

> [!abstract] 📋 Qué se te evalúa en esta sub-fase
> **Resultado de Aprendizaje — `RA.01`** *(35 % del módulo · UD1-UD4)*
> *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.c` | Se ha planificado y realizado el particionado del disco del servidor. | Paso 7 del instalador: `Use an entire disk` con LVM sobre el disco de 20 GB |
> | `CE.01.e` | Se han seleccionado los componentes a instalar. | `Ubuntu Server` frente a la versión *minimized*, marcar OpenSSH, no instalar snaps |
> | `CE.01.g` | Se han aplicado preferencias en la configuración del entorno personal. | Idioma, **teclado español**, hostname y perfil de usuario |

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta sub-fase** en Obsidian: fichero `v1-fase-1-3-instalar-ubuntu-server.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 1.3 de Boochan V1 — Instalar Ubuntu Server."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 1.3 — Instalar Ubuntu Server`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** La Fase 1 va en cuatro sub-fases precisamente para que cada vídeo sea corto: ve al grano, pero no te saltes pasos.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta sub-fase y otras**; te llegará notificación con fecha límite.
>
> > [!danger] ⚠️ Los nombres NO son orientativos
> > El fichero se llama **exactamente** `v1-fase-1-3-instalar-ubuntu-server.md` y el vídeo **exactamente** `V1 · Fase 1.3 — Instalar Ubuntu Server`. No es una manía: con cuatro sub-fases por alumno y un grupo entero, si cada uno pone el nombre que le apetece, corregir se vuelve imposible y **tu entrega se pierde**. Un nombre distinto es una entrega no localizada.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de la 1.2
> La VM existe, está dimensionada y tiene dos tarjetas de red apuntando a donde deben. Es una máquina completa **sin sistema operativo**: si la enciendes ahora, no sabe hacer nada.

> [!warning] El problema
> Un instalador es una **sucesión de decisiones**, y casi todas son irreversibles sin reinstalar. El teclado, el particionado, el nombre del servidor, el usuario. Ir dándole a "siguiente" es la forma más rápida de tener que empezar de cero mañana.

> [!success] Objetivo de esta sub-fase
> Ubuntu Server 26.04 LTS instalado y arrancando, con teclado español, IP fija `10.10.10.10/24` en la tarjeta sólo-anfitrión, usuario `boochan` y OpenSSH instalado.

> [!tip] Hoja de ruta
> 1. Arrancar el instalador
> 2. Recorrer sus pantallas, entendiendo cada decisión
> 3. Esperar, reiniciar y entrar
>
> **Siguiente:** [[Fase_1.4_Verificacion_y_Acceso_Remoto]] — comprobar que todo funciona de verdad.

---

### 📚 Fundamento Teórico

> [!abstract] 1. Un teclado no envía letras
> Envía **números de tecla**. Es el sistema operativo quien decide qué carácter significa cada número, según la *distribución* configurada. Por eso, con la distribución equivocada, las letras y los números salen bien (coinciden en casi todas) pero **los símbolos no**: `@`, `;`, `-`, `/` cambian de sitio.
>
> Guárdate esto: cuando alguien te diga *"se me ha roto el teclado"*, casi nunca es el teclado.

> [!info] 2. Por qué la IP se pone durante la instalación
> El instalador de Ubuntu Server (**Subiquity**) escribe la configuración de red directamente en `/etc/netplan/`. Hacerlo aquí te ahorra editar ficheros nada más arrancar. Si por lo que sea no puedes, se puede hacer después a mano — está explicado en [[Fase_1.E_Cuando_Algo_Falla]].

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

### 🛠️ Procedimiento

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. **Léete las once pantallas enteras** antes de arrancar. En un instalador no puedes "volver atrás" cómodamente.
> 3. Ten OBS listo.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso único: el instalador, pantalla a pantalla
> Enciende la VM (`Iniciar`). Arrancará el instalador desde la ISO.
>
> **1. Idioma.** `English` o `Español`. El instalador en español a veces tiene menos opciones traducidas; `English` es algo más estable, pero cualquiera sirve.
>
> **2. Actualizar el instalador.** Si te lo ofrece, acepta. *(Si se queda mucho rato aquí, es red: ver [[Fase_1.E_Cuando_Algo_Falla]].)*
>
> **3. Distribución del teclado → `Spanish`.**
>
> > [!danger] ⌨️ Esta es LA pantalla que más caro se paga
> > Si te la saltas o eliges mal, dentro de diez minutos estarás escribiendo una contraseña **a ciegas** con el mapa equivocado. Y no lo descubrirás hasta mucho después, cuando intentes escribir una `@` y salgan comillas.
> > **Compruébalo aquí mismo:** el instalador tiene un campo de prueba. Escribe `@` con `AltGr+2` y mira que sale una arroba. Diez segundos ahora, una hora menos luego.
>
> **4. Tipo de instalación** → `Ubuntu Server`, la normal, **no** la *minimized*.
>
> **5. Configuración de red.** La pantalla más importante de todo el instalador.
>
> > [!danger] 🛑 PARA AQUÍ Y CUENTA LAS TARJETAS
> > Tienes que ver **DOS**: `enp0s3` (la NAT) y `enp0s8` (la sólo-anfitrión). Los nombres exactos pueden variar ligeramente.
> >
> > **Si solo ves UNA, no sigas.** Significa que el Adaptador 2 no llegó a la máquina. Aborta la instalación, apaga la VM y vuelve a la [[Fase_1.2_La_Red_del_Laboratorio]] a revisar el Adaptador 2 y su casilla `Cable conectado`.
> >
> > Continuar con una sola tarjeta parece que funciona — la instalación termina, el sistema arranca, todo va bien. Y tres pasos después descubres que tu servidor no tiene la IP `10.10.10.10`, que nadie le hace ping, y que la Fase 4 no puede funcionar. **Dos minutos aquí frente a una tarde después.**
>
> Con las dos delante:
> - **La primera (NAT):** déjala en **automático (DHCP)**. No la toques.
> - **La segunda (sólo-anfitrión):** configúrala **manualmente**:
>   - **Subnet:** `10.10.10.0/24`
>   - **Address:** `10.10.10.10`
>   - **Gateway:** **en blanco** *(esta tarjeta no da salida a Internet; para eso está la NAT)*
>   - **Name servers:** **en blanco** *(el DNS lo pondrá el propio dominio en la Fase 4)*
>
> **6. Proxy y espejo de Ubuntu.** Valores por defecto.
>
> **7. Configuración del disco.** `Use an entire disk`, con el LVM que propone por defecto. Es todo el disco virtual de 20 GB de la 1.1 — no estás tocando el disco real de tu ordenador.
>
> **8. Perfil del usuario.** Cuatro campos en una pantalla:
>
> | Campo | Qué pones | ¿Se puede cambiar? |
> | :--- | :--- | :--- |
> | **Your name** | El que quieras (ej. `Alumno`) | Sí, es decorativo |
> | **Your server's name** (hostname) | `UbuntuServer` | **No.** Las fases siguientes lo usan tal cual |
> | **Pick a username** | `boochan` | **No.** Todos los comandos del manual asumen este usuario |
> | **Choose a password** | `P@ssw0rd` | **No.** Es la contraseña de laboratorio de todo el módulo |
>
> `boochan` será tu **administrador**: el instalador lo mete en el grupo `sudo`. Ubuntu, a diferencia de Windows, **no crea una cuenta `root` con contraseña** — no la busques, no existe.
>
> > [!important] 🔐 Por qué toda la clase usa la misma contraseña — y por qué eso sería inaceptable en una empresa
> > No es pereza. En un laboratorio donde montamos y destruimos servidores todo el curso, que cada uno tenga la suya significa que media clase se queda fuera de su propia VM el segundo día, y las horas se van en resetear contraseñas en vez de administrar sistemas.
> >
> > Dicho eso, quiero que sepas lo que estás haciendo: **`P@ssw0rd` es una de las contraseñas más comprometidas del mundo.** Está en los primeros puestos de cualquier diccionario de ataque. Cumple las reglas de complejidad —mayúscula, minúscula, número, símbolo— y aun así es basura. **Que una contraseña cumpla la política no significa que sea segura.**
> >
> > La regla: vale **porque tu servidor vive dentro de tu portátil, en una red aislada, y no lo ve nadie**. En cuanto un servidor tiene IP pública (lo verás en las versiones cloud) deja de ser aceptable — de hecho Azure directamente la rechaza. Ahí se usan contraseñas largas y únicas, o **claves SSH**, como las que generaste en la Fase 0.2.1.
>
> > [!warning] ⌨️ La escribes a ciegas: dos trampas
> > - **La `@`:** en teclado **español** es `AltGr+2`; en **inglés** es `Shift+2`. Si el teclado quedó en inglés, tu `AltGr+2` **no escribe una arroba** y tu contraseña no es la que crees.
> > - **El `0`** es un **cero**, no una `o`. `P@ssw0rd`, no `P@ssword`.
> >
> > **Truco:** escríbela primero en el campo de *nombre de usuario*, donde **sí** se ven los caracteres. Comprueba con tus ojos que pone `P@ssw0rd`, bórralo, y solo entonces escríbela en los dos campos de contraseña.
>
> **9. OpenSSH Server** → **marca `Install OpenSSH server`**.
>
> > [!important] 🔑 No es opcional, es el objetivo de la fase siguiente
> > Sin esto no podrás entrar al servidor desde tu terminal y tendrás que trabajar siempre dentro de la ventana de VirtualBox: sin copiar y pegar, con la letra minúscula, y con una sola pantalla.
> > Nadie administra un servidor así en la vida real. **Márcala.** Si se te olvida, tiene arreglo — está en [[Fase_1.E_Cuando_Algo_Falla]] — pero es un rato perdido.
>
> **10. Featured Server Snaps** → no instales ninguno. Lo que haga falta se instalará cuando toque.
>
> **11. Espera y reinicia.** Cuando termine, pulsa **`Reboot Now`**. Si te pide quitar el medio de instalación, pulsa `Enter`: VirtualBox expulsa la ISO solo.
>
> > [!tip] ⏱️ ¿Y si tarda muchísimo?
> > Entre 15 y 30 minutos es normal. **Si pasa de 40**, casi siempre está en `Downloading and installing security updates`, bajando parches por la NAT. Hay un botón **`Cancel update and reboot`** que puedes pulsar sin miedo: el sistema queda instalado y perfectamente usable, y los parches se aplican en la Fase 2, que es donde tocan. Detalle completo en [[Fase_1.E_Cuando_Algo_Falla]].

> [!example] Primer arranque
> 1. Verás el `login:`. Entra con `boochan` y `P@ssw0rd`.
> 2. Puede que aparezcan mensajes del sistema **encima** del prompt — incluido alguno que dice `error`. Escribe igualmente: los mensajes no interrumpen lo que tecleas.
>
> > [!info] ℹ️ Sobre el mensaje `vmwgfx ... DRM error`
> > Si lo ves, **no es una avería**. Es el driver gráfico de VMware protestando porque corre sobre VirtualBox. En un servidor sin escritorio no afecta a nada. Aprender a distinguir **el error que rompe algo** del **error que solo habla** es media asignatura. Si te molesta, en [[Fase_1.E_Cuando_Algo_Falla]] está cómo quitarlo.

---

### ✅ Checklist de la 1.3

- [ ] Teclado `Spanish`, **comprobado escribiendo una `@`** en el instalador.
- [ ] Las **dos** tarjetas visibles en la pantalla de red.
- [ ] `enp0s3` en DHCP · `enp0s8` manual con `10.10.10.10/24`, sin gateway ni DNS.
- [ ] Disco: `Use an entire disk` con LVM.
- [ ] Hostname `UbuntuServer` · usuario `boochan` · contraseña `P@ssw0rd`.
- [ ] **`Install OpenSSH server` marcado.**
- [ ] Ningún snap instalado.
- [ ] El sistema arranca y puedes iniciar sesión.

---

### ✅ Entregables

> [!abstract] Qué tienes que tener al acabar
> | Entregable | Dónde | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `.../v1-fase-1-3-instalar-ubuntu-server.md` | Las decisiones que tomaste **y por qué** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` | `V1 · Fase 1.3 — Instalar Ubuntu Server`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes | La entrada subida con `add` → `commit` → `push` |

> [!summary] 🎓 Qué has aprendido
> Que un instalador no es un formulario: es una cadena de decisiones que condicionan meses de trabajo. Y que un teclado no envía letras, envía números — el significado lo pone el sistema.
>
> **Siguiente:** [[Fase_1.4_Verificacion_y_Acceso_Remoto]] — comprobar que lo que crees que has hecho es lo que de verdad ha pasado.
>
> ¿Algo no ha salido? → [[Fase_1.E_Cuando_Algo_Falla]]
