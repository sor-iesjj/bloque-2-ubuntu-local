## Fase 2 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!important] 🔌 Paso 0: Conéctate al servidor
> Todos los comandos de esta fase se ejecutan **dentro de tu VM de VirtualBox**, no en tu PC físico. Puedes trabajar directamente en la ventana de consola de la VM, o bien abrir una terminal en tu PC y conectarte por SSH a la IP interna que configuraste en la Fase 1:
> ```bash
> ssh boochan@10.10.10.10
> ```
> Cuando veas el símbolo `$` al final de la línea, ya estás listo para continuar.
>
> > [!tip] 💡 ¿Consola de VirtualBox o SSH?
> > Ambas opciones son válidas y hacen exactamente lo mismo. La consola de VirtualBox (la ventana de la VM) siempre funciona, incluso si la red todavía no está bien configurada. El SSH es más cómodo (puedes copiar y pegar comandos largos) pero requiere que la Red Solo Anfitrión ya esté operativa. Si tienes dudas de cuál usar, empieza por la consola de VirtualBox.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b2-f2-purga-y-preparacion.md`) con su estructura, vacía.
> 2. **Léete los pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado**.

> [!example] Paso 1A: Limpieza Total del Entorno
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"No encuentra Samba"* → [[Fase_2.7_Resolucion_Problemas#E2 · apt purge dice que no encuentra Samba|caso E2]] *(casi siempre **no es un error**)*
> > · *"Purgué y `winbind` sigue"* → [[Fase_2.7_Resolucion_Problemas#E3 · Purgué Samba pero winbind sigue instalado|caso E3]]
> > · *"Sigue algo en el puerto 445"* → [[Fase_2.7_Resolucion_Problemas#E5 · Algo sigue escuchando en el puerto 445|caso E5]]
> Antes de construir, debemos demoler lo viejo. Ejecuta estos comandos para liberar los puertos y limpiar la caché:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta y ver ejemplos de `apt`, `systemctl` y `rm`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # 1. Detiene los servicios actuales (si no existen, el aviso es normal e inofensivo)
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
>
> # 2. Elimina Samba, winbind y su configuración. Lista EXPLÍCITA, sin comodines
> sudo apt purge -y samba samba-common samba-common-bin winbind libnss-winbind libpam-winbind
> sudo apt autoremove -y
>
> # 3. Borra carpetas manuales para evitar residuos configurados
> sudo rm -rf /etc/samba/ /var/lib/samba/ /var/cache/samba/ /run/samba/
> ```
>
> > [!tip] 💡 ¿Qué hace cada cosa?
> > - **`purge` y no `remove`:** `remove` borra los programas pero **deja los ficheros de configuración**. Y el que nos estorba es precisamente `/etc/samba/smb.conf`: si sobrevive, la Fase 4 se encuentra una configuración vieja mezclada con la del dominio. **Ésta es la diferencia que hay que entender de esta fase.**
> > - **`winbind` va en la lista aparte:** no empieza por "samba", así que si solo borraras los paquetes `samba*` se te quedaría instalado. Viene de fábrica en Ubuntu Server igual que Samba.
> > - **`rm -rf`:** la "demolición total". Borra carpetas aunque no estén vacías. A veces el desinstalador se deja bases de datos antiguas que darían errores después.
> > - **`2>/dev/null || true`:** si el servicio no existiera, el comando daría un error inofensivo. Esto le dice a Linux "si falla, ignóralo y sigue".
>
> > [!danger] ⚠️ Por qué la lista va escrita entera y no `apt purge samba*`
> > Verás por internet ese atajo con asterisco. **No lo uses en un borrado**, por dos motivos:
> > 1. **El asterisco sin comillas lo interpreta primero la shell**, no `apt`: bash intenta expandirlo contra los ficheros del directorio donde estés, y el comando puede acabar haciendo algo distinto de lo que crees.
> > 2. **Un comodín borra lo que caza, no lo que querías.** En un servidor se escribe la lista de lo que se va a borrar — y se lee antes de pulsar Enter. Fíjate en que `apt` te muestra esa lista **antes** de actuar: es tu última oportunidad de ver que se lleva algo que no esperabas.

