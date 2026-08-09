## Fase 6 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!abstract] 🏢 Hoy le das sitio a la empresa
> En la Fase 5 diste de alta a los doce trabajadores de **Boochan S.L.** Hoy les creas **dónde guardar su trabajo**: una carpeta por departamento, más una común para intercambiar ficheros.
>
> **Ten abierta la ficha del escenario:** [[Escenario_Boochan_SL]].

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> 1. **Abre la entrada de apuntes** que llevas escribiendo desde el índice (`b2-6-almacenamiento-virtual.md`). Repasa lo que tienes: la teoría del apartado 5 la vas a necesitar ahora.
> 2. **Léete los 7 pasos** del procedimiento enteros.
> 3. **Comprueba que tienes sitio:** `df -h /` debe mostrar **al menos 11 GB libres**.
> 4. Ten **OBS** listo y comprueba **pantalla y micrófono**.

---

> [!info] 🗺️ Lo que vas a montar, de un vistazo
> ```
> /srv/samba/
> ├── departamentos/      ← disco virtual de 8 GB   (/samba_deptos.img)
> │   ├── facturacion/    root:facturacion   2770
> │   ├── contabilidad/   root:contabilidad  2770
> │   ├── comercial/      root:comercial     2770
> │   ├── logistica/      root:logistica     2770
> │   ├── rrhh/           root:rrhh          2770
> │   └── becarios/       root:becarios      2770
> └── comun/              ← disco virtual de 2 GB   (/samba_comun.img)
>                           root:root          1777
> ```
>
> > [!question] 🤔 ¿Por qué dos discos y no siete?
> > Porque **siete discos de 5 GB serían 35 GB** y tu servidor tiene 20. Pero además, porque no haría falta: los seis departamentos pueden compartir un volumen.
> >
> > **Lo que sí tiene sentido es separar la carpeta común**, y el motivo es puro oficio: una carpeta donde todo el mundo escribe **se convierte en un vertedero**. Con su propio disco de 2 GB, cuando se llene **solo se llena ella** — y contabilidad sigue trabajando.
> >
> > **Aislar lo que se puede descontrolar** es una decisión de diseño, no una limitación.

---

> [!example] Paso 1: Los puntos de montaje
> ```bash
> sudo mkdir -p /srv/samba/departamentos
> sudo mkdir -p /srv/samba/comun
> ls -la /srv/samba/
> ```
>
> > [!tip] 💡 ¿Qué hace `-p`?
> > Crea **todas las carpetas del camino** que no existan. Sin `-p`, `mkdir` daría error porque `/srv/samba/` todavía no existe.

---

