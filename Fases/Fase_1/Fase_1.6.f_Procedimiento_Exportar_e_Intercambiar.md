## Fase 1 · Apartado 6.f — 👥 Procedimiento — Exportar e intercambiar con un compañero

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Después del punto de control**, con la instantánea `Fase 1 terminada` ya tomada y tu `.ova` de respaldo ya hecho.

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~50 min (se trabaja **por parejas**) |
> | **Entrada de apuntes** | `b2-1.6-exportar-e-intercambiar.md` |
> | **Vídeo** | `B2 · F1 · Exportar e intercambiar` · ~10-12 min |
>
> **Requisitos:** la instantánea **`Fase 1 terminada`** y **saber exportar** — las dos cosas las hiciste en [[Fase_1.8.b_Punto_de_Control]].

> [!abstract] 📋 Qué se te evalúa aquí
> **`RA.06`** — *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras |
> | :--- | :--- | :--- |
> | `CE.06.g` | Se ha trabajado en grupo. | Pasos 4 y 5 — entregas tu máquina a un compañero e importas la suya |
>
> **Este criterio no se puede demostrar en solitario.** Es el motivo de que esta entrega sea por parejas. El detalle del resto de la fase: [[Fase_1.1_Que_Se_Evalua]].

---

### 🎯 Qué vas a hacer, y por qué no es un ejercicio de relleno

Vas a **empaquetar tu servidor y dárselo a un compañero**. Él te dará el suyo. Y los dos vais a acabar, un rato, con **dos servidores encendidos a la vez**: el vuestro y el del otro.

> [!info] 🏭 Esto se llama *imagen maestra* y es como se despliegan los servidores de verdad
> Ningún administrador instala cien máquinas a mano. Instala **una**, la deja perfecta, la convierte en plantilla y la reparte. Es lo que hace Azure con sus imágenes, lo que hace AWS con las AMI y lo que vas a hacer tú dentro de cinco minutos.
>
> El problema es que **copiar una máquina no es copiar un fichero**. Una máquina tiene cosas que deben ser **únicas** —identidad, direcciones, claves— y si las duplicas sin pensar, las dos copias se estorban entre sí. Descubrir *cuáles* son esas cosas es el objetivo real de este ejercicio.
>
> En el mundo Windows esto tiene nombre propio: **Sysprep**. Existe exactamente para esto.

> [!danger] 🤔 Antes de tocar nada: escribe tu predicción
> Vas a encender los dos servidores a la vez —el tuyo y el que te dé tu compañero—. Pregúntate **antes de hacerlo**:
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

## 📤 PRIMERA PARTE — PREPARAR Y ENTREGAR TU MÁQUINA

> [!example] Paso 1: Limpia la identidad ANTES de exportar
> Enciende tu VM y entra por SSH. Estos dos ficheros son los que **no deben viajar** en una plantilla:
>
> ```bash
> sudo rm -f /etc/ssh/ssh_host_*
> sudo truncate -s 0 /etc/machine-id
> sudo poweroff
> ```
>
> **Qué acabas de borrar, y qué pasa con cada cosa:**
>
> | Fichero | Qué es | Qué pasa al arrancar |
> | :--- | :--- | :--- |
> | `/etc/ssh/ssh_host_*` | La **identidad criptográfica** del servidor. La huella que tu cliente SSH memorizó la primera vez que dijiste `yes` | 🔴 **NO se regeneran solas.** La máquina arrancará sin SSH |
> | `/etc/machine-id` | El identificador único de esa instalación de Linux | ✅ `systemd` lo regenera solo, con un valor nuevo |
>
> > [!danger] 🔴 LEE ESTO O DEJARÁS A TU COMPAÑERO SIN SERVIDOR
> > **Las claves de host NO se recrean al arrancar.** Es una creencia extendida y es **falsa** en Ubuntu 26.04. Está comprobado ejecutándolo: se borran, se reinicia la máquina entera, y siguen sin estar. `sshd` **no arranca**.
> >
> > **Por qué mucha gente cree lo contrario:** porque existe un servicio, `sshd-keygen.service`, que hace justo eso… pero solo en el **primerísimo arranque** de una imagen recién fabricada. En una máquina ya instalada, el sistema lo salta:
> > ```
> > sshd-keygen.service ... skipped, unmet condition check ConditionFirstBoot=yes
> > ```
> >
> > **Consecuencia práctica:** el `.ova` que le des a tu compañero **llegará sin identidad SSH**, y él no podrá entrar por SSH hasta crearla. Está previsto y es parte del ejercicio — pero tiene que saberlo, y por eso lo pone aquí en rojo.
> >
> > **Se arregla en un comando**, y lo hará él en el Paso 7.
>
> > [!info] 🏭 Y así es exactamente como funciona en la vida real
> > Una plantilla de servidor **se entrega despersonalizada a propósito**. La identidad no viaja en la imagen: se crea en el destino, en lo que Microsoft llama la fase de **especialización** de Sysprep.
> >
> > Lo que acabas de hacer es la mitad *"generalizar"*. La mitad *"especializar"* la hace quien recibe la máquina.
>
> > [!danger] ⚠️ Si NO lo haces, los dos servidores son la misma máquina para el mundo
> > Y no en sentido figurado: tienen **la misma clave privada de host**. Cualquiera que tenga la copia puede **suplantar a tu servidor** en la red y tu propio SSH no notaría nada raro, porque la huella cuadraría.
> >
> > Es un fallo real y famoso: fabricantes de routers que enviaron miles de equipos con la misma clave de host porque la metieron en la imagen de fábrica.
>
> > [!bug] 🚨 Antes de dar tu máquina a nadie, mira qué llevas dentro
> > Una copia se lleva **todo**: ficheros, historial de comandos, credenciales guardadas.
> >
> > En la Fase 1 no deberías tener nada personal en la VM —tus claves de GitHub viven en tu ordenador, no aquí—, pero **acostúmbrate a comprobarlo**, porque en la Fase 4 esto ya no será inocente:
> > ```bash
> > ls -la ~/.ssh/ 2>/dev/null
> > tail -20 ~/.bash_history
> > ```
> > Entregar una máquina sin mirar qué contiene es cómo se filtran las contraseñas en las empresas.

