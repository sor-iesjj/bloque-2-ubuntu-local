## Fase 10 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Después del punto de control.** Romper de verdad, para aprender reparando.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 10 terminada` del servidor DEBE estar hecha
> Aquí vas a romper el acceso. Sin la instantánea no hay red de seguridad. Si algo se rompe de verdad y no puedes arreglarlo: **restaura** y anota qué hiciste mal.

> [!info] 🎯 El Mac NO es una VM — romper aquí no toca la máquina
> A diferencia de las Fases 8 y 9, **no rompes el cliente** (es un Mac real, no lo tocas). Rompes cosas **del servidor o de la configuración** que hacen que el acceso falle — y las reparas. El Mac es solo el observador.

> [!warning] ⏱️ **Sigue siendo UN SOLO vídeo** `B2 · F10 · Averías`, con un timestamp por avería.

> [!tip] 💡 Todas siguen el mismo guion
> **Romper → Comprobar → Diagnosticar → Reparar.** Predice antes de romper.

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 3 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**

| **Avería** | **La frase del cliente que la resume** |
| :--- | :--- |
| **1** | [[#AVERÍA 1 · QUITAR EL CPUID DE LA VM\|"La VM no arranca"]] — pantalla negra |
| **2** | [[#AVERÍA 2 · DESFASAR LA HORA DEL MAC\|"No me deja entrar"]] — la hora |
| **3** | [[#AVERÍA 3 · 🔴 SACAR A masao.sato DEL GRUPO\|"Ya no veo mis carpetas"]] — ABE en directo |
| **4** | [[#AVERÍA 4 · CAMBIAR EL DNS DEL CLIENTE\|"No encuentro el servidor"]] — DNS |

---

# **AVERÍA 1 · QUITAR EL CPUID DE LA VM**

> [!abstract] 🎯 Objetivo
> Reproducir el fallo más característico del hackintosh: qué le pasa a la VM de macOS cuando le quitas la simulación de CPU. **Es el ensayo de "se me ha roto y no arranca".**

> [!question] 🤔 Predice antes de romper
> Si quitas el `--cpuidset` (el ajuste de CPU que hace que macOS "crea" que está en hardware válido), ¿qué verás al arrancar la VM? ¿Una pantalla negra? ¿Un mensaje?

### **1 · Romper**
Quita el ajuste de CPU que hace arrancar a macOS:
```bash
VBoxManage modifyvm "macOS" --cpuidremoveall
```

### **2 · Comprobar**
Arranca la VM de macOS.

### **3 · Consecuencias**
La VM **no arranca** — pantalla negra o se queda a mitad. Es exactamente el síntoma de "EXITBS / EndRandomSeed" que verías si montaras la VM mal.

### **4 · Reparar**
Vuelve a poner el `--cpuidset` de un Intel válido:
```bash
VBoxManage modifyvm "macOS" --cpuidset 00000001 000306a9 00020800 80000201 178bfbff
```
Arranca y comprueba que vuelve al escritorio.

> [!summary] 🎓 La lección
> **Sin la simulación de CPU, macOS se niega a arrancar.** Es el corazón de por qué montar una VM de macOS es delicado: no basta con crear la VM, hay que darle el hardware que el sistema exige.

---

# **AVERÍA 2 · DESFASAR LA HORA DEL MAC**

> [!abstract] 🎯 Objetivo
> Reproducir el fallo nº1: qué le hace a la autenticación un reloj del Mac desfasado.

> [!question] 🤔 Predice antes de romper
> Si adelantas la hora del Mac 2 horas, ¿qué pasará al conectar al servidor? ¿El `ping` fallará? ¿O fallará la autenticación?

### **1 · Romper**
En Ajustes → Fecha y hora, desactiva la automática y adelanta la hora 2 horas.

### **2 · Comprobar**
Intenta conectar al servidor por `smb://…` con `masao.sato`.

### **3 · Consecuencias**
La autenticación **falla** con un error de credenciales — **sin mencionar la hora**. El `ping` sigue funcionando (la red no tiene nada que ver).

### **4 · Reparar**
Vuelve a activar la hora automática. Reconecta y comprueba que entra.

> [!summary] 🎓 La lección
> **La hora es el fallo invisible de las tres fases.** Kerberos rechaza el desfase y el error no lo cuenta. En Windows, en Ubuntu y en el Mac.

---

# **AVERÍA 3 · 🔴 SACAR A `masao.sato` DEL GRUPO**

> [!abstract] 🎯 Objetivo
> Ver el **ABE** en directo desde el tercer sistema: qué ve el Mac cuando `masao.sato` deja de pertenecer a `comercial`.

> [!question] 🤔 Predice antes de romper
> Si sacas a `masao.sato` de `comercial` en el servidor, ¿desaparecerá `comercial` del Finder del Mac? ¿Y cuándo se dará cuenta el usuario?

### **1 · Romper**
En el **servidor**:
```bash
sudo samba-tool group removemembers "comercial" masao.sato
```

### **2 · Comprobar**
Desde el Mac, **desconecta y vuelve a conectar** (`Cmd + K` → conectar) con `masao.sato`.

### **3 · Consecuencias**
La carpeta `comercial` **desaparece** del Finder (ABE: sin permiso, ni se ve). Sigue viendo `facturacion`, `logistica`, `comun`.

### **4 · Reparar**
Vuelve a meterlo en el grupo (servidor):
```bash
sudo samba-tool group addmembers "comercial" masao.sato
```
Reconecta y comprueba que `comercial` aparece otra vez.

> [!summary] 🎓 La lección
> **El ABE lo decide el servidor, no el cliente.** Da igual que sea Windows, Ubuntu o macOS: un usuario sin permiso ni siquiera ve que la carpeta existe. Es la misma avería de las Fases 8 y 9, demostrada desde el tercer sistema.

---

# **AVERÍA 4 · CAMBIAR EL DNS DEL CLIENTE**

> [!abstract] 🎯 Objetivo
> Ver qué pasa cuando el Mac deja de resolver el dominio.

> [!question] 🤔 Predice antes de romper
> Si el Mac no puede resolver `UbuntuServer.BOOCHANLAB.LOCAL`, ¿podrá conectar por nombre? ¿Y por IP?

### **1 · Romper**
Cambia el DNS del Mac a un servidor que no conozca el dominio (p. ej. `8.8.8.8`), o pon un DNS manual incorrecto en Ajustes → Red.

### **2 · Comprobar**
```bash
ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
```

### **3 · Consecuencias**
El nombre no resuelve → el Finder no conecta por nombre. Pero **la IP directa sí funciona** (`smb://10.10.10.10`), porque la red no ha cambiado.

### **4 · Reparar**
Vuelve a poner el DNS automático (o el del servidor). Comprueba que el nombre vuelve a resolver.

> [!summary] 🎓 La lección
> **"Tengo red" y "resuelvo el nombre" son dos cosas distintas.** Y la IP directa es el plan B que siempre funciona — aunque pierdes Kerberos.

---

> [!success] ✅ Al terminar: comprueba que dejaste todo como estaba
> - [ ] Todas las averías reparadas: `--cpuidset` aplicado, hora automática, `masao.sato` en `comercial`, DNS correcto.
> - [ ] La VM de macOS arranca al escritorio.
> - [ ] Reconecta al servidor y comprueba que ves la matriz completa.
> - [ ] Añadido a la entrada de apuntes: el error de cada avería y cómo lo resolviste.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.9_Preguntas]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.10.b_Auditoria_y_Cierre]] |
