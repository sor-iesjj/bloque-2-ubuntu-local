## Fase 1 · Apartado 6.e — 🌐 Procedimiento — Acceso desde otro equipo de la red *(opcional)*

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1_Infraestructura_Virtual_Local]]
>
> **📍 Cuándo se lee:** **Solo si lo necesitas.** Cuando el ordenador desde el que quieres administrar el servidor **no es** el que ejecuta VirtualBox: ~20 min

---

> [!warning] 🚦 Esto es OPCIONAL. Lee esto antes de decidir si te hace falta
> **En el aula no lo necesitas.** Tu VM corre en el mismo PC desde el que trabajas, y `ssh boochan@10.10.10.10` te responde directamente, como acabas de comprobar en la [[Fase_1.6.d_Procedimiento_Verificacion_SSH]]. Si es tu caso, **sáltate esta parte y ve al apartado 7**.
>
> Esta parte es para dos situaciones concretas, las dos muy reales:
>
> | Situación | Ejemplo |
> | :--- | :--- |
> | El servidor vive en **otra máquina** de tu red | Lo tienes en el sobremesa de casa y quieres entrar desde el portátil |
> | Administras **desde otro sistema operativo** | El servidor está en un Windows y tú trabajas desde un Mac o un Linux |
>
> **No es una entrega aparte.** Si la haces, la documentas dentro de la entrada de la 1.4 y la enseñas en el mismo vídeo.

---

### 🧠 Por qué `ssh boochan@10.10.10.10` NO va a funcionar desde otro equipo

Esto no es un fallo tuyo ni una configuración que falte. Es la definición misma de la red que montaste en la 1.2:

> [!danger] La red sólo-anfitrión vive DENTRO del anfitrión
> `10.10.10.0/24` es una red virtual que **existe únicamente dentro del ordenador que ejecuta VirtualBox**. No sale por el cable, no sale por el Wi-Fi, el router no la conoce y ningún otro equipo la ve.
>
> Desde otra máquina, `10.10.10.10` **nunca** será alcanzable. Da igual que estéis en el mismo Wi-Fi, que apagues los cortafuegos o que el SSH esté perfecto. **No hay ruta.**
>
> Y aquí está la trampa de diagnóstico: el error que ves (`Connection timed out`) es **el mismo** que verías si el servidor estuviera apagado. Si no entiendes la causa, te puedes pasar una hora revisando el servidor cuando el servidor no tiene ningún problema.

Entonces, ¿por dónde entramos? Por el **otro** adaptador: el NAT.

Pero el NAT es **unidireccional**. Tu VM sale a Internet disfrazada de tu anfitrión (lo comprobaste con `ipify` en la 1.4: los dos daban la misma IP pública), y por eso mismo **nadie puede entrar desde fuera**. No hay ninguna dirección que apunte a tu VM.

La solución es un **reenvío de puertos** (*Port Forwarding*): abrir a mano un agujero en el NAT.

> [!info] 🏢 La analogía: la centralita de la empresa
> El NAT es la centralita. Desde dentro, cualquier empleado puede llamar a la calle sin problema. Pero desde la calle solo hay **un número**, el de la empresa, y no existe forma de marcar la extensión de un despacho concreto.
>
> El reenvío de puertos es decirle a la centralista: *"todas las llamadas que entren por la extensión **2222**, pásalas al despacho 22"*.
>
> Un número público, una regla escrita a mano, un destino interno. Eso es todo.

**Por qué 2222 y no 22:** el puerto 22 del anfitrión puede estar ya ocupado por su propio servicio SSH (en Mac y Linux es habitual). Se elige uno libre y alto para no chocar. El `2222` es convención, no obligación.

---

