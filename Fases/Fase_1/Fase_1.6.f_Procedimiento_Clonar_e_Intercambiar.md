## Fase 1 · Apartado 6.f — 👥 Procedimiento — Clonar e intercambiar con un compañero

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Lo último de la Fase 1**, con la instantánea `Fase 1 terminada` ya tomada. Es **una entrega**: ~10-12 min

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~50 min (se trabaja **por parejas**) |
> | **Entrada de apuntes** | `v1-fase-1-5-clonar-e-intercambiar.md` |
> | **Vídeo** | `V1 · Fase 1.5 — Clonar e Intercambiar` · ~10-12 min |
>
> **Requisito imprescindible:** tener la instantánea **`Fase 1 terminada`** ([[Fase_1.8_Punto_de_Control]]). Sin ella no se puede empezar.


> [!abstract] 📋 Qué se te evalúa aquí
> **`RA.06`** — *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras |
> | :--- | :--- | :--- |
> | `CE.06.g` | Se ha trabajado en grupo. | Pasos 3 y 4 — entregas tu clon a un compañero e importas el suyo |
>
> **Este criterio no se puede demostrar en solitario.** Es el motivo de que esta entrega sea por parejas y no una más de la lista. El detalle del resto de la fase: [[Fase_1.1_Que_Se_Evalua]].

---

### 🎯 Qué vas a hacer, y por qué no es un ejercicio de relleno

Vas a **empaquetar tu servidor y dárselo a un compañero**. Él te dará el suyo. Y los dos vais a acabar con **dos servidores funcionando a la vez en vuestro VirtualBox**: el vuestro y el del otro.

> [!info] 🏭 Esto se llama *imagen maestra* y es como se despliegan los servidores de verdad
> Ningún administrador instala cien máquinas a mano. Instala **una**, la deja perfecta, la convierte en plantilla y **clona**. Es lo que hace Azure con sus imágenes, lo que hace AWS con las AMI y lo que harás tú en el aula dentro de cinco minutos.
>
> El problema es que **clonar no es copiar**. Una máquina tiene cosas que deben ser **únicas** —identidad, direcciones, claves— y si las duplicas sin pensar, las dos copias se estorban entre sí. Descubrir *cuáles* son esas cosas es el objetivo real de este ejercicio.
>
> En el mundo Windows esto tiene nombre propio: **Sysprep**. Existe exactamente para esto.

> [!danger] 🤔 Antes de tocar nada: escribe tu predicción
> Enciende los dos servidores a la vez —el tuyo y el que te dé tu compañero— y pregúntate **antes de hacerlo**:
>
> **¿Qué va a pasar?** Los dos se llaman `UbuntuServer`. Los dos tienen la IP `10.10.10.10`. Los dos están en la misma red sólo-anfitrión.
>
> **Escribe tu respuesta en la entrada de apuntes ANTES de probarlo.** Acertar no puntúa. Haber predicho y contrastado, sí.

---

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Ponte de acuerdo con **un compañero**. Este ejercicio no se hace solo.
> 2. Decidid cómo os pasáis el fichero: **pendrive**, carpeta compartida del aula o Teams.
> 3. Crea vacía la entrada de apuntes y escribe ahí tu predicción.
> 4. Ten OBS listo.
>
> Cuando lo tengas: arranca la grabación y preséntate.

---

