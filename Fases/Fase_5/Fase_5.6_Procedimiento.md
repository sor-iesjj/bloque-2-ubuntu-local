## Fase 5 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-5-gestion-de-identidades-usuarios-y-grupos.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Configuración del Traductor (nsswitch.conf)
> Antes de crear usuarios, debemos decirle a Linux que "pregunte también a Winbind" cuando alguien busque un usuario o un grupo. Sin este paso, el servidor no reconocerá a los usuarios del dominio aunque existan:
> ```bash
> sudo nano /etc/nsswitch.conf
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Busca las líneas que empiezan por `passwd:` y `group:` y añade la palabra `winbind` al final de cada una, dejándolas así:
> ```
> passwd:         files systemd winbind
> group:          files systemd winbind
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!tip] 💡 ¿Qué hace este cambio?
> > El archivo `nsswitch.conf` es la "guía de consulta" de Linux. Le dice dónde buscar cuando alguien pregunta "¿quién es el usuario X?". Al añadir `winbind`, le estamos diciendo: "Si no lo encuentras en los archivos locales, pregúntale a Winbind, que conoce a todos los usuarios del dominio Windows".

> [!example] Paso 2: Creación de Grupos y sus Atributos Unix
> Creamos los dos grupos del proyecto. El grupo `policia` tendrá acceso a las carpetas protegidas y `bomberos` servirá para demostrar que los usuarios sin permisos no ven esas carpetas:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis de `samba-tool` al crear grupos y usuarios, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Creamos el grupo "policia" en el dominio
> sudo samba-tool group add policia
> # Le asignamos un GID (Group ID) de Linux
> sudo samba-tool group addunixattrs policia 3001
>
> # Creamos el grupo "bomberos" en el dominio
> sudo samba-tool group add bomberos
> # Le asignamos un GID diferente
> sudo samba-tool group addunixattrs bomberos 3002
> ```
>
> > [!tip] 💡 ¿Qué hace el comando `addunixattrs`?
> > - **`group addunixattrs`:** Es el comando que "traduce" el grupo de Windows al mundo Linux, dándole un número de identidad (GID) que el sistema de archivos puede entender. Sin este número, Linux simplemente ignoraría al grupo.

> [!example] Paso 3: Creación de Usuarios con Mapeo Correcto
> Creamos dos usuarios: `user1` pertenecerá al grupo `policia` y `user2` al grupo `bomberos`. Esto nos permitirá demostrar en la Fase 7 que cada uno ve carpetas diferentes:
> ```bash
> # Creamos user1 asignando su UID y el GID del grupo policia
> sudo samba-tool user create user1 'P@ssw0rd' --uid-number=10001 --gid-number=3001
>
> # Creamos user2 asignando su UID y el GID del grupo bomberos
> sudo samba-tool user create user2 'P@ssw0rd' --uid-number=10002 --gid-number=3002
>
> # Añadimos cada usuario a su grupo correspondiente
> sudo samba-tool group addmembers policia user1
> sudo samba-tool group addmembers bomberos user2
> ```
>
> > [!important] 💡 ¿Por qué usar `--uid-number`?
> > **Corrección Crítica:** Usar `--uid-number` asegura que el mapeo entre el usuario de Active Directory y el usuario de Linux sea exacto y permanente. Sin este parámetro, el sistema podría asignar IDs aleatorios y perderíamos el control de los permisos.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.5_Fundamento_Teorico]] | [[Fase_5]] | [[Fase_5.7_Resolucion_Problemas]] |
