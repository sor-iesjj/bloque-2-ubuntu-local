## Fase 7 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> No saltes a la solución. **La comprobación es la parte que te enseña a diagnosticar**, y es la que vas a necesitar el día que el fallo no esté en ninguna lista.

> [!danger] 🛑 Esta fase tiene un fallo que es INVISIBLE desde el servidor
> Es el **[[#E5 · Una carpeta protegida se ve desde Windows|caso E5]]**: la protección funciona a medias —no se puede entrar, pero **se ve**— y desde Ubuntu no hay forma de notarlo. **Lo descubres en la Fase 8, con el cliente Windows delante.**
>
> Si solo vas a leer un caso de esta página, lee ese.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| **`samba-ad-dc` no arranca tras editar el `smb.conf`** | [[#E1 · samba-ad-dc no arranca tras editar el smb.conf\|E1]] 🔥 |
| `setfacl: Operation not supported` | [[#E2 · setfacl: Operation not supported\|E2]] |
| El usuario ve la carpeta pero no puede entrar | [[#E3 · El usuario ve la carpeta pero no puede entrar\|E3]] |
| Los ficheros nuevos no heredan los permisos | [[#E4 · Los ficheros nuevos no heredan los permisos\|E4]] |
| **La carpeta protegida se ve desde Windows** | [[#E5 · Una carpeta protegida se ve desde Windows\|E5]] ⚠️ |
| `getfacl` muestra el permiso pero pone `#effective` | [[#E6 · getfacl dice effective y el permiso no se aplica\|E6]] ⚠️ |
| He añadido dos veces la misma sección | [[#E7 · Secciones duplicadas en smb.conf\|E7]] |
| Las ACL desaparecen al copiar desde Windows | [[#E8 · Las ACL desaparecen al copiar ficheros desde Windows\|E8]] |

---

### E1 · samba-ad-dc no arranca tras editar el smb.conf

> [!bug] Síntoma
> Reinicias Samba y el servicio no vuelve:
> ```
> Job for samba-ad-dc.service failed
> ```
> Y con él **se ha caído el dominio entero**: no hay DNS, no hay autenticación, no hay nada.

**Hipótesis.** Un error de sintaxis en `/etc/samba/smb.conf`. Un corchete sin cerrar, una línea mal indentada, un parámetro mal escrito.

> [!danger] 🛑 Aquí has tirado bastante más que una carpeta compartida
> `samba-ad-dc` **no es solo el servidor de ficheros: es el controlador de dominio.** Al caer, se lleva por delante el DNS, Kerberos y LDAP. El servidor sigue encendido y el dominio ha dejado de existir.
>
> Por eso el `testparm` **no es opcional** en esta fase.

**Comprobación.** Samba trae su propio validador, y te dice la línea exacta:
```bash
sudo testparm
```
Y si quieres ver qué pasó al arrancar:
```bash
sudo journalctl -u samba-ad-dc -n 30 --no-pager
```

**Arreglo.**
1. Corrige lo que diga `testparm`:
   ```bash
   sudo nano /etc/samba/smb.conf
   ```
2. **Vuelve a validar antes de tocar el servicio:**
   ```bash
   sudo testparm
   ```
   *(Pulsa Enter cuando pregunte. Si termina mostrando la configuración sin errores, está bien.)*
3. Y ahora sí:
   ```bash
   sudo systemctl restart samba-ad-dc
   systemctl is-active samba-ad-dc
   ```

> [!summary] Qué aprendes
> **`testparm` es a `smb.conf` lo que `mount -a` era a `fstab`**: un ensayo que puedes hacer sin jugártela. Lo viste en la Fase 6 y aquí vuelve con otro nombre.
>
> La regla, que ya te sabes: **cuando toques la configuración de un servicio, valídala antes de reiniciarlo.** `nginx -t`, `visudo`, `named-checkconf`, `testparm`. Casi todo servicio serio trae el suyo, y existe precisamente porque este error es habitual.

---

### E2 · setfacl: Operation not supported

> [!bug] Síntoma
> ```
> setfacl: /srv/samba/departamentos/facturacion: Operation not supported
> ```

**Hipótesis.** Dos posibilidades: falta el paquete `acl`, o el sistema de ficheros donde está la carpeta no soporta ACL.

**Comprobación.**
```bash
which setfacl getfacl
mount | grep facturacion
df -h /srv/samba/departamentos/facturacion
```

**Arreglo.**
```bash
sudo apt install -y acl
sudo setfacl -m g:comercial:rx /srv/samba/departamentos/facturacion
```

> [!info] 🎓 En `ext4` las ACL van activadas por defecto
> No hace falta tocar el `fstab` para esto: `ext4` las soporta de serie desde hace años. Si el error persiste con el paquete instalado, **comprueba que estás aplicando la ACL sobre el disco montado** y no sobre la carpeta de debajo → [[Fase_6.7_Resolucion_Problemas#E2 · df -h no muestra los discos|caso E2 de la Fase 6]].

> [!summary] Qué aprendes
> Que **los permisos avanzados dependen del sistema de ficheros**, no solo del sistema operativo. No todos los formatos guardan lo mismo: en un `FAT32` no hay ni dueños ni permisos, y por eso un USB con FAT32 no conserva nada de esto.

---

### E3 · El usuario ve la carpeta pero no puede entrar

> [!bug] Síntoma
> Desde el cliente, la carpeta aparece, pero al abrirla: *"Acceso denegado"*.

**Hipótesis.** Tres candidatas, en este orden:
1. Samba **no se ha reiniciado** tras el cambio.
2. El usuario **no pertenece al grupo** con permiso.
3. La ACL está puesta, pero **la máscara la recorta** → [[#E6 · getfacl dice effective y el permiso no se aplica|caso E6]].

**Comprobación.** Las tres, en orden:
```bash
systemctl status samba-ad-dc --no-pager | head -5
id -nG masao.sato
getfacl -p /srv/samba/departamentos/facturacion
```

**Arreglo.** Según lo que falle:

| Qué falla | Arreglo |
| :--- | :--- |
| Samba lleva más rato del cambio | `sudo systemctl restart samba-ad-dc` |
| `masao.sato` no sale en `comercial` | `sudo samba-tool group addmembers comercial masao.sato` |
| `getfacl` dice `#effective` | `sudo setfacl -m m::rwx /srv/samba/departamentos/facturacion` |

> [!summary] Qué aprendes
> Que ante un *"no tengo acceso"* hay **un orden de diagnóstico** que ahorra tiempo: primero el servicio *(¿está leyendo la configuración nueva?)*, luego la identidad *(¿es quien creemos?)*, y por último el permiso *(¿dice lo que creemos?)*.
>
> Casi todo el mundo empieza por el tercero. Y casi siempre el problema está en los dos primeros.

---

### E4 · Los ficheros nuevos no heredan los permisos

> [!bug] Síntoma
> La carpeta tiene la ACL correcta, pero los ficheros que se crean dentro **no la llevan**. Los antiguos van bien; los nuevos, no.

**Hipótesis.** Falta la **ACL por defecto**: se ejecutó el `setfacl -m` pero no el `setfacl -d -m`.

**Comprobación.**
```bash
getfacl -p /srv/samba/departamentos/facturacion | grep default
```
- **✅ Bien:** aparece `default:group:comercial:r-x`. **`r-x`, no `rwx`:** comercial *consulta* facturación, no escribe en ella.
- **❌ Mal:** no hay ninguna línea `default:`.

**Arreglo.**
```bash
sudo setfacl -d -m g:comercial:rx /srv/samba/departamentos/facturacion
getfacl -p /srv/samba/departamentos/facturacion
```

> [!warning] ⚠️ El arreglo NO afecta a lo que ya existe
> La ACL por defecto solo se aplica a **lo que se cree a partir de ahora**. Si ya hay ficheros dentro sin permisos, hay que corregirlos aparte:
> ```bash
> sudo setfacl -R -m g:comercial:rx /srv/samba/departamentos/facturacion
> ```
> *(La `-R` es recursiva: entra en todo lo que hay dentro.)*

> [!summary] Qué aprendes
> Que **hay dos listas de permisos en la misma carpeta**: la que dice quién puede entrar *ahora* y la que dice qué heredará lo que nazca dentro. Son independientes, y arreglar una no arregla la otra.
>
> Es la misma idea que el **setgid** de la Fase 6 —herencia de grupo— llevada a las ACL. Dos mecanismos distintos para el mismo problema: que lo nuevo salga bien sin tener que acordarse cada vez.

---

### E5 · Una carpeta protegida se ve desde Windows

> [!bug] Síntoma
> **Desde el servidor, ninguno.** Todo correcto.
>
> Desde el cliente Windows, `shinnosuke.nohara` —que **no** es del grupo `comercial`— abre `\\ubuntuserver` y **ve `facturacion` en la lista**. No puede entrar, pero la ve.

**Hipótesis.** Falta `access based share enum = yes` en la sección `[facturacion]` del `smb.conf`, o Samba no se ha reiniciado después de añadirlo.

**Comprobación.** Desde el servidor:
```bash
testparm -s --section-name=facturacion
```
- **✅ Bien:** aparecen `access based share enum = Yes` y `hide unreadable = Yes`.
- **❌ Mal:** falta alguna.

**Arreglo.** Añádelas a la sección, valida y reinicia:
```bash
sudo nano /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
```

> [!danger] ⚠️ Por qué esto es el fallo invisible de la fase
> **Desde Ubuntu no hay forma de verlo.** Los permisos son correctos, las ACL son correctas, nadie sin autorización puede abrir la carpeta. El sistema hace exactamente lo que le pediste.
>
> Lo que falta no es un permiso: es **ocultar la existencia** del recurso. Y eso solo se comprueba mirando la lista de carpetas compartidas **desde un cliente Windows**, que es la Fase 8.
>
> **Y no es un detalle cosmético.** Que un usuario vea una carpeta llamada `nominas` o `expedientes` ya es información: le dice qué hay, dónde está y a quién preguntarle. La mitad de los ataques internos empiezan por un listado de carpetas.

> [!summary] Qué aprendes
> La diferencia entre **denegar el acceso** y **ocultar la existencia**, que son dos capas de seguridad distintas.
>
> Y algo incómodo pero cierto: **hay configuraciones que no puedes verificar desde donde las escribes.** Esta fase se termina de comprobar en la siguiente, y por eso el apartado 8.a te dice explícitamente qué queda pendiente en vez de fingir que todo está probado.

---

### E6 · getfacl dice effective y el permiso no se aplica

> [!bug] Síntoma
> `getfacl` muestra el permiso perfectamente… con una coletilla al final:
> ```
> group:contabilidad:rwx		#effective:r--
> ```
> Y el usuario no puede escribir, aunque pone `rwx`.

**Hipótesis.** **La máscara.** Las ACL tienen una entrada `mask::` que funciona como un techo: ningún permiso del grupo puede superarla, por mucho que figure en la lista.

**Comprobación.**
```bash
getfacl -p /srv/samba/departamentos/facturacion
```
Busca la línea `mask::`. Si dice `mask::r--`, ese es tu techo.

**Arreglo.**
```bash
sudo setfacl -m m::rwx /srv/samba/departamentos/facturacion
getfacl -p /srv/samba/departamentos/facturacion
```
- **✅ Bien:** desaparece el `#effective` de la línea del grupo.

> [!info] 🎓 Para qué sirve la máscara
> Es un limitador general: permite recortar de golpe lo que pueden hacer **todos** los grupos y usuarios de la lista, sin editarlos uno a uno. Útil para cerrar rápido, y una trampa cuando no sabes que existe.
>
> **Lo peligroso es que el permiso sigue apareciendo en la lista.** Si lees la ACL por encima, ves `rwx` y das por hecho que funciona.

> [!summary] Qué aprendes
> Que **lo que está escrito y lo que se aplica pueden ser cosas distintas**, y que el sistema te lo está diciendo — en una columna que hay que saber mirar.
>
> Es la versión más pura del *"que el comando no proteste no significa que haga lo que quieres"* que llevas arrastrando desde la Fase 4. Aquí ni siquiera hace falta un comando: **basta con leer mal una salida**.

---

### E7 · Secciones duplicadas en smb.conf

> [!bug] Síntoma
> Cambias algo en `[facturacion]`, reinicias, y **no pasa nada**. El cambio parece ignorarse.

**Hipótesis.** La sección está **dos veces** en el fichero: la que añadiste tú y otra que ya existía. Samba se queda con la **última** y descarta la primera **sin decir nada**.

**Comprobación.**
```bash
grep -n "^\[facturacion\]" /etc/samba/smb.conf
```
- **❌ Mal:** aparece `[facturacion]` en dos líneas distintas.

Y para ver **qué configuración está usando realmente**:
```bash
testparm -s --section-name=facturacion
```

**Arreglo.** Edita el fichero y **deja una sola sección**, con todos los parámetros juntos:
```bash
sudo nano /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
```

> [!summary] Qué aprendes
> Que **el fichero de configuración y la configuración efectiva no son lo mismo**, y que hay una forma de preguntar por la segunda: `testparm -s` te enseña lo que Samba entiende, no lo que tú escribiste.
>
> Cuando un cambio "no hace nada", esa distinción es lo primero que hay que comprobar. Vale para Samba, para Apache, para SSH y para casi cualquier servicio con ficheros de configuración largos.

---

### E8 · Las ACL desaparecen al copiar ficheros desde Windows

> [!bug] Síntoma
> Copias un fichero desde el cliente Windows a la carpeta compartida y **los permisos que tenía la carpeta no se aplican**, o se sustituyen por otros que no has puesto tú.

**Hipótesis.** Falta `vfs objects = acl_xattr` en la sección del recurso. Sin ese módulo, Samba no sabe guardar los permisos de Windows sobre el sistema de ficheros de Linux, y cada uno escribe los suyos por encima.

**Comprobación.**
```bash
testparm -s --section-name=facturacion | grep -i "vfs objects"
```

**Arreglo.** Añádelo a la sección, valida y reinicia:
```bash
sudo nano /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
```

> [!summary] Qué aprendes
> Que **Windows y Linux no tienen el mismo modelo de permisos**, y que hacerlos convivir necesita un traductor — igual que `winbind` traducía identidades en la Fase 5.
>
> `acl_xattr` guarda los permisos de Windows como **atributos extendidos** dentro del sistema de ficheros de Linux. Sin él, cada sistema escribe los suyos y el último que pasa gana.

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. **Pasa el verificador:** `sudo ./verificar_fase7.sh`. Te dice qué comprobación falla, y eso ya acota el problema a un bloque.
> 2. **Valida la configuración:** `sudo testparm`. Es el comando más rentable de esta fase.
> 3. **Anota el mensaje literal** en tu entrada de apuntes, aunque lo resuelvas. Los mensajes de error se repiten, y el tuyo de hoy es el de un compañero de la semana que viene.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.6_Procedimiento]] | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | [[Fase_7.8.a_Verificacion]] |