> [!example] Paso 1: Averigua la IP real del anfitrión en tu red
> Es la IP del **ordenador que ejecuta VirtualBox**, en la red de tu casa o del centro. No la de la VM.
>
> - **Windows:** `Windows + R` → `cmd` → `ipconfig`
>   Busca tu adaptador (Wi-Fi o Ethernet) y la línea `Dirección IPv4`. Algo tipo `192.168.1.45`.
> - **Mac / Linux:** `ip a` o `ifconfig`
>
> > [!warning] ⚠️ Esa IP es de DHCP y CAMBIA
> > Al reiniciar el router, o al cambiar de red, te asignarán otra. Si mañana esto deja de funcionar, **antes de dar nada por roto, vuelve a mirar `ipconfig`**. Es la causa nº1.
> >
> > La solución de verdad es reservar la IP por DHCP en el router o ponerla fija — pero eso no siempre lo controlas tú, y en el centro desde luego no.
>
> **Anótala.** La llamaremos `IP_ANFITRION` en el resto del documento.

> [!example] Paso 2: La regla de reenvío en VirtualBox
> Con la VM **apagada** (o encendida, da igual, pero apagada es más limpio):
>
> 1. Selecciona la VM → **`Configuración`** → **`Red`** → pestaña **`Adaptador 1`** (el NAT, **no** el sólo-anfitrión).
> 2. Despliega **`Avanzadas`** → botón **`Reenvío de puertos`**.
> 3. Pulsa el **`+`** de la derecha y rellena la fila:
>
> | Nombre | Protocolo | IP anfitrión | Puerto anfitrión | IP invitado | Puerto invitado |
> | :--- | :--- | :--- | :--- | :--- | :--- |
> | `SSH` | `TCP` | *(vacío)* | `2222` | *(vacío)* | `22` |
>
> > [!danger] ⚠️ Las dos columnas de IP se dejan VACÍAS. Es el error nº1 de este paso
> > Mucha documentación te dice que pongas `127.0.0.1` en **IP anfitrión**. Si lo haces, VirtualBox solo escucha en la interfaz de bucle local y **el reenvío funcionará únicamente desde el propio anfitrión** — justo lo contrario de lo que quieres. Desde otra máquina no entrará nadie, y el síntoma vuelve a ser un `timed out` mudo.
> >
> > Dejándola vacía, VirtualBox escucha en **todas** las interfaces del anfitrión, incluida la Wi-Fi.
>
> > [!bug] ⚠️ Hay que pulsar `Aceptar` en LAS DOS ventanas
> > Primero en la ventana de **`Reenvío de puertos`**, y después otra vez en la de **`Configuración`**.
> >
> > Si cierras la ventana interior con la **X**, o si aceptas esa pero cierras la de Configuración con la X, **la regla se descarta sin avisar de nada**. Vuelves, miras, y está vacío. Esto nos costó un buen rato la primera vez.
> >
> > **Compruébalo:** vuelve a entrar en `Configuración → Red → Avanzadas → Reenvío de puertos` y verifica que la regla sigue ahí.

> [!example] Paso 3: Abre el puerto en el cortafuegos del ANFITRIÓN
> VirtualBox ya escucha en el `2222`, pero el sistema operativo del anfitrión sigue bloqueando la conexión entrante. Hay que autorizarla.
>
> > [!danger] 🛑 Esto se hace en el ANFITRIÓN. **Dentro del servidor no se toca nada**
> > Abajo hay **tres** variantes. **Ejecutas solo UNA: la del sistema operativo del ordenador que ejecuta VirtualBox.** Si tu anfitrión es Windows, la de PowerShell; si es Linux, la de `ufw`.
> >
> > **La línea de `ufw` NO va en el servidor Ubuntu.** Está ahí para quien tenga VirtualBox instalado sobre Linux. Ejecutarla dentro de la VM no rompe nada, pero no sirve de nada y te hace creer que hiciste algo que no hiciste.
> >
> > **¿Y por qué el servidor no necesita ninguna regla?** Porque en la Fase 1 su `ufw` todavía **no está activo**: acepta todo. El cortafuegos del servidor se levanta en la [[Auditoria_Final]] — y es ahí, no aquí, donde este acceso se te puede caer.
>
> **En Windows** — PowerShell **como administrador** (`Windows + X` → `Terminal (Administrador)`):
> ```powershell
> New-NetFirewallRule -DisplayName "SSH VM Boochan 2222" -Direction Inbound -Protocol TCP -LocalPort 2222 -Action Allow
> ```
>
> **En Linux** con `ufw`:
> ```bash
> sudo ufw allow 2222/tcp
> ```
>
> **En macOS** el cortafuegos suele permitir por aplicación: si pregunta si quieres dejar que `VirtualBox` acepte conexiones entrantes, di que sí.
>
> > [!note] 💡 Ponle un nombre descriptivo a la regla
> > `"SSH VM Boochan 2222"` y no `"regla1"`. Dentro de tres meses, cuando audites el cortafuegos, esa es la diferencia entre saber qué borras y borrar a ciegas. Y la Auditoría Final te va a pedir exactamente eso.

