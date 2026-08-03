## 💻 Fase 8: Integración del Cliente (Windows 11)

### Infraestructura de Laboratorio Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Linux como servidor de dominio / Linux como cliente de dominio]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (creación de VM + teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VirtualBox instalado en el equipo | ISO de Windows 11 | 4 GB RAM libres para la nueva VM | 40 GB de disco libres | Samba completo (Fases 1-7)

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.06`** *(pesa un **12 %** del módulo · UD7)*
> *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> Esta es **la fase central del RA.06**, y la única de todo el itinerario donde un Windows y un Linux trabajan juntos de verdad. Toca **6 de los 9 criterios** del RA.06, y de paso cierra un criterio del `RA.02` y otro del `RA.04` que quedaban pendientes.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.06.a` | Se ha identificado la necesidad de compartir recursos en red entre diferentes sistemas operativos. | El caso de partida: por qué el cliente Windows necesita los datos que vive en el servidor Linux |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | `ping` Windows ↔ Ubuntu por la Red Solo Anfitrión antes de unir nada |
> | `CE.06.c` | Se ha descrito la funcionalidad de los servicios que permiten compartir recursos en red. | Explicar qué hacen SMB, LDAP y Kerberos en esta unión |
> | `CE.06.d` | Se han instalado y configurado servicios para compartir recursos en red. | Unir el Windows 11 al dominio y montar los recursos compartidos |
> | `CE.06.e` | Se ha accedido a sistemas de archivos en red desde equipos con diferentes sistemas operativos. | Abrir desde el Explorador de Windows las carpetas que sirve el Samba de Ubuntu |
> | `CE.06.i` | Se ha comprobado el funcionamiento de los servicios instalados. | Iniciar sesión como `user1` del dominio y comprobar que ve lo suyo y no lo ajeno |
> | `CE.02.c` | Se han configurado y gestionado cuentas de equipo. | **Unir el PC al dominio crea una cuenta de equipo**, no de usuario. Es el único sitio del itinerario donde se ve |
> | `CE.04.e` | Se ha utilizado el entorno gráfico para compartir recursos. | Toda la parte de Windows: el Explorador, no la consola |
>
> **Los 3 del RA.06 que NO se evalúan aquí:** `CE.06.f` (impresoras entre sistemas distintos) y `CE.06.g` (trabajo en grupo) no se trabajan en este itinerario; `CE.06.h` (niveles de seguridad de acceso) se demuestra en la **Fase 3** y en la **Auditoría Final**.

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-8-integracion-del-cliente-windows-11.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 8 de Boochan V1 — Integración del Cliente (Windows 11)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 8 — Integración del Cliente (Windows 11)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 7
> El servidor Linux es ahora un "reino" completo: dominio `BOOCHANLAB.LOCAL`, usuarios, grupos, discos protegidos, y permisos granulares. Todo está funcionando perfectamente desde la terminal. Sin embargo, todavía no existe ningún cliente que se beneficie de ese dominio — solo hay una VM en VirtualBox: el servidor. Ahora toca crear una **segunda VM**, esta vez con Windows 11, para que los usuarios del aula tengan un puesto de trabajo real.

> [!warning] El Problema
> Windows y Linux hablan idiomas diferentes de seguridad. Windows necesita: (1) encontrar el servidor por DNS, (2) sincronizar el reloj exactamente (Kerberos rechaza diferencias > 5 minutos), (3) establecer una "relación de confianza" registrándose en Active Directory, (4) permitir que los usuarios inicien sesión con sus credenciales de dominio. Si algo falla, el usuario ve "No se encuentra el dominio" o "Error de relación de confianza".

> [!success] Objetivo de esta Fase
> **Crear una VM de Windows 11 en VirtualBox y unirla al dominio BOOCHANLAB.LOCAL**, de forma que los usuarios puedan iniciar sesión con sus credenciales de dominio (ej. `BOOCHANLAB\user1`) y acceder a las carpetas compartidas del servidor con los permisos que se les asignaron en Linux. Es el momento de la verdad: la infraestructura híbrida (Linux servidor + Windows cliente), ambas viviendo como VMs dentro del mismo VirtualBox, funcionando en sinergia.