> [!example] Paso 2: Expórtala a un `.ova`
> **Es lo mismo que hiciste en [[Fase_1.8.b_Punto_de_Control]]**, así que ya sabes: `Archivo` → **`Exportar servicio virtualizado…`** → `UbuntuServer` → **OVF 2.0** → manifiesto marcado.
>
> **Solo cambian dos cosas:**
>
> | | El respaldo del 8.b | Este de ahora |
> | :--- | :--- | :--- |
> | **Nombre** | `B2-F1-infraestructura-virtual.ova` | **`B2-F1-<tu credencial>.ova`** |
> | **Dónde** | Tu disco externo | Pendrive o carpeta compartida, para dárselo |
>
> > [!danger] 🏷️ El nombre NO te lo inventas
> > **`B2-F1-<tu credencial>`** · Bloque · Fase · **quién eres**.
> >
> > **Tu credencial es lo que va antes de la `@`** en tu correo del centro `@alu.edu.gva.es`. Es única en todo el instituto: por eso identifica tu máquina sin ambigüedad.
> >
> > **Ejemplo:** si tu correo es `lgarcia3@alu.edu.gva.es`, tu fichero es **`B2-F1-lgarcia3.ova`**.
> >
> > **Por qué importa:** en cuanto haya veinte ficheros circulando por el aula, el nombre es lo único que dice **de quién es cada uno** y **de qué fase**. Un `servidor.ova` o un `copia2.ova` es un fichero huérfano.
>
> > [!warning] ⏱️ Tarda varios minutos
> > Pausa la grabación mientras trabaja y reanúdala para enseñar **el fichero ya creado**, con su tamaño.

> [!example] Paso 3: Recupera TU máquina
> Acabas de dejar tu servidor sin claves de host. **Devuélvelo a su sitio antes de seguir**, y no con comandos: con la instantánea.
>
> En VirtualBox: selecciona la VM → pestaña **`Instantáneas`** → clic derecho en **`Fase 1 terminada`** → **`Restaurar`**.
>
> Enciende y comprueba que ha vuelto entera:
> ```bash
> sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
> ip -brief addr show enp0s8
> ```
> - **✅ Bien:** aparece una huella y la IP `10.10.10.10/24`.
>
> > [!success] 🎓 Para esto sirve una instantánea
> > No la has usado para arreglar un desastre: la has usado **para poder hacer algo destructivo con tranquilidad**, sabiendo que había vuelta.
> >
> > Esa es la diferencia entre trabajar con miedo y trabajar bien. **Un administrador no es alguien que no rompe nada: es alguien que siempre tiene por dónde volver.**

