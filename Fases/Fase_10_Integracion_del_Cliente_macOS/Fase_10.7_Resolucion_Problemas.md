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
| "Nombre de usuario o contraseña incorrectos" | [[#C2 · La contraseña correcta falla\|C2]] |
| No se conecta / no encuentra el servidor | [[#C1 · No llego al servidor\|C1]] |
| Entro pero no veo carpetas (o no las que tocan) | [[#C3 · Entro pero no veo mis carpetas\|C3]] |
| `smb://` se queda colgado o tarda | [[#C4 · La conexión tarda o se cuelga\|C4]] |

---

### C1 · No llego al servidor

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

### C2 · La contraseña correcta falla

> [!bug] Síntoma
> Entras con `masao.sato` y `P@ssw0rd`, que son correctos, y el Mac dice que el usuario o la contraseña son incorrectos.

**Hipótesis.** **La hora del Mac.** Kerberos rechaza más de 5 minutos de desfase, y el error no lo dice.

**Comprobación.** Ajustes → Fecha y hora: ¿la hora es correcta?

**Arreglo.** Activa la hora automática o ajústala a mano. Vuelve a intentar.

> [!summary] Qué aprendes
> Que el error de credenciales no siempre es la contraseña — es la hora. Igual que en Windows (Fase 8) y en Ubuntu (Fase 9). **Es el fallo nº1 de esta fase.**

---

### C3 · Entro pero no veo mis carpetas

> [!bug] Síntoma
> Conectas y ves el servidor, pero no las carpetas que esperabas.

**Hipótesis.** O bien estás entrando con el usuario equivocado, o bien la matriz/ABE no está como debe.

**Comprobación.** ¿Con qué usuario entraste? ¿`masao.sato` (comercial)?

**Arreglo.** Si entras con otro usuario (o con la cuenta local del Mac), las carpetas que veas son las de **ese** usuario. Cierra sesión de la conexión y entra con el usuario del dominio que toca.

> [!summary] Qué aprendes
> Que lo que ves en una carpeta compartida depende de **quién eres**, no del sistema con el que entras. La matriz la decide el servidor.

---

### C4 · La conexión tarda o se cuelga

> [!bug] Síntoma
> `smb://…` tarda mucho en conectar, o se queda colgado.

**Hipótesis.** El Mac intenta resolver el nombre por varios servidores DNS antes de dar con el correcto, o hay un problema de red.

**Comprobación.** Espera; si no conecta, prueba con la IP directa.

**Arreglo.** Usa `smb://10.10.10.10` en vez del nombre (funciona, aunque sin Kerberos). Si va por nombre pero lento, revisa el DNS.

> [!summary] Qué aprendes
> Que a veces lo pragmático (IP directa) desbloquea, aunque el ideal sea el nombre (que permite Kerberos).

---

> [!question] 🤔 Si tu fallo no está aquí
> 1. Comprueba el **servidor**, que es donde suele estar el problema: `sudo ./verificar_fase7.sh`.
> 2. Pregunta en el aula — el problema puede ser de red (Mac fuera de la red del laboratorio).
> 3. Anota el mensaje literal en tu entrada de apuntes.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.6_Procedimiento]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.8.a_Verificacion]] |
