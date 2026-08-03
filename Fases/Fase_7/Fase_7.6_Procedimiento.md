## Fase 7 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-7-seguridad-avanzada-acls-y-abe.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
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

> [!example] Paso 3: Aplicar los Cambios (Reinicio de Samba)
> Cada vez que se modifica el `smb.conf`, es obligatorio reiniciar el servicio para que los cambios surtan efecto:
> ```bash
> sudo systemctl restart samba-ad-dc
> ```
> Comprueba que el servicio ha arrancado correctamente:
> ```bash
> sudo systemctl status samba-ad-dc
> ```
> Busca la línea `Active: active (running)`. Si ves `failed`, revisa que no hay errores de sintaxis en el `smb.conf`.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.5_Fundamento_Teorico]] | [[Fase_7]] | [[Fase_7.7_Resolucion_Problemas]] |
