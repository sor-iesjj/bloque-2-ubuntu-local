## Fase 8 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. Dos VMs, una Red Solo Anfitrión
> A diferencia de un despliegue en la nube (donde el cliente Windows sería un PC físico del aula conectándose por Internet y VPN), aquí **el cliente Windows 11 es otra máquina virtual** dentro del mismo VirtualBox que el servidor. Ambas VMs comparten la misma **Red Solo Anfitrión (Host-Only)** de VirtualBox — la misma red del laboratorio (`10.10.10.0/24`) que ya creaste y configuraste en la Fase 1 — un cable de red virtual que conecta servidor, cliente y tu propio ordenador. Esto es clave porque los equipos de Consellería de las aulas no dan permisos de administrador sobre el sistema físico (el host): todo lo que se pueda tocar o romper debe vivir *dentro* de las VMs, nunca en el host.

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
> | **Adaptador 1** | Red Solo Anfitrión (*Host-only Adapter*) | la del laboratorio — la misma red host-only que ya creaste y configuraste en la Fase 1 | Hablar con el servidor: dominio, DNS, SMB, Kerberos |
> | **Adaptador 2** | NAT | — | Salida a Internet: activación de Windows, Windows Update, descarga de RSAT |
>
> > [!important] ⚠️ Selecciona la misma red del laboratorio (`10.10.10.0/24`), no crees una red nueva
> > No hace falta crear ninguna red nueva ni inventar un nombre propio: en el Adaptador 1, selecciona **`Red Solo Anfitrión`** y, en el desplegable de nombre de red, elige **la que tiene la IP `10.10.10.1`** — la misma red host-only que configuraste manualmente en la Fase 1 (IP del host `10.10.10.1/24`, DHCP desactivado) y a la que ya está conectado el servidor. Al compartir exactamente la misma red host-only, servidor, cliente y tu propio ordenador se ven entre sí sin ningún paso adicional.
>
> > [!tip] 💡 ¿Por qué añadimos un adaptador NAT si el proyecto es "todo local"?
> > Decisión de diseño: sin salida a Internet, Windows 11 no puede activarse, no puede descargar actualizaciones ni instalar las **RSAT** (Paso 8, más abajo, requiere descargar un paquete desde los servidores de Microsoft). El adaptador NAT resuelve esto sin comprometer la seguridad del laboratorio: NAT es una salida *unidireccional* — nadie desde fuera puede entrar hacia la VM a través de él salvo que configures explícitamente un reenvío de puertos (Port Forwarding), cosa que no vamos a hacer en el cliente. El tráfico de dominio (DNS, Kerberos, SMB) sigue viajando exclusivamente por el Adaptador 1 (Red Solo Anfitrión), nunca por el NAT.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.4_Donde_Estamos]] | [[Fase_8]] | [[Fase_8.6_Procedimiento]] |