> [!example] Paso 2: Los dos discos virtuales
> > [!info] 📚 Diccionario de Comandos: cómo funciona `dd` creando discos virtuales, en el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Disco de los departamentos: 8 GB
> sudo dd if=/dev/zero of=/samba_deptos.img bs=1M count=8192 status=progress
>
> # Disco de la carpeta común: 2 GB
> sudo dd if=/dev/zero of=/samba_comun.img bs=1M count=2048 status=progress
> ```
> El primero tarda **2-3 minutos**; el segundo, menos de uno.
>
> > [!caution] ⚠️ Comprueba el espacio ANTES de lanzarlo
> > Estos dos ficheros ocupan **10 GB dentro del disco virtual de tu VM**. Si no caben, `dd` fallará a mitad de escritura dejando un fichero incompleto:
> > ```bash
> > df -h /
> > ```
> > Necesitas **al menos 11 GB libres** → si no, [[Fase_6.7_Resolucion_Problemas#E4 · dd falla por falta de espacio|caso E4]].
>
> > [!tip] 💡 ¿Qué hace cada parte?
> > - **`if=/dev/zero`:** el origen es un generador infinito de ceros.
> > - **`of=/samba_deptos.img`:** el fichero que será nuestro disco.
> > - **`bs=1M count=8192`:** 8192 bloques de 1 MB = **8 GB exactos**.
> > - **`status=progress`:** enseña el avance. Sin esto, `dd` no dice nada en tres minutos y parece colgado.

---

> [!example] Paso 3: Darles formato
> Un fichero de ceros no es un disco todavía: hay que crear dentro un **sistema de ficheros**.
> ```bash
> sudo mkfs.ext4 /samba_deptos.img
> sudo mkfs.ext4 /samba_comun.img
> ```
>
> > [!info] 🎓 Un disco pasa por tres estados y no se salta ninguno
> > **Existir** (`dd`) → **tener formato** (`mkfs`) → **estar montado** (`mount`).
> >
> > Es exactamente lo mismo que harías con un disco duro nuevo: particionar, formatear y asignarle una letra o un punto de montaje. **Aquí lo haces a mano, y por eso lo entiendes.**

---

> [!example] Paso 4: Montaje persistente (fstab)
> ```bash
> sudo nano /etc/fstab
> ```
>
> > [!info] 📚 Recurso: si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
>
> Añade estas **dos líneas al final** del fichero, sin borrar nada de lo que ya hay:
> ```
> /samba_deptos.img  /srv/samba/departamentos  ext4  loop,defaults  0  0
> /samba_comun.img   /srv/samba/comun          ext4  loop,defaults  0  0
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`). Avisa a systemd de que el fichero ha cambiado y monta:
> ```bash
> sudo systemctl daemon-reload
> sudo mount -a
> df -h | grep srv
> ```
>
> > [!tip] 💡 ¿Y ese `daemon-reload` para qué es?
> > `systemd` **se fabrica sus propias unidades a partir de `/etc/fstab`** y las tiene guardadas en memoria. Al editar el fichero, su copia se queda vieja.
> >
> > Si te lo saltas, `mount -a` funcionará igual pero te soltará este aviso:
> > ```
> > mount: (hint) your fstab has been modified, but systemd still uses
> >        the old version; use 'systemctl daemon-reload' to reload.
> > ```
> > **Fíjate en la palabra `(hint)`: es una sugerencia, no un error.** El montaje ha funcionado. Pero refrescarlo es lo que hace un administrador.
>
> > [!caution] ⚠️ La palabra `loop` es obligatoria
> > Sin ella, Linux intenta tratar el fichero como una **partición física real** y el arranque puede quedarse colgado. Compruébalo dos veces antes de seguir.
>
> > [!important] 🪂 EL PARACAÍDAS: `sudo mount -a`
> > Este comando **ensaya el arranque sin arrancar**: lee el `fstab` entero e intenta montar todo lo que dice.
> >
> > - **Silencio absoluto** = tu sintaxis es correcta.
> > - **Un aviso que empieza por `mount: (hint)`** = no es un fallo. Lee el punto de arriba: te falta el `daemon-reload`.
> > - **Un ERROR de montaje** —`wrong fs type`, `can't find`, `unknown filesystem`— = tienes un fallo. **BAJO NINGÚN CONCEPTO REINICIES** hasta arreglarlo, o la máquina se quedará en modo emergencia → [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]].
> >
> > **Y la comprobación que zanja la duda es el `df`:** si los dos volúmenes aparecen montados, el `fstab` ha funcionado.
> >
> > **`/etc/fstab` es de los poquísimos ficheros de Linux donde una errata impide arrancar el sistema.** Por eso existe este ensayo, y por eso se hace siempre.

---

> [!example] Paso 5: Las seis carpetas de departamento
> Cada departamento tiene su carpeta, propiedad de **su grupo**. Empieza por las dos primeras **a mano**:
> ```bash
> sudo mkdir -p /srv/samba/departamentos/facturacion
> sudo chown root:facturacion /srv/samba/departamentos/facturacion
> sudo chmod 2770 /srv/samba/departamentos/facturacion
> ls -ld /srv/samba/departamentos/facturacion
>
> sudo mkdir -p /srv/samba/departamentos/contabilidad
> sudo chown root:contabilidad /srv/samba/departamentos/contabilidad
> sudo chmod 2770 /srv/samba/departamentos/contabilidad
> ls -ld /srv/samba/departamentos/contabilidad
> ```
>
> > [!danger] 🛑 Mira el `ls -ld` DESPUÉS de cada `chown`. No es opcional
> > La columna del grupo tiene que decir **`facturacion`**, no `root`.
> >
> > Si el dominio no estaba levantado, el `chown` falla con `invalid group` — **o peor, la carpeta se queda a nombre de `root` y todo parece correcto**. Ese es el fallo silencioso de esta fase → [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento|caso E6]].
> >
> > **Que un comando no proteste no significa que hiciera lo que querías.**
>
> **Y ahora las cuatro que faltan, con un bucle:**
> ```bash
> for d in comercial logistica rrhh becarios; do
>     echo ">>> Creando carpeta de $d"
>     sudo mkdir -p "/srv/samba/departamentos/$d"
>     sudo chown "root:$d" "/srv/samba/departamentos/$d"
>     sudo chmod 2770 "/srv/samba/departamentos/$d"
> done
> ls -ld /srv/samba/departamentos/*
> ```
>
> > [!important] 📖 Comprueba las seis de golpe
> > ```bash
> > stat -c '%n  %U:%G  %a' /srv/samba/departamentos/*
> > ```
> > Las seis tienen que decir **`root:<su grupo>  2770`**. Si alguna dice `root:root`, el `chown` no funcionó.
>
> > [!tip] 💡 ¿Qué es el `2770`?
> > - **`2`** → el **bit setgid**: todo lo que se cree dentro **hereda el grupo de la carpeta**, en vez del grupo personal de quien lo crea. Sin él, una carpeta "de facturación" se llena de ficheros que el resto de facturación no puede tocar.
> > - **`770`** → dueño y grupo con acceso total; **el resto del mundo, nada**.
> >
> > Fíjate en que `ls -ld` muestra una **`s`** donde iría la `x` del grupo: `drwxrws---`. **Esa `s` es el setgid**, y saber leerla es parte del trabajo.

