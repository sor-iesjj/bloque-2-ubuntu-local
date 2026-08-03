---
Práctica: V1.F6
Bloque: 02_Ubuntu_Local
Version: BoochanV1
RA: RA.01, RA.04, RA.05
CE: CE.01.d, CE.04.b, CE.05.b
Playlist: B2_Ubuntu_Local
Vídeo: V1 · Fase 6 — Almacenamiento Virtual (Cuotas con Loop Devices)
---
## 💾 Fase 6: Almacenamiento Virtual (Cuotas con Loop Devices)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5: Administración en Linux - Cuotas de Discos]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 4 GB RAM | 11 GB disco libre | SSH (o consola de VirtualBox)

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> Poner cuotas de disco toca **tres** resultados de aprendizaje, porque es a la vez sistema de archivos, recurso compartido y rendimiento del almacenamiento:
>
> **`RA.01`** *(35 % del módulo · UD1-UD4)* — *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
> **`RA.04`** *(12 % del módulo · UD7)* — *Gestiona los recursos compartidos del sistema, interpretando especificaciones y determinando niveles de seguridad.*
> **`RA.05`** *(10 % del módulo · UD7)* — *Realiza tareas de monitorización y uso del sistema operativo en red, describiendo las herramientas utilizadas.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.d` | Se han seleccionado y aplicado los sistemas de archivos. | Crear el sistema de archivos dentro del *loop device* y montarlo con las opciones de cuota |
> | `CE.04.b` | Se han identificado los recursos del sistema que se van a compartir y en qué condiciones. | **"En qué condiciones" es literalmente la cuota**: cuánto espacio puede ocupar cada usuario |
> | `CE.05.b` | Se han identificado problemas de rendimiento en los dispositivos de almacenamiento. | Comprobar el consumo con `repquota` y ver qué pasa cuando un usuario llega a su límite |

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-6-almacenamiento-virtual-cuotas-con-loop-d.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 6 de Boochan V1 — Almacenamiento Virtual (Cuotas con Loop Devices)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 6 — Almacenamiento Virtual (Cuotas con Loop Devices)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 5
> Tienes usuarios y grupos del dominio completamente mapeados a UIDs/GIDs de Linux. El servidor ahora reconoce a los usuarios como si fueran locales, y pueden crear archivos con propietario válido. Sin embargo, no existe ningún límite sobre cuánto espacio pueden usar en el disco duro virtual de la máquina.

> [!warning] El Problema
> Sin cuotas de disco, un usuario malintencionado (o simplemente desprevenido) podría llenar el disco duro completamente. Cuando el disco llena, el sistema operativo colapsa: los logs dejan de escribirse, las nuevas conexiones se rechazan, y el servidor se vuelve irrecuperable sin intervención manual. En empresas, esto es un "Denegación de Servicio" (DoS) involuntaria pero devastadora.

> [!success] Objetivo de esta Fase
> Crear **discos virtuales independientes** (Loop Devices) con tamaños limitados (5GB cada uno) para que el servidor tenga **cuotas físicas infranqueables**. Si un disco llena, solo ese "usuario" o "departamento" se ve afectado — el resto del servidor continúa funcionando.

> [!tip] Hoja de Ruta
> 1. Crear carpetas de montaje en `/srv/samba/` para los discos virtuales (`prueba1` y `prueba3`)
> 2. Generar dos archivos imagen de 5GB cada uno con `dd` (archivo binario lleno de ceros)
> 3. Formatear cada imagen con el sistema de archivos ext4
> 4. Editar `/etc/fstab` para que los discos se monten automáticamente al reiniciar (con la palabra clave `loop`)
> 5. Montar los discos con `mount -a` (sin reiniciar)
> 6. Asignar permisos: `prueba1` accesible para todos (777), `prueba3` solo para el grupo `policia` (2770)
> 7. Verificar con `df -h` que aparecen los discos de 5GB; intentar llenarlos para comprobar que la barrera física es infranqueable
>
> **Resultado Final:** Dos discos virtuales independientes montados en `/srv/samba/prueba1` y `/srv/samba/prueba3`, cada uno con límite físico de 5GB. El servidor está protegido contra llenado de disco.
> **Siguiente:** Fase 7 (Seguridad Avanzada) — aplicarás ACLs y ABE para controlar quién ve y accede a cada carpeta.

---

### 📚 Fundamento Teórico

> [!abstract] 1. Evitando el Colapso por Llenado
> La gestión de cuotas de disco es vital para evitar el "Denegación de Servicio" por llenado de disco. Si un usuario (o un atacante) llena todo el disco duro del servidor, los logs no podrán escribirse y el sistema operativo colapsará.

> [!tip] 2. Cuota Física Infranqueable (Loop Devices)
> En lugar de usar cuotas de software (que a veces fallan o son difíciles de configurar), usaremos **Loop Devices**: archivos que actúan como discos duros virtuales. 
> *   **La Lógica:** Si creamos un archivo de 5GB y lo montamos como disco, el sistema de archivos simplemente **no puede crecer más allá de eso**. Es una barrera física que protege el resto del servidor de usuarios que intenten guardar datos masivos.

### 📖 Diccionario de Conceptos Clave

> [!quote] Almacenamiento Avanzado
> - **dd:** Comando para copiar datos a bajo nivel (usado aquí para "dibujar" el tamaño de nuestro disco virtual).
> - **ext4:** El sistema de archivos estándar de Linux que vamos a "formatear" dentro de nuestro archivo `.img`.
> - **fstab:** La tabla maestra que le dice a Linux qué discos debe montar automáticamente al arrancar.
> - **Punto de Montaje:** La carpeta de Linux donde se hace accesible el contenido del disco virtual.

---

### 🔓 Red Solo Anfitrión de VirtualBox

> [!info] ℹ️ Sin cambios de red en esta fase
> El puerto **123 UDP (NTP)** circula sin problema por la Red Solo Anfitrión desde que se levantó el dominio en la **Fase 4** (Kerberos necesita sincronía horaria). El firewall local (`ufw`) del servidor sigue **inactivo** en este punto — no se activa hasta la Auditoría Final — así que no hay nada que tocar ni comprobar en él todavía.
>
> Recuerda: si el reloj de la VM del servidor y el del cliente Windows difieren más de 5 minutos, Kerberos invalida los tickets y nadie puede autenticarse. Si sospechas un problema horario, verifica en el servidor con `timedatectl status`.

---

### 🛠️ Procedimiento Práctico (Creación del Almacenamiento)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-6-almacenamiento-virtual-cuotas-con-loop-d.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Creación de los Puntos de Montaje
> Antes de crear los discos virtuales, necesitamos las carpetas donde se "conectarán". Creamos las carpetas para las dos unidades de almacenamiento del proyecto:
> ```bash
> sudo mkdir -p /srv/samba/prueba1
> sudo mkdir -p /srv/samba/prueba3
> ```
>
> > [!tip] 💡 ¿Qué hace `-p`?
> > El parámetro `-p` (de *parents*) crea todas las carpetas del camino que no existan. Si `/srv/samba/` no existiera, lo crearía también automáticamente. Sin `-p`, daría error si la carpeta padre no existe.

> [!example] Paso 2: Creación de los Archivos de Disco Virtual
> Creamos dos archivos que actuarán como discos duros independientes:
>
> > [!info] 📚 Diccionario de Comandos: Para entender cómo funciona el comando `dd` creando discos virtuales, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Disco virtual para "prueba1" (carpeta compartida general)
> sudo dd if=/dev/zero of=/samba_p1.img bs=1M count=5120
>
> # Disco virtual para "prueba3" (carpeta protegida con permisos en la Fase 7)
> sudo dd if=/dev/zero of=/samba_p3.img bs=1M count=5120
> ```
> Este comando tarda aproximadamente **1-2 minutos** por cada disco. Verás el progreso en pantalla.
>
> > [!caution] ⚠️ Comprueba el disco virtual (.vdi) de la VM antes de empezar
> > Estos dos archivos de 5GB se guardan dentro del disco duro virtual (.vdi/.vmdk) que VirtualBox asignó a tu máquina en la Fase 1. Si el disco de la VM tiene poco espacio libre, `dd` fallará a mitad de escritura con "No space left on device". Verifica antes con `df -h /` que tienes al menos 11 GB libres.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`if=/dev/zero`:** El origen de los datos es un generador infinito de ceros.
> > - **`of=/samba_p1.img`:** El archivo de destino que se convertirá en nuestro disco.
> > - **`bs=1M`:** "Block Size". Escribimos en bloques de 1 Megabyte.
> > - **`count=5120`:** Multiplicamos 1MB x 5120 para obtener exactamente 5 Gigabytes.

