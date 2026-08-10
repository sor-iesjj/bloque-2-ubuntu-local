## Fase 5 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!abstract] 🏢 A partir de aquí trabajas para una empresa
> Se acabó el `hiroshi.nohara` y el `misae.nohara`. Vas a dar de alta a **los doce trabajadores de Boochan S.L.**, repartidos en **seis departamentos**.
>
> **Ten abierta la ficha del escenario mientras trabajas:** [[Escenario_Boochan_SL]]. Ahí están los nombres, los UID y los GID exactos, y es la fuente de verdad de las fases 5 a 8.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> 1. **Abre la entrada de apuntes** que llevas escribiendo desde el índice (`b2-5-gestion-de-identidades.md`). Repasa lo que tienes: la teoría del apartado 5 la vas a necesitar ahora.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. **Lee [[Escenario_Boochan_SL]]** entero. Si no sabes quién es quién, no sabes qué estás haciendo.
> 4. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**.

---

> [!example] Paso 1: Configuración del Traductor (nsswitch.conf)
> Antes de crear a nadie, hay que decirle a Linux que **pregunte también a Winbind** cuando alguien busque un usuario o un grupo. Sin este paso, el servidor no reconocerá a los trabajadores del dominio aunque existan:
> ```bash
> sudo nano /etc/nsswitch.conf
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
>
> Busca las líneas que empiezan por `passwd:` y `group:` y añade la palabra `winbind` al final de cada una:
> ```
> passwd:         files systemd winbind
> group:          files systemd winbind
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> Y comprueba que el traductor **responde**:
> ```bash
> wbinfo -p
> ```
> - **✅ Bien:** `Ping to winbindd succeeded`.
>
> > [!danger] 🛑 NO arranques el servicio `winbind` de systemd
> > Si ejecutas `systemctl is-active winbind` te dirá **`inactive`**, y **eso es lo correcto**.
> >
> > En un **controlador de dominio**, `winbindd` va **dentro** del proceso `samba`: lo arranca `samba-ad-dc`. El servicio `winbind` de systemd es el del **Samba clásico**, el que apagaste en la Fase 4 junto a `smbd` y `nmbd`.
> >
> > Compruébalo tú mismo: el servicio está parado y `wbinfo -p` responde igual.
> > ```bash
> > systemctl is-active winbind   # inactive
> > wbinfo -p                      # Ping to winbindd succeeded
> > getent passwd hiroshi.nohara   # lo resuelve
> > ```
> >
> > **La comprobación correcta no es "¿está el servicio corriendo?", sino "¿responde el traductor?".** Un servicio parado que hace su trabajo por otra vía es exactamente el tipo de cosa que hay que saber leer.
>
> > [!tip] 💡 ¿Qué hace este cambio?
> > `nsswitch.conf` es la **guía de consulta** de Linux: le dice dónde buscar cuando alguien pregunta *"¿quién es este usuario?"*. Al añadir `winbind`, le estás diciendo: *"si no lo encuentras en los ficheros locales, pregúntale a Winbind, que conoce a todo el dominio"*.

---

> [!example] Paso 2: Los seis departamentos (grupos con GID)
> Cada departamento de la empresa es un **grupo del dominio**. Y cada grupo necesita un **número de Linux (GID)** para que el sistema de ficheros pueda usarlo en la Fase 7.
>
> > [!info] 📚 Diccionario de Comandos: la sintaxis de `samba-tool` está en el [[Diccionario_Comandos_Sistema]].
>
> **Empieza creando los dos primeros a mano**, entendiendo cada parte:
> ```bash
> # Departamento de Facturación
> sudo samba-tool group add facturacion
> sudo samba-tool group addunixattrs facturacion 3001
>
> # Departamento de Contabilidad
> sudo samba-tool group add contabilidad
> sudo samba-tool group addunixattrs contabilidad 3002
> ```
>
> > [!tip] 💡 Son DOS comandos porque son dos mundos
> > - **`group add`** crea el grupo en **Active Directory**. Windows ya lo ve.
> > - **`group addunixattrs`** le pone un **GID**, que es lo que entiende **Linux**.
> >
> > Sin el segundo, el grupo existe en el dominio y el sistema de ficheros no puede darle permisos. **Es un grupo invisible para la mitad de tu servidor.**
>
> **Y ahora los cuatro que faltan, con un bucle:**
> ```bash
> for g in comercial:3003 logistica:3004 rrhh:3005 becarios:3006; do
>     NOMBRE="${g%:*}"
>     GID="${g#*:}"
>     echo ">>> Creando grupo $NOMBRE con GID $GID"
>     sudo samba-tool group add "$NOMBRE"
>     sudo samba-tool group addunixattrs "$NOMBRE" "$GID"
> done
> ```
>
> > [!important] 📖 Antes de ejecutarlo, léelo. Y explícalo en el vídeo
> > Tienes que ser capaz de decir en voz alta:
> > 1. Qué contiene la variable `g` en cada vuelta.
> > 2. Qué hacen `${g%:*}` y `${g#*:}` *(pista: uno se queda con lo de antes de los dos puntos y el otro con lo de después).*
> > 3. **Por qué está el `echo`**: para que, si algo falla, sepas en qué vuelta iba.
> >
> > **Un bucle que no entiendes es un comando que no deberías ejecutar.** Es la misma norma del script de la Fase 4.
>
> > [!info] 🎓 Por qué los dos primeros a mano y el resto con bucle
> > Porque así es como se trabaja de verdad: **haces una vez a mano lo que vas a repetir**, compruebas que sale bien, y solo entonces lo automatizas.
> >
> > Automatizar antes de entender es la forma más rápida de crear seis grupos mal configurados en lugar de uno.
>
> **Comprueba los seis:**
> ```bash
> sudo samba-tool group list | sort
> for g in facturacion contabilidad comercial logistica rrhh becarios; do getent group "$g"; done
> ```
> - **✅ Bien:** los seis aparecen con sus GID `3001` a `3006`, en orden.