> [!tip] Hoja de Ruta
> 1. **Crear la VM cliente:** Windows 11, 4 GB RAM, 40 GB de disco, dos adaptadores de red (Red Solo Anfitrión + NAT)
> 2. **Instalar Windows 11** en la nueva VM (si no la tenías ya preparada)
> 3. **Configurar IP y DNS:** IP fija `10.10.10.20` en el adaptador de Red Solo Anfitrión, DNS apuntando a `10.10.10.10` (el servidor)
> 4. **Sincronizar reloj:** Ejecutar `w32tm /resync /force` para emparejar la hora exactamente con el servidor
> 5. **Unir al dominio:** A través de Configuración → Sistema → Acerca de, introducir `BOOCHANLAB.LOCAL` y credenciales de Administrator
> 6. **Reiniciar Windows:** Obligatorio para aplicar los cambios de dominio
> 7. **Primer login:** Iniciar sesión con `BOOCHANLAB\user1` y su contraseña desde la pantalla de inicio
> 8. **Instalar RSAT:** Herramientas administrativas para gestionar usuarios/grupos desde Windows gráficamente
> 9. **Mapear carpetas de red:** Conectar `\\UbuntuServer.BOOCHANLAB.LOCAL\prueba1` y `prueba3` como unidades de red (Z:, por ejemplo)
>
> **Resultado Final:** Windows 11 es ahora un cliente legítimo del dominio, viviendo como una VM más dentro de tu VirtualBox local. Los usuarios pueden iniciar sesión, acceder a carpetas según sus permisos de grupo, y crear archivos que el servidor Linux reconoce automáticamente.
> **Siguiente:** Fase completada — el proyecto es funcional de extremo a extremo. Servidor Linux como DC, usuarios en AD, almacenamiento seguro, y clientes Windows integrados. Solo queda la Auditoría Final de seguridad.

---

### 📚 Fundamento Teórico

> [!abstract] 1. Dos VMs, una Red Solo Anfitrión
> A diferencia de un despliegue en la nube (donde el cliente Windows sería un PC físico del aula conectándose por Internet y VPN), aquí **el cliente Windows 11 es otra máquina virtual** dentro del mismo VirtualBox que el servidor. Ambas VMs comparten la misma **Red Solo Anfitrión (Host-Only)** de VirtualBox — la misma red `vboxnet0` que ya creaste y configuraste en la Fase 1 — un cable de red virtual que conecta servidor, cliente y tu propio ordenador. Esto es clave porque los equipos de Consellería de las aulas no dan permisos de administrador sobre el sistema físico (el host): todo lo que se pueda tocar o romper debe vivir *dentro* de las VMs, nunca en el host.

> [!important] 2. ¿Por qué esta vez NO hace falta VPN?
> En BoochanV2/V3 (servidor en la nube), el cliente Windows estaba en un PC físico distinto, conectado a Internet, y necesitaba el túnel WireGuard para "entrar" en la red privada del servidor. Aquí no: el cliente Windows 11 **ya vive dentro de la misma Red Solo Anfitrión que el servidor** (`10.10.10.0/24`), así que hablan directamente, sin cifrado adicional ni túnel de por medio. El túnel WireGuard (`10.20.20.1` / `10.20.20.2`) que configuraste en fases anteriores sigue existiendo — pero es para el acceso *remoto* de administración desde tu equipo host, no para que el cliente de dominio funcione.

> [!warning] 3. Sincronización Horaria (NTP)
> Kerberos (el sistema de tickets) utiliza marcas de tiempo para evitar ataques. Si el reloj del PC y el del Servidor varían más de **5 minutos (Clock Skew)**, la comunicación se cortará por seguridad y no podrás iniciar sesión. Esto es especialmente fácil que ocurra en VirtualBox: las VMs paradas o suspendidas pierden la noción del tiempo real y hay que forzar la resincronización al arrancarlas.

> [!important] 4. DNS: El Guía de la Red
> Windows debe usar el DNS del servidor (`10.10.10.10`) para poder encontrar al "Rey" (el Controlador de Dominio). Si usa el DNS que le entregue por DHCP el adaptador NAT (que apunta a Internet), jamás encontrará el servidor `BOOCHANLAB.LOCAL`.