> [!example] Paso 1: Limpia la identidad ANTES de clonar
> Enciende tu VM y entra por SSH. Estos tres ficheros son los que **no deben viajar** en una plantilla:
>
> ```bash
> sudo rm -f /etc/ssh/ssh_host_*
> sudo truncate -s 0 /etc/machine-id
> sudo poweroff
> ```
>
> **Qué acabas de borrar, y por qué no es peligroso:**
>
> | Fichero | Qué es | Qué pasa al arrancar |
> | :--- | :--- | :--- |
> | `/etc/ssh/ssh_host_*` | La **identidad criptográfica** del servidor. La huella que tu cliente SSH memorizó la primera vez que dijiste `yes` | El servicio SSH genera unas nuevas, distintas, al arrancar |
> | `/etc/machine-id` | El identificador único de esa instalación de Linux | `systemd` lo regenera solo |
>
> > [!danger] ⚠️ Si NO lo haces, los dos servidores son la misma máquina para el mundo
> > Y no en sentido figurado: tienen **la misma clave privada de host**. Cualquiera que tenga el clon puede **suplantar a tu servidor** en la red y tu propio SSH no notaría nada raro, porque la huella cuadraría.
> >
> > Es un fallo real y famoso: fabricantes de routers que enviaron miles de equipos con la misma clave de host porque la metieron en la imagen de fábrica.
>
> > [!bug] 🚨 Antes de dar tu máquina a nadie, mira qué llevas dentro
> > Un clon se lleva **todo**: ficheros, historial de comandos, credenciales guardadas.
> >
> > En la Fase 1 no deberías tener nada personal en la VM —tus claves de GitHub viven en tu ordenador, no aquí—, pero **acostúmbrate a comprobarlo**, porque en la Fase 4 esto ya no será inocente:
> > ```bash
> > ls -la ~/.ssh/ 2>/dev/null
> > tail -20 ~/.bash_history
> > ```
> > Entregar una máquina sin mirar qué contiene es cómo se filtran las contraseñas en las empresas.

> [!example] Paso 2: Clona desde la instantánea
> Con la VM **apagada**, en VirtualBox:
>
> 1. Selecciona tu VM → pestaña **`Instantáneas`**.
> 2. **Clic derecho sobre `Fase 1 terminada`** → **`Clonar…`**
> 3. Nombre: **`Boochan-<TuNombre>-Fase1`** — por ejemplo `Boochan-Lucia-Fase1`.
> 4. **Política de MAC:** que genere **direcciones MAC nuevas para todos los adaptadores**.
> 5. Tipo de clon: **`Clon completo`**.
>
> > [!warning] ⚠️ Clic derecho sobre **la instantánea**, no sobre la máquina
> > Si lo haces sobre la VM en la lista principal, clonas el **estado actual**, no el punto guardado. Puede parecer lo mismo hoy y no serlo mañana.
>
> > [!danger] ⚠️ `Clon enlazado` NO sirve para esto
> > El clon enlazado **no copia el disco**: guarda solo las diferencias y depende del original. Ocupa poquísimo y va rapidísimo… y en cuanto sale del ordenador donde vive el original, **no arranca**.
> >
> > Sirve para hacerte pruebas rápidas a ti mismo. No para dar nada a nadie. El **clon completo** es autosuficiente.
>
> > [!question] 🔬 Compruébalo tú
> > Mira lo que ocupa la carpeta del clon y compárala con la de tu VM original. **Anota los dos números.** ¿Por qué el clon puede ser bastante más pequeño que el original si son la misma máquina?

> [!example] Paso 3: Empaquétalo y dáselo a tu compañero
> Dos formas. Las dos valen; elige según cómo lo vayáis a mover:
>
> **a) ZIP de la carpeta** — para pendrive o carpeta compartida del aula. Lo más rápido.
> Comprime la **carpeta entera** del clon (`VirtualBox VMs/Boochan-<Nombre>-Fase1/`).
>
> > [!danger] ⚠️ La CARPETA entera, nunca solo el `.vdi`
> > Es el error nº1 de este paso. El `.vdi` suelto no lleva la configuración de la máquina —RAM, adaptadores, orden de arranque— y, si hubiera instantáneas, ni siquiera lleva el estado que crees.
>
> **b) Exportar a `.ova`** — para colgarlo en Teams o mandarlo por la red.
> `Archivo` → **`Exportar servicio virtualizado`** → elige el clon → formato **OVF 2.0** → guarda el `.ova`.
>
> Un `.ova` es **un solo fichero**, comprimido, y al importarlo VirtualBox regenera identificadores solo. Tarda más en generarse, pero es lo que darías a alguien de fuera.
>
> > [!tip] 💡 Si pesa demasiado, quítale el aire antes
> > El disco arrastra como ocupado todo lo que borraste alguna vez. Dentro de la VM, **antes de apagarla**:
> > ```bash
> > sudo dd if=/dev/zero of=/CERO bs=1M status=progress; sudo rm -f /CERO; sudo sync
> > ```
> > Y luego, con la VM apagada, desde el `cmd`:
> > ```
> > VBoxManage modifymedium disk "ruta\al\clon.vdi" --compact
> > ```
> > Escribir ceros sobre el espacio libre suena absurdo, pero es justo lo que permite que la compresión lo reduzca. Suele quitar 1-2 GB. **Anota el tamaño antes y después.**

