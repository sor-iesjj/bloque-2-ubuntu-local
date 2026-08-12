## Fase 9 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Después del punto de control.** Romper de verdad, para aprender reparando.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 9 terminada` del cliente DEBE estar hecha
> Aquí vas a romper el cliente a propósito. Sin la instantánea, no hay red de seguridad — y esta fase es justo para ensayar que sabes reparar. Si algo se rompe de verdad y no puedes arreglarlo: **restaura la instantánea** y anota qué hiciste mal.

> [!info] 🤖 En cada avería vas a usar el verificador (`verificar_fase9.sh`)
> Igual que en las fases anteriores: romper → comprobar con el comando → diagnosticar → reparar → **volver a pasar el verificador hasta que esté en verde**.

> [!warning] ⏱️ **Sigue siendo UN SOLO vídeo** `B2 · F9 · Averías`, con un timestamp por avería.

> [!tip] 💡 Las averías siguen siempre el mismo guion
> **Romper** (qué tocas) → **Comprobar** (qué comando lo confirma) → **Diagnosticar** (por qué) → **Reparar** (cómo se arregla). Predice antes de romper: ¿qué crees que pasará?

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 4 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**

| **Avería** | **La frase del cliente que la resume** |
| :--- | :--- |
| **1** | [[#AVERÍA 1 · CAMBIAR EL DNS DEL CLIENTE\|"No me une"]] — el DNS apunta mal |
| **2** | [[#AVERÍA 2 · DESFASAR LA HORA\|"Me da un error raro"]] — la hora en UTC |
| **3** | [[#AVERÍA 3 · 🔴 SACAR A masao.sato DEL GRUPO\|"Ya no veo mis carpetas"]] — ABE en directo |
| **4** | [[#AVERÍA 4 · ROMPER LA RELACIÓN CON EL DOMINIO\|"Me he quedado fuera"]] — salirse del dominio |

---

# **AVERÍA 1 · CAMBIAR EL DNS DEL CLIENTE**

> [!abstract] 🎯 Objetivo
> Ver qué pasa cuando el cliente deja de preguntar al servidor y pregunta a Internet: la unión al dominio (o el acceso) **se rompe sin tocar nada del servidor**.

> [!question] 🤔 Predice antes de romper
> Si el DNS del Ubuntu Desktop apunta a un servidor de Internet en vez de a `10.10.10.10`, ¿qué fallará exactamente? ¿El `ping`? ¿`realm list`? ¿El acceso a carpetas?

### **1 · Romper**
En la configuración de red del cliente, cambia el **DNS** a `8.8.8.8` (o a cualquier servidor que no sea el del laboratorio).

### **2 · Comprobar**
```bash
nslookup BOOCHANLAB.LOCAL
realm list
```
### **3 · Consecuencias**
`nslookup` no resuelve el dominio (pregunta a Google, que no lo conoce). **`realm list` puede seguir diciendo que está unido** — la pertenencia está en el fichero local, no depende del DNS en ese momento — pero un **inicio de sesión nuevo de un usuario del dominio** fallará, porque para autenticar hay que resolver al controlador.

### **4 · Reparar**
Vuelve a poner el DNS a `10.10.10.10` (Paso 5 del procedimiento). Comprueba que `nslookup BOOCHANLAB.LOCAL` vuelve a resolver y que un usuario del dominio puede entrar.

> [!summary] 🎓 La lección
> **"Tengo internet" y "resuelvo el dominio" son dos cosas distintas.** Igual que en la Fase 8 (caso E2), pero ahora desde el lado Linux. El DNS es lo primero que se revisa.

---

# **AVERÍA 2 · DESFASAR LA HORA**

> [!abstract] 🎯 Objetivo
> Reproducir el fallo nº1 de la fase: qué le hace a la autenticación un reloj desfasado, y por qué el error no lo dice.

> [!question] 🤔 Predice antes de romper
> Si pones el reloj del cliente en UTC (2 h de desfase), ¿qué comando empezará a fallar? ¿`realm join`? ¿`getent passwd masao.sato`? ¿O solo el inicio de sesión con usuario del dominio?

### **1 · Romper**
```bash
sudo timedatectl set-timezone UTC
```

### **2 · Comprobar**
```bash
timedatectl
# y, si hay una sesión del dominio abierta, intenta entrar de nuevo
```

### **3 · Consecuencias**
La autenticación **Kerberos** falla: el ticket se considera inválido por desfase. El mensaje de error no dice "es la hora" — dice algo de credenciales o de servicio.

### **4 · Reparar**
```bash
sudo timedatectl set-timezone Europe/Madrid
```
Vuelve a comprobar que un usuario del dominio puede autenticarse.

> [!summary] 🎓 La lección
> **La hora es invisible hasta que la miras.** Kerberos tolera 5 minutos de desfase; una zona horaria mal puesta son 2 horas. Y el error no lo cuenta.

---

# **AVERÍA 3 · 🔴 SACAR A `masao.sato` DEL GRUPO**

> [!abstract] 🎯 Objetivo
> Ver el **ABE** en directo desde el lado libre: qué ve `masao.sato` cuando deja de pertenecer a `comercial`.

> [!question] 🤔 Predice antes de romper
> Si sacas a `masao.sato` del grupo `comercial` en el servidor, ¿qué cambiará en lo que ve desde el Ubuntu Desktop? ¿Y cuándo se dará cuenta?

### **1 · Romper**
En el **servidor**, saca a `masao.sato` de `comercial`:
```bash
sudo samba-tool group removemembers "comercial" masao.sato
```

### **2 · Comprobar**
Desde el cliente, **cierra sesión y entra** como `masao.sato`, y mira `smb://UbuntuServer.BOOCHANLAB.LOCAL`.

### **3 · Consecuencias**
La carpeta `comercial` **desaparece** del listado (ABE: sin permiso, ni se ve). Lo que **sí** sigue viendo: `facturacion` y `logistica` (lectura), `comun`. No es que no pueda entrar en `comercial`: es que **no aparece**.

### **4 · Reparar**
Vuelve a meterlo en el grupo (servidor):
```bash
sudo samba-tool group addmembers "comercial" masao.sato
```
Comprueba que, al volver a entrar, `comercial` aparece otra vez.

> [!summary] 🎓 La lección
> **El ABE no depende del cliente.** Da igual que sea Windows o Ubuntu: lo que se ve lo decide el servidor, y un usuario sin permiso ni siquiera ve que la carpeta existe. Es la misma prueba que la avería 4 de la Fase 8 — ahora demostrada desde Linux.

---

# **AVERÍA 4 · ROMPER LA RELACIÓN CON EL DOMINIO**

> [!abstract] 🎯 Objetivo
> Ver qué significa "estar unido al dominio" cuando se rompe el vínculo: el equipo deja de resolver usuarios del dominio.

> [!question] 🤔 Predice antes de romper
> Si dejas de estar unido al dominio, ¿qué pasa con las cuentas del dominio? ¿Se borran del servidor? ¿Y un usuario local del cliente, puede seguir entrando?

### **1 · Romper**
En el cliente, sal del dominio:
```bash
sudo realm leave --user=Administrator BOOCHANLAB.LOCAL
```

### **2 · Comprobar**
```bash
realm list
getent passwd masao.sato
```

### **3 · Consecuencias**
- `realm list` ya no muestra el dominio configurado.
- `getent passwd masao.sato` **no devuelve nada**: el cliente ya no sabe quién es el usuario del dominio.
- **El usuario local de la instalación sigue entrando** (cuenta local), pero los del dominio ya no.
- **En el servidor no se borra nada**: las cuentas siguen (son del dominio, no del cliente).

### **4 · Reparar**
Vuelve a unir:
```bash
sudo realm join --user=Administrator BOOCHANLAB.LOCAL
```
Comprueba que `getent passwd masao.sato` vuelve a resolver y que el usuario del dominio puede entrar.

> [!summary] 🎓 La lección
> **"Estar unido al dominio" es una relación entre dos máquinas, no una casilla en el cliente.** Se puede romper por el lado del cliente sin tocar el servidor — y al revés. Es la misma avería que la 5 de la Fase 8, pero con `realm`.

---

> [!success] ✅ Al terminar: comprueba que dejaste todo como estaba
> - [ ] Todas las averías reparadas: DNS a `10.10.10.10`, hora en `Europe/Madrid`, `masao.sato` en `comercial`, unido al dominio.
> - [ ] `sudo ./verificar_fase9.sh` en verde.
> - [ ] Añadido a la entrada de apuntes: el error de cada avería y cómo lo resolviste.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.9_Preguntas]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.10.b_Auditoria_y_Cierre]] |