### 📖 Diccionario de Conceptos Clave

> [!quote] Integración de Clientes
> - **Unirse al Dominio:** Proceso de registrar un ordenador cliente en la base de datos central del Directorio Activo.
> - **Clock Skew:** El desfase de tiempo máximo permitido por seguridad (300 segundos = 5 minutos).
> - **RSAT:** Herramientas de administración remota para gestionar el dominio Linux desde la interfaz gráfica de Windows.
> - **net use:** Comando de consola para conectar carpetas compartidas como si fueran discos locales.
> - **Red Solo Anfitrión (Host-Only Adapter):** Modo de red de VirtualBox que crea una red privada entre el host y las VMs que se conectan a la misma red host-only (aquí, `vboxnet0`) — no sale a Internet, pero sí es visible desde el host.

---

### 🖥️ Creación de la VM Cliente (VirtualBox)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-8-integracion-del-cliente-windows-11.md`) con su estructura, vacía.
> 2. **Léete los 6 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 0: Crear la máquina virtual Windows 11
> Antes de tocar nada de dominio, necesitas una segunda VM. Ábrela así:
>
> 1. En VirtualBox, pulsa **"Nueva"**.
> 2. **Nombre:** `Cliente-Windows11` — Tipo: `Microsoft Windows` — Versión: `Windows 11 (64-bit)`.
> 3. **Memoria RAM:** `4096 MB` (4 GB). Es el mínimo razonable para que Windows 11 no vaya "a tirones" dentro de una VM; si tu equipo host tiene 16 GB o más, puedes subir a 6144 MB.
> 4. **Procesadores:** 2 CPUs (Windows 11 exige al menos 2 núcleos lógicos para instalarse).
> 5. **Disco duro:** crear uno nuevo, tipo VDI, **reservado dinámicamente**, de **40 GB**. Dinámico porque no ocuparán los 40 GB reales hasta que se necesiten — importante si tu disco del host anda justo de espacio.
> 6. Activa **TPM 2.0** y **Secure Boot** en la configuración del sistema de la VM (Windows 11 los exige para instalarse; VirtualBox los emula desde la versión 7).
> 7. Monta la ISO de Windows 11 en la unidad óptica virtual e instala el sistema con una cuenta local (no uses cuenta Microsoft — así evitas depender de Internet durante la instalación).
>
> > [!tip] 💡 ¿Por qué 4 GB de RAM y 40 GB de disco?
> > Es la configuración mínima recomendada por Microsoft para Windows 11 (4 GB RAM / 64 GB disco), ajustada a la baja en disco porque en este laboratorio no vamos a instalar software pesado adicional — solo el sistema, RSAT y las herramientas de red. Si tu equipo host tiene recursos de sobra, generosidad extra en RAM (6-8 GB) hace que la experiencia sea más fluida.

> [!example] Paso 0.1: Configurar los dos adaptadores de red de la VM
> Con la VM apagada, ve a **Configuración → Red** y configura **dos adaptadores**:
>
> | Adaptador | Modo | Nombre de red | Para qué sirve |
> | :--- | :--- | :--- | :--- |
> | **Adaptador 1** | Red Solo Anfitrión (*Host-only Adapter*) | `vboxnet0` — la misma red host-only que ya creaste y configuraste en la Fase 1 | Hablar con el servidor: dominio, DNS, SMB, Kerberos |
> | **Adaptador 2** | NAT | — | Salida a Internet: activación de Windows, Windows Update, descarga de RSAT |
>
> > [!important] ⚠️ Selecciona la misma red `vboxnet0`, no crees una red nueva
> > No hace falta crear ninguna red nueva ni inventar un nombre propio: en el Adaptador 1, selecciona **`Red Solo Anfitrión`** y, en el desplegable de nombre de red, elige **`vboxnet0`** — la misma red host-only que configuraste manualmente en la Fase 1 (IP del host `10.10.10.1/24`, DHCP desactivado) y a la que ya está conectado el servidor. Al compartir exactamente la misma red host-only, servidor, cliente y tu propio ordenador se ven entre sí sin ningún paso adicional.
>
> > [!tip] 💡 ¿Por qué añadimos un adaptador NAT si el proyecto es "todo local"?
> > Decisión de diseño: sin salida a Internet, Windows 11 no puede activarse, no puede descargar actualizaciones ni instalar las **RSAT** (Paso 8, más abajo, requiere descargar un paquete desde los servidores de Microsoft). El adaptador NAT resuelve esto sin comprometer la seguridad del laboratorio: NAT es una salida *unidireccional* — nadie desde fuera puede entrar hacia la VM a través de él salvo que configures explícitamente un reenvío de puertos (Port Forwarding), cosa que no vamos a hacer en el cliente. El tráfico de dominio (DNS, Kerberos, SMB) sigue viajando exclusivamente por el Adaptador 1 (Red Solo Anfitrión), nunca por el NAT.

