## 👥 Fase 5: Gestión de Identidades (Usuarios y Grupos)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5 y 6: Administración de usuarios y grupos en Linux y Windows]**
> **[RA.02]** Gestiona usuarios y grupos de sistemas operativos en red.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **[Estimación de Implementación]**
> - **Tiempo total:** ~0,5 horas (30 minutos)
> - **RAM del servidor:** 4 GB (winbind demanda ~200 MB adicional)
> - **Desglose:** Configurar nsswitch.conf (5 min) + Crear grupos con GID (5 min) + Crear usuarios con UID (5 min) + Verificaciones (10 min) + Troubleshooting (5 min)
> - **Dependencias externas:** Samba AD DC operativo desde Fase 4, winbind activado

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-5-gestion-de-identidades-usuarios-y-grupos.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 5 de Boochan V1 — Gestión de Identidades (Usuarios y Grupos)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 5 — Gestión de Identidades (Usuarios y Grupos)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 4
> Tienes un Active Directory completamente provisionado (Samba AD DC) dentro de tu máquina virtual de VirtualBox, el dominio BOOCHANLAB.LOCAL existe como un "reino" Kerberos, y DNS + LDAP están operativos en la Red Solo Anfitrión (10.10.10.10). Sin embargo, el servidor no sabe aún "traducir" usuarios de Windows (que hablan en SIDs) a usuarios Linux (que hablan en números UID/GID). Los usuarios del dominio existen en AD, pero el servidor no los reconoce como entidades válidas del sistema de archivos.

> [!warning] El Problema
> Sin mapeo RFC 2307, los usuarios del dominio son "fantasmas" para Linux. Si un usuario intenta crear un archivo, el servidor dirá "¿Quién eres?". Además, aunque logres que se autentiquen, los archivos que creen no tendrán propietario válido — aparecerán con UIDs numéricos inválidos en lugar de nombres legibles. En producción, esto significa que nadie puede acceder a los archivos de sus compañeros porque el sistema no comprende las relaciones de grupo.

> [!success] Objetivo de esta Fase
> Integrar el servicio **winbind** (el "traductor") en el servidor para que Linux reconozca a los usuarios de Windows como ciudadanos de primer nivel del sistema de archivos. Cada usuario y grupo tendrá un UID/GID permanente, y cualquier archivo creado podrá ser compartido y editado por sus compañeros de grupo con permisos claros.

> [!tip] Hoja de Ruta
> 1. Configurar **nsswitch.conf** para añadir winbind en las búsquedas de usuarios y grupos (el servidor preguntará a Samba primero)
> 2. Crear dos grupos del dominio: `policia` (GID 3001) y `bomberos` (GID 3002) — para demostrar después segregación de datos
> 3. Crear dos usuarios: `user1` (UID 10001, grupo policia) y `user2` (UID 10002, grupo bomberos) — con sus atributos RFC 2307
> 4. Verificar que `id user1` e `id user2` devuelven los UIDs y GIDs esperados
> 5. Probar creación de archivo: verificar que los permisos y propietarios se asignan correctamente en ext4
> 6. Comprobar que `getent passwd user1` y `getent group policia` muestran los usuarios del dominio como si fueran locales
>
> **Resultado Final:** El servidor reconoce a los usuarios del dominio como entidades Linux válidas, con UIDs/GIDs estables y heredables. Los archivos que creen llevarán sus identidades de forma permanente.
> **Siguiente:** Fase 6 (Almacenamiento Virtual) — crearás discos virtuales con cuotas para controlar que no llenen el servidor.

---

### 📚 Fundamento Teórico

> [!abstract] 1. La "Traducción de Mundos"
> En esta fase ocurre la magia de la interoperabilidad. Windows identifica usuarios con un **SID** (una cadena alfanumérica muy larga e ilegible). Linux, por el contrario, usa un **UID** (un número corto de 4 o 5 cifras). 