> [!example] Paso 4: Intercambiad los ficheros
> Dale tu `B2-F1-<tu credencial>.ova` a tu compañero y coge el suyo. Pendrive, carpeta compartida o Teams, lo que hayáis decidido.
>
> **Comprueba el tamaño del que recibes.** Si pesa mucho menos de lo que esperabas, la copia se cortó a medias.

---

## 📥 SEGUNDA PARTE — IMPORTAR LA SUYA Y VER EL CHOQUE

> [!example] Paso 5: Importa la máquina de tu compañero
> En **tu** VirtualBox:
>
> **1.** Menú **`Archivo`** → **`Importar servicio virtualizado…`**
>
> **2.** Selecciona el fichero **`B2-F1-<credencial de tu compañero>.ova`** y pulsa `Siguiente`.
>
> **3.** *(Configuración)* — Aquí ves lo que trae la máquina: memoria, CPU, tarjetas de red, disco. **Y hay una opción que SÍ tienes que tocar:**
>
> > [!danger] ⚠️ Política de dirección MAC: **generar direcciones MAC nuevas**
> > Búscala en esa pantalla y ponla en **generar direcciones MAC nuevas para todos los adaptadores de red**.
> >
> > **Si no lo haces**, la máquina de tu compañero llega con **las mismas direcciones físicas de red** que tenía en su ordenador. Y una dirección MAC repetida en la misma red produce fallos intermitentes de los que no dan ningún error claro: unas veces va y otras no.
> >
> > Es el mismo problema que las claves SSH del Paso 1, una capa más abajo.
>
> **4.** Confirma y espera.
>
> Cuando acabe, en tu lista aparecerá una máquina **con el nombre de tu compañero**. Así sabrás siempre cuál es cuál.
>
> > [!bug] Si dice que ya existe un disco con ese identificador
> > Solo te pasaría importando **tu propio** `.ova` en el mismo VirtualBox donde está el original. Con el de tu compañero no ocurre.
>
> **No la enciendas todavía.** Antes, lee el paso 6.

> [!example] Paso 6: 💥 El choque — enciende las dos a la vez
> Arranca **primero la tuya** y después la de tu compañero. Con las dos encendidas, entra en cada una **por la ventana de VirtualBox** (no por SSH todavía) y ejecuta en las dos:
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
>
> > [!bug] 🔌 Y hay una segunda sorpresa: la máquina importada no acepta SSH
> > Prueba a entrar y verás algo así:
> > ```
> > kex_exchange_identification: read: Connection reset by peer
> > ```
> > **No es un fallo tuyo.** Es la consecuencia directa del Paso 1: esa máquina **no tiene claves de host**, así que `sshd` no puede presentarse y corta la conversación.
> >
> > Fíjate en lo que dice el mensaje: *"connection reset"* no es ni `refused` ni `timed out`. **Has llegado, te han contestado, y la conversación se ha roto a mitad.** Un tercer sabor de fallo, y te dice que el problema no es de red sino del propio servicio.
> >
> > Por eso el Paso 7 se hace **desde la ventana de VirtualBox**: hasta arreglarlo, no hay otra forma de entrar.
>
> **Grábalo. Explícalo en voz alta.** Este momento es el ejercicio entero.

