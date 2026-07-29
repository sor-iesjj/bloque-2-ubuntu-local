## 🧹 Fase 2: Purga y Preparación del Entorno

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5: Administración en Linux - Instalación y Configuración]**
> **[RA.02]** Gestiona usuarios y grupos, interpretando especificaciones y aplicando herramientas del sistema.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,25 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM VirtualBox encendida | Conectividad a internet vía adaptador NAT | SSH o consola de VirtualBox

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-2-purga-y-preparacion-del-entorno.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 2 de Boochan V1 — Purga y Preparación del Entorno."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 2 — Purga y Preparación del Entorno`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 1
> Creaste una máquina virtual con Ubuntu Server 24.04 LTS en VirtualBox, con dos adaptadores de red: uno de **Red Solo Anfitrión** con la IP estática `10.10.10.10/24` (para hablar con la futura VM cliente Windows 11 y con tu propio ordenador) y otro **NAT** (para salir a internet y actualizar paquetes). La VM está encendida y accesible. Pero viene "de fábrica" con software innecesario: servicios antiguos, demonios durmiendo, paquetes que consumirán RAM y podrían ser puertas de seguridad.

> [!warning] El Problema
> Ubuntu instala de serie Samba básico (para "compartir archivos entre amigos"). Este Samba primitivo ocupa el puerto 445, que tu futuro **Controlador de Dominio profesional** (Fase 4) necesitará. Además, servicios como CUPS (impresoras) o IMAP (correo) están dormidos pero activos, consumiendo recursos. El servidor tampoco sabe su identidad: `/etc/hosts` dice "localhost" sin un verdadero nombre de dominio.

> [!success] Objetivo de esta Fase
> **Purga:** Eliminar completamente Samba viejo, impresoras, CUPS, servicios heredados. **Identidad:** Configurar `/etc/hosts` para que el servidor sepa que se llama `UbuntuServer.BOOCHANLAB.LOCAL`. Esto es imprescindible porque Kerberos (Fase 4) valida identidades por nombre de dominio completo (FQDN).

> [!tip] Hoja de Ruta
> 1. Ejecutar `apt update && apt upgrade -y` (actualizar repositorio y parches de seguridad, usando el adaptador NAT)
> 2. Usar `apt purge` (no solo `remove`) para borrar Samba viejo, CUPS, servicios heredados
> 3. Ejecutar `apt autoremove` para limpiar dependencias huérfanas
> 4. Editar `/etc/hosts` e insertar: `10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer`
> 5. Verificar con `hostname -f` que devuelve exactamente `UbuntuServer.BOOCHANLAB.LOCAL`
> 6. Validar resolución: `ping UbuntuServer` y `ping UbuntuServer.BOOCHANLAB.LOCAL` responden
>
> **Resultado Final:** Servidor limpio, sin ruido de servicios heredados, con identidad de dominio establecida.
> **Siguiente:** Fase 3 (Conectividad VPN) — instalarás WireGuard para cifrar la comunicación con la futura VM cliente Windows 11.

---

### 📚 Fundamento Teórico Avanzado

> [!abstract] 1. Idempotencia: "La Pizarra Limpia"
> En la U.T. 5 aprendemos que un servidor profesional debe ser **idempotente** (puedes repetir el proceso y el resultado siempre será el mismo) y **predecible**. No podemos construir un rascacielos sobre los cimientos de una cabaña vieja.

> [!warning] 2. El Conflicto de Puertos (SMB 445)
> Muchas distribuciones Linux incluyen de serie servicios de archivos (Samba) para uso doméstico. Esto genera un conflicto:
> *   **El "Teléfono" de Red:** El puerto 445 (SMB) es el canal por el que Windows pide archivos.
> *   **El Conflicto:** Si un Samba básico ya está "escuchando" ese teléfono, nuestro potente Controlador de Dominio no podrá recibir llamadas y el sistema colapsará. La purga elimina el software viejo y sus configuraciones para liberar el puerto.

> [!tip] 3. Kerberos (krb5): El Taquillero del Cine
> Es el protocolo de autenticación que usa Windows. Imagínalo como un cine:
> *   **El KDC (Taquilla):** No vas directo a la sala. Primero vas a la taquilla, demuestras quién eres y compras un **Ticket (TGT)**.
> *   **El Ticket:** Se lo enseñas al acomodador (servidor de archivos). Él no necesita saber tu contraseña; solo necesita ver que tu ticket es oficial. Esto permite el **Single Sign-On (SSO)**: entrar una vez y acceder a todo.