---

> [!example] Paso 3: Los doce trabajadores (usuarios con UID)
> Mismo método: **los dos primeros a mano**, el resto con un bucle.
>
> ```bash
> # Hiroshi Nohara - Facturación
> sudo samba-tool user create hiroshi.nohara 'P@ssw0rd' \
>      --uid-number=10001 --gid-number=3001 \
>      --given-name=Hiroshi --surname=Nohara
> sudo samba-tool group addmembers facturacion hiroshi.nohara
>
> # Nene Sakurada - Facturación
> sudo samba-tool user create nene.sakurada 'P@ssw0rd' \
>      --uid-number=10002 --gid-number=3001 \
>      --given-name=Nene --surname=Sakurada
> sudo samba-tool group addmembers facturacion nene.sakurada
> ```
>
> > [!danger] 🛑 `--uid-number` es el parámetro que decide si la Fase 7 funcionará
> > Sin él, el comando **se ejecuta igual de bien**: crea el usuario, no da ningún error y todo parece correcto. La diferencia es que **el número lo elige la máquina**.
> >
> > En la **Fase 7** darás permisos usando los GID `3001` a `3006`. Si tus trabajadores no llevan exactamente los números del escenario, esos permisos **no alcanzarán a nadie** — y el error que verás allí hablará de accesos denegados, no de esta línea.
> >
> > **En Unix, una persona no es su nombre: es su número.**
>
> > [!warning] ⚠️ El `--gid-number` NO cambia el grupo primario. Y da igual
> > Cuando compruebes con `id`, verás algo así:
> > ```
> > uid=10001(...hiroshi.nohara) gid=100(users) groups=100(users),3001(...facturacion)
> > ```
> > **El grupo primario es `users`, no `facturacion`.** Y es correcto: en Active Directory **el grupo primario de todo el mundo es `Domain Users`**, por diseño. `--gid-number` rellena el atributo, pero no cambia esa pertenencia.
> >
> > **¿Y entonces funcionará algo?** Sí, por dos motivos:
> > - Las **ACL de la Fase 7** miran la **pertenencia** al grupo, y ahí sí aparece `facturacion`.
> > - Los ficheros que cree heredarán el grupo **de la carpeta**, gracias al **setgid** que pondrás en la Fase 6.
> >
> > Lo que sí tiene que ser exacto es **el UID**: eso es lo que se graba en cada fichero.
>
> > [!tip] 💡 ¿Y `--given-name` y `--surname`?
> > Son el nombre y los apellidos que verá Windows en la pantalla de inicio de sesión y en RSAT. **No son obligatorios y sí importan**: un directorio lleno de `hiroshi.nohara` sin nombre real es un directorio que nadie quiere administrar.
>
> **Y ahora los diez que faltan:**
> ```bash
> for u in \
>   "misae.nohara:10003:3002:contabilidad:Misae:Nohara" \
>   "toru.kazama:10004:3002:contabilidad:Toru:Kazama" \
>   "masao.sato:10005:3003:comercial:Masao:Sato" \
>   "ai.suotome:10006:3003:comercial:Ai:Suotome" \
>   "bo.suzuki:10007:3004:logistica:Bo:Suzuki" \
>   "midori.yoshinaga:10008:3004:logistica:Midori:Yoshinaga" \
>   "ume.matsuzaka:10009:3005:rrhh:Ume:Matsuzaka" \
>   "bunta.takakura:10010:3005:rrhh:Bunta:Takakura" \
>   "shinnosuke.nohara:10011:3006:becarios:Shinnosuke:Nohara" \
>   "himawari.nohara:10012:3006:becarios:Himawari:Nohara" ; do
>     IFS=':' read -r LOGIN UID_N GID_N GRUPO NOMBRE APELLIDO <<< "$u"
>     echo ">>> Creando $LOGIN (uid=$UID_N) en $GRUPO"
>     sudo samba-tool user create "$LOGIN" 'P@ssw0rd' \
>          --uid-number="$UID_N" --gid-number="$GID_N" \
>          --given-name="$NOMBRE" --surname="$APELLIDO"
>     sudo samba-tool group addmembers "$GRUPO" "$LOGIN"
> done
> ```
>
> > [!important] 📖 Otra vez: léelo antes de ejecutarlo
> > En el vídeo tienes que explicar:
> > 1. Qué hace **`IFS=':' read -r ...`** *(pista: parte cada línea por los dos puntos y reparte los trozos en seis variables).*
> > 2. Por qué la contraseña va entre **comillas simples** *(pista: la `@` y el `$` en una contraseña sin comillas pueden acabar muy mal).*
> > 3. Qué pasaría si dos líneas tuvieran **el mismo UID**.
>
> > [!warning] ⚠️ Si el bucle falla a mitad, NO lo relances a ciegas
> > `samba-tool user create` **no es idempotente**: los que ya existan darán error. Mira primero qué se creó:
> > ```bash
> > sudo samba-tool user list | sort
> > ```
> > Y crea solo los que falten, a mano → [[Fase_5.7_Resolucion_Problemas#E4 · Ya existe el grupo o el usuario|caso E4]].
>
> > [!tip] 💡 Sobre la contraseña única
> > Los doce llevan `P@ssw0rd` porque esto es un laboratorio. **En una empresa real, cada persona tendría la suya y estaría obligada a cambiarla en el primer inicio de sesión** (`--must-change-at-next-login`).
> >
> > Anótalo en tu entrada: **saber qué estás simplificando es parte de entenderlo.**

---

> [!example] Paso 4: Comprobar la plantilla al completo
> ```bash
> for u in hiroshi.nohara nene.sakurada misae.nohara toru.kazama \
>          masao.sato ai.suotome bo.suzuki midori.yoshinaga \
>          ume.matsuzaka bunta.takakura shinnosuke.nohara himawari.nohara; do
>     printf '%-20s ' "$u"; id "$u" 2>/dev/null || echo "NO SE ENCUENTRA"
> done
> ```
>
> - **✅ Bien:** los doce aparecen con los UID **`10001`** a **`10012`** y sus GID correspondientes, **exactamente** los del escenario.
> - **❌ Mal:**
>   - `NO SE ENCUENTRA` → [[Fase_5.7_Resolucion_Problemas#E1 · Un usuario no aparece con id|caso E1]]
>   - **Otros números** → [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los del escenario|caso E7]]
>
> > [!info] 🎓 Este bucle es tu primera herramienta de auditoría
> > No crea nada: **comprueba**. Y en dos segundos te dice si doce identidades están bien, cosa que a mano te llevaría doce comandos y dos despistes.
> >
> > Guárdalo. Vas a repetirlo en cada fase que venga.

---

> [!example] Paso 5: El primer latido — ¿los grupos tienen a quien deben?
> Esto **no es la verificación de la fase**: es el pulso mínimo antes de seguir.
> ```bash
> for g in facturacion contabilidad comercial logistica rrhh becarios; do
>     echo "--- $g"; sudo samba-tool group listmembers "$g"
> done
> ```
> - **✅ Bien:** **dos personas en cada departamento**, las del escenario.
>
> > [!bug] 🛑 ¿Estás seguro de que esto lo ha contestado el SERVIDOR?
> > Si administras por SSH: `hostname` tiene que responder `UbuntuServer` → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

---

### ✅ Checklist de esta parte

- [ ] `/etc/nsswitch.conf` con `winbind` en las líneas `passwd` **y** `group`.
- [ ] `wbinfo -p` responde *(el servicio de systemd sigue `inactive`, y es correcto)*.
- [ ] Los **seis grupos** creados, con GID **`3001`** a **`3006`**.
- [ ] Los **doce usuarios** creados, con UID **`10001`** a **`10012`**.
- [ ] Cada usuario **añadido a su grupo** con `addmembers`.
- [ ] Los dos bucles **leídos y entendidos** antes de ejecutarlos.
- [ ] `id` de los doce devuelve **exactamente** los números del escenario.
- [ ] Cada departamento tiene **dos miembros**.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!danger] 🛑 AQUÍ NO HAS TERMINADO LA FASE
> Los doce trabajadores existen y `id` responde. **Y aun así el trabajo puede estar mal hecho sin que nada te avise:**
>
> - Un UID que no es el del escenario → los permisos de la Fase 7 no le alcanzarán.
> - Un usuario en el grupo equivocado → verá lo que no debe, o no verá lo suyo.
> - `winbind` funcionando hoy y sin arrancar mañana → los doce desaparecen al reiniciar.
>
> **Ninguna de esas tres cosas da un error.** Se comprueban en el [[Fase_5.8.a_Verificacion|apartado 8.a]], que es de obligado cumplimiento.
>
> **Orden correcto:** [[Fase_5.8.a_Verificacion|8.a · verificar]] → [[Fase_5.8.b_Punto_de_Control|8.b · guardar la instantánea]]. Nunca al revés.

> ¿Algo no ha salido? → [[Fase_5.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio (casos `E1` a `E8`).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.5_Fundamento_Teorico]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.7_Resolucion_Problemas]] |
