## Fase 5 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> No saltes a la solución. **La comprobación es la parte que te enseña a diagnosticar**, y es la que vas a necesitar el día que el fallo no esté en ninguna lista.

> [!danger] 🛑 Esta fase tiene un fallo que NO da ningún error
> Es el **[[#E7 · Los UID no son los del escenario|caso E7]]**: los usuarios existen, `id` responde, todo parece correcto — pero con números distintos a los que pusiste. **Los permisos de la Fase 7 se te caerán sin que nada apunte aquí.**
>
> Si solo vas a leer un caso de esta página, lee ese.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| `id hiroshi.nohara` no devuelve nada | [[#E1 · Un usuario no aparece con id\|E1]] |
| El usuario existe en el dominio pero Linux no lo ve | [[#E2 · El usuario existe en el dominio pero Linux no lo ve\|E2]] |
| `Password too weak` / la contraseña no se acepta | [[#E3 · La contraseña no se acepta\|E3]] |
| `Group already exists` o `User already exists` | [[#E4 · Ya existe el grupo o el usuario\|E4]] |
| Error de esquema LDAP en `addunixattrs` | [[#E5 · addunixattrs da error de esquema LDAP\|E5]] |
| El usuario no aparece en su grupo | [[#E6 · El usuario no está en su grupo\|E6]] |
| **Todo funciona pero los UID no son los míos** | [[#E7 · Los UID no son los del escenario\|E7]] ⚠️ |
| Funciona hoy; tras reiniciar, los usuarios desaparecen | [[#E8 · Tras reiniciar los usuarios han desaparecido\|E8]] |

---

### E1 · Un usuario no aparece con id

> [!bug] Síntoma
> ```
> id: 'hiroshi.nohara': no such user
> ```
> O el comando no devuelve absolutamente nada.

**Hipótesis.** El usuario puede existir perfectamente en el dominio. Lo que falla es **el traductor**: o `winbind` está parado, o Linux ni siquiera le pregunta.

**Comprobación.** Separa las dos preguntas — *"¿existe?"* y *"¿lo veo?"*:
```bash
sudo samba-tool user list | grep hiroshi.nohara      # ¿existe en el dominio?
systemctl is-active winbind                 # ¿el traductor está vivo?
grep -E "^passwd:|^group:" /etc/nsswitch.conf   # ¿Linux le pregunta?
```

**Arreglo.** Según lo que falle:

| Qué falla                            | Arreglo                                     |
| :----------------------------------- | :------------------------------------------ |
| No aparece en `samba-tool user list` | El usuario no se creó. Repite el Paso 3     |
| `winbind` no está `active`           | `sudo systemctl enable --now winbind`       |
| Falta `winbind` en `nsswitch.conf`   | Vuelve al Paso 1 y añádelo a las dos líneas |

> [!summary] Qué aprendes
> Que **"existir" y "ser visible" son dos cosas distintas**, y que hay una pieza entre medias haciendo de intérprete.
>
> Es la primera vez en el proyecto que te encuentras con esto, y no será la última: en administración de sistemas, media docena de fallos se resumen en *"el dato está, pero nadie lo está preguntando donde toca"*.

---

### E2 · El usuario existe en el dominio pero Linux no lo ve

> [!bug] Síntoma
> `sudo samba-tool user list` **sí** muestra `hiroshi.nohara`, pero `id hiroshi.nohara` sigue diciendo que no existe.

**Hipótesis.** Winbind está en medio y no hace su trabajo: o no habla con el dominio, o `nsswitch.conf` no le pasa la pregunta.

**Comprobación.** `wbinfo` pregunta a winbind **directamente**, saltándose `nsswitch`. Esa es su utilidad aquí:
```bash
wbinfo -p                    # ¿winbind responde?
wbinfo -u                    # ¿ve los usuarios del dominio?
getent passwd hiroshi.nohara          # ¿el sistema lo resuelve por la vía normal?
```

| Resultado | Dónde está el problema |
| :--- | :--- |
| `wbinfo -u` **sí** lista a `hiroshi.nohara`, `getent` **no** | En `nsswitch.conf`: winbind sabe, pero nadie le pregunta |
| `wbinfo -u` **tampoco** lo lista | En winbind: no está hablando con el dominio |
| `wbinfo -p` falla | El servicio está muerto |

**Arreglo.** Si es de `nsswitch`, vuelve al Paso 1. Si es de winbind:
```bash
sudo systemctl restart winbind
wbinfo -u
```

> [!summary] Qué aprendes
> **La técnica de diagnóstico vale más que el arreglo.** `wbinfo` y `getent` preguntan lo mismo por dos caminos distintos, y comparar sus respuestas te dice **en qué tramo del camino** se pierde la información.
>
> Es la misma idea del `ping 8.8.8.8` contra `getent hosts` de la Fase 4: dos comandos que se diferencian en un solo paso, para localizar cuál es el paso roto.

---

### E3 · La contraseña no se acepta

> [!bug] Síntoma
> ```
> ERROR: Failed to add user 'hiroshi.nohara': Password does not meet complexity requirements
> ```

**Hipótesis.** Active Directory trae una **política de contraseñas activada de fábrica**: longitud mínima y mezcla de mayúsculas, minúsculas, números y símbolos.

**Comprobación.** Mira la política que te está bloqueando:
```bash
sudo samba-tool domain passwordsettings show
```

**Arreglo.** Usa la contraseña del proyecto, que sí la cumple: **`P@ssw0rd`**.

> [!warning] ⚠️ Se puede desactivar la política. No lo hagas
> Existe `samba-tool domain passwordsettings set --complexity=off`, y en internet lo verás recomendado a la ligera.
>
> **En este proyecto no se toca.** Estás montando un controlador de dominio: bajar la política de contraseñas para que te deje poner `1234` es exactamente el atajo que un auditor te marcaría. Si un día lo haces en producción, que sea una decisión escrita y justificada, no una forma de saltarte un error.

> [!summary] Qué aprendes
> Que **el sistema te está protegiendo, no molestando.** Un error que te impide hacer algo inseguro es una función, no un fallo — como el `set -euo pipefail` del script de la Fase 4.

---

### E4 · Ya existe el grupo o el usuario

> [!bug] Síntoma
> ```
> ERROR: Unable to add group 'facturacion': Group 'facturacion' already exists
> ```
> Lo mismo con `hiroshi.nohara` o `misae.nohara`.

**Hipótesis.** Lo creaste en un intento anterior. **El comando no es idempotente**: ejecutarlo dos veces no da el mismo resultado que ejecutarlo una.

**Comprobación.** Mira qué hay realmente antes de borrar nada:
```bash
sudo samba-tool group list
sudo samba-tool user list
getent group facturacion
id hiroshi.nohara
```

**Arreglo.** Si lo que existe **ya está bien** (el `getent` y el `id` devuelven los números correctos), **no toques nada**: el paso ya estaba hecho. Solo si está mal:
```bash
sudo samba-tool group delete facturacion
sudo samba-tool group add facturacion
sudo samba-tool group addunixattrs facturacion 3001
```

> [!summary] Qué aprendes
> Que antes de repetir un paso hay que **mirar en qué estado está el sistema**, no asumir que está como al principio. Media hora de averías se ahorra con un `list` a tiempo.
>
> Y una palabra que te vas a encontrar mucho: **idempotente**. Un comando idempotente se puede repetir sin cambiar nada más. `samba-tool group add` **no** lo es, y por eso protesta.

---

### E5 · `addunixattrs` da error de esquema LDAP

> [!bug] Síntoma
> Al ejecutar `sudo samba-tool group addunixattrs facturacion 3001`:
> ```
> ERROR: ... no such attribute ... gidNumber
> ```
> O cualquier mensaje que hable del **esquema** o de un atributo que no existe.

**Hipótesis.** El dominio se aprovisionó **sin `--use-rfc2307`**. Sin ese flag, Active Directory no tiene dónde guardar los `uidNumber` y `gidNumber` de Unix: el hueco no existe en la base de datos.

**Comprobación.**
```bash
grep -i rfc2307 /etc/samba/smb.conf
```
- **Si no devuelve nada**, ese es el problema.

**Arreglo.** No se parchea desde aquí: **hay que rehacer el dominio**.

> [!danger] 🛑 Esto es volver a la Fase 4, y es una decisión seria
> La forma limpia es **restaurar la instantánea `Fase 3 terminada`** y volver a lanzar el script de aprovisionamiento, comprobando que lleva `--use-rfc2307`.
>
> La alternativa (`samba-tool domain demote` y reaprovisionar encima) deja restos con frecuencia. **Para eso tomaste las instantáneas**: úsalas antes de intentar reparaciones artesanales.

> [!summary] Qué aprendes
> Que **hay decisiones que solo se pueden tomar en el momento de crear algo.** El `--use-rfc2307` era un parámetro en una línea de la Fase 4, parecía un detalle, y determina si la Fase 5 es posible.
>
> Esto se llama, en la práctica, *"pagar un error de diseño"*: cuanto más tarde lo descubres, más caro sale. Y es exactamente por lo que se te pidió **leer el script antes de ejecutarlo**.

---

### E6 · El usuario no está en su grupo

> [!bug] Síntoma
> `id hiroshi.nohara` responde con su UID y su GID, pero al mirar los grupos:
> ```bash
> id -nG hiroshi.nohara
> ```
> no aparece `facturacion`.

**Hipótesis.** Se creó el usuario con `--gid-number=3001`, pero **no se ejecutó** el `samba-tool group addmembers`. Son dos cosas distintas y hacen falta las dos.

**Comprobación.**
```bash
sudo samba-tool group listmembers facturacion
id -nG hiroshi.nohara
```

**Arreglo.**
```bash
sudo samba-tool group addmembers facturacion hiroshi.nohara
id -nG hiroshi.nohara
```

> [!info] 🎓 Entonces, ¿para qué sirve cada cosa?
> - **`--gid-number=3001`** le da al usuario un **grupo primario** en el mundo Unix: el que se usa al crear ficheros.
> - **`group addmembers`** lo mete en el grupo **dentro de Active Directory**: lo que mira Windows y lo que usarán las ACL de la Fase 7.
>
> Un usuario puede tener el número correcto y no estar en el grupo. Para el sistema de ficheros parecerá bien; para el dominio, no pertenece.

> [!summary] Qué aprendes
> Que en un entorno mixto **la misma pertenencia se representa dos veces**, en dos mundos distintos, y hay que dejarla coherente en los dos. Este es el precio de que Linux y Windows hablen entre sí — y el motivo de que exista winbind.

---

### E7 · Los UID no son los del escenario

> [!bug] Síntoma
> **Ninguno.** Y ese es el problema.
>
> `id hiroshi.nohara` responde, el usuario existe, todo va bien. Pero devuelve algo así:
> ```
> uid=3000019(hiroshi.nohara) gid=100(users)
> ```
> en lugar de `uid=10001 gid=3001`.

**Hipótesis.** El usuario se creó **sin** `--uid-number` / `--gid-number`, y winbind le asignó un número automático del rango que tiene reservado.

**Comprobación.**
```bash
id hiroshi.nohara
id misae.nohara
getent group facturacion
```
- **✅ Bien:** `uid=10001 gid=3001` y `uid=10002 gid=3002`, exactamente.
- **❌ Mal:** cualquier otro número.

**Arreglo.** Asigna los atributos Unix a mano y reinicia el traductor para que se entere:
```bash
sudo samba-tool user addunixattrs hiroshi.nohara 10001
sudo systemctl restart winbind
id hiroshi.nohara
```
Si sigue sin cuadrar, borra el usuario y créalo otra vez **con los parámetros completos** del Paso 3.

> [!danger] ⚠️ Por qué esto es el fallo caro de la fase
> Un UID asignado automáticamente **funciona perfectamente hoy**. El usuario entra, crea ficheros, todo normal.
>
> El problema llega en la **Fase 7**, cuando pongas permisos sobre carpetas usando esos números. Y sobre todo si alguna vez restauras una instantánea o rehaces el dominio: **los números automáticos pueden salir distintos la segunda vez**, y entonces los ficheros de `hiroshi.nohara` pasan a pertenecer a un usuario que no existe. Verás `10001` como propietario en lugar de un nombre, y nadie podrá acceder a sus datos.
>
> **En el mundo Unix, un usuario NO es su nombre: es su número.** El nombre es una etiqueta que se le pone encima.

> [!summary] Qué aprendes
> **El fallo que no da error es el caro**, otra vez. Es la misma lección de la Fase 4 con el dominio anunciado en la tarjeta equivocada, en otra forma.
>
> Y la regla práctica: **cuando un sistema te deja elegir un identificador, elígelo tú.** Lo que asigna la máquina por su cuenta, la máquina se lo puede volver a asignar de otra manera.

---

### E8 · Tras reiniciar, los usuarios han desaparecido

> [!bug] Síntoma
> Ayer `id hiroshi.nohara` funcionaba. Hoy, tras encender la máquina:
> ```
> id: 'hiroshi.nohara': no such user
> ```
> Y tú no has tocado nada.

**Hipótesis.** `winbind` está **activo pero no habilitado**: lo arrancaste a mano (o lo arrancó otra cosa) y no se levanta solo al encender.

**Comprobación.**
```bash
systemctl is-active winbind
systemctl is-enabled winbind
```
- **❌ Mal:** `inactive` + `disabled`, o `active` + `disabled` *(este segundo es la bomba de relojería: hoy va, mañana no)*.

**Arreglo.**
```bash
sudo systemctl enable --now winbind
systemctl is-enabled winbind
id hiroshi.nohara
```

> [!summary] Qué aprendes
> **`active` es "ahora". `enabled` es "la próxima vez".** Llevas tres fases encontrándote esta distinción: el `netplan` de la Fase 1, el `wg-quick@wg0` de la Fase 3, el `samba-ad-dc` de la Fase 4 y ahora `winbind`.
>
> Que se repita cuatro veces no es casualidad del material: es que **lo que no persiste, no está configurado.** Solo está encendido.

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. **Pasa el verificador:** `sudo ./verificar_fase5.sh`. Te dice qué comprobación falla, y eso ya acota el problema a un bloque.
> 2. **Lee el registro de winbind:** `sudo journalctl -u winbind -n 40 --no-pager`.
> 3. **Anota el mensaje literal** en tu entrada de apuntes, aunque lo resuelvas. Los mensajes de error se repiten, y el tuyo de hoy es el de un compañero de la semana que viene.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.6_Procedimiento]] | [[Fase_5]] | [[Fase_5.8.a_Verificacion]] |
