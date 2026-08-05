## Fase 7 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b2-f7-seguridad-avanzada.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Configuración de los Candados (ACLs)
> Aplicamos permisos granulares al grupo `policia` sobre la carpeta `prueba3` y configuramos la herencia para que todos los archivos nuevos los hereden:
>
> > [!info] 📚 Diccionario de Comandos: Para repasar los operadores exactos de `setfacl`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Aplicamos el permiso al grupo "policia"
> sudo setfacl -m g:policia:rwx /srv/samba/prueba3
>
> # Configuramos la HERENCIA para el futuro
> sudo setfacl -d -m g:policia:rwx /srv/samba/prueba3
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`-m`:** Significa "Modify". Estamos modificando la lista de permisos.
> > - **`g:policia:rwx`:** Le damos permisos de Lectura, Escritura y Ejecución (rwx) al **Grupo (g)** policia.
> > - **`-d`:** Significa "Default" (Herencia). Indica que cualquier archivo nuevo que se cree ahí dentro heredará este permiso automáticamente.

> [!example] Paso 2: Publicación de las Carpetas (smb.conf)
> Para que los usuarios puedan ver y acceder a las carpetas desde Windows, debemos declarar cada una como un "recurso compartido" en el archivo de configuración de Samba.
>
> Antes de editar, comprueba que el script de la Fase 4 no añadió ya estas secciones:
> ```bash
> sudo grep -n "prueba" /etc/samba/smb.conf
> ```
> Si el comando no devuelve nada, continúa. Si devuelve líneas con `[prueba1]` o `[prueba3]`, esas secciones ya existen: **no las añadas de nuevo**; en su lugar edítalas para completar los parámetros que falten.
>
> Abre el archivo de configuración:
> ```bash
> sudo nano /etc/samba/smb.conf
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Desplázate hasta el **final del archivo** (puedes usar `Ctrl + End` en nano) y añade estos dos bloques:
> ```ini
> [prueba1]
>     path = /srv/samba/prueba1
>     read only = no
>     vfs objects = acl_xattr
>
> [prueba3]
>     path = /srv/samba/prueba3
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!tip] 💡 ¿Qué diferencia hay entre `prueba1` y `prueba3`?
> > - **`prueba1`:** Es una carpeta de acceso general para todos los usuarios del dominio. No tiene ABE.
> > - **`prueba3`:** Es la carpeta protegida. Los parámetros `access based share enum = yes` y `hide unreadable = yes` activan la doble capa de invisibilidad: la primera oculta el recurso del listado de red a quien no tiene acceso, y la segunda oculta el contenido interno a quien logra verlo pero no tiene permiso sobre los archivos.

> [!example] Paso 3: VALIDAR antes de aplicar
> Cada vez que se modifica el `smb.conf` hay que reiniciar el servicio para que los cambios surtan efecto. **Pero antes se valida.**
>
> ```bash
> sudo testparm
> ```
> *(Pulsa `Enter` cuando pregunte.)*
>
> - **✅ Bien:** `Loaded services file OK` y te muestra la configuración interpretada.
> - **❌ Mal:** te dice **la línea exacta** del error. **No reinicies** hasta arreglarlo → [[Fase_7.7_Resolucion_Problemas#E1 · samba-ad-dc no arranca tras editar el smb.conf|caso E1]].
>
> > [!danger] 🛑 Aquí reiniciar a ciegas no te tumba las carpetas: te tumba el DOMINIO
> > `samba-ad-dc` **es el controlador de dominio**. Si no arranca por una errata, se lleva por delante el **DNS**, **Kerberos** y **LDAP**. El servidor seguirá encendido y el dominio habrá dejado de existir.
> >
> > **`testparm` es a `smb.conf` lo que `sudo mount -a` era al `fstab` en la Fase 6.** Mismo reflejo, otro servicio: se valida antes de reiniciar, no después de romper.

> [!example] Paso 4: Aplicar los cambios
> Y ahora sí, con la configuración validada:
> ```bash
> sudo systemctl restart samba-ad-dc
> systemctl is-active samba-ad-dc
> ```
> - **✅ Bien:** devuelve `active`.
>
> Comprueba que el dominio ha vuelto **entero**, no solo que el servicio arrancó:
> ```bash
> host -t A ubuntuserver.boochanlab.local 127.0.0.1
> id user1
> ```
> - **✅ Bien:** el `host` devuelve `10.10.10.10` e `id user1` sigue dando `uid=10001`.

> [!example] Paso 5: El primer latido — ¿la ACL dice lo que crees?
> Esto **no es la verificación de la fase**: es el pulso mínimo antes de seguir.
> ```bash
> getfacl -p /srv/samba/prueba3
> ```
>
> Busca estas dos líneas, **y mira que no lleven nada escrito a la derecha**:
> ```
> group:policia:rwx
> default:group:policia:rwx
> ```
>
> | Qué ves | Qué significa |
> | :--- | :--- |
> | Las dos líneas, limpias | Vas bien. Sigue al apartado 8.a |
> | Falta la línea `default:` | No hay herencia → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos\|caso E4]] |
> | Pone `#effective:r--` al final | **La máscara lo anula** → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica\|caso E6]] |
>
> > [!warning] ⚠️ Esa columna de la derecha es la trampa de la fase
> > `group:policia:rwx		#effective:r--` **pone `rwx` y significa `r--`**. El permiso está escrito, es correcto, y no se aplica. Si lees la ACL con prisa, ves lo que esperabas ver.

---

### ✅ Checklist de esta parte

- [ ] `setfacl -m g:policia:rwx` ejecutado sobre `/srv/samba/prueba3`.
- [ ] `setfacl -d -m g:policia:rwx` ejecutado *(la herencia, con la `-d`)*.
- [ ] Comprobado con `grep` que **no había ya** secciones `[prueba1]` / `[prueba3]` antes de añadirlas.
- [ ] Los dos bloques añadidos al final del `smb.conf`, **una sola vez cada uno**.
- [ ] `[prueba3]` con **`access based share enum`**, **`hide unreadable`** y **`acl_xattr`**.
- [ ] 🛑 `sudo testparm` → **`Loaded services file OK`**, ejecutado **antes** del reinicio.
- [ ] `samba-ad-dc` en `active`, y el dominio responde al `host` y al `id`.
- [ ] `getfacl` muestra las dos líneas **sin `#effective`**.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!danger] 🛑 AQUÍ NO HAS TERMINADO LA FASE. Y esta tiene una particularidad
> La configuración está puesta. **Pero la mitad del trabajo de esta fase no se puede comprobar desde el servidor.**
>
> Hacer **invisible** una carpeta para quien no tiene permiso solo se ve **desde el listado de red de un cliente Windows** — y eso es la Fase 8. Desde Ubuntu, una carpeta bien protegida y una carpeta protegida a medias **se comportan exactamente igual**.
>
> Lo que sí puedes comprobar aquí es que el servidor está correctamente configurado para ello, y el [[Fase_7.8.a_Verificacion|apartado 8.a]] te dice además **qué queda pendiente**, para que lo anotes en vez de darlo por hecho.
>
> **Orden correcto:** [[Fase_7.8.a_Verificacion|8.a · verificar]] → [[Fase_7.8.b_Punto_de_Control|8.b · guardar la instantánea]]. Nunca al revés.

> ¿Algo no ha salido? → [[Fase_7.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio (casos `E1` a `E8`), no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.5_Fundamento_Teorico]] | [[Fase_7]] | [[Fase_7.7_Resolucion_Problemas]] |