---

### 🛠️ Procedimiento Práctico

> [!example] Paso 1: Configuración de IP y DNS en Windows
> Con Windows 11 ya instalado y arrancado, configura el adaptador de Red Solo Anfitrión con una IP fija dentro del rango del servidor:
>
> 1. Haz clic en el icono de **Red** de la barra de tareas → **"Configuración de red e Internet"**.
> 2. Verás dos adaptadores (uno por cada tarjeta de red virtual). Identifica el que corresponde a la **Red Solo Anfitrión** — normalmente el que no tiene salida a Internet — y haz clic en **"Editar"** junto a "Asignación de IP".
> 3. Cambia "Automático (DHCP)" a **"Manual"**, activa **IPv4** e introduce:
>    - **Dirección IP:** `10.10.10.20`
>    - **Máscara de subred:** `255.255.255.0` (equivalente a `/24`)
>    - **Puerta de enlace:** déjala en blanco (no la necesitas para el adaptador de Red Solo Anfitrión; la salida a Internet la da el otro adaptador, el NAT)
>    - **DNS preferido:** `10.10.10.10`
>    - **DNS alternativo:** déjalo vacío en este adaptador
> 4. Pulsa **"Guardar"**.
>
> > [!tip] 💡 ¿Por qué IP fija y no DHCP?
> > El servidor Samba AD DC de este proyecto no está configurado como servidor DHCP (ver Fases 1-7). Por eso asignamos la IP manualmente. Si en una fase anterior activaste un rango DHCP en el servidor, puedes usarlo, pero asegúrate de que la IP resultante siga en el rango `10.10.10.0/24` y de fijar el DNS a `10.10.10.10`.
>
> > [!tip] 💡 Verifica que el DNS funciona
> > Abre el Símbolo del sistema (`cmd`) y ejecuta:
> > ```cmd
> > nslookup BOOCHANLAB.LOCAL
> > ```
> > Si devuelve la IP `10.10.10.10`, el DNS está funcionando. Si dice "no se encuentra el servidor", revisa que el adaptador de Red Solo Anfitrión esté bien configurado (Paso 0.1) y que el servidor esté encendido.

