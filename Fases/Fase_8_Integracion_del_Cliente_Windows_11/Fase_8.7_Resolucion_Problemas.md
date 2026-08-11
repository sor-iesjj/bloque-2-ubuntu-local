## Fase 8 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**

> [!danger] 🛑 En esta fase, la mitad de los fallos NO son de esta fase
> Windows te dará mensajes como *"No se encuentra el dominio"* o *"El nombre de usuario o la contraseña son incorrectos"*. **Casi ninguno de esos mensajes apunta al sitio donde está el problema**, y muchos vienen de trabajo que hiciste hace semanas.
>
> | Lo que ves aquí | Dónde suele estar el fallo |
> | :--- | :--- |
> | No se encuentra el dominio | Fase 4 *(el dominio en la tarjeta NAT)* o el DNS del cliente |
> | Usuario o contraseña incorrectos | El **reloj**, no la contraseña |
> | `shinnosuke.nohara` ve la carpeta protegida | **Fase 7** *(falta el ABE)* |
> | El usuario no puede escribir | Fase 5 *(los UID)* o Fase 7 *(la máscara)* |
>
> **Esta fase es el examen de todo lo anterior.** Por eso los casos de abajo te mandan constantemente a fases previas: no es un defecto del material, es cómo funciona un sistema real.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| `No se encuentra el dominio` y el ping falla | [[#E1 · No se encuentra el dominio y no hay red\|E1]] |
| `No se encuentra el dominio` pero el ping va | [[#E2 · No se encuentra el dominio aunque hay red\|E2]] |
| `Error de relación de confianza` / credenciales incorrectas | [[#E3 · Relación de confianza o credenciales incorrectas\|E3]] 🕐 |
| La unidad `Z:` desaparece al reiniciar | [[#E4 · La unidad Z: desaparece al reiniciar\|E4]] |
| RSAT no se descarga | [[#E5 · RSAT no se descarga\|E5]] |
| **`shinnosuke.nohara` VE la carpeta protegida** | [[#E6 · shinnosuke.nohara ve la carpeta que no debería ver\|E6]] ⚠️ |
| El usuario entra pero no puede escribir | [[#E7 · El usuario entra pero no puede escribir\|E7]] |
| Puedo iniciar sesión con el servidor APAGADO | [[#E8 · Puedo iniciar sesión con el servidor apagado\|E8]] |
| 🔴 **La VM de Windows se cuelga instalando** · icono de **tortuga** · «ejecución nativa API» | [[#E9 · La VM de Windows se cuelga y VirtualBox muestra una tortuga\|E9]] 🛑 |

---

### E1 · No se encuentra el dominio y no hay red

> [!bug] Síntoma
> Al intentar unirte: *"No se encontró el dominio BOOCHANLAB.LOCAL"*. Y desde el cliente:
> ```cmd
> ping 10.10.10.10
> ```
> tampoco responde.

**Hipótesis.** Las dos máquinas no están en la misma red de laboratorio, o el cliente no tiene la IP correcta.

**Comprobación.** En el cliente:
```cmd
ipconfig /all
ping 10.10.10.10
```
Y en **VirtualBox**, con las dos VMs a la vista: `Configuración` → `Red` → `Adaptador 1`.

| Qué mirar | Tiene que ser |
| :--- | :--- |
| IP del cliente | `10.10.10.20` con máscara `255.255.255.0` |
| Adaptador 1 de **las dos** VMs | `Red Solo Anfitrión`, **con el mismo nombre de red** |
| Cable conectado | Marcado en `Avanzadas` |

**Arreglo.** Pon las dos VMs en **la misma** red host-only —la que tiene la IP `10.10.10.1`— y comprueba el ping antes de volver a intentar la unión.

> [!warning] ⚠️ "Las dos están en Red Solo Anfitrión" no basta
> VirtualBox permite tener **varias** redes host-only distintas. Dos máquinas pueden estar las dos en "Red Solo Anfitrión" y **en redes diferentes**, sin verse. Hay que comprobar el **nombre** de la red, no el modo.

> [!summary] Qué aprendes
> Que **ping a una IP es la prueba más barata que existe** y siempre va primero: si no hay camino físico, no hay nada más que investigar. Es lo mismo que hacías en la Fase 4 con `ping 8.8.8.8` para separar "no hay red" de "no hay DNS".

---

### E2 · No se encuentra el dominio aunque hay red

> [!bug] Síntoma
> `ping 10.10.10.10` **responde perfectamente**, y Windows sigue diciendo que no encuentra el dominio.

**Hipótesis.** El cliente tiene red pero **no sabe a quién preguntar**: su DNS apunta al router de casa o a Google en vez de al servidor. Y ni el router ni Google saben nada de `BOOCHANLAB.LOCAL`.

**Comprobación.**
```cmd
nslookup BOOCHANLAB.LOCAL
ipconfig /all | findstr /i "DNS"
```
- **✅ Bien:** `nslookup` devuelve `10.10.10.10`.
- **❌ Mal:** *"no se encuentra el servidor"*, o el DNS configurado no es `10.10.10.10`.

**Arreglo.** Pon `10.10.10.10` como **DNS preferido del adaptador de Red Solo Anfitrión** *(Paso 1 del procedimiento)*.

> [!danger] ⚠️ Si el DNS es correcto y AUN ASÍ falla, el problema está en la Fase 4
> Ejecuta esto en el cliente:
> ```cmd
> nslookup ubuntuserver.boochanlab.local 10.10.10.10
> ```
> Si devuelve una dirección **`10.0.2.x`** en lugar de `10.10.10.10`, has encontrado el fallo silencioso de la Fase 4: **el dominio se anunció en la tarjeta NAT**.
>
> Ese es exactamente el fallo del que te avisaba el [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5 de la Fase 4]], tres semanas después y con este mensaje que no lo menciona por ningún sitio. **Se arregla allí, no aquí.**

> [!summary] Qué aprendes
> Que **"hay red" y "hay resolución de nombres" son dos cosas distintas**, y que un dominio de Windows depende por completo de la segunda.
>
> Y algo más grande: **el mensaje de error te dice la consecuencia, no la causa.** *"No se encuentra el dominio"* puede significar cinco cosas distintas, y ninguna de ellas está escrita en el mensaje.

---

### E3 · Relación de confianza o credenciales incorrectas

> [!bug] Síntoma
> Escribes `BOOCHANLAB\masao.sato` y `P@ssw0rd`, que **son correctos**, y Windows responde:
> ```
> El nombre de usuario o la contraseña son incorrectos
> ```
> O, tras unirte: *"Error en la relación de confianza entre esta estación de trabajo y el dominio principal"*.

**Hipótesis.** **El reloj.** Kerberos rechaza cualquier autenticación con más de **5 minutos** de desfase entre cliente y servidor, y el mensaje de error **no menciona la hora en ningún sitio**.

Pasa siempre por lo mismo: dejaste una VM en pausa o con el estado guardado, y al reanudarla su reloj se quedó donde lo dejaste.

**Comprobación.** En el cliente, como Administrador:
```cmd
w32tm /stripchart /computer:10.10.10.10 /samples:3 /dataonly
```
Mira la columna del desfase. **Más de 300 segundos y Kerberos no te dejará entrar.**

**Arreglo.**
```cmd
w32tm /resync /force
```
Y si el equipo no consigue sincronizar, ajusta la hora a mano y vuelve a intentarlo.

> [!danger] 🛑 Este es el motivo de que las instantáneas se tomen con la VM APAGADA
> Una instantánea tomada con la máquina encendida guarda **el contenido de la RAM**, y con ella el reloj. Al restaurarla dentro de tres semanas, la máquina despierta creyendo que sigue siendo aquel día.
>
> Y entonces te encuentras esto: **un dominio intacto, unas credenciales correctas, y nadie puede entrar.** Es la razón por la que cada apartado 8.b del proyecto insiste en apagar del todo.

> [!summary] Qué aprendes
> Que **la autenticación moderna depende del tiempo.** Kerberos usa tickets con caducidad, y para que dos máquinas se pongan de acuerdo en si un ticket es válido, tienen que estar de acuerdo en qué hora es.
>
> Y la lección de diagnóstico: cuando unas credenciales correctas fallan, **el reloj es de las primeras cosas que hay que mirar**, no de las últimas.

---

### E4 · La unidad Z: desaparece al reiniciar

> [!bug] Síntoma
> Mapeas la carpeta con `net use`, funciona, y al cerrar sesión o reiniciar ya no está.

**Hipótesis.** El mapeo se hizo **sin la opción de persistencia**, y `net use` no la aplica por defecto.

**Comprobación.**
```cmd
net use
```

**Arreglo.**
```cmd
net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial /persistent:yes
```

> [!summary] Qué aprendes
> **`active` es "ahora"; `enabled` es "la próxima vez"** — en su versión de Windows. Llevas seis fases encontrándote la misma distinción: `netplan`, `wg-quick@wg0`, `samba-ad-dc`, `winbind`, `fstab` y ahora `/persistent:yes`.
>
> Seis mecanismos distintos, en dos sistemas operativos, para la misma idea: **lo que no persiste, no está configurado.** Solo está puesto.

---

### E5 · RSAT no se descarga

> [!bug] Síntoma
> En `Características opcionales`, RSAT se queda *"buscando actualizaciones"* o falla la instalación.

**Hipótesis.** RSAT se descarga **de internet**, y el cliente está saliendo por la red del laboratorio, que no tiene salida.

**Comprobación.**
```cmd
ping 8.8.8.8
nslookup www.microsoft.com
```

**Arreglo.** Comprueba en VirtualBox que el cliente tiene **dos adaptadores**: el host-only para el laboratorio y el **NAT** para internet. El NAT tiene que estar conectado.

> [!warning] ⚠️ Ojo con el DNS después de tocar los adaptadores
> Si al arreglar la salida a internet cambias el DNS del adaptador equivocado, romperás el dominio. **El DNS `10.10.10.10` va en el adaptador de Red Solo Anfitrión**; el del NAT se deja en automático.

> [!summary] Qué aprendes
> Que **una máquina con dos tarjetas tiene dos trabajos**, y que cada configuración va en la tarjeta que le toca. Es lo mismo que aprendiste en el servidor en la Fase 1 — aquí lo repites del otro lado.

---

### E6 · shinnosuke.nohara ve la carpeta que no debería ver

> [!bug] Síntoma
> Inicias sesión con `BOOCHANLAB\shinnosuke.nohara`, que **no** pertenece al grupo `comercial`, abres `\\UbuntuServer.BOOCHANLAB.LOCAL` y **`facturacion` aparece en la lista**.
>
> Al intentar abrirla, acceso denegado — correcto. Pero **la ve**.

**Hipótesis.** Falta `access based share enum = yes` en la sección `[facturacion]` del `smb.conf` **del servidor**. El problema no está en el cliente: está en la Fase 7.

**Comprobación.** En el **servidor Ubuntu**:
```bash
testparm -s --section-name=facturacion
```
- **✅ Bien:** `access based share enum = Yes` y `hide unreadable = Yes`.
- **❌ Mal:** falta alguna.

**Arreglo.** En el servidor, y **validando antes de reiniciar**:
```bash
sudo nano /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
```
Después, en el cliente, **cierra sesión y vuelve a entrar** con `shinnosuke.nohara` para comprobarlo.

> [!danger] 🎯 Enhorabuena: acabas de encontrar el fallo invisible de la Fase 7
> **Esta es exactamente la prueba que quedó pendiente allí.** El apartado 8.a de la Fase 7 te pidió que anotaras dos comprobaciones para hacer hoy, porque **desde el servidor no había forma de verificar esto**.
>
> Si has llegado aquí y el fallo estaba, el material ha funcionado: lo has descubierto **haciendo la prueba que tocaba**, no por casualidad tres meses después.

> [!summary] Qué aprendes
> Que **denegar el acceso y ocultar la existencia son dos capas distintas**, y que la segunda solo se puede comprobar desde el lado del cliente.
>
> Y por qué importa: un usuario que ve una lista con `nominas`, `expedientes` o `direccion` **ya tiene información**, aunque no pueda abrir nada. Sabe qué hay, dónde está y a quién pedírselo. Buena parte del reconocimiento en un ataque interno es exactamente eso: mirar qué carpetas existen.

---

### E7 · El usuario entra pero no puede escribir

> [!bug] Síntoma
> `masao.sato` inicia sesión, ve `facturacion`, entra… y al crear un fichero: *"Acceso denegado"*.

**Hipótesis.** Tres candidatas, **todas del servidor**:
1. La **máscara** de la ACL está recortando el permiso.
2. `masao.sato` ya no pertenece al grupo `comercial`.
3. Los **UID** de la Fase 5 no son los que deberían.

**Comprobación.** En el **servidor**:
```bash
getfacl -p /srv/samba/departamentos/facturacion
id -nG masao.sato
id masao.sato
```

| Qué encuentras | Dónde está el fallo |
| :--- | :--- |
| `#effective:r--` en la línea del grupo | Fase 7 → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica\|caso E6]] |
| `masao.sato` no sale en `comercial` | Fase 5 → [[Fase_5.7_Resolucion_Problemas#E6 · El usuario no está en su grupo\|caso E6]] |
| `id masao.sato` da un UID que no es `10005` | Fase 5 → [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los del escenario\|caso E7]] |

> [!summary] Qué aprendes
> Que **el cliente casi nunca es el culpable.** Windows te está informando fielmente de lo que el servidor le deja hacer.
>
> Y el orden de diagnóstico que vale para cualquier problema de permisos en red: **primero quién eres** *(identidad)*, **luego a qué perteneces** *(grupos)*, **luego qué permite el recurso** *(ACL)*. En ese orden, y casi siempre el fallo está en los dos primeros.

---

### E8 · Puedo iniciar sesión con el servidor apagado

> [!bug] Síntoma
> Apagas el servidor, inicias sesión en el cliente con `BOOCHANLAB\masao.sato`… **y entra**. ¿No debería fallar?

**Hipótesis.** Ninguna: **es el comportamiento correcto.** Windows guarda unas **credenciales en caché** de los últimos usuarios que entraron, para que un portátil fuera de la oficina siga siendo utilizable.

**Comprobación.** Con el servidor apagado, entra y prueba a usar los recursos:
```cmd
net use W: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial
```
- **Entrar en Windows:** funciona *(caché)*.
- **Acceder a las carpetas del servidor:** falla. No hay servidor.

**Arreglo.** No hay nada que arreglar. Enciende el servidor.

> [!info] 🎓 Lo que sí falla sin servidor
> Cambiar la contraseña, aplicar directivas nuevas, acceder a recursos de red, y **el primer inicio de sesión de un usuario que nunca ha entrado en ese equipo** — ese no está en la caché y no puede entrar.

> [!summary] Qué aprendes
> Que **la caché de credenciales es una decisión de diseño, no un agujero**: sin ella, un portátil sin conexión sería un ladrillo.
>
> Y que en seguridad casi todo es un equilibrio entre **comodidad y control**. Aquí se ha elegido comodidad, a cambio de que un equipo robado siga aceptando la contraseña de su último usuario durante un tiempo. Saber que existe ese equilibrio —y en qué dirección lo ha resuelto cada sistema— es parte del oficio.

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. **Pasa el verificador** en el cliente: `.\verificar_fase8.ps1`.
> 2. **Comprueba el servidor**, que es donde suele estar el problema: `sudo ./verificar_fase7.sh` y `sudo ./verificar_fase4.sh`.
> 3. **Anota el mensaje literal** en tu entrada de apuntes, aunque lo resuelvas.

---

### E9 · La VM de Windows se cuelga y VirtualBox muestra una tortuga

> [!danger] 🛑 Esto NO es un problema de la Fase 8. Es del ordenador anfitrión
> Y es de los caros: aparece **en la última fase**, después de semanas de trabajo, porque las Fases 1-7 no lo destapan.

**Síntoma.** La instalación de Windows 11 se queda parada, o la VM entra en bucle de reinicio. **El disco no hace nada** — no está trabajando lenta: está muerta. En la barra de estado de VirtualBox hay un **icono de tortuga 🐢** y, al pasar el ratón, dice **«ejecución nativa API»** *(«native API execution»)*.

**Qué significa.** VirtualBox **no está usando VT-x**, la virtualización por hardware del procesador. Está corriendo **encima del hipervisor de Windows**, en un modo mucho más lento.

**Por qué no lo viste antes.** Un Ubuntu Server sin escritorio aguanta esa capa razonablemente. **Windows 11 con escritorio, no.**

**Quién te ha quitado el VT-x.** Windows, para **VBS** *(Virtualization-Based Security)*. Solo puede haber un hipervisor mandando, y si Windows lo arranca primero, VirtualBox se queda con las sobras.

---

**Paso 1 — Confírmalo.** `Windows + R` → `msinfo32` → busca **«Seguridad basada en virtualización»**:

- **`No habilitada`** → el problema es otro. La tortuga no es esto.
- **`En ejecución`** → es esto. Sigue.

**Paso 2 — Apaga lo que la enciende.** Todo desde una ventana **elevada**, y **PowerShell como administrador**:

```powershell
bcdedit /set hypervisorlaunchtype off
```

> [!danger] 🛑 La trampa que cuesta media tarde
> **En una ventana NO elevada, este comando falla sin decírtelo de forma clara.** No aplica nada, y la línea `hypervisorlaunchtype` **ni siquiera aparece** al comprobarlo. Se da por hecho que está puesto, y no lo está.
>
> **Ábrela como administrador.** Debe responder `The operation completed successfully.`

**Paso 3 — Quita las características de Windows** que arrancan un hipervisor. `Windows + R` → `OptionalFeatures` → desmarca, si están:

`Hyper-V` · `Plataforma de máquina virtual` · `Plataforma del hipervisor de Windows` · `Subsistema de Windows para Linux` · `Espacio aislado de Windows`

**Paso 4 — Integridad de memoria fuera.** `Seguridad de Windows → Seguridad del dispositivo → Aislamiento del núcleo → Integridad de memoria` → **Desactivada**.

**Paso 5 — 🔴 REINICIA.** Nada de lo anterior surte efecto sin reiniciar. **Es el fallo más tonto y el más frecuente:** se aplica todo, no se reinicia, se comprueba y sigue igual.

**Paso 6 — Comprueba, en este orden:**

```powershell
bcdedit /enum '{current}'
```

> 💡 **Las comillas no son opcionales en PowerShell.** Sin ellas interpreta `{current}` como un bloque de código y no funciona.

- Debe aparecer **`hypervisorlaunchtype    Off`**.
- `msinfo32` → **«Seguridad basada en virtualización: No habilitada»**.
- Y arranca `UbuntuServer`: **la tortuga tiene que haber desaparecido**.

---

> [!warning] ⚠️ Si VBS SIGUE «En ejecución» con todo lo anterior hecho y reiniciado
> Mira en `msinfo32` la línea **«Directiva de App Control for Business»**. Si pone **`Enforced`**, hay una directiva de control de aplicaciones que está manteniendo VBS encendido, y **no se quita con los pasos de arriba**.
>
> **No te rindas todavía.** Hay un diagnóstico más profundo que cubre el 20 % de casos que el E9 no alcanza: `dism` para quitar componentes que OptionalFeatures no ve, `citool` para leer las políticas que fuerzan VBS, y —lo más importante— **cuándo puedes ignorar la tortuga** si la VM ya funciona.
>
> 👉 [[Fase_8.7.E9x_Diagnostico_VBS_Avanzado|E9 bis · Diagnóstico avanzado de VBS]]
>
> ⚠️ *El 11/08/2026 se completó el diagnóstico en un equipo real (Huawei MateBook, Windows 11 Pro). Tras los pasos del E9 bis, `msinfo32` seguía en `Running` pero la VM **arrancó y funciona**. La tortuga no desapareció; el hipervisor sí aflojó.*

> [!danger] 💀 Y si ya se te colgó tres veces: **borra la VM y empieza de nuevo**
> Una instalación de Windows interrumpida a la fuerza **queda corrupta**, y arrastrarás fallos raros toda la fase creyendo que es el dominio.
>
> Bórrala, rehazla con el VT-x ya funcionando, y **haz una instantánea `Windows11 limpio` nada más terminar la instalación**, antes de tocar el dominio.


---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.6_Procedimiento]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.8.a_Verificacion]] |
