## Fase 9 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**

> [!danger] 🛑 En esta fase, casi todo lo que falla NO es de esta fase
> El dominio, la hora, el DNS y los permisos vienen de **fases anteriores**. Cuando `realm join` falle, la causa casi nunca está en el comando en sí — está detrás, en algo que montaste (o no) hace semanas. Lo mismo que te avisaba la Fase 8.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| `realm join` falla con error de **credenciales** | [[#C2 · La unión falla por credenciales\|C2]] |
| `realm join` falla **sin razón aparente** | [[#C1 · La unión falla: la hora (fallo nº1)\|C1]] |
| `realm join` no encuentra el dominio | [[#C3 · No encuentra el dominio\|C3]] |
| Entro con usuario del dominio pero **no veo carpetas** | [[#C4 · El usuario ve la pantalla pero no las carpetas\|C4]] |
| `nslookup BOOCHANLAB.LOCAL` no resuelve | [[#C3 · No encuentra el dominio\|C3]] |
| El cliente **no llega** al servidor (`ping` falla) | [[#C5 · El cliente no ve el servidor\|C5]] |

---

### C1 · La unión falla: la hora (fallo nº1)

> [!bug] Síntoma
> `realm join` da un error de Kerberos o *"unable to join"* sin un mensaje claro. **El comando no menciona la hora.**

**Hipótesis.** La **zona horaria** de la VM de Ubuntu Desktop está en UTC (2 h de desfase en verano), y Kerberos rechaza más de 5 minutos.

**Comprobación.**
```bash
timedatectl
```
Mira el `Time zone`. Si no es `Europe/Madrid`, es esto.

**Arreglo.**
```bash
sudo timedatectl set-timezone Europe/Madrid
```
Y vuelve a intentar la unión.

> [!summary] Qué aprendes
> Que el error de Kerberos **no dice lo que es**. Una VM recién instalada arranca en UTC, y eso rompe la unión "sin razón". La hora es lo primero que se mira cuando algo de dominio falla — en Windows (Fase 8) y en Linux (aquí).

---

### C2 · La unión falla por credenciales

> [!bug] Síntoma
> `realm join` responde *"Insufficient permissions"* o rechaza la contraseña.

**Hipótesis.** La cuenta que usas no es la del dominio, o la contraseña no es la de `Administrator`.

**Comprobación.** ¿Qué usuario estás pasando?

**Arreglo.** Usa la cuenta del **dominio**, no la local del servidor ni la del cliente:
```bash
sudo realm join --user=Administrator@BOOCHANLAB.LOCAL BOOCHANLAB.LOCAL
```
Contraseña: `P@ssw0rd` — la de `BOOCHANLAB\Administrator`, **no** la de `boochan`.

> [!summary] Qué aprendes
> Que la unión la autoriza el **dominio**, y en el dominio el administrador es `Administrator`. Es exactamente la confusión de contraseñas que viste en la Fase 8 (usuario local del servidor vs administrador del dominio).

---

### C3 · No encuentra el dominio

> [!bug] Síntoma
> `realm join` o `nslookup BOOCHANLAB.LOCAL` dicen que no existe o que no hay servidor.

**Hipótesis.** El **DNS** del cliente no apunta al servidor (o apunta al NAT/Internet).

**Comprobación.**
```bash
nslookup BOOCHANLAB.LOCAL
cat /etc/resolv.conf
```

**Arreglo.** Pon el DNS a `10.10.10.10` en la configuración de red del cliente (Paso 5 del procedimiento) y vuelve a intentar.

> [!summary] Qué aprendes
> Que sin resolver el dominio, `realm join` no sabe a quién preguntar. Igual que en la Fase 8: primero el DNS, después el resto.

---

### C4 · El usuario ve la pantalla pero no las carpetas

> [!bug] Síntoma
> Inicias sesión con `masao.sato` del dominio, pero el gestor de archivos no muestra las carpetas del servidor.

**Hipótesis.** No las has buscado: en Ubuntu **no aparecen solas**. Hay que ir a `smb://…`, igual que en Windows no aparecían en "Este equipo".

**Arreglo.** En el gestor de archivos, barra de dirección:
```
smb://UbuntuServer.BOOCHANLAB.LOCAL
```
Entra con `masao.sato` / `P@ssw0rd`. Si pide el dominio, usa `BOOCHANLAB\masao.sato`.

> [!summary] Qué aprendes
> Que "ver carpetas de red" es una acción explícita, no automática — en Windows (Fase 8) y en Linux (aquí) por igual.

---

### C5 · El cliente no ve el servidor

> [!bug] Síntoma
> `ping 10.10.10.10` falla desde el cliente.

**Hipótesis.** El cliente no está en la Red Solo Anfitrión correcta, o no tiene IP de `10.10.10.0/24`.

**Comprobación.**
```bash
ip addr show
```

**Arreglo.** En VirtualBox, `UbuntuDesktop → Configuración → Red → Adaptador 1` → la misma red host-only que usa `UbuntuServer`. Si tiene IP `169.254.x.x`, la red no está bien asignada.

> [!summary] Qué aprendes
> Que sin red no hay nada que unir. `ping` primero, dominio después — la prueba más barata que existe.

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. Pasa el verificador (8.a): te dice qué está mal.
> 2. Comprueba el **servidor**, que es donde suele estar el problema: `sudo ./verificar_fase7.sh` y `sudo ./verificar_fase4.sh`.
> 3. Anota el mensaje **literal** en tu entrada de apuntes, aunque lo resuelvas.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.6_Procedimiento]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.8.a_Verificacion]] |
