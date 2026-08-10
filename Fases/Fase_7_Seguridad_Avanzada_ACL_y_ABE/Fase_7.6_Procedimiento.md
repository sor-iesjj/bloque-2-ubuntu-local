## Fase 7 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!abstract] 🏢 Hoy se aplica la política de la empresa
> Tienes doce trabajadores (Fase 5) y siete carpetas (Fase 6). **Hoy decides quién entra dónde**, y hasta qué punto.
>
> **La matriz de permisos está en [[Escenario_Boochan_SL]] y no te la inventas tú.** Ténla abierta durante toda la fase.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> 1. **Abre la entrada de apuntes** que llevas escribiendo desde el índice (`b2-7-seguridad-avanzada.md`). Repasa las **seis preguntas del apartado 5**: si no las tienes contestadas, vuelve — la máscara la vas a ver hoy en pantalla.
> 2. **Léete los 7 pasos** del procedimiento enteros.
> 3. **Lee la matriz de permisos** y su justificación en [[Escenario_Boochan_SL]]. Si no sabes **por qué** comercial no escribe en facturación, no sabes qué estás haciendo.
> 4. Ten **OBS** listo y comprueba **pantalla y micrófono**.

---

> [!info] 🗺️ La matriz que vas a aplicar
> | Grupo ↓ · Carpeta → | factur. | contab. | comerc. | logíst. | rrhh | becarios | comun |
> | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
> | **facturacion** | **RW** | — | R | — | — | — | RW* |
> | **contabilidad** | **RW** | **RW** | R | R | — | — | RW* |
> | **comercial** | R | — | **RW** | R | — | — | RW* |
> | **logistica** | — | — | R | **RW** | — | — | RW* |
> | **rrhh** | — | — | — | — | **RW** | R | RW* |
> | **becarios** | — | — | — | — | — | **R** | — |
>
> **RW** = leer y escribir · R = solo lectura · — = sin acceso *(y sin verla)* · RW* = escribir, pero solo borrar lo suyo
>
> > [!warning] ⚠️ El acceso **RW** de cada grupo a su propia carpeta ya lo diste en la Fase 6
> > Con el `chown root:<grupo>` y el `chmod 2770`. **Lo que añades hoy son los cruces**: los permisos que un departamento tiene sobre la carpeta **de otro**.
> >
> > Y eso los permisos clásicos de Unix **no lo pueden hacer**: solo admiten **un** dueño y **un** grupo. Para dar acceso a un segundo grupo hace falta una **ACL**.

---

