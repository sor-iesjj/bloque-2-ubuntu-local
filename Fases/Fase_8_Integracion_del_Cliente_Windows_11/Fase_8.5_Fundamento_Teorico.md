## Fase 8 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. Dos VMs, una Red Solo Anfitrión
> A diferencia de un despliegue en la nube (donde el cliente Windows sería un PC físico del aula conectándose por Internet y VPN), aquí **el cliente Windows 11 es otra máquina virtual** dentro del mismo VirtualBox que el servidor. Ambas VMs comparten la misma **Red Solo Anfitrión (Host-Only)** de VirtualBox — la misma red del laboratorio (`10.10.10.0/24`) que ya creaste y configuraste en la Fase 1 — un cable de red virtual que conecta servidor, cliente y tu propio ordenador. Esto es clave porque los equipos de Consellería de las aulas no dan permisos de administrador sobre el sistema físico (el host): todo lo que se pueda tocar o romper debe vivir *dentro* de las VMs, nunca en el host.

> [!important] 2. ¿Por qué esta vez NO hace falta VPN?
> En el Bloque 4 (servidor en la nube), el cliente Windows estaba en un PC físico distinto, conectado a Internet, y necesitaba el túnel WireGuard para "entrar" en la red privada del servidor. Aquí no: el cliente Windows 11 **ya vive dentro de la misma Red Solo Anfitrión que el servidor** (`10.10.10.0/24`), así que hablan directamente, sin cifrado adicional ni túnel de por medio. El túnel WireGuard (`10.20.20.1` / `10.20.20.2`) que configuraste en fases anteriores sigue existiendo — pero es para el acceso *remoto* de administración desde tu equipo host, no para que el cliente de dominio funcione.

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
> - **Red Solo Anfitrión (Host-Only Adapter):** Modo de red de VirtualBox que crea una red privada entre el host y las VMs que se conectan a la misma red host-only (aquí, la del laboratorio: `10.10.10.0/24`) — no sale a Internet, pero sí es visible desde el host.

---

### 🖥️ Creación de la VM Cliente (VirtualBox)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Abre la entrada de apuntes** que llevas escribiendo desde el índice (`b2-8-integracion-del-cliente.md`). Repasa lo que tienes: la teoría del apartado 5 la vas a necesitar ahora.
> 2. **Léete los 6 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!danger] 🛑 Paso 0 · ANTES DE NADA: la ISO tiene que ser **Windows 11 Pro**
> **Windows 11 Home NO puede unirse a un dominio.** No es una limitación de este laboratorio: Microsoft **quita esa función** de la edición Home. La opción *"Unirse a un dominio"* sencillamente **no existe** en ella.
>
> Y el problema no es que falle: es **cuándo** falla. La instalación va perfecta, tardas una hora, y te estrellas en el **Paso 5**, con todo hecho, sin forma de arreglarlo salvo **reinstalar**.
>
> **Vale:** `Windows 11 Pro` · `Enterprise` · `Education`. **No vale:** `Home`.
>
> Durante la instalación, cuando te pregunte la edición, **elige `Windows 11 Pro`**. Si la ISO no te da a elegir, es que trae una sola edición — compruébalo **antes** de instalar.
>
> **¿De dónde sale la ISO y cómo se comprueba que no está corrupta?** Ya lo hiciste en el **Bloque 1 · B1.04 — Descargar y verificar una ISO**. Mismo procedimiento.

> [!example] Paso 0.a: CREAR la máquina virtual *(asistente de VirtualBox)*
> En VirtualBox, pulsa **`Nueva`**:
>
> 1. **Nombre:** `Windows11` — **exactamente así, sin guiones ni espacios**.
> 2. **Carpeta:** la que te proponga. **Tipo:** `Microsoft Windows` · **Versión:** `Windows 11 (64-bit)`.
> 3. **Imagen ISO:** monta aquí tu ISO de Windows 11 Pro.
> 4. **Memoria RAM:** `4096 MB` · **Procesadores:** `2 CPU` *(Windows 11 no se instala con uno)*.
> 5. **Disco duro:** nuevo, **VDI**, **reservado dinámicamente**, **40 GB**.
>
> > [!tip] 💡 ¿De dónde salen esos números?
> > Microsoft pide para Windows 11 un mínimo de **4 GB de RAM, 2 núcleos y 64 GB de disco**. La RAM y los núcleos son los suyos; **el disco lo bajamos a 40 GB** porque aquí no vas a instalar nada pesado — solo el sistema, las RSAT y las herramientas de red.
> >
> > Y **dinámico** significa que esos 40 GB **no se ocupan de golpe**: el fichero crece según se usa. Lo comprobaste tú mismo en la **Fase 1.6.a** con el disco de Ubuntu.
>
> > [!danger] 🛑 Marca **«Omitir instalación desatendida»**. Es el atasco nº1 de esta fase
> > Al detectar una ISO de Windows, **VirtualBox 7 activa por su cuenta la instalación desatendida** y te pide una **Clave de producto** que no tienes. **Sin ella el asistente no te deja continuar**, y no dice por qué.
> >
> > Marca la casilla **`Omitir instalación desatendida`** *(«Skip Unattended Installation»)* y el campo desaparece. Instalas tú a mano, como toca.
> >
> > **Ya te pasó con Ubuntu** en el **Bloque 2 · Fase 1.6.a**: es exactamente la misma casilla. [[Fase_1.6.a_Procedimiento_Maquina_Virtual]]

