## 🛡️ Auditoría Final y Hardening (Cierre de Seguridad)

> **[RA.06]** Diseña e implementa soluciones de seguridad perimetral y auditoría de sistemas.

### 📚 Fundamento Teórico: El Principio de "Zero Trust"

Para terminar el proyecto, debemos aplicar la filosofía **Zero Trust** (Confianza Cero). Hasta ahora, hemos priorizado que todo funcione: hemos dejado el servidor accesible desde cualquier interfaz de red para facilitar la configuración inicial. Un administrador profesional, una vez terminado el trabajo, debe "cerrar el castillo" y solo permitir el paso a quien esté dentro de la muralla — en este proyecto, eso significa la Red Solo Anfitrión del laboratorio (`10.10.10.0/24`) y el túnel VPN de administración (`10.20.20.0/24`).

> [!info] Diferencia con BoochanV2/V3
> En los proyectos en la nube (Azure/AWS), este hardening se hacía **fuera** del servidor, restringiendo el Grupo de Seguridad (NSG/Security Group) del proveedor cloud. Aquí no existe ese firewall externo: **VirtualBox no filtra el tráfico entre el host y las VMs de una misma Red Solo Anfitrión**, así que el filtrado tiene que hacerse **dentro** del propio Ubuntu Server, con su firewall local: **`ufw`** (*Uncomplicated Firewall*).

### 📖 Diccionario de Conceptos Clave

- **Hardening:** El proceso de "endurecer" un servidor eliminando servicios innecesarios y cerrando puertos.
- **Whitelist (Lista Blanca):** Configuración que bloquea todo por defecto y solo permite el paso a IPs u orígenes específicos.
- **Zero Trust:** Estrategia de seguridad que asume que la red ya está comprometida y exige verificación constante.
- **ufw (Uncomplicated Firewall):** Interfaz simplificada sobre `iptables`/`nftables` para gestionar el firewall de un servidor Linux con reglas legibles.
- **Adaptador NAT (VirtualBox):** Adaptador de red del servidor que le da salida a Internet (para actualizaciones, `apt`, etc.). Es también, potencialmente, la puerta que quedó abierta durante el desarrollo del proyecto si en algún momento reenviaste puertos desde el host hacia la VM (*Port Forwarding*).

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-auditoria-final-hardening-y-cierre-de-seguridad.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Auditoría Final de Boochan V1 — Hardening y cierre de seguridad."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Auditoría Final — Hardening y cierre de seguridad`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🛠️ Procedimiento Práctico de Hardening

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-auditoria-final-hardening-y-cierre-de-seguridad.md`) con su estructura, vacía.
> 2. **Léete los 4 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Revisión del adaptador NAT del servidor
> Antes de tocar el firewall, comprueba en VirtualBox → tu VM de servidor → **Configuración → Red** qué reglas de reenvío de puertos (*Port Forwarding*) tiene configuradas el Adaptador NAT (si usaste alguna en fases anteriores para conectar por SSH desde el host, por ejemplo `127.0.0.1:2222 → 10.10.10.10:22`).
>
> > [!warning] ⚠️ El Port Forwarding es tu única "puerta al exterior"
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

### ❓ Preguntas Críticas de Cierre
1. ¿Por qué en este proyecto el hardening final se hace con `ufw` dentro del servidor, y no con un firewall externo como en BoochanV2/V3?
2. ¿Qué diferencia de seguridad hay entre dejar el puerto `51820/udp` abierto "a cualquiera" y dejar el puerto `445` (SMB) abierto "a cualquiera"? ¿Por qué el primero es aceptable y el segundo no?
3. Si después de activar `ufw` ya no puedes conectar por SSH al servidor, ¿qué es lo primero que deberías comprobar sobre tu propia conexión?
4. ¿Qué significa que un servidor esté "bastionado" (*Hardened*)?
5. ¿Qué proceso es el dueño del puerto 445 según el comando `ss -tunlp`?
6. Si en algún momento configuraste un reenvío de puertos (*Port Forwarding*) en el adaptador NAT del servidor para administrarlo desde el host, ¿por qué debe revisarse esa regla en una auditoría final, aunque `ufw` ya esté activo dentro de la VM?

---

> [!success] 🏁 Proyecto Finalizado
> ¡Enhorabuena! Has construido una infraestructura híbrida profesional, segura y escalable, esta vez completamente local: dos VMs en VirtualBox comunicándose por una Red Solo Anfitrión aislada. Has pasado de tener un servidor vacío a un Controlador de Dominio con cuotas de disco, seguridad ACL invisible y un cliente Windows 11 integrado, todo ello protegido por un firewall local (`ufw`) que solo confía en la Red Solo Anfitrión del laboratorio y en el túnel cifrado WireGuard.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-auditoria-final-hardening-y-cierre-de-seguridad.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Auditoría Final — Hardening y cierre de seguridad`, con presentación, identidad y timestamps |
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