> [!example] Paso 2: Sincronización de Tiempo
> Ejecuta este comando en el **Símbolo del sistema (CMD) como Administrador**:
>
> *(Para abrirlo como Administrador: pulsa `Windows + X` → "Terminal de Windows (Administrador)" o busca "cmd" en el menú inicio, haz clic derecho → "Ejecutar como administrador")*
>
> > [!info] 📚 Diccionario de Comandos: Recuerda que también tienes explicados los comandos vitales de Windows (`w32tm`, `nslookup`) en el [[Diccionario_Comandos_Sistema]].
>
> ```cmd
> w32tm /resync /force
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`w32tm`:** Es la herramienta de gestión del tiempo de Windows. El parámetro `/resync /force` obliga al PC a emparejar su reloj con el del Controlador de Dominio inmediatamente, ignorando cualquier restricción.
>
> > [!caution] ⚠️ VMs pausadas o congeladas
> > Si dejaste la VM del cliente en pausa (Guardar estado) durante días, su reloj interno se habrá quedado "congelado" en el momento en que la pausaste. Al reanudarla, ejecuta este paso sin falta antes de intentar unirte al dominio.

> [!example] Paso 3: Unión al Dominio
> 1. Abre **Configuración** (tecla `Windows + I`).
> 2. Ve a **Sistema** → **Acerca de**.
> 3. Haz clic en **"Cambiar nombre de este PC (avanzado)"** → pestaña **"Nombre de equipo"** → botón **"Cambiar..."**.
> 4. Selecciona **"Dominio"** e introduce: `BOOCHANLAB.LOCAL`
> 5. Pulsa **Aceptar**. Te pedirá credenciales: introduce `Administrator` y `P@ssw0rd`.
> 6. Si aparece el mensaje **"Bienvenido al dominio BOOCHANLAB"**, el proceso ha sido correcto.
> 7. **Reinicia el equipo** cuando te lo pida. Este paso es obligatorio.
>
> > [!important] 💡 El reinicio es obligatorio
> > Sin reiniciar, Windows no aplica los cambios del dominio. Al volver a encender el PC, en la pantalla de inicio de sesión verás la opción de iniciar sesión con un usuario del dominio.

> [!example] Paso 4: Primer Inicio de Sesión con Usuario del Dominio
> > [!caution] ⚠️ El servidor debe estar encendido y la Red Solo Anfitrión conectada
> > Al iniciar sesión con `BOOCHANLAB\user1`, Windows necesita contactar con el servidor en `10.10.10.10` para validar las credenciales. Comprueba que la VM del servidor está arrancada y que el Adaptador 1 (Red Solo Anfitrión) del cliente sigue conectado (icono de red sin aspa roja) antes de introducir el usuario y la contraseña.
>
> En la pantalla de inicio de sesión de Windows, introduce las credenciales del usuario del dominio. Fíjate en el formato correcto:
>
> - **Usuario:** `BOOCHANLAB\user1`  *(el nombre NetBIOS del dominio, una barra invertida `\`, y el nombre de usuario)*
> - **Contraseña:** `P@ssw0rd`
>
> > [!warning] ⚠️ La barra invertida `\`, no la barra normal `/`
> > La barra invertida se escribe con la tecla que tiene el símbolo `\` en tu teclado (normalmente junto al `Intro` o junto al `0`). Si usas la barra normal `/`, no funcionará.

> [!example] Paso 5: Instalación de RSAT (Herramientas de Administración)
> RSAT permite gestionar usuarios y grupos del dominio directamente desde Windows, con una interfaz gráfica. Requiere el adaptador NAT activo (Paso 0.1) para descargar el paquete desde Internet. Instálalo así:
>
> 1. Ve a **Configuración** → **Aplicaciones** → **Características opcionales**.
> 2. Haz clic en **"Ver características"**.
> 3. Busca `RSAT` en el cuadro de búsqueda.
> 4. Instala **"RSAT: Herramientas de Servicios de dominio de Active Directory y Lightweight Directory"**.
> 5. Pulsa **"Instalar"** y espera a que termine.
>
> Una vez instalado, encontrarás las herramientas buscando **"Usuarios y equipos de Active Directory"** en el menú Inicio.

> [!example] Paso 6: Mapeo de Carpetas de Red
> Con el usuario del dominio iniciado, conecta las carpetas del servidor como si fueran discos locales. Abre el **Símbolo del sistema (CMD)** y ejecuta:
> ```cmd
> net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\prueba1 /user:BOOCHANLAB\user1
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`Z:`**: Asigna una letra de unidad libre (como un disco duro más).
> > - **`\\UbuntuServer.BOOCHANLAB.LOCAL\prueba1`**: Es la ruta UNC (la dirección de la carpeta en la red). Usamos el nombre del servidor en lugar de la IP para que Windows use Kerberos (el sistema de tickets seguro) en lugar de un protocolo más antiguo y menos fiable.
> > - **`/user:BOOCHANLAB\user1`**: Especifica con qué identidad del dominio queremos entrar.

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿No puedes unirte?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | "No se encuentra el dominio". | El adaptador de Red Solo Anfitrión no está bien configurado o no apunta a la red `vboxnet0`. | Revisa el Paso 0.1: el Adaptador 1 debe estar en modo `Red Solo Anfitrión` con la red `vboxnet0` seleccionada, igual que en el servidor. |
> | "No se encuentra el dominio" aunque la red parece bien. | El DNS del cliente apunta al adaptador NAT en vez de al servidor. | Comprueba que el DNS preferido del adaptador de Red Solo Anfitrión es `10.10.10.10` (Paso 1). |
> | "Error de relación de confianza". | Desfase horario (Clock Skew) superior a 5 minutos — muy típico tras reanudar una VM pausada. | Ejecuta `w32tm /resync /force` (Paso 2) antes de reintentar. |
> | La unidad `Z:` no aparece al reiniciar. | El mapeo no es persistente. | Añade `/persistent:yes` al final del comando `net use`. |
> | RSAT no se descarga / se queda "buscando actualizaciones". | El adaptador NAT no está activo o no tiene salida a Internet. | Comprueba que el Adaptador 2 (NAT) está conectado en la configuración de la VM y que el host tiene Internet. |
> | Las dos VMs no se ven entre sí aunque ambas tienen "Red Solo Anfitrión". | El cliente está conectado a una red host-only distinta (por ejemplo `vboxnet1`) en lugar de `vboxnet0`. | Corrígelo en VirtualBox → Configuración → Red → Adaptador 1 → Nombre: selecciona `vboxnet0`, la misma red que usa el servidor. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué en este proyecto el cliente Windows no necesita el túnel WireGuard para unirse al dominio, a diferencia de BoochanV2/V3?
> 2. ¿Qué sucede técnica y exactamente si hay más de 5 minutos de diferencia horaria entre cliente y servidor?
> 3. ¿Para qué sirven las herramientas **RSAT** en esta infraestructura híbrida, y por qué necesitas el adaptador NAT para instalarlas?
> 4. ¿Qué riesgo de seguridad existiría si, en lugar de un segundo adaptador NAT, hubieras usado un único adaptador en modo "Adaptador Puente" (*Bridged*) conectado directamente a la red del centro?
> 5. 🔬 **Reto práctico:** Con `user1` iniciado en Windows, crea un archivo de texto en la unidad `Z:` (por ejemplo `prueba_user1.txt`). Sin cerrar Windows, entra al servidor por SSH (puedes hacerlo desde el propio host a través del túnel WireGuard) y ejecuta `ls -la /srv/samba/prueba1/`. ¿Ves el archivo? ¿A qué usuario Linux pertenece según la columna de propietario? ¿Coincide con el UID que configuraste en la Fase 5?
> 6. 🔬 **Reto práctico:** Con `user1` logueado y la unidad `Z:` mapeada, **apaga el Adaptador 1 (Red Solo Anfitrión)** de la VM cliente desde VirtualBox (Dispositivos → Red → sin conectar), sin cerrar sesión de Windows. Intenta abrir un archivo de la unidad `Z:`. ¿Qué error aparece? ¿Qué diferencia hay con lo que le pasaría a un usuario real de empresa cuya "carpeta compartida desaparece" por caerse la VPN?

---

> [!caution] 🛑 Auditoría de Integración (RA.06)
> **Validación:** El alumno debe loguearse con `user1` en la VM de Windows 11 y demostrar que puede crear un archivo en la unidad `Z:` que luego sea visible en el servidor Linux con `ls /srv/samba/prueba1`. Además, debe demostrar que `user2` (bomberos) no ve la carpeta `prueba3` en el explorador de archivos.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿Has creado la VM cliente con los dos adaptadores de red correctamente configurados (Red Solo Anfitrión + NAT)?
> - [ ] ¿Te has podido unir al dominio sin errores de DNS?
> - [ ] ¿La unidad de red `Z:` aparece en el explorador de archivos?
> - [ ] ¿`user1` puede crear archivos en `Z:` y se ven desde el servidor Linux?
> - [ ] ¿`user2` no ve la carpeta `prueba3` al navegar por la red?

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-8-integracion-del-cliente-windows-11.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 8 — Integración del Cliente (Windows 11)`, con presentación, identidad y timestamps |
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
