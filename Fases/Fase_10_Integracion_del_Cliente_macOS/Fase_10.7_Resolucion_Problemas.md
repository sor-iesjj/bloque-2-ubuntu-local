## Fase 10 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**

> [!danger] 🛑 El Mac NO está unido al dominio: eso NO es un error
> Esta fase es de **acceso**, no de unión. Que el Mac no tenga cuenta de equipo es lo correcto. Lo que se comprueba aquí es que **accede** con un usuario del dominio.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| **La VM de macOS se queda en pantalla negra / "EXITBS"** | [[#C1 · La VM de macOS no arranca\|C1]] |
| **La tortuga de VirtualBox aparece al arrancar la VM** | [[#C2 · La tortuga / VBS bloquea\|C2]] |
| "Nombre de usuario o contraseña incorrectos" | [[#C4 · La contraseña correcta falla\|C4]] |
| No se conecta / no encuentra el servidor | [[#C3 · No llego al servidor\|C3]] |
| Entro pero no veo carpetas (o no las que tocan) | [[#C5 · Entro pero no veo mis carpetas\|C5]] |
| `smb://` se queda colgado o tarda | [[#C6 · La conexión tarda o se cuelga\|C6]] |
| "No tengo bash en Windows para ejecutar el script" | [[#C7 · No tengo bash en Windows (WSL o Cygwin)\|C7]] |

---

### C1 · La VM de macOS no arranca

> [!bug] Síntoma
> Al iniciar la VM de macOS, se queda en **pantalla negra** o en un mensaje como `EXITBS` / `EndRandomSeed`. No llega al instalador.

**Hipótesis.** La VM no está "engañando" a macOS con el hardware que exige.

**Comprobación.** ¿Aplicaste el `--cpuidset` (Paso 1.3)? ¿La memoria de vídeo es 128 MB? ¿El firmware es EFI?

**Arreglo.** En orden:
```bash
# 1. CPU de Intel válida para macOS
VBoxManage modifyvm "macOS" --cpuidset 00000001 000306a9 00020800 80000201 178bfbff
# 2. Memoria de vídeo suficiente
VBoxManage modifyvm "macOS" --vram 128
# 3. Si sigue, prueba a marcar la ISO como Live CD en Almacenamiento
```
Si sigue en negro, revisa el caso C2 (la tortuga): macOS **no se instala** bajo VBS/NEM.

> [!summary] Qué aprendes
> Que macOS exige un hardware muy concreto, y VirtualBox tiene que **simularlo** con `--cpuidset`. Un "pantallazo negro" al arrancar suele ser eso — no un fallo tuyo.

---

### C2 · La tortuga / VBS bloquea

> [!bug] Síntoma
> Al arrancar la VM, en la barra de estado de VirtualBox aparece la **tortuga 🐢** («native API execution»), y macOS se cuelga o no instala.

**Hipótesis.** El hipervisor de Windows (VBS) está activo y VirtualBox corre en modo NEM — **el instalador de macOS se corrompe bajo NEM**.

**Comprobación.** `msinfo32` → "Seguridad basada en virtualización" → **"En ejecución"** = es esto.

**Arreglo.** **No es esta fase la que lo resuelve.** Es el mismo diagnóstico que la Fase 8 (el E9 bis: `dism`, `bcdedit`, Secure Boot). Para esta fase, si la tortuga está, el host no puede correr macOS — **avisa al profesor y usa un host con VT-x real**.

> [!summary] Qué aprendes
> Que el muro de la Fase 8 (VBS) no era solo de Windows: **también bloquea macOS**. Es la misma raíz, y por eso el diagnóstico de la Fase 8 sirve para las dos.

---

### C3 · No llego al servidor

> [!bug] Síntoma
> El Finder no conecta, o `ping` al servidor falla desde la VM de macOS.

**Hipótesis.** La VM no está en la red del laboratorio, o no resuelve el nombre.

**Comprobación.** En Terminal (dentro de la VM):
```bash
ping -c 2 10.10.10.10
ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
```

**Arreglo.** Si la IP responde pero el nombre no, usa la IP directa en el Finder (`smb://10.10.10.10`) o configura el DNS del dominio. Si ni la IP responde, la VM no está en la Red Solo Anfitrión → revisa el Adaptador 1.

> [!summary] Qué aprendes
> Que "llego por IP" y "resuelvo el nombre" son dos cosas distintas — la misma lección que en las Fases 8 y 9, desde el Mac.

---

### C4 · La contraseña correcta falla

> [!bug] Síntoma
> Entras con `masao.sato` y `P@ssw0rd`, que son correctos, y el Mac dice que el usuario o la contraseña son incorrectos.

**Hipótesis.** **La hora de la VM de macOS.** Kerberos rechaza más de 5 minutos de desfase, y el error no lo dice.

**Comprobación.** Ajustes → Fecha y hora: ¿la hora es correcta?

**Arreglo.** Activa la hora automática o ajústala a mano. Vuelve a intentar.

> [!summary] Qué aprendes
> Que el error de credenciales no siempre es la contraseña — es la hora. Igual que en Windows (Fase 8) y en Ubuntu (Fase 9). **Es el fallo nº1 de esta fase.**

---

### C5 · Entro pero no veo mis carpetas

> [!bug] Síntoma
> Conectas y ves el servidor, pero no las carpetas que esperabas.

**Hipótesis.** O bien estás entrando con el usuario equivocado, o bien la matriz/ABE no está como debe.

**Comprobación.** ¿Con qué usuario entraste? ¿`masao.sato` (comercial)?

**Arreglo.** Si entras con otro usuario (o con la cuenta local de la VM), las carpetas que veas son las de **ese** usuario. Desconecta y entra con el usuario del dominio que toca.

> [!summary] Qué aprendes
> Que lo que ves en una carpeta compartida depende de **quién eres**, no del sistema con el que entras. La matriz la decide el servidor.

---

### C6 · La conexión tarda o se cuelga

> [!bug] Síntoma
> `smb://…` tarda mucho en conectar, o se queda colgado.

**Hipótesis.** El Mac intenta resolver el nombre por varios servidores DNS antes de dar con el correcto, o hay un problema de red.

**Comprobación.** Espera; si no conecta, prueba con la IP directa.

**Arreglo.** Usa `smb://10.10.10.10` en vez del nombre (funciona, aunque sin Kerberos). Si va por nombre pero lento, revisa el DNS.

> [!summary] Qué aprendes
> Que a veces lo pragmático (IP directa) desbloquea, aunque el ideal sea el nombre (que permite Kerberos).

> [!bug] Síntoma
> El Finder no conecta, o `ping` al servidor falla.

**Hipótesis.** El Mac no está en la red del laboratorio, o no resuelve el nombre.

**Comprobación.** En Terminal:
```bash
ping -c 2 10.10.10.10
ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
```

**Arreglo.** Si la IP responde pero el nombre no, usa la IP directa en el Finder (`smb://10.10.10.10`) o configura el DNS del dominio. Si ni la IP responde, el Mac no está en la red del laboratorio → avisa al profesor (puede hacer falta WireGuard).

> [!summary] Qué aprendes
> Que "llego por IP" y "resuelvo el nombre" son dos cosas distintas — la misma lección que en las Fases 8 y 9, desde el Mac.

---

### C7 · No tengo bash en Windows (WSL o Cygwin)

> [!bug] Síntoma
> Quieres ejecutar `macos-guest-virtualbox.sh` (Paso 1.1) pero en Windows: escribes `wsl` en CMD y no sabes si hay que hacer algo, o el comando no existe.

**Hipótesis.** El script es de **Linux** (bash). En Windows no se ejecuta en CMD/PowerShell: necesitas un **entorno bash**. Eso es **Cygwin** o **WSL**.

**Comprobación.** ¿Tienes alguno? En **CMD**:
```cmd
wsl --version
```
- **✅ Bien:** responde con la versión → tienes WSL.
- **❌ Mal:** *"WSL no está instalado"* o comando no reconocido → sigue.

**Arreglo — opción A: instalar Cygwin (recomendado para esta fase).**
Cygwin es un "Linux en miniatura" para Windows que **no toca el hipervisor**, así que **no rompe VirtualBox**. Es la opción segura aquí.

1. Descarga el instalador de `https://www.cygwin.com/` (`setup-x86_64.exe`).
2. Ejecútalo y acepta los valores por defecto.
3. **Cuando te pida elegir paquetes, NO elijas ninguno** — deja todo en "Skip" y pulsa Siguiente hasta el final. Cygwin se instala con `bash` de serie, que es **lo único imprescindible**.
4. Al terminar, abre la **"Cygwin64 Terminal"** (icono del escritorio). Ahí ya tienes bash: prueba con `echo hola` → debe responder `hola`.
5. Ejecuta el script **desde esa terminal**:
   ```bash
   ./macos-guest-virtualbox.sh
   ```

> [!warning] ⚠️ ¿Y si el script te dice "comando no encontrado" (ej. `wget`)?
> Entonces instala **solo ese** paquete — no "por si acaso" todos. Vuelve a ejecutar `setup-x86_64.exe`, elige **"mantener la instalación existente"**, y en la **búsqueda** escribe el nombre **exacto** del comando. En la lista, clic en el "Skip" del paquete que se llama **igual que el comando** (ej. `wget`, no `wget2` ni `wget-devel`) y elige la **última** versión. Los paquetes `curl`, `wget`, `unzip` y `coreutils` existen en Cygwin con esos nombres — pero **no los instales todos de entrada**: solo lo que el script te pida.

**Arreglo — opción B: instalar WSL1 (con cuidado).**
> [!danger] 🛑 Ojo: **WSL2 activa el hipervisor** y puede encender VBS → tortuga → macOS no instala. Si usas WSL, usa **WSL1**, no WSL2.
> En CMD **como administrador**:
> ```cmd
> wsl --install -d Ubuntu --no-launch
> wsl --set-version Ubuntu 1
> ```
> Reinicia si lo pide, abre "Ubuntu" desde el menú Inicio, y ejecuta el script ahí.

> [!summary] Qué aprendes
> Que no es un fallo tuyo: el script está escrito para un entorno bash, y Windows no lo tiene de serie. Saber cuándo necesitas Cygwin o WSL —y por qué WSL2 puede ser un problema aquí— es parte de entender qué hace el script, no solo ejecutarlo.

---

> [!question] 🤔 Si tu fallo no está aquí
> 1. Comprueba el **servidor**, que es donde suele estar el problema: `sudo ./verificar_fase7.sh`.
> 2. Pregunta en el aula — el problema puede ser de red (Mac fuera de la red del laboratorio).
> 3. Anota el mensaje literal en tu entrada de apuntes.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.6_Procedimiento]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.8.a_Verificacion]] |
