## Fase 9 · Apartado 6 — 🛠️ Procedimiento

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] Paso 0 — Prepárate y empieza a grabar
> 1. Léete el procedimiento entero, para no atascarte a mitad del vídeo.
> 2. Ten OBS listo y comprueba pantalla y micrófono.
> 3. Arranca la grabación, **preséntate y muestra tu identidad**. Todo lo que sigue queda grabado.
>
> **Lo que ya tienes (de la Fase 8):** el servidor encendido con el dominio `BOOCHANLAB.LOCAL` y la Red Solo Anfitrión funcionando. No lo toques.

> [!example] Paso 1 — Crea la máquina virtual del cliente Ubuntu Desktop
> En VirtualBox, `Nueva`:
>
> | Campo | Valor |
> | :--- | :--- |
> | **Nombre** | `UbuntuDesktop` — exactamente así, sin guiones ni espacios |
> | **Tipo** | `Linux` · **Versión** | `Ubuntu (64-bit)` |
> | **Imagen ISO** | `ubuntu-26.04-desktop-amd64.iso` (la de **escritorio**, no la de servidor) |
> | **Memoria RAM** | `2048 MB` |
> | **Procesadores** | `2 CPU` |
> | **Disco duro** | nuevo, **VDI**, **dinámico**, **25 GB** |
>
> > [!danger] 🛑 Marca **«Omitir instalación desatendida»** — el mismo atasco de la Fase 8
> > VirtualBox 7 activa la instalación desatendida por su cuenta y pide una cuenta. Márcala para instalar a mano, como toca. [[Fase_8.5_Fundamento_Teorico|Lo viste en la Fase 8]].
>
> **No marques TPM ni Secure Boot** en esta VM: a diferencia de Windows 11, Ubuntu Desktop **no los exige** para arrancar, y el objetivo aquí es un cliente Linux sencillo.

> [!example] Paso 2 — Configura el adaptador de red (Red Solo Anfitrión)
> Con la VM **apagada**, en `Configuración → Red`:
>
> | Adaptador | Modo | Para qué |
> | :--- | :--- | :--- |
> | **Adaptador 1** | Red Solo Anfitrión | **La misma** red host-only que usa `UbuntuServer` — la del laboratorio `10.10.10.0/24`. Sin NAT |
>
> > [!warning] ⚠️ La misma red, **NO una nueva**
> > Mira en `UbuntuServer → Configuración → Red → Adaptador 1` qué **nombre** de red tiene puesto, y pon **ese mismo** aquí. No crees una red nueva. *(El desplegable enseña el nombre, no la IP — como ya sabes de la Fase 8.)*
>
> **Solo un adaptador (host-only).** A diferencia de Windows, Ubuntu Desktop **no necesita salir a Internet** para esta fase: la instalación se hace con la ISO, y la unión al dominio y el acceso a carpetas van por la red local. Sin NAT, el cliente está **aislado** del exterior — correcto para el laboratorio.

> [!example] Paso 3 — Instala Ubuntu Desktop
> Arranca la VM e instala Ubuntu Desktop 26.04 LTS:
>
> 1. Elige **idioma español** y la opción de **instalación normal** (no mínima).
> 2. En **actualizaciones**, puedes dejar la instalación normal.
> 3. **Tipo de instalación:** borrar disco e instalar (el disco virtual está vacío).
> 4. **Usuario local:** aquí creas una cuenta local para la máquina (p. ej. `ubuntu`). **Anota el nombre y la contraseña** — la necesitarás al inicio de sesión y para `sudo`.
> 5. **Instalar** y reiniciar al terminar.

> [!important] ⚠️ La cuenta local de la instalación NO es del dominio
> Es la cuenta con la que se administra la máquina (equivalente al usuario local de Windows). **El dominio entra después**, con `realm join`. No la confundas con las cuentas del dominio.

> [!example] Paso 4 — Comprueba que el cliente ve el servidor (antes de unir nada)
> Abre un **terminal** en Ubuntu Desktop y comprueba la red:
>
> ```bash
> ip addr show
> ping -c 2 10.10.10.10
> ```
>
> - **✅ Bien:** la interfaz tiene una IP de `10.10.10.0/24` (p. ej. `10.10.10.30`) y el servidor responde.
> - **❌ Mal:** no hay IP en la red del laboratorio → la VM no está en la Red Solo Anfitrión correcta (revisa el Paso 2).
>
> > [!tip] 💡 ¿IP fija o DHCP?
> > Para esta fase, la IP puede ser por **DHCP de la red host-only** o fija. Lo importante es que esté en `10.10.10.0/24` y que el DNS apunte al servidor (Paso 5). Si quieres IP fija, asígnasela igual que hiciste con el servidor en la Fase 1 — pero **no es imprescindible** para unirse al dominio.