> [!info] 4. Winbind: El Traductor de la ONU
> Linux y Windows hablan idiomas diferentes para identificar usuarios:
> *   **Windows:** Usa códigos largos (SIDs).
> *   **Linux:** Usa números cortos (UIDs).
> *   **La función:** Winbind actúa como traductor. Cuando llega un usuario de Windows, le dice a Linux: *"Este código raro equivale a nuestro número 10001"*. Sin este puente, Linux ignoraría a los usuarios de Windows.

> [!note] 5. ACLs y Atributos: Cirugía de Permisos
> En Linux básico usamos `rwx`, pero en una empresa eso se queda corto.
> *   **ACL (Access Control Lists):** Permiten permisos específicos: *"Juan lee, María escribe y Pedro borra"*, aunque no estén en el mismo grupo.
> *   **Atributos (attr):** Permiten guardar info extra que Samba necesita para "engañar" a Windows y que crea que el disco es NTFS (el formato de Windows).

> [!important] 6. El FQDN: Nombre y "Apellido" Digital
> Configurar el `/etc/hosts` es vital. Un servidor necesita un **FQDN (Fully Qualified Domain Name)** completo.
> *   **Nombre:** `UbuntuServer` | **Apellido:** `BOOCHANLAB.LOCAL` | **FQDN:** `UbuntuServer.BOOCHANLAB.LOCAL`
> Si Kerberos intenta dar un ticket para el nombre sin el "apellido", el sistema lo rechazará por falta de confianza.

> [!info] 7. `.LOCAL`: un dominio que no existe en internet (y así debe ser)
> A diferencia de `BOOCHAN.SPACE` (usado en las versiones cloud del proyecto, que sí es un dominio real registrado en internet), `BOOCHANLAB.LOCAL` es un **dominio privado**, inventado para este laboratorio, que **no es resoluble fuera de tu red virtual**. Esto es intencionado: un Active Directory de laboratorio no necesita —ni debe— ser accesible desde internet. El sufijo `.LOCAL` es una convención muy usada en redes internas de empresa para dejar claro que ese nombre solo tiene sentido dentro de las cuatro paredes de la organización (o, en tu caso, dentro de VirtualBox).

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología Profesional
> - **Demonio (Daemon):** Un programa que vive y trabaja en segundo plano sin que tú lo veas (ej. `smbd`).
> - **FQDN:** El nombre completo y único de tu servidor en la red.
> - **Apt Purge:** Comando "agresivo" que borra el software Y todos sus archivos de configuración.
> - **Winbind:** El servicio que hace de puente entre identidades Linux y Windows.
> - **Red Solo Anfitrión / Host-Only (VirtualBox):** Un adaptador de red virtual que crea una red privada entre el host (tu propio ordenador) y las VMs que la comparten — no tiene salida a internet, pero sí es visible desde el host. Es el "cable de red" que unirá tu servidor con la futura VM cliente Windows 11 y con tu propio ordenador.
> - **NAT (VirtualBox):** Adaptador que traduce el tráfico de la VM a través de la conexión de red de tu PC físico, dándole salida a internet sin exponerla directamente.

---

### 🛠️ Procedimiento Práctico (BoochanV1)

> [!important] 🔌 Antes de empezar: Conéctate al servidor
> Todos los comandos de esta fase se ejecutan **dentro de tu VM de VirtualBox**, no en tu PC físico. Puedes trabajar directamente en la ventana de consola de la VM, o bien abrir una terminal en tu PC y conectarte por SSH a la IP interna que configuraste en la Fase 1:
> ```bash
> ssh usuario@10.10.10.10
> ```
> Sustituye `usuario` por el nombre de usuario administrador que creaste durante la instalación de Ubuntu Server en la Fase 1. Cuando veas el símbolo `$` al final de la línea, ya estás listo para continuar.
>
> > [!tip] 💡 ¿Consola de VirtualBox o SSH?
> > Ambas opciones son válidas y hacen exactamente lo mismo. La consola de VirtualBox (la ventana de la VM) siempre funciona, incluso si la red todavía no está bien configurada. El SSH es más cómodo (puedes copiar y pegar comandos largos) pero requiere que la Red Solo Anfitrión ya esté operativa. Si tienes dudas de cuál usar, empieza por la consola de VirtualBox.

