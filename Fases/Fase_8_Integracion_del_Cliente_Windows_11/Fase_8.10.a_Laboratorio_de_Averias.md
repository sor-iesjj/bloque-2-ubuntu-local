## Fase 8 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Después de las instantáneas** del apartado 8.b. Aquí vas a **romper la integración a propósito**.

---

> [!danger] 🛑 REQUISITO: las DOS instantáneas `Fase 8 terminada` deben estar hechas
> ```
> VBoxManage snapshot "Windows11" list
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si falta alguna, vuelve a [[Fase_8.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador de PowerShell en cada avería
> En el cliente:
> ```powershell
> cd $env:USERPROFILE
> curl.exe -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase8.ps1
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> ```

> [!warning] 🖥️ Este laboratorio es distinto a los siete anteriores
> Aquí no rompes un servicio: **rompes la relación entre dos máquinas**. Y el síntoma sale siempre en la máquina que **no** tiene el problema.
>
> Es la habilidad más difícil de todo el proyecto y la más parecida a un trabajo real: **te llaman desde el sitio donde se ve el error, y la causa está en otro sitio.**

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Un usuario nunca te va a decir *"falta `access based share enum` en el `smb.conf`"*. Te va a decir *"no me deja entrar"*, *"se han borrado mis carpetas"* o *"me dice que la contraseña está mal y no lo está"*.
>
> **Tu trabajo es traducir eso.** Estas seis averías son las seis frases que vas a oír de verdad, con su causa detrás.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3** | El cliente **no encuentra** el dominio |
> | **2.ª** | **4 · 5 · 6** | El cliente lo encuentra y **algo no cuadra** |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F8 · Laboratorio de averías`, con sus seis timestamps.

> [!tip] 💡 Las seis averías siguen siempre el mismo guion
> **🎯 Objetivo** → **🤔 Predice** → **1. Romper** → **2. Comprobar** → **3. Consecuencias** → **4. Reparar** → **🎓 La lección**
>
> **Y en esta fase hay un paso extra que importa más que ninguno:** antes de mirar nada, escribe **en qué máquina crees que está el problema**. Acertar eso es el objetivo del laboratorio.