> [!example] Paso 4: Importa el de tu compañero
> Ya tienes el fichero del otro. En **tu** VirtualBox:
>
> - **Si es un ZIP:** descomprímelo en tu carpeta `VirtualBox VMs/` y luego `Máquina` → **`Añadir…`** → selecciona el fichero **`.vbox`** de dentro.
> - **Si es un `.ova`:** `Archivo` → **`Importar servicio virtualizado`** → selecciónalo → y **antes de darle a importar**, en las opciones marca que **regenere las direcciones MAC**.
>
> > [!bug] Si dice que ya existe un disco con ese UUID
> > Solo te pasará si intentas registrar **tu propio** clon en el mismo VirtualBox donde está el original: dos discos no pueden compartir identificador.
> >
> > Con el de tu compañero no ocurre. Y si te pasa con el tuyo, la vía limpia es importar el `.ova`, que asigna identificadores nuevos.
>
> **No lo enciendas todavía.** Antes, lee el paso 5.

> [!example] Paso 5: 💥 El choque — enciende las dos a la vez
> Arranca **primero la tuya** y después la de tu compañero. Con las dos encendidas, entra en cada una por la ventana de VirtualBox (**no por SSH todavía**) y ejecuta en las dos:
>
> ```bash
> hostname
> ip a | grep 10.10.10
> ```
>
> > [!danger] 🤯 Las dos dicen llamarse `UbuntuServer` y tener la IP `10.10.10.10`
> > Ese es el choque. Y ahora **compruébalo desde tu ordenador anfitrión**:
> > ```
> > ping 10.10.10.10
> > ssh boochan@10.10.10.10
> > ```
> > **¿A cuál de las dos has entrado?** No hay forma de saberlo desde fuera. Puede responderte una, la otra, o ir alternando.
> >
> > Y si antes ya habías entrado por SSH a `10.10.10.10`, es muy probable que te salte esto:
> > ```
> > @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> > @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
> > @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> > ```
> > **Ese aviso no es un error: es SSH haciendo su trabajo.** Está diciéndote que la máquina que hay en esa IP **no es la misma** que conociste. Exactamente lo que pasaría en un ataque de suplantación. Aquí lo has provocado tú, y por eso puedes entenderlo sin miedo.
>
> **Grábalo. Explícalo en voz alta.** Este momento es el ejercicio entero.

> [!example] Paso 6: Arréglalo — dale identidad propia al clon
> Deja **solo la máquina importada** encendida (apaga la tuya para no confundirte) y trabaja **desde la ventana de VirtualBox**, no por SSH.
>
> **a) Nombre nuevo:**
> ```bash
> sudo hostnamectl set-hostname UbuntuServer-Clon
> ```
>
> **b) IP nueva** — edita la configuración de red:
> ```bash
> sudo nano /etc/netplan/50-cloud-init.yaml
> ```
> Cambia **`10.10.10.10/24`** por **`10.10.10.11/24`** en el adaptador `enp0s8`. Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y aplica:
> ```bash
> sudo netplan apply
> ```
>
> > [!warning] ⚠️ En YAML se indenta con **espacios**, nunca con tabuladores
> > Si pulsas `Tab` en `nano`, netplan rechazará el fichero con un error de sintaxis. Respeta la sangría que ya hay.
>
> **c) Comprueba que la identidad SSH es distinta.** En cada una de las dos máquinas:
> ```bash
> sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
> ```
> Las huellas **deben ser diferentes**. Si son idénticas, alguien se saltó el Paso 1.

> [!example] Paso 7: Verificación final — las dos conviviendo
> Enciende **las dos** y, desde tu ordenador anfitrión:
>
> ```
> ping 10.10.10.10
> ping 10.10.10.11
> ssh boochan@10.10.10.10
> ssh boochan@10.10.10.11
> ```
>
> > [!success] ✅ Está bien hecho si…
> > - Las dos IP responden **a la vez**, sin interferirse.
> > - Entras por SSH a cada una y `hostname` te dice **cuál es cuál**.
> > - SSH te pide confirmar la huella de la nueva **una sola vez**, y no vuelve a protestar.
> >
> > Acabas de convertir dos máquinas idénticas en dos servidores independientes. Eso es lo que hace un administrador cada vez que despliega desde plantilla.