> [!example] Paso 1: Comprueba que puedes usar ACL
> ```bash
> sudo apt install -y acl
> getfacl -p /srv/samba/departamentos/facturacion
> ```
>
> - **✅ Bien:** devuelve las líneas `user::`, `group::` y `other::`.
> - **❌ Mal:** `Operation not supported` → [[Fase_7.7_Resolucion_Problemas#E2 · setfacl: Operation not supported|caso E2]].
>
> > [!info] 🎓 Lo que ves ahora son los permisos clásicos, traducidos
> > `getfacl` enseña `rwx` para el dueño, `rwx` para el grupo y `---` para el resto. **Es lo mismo que el `2770` de la Fase 6**, contado de otra forma.
> >
> > A partir del siguiente paso vas a añadir **líneas nuevas**: grupos adicionales que los permisos clásicos no podrían representar.

---

> [!example] Paso 2: Los permisos cruzados de LECTURA
> Empieza por el más importante de la matriz, y hazlo **a mano** entendiendo cada parte: **comercial puede leer facturación**.
> ```bash
> sudo setfacl -m g:comercial:rx /srv/samba/departamentos/facturacion
> sudo setfacl -d -m g:comercial:rx /srv/samba/departamentos/facturacion
> getfacl -p /srv/samba/departamentos/facturacion
> ```
>
> > [!tip] 💡 Qué dice cada trozo
> > - **`-m`** → *modify*: añade o cambia una entrada de la lista.
> > - **`g:comercial:rx`** → al **grupo** `comercial`, permiso de **leer** (`r`) y **entrar** en la carpeta (`x`).
> > - **`-d`** → *default*: la misma regla **para lo que se cree a partir de ahora**. Sin esto, funciona con los ficheros de hoy y falla con los de mañana.
> >
> > **Son dos comandos porque son dos cosas distintas:** el permiso de ahora y la herencia.
>
> > [!danger] 🛑 Fíjate en que NO lleva `w`
> > Un comercial necesita saber si su cliente ha pagado. **No puede tocar la factura.**
> >
> > Si pudiera, **el mismo que cobra la comisión podría modificar el importe facturado**. Eso no es un detalle técnico: es control interno, y es la regla más importante de la matriz.
>
> **Y ahora el resto de los permisos de lectura, con un bucle:**
> ```bash
> for regla in \
>   "contabilidad:comercial" \
>   "contabilidad:logistica" \
>   "comercial:logistica" \
>   "logistica:comercial" \
>   "facturacion:comercial" \
>   "rrhh:becarios" ; do
>     GRUPO="${regla%:*}"
>     CARPETA="${regla#*:}"
>     echo ">>> $GRUPO podrá LEER la carpeta de $CARPETA"
>     sudo setfacl    -m g:"$GRUPO":rx "/srv/samba/departamentos/$CARPETA"
>     sudo setfacl -d -m g:"$GRUPO":rx "/srv/samba/departamentos/$CARPETA"
> done
> ```
>
> > [!important] 📖 Antes de ejecutarlo, léelo y compáralo con la matriz
> > Cada línea es **`grupo_que_accede:carpeta_a_la_que_accede`**. Ve una por una contra la tabla de arriba y confirma que **cada par está en una casilla con `R`**.
> >
> > En el vídeo tienes que poder decir por qué está `rrhh:becarios` y **por qué NO está `contabilidad:rrhh`**.

---

> [!example] Paso 3: El permiso cruzado de ESCRITURA
> Solo hay uno en toda la matriz: **contabilidad escribe en facturación**.
> ```bash
> sudo setfacl    -m g:contabilidad:rwx /srv/samba/departamentos/facturacion
> sudo setfacl -d -m g:contabilidad:rwx /srv/samba/departamentos/facturacion
> getfacl -p /srv/samba/departamentos/facturacion
> ```
>
> - **✅ Bien:** ahora la carpeta de facturación tiene **tres grupos** en su lista: el suyo, `comercial` con `r-x` y `contabilidad` con `rwx`.
>
> > [!info] 🎓 Esto es lo que los permisos clásicos no podían hacer
> > Una carpeta, **tres grupos distintos con tres niveles distintos**. Con `chown` y `chmod` solo tendrías un dueño y un grupo: o dabas acceso a todos o a ninguno.
> >
> > **Para eso existen las ACL**, y por eso esta fase va después de la 6 y no antes.
>
> > [!question] 🤔 ¿Por qué contabilidad sí escribe y comercial no?
> > Son el **mismo circuito de dinero**: contabilidad corrige, ajusta y cierra lo que facturación emite. Comercial solo consulta.
> >
> > Anótalo en tu entrada. Es la diferencia entre *"dar permisos"* y **decidir una política**.

> [!example] Paso 3.b: 🔴 Quitar la escritura a los becarios
> Mira la matriz otra vez. Los becarios tienen **`R`** sobre su propia carpeta, **no `RW`**. Son los únicos.
>
> Y ahora mira lo que les dejó la Fase 6. **Los dos comandos dicen lo mismo de dos formas distintas:**
> ```bash
> ls -ld /srv/samba/departamentos/becarios      # forma simbólica
> stat -c '%a  %n' /srv/samba/departamentos/becarios   # forma numérica
> ```
> ```
> drwxrws--- 2 root BOOCHANLAB\becarios 4096 ... /srv/samba/departamentos/becarios
> 2770  /srv/samba/departamentos/becarios
> ```
>
> > [!warning] ⚠️ `ls -ld` NO te da el número. Te da las letras
> > Es un despiste clásico: **`ls` nunca enseña `2770`**. Enseña `drwxrws---`. El número lo da **`stat -c %a`**.
> >
> > Y hay que saber pasar de una forma a la otra, porque **el material y los comandos usan las dos**: `chmod` habla en números, `ls` contesta en letras.
> >
> > | | | |
> > | :--- | :--- | :--- |
> > | `d` | tipo | `d` = directorio |
> > | `rwx` | **dueño** | 4+2+1 = **7** |
> > | `rws` | **grupo** | 4+2+1 = **7**, y la `s` es el **setgid** → el `2` de delante |
> > | `---` | otros | **0** |
> >
> > **`drwxrws---` = `2770`.** Misma información, dos idiomas.
>
> El grupo tiene **`rws`**, o sea `rwx` más el setgid: **pueden escribir y borrar.** Hay que quitarles la `w`:
> ```bash
> sudo chmod 2750 /srv/samba/departamentos/becarios
> ls -ld /srv/samba/departamentos/becarios
> stat -c '%a  %n' /srv/samba/departamentos/becarios
> ```
> - **✅ Bien:** ahora se lee **`drwxr-s---`** y `stat` dice **`2750`**.
>
> > [!tip] 💡 Fíjate en qué letra ha cambiado, que es una sola
> > ```
> > antes:  drwx rws ---     2770
> > ahora:  drwx r-s ---     2750
> >              ↑
> >              la 'w' del grupo se ha ido
> > ```
> > **El `7` del medio ha pasado a `5`.** Y la `s` sigue ahí: el setgid no se toca, solo la escritura.
>
> > [!danger] 🛑 Este paso es fácil de saltarse, y se nota en la Fase 8
> > La Fase 6 creó las siete carpetas **iguales**, porque allí todavía no había política. Hoy aplicas la política, y **la carpeta de becarios es la única excepción de toda la matriz**.
> >
> > Si no lo haces, en la Fase 8 `shinnosuke.nohara` **podrá borrar ficheros de su carpeta** — y la prueba de *"los becarios no tocan nada"* fallará.
>
> > [!question] 🤔 ¿Y por qué a un becario se le da solo lectura?
> > Porque llega la semana que viene, se va en tres meses y **nadie le ha enseñado todavía qué es importante**. Puede consultar, aprender y trabajar sobre copias; no puede destruir el material del que aprende.
> >
> > No es desconfianza: es **mínimo privilegio**. El mismo criterio por el que contabilidad no entra en RRHH.

---

> [!example] Paso 4: 🔴 Comprueba la MÁSCARA antes de seguir
> ```bash
> getfacl -p /srv/samba/departamentos/facturacion
> ```
>
> Mira las líneas de grupo y **lee hasta el final de cada una**:
>
> | Lo que quieres ver | Lo que NO quieres ver |
> | :--- | :--- |
> | `group:comercial:r-x` | `group:comercial:r-x		#effective:r--` |
>
> - **❌ Si aparece `#effective`**, la máscara está recortando el permiso → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]]:
>   ```bash
>   sudo setfacl -m m::rwx /srv/samba/departamentos/facturacion
>   ```
>
> > [!danger] 🛑 Esta es la trampa más fina de toda la fase
> > `group:comercial:r-x   #effective:r--` **pone `r-x` y significa `r--`**. El permiso está escrito, es correcto, y **no se aplica**.
> >
> > La máscara es un techo general: ningún grupo de la lista puede superarla, por mucho que figure. Y **el permiso sigue apareciendo**, así que si lees la ACL con prisa ves lo que esperabas ver.
> >
> > **Lo que está escrito y lo que se aplica pueden ser cosas distintas.** El sistema te lo está diciendo, en una columna que casi nadie mira.