> [!example] Paso 3: Formateo y Preparación
> Ahora le damos "formato" a cada archivo para que Linux pueda guardar archivos dentro:
> ```bash
> # Formateamos el disco de prueba1
> sudo mkfs.ext4 /samba_p1.img
>
> # Formateamos el disco de prueba3
> sudo mkfs.ext4 /samba_p3.img
> ```

> [!example] Paso 4: Montaje Persistente (fstab)
> Editamos la tabla de discos del sistema para que ambos discos se monten automáticamente al reiniciar:
> ```bash
> sudo nano /etc/fstab
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Añade estas dos líneas **al final del archivo** (sin borrar nada de lo que ya hay):
> ```
> /samba_p1.img  /srv/samba/prueba1  ext4  loop,defaults  0  0
> /samba_p3.img  /srv/samba/prueba3  ext4  loop,defaults  0  0
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`). Ahora monta los discos sin necesidad de reiniciar:
> ```bash
> sudo mount -a
> ```
>
> > [!caution] ⚠️ La palabra `loop` es obligatoria
> > Si olvidas escribir `loop` en las opciones del fstab, Linux intentará tratar el archivo como una partición física real y el servidor **entrará en pánico al arrancar**. Comprueba dos veces que la has escrito.
>
> > [!important] 🪂 El Paracaídas Púrpura (Comprobación de Vida)
> > Ejecutar `sudo mount -a` es tu paracaídas. Este comando simula el arranque del servidor leyendo el archivo `fstab`. Si la terminal **no devuelve ningún texto** (silencio), ¡enhorabuena! Tu sintaxis es perfecta. Si devuelve **texto rojo o un aviso de error**, tienes un fallo tipográfico grave. **¡BAJO NINGÚN CONCEPTO REINICIES!** Vuelve a editar el `fstab` hasta que `sudo mount -a` no devuelva errores, o de lo contrario tu máquina virtual dejará de arrancar.

> [!example] Paso 5: Permisos de Acceso
> Asignamos los permisos correctos para que los usuarios del dominio puedan escribir en las carpetas:
> ```bash
> # prueba1: accesible por todos los usuarios del dominio
> sudo chown root:root /srv/samba/prueba1
> sudo chmod 777 /srv/samba/prueba1
>
> # prueba3: solo accesible por el grupo "policia" (lo protegeremos en la Fase 7)
> sudo chown root:policia /srv/samba/prueba3
> sudo chmod 2770 /srv/samba/prueba3
> ```
> > [!caution] ⚠️ Verifica que el grupo `policia` fue reconocido
> > Si el servicio `winbind` no estaba activo, el `chown` falla con `invalid group: 'policia'` y la carpeta queda mal configurada sin aviso visible. Compruébalo:
> > ```bash
> > ls -la /srv/samba/ | grep prueba3
> > ```
> > La columna de grupo debe mostrar `policia`, no `root`. Si muestra `root`, arranca winbind y repite:
> > ```bash
> > sudo systemctl enable winbind --now
> > sudo chown root:policia /srv/samba/prueba3
> > ```
>
> > [!tip] 💡 ¿Qué es el `chmod 2770`?
> > - **`2`:** Es el **bit setgid**. Hace que todos los archivos nuevos creados dentro de la carpeta hereden automáticamente el grupo `policia`, en lugar del grupo personal de quien lo creó. Así todos los archivos de la carpeta siempre pertenecen al grupo correcto.
> > - **`770`:** El propietario y el grupo tienen acceso total (rwx), pero el resto del mundo no tiene ningún acceso (---).

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿El disco no aparece?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | El servidor no arranca tras editar el fstab. | Error de sintaxis crítico en `/etc/fstab`. No ejecutaste `sudo mount -a` antes de reiniciar. | Abre la **ventana de la máquina virtual en VirtualBox** (no hace falta SSH, ni SSM, ni consola serie: al ser una VM local tienes la pantalla completa disponible). Inicia sesión con el usuario local del servidor y ejecuta `sudo nano /etc/fstab`, corrige la línea, guarda y ejecuta `sudo reboot`. |
> | `df -h` no muestra los discos de 5GB. | No se ha ejecutado el comando de montaje. | Ejecuta `sudo mount -a` para forzar el montaje de lo definido en el fstab. |
> | Error "wrong fs type" al montar. | El archivo `.img` no se formateó correctamente. | Vuelve a ejecutar `sudo mkfs.ext4 /samba_p1.img` y luego `sudo mount -a`. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué un **Loop Device** es más seguro que una cuota de software tradicional?
> 2. ¿Qué representa exactamente el parámetro `bs=1M` en el comando `dd`?
> 3. ¿Qué pasaría con los archivos de los usuarios si el servidor se reinicia y no hemos configurado el `fstab`?
> 4. 🔬 **Reto práctico:** Intenta llenar el disco virtual ejecutando: `dd if=/dev/zero of=/srv/samba/prueba1/lleno.img bs=1M count=6000 2>&1`. ¿Qué mensaje de error aparece cuando el disco se queda sin espacio? Borra el archivo con `rm /srv/samba/prueba1/lleno.img` y comprueba con `df -h` que el espacio se ha liberado. Acabas de ver en acción la cuota física — y por qué el resto del servidor no se ve afectado.
> 5. 🔬 **Reto práctico:** Ejecuta `df -h | grep samba`. ¿Cuánto espacio queda libre en cada disco? Ahora ejecuta `df -h /` (la raíz del sistema). ¿Qué ocurriría con la raíz si no hubieras usado Loop Devices y los usuarios hubieran llenado el disco del servidor?

---

> [!caution] 🛑 Auditoría de Persistencia (RA.04)
> **Riesgo Crítico:** Si el alumno olvida la palabra `loop` en las opciones del `fstab`, Linux intentará tratar el archivo como una partición física real y el servidor entrará en pánico al arrancar.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿Aparecen los discos `/samba_p1.img` y `/samba_p3.img` al ejecutar `df -h`?
> - [ ] Reinicia el servidor para comprobar que los discos se montan solos al arrancar:
>   ```bash
>   sudo reboot
>   ```
>   > [!caution] ⚠️ La conexión SSH se cortará al instante — es normal
>   > La máquina virtual se está reiniciando. **Espera 1-2 minutos** y vuelve a conectarte con el mismo comando SSH (o abre la ventana de VirtualBox y espera a ver el prompt de login). No es un error. Cuando veas el prompt de nuevo, ejecuta `df -h` y confirma que los discos de 5 GB aparecen montados.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-6-almacenamiento-virtual-cuotas-con-loop-d.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 6 — Almacenamiento Virtual (Cuotas con Loop Devices)`, con presentación, identidad y timestamps |
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