> [!example] Paso 1B: Comprueba que la demolición ha funcionado
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"`smbd` sigue `active (running)`"* → [[Fase_2.7_Resolucion_Problemas#E4 · En el Paso 1B smbd sigue activo|caso E4]]
> > · *"Sigue algo en el puerto 445"* → [[Fase_2.7_Resolucion_Problemas#E5 · Algo sigue escuchando en el puerto 445|caso E5]]
> **Hazlo AHORA, antes del Paso 2.** Es tu única oportunidad: el Paso 2 vuelve a instalar Samba, y a partir de ahí ya no podrás comprobar si la purga funcionó.
>
> No des por hecho que un comando ha hecho su trabajo porque no dio error. Las tres comprobaciones:
>
> ```bash
> systemctl status smbd
> sudo ss -tlnp | grep -E ':(139|445)'
> dpkg -l | grep -E '^ii\s+samba'
> ```
>
> Lo correcto es:
>
> | Comando | Respuesta que buscas | Si sale otra cosa |
> | :--- | :--- | :--- |
> | `systemctl status smbd` | `Unit smbd.service could not be found` | Si dice `active (running)`, la purga **no se ha ejecutado**. Vuelve al Paso 1A |
> | `ss` en 139/445 | **nada, ninguna línea** | Si aparece `smbd` escuchando, esos puertos siguen ocupados y **la Fase 4 fallará** |
> | `dpkg -l \| grep '^ii samba'` | **nada** | Si hay líneas `ii`, los paquetes siguen instalados |
>
> > [!info] ℹ️ Es normal que queden bibliotecas
> > Puede que veas `samba-libs`, `python3-samba`, `libtdb1` o `libtalloc2`. **Déjalas si el `autoremove` no se las llevó.** Son bibliotecas, no servicios: no escuchan en ningún puerto y la Fase 4 las necesitará. Lo que teníamos que quitar era el **servidor** y su configuración.
>
> > [!question] 🤔 Antes de seguir
> > Los puertos **139** y **445** que acabas de liberar, ¿de quién eran y quién los va a querer en la Fase 4? Contéstalo en tu entrada.

> [!example] Paso 2: Instalación de Dependencias Críticas
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"`apt update` no descarga nada"* → [[Fase_2.7_Resolucion_Problemas#E1 · apt update no descarga nada o no hay internet|caso E1]]
> > · *"No sale la pantalla azul de Kerberos"* → [[Fase_2.7_Resolucion_Problemas#E9 · La pantalla azul de Kerberos no aparece|caso E9]] *(**no es un error**)*
> Instalamos las herramientas que permiten a Linux "disfrazarse" de servidor Windows. Este comando necesita el adaptador **NAT** funcionando, ya que descarga paquetes de internet:
> ```bash
> sudo apt update && sudo apt install -y acl attr samba samba-ad-dc samba-ad-provision krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard
> ```
>
> > [!danger] ⚠️ `samba-ad-dc` y `samba-ad-provision`: sin ellos la Fase 4 es IMPOSIBLE
> > **Desde Ubuntu 24.04, el paquete `samba` ya NO incluye lo necesario para montar un controlador de dominio.** Se reparte en dos paquetes aparte:
> >
> > | Paquete | Qué aporta | Qué pasa si falta |
> > | :--- | :--- | :--- |
> > | **`samba-ad-provision`** | Los ficheros de esquema de Active Directory | El aprovisionamiento falla: *"AD_DS_Attributes... not found"* |
> > | **`samba-ad-dc`** | El servicio `samba-ad-dc.service` y módulos internos | *"Unit samba-ad-dc.service does not exist"* y *"Module [samba_secrets] not found"* |
> >
> > Y lo peor: **los errores no aparecen aquí, sino dos fases más adelante**, en mitad del aprovisionamiento del dominio, con mensajes que no mencionan que falte un paquete. Si te saltas esta línea, lo descubrirás en la Fase 4 sin saber por qué.
> >
> > Comprueba que están:
> > ```bash
> > dpkg -s samba-ad-dc samba-ad-provision | grep -E '^Package|^Status'
> > ```
>
> > [!caution] ⚠️ Si el comando falla a mitad de la instalación
> > Este comando instala muchos paquetes a la vez. Si ves un error en rojo y la instalación se detiene, no entres en pánico. Ejecuta esto para reparar los paquetes que quedaron a medias y vuelve a intentarlo:
> > ```bash
> > sudo apt --fix-broken install -y
> > ```
> > **Si `apt update` da error de red:** comprueba que el adaptador **NAT** de la VM está conectado (`Configuración → Red → Adaptador 1` en VirtualBox) y que puedes hacer `ping 8.8.8.8` desde dentro de la VM. El adaptador de Red Solo Anfitrión (`10.10.10.10`) **no** da salida a internet por diseño — solo el NAT lo hace.
>
> > [!important] 💡 La pantalla azul de Kerberos (`krb5-config`)
> > En algún momento durante la instalación, **la pantalla se pondrá completamente azul** y aparecerá un formulario preguntando por el "Reino Kerberos por defecto". No te asustes, es normal. Sigue estos pasos exactos:
> > 1. El cursor estará en un campo de texto. Escribe `BOOCHANLAB.LOCAL` (**siempre en MAYÚSCULAS**).
> > 2. Pulsa la tecla `Tab` para seleccionar el botón `<Ok>` y luego pulsa `Enter`.
> > 3. Si aparecen más pantallas preguntando por servidores adicionales, déjalas en blanco y pulsa `Enter` para aceptar los valores por defecto.
> >
> > **¡Las mayúsculas son obligatorias!** Si escribes `boochanlab.local` en minúsculas, el sistema de seguridad Kerberos fallará más adelante y ningún usuario podrá autenticarse.
>
> > [!warning] ⚠️ El DNS del sistema lo lleva `systemd-resolved`, y punto
> > Manuales antiguos —y versiones anteriores de esta práctica— te hacen instalar aquí un paquete llamado `resolvconf`. **En Ubuntu Server 26.04 ese paquete ya no existe**: lo comprobamos ejecutando y `apt-cache policy resolvconf` devuelve `Candidate: (none)`. Tampoco está `openresolv`.
> >
> > El DNS lo gestiona en exclusiva **`systemd-resolved`**, y `/etc/resolv.conf` es un enlace simbólico a un fichero suyo. Míralo:
> > ```bash
> > ls -l /etc/resolv.conf
> > ```
> >
> > No hay que hacer nada ahora. El script de la Fase 4 apaga el *stub* de `systemd-resolved` justo antes de levantar el DNS interno de Samba, para que este pueda quedarse con el puerto 53.
> >
> > > [!bug] 🚩 Ojo a este comportamiento de `apt`
> > > Si pides un paquete que **no existe en los repositorios**, `apt` avisa… y **puede seguir instalando el resto sin abortar**. Terminas creyendo que instalaste todo. Por eso la comprobación de después no es un adorno: es la única forma de saber qué hay realmente.
> > > Detalle: [[Fase_2.7_Resolucion_Problemas#E11 · Instalé los paquetes pero uno no está|caso E11]].

> [!example] Paso 2B: Actualizar el sistema
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"Sale una pantalla morada preguntando por servicios"* → [[Fase_2.7_Resolucion_Problemas#E12 · Pantalla morada que pregunta por reiniciar servicios|caso E12]] *(**no es un error**)*
> Un servidor recién instalado arrastra semanas —o meses— de parches sin aplicar. Antes de construir el dominio encima, se pone al día:
>
> ```bash
> sudo apt upgrade -y
> ```
>
> > [!info] ⏱️ Tarda, y es normal
> > Pueden ser **40 o 50 paquetes** y varios minutos. Déjalo terminar: interrumpir una actualización a medias deja paquetes rotos.
>
> > [!important] 🟪 Aparecerá una pantalla MORADA. No te asustes
> > Es **`needrestart`**, y pregunta qué servicios reiniciar con las bibliotecas nuevas. Aparece con una lista de servicios preseleccionados.
> >
> > **Pulsa `Enter` para aceptar** lo que propone. Es lo correcto: un servicio que sigue usando una biblioteca vieja no tiene el parche de seguridad que acabas de instalar, aunque el paquete ya esté actualizado.
> >
> > Si además pregunta *"¿Reiniciar el sistema?"*, responde **que no**: reinicias tú al final del paso.
>
> **Comprueba que no ha quedado nada roto:**
> ```bash
> sudo dpkg --audit          # sin salida = todo correcto
> apt list --upgradable      # deberían quedar muy pocos o ninguno
> ```
>
> > [!tip] 💡 ¿Y si quedan dos o tres sin actualizar?
> > Normal. `apt upgrade` **no toca** los paquetes cuya actualización obligaría a instalar o eliminar otros — es deliberadamente conservador. Para eso está `apt full-upgrade`, que **aquí no vamos a usar**: en un servidor, un comando que puede desinstalar cosas por su cuenta se ejecuta sabiendo lo que hace, no por costumbre.
>
> **Si te pide reiniciar, reinicia:**
> ```bash
> [ -f /var/run/reboot-required ] && echo "hay que reiniciar" || echo "no hace falta"
> sudo reboot
> ```
> Se actualiza el **kernel** a menudo, y el nuevo no entra en uso hasta que reinicias.
>
> > [!question] 🤔 Antes de seguir
> > `sudo apt update` y `sudo apt upgrade` **no son lo mismo**, y los dos los has ejecutado hoy. ¿Qué hace exactamente cada uno? Explícalo en tu entrada con tus palabras. *(Pista: uno consulta y el otro modifica.)*
> >
> > **Aquí demuestras el `CE.01.h`** — *"se ha actualizado el sistema operativo en red"*.

> [!example] Paso 3: Configuración de la Identidad (FQDN)
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"Abro `/etc/hosts` y está VACÍO"* → [[Fase_2.7_Resolucion_Problemas#E6 · El fichero de identidades de red está vacío|caso E6]] — **le pasa a todo el mundo en Ubuntu 26.04**
> > · *"`hostname -f` no devuelve el nombre completo"* → [[Fase_2.7_Resolucion_Problemas#E7 · hostname -f no devuelve el nombre completo|caso E7]]
> > · *"`hostname -I` no muestra `10.10.10.10`"* → [[Fase_2.7_Resolucion_Problemas#E8 · hostname -I no muestra la IP 10.10.10.10|caso E8]]
> Debemos decirle al servidor quién es. Primero comprobamos que la IP estática de la Fase 1 sigue activa:
> ```bash
> hostname -I
> ```
> > [!tip] 💡 ¿Qué IP anoto si aparecen varias?
> > Verás **dos IPs distintas**, una por cada adaptador de red de la VM:
> > - `10.10.10.10` → tu adaptador de **Red Solo Anfitrión**, la IP estática que fijaste en la Fase 1. **Es la que usaremos.**
> > - Algo del estilo `10.0.2.15` → tu adaptador **NAT**, dinámico, solo para salir a internet. No lo uses para el `/etc/hosts`.
> >
> > Si `10.10.10.10` no aparece, revisa la configuración de red de la Fase 1 (`/etc/netplan/`) antes de continuar — sin esa IP fija, el dominio de la Fase 4 no se levantará de forma estable.
>
> Ahora fijamos el nombre del servidor de forma permanente. Primero editamos el archivo que guarda el nombre corto:
> ```bash
> sudo nano /etc/hostname
> ```
> Borra lo que haya y escribe únicamente esto:
> ```
> UbuntuServer
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> A continuación abrimos el archivo de identidades de red:
> ```bash
> sudo nano /etc/hosts
> ```
> **Mira primero qué hay dentro.** Lo normal es que tenga ya un par de líneas de `localhost`, pero **puede estar vacío** — pasa con algunas instalaciones de Ubuntu Server 26.04 y no es culpa tuya.
>
> Déjalo **exactamente así**, tenga lo que tenga:
> ```
> 127.0.0.1       localhost
> 10.10.10.10     UbuntuServer.BOOCHANLAB.LOCAL   UbuntuServer
>
> ::1     localhost ip6-localhost ip6-loopback
> ff02::1 ip6-allnodes
> ff02::2 ip6-allrouters
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!danger] 🛑 Si ves una línea `127.0.1.1 UbuntuServer`, BÓRRALA
> > Ubuntu la pone por defecto en muchas instalaciones. Aquí **sobra, y hace daño**.
> >
> > `hostname -f` resuelve el nombre y se queda con **la primera coincidencia**. Si la del `127.0.1.1` va antes, encuentra esa —que solo lleva el nombre corto— y **nunca llega a la del `10.10.10.10`**. Resultado: te devuelve `UbuntuServer` en vez del nombre completo.
> >
> > Y hay algo peor que el síntoma: dejaría el nombre de tu servidor apuntando a una dirección de **bucle local**. Un controlador de dominio anunciado en `127.0.1.1` **no lo alcanza nadie desde la red** — es el mismo problema que el `--host-ip` de la Fase 4.
> >
> > ```bash
> > sudo sed -i '/^127\.0\.1\.1/d' /etc/hosts
> > ```
> >
> > Es lo que recomienda la propia documentación de Samba para un controlador de dominio. **Probado ejecutando: con esa línea, `hostname -f` falla; sin ella, funciona.**
>
> > [!danger] ⚠️ Si el fichero estaba vacío, no era un detalle sin importancia
> > `127.0.0.1 localhost` es cómo un sistema Linux **se encuentra a sí mismo**. Sin esa línea, cualquier programa que intente conectarse a `localhost` falla, y los errores que da no mencionan `/etc/hosts` por ninguna parte.
> >
> > La tercera línea es la que necesita el dominio de la **Fase 4**: hace que el servidor se reconozca por su **nombre completo**, no solo por el corto.
>
> > [!tip] 💡 Las tres columnas
> > `IP` · `nombre completo (FQDN)` · `nombre corto (alias)`. El orden importa: `hostname -f` devuelve **el segundo campo** de la línea que corresponda. Si pones el nombre corto antes que el largo, `hostname -f` te dará `UbuntuServer` y la Fase 4 se aprovisionará mal.
>
> Verifica que el servidor se reconoce a sí mismo con el nombre completo:
> ```bash
> # Debe devolver: UbuntuServer.BOOCHANLAB.LOCAL
> hostname -f
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].

---

### ✅ Checklist de esta parte

- [ ] Entorno **limpio**: los restos de instalaciones anteriores eliminados (Paso 1A).
- [ ] **Demolición comprobada** (Paso 1B), no dada por hecha.
- [ ] Paquetes de la Fase 4 instalados: `samba-ad-dc`, `samba-ad-provision`.
- [ ] Sistema actualizado sin errores.
- [ ] `/etc/hosts` con sus **tres columnas** en el orden correcto: IP · FQDN · alias.
- [ ] `hostname -f` → **`UbuntuServer.BOOCHANLAB.LOCAL`**.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!important] 🛑 Aquí no has terminado la fase
> Los comandos han salido bien, pero **eso no es lo mismo que estar verificado**. La lista con la que se decide si esta fase está lista —y con la que se guarda o no la instantánea— es el [[Fase_2.8.a_Verificacion|apartado 8.a]]: cinco comprobaciones, y una de ellas (`hostname -f` y el reino **en mayúsculas**) es la que sostiene toda la Fase 4.
>
> **Orden correcto:** [[Fase_2.8.a_Verificacion|8.a · verificar]] → [[Fase_2.8.b_Punto_de_Control|8.b · guardar]]. Nunca al revés: una instantánea de un trabajo mal hecho convierte el fallo en tu punto de retorno.

> ¿Algo no ha salido? → [[Fase_2.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio, no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.5_Fundamento_Teorico]] | [[Fase_2]] | [[Fase_2.7_Resolucion_Problemas]] |
