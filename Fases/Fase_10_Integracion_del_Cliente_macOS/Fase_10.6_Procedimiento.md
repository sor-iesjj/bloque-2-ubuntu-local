## Fase 10 · Apartado 6 — 🛠️ Procedimiento

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!danger] 🛑 REQUISITO DEL HOST antes de empezar: VirtualBox con VT-x real, sin la tortuga
> La VM de macOS **no se instala** si VirtualBox cae en modo NEM (la tortuga de la Fase 8) — es decir, si VBS/Hyper-V están activos en el host. **Comprueba antes de grabar:**
>
> 1. Arranca cualquier VM y mira la barra de estado: **si aparece la 🐢, macOS no va a funcionar.**
> 2. En `msinfo32` (host): *"Seguridad basada en virtualización"* debe decir **"No habilitada"**.
>
> Si la tortuga está: **no es esta fase la que lo arregla** — es el diagnóstico de la Fase 8 (el E9 bis). Para esta fase necesitas un host con VT-x real.

---

> [!example] Paso 0 — Prepárate y empieza a grabar
> 1. Léete el procedimiento entero, sobre todo el **Paso 1** (crear la VM) — es el que más puede fallar.
> 2. Ten OBS listo y comprueba pantalla y micrófono.
> 3. Arranca la grabación, **preséntate y muestra tu identidad**. Todo lo que sigue queda grabado.
>
> **Lo que ya tienes:** el servidor encendido con el dominio y las carpetas publicadas (Fases 1-7), y los clientes Windows y Ubuntu ya integrados (Fases 8-9). No toques nada del servidor.

---

