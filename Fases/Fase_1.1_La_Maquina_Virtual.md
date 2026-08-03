## 🏗️ Fase 1.1: La Máquina Virtual

### Crear el "ordenador dentro del ordenador"

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~40 min (sin contar la descarga de la ISO, que va por su cuenta)
> **Requisitos:** VirtualBox instalado · ~2 GB de RAM libres · ~20 GB de disco libres

---

> [!abstract] 📋 Qué se te evalúa en esta sub-fase
> **Resultado de Aprendizaje — `RA.01`** *(pesa un **35 %** del módulo, el más alto de los seis · UD1-UD4)*
> *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.a` | Se ha realizado el estudio de compatibilidad del sistema informático. | Paso 3: dimensionar RAM, CPU y disco según el equipo **real** del aula, y comprobar que la virtualización por hardware está activa |
> | `CE.01.b` | Se han diferenciado los modos de instalación. | Paso 3: distinguir **instalación desatendida** de **instalación manual**, y justificar por qué eliges la manual |

---

> [!important] 📹 Obligaciones de grabación
> 1. **Sin grabar:** léete el procedimiento entero y **crea vacía** la entrada `v1-fase-1-1-la-maquina-virtual.md` en `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`.
> 2. **Arranca OBS y preséntate**, mostrando algo que demuestre que eres tú.
> 3. **Graba todo el procedimiento**, explicando en voz alta.
> 4. **Timestamps** en la descripción.
> 5. Vídeo: `V1 · Fase 1.1 — La Máquina Virtual`, playlist **`B2_Ubuntu_Local`** (No listado). **~6-8 min.**
> 6. El enlace del vídeo va **dentro** de tu entrada de apuntes.

---

### 🎯 ¿Dónde Estamos?

> [!info] El punto de partida
> Esta es la primera piedra de BoochanV1. En BoochanV2 y V3 alquilabas un servidor en la nube; aquí lo vas a construir **dentro de tu propio ordenador**, con VirtualBox.

> [!warning] El problema
> No siempre hay presupuesto ni conexión fiable en el aula para una cuenta cloud por alumno. Y hay algo más de fondo: entender la virtualización **local** — la que corre sobre tu hardware — es lo que luego te permite entender la de la nube. Antes de alquilarle un ordenador virtual a Microsoft, conviene saber crear uno.

> [!success] Objetivo de esta sub-fase
> Tener creada, **apagada y sin sistema operativo todavía**, una máquina virtual llamada `UbuntuServer` correctamente dimensionada. Nada más. La red va en la 1.2 y la instalación en la 1.3.

> [!tip] Hoja de ruta
> 1. Verificar o instalar VirtualBox
> 2. Descargar la ISO de Ubuntu Server 26.04 LTS
> 3. Crear la VM: RAM, CPU y disco
>
> **Siguiente:** [[Fase_1.2_La_Red_del_Laboratorio]] — las dos tarjetas de red.

---

### 📚 Fundamento Teórico

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

### 🛠️ Procedimiento

> [!danger] ⚠️ LÉEME ANTES: permisos de administrador en el equipo del aula
> Instalar VirtualBox requiere permisos de administrador **del sistema operativo anfitrión**.
> - **Si ya está instalado** (mira el menú de aplicaciones o pregunta al profesor): salta al Paso 2.
> - **Si no lo está y no tienes permisos:** esta práctica **no es viable en ese equipo**. No intentes saltarte los permisos ni usar instaladores "portables" no autorizados. Avísame: lo instala el departamento en la imagen del aula, o se usa un equipo personal.

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes de esta sub-fase.
> 2. Léete los tres pasos enteros.
> 3. Ten OBS listo, con pantalla y micrófono comprobados.
>
> Cuando lo tengas: **arranca la grabación y preséntate.** A partir de ahí, todo queda grabado.

> [!example] Paso 1: Instalar VirtualBox (solo si no está ya)
> 1. Entra en la web oficial: `virtualbox.org` → **Downloads**.
> 2. Descarga el instalador de tu sistema operativo.
> 3. Ejecútalo con permisos de administrador y acepta las opciones por defecto.
> 4. Ábrelo. Si ves la ventana del *VirtualBox Manager* con la lista de máquinas vacía, ha ido bien.
>
> > [!tip] 💡 Qué versión
> > La estable más reciente que ofrezca la web oficial. No hace falta anotar el número exacto.

> [!example] Paso 2: Descargar la ISO de Ubuntu Server 26.04 LTS
> 1. Entra en `ubuntu.com/download/server`.
> 2. Descarga **Ubuntu Server 26.04 LTS**. *LTS* significa **Long Term Support**: recibe actualizaciones de seguridad durante años, y es lo que se usa siempre en producción.
> 3. Guarda el `.iso` en una carpeta que recuerdes. Pesa 2-3 GB.
>
> > [!warning] ⚠️ "Server", no "Desktop"
> > Ubuntu **Desktop** trae escritorio gráfico y está pensado para uso personal. Ubuntu **Server** no tiene entorno gráfico (*headless*) y está pensado para máquinas que dan servicio. Comprueba que pone **Server** en el nombre del fichero.

> [!example] Paso 3: Crear la máquina virtual
> Con VirtualBox abierto, pulsa **`Nueva`** y rellena:
>
> | Campo | Valor | Por qué |
> | :--- | :--- | :--- |
> | **Nombre** | `UbuntuServer` | Coherencia con V2/V3 y con el resto del manual |
> | **Carpeta** | La que sugiera VirtualBox | Evita rutas con espacios o caracteres raros |
> | **Imagen ISO** | El `.iso` del Paso 2 | Es el "disco de instalación" que arrancará la VM |
> | **⚠️ `Omitir instalación desatendida`** | **MARCADA** | **Lee el aviso de abajo. Es el paso más importante de toda la Fase 1.** |
> | **Tipo** | `Linux` | — |
> | **Versión** | `Ubuntu (64-bit)` | Ubuntu Server 26.04 es de 64 bits |
> | **Memoria base (RAM)** | `2048 MB` | Ver la nota de dimensionado |
> | **Procesadores** | `2 vCPU` | Suficiente, y no bloquea el host |
> | **Tamaño de disco** | `20 GB`, con **`Preasignar tamaño completo` SIN marcar** | Margen para sistema, Samba y prácticas, creciendo según se usa |
>
> Revisa el resumen y pulsa **`Finalizar`**.

> [!danger] ⚠️ MARCA `Omitir instalación desatendida`. Si no, arrastrarás fallos durante horas.
> En cuanto seleccionas la ISO, **VirtualBox 7.x reconoce que es Ubuntu y se ofrece a instalarlo él solo**: te pide un usuario y una contraseña en el propio asistente, arranca la VM e instala el sistema entero sin que tú toques nada.
>
> Suena cómodo. Y es exactamente lo que no queremos, porque **VirtualBox se salta la Fase 1.3 completa** y decide por ti. Esto es lo que ocurre de verdad cuando se deja marcada (probado, no teórico):
>
> | Lo que VirtualBox decide por su cuenta | La consecuencia que te encuentras después |
> | :--- | :--- |
> | El teclado, que deja en **inglés** | No puedes escribir `@` ni `;`. Y tu contraseña puede no ser la que crees |
> | La red: deja las **dos tarjetas en DHCP** | Tu servidor se queda **sin la IP fija `10.10.10.10`**, y la Fase 4 no funciona sin ella |
> | El usuario, que **no será `boochan`** | Todos los comandos del manual dejan de encajar |
> | **No instala OpenSSH** | No puedes entrar desde tu terminal: te toca trabajar en la ventana de VirtualBox |
>
> Un solo *checkbox* sin marcar genera cuatro problemas que aparecen **más tarde y por separado**, cuando ya no los relacionas con su causa. Ese es el tipo de fallo más caro que existe.
>
> Y hay un motivo de fondo: **instalar sistemas operativos en red es literalmente el `RA.01` de este módulo.** Es lo que se evalúa. No se delega en un asistente.
>
> **Dónde está:** primera página del asistente, **`Nombre y sistema operativo`**, justo debajo del selector de la ISO. Se llama `Omitir instalación desatendida` (*Skip Unattended Installation*). Al marcarla verás que **desaparece** la página siguiente, la que pedía usuario y contraseña: ya no hace falta, porque esos datos los pondrás tú en la 1.3.
>
> 🎥 **Que se te vea marcarla en el vídeo.**

> [!note] 💡 Sobre el disco: ¿y el "VDI de asignación dinámica"?
> Otros manuales hablan de elegir **VDI** y **asignación dinámica**. En el asistente de VirtualBox 7.x **esas opciones ya no aparecen**: solo hay el tamaño y una casilla `Preasignar tamaño completo`. No te has saltado nada — VirtualBox ya decide:
> - **VDI** es el formato por defecto (VMDK y VHD solo se eligen si necesitas abrir el disco con VMware o Hyper-V).
> - **Dejar `Preasignar tamaño completo` sin marcar ES la asignación dinámica.** Marcarla reservaría los 20 GB de golpe aunque Ubuntu use 6.
>
> **🔬 Compruébalo tú.** Al terminar de crear la VM, abre el explorador de archivos y busca la carpeta de la máquina (`VirtualBox VMs/UbuntuServer/`). Dentro está `UbuntuServer.vdi`. **Mira lo que ocupa y anótalo.** Dice tener 20 GB y ocupa unos pocos MB: eso es la asignación dinámica, vista con tus ojos en vez de creída.
>
> Vuelve a mirarlo al acabar la Fase 1.3, con Ubuntu ya instalado, y anota los dos tamaños.

---

### ✅ Checklist de la 1.1

- [ ] VirtualBox instalado o verificado.
- [ ] ISO de Ubuntu Server 26.04 LTS descargada (comprobado que pone **Server**).
- [ ] Casilla **`Omitir instalación desatendida`** marcada.
- [ ] VM `UbuntuServer` creada: 2048 MB, 2 vCPU, 20 GB sin preasignar.
- [ ] Tamaño real del `.vdi` anotado en la entrada.

---

### ✅ Entregables

> [!abstract] Qué tienes que tener al acabar
> | Entregable | Dónde | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-1-1-la-maquina-virtual.md` | El procedimiento con tus palabras + el tamaño del `.vdi` + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` | `V1 · Fase 1.1 — La Máquina Virtual`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes | La entrada subida con `add` → `commit` → `push` |

> [!summary] 🎓 Qué has aprendido
> Que un hipervisor de Tipo 2 reparte **tu** hardware, que dimensionar es decidir y no maximizar, y que un asistente que "lo hace todo por ti" te quita justo aquello que se te evalúa.
>
> **Siguiente:** [[Fase_1.2_La_Red_del_Laboratorio]] — donde tu VM aprende a hablar.
