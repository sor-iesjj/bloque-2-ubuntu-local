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
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-2-purga-y-preparacion-del-entorno.md`) con su estructura, vacía.
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
> sudo apt update && sudo apt install -y acl attr samba samba-ad-dc samba-ad-provision krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf
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
> > [!warning] ⚠️ Nota sobre `resolvconf` y el DNS del sistema
> > El paquete `resolvconf` que acabas de instalar puede entrar en conflicto con el servicio de DNS que Ubuntu trae por defecto (`systemd-resolved`). De momento no haremos nada; el script de la Fase 4 se encarga de resolver este conflicto automáticamente.

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
> 127.0.1.1       UbuntuServer
> 10.10.10.10     UbuntuServer.BOOCHANLAB.LOCAL   UbuntuServer
>
> ::1     localhost ip6-localhost ip6-loopback
> ff02::1 ip6-allnodes
> ff02::2 ip6-allrouters
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
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

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.5_Fundamento_Teorico]] | [[Fase_2]] | [[Fase_2.7_Resolucion_Problemas]] |