> [!example] Paso 1: Limpieza Total del Entorno
> Antes de construir, debemos demoler lo viejo. Ejecuta estos comandos para liberar los puertos y limpiar la caché:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta y ver ejemplos de `apt`, `systemctl` y `rm`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Detiene los servicios actuales (si no existen, el aviso es normal e inofensivo)
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
> # Elimina agresivamente Samba y sus restos
> sudo apt-get purge samba* -y
> sudo apt-get autoremove -y
> # Borra carpetas manuales para evitar residuos configurados
> sudo rm -rf /etc/samba/ /var/lib/samba/ /var/cache/samba/ /run/samba/
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **El asterisco (`samba*`):** Es un "comodín". Le dice a Linux: "Borra todo lo que empiece por la palabra samba". Así nos aseguramos de no dejar herramientas sueltas.
> > - **El comando `rm -rf`:** Es la "demolición total". Borra carpetas aunque no estén vacías. Lo usamos porque a veces el desinstalador se olvida de borrar las bases de datos antiguas que podrían dar errores después.
> > - **El `2>/dev/null || true` en el `systemctl stop`:** Si Samba no estaba instalado todavía en esta instalación limpia de Ubuntu, el comando daría un error inofensivo. Esta parte le dice a Linux "si falla, ignóralo y continúa". Es completamente normal ver ese paso sin ningún mensaje.

> [!example] Paso 2: Instalación de Dependencias Críticas
> Instalamos las herramientas que permiten a Linux "disfrazarse" de servidor Windows. Este comando necesita el adaptador **NAT** funcionando, ya que descarga paquetes de internet:
> ```bash
> sudo apt update && sudo apt install acl attr samba krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf -y
> ```
>
> > [!caution] ⚠️ Si el comando falla a mitad de la instalación
> > Este comando instala muchos paquetes a la vez. Si ves un error en rojo y la instalación se detiene, no entres en pánico. Ejecuta este comando para reparar los paquetes que quedaron a medias y vuelve a intentarlo:
> > ```bash
> > sudo apt --fix-broken install -y
> > sudo apt install acl attr samba krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf -y
> > ```
> >
> > **Si `apt update` da error de red:** comprueba que el adaptador **NAT** de la VM está conectado (`Configuración → Red → Adaptador 1` en VirtualBox) y que puedes hacer `ping 8.8.8.8` desde dentro de la VM. El adaptador de Red Solo Anfitrión (`10.10.10.10`) **no** da salida a internet por diseño — solo el NAT lo hace.
>
> > [!important] 💡 La pantalla azul de Kerberos (`krb5-config`)
> > En algún momento durante la instalación, **la pantalla se pondrá completamente azul** y aparecerá un formulario preguntando por el "Reino Kerberos por defecto". No te asustes, es normal. Sigue estos pasos exactos:
> > 1. El cursor estará en un campo de texto. Escribe `BOOCHANLAB.LOCAL` (**siempre en MAYÚSCULAS**).
> > 2. Pulsa la tecla `Tab` para seleccionar el botón `<Ok>` y luego pulsa `Enter`.
> > 3. Si aparecen más pantallas preguntando por servidores adicionales, déjalas en blanco y pulsa `Enter` para aceptar los valores por defecto.
> >
> > **¡Las mayúsculas son obligatorias!** Si escribes `boochanlab.local` en minúsculas, el sistema de seguridad Kerberos fallará más adelante y ningún usuario podrá autenticarse.
>
> > [!warning] ⚠️ Nota sobre `resolvconf` y el DNS del sistema
> > El paquete `resolvconf` que acabas de instalar puede entrar en conflicto con el servicio de DNS que Ubuntu trae por defecto (`systemd-resolved`). De momento no haremos nada; el script de la Fase 4 se encarga de resolver este conflicto automáticamente. Si en la Fase 4 el DNS no apunta a `127.0.0.1`, encontrarás el procedimiento de reparación en su tabla de troubleshooting.

