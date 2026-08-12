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
| "No tengo bash en Windows para ejecutar el script" | [[#C7 · No tengo bash en Windows (WSL1)\|C7]] |

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
> Al arrancar la VM, en la barra de estado de VirtualBox aparece la **tortuga 🐢** («native API execution»), y macOS se cuelga o no instala. **O el script de instalación se detiene al final con este mensaje literal:**
>
> ```
> Virtualbox is not using hardware-supported virtualization features.
> Check that software such as Hyper-V, Windows Sandbox, WSL2, memory integrity
> protection, and other Windows features that lock virtualization are turned off.
> Exiting.
> ```

**Hipótesis.** El hipervisor de Windows (VBS) está activo y VirtualBox corre en modo NEM — **el instalador de macOS se corrompe bajo NEM**, y el script lo detecta y se niega a seguir.

**Comprobación.** `msinfo32` → "Seguridad basada en virtualización" → **"En ejecución"** = es esto.

**Arreglo.** **No es esta fase la que lo resuelve.** Es el mismo diagnóstico que la Fase 8 (el E9 bis: `dism`, `bcdedit`, Secure Boot). Para esta fase, si la tortuga está o el script muestra ese mensaje, **el host no puede correr macOS — ni siquiera el script lo intenta**. Hay dos salidas reales:
- Usar un **host con VT-x libre** (donde VirtualBox no caiga en NEM).
- Si el host no lo tiene (p. ej. un portátil con VBS forzada de fábrica), **esta parte de la fase no es viable en ese equipo** — el acceso desde un Mac real (si lo hay) sigue siendo la alternativa.

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

---

### C7 · No tengo bash en Windows (WSL1)

> [!bug] Síntoma
> Quieres ejecutar `macos-guest-virtualbox.sh` (Paso 1.1) pero en Windows: el script es de **Linux** y CMD/PowerShell no lo ejecutan. Necesitas **WSL1**.

> [!warning] 🛑 Solo WSL1 vale para este script
> - **Cygwin NO sirve**: su `xxd` no acepta `-e -p` juntos, y el script se detiene siempre con el aviso de `xxd`. *(Probado en campo.)*
> - **WSL2 NO sirve**: enciende el hipervisor (VBS) → tortuga → el script se detiene con *"Virtualbox is not using hardware-supported virtualization"*.
> - **WSL1 sí sirve**: su `xxd` de Linux acepta `-e -p`, y no enciende el hipervisor.

**Comprobación.** En **CMD**:
```cmd
wsl --list --verbose
```
- **✅ Bien:** `Ubuntu` con `VERSION 1` → ya tienes lo que necesitas. Salta al paso 3.
- Si `Ubuntu` con `VERSION 2` → pasa al paso 1.
- Si "no hay distribuciones" → pasa al paso 1.

**Paso 1 — Instalar Ubuntu en WSL (si no lo tienes).** En CMD **como administrador**:
```cmd
wsl --install -d Ubuntu --no-launch
```

**Paso 2 — Forzar WSL1 (NO WSL2).** En CMD **como administrador**:
```cmd
wsl --set-version Ubuntu 1
```
> Si da error de la característica "VirtualMachinePlatform", actívala y reinicia:
> ```cmd
> dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
> ```
> *(Es un paso intermedio para poder instalar WSL1; WSL1 luego no usa ese hipervisor.)*

**Paso 3 — Abrir Ubuntu y crear el usuario.** Pulsa `Windows`, escribe **`Ubuntu`**, ábrelo. La primera vez crea un **usuario y contraseña** (anótalos).

**Paso 4 — Arreglar el DNS de WSL (sin esto no descarga nada).** Dentro de Ubuntu:
```bash
sudo nano /etc/resolv.conf
```
Deja **solo** esta línea (borra las `fec0:...`):
```
nameserver 8.8.8.8
```
Guarda (`Ctrl+X`, `Y`, `Enter`). Si WSL lo sobrescribe, crea `/etc/wsl.conf` con `[network]` y `generateResolvConf = false`, cierra y reabre Ubuntu. Comprueba: `ping -c 2 google.com`.

**Paso 5 — Instalar las herramientas.** Dentro de Ubuntu:
```bash
sudo apt update && sudo apt install -y wget unzip xxd dmg2img
```

**Paso 6 — Descargar y ejecutar el script.** Dentro de Ubuntu:
```bash
wget https://raw.githubusercontent.com/myspaghetti/macos-virtualbox/master/macos-guest-virtualbox.sh
chmod +x macos-guest-virtualbox.sh
./macos-guest-virtualbox.sh
```
> 💡 Si `wget` guarda el fichero con `.1` al final, es que ya lo descargaste: `rm macos-guest-virtualbox.sh.* && wget …`

> [!summary] Qué aprendes
> Que no es un fallo tuyo: el script está escrito para Linux, y solo **WSL1** le da un entorno compatible (ni Cygwin por el `xxd`, ni WSL2 por el hipervisor). Saber cuál de los tres entornos vale y por qué es parte de entender lo que ejecutas.

> [!warning] ⚠️ ¿Y si el script te dice que falta OTRO comando (no `wget`)?
> En WSL1 se instala con `apt`, no con Cygwin: `sudo apt install -y <comando>`. Ejecuta el script otra vez y, si pide algo concreto, instálalo con ese comando.

---

> [!question] 🤔 Si tu fallo no está aquí
> 1. Comprueba el **servidor**, que es donde suele estar el problema: `sudo ./verificar_fase7.sh`.
> 2. Pregunta en el aula — el problema puede ser de red (Mac fuera de la red del laboratorio).
> 3. Anota el mensaje literal en tu entrada de apuntes.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.6_Procedimiento]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.8.a_Verificacion]] |