> [!info] 2. El Estándar RFC 2307
> Para que un usuario de Windows pueda guardar un archivo en el disco duro de nuestro servidor Linux, necesitamos el estándar **RFC 2307**. Esto permite añadir atributos técnicos de Unix (como el número de usuario o la carpeta /home) directamente en la ficha del Active Directory. Es la única forma de que los permisos de archivo sean consistentes y no haya errores de "Acceso Denegado".

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Identidades
> - **UID-Number:** El identificador numérico único que el Kernel de Linux asigna a un usuario.
> - **GID-Number:** El identificador numérico para un grupo de usuarios.
> - **Mapeo:** La relación 1 a 1 entre un usuario de Windows y un ID de Linux.
> - **samba-tool:** La "Navaja Suiza" para gestionar todos los aspectos del dominio desde la terminal.

---

### 🔓 Red Solo Anfitrión de VirtualBox

> [!info] ℹ️ Sin cambios de red en esta fase
> El puerto **445 (SMB)** que necesita esta fase circula sin problema por la Red Solo Anfitrión de VirtualBox (no hay firewall perimetral entre servidor y cliente). El firewall local (`ufw`) del servidor sigue **inactivo** en este punto del proyecto — no se activa hasta la Auditoría Final — así que tampoco hay ninguna regla que comprobar ni tocar todavía.
>
> Si al conectarte desde el cliente Windows la carpeta no aparece y sospechas que es un problema de red, verifica en el servidor que el firewall permite el tráfico SMB:
> ```bash
> sudo ufw status
> ```
> Debe aparecer una regla `445/tcp ALLOW`. Recuerda también que servidor y cliente deben estar en el mismo adaptador de Red Solo Anfitrión de VirtualBox (10.10.10.0/24) para verse entre sí.

---

### 🛠️ Procedimiento Práctico (CORRECCIÓN CRÍTICA)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-5-gestion-de-identidades-usuarios-y-grupos.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Configuración del Traductor (nsswitch.conf)
> Antes de crear usuarios, debemos decirle a Linux que "pregunte también a Winbind" cuando alguien busque un usuario o un grupo. Sin este paso, el servidor no reconocerá a los usuarios del dominio aunque existan:
> ```bash
> sudo nano /etc/nsswitch.conf
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Busca las líneas que empiezan por `passwd:` y `group:` y añade la palabra `winbind` al final de cada una, dejándolas así:
> ```
> passwd:         files systemd winbind
> group:          files systemd winbind
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!tip] 💡 ¿Qué hace este cambio?
> > El archivo `nsswitch.conf` es la "guía de consulta" de Linux. Le dice dónde buscar cuando alguien pregunta "¿quién es el usuario X?". Al añadir `winbind`, le estamos diciendo: "Si no lo encuentras en los archivos locales, pregúntale a Winbind, que conoce a todos los usuarios del dominio Windows".