> [!warning] 🧹 Al terminar: apaga el clon
> **No sigas a la Fase 2 con la máquina de tu compañero encendida.** El resto del proyecto asume que `10.10.10.10` es tuya y única. Un clon corriendo de fondo te va a dar fallos rarísimos en la Fase 4, y ya no te acordarás de que está ahí.
>
> Apágalo. Puedes conservarlo, pero **apagado**.

---

### 🚩 Errores y verificación

> [!warning] Tabla de errores
> | Error | Qué pasa | Cómo evitarlo |
> | :--- | :--- | :--- |
> | Clonar la VM en vez de la instantánea | Clonas el estado actual, no el punto guardado | Clic derecho **sobre `Fase 1 terminada`** |
> | Usar `Clon enlazado` | No arranca en el ordenador de tu compañero | **Clon completo**, siempre que salga del equipo |
> | Copiar solo el `.vdi` | La máquina no lleva su configuración | La **carpeta entera**, o `.ova` |
> | No borrar `ssh_host_*` | Los dos servidores son la misma identidad criptográfica | Paso 1, **antes** de clonar |
> | No regenerar las MAC | Dos tarjetas idénticas en la misma red | Marcarlo en el asistente de clonado |
> | Dejar el clon encendido | Fallos incomprensibles en fases posteriores | Apagarlo al terminar |

> [!help] Autoevaluación
> 1. ¿Qué diferencia hay entre un **clon completo** y uno **enlazado**, y por qué solo uno sirve para compartir?
> 2. `hostname`, IP, MAC, clave de host SSH y `machine-id`: **¿cuáles se duplican al clonar y cuáles se regeneran solas?** Haz una tabla.
> 3. ¿Por qué SSH avisa con `REMOTE HOST IDENTIFICATION HAS CHANGED` y por qué **está bien** que lo haga?
> 4. Un fabricante vende 10.000 routers clonados de la misma imagen sin limpiar las claves de host. Explica el riesgo **concreto** para un cliente.
> 5. 🔬 **Reto:** vuestros dos servidores están ahora en la misma red sólo-anfitrión. Desde el clon, haz `ping 10.10.10.10`. ¿Responde? ¿Por qué **dos VM del mismo anfitrión** pueden verse entre ellas, si esa red no existe fuera del ordenador?

---

### ✅ Checklist de esta parte

- [ ] **Predicción escrita** en la entrada **antes** de encender las dos máquinas.
- [ ] `ssh_host_*` y `machine-id` limpiados **antes** de clonar.
- [ ] Clon completo creado **desde la instantánea `Fase 1 terminada`**, con MAC nuevas.
- [ ] Entregado a un compañero y recibido el suyo.
- [ ] Clon del compañero importado y arrancado.
- [ ] 💥 **El choque grabado y explicado en voz alta.**
- [ ] Clon renombrado a `UbuntuServer-Clon` y con IP `10.10.10.11`.
- [ ] Huellas SSH de las dos máquinas comprobadas y **distintas**.
- [ ] Las dos IP responden a la vez desde el anfitrión.
- [ ] Tamaños anotados: carpeta original, clon, y antes/después de compactar.
- [ ] 🧹 **Clon apagado** antes de pasar a la Fase 2.
- [ ] Las 5 preguntas contestadas en la entrada.

> [!summary] 🎓 Qué has aprendido aquí
> Que **clonar no es copiar**: una máquina tiene cosas que deben ser únicas, y duplicarlas sin pensar crea conflictos que no dan un error claro, sino comportamientos raros.
>
> Que la identidad de un servidor no es su nombre: es su **clave de host**. Por eso SSH te avisa cuando cambia, y por eso ese aviso hay que leerlo en vez de saltárselo.
>
> Y que desplegar desde plantilla —lo que hacen Azure y AWS a escala de millones— es esto mismo que acabas de hacer con un compañero de clase.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]] | [[Fase_1]] | [[Fase_1.7_Resolucion_Problemas]] |