> [!example] Paso 5 — Ajusta la zona horaria y apunta el DNS al servidor
> **Primero la hora** — es el fallo nº1 de esta fase (lo viste en el fundamento):
> ```bash
> sudo timedatectl set-timezone Europe/Madrid
> timedatectl
> ```
> **Después el DNS** — el cliente tiene que preguntar al servidor, no a Internet:
>
> En `Configuración → Red → (tu conexión) → Ajustes`, desactiva **DHCP** y pon:
>
> | Campo | Valor |
> | :--- | :--- |
> | **Dirección IP** | `10.10.10.30` *(o la que tenga tu cliente en la red del laboratorio)* |
> | **Máscara** | `255.255.255.0` |
> | **DNS** | `10.10.10.10` |
>
> Comprueba que resuelve el dominio:
> ```bash
> nslookup BOOCHANLAB.LOCAL
> ```
> - **✅ Bien:** responde `10.10.10.10`.
> - **❌ Mal:** no resuelve → el DNS no apunta al servidor. **Sin DNS no hay unión.**

> [!example] Paso 6 — Instala las herramientas de unión al dominio
> En el terminal de Ubuntu Desktop:
> ```bash
> sudo apt update
> sudo apt install -y realmd sssd sssd-tools libnss-sss libpam-sss samba-common-bin adcli krb5-user
> ```
>
> > [!info] 📚 Qué instala cada paquete
> > | Paquete | Para qué |
> > | :--- | :--- |
> > | `realmd` | El comando `realm join` — el corazón de la unión |
> > | `sssd` | El traductor de identidades del dominio a locales |
> > | `adcli` | La "mano" que negocia con el controlador de dominio |
> > | `krb5-user` | El cliente de Kerberos (tickets) |
> > | `samba-common-bin` | Herramientas de Samba del lado cliente |

> [!example] Paso 7 — Únete al dominio
> En el terminal, como administrador de dominio:
> ```bash
> sudo realm join --user=Administrator BOOCHANLAB.LOCAL
> ```
> Te pedirá la contraseña: **`P@ssw0rd`** (la de `BOOCHANLAB\Administrator`).
>
> - **✅ Bien:** responde algo como *"Successfully enrolled machine in realm"*.
> - **❌ Mal:**
>   - *"Unable to join the realm"* → mira la hora (Paso 5) y el DNS. Es el fallo nº1.
>   - *"Credentials"* / Kerberos → la contraseña de `Administrator` del dominio, **no** la de `boochan` ni la del usuario local.
>
> > [!danger] 🛑 El prefijo `BOOCHANLAB\` de la cuenta
> > El comando usa `--user=Administrator`, pero Windows Kerberos necesita saber **de qué dominio** es. Si la unión falla por credenciales, prueba con el formato completo:
> > ```bash
> > sudo realm join --user=Administrator@BOOCHANLAB.LOCAL BOOCHANLAB.LOCAL
> > ```

> [!example] Paso 8 — Verifica la pertenencia y comprueba que funciona
> ```bash
> realm list
> ```
> Debe mostrar el dominio, el estado *configured*, y el modo de autenticación `sssd`.
>
> Comprueba que el dominio "ve" al usuario:
> ```bash
> getent passwd masao.sato
> ```
> Debe devolver una línea con el UID del dominio (p. ej. `10005`).

> [!example] Paso 9 — Accede a las carpetas compartidas (Nautilus)
> En el **gestor de archivos** de Ubuntu (Nautilus), en la barra de dirección:
> ```
> smb://UbuntuServer.BOOCHANLAB.LOCAL
> ```
> Entra con **`masao.sato`** y `P@ssw0rd`.
>
> - **✅ Bien:** ves las carpetas a las que tiene permiso (según la matriz): `comercial`, `facturacion`, `logistica`, `comun`.
> - **❌ Mal:** si ves `contabilidad` o `rrhh`, hay un permiso de más — pero no debería (el ABE lo oculta, como en la Fase 8).

> [!example] Paso 10 — Cierra la grabación y súbela
> Detén OBS, nombra el vídeo **`B2 · F9 · Procedimiento`**, súbelo a la playlist `B2_Ubuntu_Local` como No listado y añade timestamps.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.5_Fundamento_Teorico]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.7_Resolucion_Problemas]] |