> [!example] Paso 4: Conecta desde el otro equipo
> Desde la terminal del **otro** ordenador (el Mac, el portátil, el que sea):
>
> ```bash
> ssh -p 2222 boochan@IP_ANFITRION
> ```
>
> Fíjate bien en lo que estás escribiendo, porque es lo que hay que entender:
> - La **IP es la del anfitrión**, no la del servidor. El servidor no tiene ninguna dirección visible desde aquí.
> - El **puerto es el 2222**, el de la centralita, no el 22.
> - El **usuario sí es `boochan`**, el del servidor. Porque quien acaba atendiendo la llamada es él.
>
> Si aparece `boochan@UbuntuServer:~$`, funciona. **Has entrado en una máquina que, desde donde estás, no tiene dirección.**
>
> > [!tip] 💡 Guárdatelo como alias y no vuelvas a escribirlo
> > En el equipo desde el que administras, edita `~/.ssh/config` y añade:
> > ```
> > Host boochan
> >     HostName 192.168.1.45
> >     Port 2222
> >     User boochan
> > ```
> > A partir de ahí, `ssh boochan` y dentro. Cuando cambie la IP del anfitrión, tocas **una línea** en vez de recordar el comando entero.

---

### 🚩 Cuando no funciona: diagnostica bien

> [!danger] 🛑 El `ping` NO sirve para diagnosticar esto. Te va a mentir
> Es tentador hacer `ping IP_ANFITRION` para ver "si llega". **No lo hagas**, o al menos no te creas el resultado:
>
> - **Windows descarta el ICMP entrante por defecto.** Un Windows perfectamente sano y accesible no responde al ping.
> - **macOS tampoco responde** si tiene el modo invisible del cortafuegos activo.
>
> Los dos pings pueden fallar con todo funcionando. Un ping fallido aquí **no demuestra absolutamente nada**, y perseguirlo te lleva a arreglar cosas que no están rotas.
>
> **La prueba buena es TCP**, preguntando por el puerto concreto:
> ```bash
> nc -vz IP_ANFITRION 2222
> ```
> `succeeded` significa que hay alguien escuchando y que llegas. Eso sí es información.

> [!warning] ⚠️ El puerto solo existe con la VM ENCENDIDA
> El reenvío lo hace el proceso de VirtualBox, no Windows. Con la VM apagada, **nadie escucha en el 2222** y un `netstat -an | findstr 2222` sale vacío.
>
> Eso es normal y no significa que la regla esté mal. Enciende la VM y vuelve a mirar.

| Síntoma | Causa más probable | Comprobación |
| :--- | :--- | :--- |
| `Connection timed out` | La regla no se guardó (X en vez de `Aceptar`), o el cortafuegos del anfitrión bloquea | Revisa la regla en VirtualBox; `nc -vz IP_ANFITRION 2222` |
| Funciona desde el anfitrión pero no desde fuera | Pusiste `127.0.0.1` en **IP anfitrión** | Vacía esa columna |
| Funcionaba ayer y hoy no | La IP del anfitrión cambió por DHCP | `ipconfig` en el anfitrión |
| `Connection refused` | Llegas al anfitrión, pero la VM está apagada o `ssh` no corre en ella | Enciende la VM; `systemctl status ssh` dentro |
| `Permission denied` | Llegas bien. Es la contraseña o el usuario | Nada de red: revisa credenciales |

