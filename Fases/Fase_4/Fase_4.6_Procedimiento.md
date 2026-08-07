## Fase 4 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Abre la entrada de apuntes** que llevas escribiendo desde el índice (`b2-4-aprovisionamiento-del-dominio.md`). Repasa lo que tienes: la teoría del apartado 5 la vas a necesitar ahora.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Traer el script, leerlo y ejecutarlo
> Para evitar errores humanos, usaremos el script `provision_boochan.sh`, adaptado para este laboratorio local con las variables `BOOCHANLAB` / `BOOCHANLAB.LOCAL`. Lo primero es **traerlo al servidor**.
>
> > [!info] 📚 Diccionario de Comandos: Consulta el [[Diccionario_Comandos_Sistema]] para entender al detalle cómo funcionan los comandos administrativos que usaremos aquí.
>
> **1.** Trae el script al servidor. **Hay dos formas, y elegir bien es parte del ejercicio.**
>
> > [!success] ✅ Opción A (recomendada): trae SOLO el fichero, con `curl`
> > ```bash
> > cd ~
> > curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/provision_boochan.sh
> > ls -l provision_boochan.sh
> > ```
> > Un fichero de **unos 7 KB**. Nada más. Es la misma técnica con la que descargas los verificadores desde la Fase 1.
>
> > [!info] 🔀 Opción B: clona el repositorio entero, con `git`
> > ```bash
> > sudo apt install git -y
> > sudo git clone https://github.com/sor-iesjj/bloque-2-ubuntu-local /opt/boochan
> > cd /opt/boochan
> > ```
> > Te trae **el repositorio completo: 124 ficheros**, con todo el material del bloque. Para usar **uno**.
>
> > [!question] 🤔 ¿Cuál elegirías tú? Contéstalo en tu entrada de apuntes
> > | | **A · `curl`** | **B · `git clone`** |
> > | :--- | :--- | :--- |
> > | Qué trae | **1 fichero** (7 KB) | **124 ficheros** + el historial de Git |
> > | Instala algo | No. `curl` ya está | Sí, hay que instalar `git` |
> > | Se actualiza solo | No | Sí, con `git pull` |
> > | Para qué sirve | **Coger una herramienta y usarla** | **Trabajar sobre un proyecto** |
> >
> > **La respuesta correcta aquí es la A**, y el motivo no es que `git` sea peor: es que **estás usando la herramienta equivocada para lo que necesitas.** `git clone` sirve para trabajar sobre un proyecto —ver su historia, hacer cambios, sincronizarlos—. Tú solo quieres **ejecutar un script una vez**.
> >
> > **Y hay un motivo más serio:** en un servidor de producción, **cuanto menos haya, mejor**. Instalar `git` y dejar 124 ficheros del material del curso en `/opt` de un controlador de dominio es exactamente lo que un auditor te marcaría. Se llama **superficie de ataque**: cada programa y cada fichero que no necesitas es algo más que puede fallar o que alguien puede aprovechar.
> >
> > **Entonces, ¿por qué te enseño la B?** Porque la vas a ver en mil tutoriales, y porque **saber cuándo NO usar una herramienta que dominas vale más que aprender otra nueva.** Además, si algún día quieres el material completo dentro del servidor, ya sabes cómo.
>
> > [!warning] ⚠️ Que sea el de **V1 (Local)**
> > Los scripts `provision_boochan.sh` de V1, V2 y V3 se parecen muchísimo, pero los de la nube usan el reino **`BOOCHAN.SPACE`**. Si te traes el equivocado, el dominio no coincidirá con el `/etc/hosts` que configuraste en la Fase 2 y **nada encajará**.
> >
> > La dirección correcta es la que lleva **`bloque-2-ubuntu-local`**. Compruébalo en la línea que has escrito antes de darle a `Enter`.
>
> **2.** **LEE EL SCRIPT ANTES DE EJECUTARLO** *(desde donde lo hayas dejado: `~` con la opción A, `/opt/boochan` con la B)*:
> ```bash
> cat provision_boochan.sh
> ```
>
> > [!danger] 🛑 Esto no es una formalidad
> > Vas a ejecutar como **root** un fichero descargado de internet. Ahí dentro hay comandos que **borran ficheros del sistema** (`rm -f /etc/resolv.conf`) y que dejan otros **imposibles de modificar** (`chattr +i`).
> >
> > **Nunca ejecutes como root un script que no has leído.** Si un día alguien te pasa un `curl ... | sudo bash`, esa es exactamente la costumbre que te salva.
> >
> > Localiza en el `cat` estas cinco cosas y explícalas en el vídeo:
> > 1. Las variables del principio: `DOMAIN_NAME`, `REALM_NAME`, `ADMIN_PASS`.
> > 2. Qué le hace a `/etc/resolv.conf` y por qué.
> > 3. Qué significa `--use-rfc2307` *(pista: sin eso, la Fase 5 no funciona)*.
> > 4. Para qué está `--host-ip=10.10.10.10` *(pista: tu servidor tiene DOS tarjetas — ¿qué pasaría si Samba eligiera la otra?)*.
> > 5. Qué tres servicios apaga al final, y por qué estorban.
>
> **3.** Ahora sí, dale permiso de ejecución y lánzalo:
> ```bash
> sudo chmod +x provision_boochan.sh
> sudo ./provision_boochan.sh
> ```
>
> El script tardará **2-3 minutos**. Verás mensajes de progreso en pantalla.
>
> > [!tip] 💡 El script escribe mucho en pantalla — ¿cómo sé si va bien?
> > Es normal ver líneas amarillas e incluso algún aviso en rojo durante el proceso: son mensajes informativos de Samba, no errores reales. El script está preparado para **pararse él solo en cuanto algo falle de verdad**, diciéndote qué falta y cómo arreglarlo. La confirmación de éxito es este recuadro:
> > ```
> > ==========================================================
> >  Despliegue de BOOCHANLAB finalizado CORRECTAMENTE.
> > ==========================================================
> > ```
> > Si en su lugar ves una línea que empieza por `ERROR:` o por `!!!`, **lee lo que dice**: te indica exactamente qué instalar o qué revisar. No sigas sin el recuadro de éxito — y si te habla de paquetes que faltan, es el [[Fase_4.7_Resolucion_Problemas#E1 · El script para diciendo que falta un paquete|caso E1]].
>
> > [!tip] 💡 ¿Qué hace cada comando?
> > - **`curl -O`:** Descarga **un fichero** desde una dirección de internet. La `-O` **mayúscula** significa *"guárdalo con el mismo nombre que tiene allí"*. Y `raw.githubusercontent.com` devuelve **el fichero desnudo**, sin la página web de GitHub alrededor — lo explicamos en [[Fase_1.8.a_Verificacion]].
> > - **`git clone`:** Descarga una copia completa del proyecto **con todo su historial**. Es la herramienta correcta cuando vas a trabajar sobre el proyecto, no cuando solo quieres un fichero.
> > - **Los dos necesitan el adaptador NAT.** La Red Solo Anfitrión no da salida a internet: si esto falla, mira el [[Fase_4.7_Resolucion_Problemas#E2 · No puedo traer el script porque no hay red|caso E2]].
> > - **`chmod +x`:** En Linux, los archivos descargados no "tienen permiso" para ejecutarse por seguridad. Este comando le pone la etiqueta de **ejecutable**.
> > - **El punto y la barra (`./`):** Le dice a Linux: "Busca este archivo **aquí mismo**, en esta carpeta". Sin el `./`, Linux buscaría el comando en las carpetas del sistema y no lo encontraría.
> > - **Los valores por defecto del script:** El script ya viene configurado con los valores correctos de este proyecto (`BOOCHANLAB`, Realm `BOOCHANLAB.LOCAL`, contraseña `P@ssw0rd`). No necesitas modificar nada salvo que tu profesor indique lo contrario.
>
> > [!note] 📄 Mapa del script: las cinco secciones que verás en el `cat`
> > **La fuente de verdad es el script que acabas de descargar**, no este resumen — si difieren, manda el del repositorio. Esto es el mapa para no perderte al leerlo:
> >
> > | Sección | Qué hace | La línea clave |
> > | :--- | :--- | :--- |
> > | **0. Comprobaciones previas** | Verifica que estás como root y que los paquetes de la Fase 2 están instalados. **Si falta algo, para aquí** y te dice qué instalar | `dpkg -s samba-ad-dc samba-ad-provision` |
> > | **1. Aprovisionamiento** | Crea el dominio entero: directorio LDAP, Kerberos, DNS interno | `samba-tool domain provision ... --host-ip=10.10.10.10` |
> > | **2. Kerberos** | Instala el `krb5.conf` que acaba de generar el dominio | `cp /var/lib/samba/private/krb5.conf` |
> > | **3. Arranque del AD DC** | Apaga el Samba clásico y levanta el controlador de dominio | `systemctl enable --now samba-ad-dc` |
> > | **4. DNS persistente** | Apunta el servidor a sí mismo y bloquea el fichero para que nada lo sobrescriba | `chattr +i /etc/resolv.conf` |
> >
> > > [!question] 🤔 ¿Por qué el DNS se toca al FINAL y no al principio?
> > > Porque apuntar el servidor a `127.0.0.1` **solo tiene sentido cuando ya hay un DNS escuchando ahí** — y ese DNS es el de Samba, que no existe hasta la sección 3.
> > > Y hay un motivo más importante: si el aprovisionamiento falla, el servidor **conserva su resolución de nombres** y puedes seguir instalando paquetes para arreglarlo. Al revés, un fallo te dejaría sin DNS y sin poder instalar nada: encerrado fuera de tu propia máquina.
> > > **Regla general: lo que te puede dejar aislado, se hace al final y solo si todo lo demás ha ido bien.**
> >
> > Y una línea más, arriba del todo, que es la que hace al script digno de confianza: **`set -euo pipefail`** — aborta al primer error en vez de seguir adelante con todo roto. Un script de administración que no para cuando algo falla es un script que miente.
> >
> > El `DNS_FORWARDER=8.8.8.8` funciona así: cuando Samba no sabe resolver un nombre (porque no es del dominio), reenvía la consulta a Google DNS a través del adaptador NAT.

> [!example] Paso 2: El primer latido — ¿el dominio ha arrancado?
> Esto **no es la verificación de la fase**: es solo el pulso, para saber si el script dejó el dominio en pie antes de seguir.
> ```bash
> systemctl is-active samba-ad-dc
> ```
> Debe devolver una sola palabra: **`active`**. Si dice `failed` o `inactive` → [[Fase_4.7_Resolucion_Problemas#E9 · samba-ad-dc no arranca|caso E9]].
>
> > [!tip] 💡 Si prefieres verlo con detalle, cuidado con la pantalla que se queda enganchada
> > ```bash
> > sudo systemctl status samba-ad-dc --no-pager
> > ```
> > **Sin `--no-pager`, la salida se abre dentro de `less`** —un paginador— y la pantalla parece bloqueada. No lo está: **se sale pulsando `q`**. Dentro te mueves con `↑`/`↓` y avanzas página con `espacio`. `Ctrl+C` y `Esc` no sirven aquí.
> >
> > Es el mismo `less` que usarás en el apartado 8.a para leer el verificador. Acostúmbrate: en Linux, media docena de comandos te dejan en él.

> [!example] Paso 3: El servidor se mira a sí mismo
> El script ha cambiado a quién le pregunta el servidor cuando necesita resolver un nombre. Confírmalo:
> ```bash
> cat /etc/resolv.conf
> lsattr /etc/resolv.conf
> ```
>
> | Comando | Qué tiene que salir |
> | :--- | :--- |
> | `cat` | `nameserver 127.0.0.1` |
> | `lsattr` | Una **`i`** entre los atributos: `----i---------e------- /etc/resolv.conf` |
>
> > [!info] 🤔 A mí me salen DOS líneas en el `cat`, no una
> > Normal:
> > ```
> > nameserver 127.0.0.1
> > search BOOCHANLAB.LOCAL
> > ```
> > La segunda es el **dominio de búsqueda**: hace que si escribes `ubuntuserver` a secas, el sistema complete solo hasta `ubuntuserver.boochanlab.local`. No es obligatoria y no sobra — es señal de que el aprovisionamiento dejó bien configurado el dominio.
>
> > [!warning] ⚠️ La `i` no es un adorno, y por eso se comprueba AQUÍ
> > `systemd-resolved` **reescribe `/etc/resolv.conf` en cada arranque**. Que hoy ponga `127.0.0.1` no significa que mañana lo siga poniendo.
> >
> > `chattr +i` lo deja **inmutable**: ni `root` puede tocarlo. Si el `lsattr` no muestra la `i`, tu configuración se pierde en el próximo reinicio y te enterarás en la Fase 5 o más tarde → [[Fase_4.7_Resolucion_Problemas#E6 · Tras reiniciar el DNS ha vuelto a otro sitio|caso E6]].
> >
> > **"Lo he cambiado" no es lo mismo que "se quedará cambiado".** Una configuración que no sobrevive a un reinicio no está hecha.
>
> > [!bug] 🛑 ¿Estás seguro de que estos comandos los ha contestado el SERVIDOR?
> > Si administras por SSH, comprueba **dónde estás** antes de dar nada por bueno:
> > ```bash
> > hostname
> > ```
> > Tiene que responder `ubuntuserver`. Si responde el nombre de tu ordenador, estás ejecutando los comandos en tu propia máquina y las respuestas no valen → [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11]].

---

### ✅ Checklist de esta parte

- [ ] Script traído con `curl` **y LEÍDO entero** antes de ejecutarlo.
- [ ] Comprobado que es el de **`bloque-2-ubuntu-local`**, no el de la nube.
- [ ] Las **cinco cosas** del `cat` localizadas y explicadas en el vídeo.
- [ ] Recuadro **`Despliegue de BOOCHANLAB finalizado CORRECTAMENTE`** en pantalla.
- [ ] `systemctl is-active samba-ad-dc` → `active`.
- [ ] `/etc/resolv.conf` → `nameserver 127.0.0.1` *(la línea `search` es normal)*.
- [ ] `lsattr /etc/resolv.conf` → aparece la **`i`**.
- [ ] Si trabajas por SSH: `hostname` confirma que estás **en el servidor**.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!danger] 🛑 AQUÍ NO HAS TERMINADO LA FASE. Y esta vez importa de verdad
> El script ha acabado, el servicio está activo y el DNS apunta a sí mismo. **Y aun así el trabajo puede estar mal hecho sin que nada te avise.**
>
> Tu servidor tiene **dos tarjetas**. Si el dominio se ha anunciado en la del NAT (`10.0.2.x`) en lugar de en la `10.10.10.10`, todo lo que acabas de comprobar **seguiría saliendo igual de bien**: `active`, `127.0.0.1`, recuadro verde. Y en la **Fase 8**, dentro de tres semanas, el cliente Windows dirá *"No se encuentra el dominio"* sin mencionar ni las tarjetas, ni el DNS, ni esta fase.
>
> Esa comprobación **no está en este apartado**: está en el [[Fase_4.8.a_Verificacion|apartado 8.a]], que es de obligado cumplimiento y son diez minutos.
>
> **Si tomas la instantánea ahora, guardas el fallo dentro de tu punto de retorno** — y cada vez que restaures, volverá.
>
> **Orden correcto:** [[Fase_4.8.a_Verificacion|8.a · verificar]] → [[Fase_4.8.b_Punto_de_Control|8.b · guardar la instantánea]]. Nunca al revés.

> ¿Algo no ha salido? → [[Fase_4.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio (casos `E1` a `E11`), no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.5_Fundamento_Teorico]] | [[Fase_4]] | [[Fase_4.7_Resolucion_Problemas]] |
