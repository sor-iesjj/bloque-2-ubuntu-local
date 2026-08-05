## Fase 4 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b2-f4-aprovisionamiento-del-dominio.md`) con su estructura, vacía.
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

> [!example] Paso 2: Verificación de Servicios
> Una vez finalizado el script, debemos comprobar que el "corazón" del dominio está latiendo:
> ```bash
> # Comprobar que el servicio está activo y corriendo
> sudo systemctl status samba-ad-dc
> ```

> [!example] Paso 3: Verificación del DNS
> Es vital confirmar que el servidor se mira a sí mismo para resolver nombres de red:
> ```bash
> # Debe devolver: nameserver 127.0.0.1
> cat /etc/resolv.conf
> ```

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.5_Fundamento_Teorico]] | [[Fase_4]] | [[Fase_4.7_Resolucion_Problemas]] |
