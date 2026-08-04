## Fase 1 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma. No hace falta leerlo antes.

---

> [!warning] 📖 Cómo se usa este apartado
> **Búscate por el síntoma**, arregla, y **cuenta el incidente en la entrada de la parte donde te ocurrió**: qué viste, qué pensaste que era, qué resultó ser y cómo lo resolviste.
>
> Todos los casos de aquí **han pasado de verdad**, montando esta práctica en un equipo real. No son problemas imaginados por si acaso.

> [!important] 🎓 Por qué existe este catálogo, y por qué no está todo en la fase
> Podría haber llenado la Fase 1 de avisos para que nada de esto te pasara. **No lo he hecho a propósito.**
>
> Un administrador de sistemas se pasa la vida delante de máquinas que hacen algo raro sin explicar por qué. Lo que se te evalúa no es que no cometas errores — es que, cuando aparezcan, **no entres en pánico y sepas buscar**.
>
> Fíjate en que todos los casos siguen la misma estructura, y esa estructura es la asignatura entera:
>
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> Cuando te encuentres un problema que no esté en esta lista —y te pasará— aplícale esa misma cadena.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Ve a |
| :--- | :--- |
| La VM se instaló sola, no elegí nada | [[#E1 · La VM se instaló sola y nunca vi el instalador\|E1]] |
| No me salen la `@` ni el `;` | [[#E2 · No me sale la arroba ni el punto y coma\|E2]] |
| La instalación lleva más de 40 minutos | [[#E3 · La instalación lleva más de 40 minutos\|E3]] |
| El instalador solo me muestra una tarjeta de red | [[#E4 · El instalador solo me muestra una tarjeta de red\|E4]] |
| Mi servidor no tiene la IP `10.10.10.10` | [[#E5 · Mi servidor no tiene la IP 10.10.10.10\|E5]] |
| El `ping 10.10.10.10` no responde desde mi ordenador | [[#E6 · El ping a 10.10.10.10 no responde desde mi ordenador\|E6]] |
| `ssh` dice `Connection timed out` o `refused` | [[#E7 · SSH dice Connection timed out o Connection refused\|E7]] |
| Sale un error `vmwgfx` al arrancar | [[#E8 · Sale un error vmwgfx al arrancar\|E8]] |
| La letra de la consola es minúscula (pantalla 4K) | [[#E9 · La letra de la consola es minúscula en pantallas 4K\|E9]] |
| Quiero ver qué hace el instalador por dentro | [[#E10 · Quiero ver qué hace el instalador por dentro\|E10]] |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` | [[#E11 · Aviso REMOTE HOST IDENTIFICATION HAS CHANGED\|E11]] |
| Mi servidor no se llama `UbuntuServer` | [[#E12 · Mi servidor no se llama UbuntuServer\|E12]] |
| Cosas raras sin error claro: entro y no es la máquina que creía | [[#E13 · Entro y no es la máquina que creía\|E13]] |

---

### E1 · La VM se instaló sola y nunca vi el instalador

> [!bug] Síntoma
> La máquina arrancó, estuvo un rato sola y apareció un `login:`. No elegiste teclado, ni red, ni usuario. Y el usuario **no es** `boochan`.

**Hipótesis.** No marcaste `Omitir instalación desatendida` en la [[Fase_1.6.a_Procedimiento_Maquina_Virtual]], así que VirtualBox instaló Ubuntu por su cuenta con sus propios valores.

**Comprobación.** Intenta entrar con `boochan` / `P@ssw0rd`. Si te rechaza, está confirmado.

**Arreglo.** No intentes salvarlo desde dentro: la red quedó en DHCP, el hostname no es el que toca y falta OpenSSH. Son más cosas mal que bien.

Clic derecho sobre la VM → **`Eliminar`** → **`Borrar todos los archivos`**. Y repite desde la [[Fase_1.6.a_Procedimiento_Maquina_Virtual]] **marcando la casilla**. Quince minutos, no una tarde.

> [!summary] Qué aprendes
> Que un solo *checkbox* sin marcar puede generar cuatro problemas distintos, que aparecen **por separado y mucho después**, cuando ya no los relacionas con su causa. Cuando algo automatiza decisiones que deberías tomar tú, no te está ahorrando trabajo: te lo está aplazando.

---

### E2 · No me sale la arroba ni el punto y coma

> [!bug] Síntoma
> Intentas escribir `@` con `AltGr+2` y sale otra cosa. El `;` no está donde siempre. **Las letras y los números funcionan perfectamente.**

**Hipótesis.** La distribución de teclado quedó en **inglés (US)**. Letras y números coinciden en ambas distribuciones; **los símbolos, no**.

**Comprobación.** Escribe `@` con `Shift+2`. Si ahí sí sale la arroba, confirmado.

> [!info] Lo importante: el teclado no se ha roto
> Un teclado **no envía letras: envía números de tecla**, y el sistema operativo decide qué carácter significa cada número. No ha cambiado tu hardware, ha cambiado el mapa.

**Arreglo, en dos tiempos.**

**1️⃣ Escribir ya, sin arreglar nada.** Necesitas `sudo`, y `sudo` pide `P@ssw0rd`, que lleva arroba. Con el mapa inglés activo, tu teclado físico español da esto:

| Quieres | Pulsa |
| :--- | :--- |
| **`@`** | **`Shift` + `2`** |
| **`;`** | **la tecla `Ñ`** |
| `:` | `Shift` + `Ñ` |
| `-` | la tecla `'` *(derecha del `0`)* |
| `/` | la tecla `-` *(izquierda de la `Shift` derecha)* |
| `'` | la tecla `´` *(derecha de la `Ñ`)* |
| `=` | la tecla `¡` |

Así que **`P@ssw0rd` se teclea:** `P` · `Shift+2` · `s` · `s` · `w` · `0` (cero) · `r` · `d`.

¿Ves el patrón? Los símbolos están **desplazados hacia la derecha**. Es el mapa americano puesto encima de tus teclas.

**2️⃣ Arreglarlo de verdad.**

```bash
sudo dpkg-reconfigure keyboard-configuration
```

| Pregunta | Respuesta | Por qué |
| :--- | :--- | :--- |
| **Modelo** | `Generic 105-key PC (intl.)` | Los teclados europeos tienen **105** teclas; los americanos 104. La de más es la de `< >` a la izquierda de tu `Shift` izquierda — cuéntala si dudas |
| **País de origen** | `Spanish` | — |
| **Distribución** | `Spanish` | La primera, la que **no** lleva paréntesis (`Dvorak`, `Asturian`, `Catalan` son variantes) |
| **Tecla AltGr** | `The default for the keyboard layout` | — |
| **Tecla Compose** | `No compose key` | — |

Flechas para moverte, `Enter` para confirmar, `Tab` para saltar entre botones. Y para aplicarlo **sin reiniciar**:

```bash
sudo setupcon
```

Comprueba con `AltGr+2`.

> [!tip] 💡 Si el asistente se resiste
> Todo lo que hace es escribir un fichero. Puedes editarlo tú:
> ```bash
> sudo nano /etc/default/keyboard
> ```
> Deja `XKBLAYOUT="es"` y `XKBMODEL="pc105"`, guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y ejecuta `sudo setupcon`. Mismo resultado, y ver el fichero enseña más que el menú.

> [!question] ¿Y si directamente no puedo entrar? (`Login incorrect`)
> - **Si el teclado estuvo en inglés durante TODA la instalación y sigue en inglés**, no hay problema: escribiste la contraseña a ciegas con el mapa inglés y ahora la escribes igual. Coincide. Entras.
> - **El problema aparece cuando el mapa CAMBIA** entre crearla y escribirla. Ahí la contraseña guardada no es la que crees.
>
> Prueba a teclearla con **el otro mapa** en la cabeza, usando la tabla de arriba. Si no hay manera, borra la VM y repite desde la 1.1.

> [!summary] Qué aprendes
> Que el síntoma ("no funciona el teclado") casi nunca describe la causa. Y que fijarte en **qué funciona** —las letras sí, los símbolos no— es lo que te lleva al diagnóstico correcto.

---

### E3 · La instalación lleva más de 40 minutos

> [!bug] Síntoma
> El instalador sigue trabajando mucho después de lo razonable. Entre 15 y 30 minutos es normal; más de 40, no.

**Hipótesis.** Casi siempre está en `Downloading and installing security updates`, bajando parches del mirror de Ubuntu por la tarjeta NAT. Con red lenta o filtrada, se eterniza.

**Comprobación.** Mira la línea de estado, abajo del todo. Y si hay un enlace tipo `View full log`, ábrelo: si ves reintentos contra `archive.ubuntu.com` o `security.ubuntu.com`, es red.

> [!tip] Interpretar el log
> Una línea que empieza por **`finish:`** significa que esa tarea **terminó bien**. No es ahí donde está atascado. Busca la última línea que empiece por `start:` sin su `finish:` correspondiente.

**Arreglo.** Pulsa **`Cancel update and reboot`**. Sin miedo: el sistema queda instalado y perfectamente usable. Los parches se aplican en la **Fase 2** con `apt upgrade`, que es donde tocan.

> [!summary] Qué aprendes
> Que "está tardando" y "está colgado" son cosas distintas, y que el log te lo dice si sabes leerlo. Y que a veces la decisión correcta es **cancelar una tarea opcional** para desbloquear el trabajo, en vez de esperar indefinidamente.

---

### E4 · El instalador solo me muestra una tarjeta de red

> [!bug] Síntoma
> En la pantalla de red del instalador aparece solo `enp0s3`. No hay ni rastro de `enp0s8`.

**Hipótesis.** El Adaptador 2 no llegó a la máquina: o no se habilitó antes del primer arranque, o tiene el cable "desconectado".

**Comprobación.** Es directa: **si solo ves una tarjeta, es esto.**

**Arreglo.** **No sigas con la instalación.** Aborta, apaga la VM y vuelve a la [[Fase_1.6.b_Procedimiento_Red_Laboratorio]]:
1. `Configuración → Red → Adaptador 2` → ¿está marcado `Habilitar adaptador de red`?
2. ¿`Conectado a` dice `Adaptador sólo-anfitrión`?
3. ¿`Nombre` apunta a la red del `10.10.10.1`?
4. En `Avanzadas`, ¿está marcado **`Cable conectado`**?

Luego reinstala. Si ya habías terminado la instalación, no hace falta reinstalar: ve a [[#E5 · Mi servidor no tiene la IP 10.10.10.10|E5]].

> [!summary] Qué aprendes
> Que continuar cuando algo no cuadra sale carísimo. Aquí la instalación **habría terminado bien**, el sistema **habría arrancado bien**, y el fallo no habría aparecido hasta la Fase 4. Parar dos minutos cuando la realidad no coincide con el manual es la costumbre más rentable del oficio.

---

### E5 · Mi servidor no tiene la IP 10.10.10.10

> [!bug] Síntoma
> `ip a` muestra `lo` y `enp0s3`, pero no `enp0s8`. O muestra `enp0s8` sin dirección.

**Hipótesis.** El instalador no vio la segunda tarjeta y no escribió su configuración.

**Comprobación.**
```bash
ip a show enp0s8
```
- `Device does not exist` → la tarjeta no llega a la máquina. Ve a [[#E4 · El instalador solo me muestra una tarjeta de red|E4]] primero.
- Existe pero sin `inet 10.10.10.10` → falta la configuración. Sigue aquí.

**Arreglo — configurar netplan a mano.** Primero mira qué ficheros hay:

```bash
ls /etc/netplan/
```

Puede haber `00-installer-config.yaml`, `50-cloud-init.yaml`, o ambos. **Netplan los mezcla y gana el de número más alto.**

> [!warning] ⚠️ Edita **el fichero que te haya salido a ti**, no el del ejemplo
> El nombre depende de cómo instalaras. En instalaciones recientes de Ubuntu Server suele ser **`00-installer-config.yaml`**. Sustituye el nombre en el comando por el tuyo:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

**No borres lo que hay: AÑADE el bloque que falta.** Lo normal es que `enp0s3` ya esté configurada y `enp0s8` no aparezca. Debe quedar así —fíjate en que `enp0s8:` va alineado con `enp0s3:`, con **4 espacios**:

```yaml
network:
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: true
      match:
        macaddress: 08:00:27:XX:XX:XX
      set-name: enp0s3
    enp0s8:
      dhcp4: false
      addresses:
        - 10.10.10.10/24
  version: 2
```

> [!note] 📌 `enp0s8` no lleva `gateway` ni DNS, y es a propósito
> La salida a Internet la da la NAT por `enp0s3`. La sólo-anfitrión es una red aislada: solo necesita una dirección.
>
> Y **no toques el bloque de `enp0s3`** — ese `macaddress` es el de tu tarjeta. Si lo cambias o lo borras, te quedas sin Internet.

> [!danger] ⚠️ YAML no admite tabuladores
> **Solo espacios.** Si pulsas `Tab` en `nano`, mete un tabulador y netplan lo rechazará con un error de sintaxis. Usa la barra espaciadora.

Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y aplica:

```bash
sudo netplan apply
ip a
```

`enp0s8` debe mostrar ya `10.10.10.10`.

> [!summary] Qué aprendes
> Dónde vive de verdad la configuración de red en Ubuntu, y que lo que el instalador hace por ti se puede hacer a mano. Acabas de adelantar, con un motivo real, algo que la Fase 2 explica en frío.

---

### E6 · El ping a 10.10.10.10 no responde desde mi ordenador

> [!bug] Síntoma
> Desde el anfitrión, `ping 10.10.10.1` funciona pero `ping 10.10.10.10` no. Y desde la VM, `ping 10.10.10.1` da `0 received` con errores.

**Hipótesis (por orden de probabilidad).**
1. La VM está enchufada a **otra** red sólo-anfitrión distinta de la que tiene el `10.10.10.1`.
2. El cable del Adaptador 2 está "desconectado".
3. La máscara de la red está mal (`255.255.0.0` en vez de `255.255.255.0`).

**Comprobación 1 — el enlace.** En la VM:
```bash
ip link show enp0s8
```
- `<NO-CARRIER,...>` o `state DOWN` → **es el cable**. Ve al arreglo B.
- `state UP` → sigue con la comprobación 2.

**Comprobación 2 — ¿cuántas redes hay?** En el anfitrión:
```
ipconfig
```
*(en Mac/Linux: `ifconfig`)*

Busca **todos** los adaptadores virtuales y sus IPs. Si ves uno con `192.168.56.1` **y** otro con `10.10.10.1`, tienes dos redes sólo-anfitrión y la VM puede estar en la que no es.

> [!tip] 🔍 La pista que lo confirma
> Si el ping devuelve **`Reply from 10.10.10.1: Destination host unreachable`**, eso **no es un timeout**. Es tu propio ordenador diciendo: *"estoy en esa red, he preguntado quién es el `10.10.10.10`, y no contesta nadie"*. Traducción: **en ese segmento no hay ninguna VM.** Está en el otro.

**Arreglo A — red equivocada.** Con la VM apagada:
1. `Archivo → Herramientas → Administrador de red` → `Redes sólo-anfitrión`.
2. Localiza la que tiene **`10.10.10.1`** y apunta su nombre exacto.
3. `Configuración → Red → Adaptador 2 → Nombre` → elige **esa**.

**Arreglo B — cable desconectado.** `Configuración → Red → Adaptador 2 → Avanzadas` → marca **`Cable conectado`**.

**Arreglo C — máscara.** En el Administrador de red, `Propiedades` de esa red → pestaña `Adaptador` → **Máscara `255.255.255.0`** → `Aplicar`. Comprueba después con `ipconfig` que se guardó: es un campo que a veces revierte.

> [!summary] Qué aprendes
> A distinguir un fallo de **capa 3** (IP mal puesta) de uno de **capa 2** (no hay camino físico). Y la regla que resume esta sub-fase entera: **los nombres mienten, las direcciones no.** Cuando dos cosas se llaman parecido, identifícalas por lo que las hace únicas.

---

### E7 · SSH dice Connection timed out o Connection refused

> [!bug] Síntoma
> `ping 10.10.10.10` responde perfectamente, pero `ssh boochan@10.10.10.10` no conecta.

**Hipótesis.** No hay nadie escuchando en el puerto 22: OpenSSH no se instaló. El `ping` usa ICMP y SSH usa TCP/22 — que uno funcione no dice nada del otro.

**Comprobación.** En la VM, tres comandos:

```bash
systemctl status ssh
sudo ss -tlnp | grep :22
sudo ufw status
```

| Resultado | Significa |
| :--- | :--- |
| `Unit ssh.service could not be found` | **OpenSSH no está instalado.** La casilla del paso 9 de la 1.3 se quedó sin marcar |
| `active (running)` pero `ss` no devuelve nada | El servicio está arrancado pero no escucha |
| `ss` devuelve `0.0.0.0:22` | Está escuchando: el problema es filtrado, mira `ufw` |
| `ufw status` dice `active` | El cortafuegos bloquea. Ábrelo: `sudo ufw allow 22/tcp` |

**Arreglo (caso habitual).**
```bash
sudo apt update && sudo apt install -y openssh-server
```

Y comprueba que ya escucha:
```bash
sudo ss -tlnp | grep :22
```
Debe salir una línea con `0.0.0.0:22` y `sshd`. Vuelve a intentar el `ssh` desde tu ordenador.

> [!summary] Qué aprendes
> Que **alcanzar una máquina y usar un servicio son cosas distintas**. El `ping` te dice que hay camino; no te dice que haya nadie en casa. Y que `ss -tlnp` —qué puertos hay abiertos y qué proceso los tiene— es de los comandos que más vas a usar en tu vida.

---

### E8 · Sale un error vmwgfx al arrancar

> [!bug] Síntoma
> Al arrancar aparece algo como:
> ```
> [drm] ERROR vmwgfx seems to be running on an unsupported hypervisor
> [drm] ERROR This configuration is likely broken
> ```

**Hipótesis.** `vmwgfx` es el driver gráfico de **VMware**. Ubuntu lo carga porque detecta una tarjeta virtual parecida, se da cuenta a medias de que está en VirtualBox, protesta, y sigue adelante.

**Comprobación.** ¿Funciona todo lo demás? ¿Arranca, entras, hay red? Entonces está confirmado: **es ruido.**

**Arreglo (opcional).** En un servidor **sin escritorio gráfico no afecta a nada**: no usas 3D ni ventanas. Si quieres quitarlo, con la VM apagada:

**`Configuración` → `Pantalla` → `Controlador gráfico`** → cambia **`VMSVGA`** por **`VBoxVGA`**.

Si lo que molesta es que los mensajes pisen el `login:` mientras escribes:

```bash
sudo nano /etc/sysctl.d/99-consola-silenciosa.conf
```

Con esta línea dentro:
```
kernel.printk = 3 4 1 3
```

Guarda y reinicia. Solo verás en consola los mensajes graves; los demás se siguen registrando y los consultas con `dmesg` o `journalctl`. **No se pierde información: se deja de gritar.**

> [!summary] Qué aprendes
> Que **no todo lo que pone `ERROR` rompe algo**. Un arranque de Linux escupe decenas de mensajes de componentes que se quejan de cosas irrelevantes. Distinguir el error que rompe del error que solo habla es una habilidad, y se entrena.

---

### E9 · La letra de la consola es minúscula en pantallas 4K

> [!bug] Síntoma
> En un portátil de alta resolución, el texto de la consola es prácticamente ilegible.

**Arreglo, tres opciones de menos a más definitiva.**

**1. Instantáneo, sin tocar el servidor.** En la ventana de la VM: **`Ver` → `Factor de escala`** → súbelo a **200 %** o más. La VM sigue creyendo que tiene una consola de 80×25, pero se dibuja al doble.

**2. Permanente, dentro del servidor.**
```bash
sudo dpkg-reconfigure console-setup
```
| Pregunta | Respuesta |
| :--- | :--- |
| Codificación | `UTF-8` |
| Juego de caracteres | El que propone (`Latin1 and Latin5 — western Europe...`) |
| **Fuente** | **`TerminusBold`** |
| **Tamaño** | **`16x32`** *(el mayor; si es excesivo, `14x28` o `12x24`)* |

Y aplica sin reiniciar:
```bash
sudo setupcon
```

> [!info] Fíjate: es el mismo `setupcon` del teclado
> **`console-setup` gestiona teclado y fuente juntos.** Por eso el mismo comando aplica las dos cosas.

**3. La buena: SSH.** En cuanto tengas red, conéctate desde tu propia terminal ([[Fase_1.6.d_Procedimiento_Verificacion_SSH]], Paso 2). Tu fuente, tu tamaño, varias pestañas, copiar y pegar. La ventana de VirtualBox se queda para arrancar la VM y poco más.

> [!summary] Qué aprendes
> Que la consola de VirtualBox es una **pantalla de emergencia**, no un puesto de trabajo. Y que la solución a muchos problemas de comodidad no es pelearse con la herramienta, sino usar la herramienta adecuada.

---

### E10 · Quiero ver qué hace el instalador por dentro

> [!bug] Situación
> La instalación va rara y quieres una terminal para diagnosticar **sin abortar** el proceso.

**Arreglo.** El ISO de Ubuntu Server tiene una consola esperando en la TTY2. El problema es que `Ctrl+Alt+F2` se lo queda **tu** sistema operativo, no la VM. Hay que usar la **tecla Anfitrión** de VirtualBox:

> **Tecla Anfitrión + F2**

**¿Cuál es tu tecla Anfitrión?** Se muestra siempre en la **esquina inferior derecha de la ventana de la VM**. Por defecto: `⌘ izquierdo` en Mac, `Ctrl derecho` en Windows y Linux. En portátiles puede hacer falta añadir `Fn`.

Vuelves al instalador con **Anfitrión + F1**.

Una vez dentro:
```bash
ip a
ping -c2 8.8.8.8
ping -c2 archive.ubuntu.com
```

| Resultado | Diagnóstico |
| :--- | :--- |
| `enp0s3` sin IP | El DHCP de la NAT no responde: revisa el Adaptador 1 |
| `8.8.8.8` va, `archive.ubuntu.com` no | Es **DNS**, no conectividad |
| Ninguno funciona | Problema en la NAT o en la red del sitio |

> [!summary] Qué aprendes
> Que un instalador es un sistema Linux funcionando, con sus consolas y sus herramientas. Y que separar *"no hay red"* de *"no hay DNS"* con dos `ping` —uno a IP, otro a nombre— es el diagnóstico de red más rentable que existe.

---

### E11 · Aviso REMOTE HOST IDENTIFICATION HAS CHANGED

**Síntoma.** Al conectar por SSH a una máquina donde ya habías entrado antes, sale un aviso enorme hablando de *man-in-the-middle*, y **no te deja entrar**:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Offending ECDSA key in /home/tu_usuario/.ssh/known_hosts:6
Host key verification failed.
```

**Hipótesis.** La primera vez que entraste, tu cliente guardó la **huella** del servidor en `~/.ssh/known_hosts`. Ahora esa IP responde con una huella distinta y SSH se planta.

En este proyecto casi siempre es por una de estas tres, y **ninguna es un ataque**:

| Causa | Cuándo |
| :--- | :--- |
| **Reinstalaste el sistema** | Ubuntu genera claves de host nuevas en cada instalación |
| **Restauraste una instantánea** anterior a la instalación de OpenSSH | El servidor vuelve a tener otra identidad |
| **Hay otra máquina en esa IP** | Un clon encendido a la vez → ver [[#E13 · Entro y no es la máquina que creía\|E13]] |

> [!danger] ⚠️ No borres el aviso sin comprobar. Ese es el error de verdad
> Casi todo el mundo borra la línea y sigue. **Mal.** El aviso existe precisamente para detectar que alguien ha puesto **otra máquina** donde estaba la tuya.
>
> Lo correcto es **comparar huellas** antes de aceptar nada.

**Comprobación.** En el servidor, por la ventana de VirtualBox:

```bash
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Compara ese `SHA256:...` con el que te muestra el aviso.

- **Coinciden** → es tu servidor. Sigue al arreglo.
- **No coinciden** → estás conectando a otra máquina. **Para** y averigua a cuál ([[#E13 · Entro y no es la máquina que creía|E13]]).

**Arreglo.** Borra la entrada vieja **en el ordenador desde el que te conectas**:

```bash
ssh-keygen -R 10.10.10.10
```

Si conectas por un puerto distinto, la clave incluye el puerto y va entre corchetes:

```bash
ssh-keygen -R "[192.168.18.229]:2222"
```

Vuelve a conectar. Te pedirá aceptar la huella nueva: escribe `yes`.

> [!summary] Qué aprendes
> Que **la identidad de un servidor no es su IP ni su nombre: es su clave de host**. Por eso SSH puede detectar que la máquina detrás de una dirección ha cambiado, aunque la dirección sea la misma.
>
> Y que un aviso de seguridad se **verifica**, no se silencia. La diferencia entre un técnico y alguien que copia comandos está justo aquí.

---

### E12 · Mi servidor no se llama UbuntuServer

**Síntoma.** El prompt dice `boochan@UbuntuServer2`, `boochan@ubuntu` o cualquier otra cosa. O `hostname` no devuelve `UbuntuServer`.

**Hipótesis.** El nombre se escribió mal en el instalador, o instalaste una segunda vez y le pusiste otro para distinguirla.

> [!warning] ⚠️ No es cosmético. Rompe la Fase 4
> El dominio de Active Directory se construye sobre este nombre: el servidor se anunciará como `UbuntuServer.BOOCHANLAB.LOCAL`. Si el nombre no es el que espera el resto del material, los comandos de las fases siguientes no encajarán y el cliente Windows de la Fase 8 no lo encontrará.
>
> **Arréglalo ahora, no más adelante.** Cuanto más tarde, más cosas lo dan por bueno.

**Arreglo.** Dos ficheros, no uno:

```bash
sudo hostnamectl set-hostname UbuntuServer
sudo nano /etc/hosts
```

En `/etc/hosts`, busca la línea que empieza por `127.0.1.1` y deja el nombre correcto:

```
127.0.0.1   localhost
127.0.1.1   UbuntuServer
```

> [!bug] Si `nano` te abre un fichero vacío
> Escribiste la ruta **sin la barra inicial** (`etc/hosts` en vez de `/etc/hosts`), y `nano` está creando un fichero nuevo en tu carpeta personal.
>
> Sal con `Ctrl+X` y responde `N` a guardar. Repite el comando con `/etc/hosts`.

Cierra la sesión y vuelve a entrar (`exit` y reconecta). Verifica:

```bash
hostname
```

> [!note] 📌 Dos nombres distintos: el de VirtualBox y el de dentro
> El nombre de la VM en la lista de VirtualBox y el `hostname` del sistema **son cosas independientes**. Puedes tener una VM llamada `UbuntuServer2` cuyo sistema se llame `UbuntuServer`, y eso confunde muchísimo.
>
> Si quieres que coincidan, con la VM apagada:
> ```
> VBoxManage modifyvm "NombreViejo" --name "UbuntuServer"
> ```
> Solo cambia la etiqueta: no toca nada del sistema de dentro.

> [!summary] Qué aprendes
> Que un nombre mal puesto no da error: **da problemas más tarde y en otro sitio**. Y que en un sistema Linux la identidad se declara en más de un fichero, así que cambiarla en uno solo deja el sistema en desacuerdo consigo mismo.

---

### E13 · Entro y no es la máquina que creía

**Síntoma.** No hay un error concreto. Hay **incoherencias**:

- Arreglas algo, y al rato aparece sin arreglar
- `ssh boochan@10.10.10.10` entra, pero el `hostname` no es el que esperabas
- El `ping` a `10.10.10.10` responde aunque hayas apagado el servidor
- Salta el aviso de [[#E11 · Aviso REMOTE HOST IDENTIFICATION HAS CHANGED|E11]] sin que hayas reinstalado nada

**Hipótesis.** **Tienes dos máquinas virtuales encendidas a la vez con la misma IP.**

Pasa con una segunda instalación, con un clon del ejercicio [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar]], o con una VM de otra fase que dejaste corriendo.

> [!danger] ⚠️ Este es el fallo más caro de todos, porque NO da error
> Las dos máquinas responden a `10.10.10.10`. Cuando preguntas por esa IP, **contesta la que llegue antes**, y puede cambiar entre un intento y el siguiente.
>
> Puedes trabajar media hora en la máquina equivocada sin enterarte. Y lo peor: tomar una instantánea creyendo que guardas lo que has hecho.

**Comprobación.** En el anfitrión:

```
VBoxManage list runningvms
```

**Debe salir UNA sola línea.** Si salen dos, ya tienes el diagnóstico.

Para saber **cuál** te está respondiendo, pregunta por su dirección física:

```
ping 10.10.10.10
arp -a | findstr 10.10.10.10
```

Eso te da la **MAC** de quien contesta. Compárala con la de cada máquina:

```
VBoxManage showvminfo "NombreDeLaVM" | findstr /i "NIC 2"
```

**Arreglo.** Apaga todas menos una:

```
VBoxManage controlvm "LaQueSobra" acpipowerbutton
```

Y si necesitas de verdad tener dos a la vez, dale a la segunda una IP distinta (`10.10.10.11`) y otro `hostname` — es justo lo que se practica en [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar]].

> [!success] ✅ La costumbre que te ahorra esto para siempre
> **Antes de empezar a trabajar, siempre:**
> ```
> VBoxManage list runningvms
> ```
> Una línea. Tres segundos. Te ahorra tardes enteras.

> [!summary] Qué aprendes
> Que **identificar una máquina por su nombre o por su IP no basta**: los nombres se repiten y las direcciones se duplican. Lo único que no miente es la MAC.
>
> Y que un fallo sin mensaje de error es peor que uno con error. Cuando el sistema se comporta de forma incoherente en vez de fallar, lo primero no es arreglar: es **verificar que estás mirando lo que crees que miras**.

---

> [!summary] 🎓 Lo que se llevan estos trece casos
> Ninguno se arregla sabiendo el comando de memoria. Todos se arreglan **mirando qué funciona y qué no, y acotando**.
>
> - Las letras van pero los símbolos no → no es el teclado, es el mapa.
> - Hay ping pero no SSH → hay camino, pero no hay servicio.
> - Ping a IP sí, a nombre no → hay red, pero no hay DNS.
> - `Destination host unreachable` no es lo mismo que `Request timed out`.
>
> **Esa forma de pensar es el módulo entero.** Los comandos se buscan; el razonamiento, no.
>
> [!tip] 💾 La red de seguridad que evita la mitad de estos sustos
> Varios de los casos de arriba se resuelven en treinta segundos si tienes un **punto de control** de la fase anterior: restauras y repites, en vez de diagnosticar a ciegas sobre una máquina que ya no sabes en qué estado está. Ver **[[Fase_0.S_Instantaneas_Puntos_de_Control]]**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] | [[Fase_1]] | [[Fase_1.8_Punto_de_Control]] |