> [!example] Paso 2: Creación de Grupos y sus Atributos Unix
> Creamos los dos grupos del proyecto. El grupo `policia` tendrá acceso a las carpetas protegidas y `bomberos` servirá para demostrar que los usuarios sin permisos no ven esas carpetas:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis de `samba-tool` al crear grupos y usuarios, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Creamos el grupo "policia" en el dominio
> sudo samba-tool group add policia
> # Le asignamos un GID (Group ID) de Linux
> sudo samba-tool group addunixattrs policia 3001
>
> # Creamos el grupo "bomberos" en el dominio
> sudo samba-tool group add bomberos
> # Le asignamos un GID diferente
> sudo samba-tool group addunixattrs bomberos 3002
> ```
>
> > [!tip] 💡 ¿Qué hace el comando `addunixattrs`?
> > - **`group addunixattrs`:** Es el comando que "traduce" el grupo de Windows al mundo Linux, dándole un número de identidad (GID) que el sistema de archivos puede entender. Sin este número, Linux simplemente ignoraría al grupo.

> [!example] Paso 3: Creación de Usuarios con Mapeo Correcto
> Creamos dos usuarios: `user1` pertenecerá al grupo `policia` y `user2` al grupo `bomberos`. Esto nos permitirá demostrar en la Fase 7 que cada uno ve carpetas diferentes:
> ```bash
> # Creamos user1 asignando su UID y el GID del grupo policia
> sudo samba-tool user create user1 'P@ssw0rd' --uid-number=10001 --gid-number=3001
>
> # Creamos user2 asignando su UID y el GID del grupo bomberos
> sudo samba-tool user create user2 'P@ssw0rd' --uid-number=10002 --gid-number=3002
>
> # Añadimos cada usuario a su grupo correspondiente
> sudo samba-tool group addmembers policia user1
> sudo samba-tool group addmembers bomberos user2
> ```
>
> > [!important] 💡 ¿Por qué usar `--uid-number`?
> > **Corrección Crítica:** Usar `--uid-number` asegura que el mapeo entre el usuario de Active Directory y el usuario de Linux sea exacto y permanente. Sin este parámetro, el sistema podría asignar IDs aleatorios y perderíamos el control de los permisos.

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿Los usuarios no funcionan?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `id user1` no devuelve nada. | El `winbind` no está en `/etc/nsswitch.conf` o el servicio no está activo. | Comprueba el Paso 1 y verifica que las líneas `passwd` y `group` incluyen `winbind`. Luego ejecuta `sudo systemctl status winbind`. |
> | Error: "Password too weak". | La política de AD exige complejidad. | Usa una contraseña con mayúsculas, números y símbolos como `P@ssw0rd`. |
> | Error: "Group already exists". | El grupo se creó en un intento anterior. | Ejecuta `sudo samba-tool group delete policia` y vuelve a crearlo. |
> | Error de esquema LDAP en `addunixattrs` ("no such attribute" o similar). | El dominio se provisionó sin el flag RFC 2307. | El script de la Fase 4 debe haberse ejecutado con `--use-rfc2307`. Vuelve a la Fase 4, borra el dominio con `sudo samba-tool domain demote` y ejecuta de nuevo el script. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué es mejor y más profesional dar permisos a un grupo que a un usuario individual?
> 2. ¿Qué es el servicio **winbind** y por qué decimos que es el "traductor" del sistema?
> 3. 🔬 **Reto práctico:** Ejecuta `id user1` e `id user2` en el servidor. Anota el UID y GID de cada uno. Ahora crea un archivo vacío dentro de `/srv/samba/prueba1/` con `sudo -u 'BOOCHANLAB\user1' touch /srv/samba/prueba1/test_user1.txt` y ejecuta `ls -la /srv/samba/prueba1/`. ¿A qué usuario y grupo pertenece el archivo? ¿Coincide con los IDs que anotaste?
> 4. 🔬 **Reto práctico:** Intenta crear un usuario sin especificar UID: `sudo samba-tool user create user3 'P@ssw0rd'`. Luego ejecuta `id user3`. ¿Qué UID recibe? ¿Puedes predecir qué UID tendrá el próximo usuario sin especificarlo? ¿Por qué esto es un problema en un servidor de producción con permisos de carpetas?
> 5. ¿Cómo verificarías en la terminal que un usuario de Samba es reconocido por el comando `ls -l`?

---

> [!caution] 🛑 Auditoría y Evaluación (RA.02)
> El alumno debe demostrar que el servidor reconoce a los usuarios del dominio como si fueran locales. **Validación:** El comando `id user1` debe devolver el UID y GID configurados manualmente.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de verificar los usuarios, comprueba que el servicio traductor está activo. Si no lo está, el comando `id` devolverá vacío aunque los usuarios existan perfectamente:
> ```bash
> sudo systemctl status winbind
> ```
> Busca la línea `Active: active (running)`. Si dice `inactive` o `failed`, arráncalo:
> ```bash
> sudo systemctl enable winbind --now
> ```
> - [ ] ¿El comando `id user1` devuelve correctamente `uid=10001` y `gid=3001`?
> - [ ] ¿El comando `id user2` devuelve correctamente `uid=10002` y `gid=3002`?
> - [ ] ¿El archivo `/etc/nsswitch.conf` tiene `winbind` en las líneas `passwd` y `group`?

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-5-gestion-de-identidades-usuarios-y-grupos.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 5 — Gestión de Identidades (Usuarios y Grupos)`, con presentación, identidad y timestamps |
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