> [!example] Paso 7: Arréglalo — dale identidad propia a la máquina importada
> Deja **solo la máquina importada** encendida (apaga la tuya para no confundirte) y trabaja **desde la ventana de VirtualBox**. Por SSH todavía no se puede: es lo primero que vas a arreglar.
>
> **a) Devuélvele una identidad criptográfica** *(la mitad "especializar" de la plantilla)*:
> ```bash
> sudo ssh-keygen -A
> sudo systemctl restart ssh
> systemctl is-active ssh
> ```
>
> - **✅ Bien:** `active`. La `-A` significa *"genera todas las claves de host que falten"*, con los tipos y nombres estándar.
> - **❌ Mal:** `failed` → mira `sudo systemctl status ssh`.
>
> Y **apunta la huella**, que la vas a comparar en el apartado d):
> ```bash
> sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
> ```
>
> > [!info] 💡 Esta clave es nueva y no se parece en nada a la del original
> > No la has copiado ni recuperado: la acabas de **fabricar**. Dos máquinas nacidas de la misma plantilla, con identidades distintas. Eso es justo lo que se buscaba.
>
> **b) Nombre nuevo:**
> ```bash
> sudo hostnamectl set-hostname UbuntuServer-Clon
> ```
>
> **c) IP nueva** — edita la configuración de red:
> ```bash
> sudo nano /etc/netplan/00-installer-config.yaml
> ```
> Cambia **`10.10.10.10/24`** por **`10.10.10.11/24`** en el adaptador `enp0s8`. Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y aplica:
> ```bash
> sudo netplan apply
> sudo netplan get
> ```
>
> - **✅ Bien:** `netplan apply` no dice nada y `ip -brief addr show enp0s8` devuelve `10.10.10.11/24`.
>
> > [!warning] ⚠️ El fichero se llama `00-installer-config.yaml`
> > No `50-cloud-init.yaml`, que es lo que verás en muchos tutoriales de internet: es de versiones anteriores de Ubuntu. Si copias el nombre a ciegas, `nano` te abrirá un fichero **vacío y nuevo**, guardarás en él y no cambiará nada. Y no entenderás por qué.
>
> > [!warning] ⚠️ En YAML se indenta con **espacios**, nunca con tabuladores
> > Si pulsas `Tab` en `nano`, netplan rechazará el fichero. Y ojo: **el rechazo no rompe la red** —sigue valiendo la configuración anterior—, así que parecerá que ha funcionado. Por eso se ejecuta `netplan get` después: si sale `Command failed:`, no has guardado nada.
>
> **d) Comprueba que las dos identidades son distintas.** En cada una de las dos máquinas:
> ```bash
> sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
> ```
> Las huellas **deben ser diferentes**. Si son idénticas, alguien se saltó el Paso 1.

> [!example] Paso 8: Verificación final — las dos conviviendo
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

> [!warning] 🧹 Al terminar: apaga la máquina de tu compañero
> **No sigas a la Fase 2 con ella encendida.** El resto del proyecto asume que `10.10.10.10` es tuya y única. Un servidor de más corriendo de fondo te va a dar fallos rarísimos en la Fase 4, y ya no te acordarás de que está ahí.
>
> Apágala. Puedes conservarla, pero **apagada**.

---

## 🔀 LAS OTRAS FORMAS DE COPIAR UNA MÁQUINA, Y POR QUÉ NO LAS USAMOS

Exportar a `.ova` no es la única manera. Hay dos más, y **conviene que sepas que existen y por qué aquí no valen**.