---

> [!example] Paso 6: La carpeta común, con sticky bit
> Esta es distinta: **todos escriben en ella**, pero cada uno solo puede borrar **lo suyo**.
> ```bash
> sudo chown root:root /srv/samba/comun
> sudo chmod 1777 /srv/samba/comun
> ls -ld /srv/samba/comun
> ```
>
> - **✅ Bien:** `ls -ld` muestra **`drwxrwxrwt`** — fíjate en la **`t`** del final.
>
> > [!info] 🎓 El sticky bit: el `1` de `1777`
> > Con permisos `777` normales, **cualquiera puede borrar el fichero de cualquiera**. En una carpeta compartida entre seis departamentos, eso es una bomba: alguien borra por error el trabajo de otro y no hay forma de saber quién fue.
> >
> > El **sticky bit** cambia una sola regla: **dentro de esta carpeta, solo puedes borrar lo que es tuyo** (o si eres `root`). Puedes crear, puedes leer lo de los demás, y no puedes destruirlo.
> >
> > **Es exactamente el mecanismo de `/tmp`**, que lleva décadas funcionando así por el mismo motivo. Compruébalo:
> > ```bash
> > ls -ld /tmp
> > ```
> > Verás la misma `t`.
>
> > [!question] 🤔 Para tu entrada de apuntes
> > El setgid del Paso 5 y el sticky bit de este paso **son los dos el cuarto dígito** de los permisos. ¿Qué hace cada uno? ¿Por qué la carpeta común lleva `t` y las de departamento llevan `s`?

---

> [!example] Paso 7: El primer latido — ¿está todo en su sitio?
> Esto **no es la verificación de la fase**: es el pulso mínimo.
> ```bash
> df -h | grep srv
> stat -c '%n  %U:%G  %a' /srv/samba/departamentos/* /srv/samba/comun
> ```
>
> | Qué tiene que salir | Si no sale |
> | :--- | :--- |
> | Dos líneas en `df`: **8,0G** y **2,0G** | [[Fase_6.7_Resolucion_Problemas#E2 · df -h no muestra los discos\|caso E2]] |
> | Seis carpetas **`root:<su grupo>  2770`** | [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento\|caso E6]] |
> | `comun` con **`root:root  1777`** | Repite el Paso 6 |
>
> > [!bug] 🛑 ¿Estás seguro de que esto lo ha contestado el SERVIDOR?
> > Si administras por SSH: `hostname` tiene que responder `UbuntuServer` → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

---

### ✅ Checklist de esta parte

- [ ] Los dos puntos de montaje creados.
- [ ] `/samba_deptos.img` de **8 GB** y `/samba_comun.img` de **2 GB**, los dos formateados en `ext4`.
- [ ] Las **dos líneas** del `/etc/fstab`, **con la palabra `loop`**.
- [ ] 🛑 `sudo mount -a` ejecutado y **en silencio**.
- [ ] `df -h` muestra los dos volúmenes montados.
- [ ] Las **seis carpetas** de departamento con **`root:<su grupo>` y `2770`**, verificado con `stat`.
- [ ] La **`s`** visible en `ls -ld` de las seis.
- [ ] `comun` con **`root:root` y `1777`**, y la **`t`** visible.
- [ ] 🛑 **Instantánea NO tomada. Y NO has reiniciado.**

---

> [!danger] 🛑 AQUÍ NO HAS TERMINADO LA FASE. Y el riesgo es el arranque
> Los discos están montados y las carpetas tienen permisos. **Y aun así puede haber dos problemas que no ves:**
>
> 1. **Un `fstab` con una errata.** No lo notarás hasta que la máquina no arranque — y no eliges tú cuándo se reinicia.
> 2. **Una carpeta a nombre de `root`** en vez de su departamento. No da ningún error y **tumba la Fase 7**.
>
> Se comprueban en el [[Fase_6.8.a_Verificacion|apartado 8.a]], que es de obligado cumplimiento.
>
> **No apagues ni reinicies antes de pasar por ahí.**
>
> **Orden correcto:** [[Fase_6.8.a_Verificacion|8.a · verificar]] → [[Fase_6.8.b_Punto_de_Control|8.b · guardar]]. Nunca al revés.

> ¿Algo no ha salido? → [[Fase_6.7_Resolucion_Problemas]] — **búscate por el síntoma** (casos `E1` a `E8`).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.5_Fundamento_Teorico]] | [[Fase_6]] | [[Fase_6.7_Resolucion_Problemas]] |