> [!success] 🎓 Fíjate en lo que acabas de aprender a leer
> `refused` y `timed out` **no son lo mismo**, y esa diferencia es oro puro diagnosticando:
> - **`timed out`** = nadie contestó. El paquete se perdió por el camino: no hay ruta, o un cortafuegos lo tiró en silencio.
> - **`refused`** = alguien contestó, y contestó que no. Llegaste al destino, pero ahí no hay ningún servicio escuchando en ese puerto.
>
> Uno es un problema de camino. El otro, de destino. Nunca los confundas.

---

### 🔒 Lo importante: esto que acabas de abrir es un agujero

> [!danger] ⚠️ Acabas de exponer tu servidor a toda la red
> Con esa regla, **cualquier equipo del Wi-Fi** —tu casa, o el aula entera— puede intentar entrar a tu servidor. Y lo hará contra un usuario `boochan` con una contraseña que también conocen tus compañeros.
>
> No lo digo para asustar: lo digo porque **es exactamente el tipo de regla que la [[Auditoria_Final]] te va a pedir que encuentres y justifiques**. Se llama *"puerta trasera de comodidad"* y es una de las causas más comunes de intrusión real en empresas: alguien la abrió para trabajar más cómodo, funcionó, y nadie la volvió a mirar en cuatro años.
>
> **Tres reglas si la mantienes:**
> 1. **Anótala en tu entrada de apuntes.** Lo que no está escrito, no se audita.
> 2. **Bórrala en cuanto no la necesites** — la regla de VirtualBox *y* la del cortafuegos del anfitrión. Las dos.
> 3. **Nunca la dejes puesta en un equipo del centro** al terminar la clase.

> [!info] 🔑 Hazlo mejor: pasa a clave pública
> Ya sabes hacerlo — lo hiciste con GitHub en el **Bloque 0 · Fase 0.2.2 — Autenticación SSH**. Desde el equipo que administra:
> ```bash
> ssh-copy-id -p 2222 boochan@IP_ANFITRION
> ```
> A partir de ahí entras sin contraseña, y una contraseña que no se teclea es una contraseña que no se puede adivinar por fuerza bruta.
>
> En la **Fase 3** montarás la solución de verdad para este problema: un túnel **WireGuard**, que da acceso remoto **sin** dejar ningún puerto abierto a la red. Este reenvío es la versión cómoda y peligrosa; WireGuard es la profesional. Tener las dos en la cabeza es lo que te permite explicar por qué una es mejor.

---

### ✅ Checklist de esta parte *(solo si la has hecho)*

- [ ] `IP_ANFITRION` averiguada con `ipconfig` / `ip a` y **anotada en la entrada**.
- [ ] Regla de reenvío `2222 → 22` creada, **con las columnas de IP vacías**.
- [ ] `Aceptar` pulsado en **las dos** ventanas, y la regla verificada volviendo a entrar.
- [ ] Puerto `2222` permitido en el cortafuegos **del anfitrión** (una sola variante, la de su SO), con nombre descriptivo.
- [ ] `ssh -p 2222 boochan@IP_ANFITRION` conecta desde el otro equipo.
- [ ] Explicado **en el vídeo** por qué la IP es la del anfitrión y no la del servidor.
- [ ] La regla **anotada como pendiente de revisar** en la Auditoría Final.

> [!question] Lo que va a tu entrada de apuntes
> 1. ¿Por qué `ssh boochan@10.10.10.10` no puede funcionar desde otro equipo de la red, por muy bien configurado que esté todo?
> 2. En `ssh -p 2222 boochan@IP_ANFITRION` conviven **dos máquinas distintas**. ¿Qué parte del comando corresponde a cada una?
> 3. ¿Qué diferencia hay entre `Connection refused` y `Connection timed out`? ¿Qué te dice cada uno sobre dónde está el problema?
> 4. Esta regla es un riesgo. Descríbelo con tus palabras y di cuándo la vas a borrar.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] | [[Fase_1_Infraestructura_Virtual_Local]] | [[Fase_1.7_Resolucion_Problemas]] |