| | Qué produce | Por qué no lo usamos |
| :--- | :--- | :--- |
| **Clonar** *(clic derecho → `Clonar`)* | **Otra máquina virtual** dentro de tu VirtualBox: una carpeta con muchos ficheros | No te da un fichero para sacar fuera. Sirve para tener dos copias **en tu propio equipo** |
| **Copiar la carpeta** de `VirtualBox VMs\` | Los mismos ficheros, en otro sitio | Ver abajo. Es lo que casi todo el mundo intenta primero |

> [!danger] ⚠️ Copiar la carpeta a mano parece que funciona… y arrastra tres problemas
> Si copias la carpeta de la máquina y la pegas en otro ordenador, **sí arranca** — hay que registrarla con `Máquina` → `Añadir…` y seleccionar el fichero `.vbox`. Pero:
>
> | | Copia manual de la carpeta | Exportar / importar `.ova` |
> | :--- | :--- | :--- |
> | **Direcciones MAC** | **Idénticas al original** | Las regeneras al importar |
> | **Identificador del disco** | El mismo → **choca** si el original sigue registrado ahí | Nuevo |
> | **Rutas absolutas** | Se copian tal cual: una ISO montada ya no se encuentra | Se rehacen |
>
> Fíjate en la primera fila: **dos máquinas con la misma dirección MAC en la misma red.** Es el mismo problema que las claves SSH, una capa más abajo — y de los que no dan un error claro, sino comportamientos raros.
>
> **La copia manual es el método ingenuo, y falla exactamente por lo que enseña esta fase.**

> [!info] 🌳 Un detalle que sí conviene saber: el `.ova` NO se lleva las instantáneas
> Exportar **aplana** la máquina: te llevas el estado actual, no el historial. Copiar la carpeta sí conserva la carpeta `Snapshots/`.
>
> **Para lo que hacemos aquí da igual**, porque tu respaldo no es una máquina con ocho instantáneas dentro: son **ocho ficheros `.ova`, uno por fase**, cada uno independiente y cada uno se abre con doble clic.
>
> Pero tenlo presente: **si alguna vez necesitas conservar el árbol de instantáneas, el `.ova` no es la herramienta.**

---

### 🚩 Errores y verificación

> [!warning] Tabla de errores
> | Error | Qué pasa | Cómo evitarlo |
> | :--- | :--- | :--- |
> | Intentar exportar con la VM encendida | No aparece en la lista del asistente | Apagarla con `sudo poweroff` |
> | Ponerle al fichero el nombre que se te ocurra | Veinte ficheros huérfanos en el aula | **`B2-F1-<tu credencial>.ova`** |
> | Clonar en vez de exportar | Te queda otra máquina en tu equipo, no un fichero que dar | `Archivo` → `Exportar servicio virtualizado` |
> | Copiar solo el `.vdi` | La máquina no lleva su configuración | Exportar a **`.ova`** |
> | No borrar `ssh_host_*` antes | Los dos servidores son la misma identidad criptográfica | Paso 1, **antes** de exportar |
> | Esperar a que las claves se regeneren solas | La máquina arranca sin SSH y crees que está rota | `sudo ssh-keygen -A` en el Paso 7 |
> | No regenerar las MAC al importar | Dos tarjetas idénticas en la misma red | Marcarlo en el asistente de importación |
> | Olvidar restaurar tu instantánea | Te quedas tú sin claves de host | Paso 3 |
> | Editar `50-cloud-init.yaml` | Creas un fichero vacío y la IP no cambia | Es **`00-installer-config.yaml`** |
> | Dejar la máquina importada encendida | Fallos incomprensibles en fases posteriores | Apagarla al terminar |

> [!help] Autoevaluación
> 1. ¿Qué diferencia hay entre **clonar** y **exportar**, y por qué solo uno sirve para dar la máquina a otra persona?
> 2. `hostname`, IP, MAC, clave de host SSH y `machine-id`: **¿cuáles se duplican al copiar una máquina y cuáles se regeneran solas?** Haz una tabla.
> 3. En el Paso 3 recuperas tu máquina restaurando una instantánea en vez de rehacerla a mano. **¿Qué te habría costado no tener esa instantánea?**
> 4. Un fabricante vende 10.000 routers clonados de la misma imagen sin limpiar las claves de host. Explica el riesgo **concreto** para un cliente.
> 5. 🔬 **Reto:** vuestros dos servidores están ahora en la misma red sólo-anfitrión. Desde el importado, haz `ping 10.10.10.10`. ¿Responde? ¿Por qué **dos VM del mismo anfitrión** pueden verse entre ellas, si esa red no existe fuera del ordenador?

---

### ✅ Checklist de esta parte

- [ ] **Predicción escrita** en la entrada **antes** de encender las dos máquinas.
- [ ] `ssh_host_*` y `machine-id` limpiados **antes** de exportar.
- [ ] Exportado a **`B2-F1-<tu credencial>.ova`**, con **OVF 2.0** y manifiesto.
- [ ] 🔄 **Instantánea `Fase 1 terminada` restaurada**, y tu servidor comprobado entero.
- [ ] Fichero entregado a un compañero y recibido el suyo.
- [ ] Importado **regenerando las direcciones MAC**.
- [ ] 💥 **El choque grabado y explicado en voz alta.**
- [ ] Comprobado que no acepta SSH (`Connection reset by peer`) y arreglado con `sudo ssh-keygen -A`.
- [ ] Renombrada a `UbuntuServer-Clon` y con IP `10.10.10.11`.
- [ ] Huellas SSH de las dos máquinas comprobadas y **distintas**.
- [ ] Las dos IP responden a la vez desde el anfitrión.
- [ ] 🧹 **Máquina del compañero apagada** antes de pasar a la Fase 2.
- [ ] Las 5 preguntas contestadas en la entrada.

> [!summary] 🎓 Qué has aprendido aquí
> Que **copiar una máquina no es copiar un fichero**: tiene cosas que deben ser únicas, y duplicarlas sin pensar crea conflictos que no dan un error claro, sino comportamientos raros.
>
> Que **exportar y clonar no son lo mismo**: clonar te deja otra máquina dentro de tu programa; exportar te da **un fichero** que puedes sacar, guardar y entregar. Para una copia de seguridad quieres lo segundo.
>
> Que la identidad de un servidor no es su nombre: es su **clave de host**. Por eso SSH avisa cuando cambia, y por eso ese aviso hay que leerlo en vez de saltárselo.
>
> Y que desplegar desde plantilla —lo que hacen Azure y AWS a escala de millones— es esto mismo que acabas de hacer con un compañero de clase.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.8.b_Punto_de_Control]] | [[Fase_1]] | [[Fase_1.9_Preguntas]] |