---

> [!example] Paso 5: Publicar las siete carpetas en Samba
> Para que Windows las vea, cada carpeta tiene que declararse como **recurso compartido**.
>
> Comprueba primero que no existan ya:
> ```bash
> sudo grep -n "^\[" /etc/samba/smb.conf
> ```
> Si aparecen secciones de departamentos, **no las dupliques**: edítalas → [[Fase_7.7_Resolucion_Problemas#E7 · Secciones duplicadas en smb.conf|caso E7]].
>
> ```bash
> sudo nano /etc/samba/smb.conf
> ```
>
> Añade **al final** estos bloques:
> ```ini
> [facturacion]
>     path = /srv/samba/departamentos/facturacion
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [contabilidad]
>     path = /srv/samba/departamentos/contabilidad
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [comercial]
>     path = /srv/samba/departamentos/comercial
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [logistica]
>     path = /srv/samba/departamentos/logistica
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [rrhh]
>     path = /srv/samba/departamentos/rrhh
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [becarios]
>     path = /srv/samba/departamentos/becarios
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
>
> [comun]
>     path = /srv/samba/comun
>     read only = no
>     vfs objects = acl_xattr
>     valid users = @facturacion,@contabilidad,@comercial,@logistica,@rrhh
>     access based share enum = yes
>     hide unreadable = yes
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!tip] 💡 Qué hace cada opción, y por qué `comun` es distinta
> > | Opción | Para qué |
> > | :--- | :--- |
> > | `vfs objects = acl_xattr` | Guarda los permisos de Windows dentro del sistema de ficheros de Linux. **Sin esto, Windows machaca tus ACL al copiar** |
> > | `access based share enum = yes` | **El recurso no aparece siquiera** en el listado de red de quien no tiene acceso |
> > | `hide unreadable = yes` | Oculta el contenido interno que no se puede abrir |
> >
> > | `valid users = @grupo,…` | **Quién puede conectar al recurso.** Es una puerta *antes* de los permisos del sistema de ficheros: si no estás en la lista, Samba no te deja ni llamar |
> >
> > **`comun` es la única que lleva `valid users`, y ahí está la lección de la fase.**
> >
> > Mira la matriz: **los becarios no tienen `comun`.** Pero la carpeta está en `1777` —escritura para todos— porque necesita el *sticky bit* para que nadie borre lo de otro. Con esos permisos, un becario **entraría**.
> >
> > Los permisos del sistema de ficheros no te sirven aquí: si le quitas el `rwx` a *otros*, rompes el `1777` que necesitas. **La solución está en otra capa:** Samba decide quién conecta *antes* de que el sistema de ficheros diga nada.
> >
> > **Dos candados en serie, y basta con que falle uno para que no se entre.** Esa es la idea que te llevas de la Fase 7.

---

> [!example] Paso 6: VALIDAR y aplicar
> **Primero se valida. Después se reinicia. Nunca al revés.**
> ```bash
> sudo testparm
> ```
> *(Pulsa `Enter` cuando pregunte.)*
>
> - **✅ Bien:** `Loaded services file OK` y te muestra la configuración interpretada.
> - **❌ Mal:** te dice **la línea exacta** del error → [[Fase_7.7_Resolucion_Problemas#E1 · samba-ad-dc no arranca tras editar el smb.conf|caso E1]].
>
> > [!danger] 🛑 Aquí reiniciar a ciegas no te tumba las carpetas: te tumba el DOMINIO
> > `samba-ad-dc` **es el controlador de dominio**. Si no arranca por una errata, se lleva por delante el **DNS**, **Kerberos** y **LDAP**. El servidor seguirá encendido y el dominio habrá dejado de existir.
> >
> > **`testparm` es a `smb.conf` lo que `sudo mount -a` era al `fstab` en la Fase 6.** Mismo reflejo, otro servicio.
>
> Y ahora sí:
> ```bash
> sudo systemctl restart samba-ad-dc
> systemctl is-active samba-ad-dc
> ```
>
> Comprueba que el dominio ha vuelto **entero**, no solo que el servicio arrancó:
> ```bash
> host -t A ubuntuserver.boochanlab.local 127.0.0.1
> id hiroshi.nohara
> ```
>
> > [!bug] 🛑 ¿Estás seguro de que esto lo ha contestado el SERVIDOR?
> > Si administras por SSH: `hostname` tiene que responder `UbuntuServer` → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

---

### ✅ Checklist de esta parte

- [ ] Paquete `acl` instalado y `getfacl` funcionando.
- [ ] **Permiso de lectura cruzado** aplicado en las **siete** casillas `R` de la matriz, **con su `-d`**.
- [ ] **Permiso de escritura cruzado** (`contabilidad` → `facturacion`) aplicado, **con su `-d`**.
- [ ] 🔴 Carpeta de **becarios bajada a `2750`**: su grupo con `r-x`, sin `w`.
- [ ] 🔴 `getfacl` sin ningún **`#effective`** en las carpetas tocadas.
- [ ] Las **siete secciones** añadidas al `smb.conf`, **una sola vez cada una**.
- [ ] Las seis de departamento con `acl_xattr`, `access based share enum` y `hide unreadable`.
- [ ] 🛑 `sudo testparm` → **`Loaded services file OK`**, ejecutado **antes** del reinicio.
- [ ] `samba-ad-dc` en `active`, y el dominio responde al `host` y al `id`.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!danger] 🛑 AQUÍ NO HAS TERMINADO. Y esta fase tiene una particularidad
> La política está aplicada. **Pero la mitad del trabajo no se puede comprobar desde el servidor.**
>
> Que una carpeta sea **invisible** para quien no tiene permiso solo se ve **desde el listado de red de un cliente Windows** — y eso es la Fase 8. Desde Ubuntu, una carpeta bien protegida y una protegida a medias **se comportan exactamente igual**.
>
> El [[Fase_7.8.a_Verificacion|apartado 8.a]] comprueba lo que sí se puede comprobar aquí, y te deja **anotadas las pruebas pendientes** en vez de darlas por hechas.
>
> **Orden correcto:** [[Fase_7.8.a_Verificacion|8.a · verificar]] → [[Fase_7.8.b_Punto_de_Control|8.b · guardar]]. Nunca al revés.

> ¿Algo no ha salido? → [[Fase_7.7_Resolucion_Problemas]] — **búscate por el síntoma** (casos `E1` a `E8`).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.5_Fundamento_Teorico]] | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | [[Fase_7.7_Resolucion_Problemas]] |
