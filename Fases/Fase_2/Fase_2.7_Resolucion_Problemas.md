## Fase 2 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma. No hace falta leerlo antes.

---

> [!warning] 📖 Cómo se usa este apartado
> **Búscate por el síntoma**, arregla, y **cuenta el incidente en tu entrada de apuntes**: qué viste, qué pensaste que era, qué resultó ser y cómo lo resolviste.
>
> Todos los casos de aquí **han pasado de verdad**, montando esta práctica en un equipo real. No son problemas imaginados por si acaso.

> [!important] 🎓 La cadena de diagnóstico
> Todos los casos siguen la misma estructura, y esa estructura es la asignatura entera:
>
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> Cuando te encuentres un problema que no esté en esta lista —y te pasará— aplícale esa misma cadena.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Ve a |
| :--- | :--- |
| `apt update` no descarga nada o dice que no hay internet | [[#E1 · apt update no descarga nada o no hay internet\|E1]] |
| `apt purge` dice que no encuentra Samba | [[#E2 · apt purge dice que no encuentra Samba\|E2]] |
| Purgué Samba pero `winbind` sigue instalado | [[#E3 · Purgué Samba pero winbind sigue instalado\|E3]] |
| En el Paso 1B, `smbd` sigue `active (running)` | [[#E4 · En el Paso 1B smbd sigue activo\|E4]] |
| Algo sigue escuchando en el puerto 445 | [[#E5 · Algo sigue escuchando en el puerto 445\|E5]] |
| Abro el fichero de identidades de red y está **vacío** | [[#E6 · El fichero de identidades de red está vacío\|E6]] |
| `hostname -f` no devuelve el nombre completo | [[#E7 · hostname -f no devuelve el nombre completo\|E7]] |
| `hostname -I` no muestra `10.10.10.10` | [[#E8 · hostname -I no muestra la IP 10.10.10.10\|E8]] |
| La pantalla azul de Kerberos no aparece | [[#E9 · La pantalla azul de Kerberos no aparece\|E9]] |
| Al **terminar** la fase, `smbd` está `active (running)` | [[#E10 · Al terminar la fase smbd sigue activo\|E10]] |
| Instalé todo pero luego falta un paquete | [[#E11 · Instalé los paquetes pero uno no está\|E11]] |
| Pantalla **morada** preguntando por servicios | [[#E12 · Pantalla morada que pregunta por reiniciar servicios\|E12]] |

---

### E1 · apt update no descarga nada o no hay internet

> [!bug] Síntoma
> `sudo apt update` se queda colgado, da errores de resolución o no trae nada. Nada de lo que viene después funciona.

**Hipótesis.** El adaptador **NAT** no está dando salida a Internet. Es el Adaptador 1 de la Fase 1, y es el único que sale fuera: la sólo-anfitrión no llega a ninguna parte.

**Comprobación.** Separa *"no hay red"* de *"no hay DNS"* con dos `ping`:

```bash
ping -c2 8.8.8.8              # ¿hay camino?
ping -c2 archive.ubuntu.com   # ¿hay resolución de nombres?
```

| Resultado | Diagnóstico |
| :--- | :--- |
| Los dos fallan | No hay red. Es el adaptador NAT |
| El primero va, el segundo no | Hay red, falla el **DNS** |
| Los dos van | El problema no es la red: lee el mensaje exacto de `apt` |

**Arreglo.** Apaga la VM y revisa en VirtualBox → `Configuración → Red → Adaptador 1`: habilitado, en modo **NAT** y con **`Cable conectado`** marcado. Enciende y repite la comprobación.

> [!summary] Qué aprendes
> Que **dos `ping`, uno a IP y otro a nombre, son el diagnóstico de red más rentable que existe**. Te dicen en qué capa está el fallo antes de tocar nada.

---

### E2 · apt purge dice que no encuentra Samba

> [!bug] Síntoma
> El `apt purge` del Paso 1A responde que los paquetes no están instalados.

**Hipótesis.** **No es un error.** Samba no venía instalado en tu imagen, o ya lo purgaste en un intento anterior.

**Comprobación.**

```bash
dpkg -l | grep -E "samba|winbind"
```

Si no devuelve nada, el entorno está limpio. Es exactamente el objetivo del Paso 1A.

**Arreglo.** Ninguno. Continúa al Paso 1B.

> [!summary] Qué aprendes
> Que **un comando que "no hace nada" puede ser un éxito**. Purgar garantiza un estado final —que no haya Samba—, no ejecuta una acción. Si el estado ya es el correcto, no hay trabajo que hacer.

---

### E3 · Purgué Samba pero winbind sigue instalado

> [!bug] Síntoma
> Después de purgar, `dpkg -l | grep winbind` sigue devolviendo paquetes instalados.

**Hipótesis.** Usaste un **comodín** (`apt purge samba*`) en vez de la lista explícita. El comodín solo caza lo que **empieza** por "samba", y `winbind`, `libnss-winbind` y `libpam-winbind` no empiezan por ahí.

**Comprobación.**

```bash
dpkg -l | grep -E "samba|winbind"
```

**Arreglo.** Ejecuta la lista completa del Paso 1A:

```bash
sudo apt purge -y samba samba-common samba-common-bin winbind libnss-winbind libpam-winbind
sudo apt autoremove -y
```

> [!danger] ⚠️ Por qué esto revienta la Fase 4
> `winbind` ocupa los mismos puertos que necesita el controlador de dominio. Un `winbind` superviviente hace que `samba-ad-dc` **no pueda arrancar**, y el error que da **no menciona a `winbind`** por ninguna parte.

> [!summary] Qué aprendes
> Que **un comodín no es una lista**. `samba*` parece abarcarlo todo y deja fuera justo las tres piezas que más molestan después. En administración, lo explícito gana a lo cómodo.

---

### E4 · En el Paso 1B smbd sigue activo

> [!bug] Síntoma
> Antes de llegar al Paso 2, `systemctl status smbd` sigue diciendo `active (running)`.

**Hipótesis.** El servicio seguía arrancado cuando purgaste, o la purga no incluyó todos los paquetes.

**Comprobación.**

```bash
systemctl status smbd
dpkg -l | grep -E "samba|winbind"
```

**Arreglo.** Repite el Paso 1A **entero y en orden**: primero el `systemctl stop`, después el `purge` con la lista completa. El orden importa — parar antes de desinstalar evita que queden procesos huérfanos.

> [!summary] Qué aprendes
> Que **desinstalar un paquete no garantiza que su proceso muera**. Paquete y proceso son cosas distintas: uno vive en el disco, el otro en memoria.

---

### E5 · Algo sigue escuchando en el puerto 445

> [!bug] Síntoma
> Después de purgar, algo sigue ocupando el 445, el puerto de SMB.

**Hipótesis.** Un proceso quedó vivo aunque el paquete se borrara.

**Comprobación.** Pregunta **qué** proceso lo ocupa, no solo si está ocupado:

```bash
sudo ss -tlnp | grep :445
```

La última columna te da el nombre del proceso y su PID.

**Arreglo.**

```bash
sudo systemctl stop <el-servicio-que-te-diga>
sudo ss -tlnp | grep :445     # ahora debe salir vacío
```

> [!summary] Qué aprendes
> Que **`ss -tlnp`, con la `p`, te da el culpable** y no solo el síntoma. Saber que un puerto está ocupado no sirve de nada; saber **quién** lo ocupa lo resuelve.

---

### E6 · El fichero de identidades de red está vacío

> [!bug] Síntoma
> Abres `/etc/hosts` en el Paso 3 y **no hay nada dentro**. El procedimiento habla de añadir una línea al final, pero no hay ninguna línea.

**Hipótesis.** **No has borrado nada.** En Ubuntu Server 26.04 ese fichero **viene vacío de fábrica** en la imagen, y el instalador no lo rellena.

**Comprobación.** Míralo, y mira su fecha:

```bash
cat /etc/hosts
stat -c "%y  %s bytes" /etc/hosts
```

Si la fecha es **anterior al día en que instalaste** el sistema, viene así de la imagen: no lo tocó nadie.

**Arreglo.** Escribe el contenido completo, no solo la línea del dominio:

```
127.0.0.1       localhost
10.10.10.10     UbuntuServer.BOOCHANLAB.LOCAL   UbuntuServer

::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Y comprueba que ahora resuelve por IPv4:

```bash
getent hosts localhost
```

> [!danger] ⚠️ Por qué no basta con la línea del dominio
> `127.0.0.1 localhost` es **cómo un sistema Linux se encuentra a sí mismo**. Si falta, cualquier programa que se conecte a `localhost` puede fallar, y el error **no menciona `/etc/hosts` por ninguna parte**.
>
> Con el fichero vacío, `getent hosts localhost` devuelve solo `::1` — la dirección **IPv6**. La resolución IPv4 la está tapando `systemd-resolved` con un apaño interno. Funciona… hasta que algo pida `127.0.0.1` explícitamente. Y en la **Fase 4**, Samba hace justo eso.

> [!summary] Qué aprendes
> Que **un fichero de configuración vacío no siempre significa que alguien lo borró** — y que la fecha de modificación lo demuestra. Y que un sistema puede parecer sano mientras le falta algo básico, porque otro componente lo está compensando en silencio. Hasta que deja de hacerlo.

---

### E7 · hostname -f no devuelve el nombre completo

> [!bug] Síntoma
> `hostname -f` devuelve `UbuntuServer` en vez de `UbuntuServer.BOOCHANLAB.LOCAL`.

**Hipótesis.** La línea de `/etc/hosts` falta, está mal escrita, o tiene **las columnas en orden equivocado**.

**Comprobación.**

```bash
cat /etc/hostname     # solo el nombre corto: UbuntuServer
cat /etc/hosts        # aquí vive el nombre completo
```

> [!warning] ⚠️ El orden de las columnas decide el resultado
> El formato es: `IP` · **`nombre completo (FQDN)`** · `nombre corto (alias)`.
>
> `hostname -f` devuelve **el segundo campo**. Si escribes el corto antes que el largo, te devolverá `UbuntuServer` y **la Fase 4 aprovisionará el dominio mal**.
>
> ✅ `10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer`
> ❌ `10.10.10.10  UbuntuServer  UbuntuServer.BOOCHANLAB.LOCAL`

**Arreglo.** Corrige la línea en `/etc/hosts` —si el fichero está vacío, ve a [[#E6 · El fichero de identidades de red está vacío|E6]]— y vuelve a comprobar.

> [!summary] Qué aprendes
> Que **`/etc/hostname` y `/etc/hosts` no son lo mismo**: el primero guarda el nombre corto, el segundo la identidad completa en la red. Y que en un fichero de configuración **el orden de los campos es sintaxis**, no presentación.

---

### E8 · hostname -I no muestra la IP 10.10.10.10

> [!bug] Síntoma
> `hostname -I` devuelve solo la IP de la NAT (`10.0.2.x`), sin la `10.10.10.10`.

**Hipótesis.** La configuración estática de netplan de la Fase 1 no se aplicó, o se perdió.

**Comprobación.**

```bash
ip -4 -o addr show
ls /etc/netplan/
```

**Arreglo.** Está resuelto en el catálogo de la fase anterior: [[Fase_1.7_Resolucion_Problemas#E5 · Mi servidor no tiene la IP 10.10.10.10|Fase 1 · caso E5]]. Edita el `.yaml` que exista, **añade** el bloque de `enp0s8` sin reescribir el resto, y aplica con `sudo netplan apply`.

> [!danger] ⚠️ No sigas a la Fase 3 sin esto
> Sin la IP fija, el dominio de la Fase 4 se anunciará en una dirección que nadie puede alcanzar, y la Fase 8 fallará **sin dar ninguna pista del motivo**.

> [!summary] Qué aprendes
> Que **un fallo de una fase anterior no siempre aparece en su fase**. Aquí se manifiesta, pero se originó en la Fase 1.

---

### E9 · La pantalla azul de Kerberos no aparece

> [!bug] Síntoma
> Al instalar los paquetes del Paso 2 no sale la pantalla azul que pregunta por el reino (*realm*) de Kerberos.

**Hipótesis.** **No es un error.** Ya estaba configurado de una instalación anterior, así que `debconf` no vuelve a preguntar.

**Comprobación.**

```bash
head -20 /etc/krb5.conf
```

**Arreglo.** Si quieres que vuelva a preguntar:

```bash
sudo dpkg-reconfigure krb5-config
```

Aunque no hace falta: la **Fase 4** sobrescribe `/etc/krb5.conf` con el que genera el propio aprovisionamiento del dominio.

> [!summary] Qué aprendes
> Que **`debconf` recuerda respuestas anteriores** y no repite preguntas ya contestadas. Un instalador que no pregunta no está roto: es que ya sabe la respuesta.

---

### E10 · Al terminar la fase smbd sigue activo

> [!bug] Síntoma
> Terminas la fase, ejecutas `systemctl status smbd` y dice `active (running)`. Después de haberlo purgado al principio.

**Hipótesis.** **Ninguna: es lo correcto.** El **Paso 2 lo reinstaló a propósito**, porque las herramientas de Samba hacen falta para la Fase 4.

> [!danger] 🛑 NO lo purgues otra vez
> Este caso está aquí porque es **el error de diagnóstico más caro de esta fase**: ver `smbd` activo al final, pensar que la purga falló, y volver a purgar. Eso te deja sin `samba-tool`, sin los paquetes del dominio, y con la instantánea de la fase contaminada.
>
> **La purga del Paso 1A y la instalación del Paso 2 hacen cosas distintas:**
> - La **purga** elimina el Samba **de fábrica** y su `smb.conf` viejo, que bloquearía el aprovisionamiento.
> - La **instalación** trae el Samba **que sí queremos**, con `samba-ad-dc` y `samba-ad-provision`.

**Comprobación.** Que estén los paquetes del dominio:

```bash
dpkg -s samba-ad-dc samba-ad-provision | grep -m2 ^Status
```

**Arreglo.** Ninguno. La Fase 4 desactiva `smbd` ella sola justo antes de levantar el controlador de dominio.

> [!summary] Qué aprendes
> Que **el mismo síntoma significa cosas opuestas según el momento**. `smbd` activo antes del Paso 2 es un problema; `smbd` activo al terminar la fase es lo correcto. Sin saber en qué punto del procedimiento estás, el diagnóstico es imposible.

---

### E11 · Instalé los paquetes pero uno no está

> [!bug] Síntoma
> Ejecutaste el `apt install` del Paso 2, no viste ningún error rojo evidente… y después `dpkg -s <paquete>` dice que no está instalado.

**Hipótesis.** El paquete **no existe en los repositorios** de tu versión de Ubuntu. `apt` lo avisa, pero **puede continuar instalando el resto sin abortar**, y el aviso se pierde entre cientos de líneas.

**Comprobación.** Pregunta si el paquete existe siquiera:

```bash
apt-cache policy <nombre-del-paquete>
```

| Respuesta | Significa |
| :--- | :--- |
| `Candidate: (none)` | **No existe** en los repositorios de tu versión |
| `Candidate: 1.2.3` + `Installed: (none)` | Existe, pero no llegó a instalarse |
| `Installed: 1.2.3` | Está instalado. El problema es otro |

**Arreglo.** Depende de la respuesta:
- **No existe** → averigua si lo sustituye otro paquete, o si su función la cubre ya el sistema. *(Le pasó a `resolvconf`: desapareció en Ubuntu 26.04 y su trabajo lo hace `systemd-resolved`.)*
- **Existe pero no se instaló** → repite con `sudo apt install -y <paquete>` y **lee el error**, esta vez solo.

> [!success] ✅ Cómo evitarlo siempre
> Después de una instalación larga, **comprueba lo que hay, no lo que pediste**:
> ```bash
> for p in samba samba-ad-dc samba-ad-provision krb5-user winbind; do
>   printf "%-22s %s\n" "$p" "$(dpkg -s $p 2>/dev/null | grep -m1 ^Status || echo FALTA)"
> done
> ```

> [!summary] Qué aprendes
> Que **"no dio error" no es lo mismo que "funcionó"**. Un comando que instala trece paquetes puede fallar en uno y terminar con éxito aparente. En administración se verifica el **estado final**, no la ausencia de quejas.

---

### E12 · Pantalla morada que pregunta por reiniciar servicios

> [!bug] Síntoma
> Durante `apt upgrade` la pantalla se pone **morada** y aparece una lista de servicios con casillas marcadas, preguntando cuáles reiniciar.

**Hipótesis.** **No es un error.** Es `needrestart`, una herramienta de Ubuntu que detecta qué servicios están usando bibliotecas que acabas de actualizar.

> [!info] 🎓 Por qué existe esa pregunta
> Cuando actualizas una biblioteca, los programas **ya en marcha siguen usando la versión vieja**, cargada en memoria desde que arrancaron. El paquete está actualizado en el disco, pero el servicio **no tiene el parche** hasta que se reinicia.
>
> Es exactamente por lo que las actualizaciones de seguridad piden reiniciar cosas.

**Arreglo.** Pulsa **`Enter`** para aceptar los servicios que propone. Y si pregunta *"¿Reiniciar el sistema?"*, di **que no**: reinicias tú al terminar el paso.

> [!warning] ⚠️ Si lanzas `apt` por SSH sin terminal interactivo, esto se cuelga
> No te pasará siguiendo la práctica, pero conviene saberlo: `needrestart` **espera una respuesta**. Si el comando corre sin nadie que pueda contestar —por ejemplo en un script automático—, se queda parado indefinidamente, sin consumir CPU y sin decir por qué.
>
> En esos casos se le indica el modo de antemano:
> ```bash
> sudo NEEDRESTART_MODE=a apt upgrade -y
> ```

> [!summary] Qué aprendes
> Que **actualizar un paquete no actualiza el proceso que ya estaba corriendo**. Disco y memoria van por separado — la misma idea del caso [[#E4 · En el Paso 1B smbd sigue activo|E4]], vista desde el otro lado.

---

> [!summary] 🎓 Lo que se llevan estos doce casos
> Ninguno se arregla sabiendo el comando de memoria. Todos se arreglan **acotando**: qué funciona, qué no, y **en qué momento**.
>
> - Ping a IP sí, a nombre no → hay red, pero no hay DNS.
> - Paquete borrado pero proceso vivo → disco y memoria son cosas distintas.
> - Un comodín no es una lista.
> - Un fichero vacío puede venir así de fábrica: **mira la fecha antes de acusar a nadie**.
> - El mismo síntoma, en dos momentos distintos, significa cosas contrarias.
>
> **Esa forma de pensar es el módulo entero.** Los comandos se buscan; el razonamiento, no.

> [!tip] 💾 La red de seguridad que evita la mitad de estos sustos
> Varios de estos casos se resuelven en treinta segundos restaurando la instantánea **`Fase 1 terminada`** y repitiendo, en vez de diagnosticar a ciegas sobre una máquina que ya no sabes en qué estado está. Ver [[Fase_2.8.a_Verificacion]].

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.6_Procedimiento]] | [[Fase_2]] | [[Fase_2.8.a_Verificacion]] |