> [!example] Paso 1 — Crear la VM de macOS en VirtualBox *(el reto de la fase)*
> Apple no soporta macOS en hardware ajeno y VirtualBox no lo soporta oficialmente. Para conseguirlo hay que **crear la VM con una configuración específica** — la que hace que macOS "crea" que está en hardware válido. **Se hace con `VBoxManage`, no solo con el asistente.**
>
> ### 1.1 · Prepara el instalador de macOS
> **🛑 NO descargas ninguna ISO. El script la descarga él solo.** El sistema de Apple no se descarga como una ISO normal: el método de `myspaghetti/macos-virtualbox` (el script de referencia, 13k★) **baja el instalador desde los servidores de Apple** (`swcdn.apple.com`), crea la VM y la arranca. **Tú no descargas nada de ningún sitio** — solo ejecutas el script.
>
> > [!warning] 🛑 PRIMERO: necesitas **WSL1** (no Cygwin, no WSL2) para ejecutar el script
> > El script es de **Linux**, y en Windows no se ejecuta en CMD/PowerShell. Necesitas **WSL1** — y solo WSL1, porque:
> > - **Cygwin NO vale** para este script: su `xxd` no acepta el comando `-e -p` que el script usa, así que se detiene siempre con el aviso de `xxd`. *(Lo descubrimos probándolo en campo.)*
> > - **WSL2 NO vale**: enciende el hipervisor de Windows (VBS) → tortuga → y el script se detiene con *"Virtualbox is not using hardware-supported virtualization"*.
> >
> > **Si no tienes WSL1 listo → [[Fase_10.7_Resolucion_Problemas#C7 · No tengo bash en Windows (WSL1)\|caso C7 del apartado 7]]** — es EL camino para hacer este paso, no un desvío. Ahí están los pasos para instalarlo y prepararlo.
>
> **En Linux o macOS** (si tienes un Mac para prepararlo), desde la terminal:
> ```bash
> curl -O https://raw.githubusercontent.com/myspaghetti/macos-virtualbox/master/macos-guest-virtualbox.sh
> ./macos-guest-virtualbox.sh
> ```
> **En Windows**, se hace **dentro de WSL1 (Ubuntu)** — el C7 te deja ahí — con `wget` en vez de `curl`, y **dando permiso de ejecución** (sin `chmod`, te dará `Permission denied`):
> ```bash
> wget https://raw.githubusercontent.com/myspaghetti/macos-virtualbox/master/macos-guest-virtualbox.sh
> chmod +x macos-guest-virtualbox.sh
> ./macos-guest-virtualbox.sh
> ```
>
> > [!danger] 🛑 Si el script se detiene con **"Virtualbox is not using hardware-supported virtualization"**
> > Es la **VBS del host** (la tortuga de la Fase 8). No es que hayas hecho nada mal: **esta parte de la fase NO es viable en un equipo con VBS forzada.** Ni siquiera el script lo intenta. → caso [[Fase_10.7_Resolucion_Problemas#C2 · La tortuga / VBS bloquea\|C2]]. Solo funciona en un host con VT-x real.
> *(Ambos bajan el instalador de Catalina/Mojave/High Sierra desde `swcdn.apple.com` y crean la VM ya configurada — los pasos 1.2 y 1.3 quedan hechos por el script. La descarga va a una carpeta temporal que el script gestiona; **no te deja una ISO que guardar**, la usa él y la limpia al terminar.)*
>
> **Mientras el script corre:** te irá pidiendo **Enter** según avance. Y cuando arranque la VM, **NO toques la ventana de la VM** mientras el script la configura ("The script interacts with the virtual machine twice…").
>
> > [!info] 📚 Qué hace el script
> > Descarga `BaseSystem.dmg` y el resto del instalador desde los servidores de Apple, y crea la VM ya configurada (los pasos 1.2-1.3). Es lo que te ahorra montarla a mano.
>
> ### 1.2 · Si lo haces a mano (configuración mínima que SÍ funciona)
> La configuración que hace falta es esta — y **no es la que pone el asistente por defecto**:
>
> | Dónde | Qué poner | Por qué |
> | :--- | :--- | :--- |
> | **Nombre** | `macOS` | — |
> | **Tipo** | `Mac OS X` · **Versión** | `macOS (64-bit)` | — |
> | **Memoria RAM** | `4096 MB` | macOS necesita al menos 4 GB |
> | **Disco** | nuevo, **VDI**, dinámico, **40-80 GB** | Big Sur exige ≥35,3 GB |
> | **Sistema → Placa base** | marcar **EFI** (`--firmware efi`) | macOS exige EFI, no BIOS |
> | **Sistema → Aceleración** | **desmarcar** "Habilitar VT-x/AMD-V anidado" **no aplica**; lo importante es tener VT-x real del host | — |
> | **Pantalla → Memoria de vídeo** | **`128 MB`** | con menos, macOS **no arranca** o va pésimo |
> | **Audio** | **desmarcar** "Habilitar audio" | el audio de VirtualBox no tiene driver en macOS |
> | **Red → Adaptador 1** | **Red Solo Anfitrión** | la red del laboratorio `10.10.10.0/24` |
>
> ### 1.3 · El ajuste de CPU que macOS exige
> macOS solo arranca en CPUs Intel concretas. Hay que **decirle a la VM que simule una**. En Terminal/CMD del host:
> ```bash
> VBoxManage modifyvm "macOS" --cpuidset 00000001 000306a9 00020800 80000201 178bfbff
> ```
> *(Ese es el "cpuid" de un procesador Intel válido para macOS. Sin él, el arranque se queda en una pantalla negra o en "EXITBS".)*
>
> ### 1.4 · Arranca la VM desde el instalador
> - Con la VM creada, pulsa **Iniciar**.
> - Cuando VirtualBox pida el medio de arranque, **elígelo** (el instalador que preparó el script, o la ISO).
> - **Si se queda en pantalla negra:** prueba a marcar la ISO como "Live CD" en `Configuración → Almacenamiento`, o ajusta el `--cpuidset`.
>
> > [!danger] 🛑 Si se queda en pantalla negra o en "EXITBS", NO es que hayas hecho algo mal
> > Es el síntoma clásico de que la VM no "engaña" lo suficiente a macOS. Lo primero a revisar: que el `--cpuidset` esté aplicado (Paso 1.3) y que la memoria de vídeo sea 128 MB. Y sobre todo: **que VirtualBox use VT-x real y no la tortuga** (requisito del principio).

> [!example] Paso 2 — Instala macOS en la VM
> Con el instalador arrancado:
> 1. Elige el **idioma**.
> 2. Abre **Utilidad de Discos** (`Utilidades → Utilidad de Discos`).
> 3. Selecciona el **disco virtual de la VM** (no el de ningún otro), pulsa **Borrar** y formato **APFS** (para Catalina/más nuevas).
> 4. Sal de Utilidad de Discos y elige **Instalar macOS**.
> 5. Sigue el asistente hasta el escritorio.
>
> > [!warning] ⚠️ Si el disco no aparece en Utilidad de Discos
> > En `Utilidad de Discos → Ver → Mostrar todos los dispositivos` y formatea el dispositivo recién visible. *(Truco documentado para High Sierra y posteriores.)*

> [!example] Paso 3 — Comprueba que la VM de macOS ve el servidor
> Ya en el escritorio de la VM de macOS, abre **Terminal** (Aplicaciones → Utilidades):
> ```bash
> ping -c 2 10.10.10.10
> ```
> - **✅ Bien:** el servidor responde — la red host-only está bien.
> - **❌ Mal:** la VM no está en la red del laboratorio → revisa el Adaptador 1 (Red Solo Anfitrión).

> [!example] Paso 4 — Comprueba que resuelve el dominio
> ```bash
> ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
> ```
> - **✅ Bien:** responde con la IP del servidor.
> - **❌ Mal:** no resuelve `BOOCHANLAB.LOCAL` → configura el DNS a `10.10.10.10` en la red de la VM, o usa la IP directa en el Paso 6.

> [!example] Paso 5 — Comprueba la hora de la VM de macOS (el fallo nº1)
> **Ajustes del sistema → Fecha y hora** → comprueba que la hora es la correcta y que está **automática**.
> - **✅ Bien:** la hora coincide con la del servidor.
> - **❌ Mal:** desfasada → actívala automática. **Si no, Kerberos te rechazará el acceso con un error que no habla de la hora.**

> [!example] Paso 6 — Accede a las carpetas del servidor desde el Finder
> 1. Abre el **Finder**.
> 2. Menú **Ir → Conectarse al servidor…** (o `Cmd + K`).
> 3. En *Dirección del servidor*, escribe:
> ```
> smb://UbuntuServer.BOOCHANLAB.LOCAL
> ```
> 4. Pulsa **Conectar**.
> 5. Cuando pida sesión, elige **usuario registrado** y entra con:
>    - **Nombre:** `masao.sato` (o `BOOCHANLAB\masao.sato`)
>    - **Contraseña:** `P@ssw0rd`
> 6. Se abre una ventana con las carpetas compartidas.

> [!example] Paso 7 — Verifica qué ves (la matriz)
> Con `masao.sato`, debes ver **exactamente** las carpetas de su matriz:
> - **✅ Bien:** `comercial`, `facturacion`, `logistica`, `comun` — y **no** `contabilidad` ni `rrhh`.
> - **❌ Mal:** si ves lo ajeno, hay un permiso de más (pero no debería: el ABE lo oculta).

> [!example] Paso 8 — Cierra la grabación y súbela
> Detén OBS, nombra el vídeo **`B2 · F10 · Procedimiento`**, súbelo a `B2_Ubuntu_Local` como No listado y añade timestamps.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.5_Fundamento_Teorico]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.7_Resolucion_Problemas]] |