> [!example] Paso 0.b: CONFIGURAR la VM *(ya creada, y APAGADA)*
> **Esto no está en el asistente.** `Configuración` **no existe hasta que la máquina está creada** — si buscas TPM mientras la creas, no lo vas a encontrar.
>
> Selecciona `Windows11` en la lista → **`Configuración`**:
>
> | Dónde | Qué |
> | :--- | :--- |
> | **Sistema → Placa base** | Activa **TPM 2.0** y **Secure Boot**. Windows 11 **no se instala sin ellos**; VirtualBox los emula desde la versión 7 |
> | **Pantalla → Pantalla** | **Memoria de vídeo: `128 MB`**. Por defecto pone 16-32 MB y con eso el escritorio de Windows 11 **se arrastra**, y parece que la VM está colgada cuando no lo está |
>
> > [!warning] ⚠️ Aquí vas a tener **DOS máquinas encendidas a la vez**. Echa la cuenta
> > Hasta ahora solo corría el servidor. En esta fase **el servidor sigue encendido** mientras trabajas en el cliente.
> >
> > | | RAM |
> > | :--- | ---: |
> > | `UbuntuServer` *(desde la Fase 4)* | 3072-4096 MB |
> > | `Windows11` | 4096 MB |
> > | **Para el sistema anfitrión** | 4000 MB |
> > | **Total** | **11-12 GB** |
> >
> > **Con 8 GB de host no salen las cuentas.** Si es tu caso: baja `Windows11` a `3072 MB`, cierra todo lo demás del anfitrión, y cuenta con que irá lento. **Y no subas a `6144 MB` "porque tengo 16 GB"** sin restar antes los del servidor.

> [!example] Paso 0.c: Los dos adaptadores de red
> Con la VM **apagada**, en **Configuración → Red**, configura **dos adaptadores**:
>
> | Adaptador | Modo | Nombre de red | Para qué sirve |
> | :--- | :--- | :--- | :--- |
> | **Adaptador 1** | Red Solo Anfitrión (*Host-only Adapter*) | la del laboratorio — la misma red host-only que ya creaste y configuraste en la Fase 1 | Hablar con el servidor: dominio, DNS, SMB, Kerberos |
> | **Adaptador 2** | NAT | — | Salida a Internet: activación de Windows, Windows Update, descarga de RSAT |
>
> > [!important] ⚠️ La misma red del laboratorio. **NO crees una nueva**
> > En el Adaptador 1 eliges **`Red Solo Anfitrión`**, y debajo aparece un desplegable de **nombre**.
> >
> > **🛑 Ahí NO sale ninguna IP.** El desplegable enseña **solo el nombre del adaptador** —del estilo `VirtualBox Host-Only Ethernet Adapter` en Windows o `vboxnetN` en Mac y Linux—, y ese nombre **cambia de un ordenador a otro**. Si esperas ver `10.10.10.1`, vas a estar buscando algo que no existe.
> >
> > **Cómo aciertas seguro:** abre la configuración de **`UbuntuServer`** → `Red` → `Adaptador 2`, mira **qué nombre tiene puesto**, y pon **ese mismo** aquí. Es la única comprobación que no depende de cómo se llame en tu equipo.
> >
> > Si en el desplegable solo hay **una** entrada, es esa: la creaste tú en la **Fase 1.2** y no hay más.
> >
> > > [!tip] 💡 ¿Y dónde está entonces el `10.10.10.1/24`?
> > > **No en la máquina: en el administrador global de VirtualBox** — `Herramientas → Red`. Es una propiedad de la red, no de la VM, y por eso no la ves aquí. Si necesitas comprobarla, es ahí *(y ahí también verificas que el DHCP sigue desactivado, como lo dejaste en la Fase 1.2)*.
>
> > [!warning] 👤 Al instalar Windows, **cuenta LOCAL** — no cuenta de Microsoft
> > Windows 11 insiste en que inicies sesión con una cuenta de Microsoft. **Aquí no la quieres:** este equipo va a ser de un dominio, y una cuenta de Microsoft solo añade una dependencia de internet y de una contraseña que no controlas.
> >
> > Busca la opción de **cuenta sin conexión / cuenta local** durante la instalación. Si la pantalla no te la ofrece, **desconecta el Adaptador 2 (NAT)** un momento: sin internet, Windows acaba ofreciéndola.
>
> > [!tip] 💡 ¿Por qué añadimos un adaptador NAT si el proyecto es "todo local"?
> > Decisión de diseño: sin salida a Internet, Windows 11 no puede activarse, no puede descargar actualizaciones ni instalar las **RSAT** (Paso 8, más abajo, requiere descargar un paquete desde los servidores de Microsoft). El adaptador NAT resuelve esto sin comprometer la seguridad del laboratorio: NAT es una salida *unidireccional* — nadie desde fuera puede entrar hacia la VM a través de él salvo que configures explícitamente un reenvío de puertos (Port Forwarding), cosa que no vamos a hacer en el cliente. El tráfico de dominio (DNS, Kerberos, SMB) sigue viajando exclusivamente por el Adaptador 1 (Red Solo Anfitrión), nunca por el NAT.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.4_Donde_Estamos]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.6_Procedimiento]] |