> [!example] Paso 3: Configuración de la Identidad (FQDN)
> Debemos decirle al servidor quién es. Primero comprobamos que la IP estática de la Fase 1 sigue activa:
> ```bash
> # Muestra las IPs del servidor
> hostname -I
> ```
> > [!tip] 💡 ¿Qué IP anoto si aparecen varias?
> > Verás **dos IPs distintas**, una por cada adaptador de red de la VM:
> > - `10.10.10.10` → tu adaptador de **Red Solo Anfitrión**, la IP estática que fijaste en la Fase 1. **Es la que usaremos.**
> > - Algo del estilo `10.0.2.15` → tu adaptador **NAT**, dinámico, solo para salir a internet. No lo uses para el `/etc/hosts`.
> >
> > Si `10.10.10.10` no aparece, revisa la configuración de red de la Fase 1 (`/etc/netplan/`) antes de continuar — sin esa IP fija, el dominio de la Fase 4 no se levantará de forma estable.
>
> Ahora fijamos el nombre del servidor de forma permanente. Primero editamos el archivo que guarda el nombre corto:
> ```bash
> sudo nano /etc/hostname
> ```
> Borra lo que haya y escribe únicamente esto:
> ```
> UbuntuServer
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> A continuación abrimos el archivo de identidades de red:
> ```bash
> sudo nano /etc/hosts
> ```
> Dentro del archivo verás varias líneas existentes. **Añade la siguiente línea al final del archivo**:
> ```
> 10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> Verifica que el servidor se reconoce a sí mismo con el nombre completo:
> ```bash
> # Debe devolver: UbuntuServer.BOOCHANLAB.LOCAL
> hostname -f
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿Algo no va bien?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `apt purge` no encuentra Samba. | Samba no estaba instalado o ya lo borraste. | No te preocupes, verifica con `dpkg -l \| grep samba`. Si está vacío, perfecto. |
> | El nombre del servidor es incorrecto. | Error de escritura en `/etc/hostname` o `/etc/hosts`. | Ejecuta `hostname -f`. Debe devolver `UbuntuServer.BOOCHANLAB.LOCAL`. |
> | La pantalla azul de Kerberos no aparece. | Ya está configurado de una instalación anterior. | Ejecuta `sudo dpkg-reconfigure krb5-config` para reconfigurarlo. |
> | `apt update` no descarga nada / sin internet. | El adaptador NAT no está conectado o mal configurado. | En VirtualBox: `Configuración de la VM → Red → Adaptador 1` debe estar habilitado y en modo `NAT`. Reinicia la VM tras el cambio. |
> | `hostname -I` no muestra `10.10.10.10`. | La configuración estática de netplan de la Fase 1 no se aplicó o se perdió. | Revisa el archivo `.yaml` en `/etc/netplan/` y ejecuta `sudo netplan apply`. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Qué diferencia real hay entre un `apt remove` y un `apt purge`?
> 2. ¿Para qué sirve el archivo `/etc/hosts` en la resolución de nombres local (sin salir a Internet)?
> 3. ¿Por qué es crítico que el FQDN sea idéntico en todos los archivos de configuración futuros?
> 4. ¿Por qué usamos el sufijo `.LOCAL` en vez de un dominio real como `.SPACE` o `.COM` para este laboratorio?
> 5. 🔬 **Reto práctico:** Ejecuta `hostname -f` en el servidor. Compara la salida letra por letra con la línea que añadiste en `/etc/hosts`. ¿Coinciden exactamente, sin espacios ni diferencias de mayúsculas? Una sola diferencia hará que el dominio falle silenciosamente en la Fase 4 sin dar un error claro.
> 6. 🔬 **Reto práctico:** Ejecuta `ping UbuntuServer` y luego `ping UbuntuServer.BOOCHANLAB.LOCAL` desde el propio servidor. ¿Responden los dos? ¿A qué IP resuelven? Si uno falla y el otro no, ¿qué línea del `/etc/hosts` tienes mal configurada?

---

> [!caution] 🛑 Auditoría y Evaluación (RA.02)
> El alumno debe demostrar que el servidor resuelve su propio FQDN. **Riesgo Crítico:** Si el `hosts` no coincide con el dominio que instalaremos en la Fase 4, Kerberos jamás sacará tickets y el proyecto fallará.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿El comando `hostname -f` devuelve `UbuntuServer.BOOCHANLAB.LOCAL`?
> - [ ] ¿Has verificado que no hay servicios de Samba antiguos corriendo (`systemctl status smbd`)?
> - [ ] ¿`hostname -I` muestra la IP estática `10.10.10.10` del adaptador de Red Solo Anfitrión?

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-2-purga-y-preparacion-del-entorno.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 2 — Purga y Preparación del Entorno`, con presentación, identidad y timestamps |
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