---

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 6 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **1** | [[#**AVERÍA 1 · APAGAR EL SERVIDOR**\|APAGAR EL SERVIDOR]] |
> | **2** | [[#**AVERÍA 2 · CAMBIAR EL DNS DEL CLIENTE**\|CAMBIAR EL DNS DEL CLIENTE]] |
> | **3** | [[#**AVERÍA 3 · DESFASAR EL RELOJ**\|DESFASAR EL RELOJ]] |
> | **4** | [[#**AVERÍA 4 · 🔴 SACAR A `masao.sato` DEL GRUPO** *(y ver el ABE en directo)*\|🔴 SACAR A `masao.sato` DEL GRUPO]] |
> | **5** | [[#**AVERÍA 5 · ROMPER LA RELACIÓN DE CONFIANZA**\|ROMPER LA RELACIÓN DE CONFIANZA]] |
> | **6** | [[#**AVERÍA 6 · DESCONECTAR EL CABLE DEL LABORATORIO**\|DESCONECTAR EL CABLE DEL LABORATORIO]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 1 · APAGAR EL SERVIDOR**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** apagar el controlador de dominio y ver qué le pasa al cliente.
>
> **Por qué provocamos esta:** porque la respuesta **no es la que esperas**. El cliente va a seguir dejándote entrar, y eso confunde a mucha gente.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrás iniciar sesión con `BOOCHANLAB\masao.sato`?
> 2. ¿Podrás acceder a la unidad `Z:`?
> 3. ¿Podrás iniciar sesión con `shinnosuke.nohara`, que **nunca** ha entrado en este equipo?

### **1 · Romper**
En el **servidor**:
```bash
sudo poweroff
```
Y en el cliente, **cierra sesión y vuelve a entrar** con `BOOCHANLAB\masao.sato`.

### **2 · Comprobar**
En el cliente:
```cmd
whoami
ping 10.10.10.10
net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial
klist
```

**Cómo se interpreta lo que sale:**

| Qué pruebas | Qué pasa | Por qué |
| :--- | :--- | :--- |
| Iniciar sesión con `masao.sato` | **Funciona** | Credenciales **en caché** |
| `ping` al servidor | Falla | Está apagado |
| Acceder a `Z:` | Falla | No hay servidor que sirva la carpeta |
| `klist` | Tickets viejos o vacío | No se pueden pedir nuevos |
| Iniciar sesión con `shinnosuke.nohara` | **Falla** | Nunca entró aquí: no está en la caché |

> [!important] ✍️ Aquí anota tú lo que veas
> **Prueba a entrar con `shinnosuke.nohara` con el servidor apagado** y copia el mensaje exacto. Y responde: ¿por qué uno sí y el otro no?

### **3 · Consecuencias**
Un usuario diría *"puedo entrar pero no me funciona nada"*. Y tendría razón: **iniciar sesión y usar los recursos son dos cosas distintas**, y solo la primera sobrevive sin servidor.

### **4 · Reparar**
Enciende el servidor, espera a que arranque **del todo**, y en el cliente:
```cmd
net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial /persistent:yes
klist purge
```
*(Cierra sesión y vuelve a entrar para obtener tickets nuevos.)*

> [!success] 🎓 La lección
> Que **Windows guarda credenciales en caché a propósito**, para que un portátil fuera de la oficina siga siendo utilizable. No es un agujero: es una decisión de diseño.
>
> Y el equilibrio que hay detrás: **comodidad contra control.** A cambio de esa comodidad, un equipo robado sigue aceptando la contraseña de su último usuario. Saber que ese equilibrio existe —y hacia dónde lo resuelve cada sistema— es parte del oficio.

---

# **AVERÍA 2 · CAMBIAR EL DNS DEL CLIENTE**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** apuntar el DNS del cliente a `8.8.8.8` en lugar de al servidor.
>
> **Por qué provocamos esta:** porque produce *"no se encuentra el dominio"* **con el servidor encendido y la red perfecta**. Es el fallo número uno de esta fase.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá respondiendo el `ping 10.10.10.10`?
> 2. ¿Funcionará internet en el cliente?
> 3. ¿Encontrará el dominio?

### **1 · Romper**
En el cliente, adaptador de **Red Solo Anfitrión** → DNS preferido → `8.8.8.8`.

O por comando, en PowerShell como Administrador:
```powershell
Get-NetAdapter
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 8.8.8.8
```
*(Cambia `Ethernet` por el nombre del adaptador host-only.)*

### **2 · Comprobar**
```cmd
ping 10.10.10.10
nslookup BOOCHANLAB.LOCAL
nslookup www.google.com
ipconfig /flushdns
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ping` al servidor | **Responde** | La red está perfecta |
| `nslookup` del dominio | **No lo encuentra** | Google no sabe qué es `BOOCHANLAB.LOCAL` |
| `nslookup` de Google | **Funciona** | Internet va mejor que nunca |

> [!danger] 🤯 Fíjate en la contradicción
> **Hay red, hay internet, el servidor responde… y el dominio no existe.** Un usuario diría *"pero si tengo internet"*, y tendría razón — y precisamente por eso estaría mirando al sitio equivocado.

### **3 · Consecuencias**
Ningún usuario nuevo puede iniciar sesión, no se accede a los recursos, y el equipo acabará perdiendo la relación de confianza. Con un diagnóstico que se va a la red, que está bien.

### **4 · Reparar**
Devuelve el DNS a `10.10.10.10`:
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10
ipconfig /flushdns
nslookup BOOCHANLAB.LOCAL
```
- **✅ Reparado:** devuelve `10.10.10.10`.

> [!success] 🎓 La lección
> **"Funciona internet" y "funciona el DNS que necesito" son dos cosas distintas.** Es literalmente la misma lección de la avería 3 de la Fase 4, ahora desde el lado del cliente.
>
> Un dominio de Windows **vive del DNS**. Sin él no hay nada: ni localizar el controlador, ni Kerberos, ni recursos.

---

# **AVERÍA 3 · DESFASAR EL RELOJ**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** adelantar el reloj del cliente diez minutos.
>
> **Por qué provocamos esta:** porque produce **el mensaje más engañoso de todo el proyecto**: *"El nombre de usuario o la contraseña son incorrectos"* — con la contraseña correcta.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Te dirá Windows que el problema es la hora?
> 2. ¿Cuánto desfase crees que hace falta para que falle?
> 3. Si te pasara esto en clase sin saber lo de hoy, ¿dónde buscarías?

### **1 · Romper**
En el cliente, PowerShell como Administrador:
```powershell
Stop-Service w32time
Set-Date (Get-Date).AddMinutes(10)
Get-Date
```

### **2 · Comprobar**
Cierra sesión e intenta entrar con `BOOCHANLAB\shinnosuke.nohara`, o desde una sesión abierta:
```cmd
klist purge
net use Y: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial /user:BOOCHANLAB\masao.sato
w32tm /stripchart /computer:10.10.10.10 /samples:2 /dataonly
```

**Cómo se interpreta lo que sale:**

| Qué pruebas | Qué verás |
| :--- | :--- |
| Autenticar | *"El nombre de usuario o la contraseña son incorrectos"* |
| El mensaje | **No menciona la hora por ningún sitio** |
| `w32tm /stripchart` | Un desfase de **~600 segundos** |

> [!important] ✍️ Copia el mensaje de error TAL CUAL
> Pégalo en tu entrada de apuntes y **subraya la parte que menciona el reloj**.
>
> **Pista: no hay ninguna.** Ese es el ejercicio, y es el mismo que hiciste en la Fase 4 con el reino de Kerberos en minúsculas.

### **3 · Consecuencias**
Nadie puede autenticarse. Y quien lo diagnostique probará contraseñas, mirará usuarios, revisará el dominio y reiniciará servicios **antes de sospechar de la hora**.

### **4 · Reparar**
```powershell
Start-Service w32time
w32tm /resync /force
w32tm /stripchart /computer:10.10.10.10 /samples:2 /dataonly
```
- **✅ Reparado:** el desfase vuelve a ser de segundos y la autenticación funciona.

> [!success] 🎓 La lección
> **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**, y no es un capricho: los tickets llevan marca de tiempo precisamente para que un ticket robado no valga eternamente. Sin relojes de acuerdo, ese mecanismo no puede funcionar.
>
> Y la consecuencia práctica que te vas a llevar de por vida: **cuando unas credenciales correctas fallan, mira el reloj.** Es de las primeras cosas, no de las últimas.
>
> Y ahora ya sabes por qué todo este proyecto insiste tanto en apagar las VMs antes de tomar una instantánea.

---

# **AVERÍA 4 · 🔴 SACAR A `masao.sato` DEL GRUPO** *(y ver el ABE en directo)*

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** sacar a `masao.sato` del grupo `comercial` **desde el servidor**, y mirar qué le pasa a su vista de la red.
>
> **Por qué provocamos esta:** porque es **la demostración en vivo de la Fase 7**. No vas a leer que el ABE funciona: **vas a ver desaparecer una carpeta de la pantalla.**

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Desaparecerá `facturacion` de la vista de `masao.sato` inmediatamente?
> 2. ¿Hará falta cerrar sesión?
> 3. ¿Cambiará algo en el servidor, en los permisos de la carpeta?

### **1 · Romper**
Antes de nada, **con `masao.sato` en el cliente**, deja la foto del "antes":
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
Y ahora, en el **servidor**:
```bash
sudo samba-tool group removemembers comercial masao.sato
id -nG masao.sato
```

### **2 · Comprobar**
En el cliente, **cierra sesión y vuelve a entrar** con `masao.sato` *(la pertenencia a grupos se lee al iniciar sesión)*:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```

**Cómo se interpreta lo que sale:**

| Dónde | Qué verás |
| :--- | :--- |
| Antes, con `masao.sato` en `comercial` | `comercial` **y** `facturacion` |
| Después | **Solo `comercial`** |
| Permisos de la carpeta, en el servidor | **Sin cambios** |

> [!success] 🎯 Acabas de ver el ABE funcionando
> **No has tocado la carpeta.** Sus permisos, sus ACL y su configuración están exactamente igual que hace un minuto.
>
> Lo único que ha cambiado es **quién eres**. Y la carpeta ha desaparecido de tu mundo.
>
> Eso es *access based share enumeration*: el servidor no te enseña una lista fija — **te enseña tu lista.**

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia las dos salidas de `net view`**, la de antes y la de después. Y responde: ¿qué habría pasado si en la Fase 7 no hubieras puesto `access based share enum = yes`?

### **3 · Consecuencias**
En un caso real, esto es lo que pasa cuando alguien cambia de departamento: **deja de ver lo que ya no le corresponde**, sin que nadie tenga que tocar ni una carpeta. Que es exactamente para lo que sirven los grupos.

### **4 · Reparar**
En el servidor:
```bash
sudo samba-tool group addmembers comercial masao.sato
id -nG masao.sato
```
Y en el cliente, cerrando sesión y volviendo a entrar:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Reparado:** `facturacion` vuelve a aparecer.

> [!success] 🎓 La lección
> Que **los permisos se dan a grupos, no a personas**, y que ahí está toda la potencia: mover a alguien de grupo cambia lo que ve en toda la infraestructura, sin tocar ni un permiso.
>
> Y que **la pertenencia a grupos se lee al iniciar sesión**, no continuamente. Por eso hay que cerrar sesión para que un cambio se note — y por eso, cuando alguien dice *"me han dado permisos y no los tengo"*, la primera pregunta es siempre: **¿has cerrado sesión y vuelto a entrar?**

---

# **AVERÍA 5 · ROMPER LA RELACIÓN DE CONFIANZA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** sacar el equipo del dominio y volver a meterlo.
>
> **Por qué provocamos esta:** porque *"Error en la relación de confianza entre esta estación de trabajo y el dominio principal"* es un mensaje que vas a ver en tu vida profesional, y conviene haberlo arreglado antes con calma.

> [!question] 🤔 Predice antes de ejecutar
> 1. Al sacar el equipo del dominio, ¿desaparecerá su cuenta del servidor?
> 2. ¿Podrás volver a entrar con `masao.sato` mientras está fuera?
> 3. ¿Qué hará falta para volver a unirlo?

### **1 · Romper**
En el cliente, `Configuración` → `Sistema` → `Acerca de` → `Cambiar nombre de este PC (avanzado)` → `Cambiar…` → selecciona **Grupo de trabajo** y escribe `WORKGROUP`.

Te pedirá credenciales de administrador del dominio y **un reinicio**.

> [!warning] ⚠️ Antes de reiniciar, comprueba que sabes la contraseña del usuario LOCAL
> Al salir del dominio, las cuentas de dominio dejan de servir para entrar. **Vas a necesitar el usuario local de Windows** que creaste al instalarlo. Si no lo recuerdas, **no hagas esta avería**: restaura la instantánea al terminar las demás.

### **2 · Comprobar**
Tras el reinicio, entra con el usuario local:
```cmd
whoami
systeminfo | findstr /i "Dominio Domain"
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
Y en el **servidor**, mira si la cuenta del equipo sigue ahí:
```bash
sudo samba-tool computer list
```

**Cómo se interpreta lo que sale:**

| Dónde | Qué verás |
| :--- | :--- |
| `systeminfo` | Grupo de trabajo `WORKGROUP` |
| Iniciar sesión con `masao.sato` | **Imposible**: ya no hay dominio |
| `samba-tool computer list` | La cuenta del equipo **puede seguir ahí**, huérfana |

### **3 · Consecuencias**
El equipo está fuera. Y en el servidor puede quedar una **cuenta de equipo huérfana**, que es justo lo que provoca el error de relación de confianza cuando alguien vuelve a unir una máquina con el mismo nombre sin limpiar antes.

### **4 · Reparar**
Vuelve a unirlo, exactamente como en el Paso 3 del procedimiento: `Dominio` → `BOOCHANLAB.LOCAL` → **`BOOCHANLAB\Administrator`** / `P@ssw0rd` → reiniciar.

Y comprueba:
```cmd
systeminfo | findstr /i "Dominio Domain"
klist
```
Después, entra con `BOOCHANLAB\masao.sato` y pasa el verificador.

> [!success] 🎓 La lección
> Que **un equipo también tiene una identidad en el dominio**, no solo los usuarios. Tiene su cuenta, su contraseña —que rota sola— y su relación de confianza.
>
> Cuando esa relación se rompe —por una restauración de instantánea desincronizada, por un cambio de nombre, por una cuenta huérfana— el equipo deja de ser de confianza aunque los usuarios y las contraseñas sean correctos.
>
> **Y por eso el 8.b te pidió tratar las dos instantáneas como una pareja.** Restaurar una sola es la forma más limpia de provocar este error.

---

# **AVERÍA 6 · DESCONECTAR EL CABLE DEL LABORATORIO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** desmarcar `Cable conectado` en el adaptador host-only del cliente, dejando el NAT intacto.
>
> **Por qué provocamos esta:** porque crea la situación más engañosa posible: **internet funciona perfectamente y el dominio no existe.** El usuario dirá *"tengo internet, así que la red va bien"*.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Funcionará internet?
> 2. ¿Funcionará el dominio?
> 3. ¿Qué dirá el icono de red de Windows?

### **1 · Romper**
En VirtualBox, con el cliente encendido: `Dispositivos` → `Red` → `Configuración de red` → **Adaptador 1 (host-only)** → desmarca **`Cable conectado`**.

### **2 · Comprobar**
```cmd
ipconfig /all
ping 10.10.10.10
ping 8.8.8.8
nslookup BOOCHANLAB.LOCAL
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ping 8.8.8.8` | **Responde** | Internet va perfectamente |
| `ping 10.10.10.10` | Falla | No hay camino al servidor |
| `ipconfig` | El adaptador host-only, **desconectado** | Aquí está la pista |
| `net view` | Error de red | Sin servidor no hay recursos |

> [!important] ✍️ Anota el mensaje del icono de red
> Windows muestra el equipo **como conectado**, porque lo está — por el NAT. **El icono de red no te va a avisar de nada.**

### **3 · Consecuencias**
Un usuario que dice *"la red funciona, tengo internet"* y un administrador que le cree. Mientras, el equipo no llega a la única red que le importa para el dominio.

### **4 · Reparar**
Vuelve a marcar `Cable conectado`, y en el cliente:
```cmd
ipconfig /renew
ping 10.10.10.10
.\verificar_fase8.ps1
```

> [!success] 🎓 La lección
> Que **un equipo con dos tarjetas tiene dos conectividades independientes**, y que una puede estar perfecta mientras la otra no existe.
>
> Y la pregunta de diagnóstico que hay que hacer siempre: no *"¿tienes red?"* sino **"¿tienes red hacia dónde?"**. Es la misma idea que arrastras desde la Fase 1 con las dos tarjetas del servidor, cerrando el círculo en el cliente.

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

En el cliente, **con `masao.sato`**:
```powershell
.\verificar_fase8.ps1
```
Y en el **servidor**:
```bash
sudo ./verificar_fase7.sh
sudo ./verificar_fase5.sh
```

- **✅ Bien:** los tres en `SUPERADA`.
- **❌ Mal:** cada script te dice exactamente qué quedó sin reparar.

> [!tip] 💡 Si algo se te ha quedado torcido, tienes las dos instantáneas
> Restaura **`Fase 8 terminada` en las dos máquinas** —recuerda: van en pareja— y vuelves al punto bueno.

> [!warning] ⚠️ Comprueba que no te dejas restos
> ```cmd
> net use
> ```
> Que no queden unidades `Y:` sueltas de la avería 3, ni ficheros de prueba en las carpetas compartidas.

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y verificador en verde al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, **incluyendo en qué máquina crees que estará el problema**.
- [ ] Anotado por qué `masao.sato` pudo entrar sin servidor y `shinnosuke.nohara` no *(avería 1)*.
- [ ] Copiado **el mensaje de error literal** de la avería 3, y comentado que no menciona la hora.
- [ ] 🔴 Copiadas **las dos salidas de `net view`** de la avería 4, antes y después.
- [ ] Anotado que en la avería 6 **el icono de red de Windows no avisaba de nada**.
- [ ] Restos limpiados: unidades sueltas y ficheros de prueba.
- [ ] Verificadores pasados al final, **en las dos máquinas**.
- [ ] Todo grabado en el vídeo **`B2 · F8 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.9_Preguntas]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.10.b_Auditoria_y_Cierre]] |
