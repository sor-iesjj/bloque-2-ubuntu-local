		## Fase 7 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Aquí compruebas. En el [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ Esta fase NO se puede verificar entera desde aquí
> La mitad del trabajo es **hacer invisible** una carpeta para quien no tiene permiso. Y la invisibilidad **solo se ve desde el cliente Windows**, que es la Fase 8.
>
> Lo que sí puedes comprobar aquí es que el servidor está **correctamente configurado para ello**. El punto 7 te dice qué queda pendiente, para que lo **anotes** en vez de darlo por hecho.
>
> **No confundas "el servidor está bien configurado" con "la protección funciona".**

> [!info] 📋 Ten delante la matriz
> Todo lo de esta lista sale de [[Escenario_Boochan_SL]]. **No la verifiques de memoria:** son ocho permisos cruzados y es muy fácil dar uno de más.

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`UbuntuServer`** → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

### **1 · LA BASE DE LAS FASES 5 Y 6 SIGUE EN PIE**

> [!abstract] 🎯 Qué compruebas aquí, y por qué antes que nada
> **Una ACL se le da a un grupo, sobre una carpeta montada.** Esas dos piezas no las has hecho hoy: los grupos vienen de la Fase 5 y las carpetas de la Fase 6.
>
> **Si alguna se ha movido, todo el trabajo de hoy se ha aplicado a la nada** — y no lo verías, porque `setfacl` no protesta por escribir permisos para un grupo que el sistema ya no reconoce.
>
> **Se comprueba primero para no perder una hora** buscando en las ACL un problema que está dos fases más atrás.

```bash
for d in facturacion contabilidad comercial logistica rrhh becarios; do
    printf '%-16s %s\n' "$d" "$(getent group $d | cut -d: -f3)"
done
mountpoint /srv/samba/departamentos && mountpoint /srv/samba/comun
stat -c '%n %U:%G' /srv/samba/departamentos/*
```

> [!info] 📖 Qué hace ese código
> Son **tres comprobaciones seguidas**, una por pieza:
>
> 1. **El bucle** recorre los seis departamentos y, por cada uno, pregunta al sistema su GID:
>    - `getent group facturacion` devuelve la línea entera del grupo → `BOOCHANLAB\facturacion:x:3001:`
>    - `cut -d: -f3` se queda con **el tercer campo**, que es el número → `3001`
>    - `printf '%-16s %s\n'` lo imprime en dos columnas alineadas, para poder leerlo de un vistazo
> 2. **`mountpoint`** pregunta si esa ruta es un punto de montaje o una carpeta normal. Van los dos unidos por `&&`: el segundo solo se ejecuta si el primero va bien.
> 3. **`stat -c '%n %U:%G'`** imprime, de cada carpeta, **su nombre, su dueño y su grupo**. El `*` hace que las recorra las seis.
>
> **Ninguno de los tres modifica nada.** Los tres preguntan.

- **✅ Bien:**
  - Los seis departamentos con sus GID **`3001`** a **`3006`**, en orden.
  - Los dos `mountpoint` responden **`is a mountpoint`**.
  - Las seis carpetas a nombre de **`root:BOOCHANLAB\<su departamento>`**.
- **❌ Mal:**
  - Un GID **vacío** → el grupo no se resuelve → [[Fase_5.7_Resolucion_Problemas|Fase 5]].
  - **`is not a mountpoint`** → el volumen no está montado → [[Fase_6.7_Resolucion_Problemas|Fase 6]].
  - Una carpeta con grupo **`root`** en vez del suyo → [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento|caso E6 de la Fase 6]].

### **2 · 🔴 LOS OCHO PERMISOS CRUZADOS ESTÁN PUESTOS**

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Que la matriz de la empresa está escrita en el servidor**, entrada por entrada.
>
> Esto es el trabajo del apartado 6: los ocho accesos que un departamento tiene sobre la carpeta **de otro**. Y hay que mirarlo en **dos direcciones**:
>
> | Miras que… | Si falla… |
> | :--- | :--- |
> | **Están los ocho** que deben estar | Alguien no podrá trabajar. Te llamará mañana |
> | **No hay ninguno de más** | Alguien verá lo que no debe. **No te llamará nunca** |
>
> Lo segundo es lo que de verdad se evalúa aquí, y es lo que nadie mira.

```bash
for d in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "=== $d"
    getfacl -p "/srv/samba/departamentos/$d" 2>/dev/null | grep -E "^(group|default:group):" 
done
```

> [!info] 📖 Qué hace ese código
> - **El bucle** recorre las seis carpetas de departamento y, en cada vuelta, imprime una cabecera `=== <nombre>` para que sepas de cuál te está hablando.
> - **`getfacl -p`** vuelca la lista de permisos completa de esa carpeta. La `-p` evita que recorte las rutas largas.
> - **`grep -E "^(group|default:group):"`** se queda **solo con las líneas de grupo** — las de acceso y las de herencia—, que son las que te interesan. Descarta el `user::`, el `mask::` y el `other::`.
> - **`2>/dev/null`** manda los mensajes de error a la papelera: si una carpeta no existiera, no quieres que el error ensucie la salida de las demás.

Compara **casilla por casilla** con la matriz. Esto es lo que tiene que salir:

| Carpeta | Grupos que deben aparecer, además del suyo |
| :--- | :--- |
| `facturacion` | `comercial:r-x` · `contabilidad:rwx` |
| `contabilidad` | **ninguno** |
| `comercial` | `facturacion:r-x` · `contabilidad:r-x` · `logistica:r-x` |
| `logistica` | `contabilidad:r-x` · `comercial:r-x` |
| `rrhh` | **ninguno** |
| `becarios` | `rrhh:r-x` |

- **❌ Falta alguno** → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]] si es la línea `default:`, o repite el Paso 2 si falta entero.

> [!danger] 🛑 Y ahora mira lo contrario: que no SOBRE ninguno
> Un permiso de más es peor que uno de menos. **El de menos se nota enseguida** —alguien no puede trabajar y te llama—. **El de más no lo nota nadie** hasta que alguien ve lo que no debía.
>
> Las dos casillas que tienen que estar **vacías** son las importantes:
> - **`rrhh`** → no debe aparecer **ningún** grupo ajeno. Ni contabilidad.
> - **`contabilidad`** → tampoco.
>
> Si en `rrhh` aparece cualquier cosa, has roto el principio de mínimo privilegio de la empresa.

### **3 · 🔴 LA MÁSCARA RECORTA SOLO DONDE DEBE**

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Que los permisos que acabas de escribir se aplican de verdad.**
>
> Una ACL puede decir `rwx` y valer `r--`: la **máscara** es un techo que recorta a los grupos con nombre sin borrarlos de la lista. El permiso sigue ahí, escrito y correcto, y no funciona.
>
> **Y no lo notarías administrando**, porque la máscara **no afecta al dueño** — y tú trabajas con `sudo`. El que se queda fuera es el usuario.
>
> Aquí compruebas que solo recorta **donde tú querías que recortara**.

```bash
getfacl -p /srv/samba/departamentos/* 2>/dev/null | grep -B8 "#effective"
```

> [!info] 📖 Qué hace ese código
> - **`getfacl -p .../\*`** saca la ACL de **las seis carpetas de golpe**: el `*` las expande todas.
> - **`grep "#effective"`** busca esa palabra, que `getfacl` **solo escribe cuando la máscara está recortando** un permiso. Si no recorta nada, no aparece.
> - **`-B8`** significa *"y enséñame las 8 líneas de antes"*. Sin eso verías la línea suelta y no sabrías **de qué carpeta** es.
>
> **Si el comando no devuelve nada, no hay ninguna máscara recortando.** Es el `grep` más rentable de la fase: una línea contra seis carpetas.

- **✅ Bien:** aparece **únicamente en `becarios`**, así:
  ```
  # file: srv/samba/departamentos/becarios
  group::rwx			#effective:r-x
  mask::r-x
  ```
- **❌ Mal:** aparece en **cualquier otra carpeta** → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]]:
  ```bash
  sudo setfacl -m m::rwx /srv/samba/departamentos/<la_carpeta>
  ```

> [!success] 🎯 En `becarios` el `#effective` es CORRECTO, y lo has provocado tú
> Esto no es un fallo: **es el Paso 3.b funcionando.**
>
> Cuando ejecutaste `chmod 2750`, la carpeta **ya tenía una ACL** (`rrhh:r-x`). Y en una carpeta con ACL, **el dígito central de `chmod` no toca al grupo dueño: toca a la máscara**. El `5` es `r-x`, y ahí se quedó.
>
> Por eso `group::rwx` sigue diciendo `rwx` y se aplica `r-x`: **los becarios no pueden escribir en su propia carpeta**, que es exactamente lo que pedía la matriz.
>
> **Es el mecanismo del fundamento teórico, en tu servidor y provocado por ti.** Míralo con calma: es la única vez en todo el proyecto que vas a ver la máscara trabajando a tu favor.

> [!danger] 🛑 Y en las demás carpetas sí sería un fallo
> En `facturacion`, `comercial` o `logistica` **no debe aparecer ningún `#effective`**. Si sale, alguien le ha bajado el techo a un grupo que necesitaba escribir — normalmente **un `chmod` inocente** sobre una carpeta que ya tenía ACL.
>
> ```
> group:contabilidad:rwx		#effective:r--
> ```
> **Pone `rwx` y significa `r--`.** El permiso está escrito, es correcto, y no funciona. Si lees la ACL con prisa, ves lo que esperabas ver.
>
> **Lo que está escrito y lo que se aplica pueden ser cosas distintas.**

> [!question] 🤔 Para tu entrada de apuntes
> El mismo mecanismo —la máscara recortando— es **un acierto en `becarios` y un fallo en `facturacion`**. Explica con tus palabras por qué.
>
> *(Pista: la pregunta no es "¿recorta?", sino "¿recorta lo que yo quería que recortara?")*

### **4 · LOS DOS CASOS ESPECIALES**

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Las dos excepciones de la matriz**, que son las que se olvidan:
>
> - **Los becarios** son el único grupo con **solo lectura sobre lo suyo**. La Fase 6 creó las siete carpetas iguales, así que esto lo corregiste a mano en el Paso 3.b.
> - **La carpeta común** conserva su **sticky bit** de la Fase 6: todos escriben, cada uno borra solo lo suyo.
>
> Si falla el primero, en la Fase 8 un becario podrá borrar ficheros y esa prueba se caerá. Si falla el segundo, cualquiera podrá borrar el trabajo de otro.

```bash
stat -c '%n  %U:%G  %a' /srv/samba/departamentos/becarios /srv/samba/comun
ls -ld /srv/samba/departamentos/becarios /srv/samba/comun
```

> [!info] 📖 Qué hace ese código
> **Los dos comandos dicen lo mismo en dos idiomas distintos**, y por eso van juntos:
>
> | Comando | Qué te da | Ejemplo |
> | :--- | :--- | :--- |
> | `stat -c '%n %U:%G %a'` | El permiso **en números** | `2750` |
> | `ls -ld` | El permiso **en letras** | `drwxr-s---` |
>
> En `stat -c`, cada `%` pide un dato: **`%n`** el nombre, **`%U`** el dueño, **`%G`** el grupo y **`%a`** los permisos en octal.
>
> **Necesitas los dos** porque `chmod` habla en números y `ls` contesta en letras — y aquí tienes que reconocer la **`s`** del setgid y la **`t`** del sticky bit, que en octal son ese primer dígito.

- **✅ Bien:**
  - `becarios` → **`2750`**, y en `ls -ld` se lee `drwxr-s---` *(el grupo con `r-x`, **sin `w`**)*
  - `comun` → **`1777`**, con la **`t`** al final
- **❌ Mal:**
  - `becarios` en `2770` → **pueden escribir y borrar**, y la prueba de la Fase 8 fallará. Vuelve al Paso 3.b
  - `comun` sin la `t` → se perdió el sticky bit de la Fase 6

> [!info] 🎓 Los becarios son la única excepción de la matriz
> Todos los departamentos tienen `RW` sobre lo suyo. **Ellos solo `R`.** Y la Fase 6 creó las siete carpetas iguales, porque allí todavía no había política.
>
> Es el tipo de detalle que se salta con facilidad y que **solo se nota dos fases después**.

### **5 · 🔴 LA CONFIGURACIÓN DE SAMBA ES VÁLIDA**

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Que el servidor podrá arrancar mañana.**
>
> `samba-ad-dc` no es solo el servidor de ficheros: **es el controlador de dominio**. Si `smb.conf` tiene una errata, al reiniciar no arranca — y se lleva por delante el **DNS, Kerberos y LDAP** de golpe.
>
> Y aquí está lo traicionero: **el servicio sigue funcionando ahora mismo con el fichero ya roto**, porque solo lo lee al arrancar. Tienes una ventana para descubrirlo, y `testparm` es la forma de usarla.
>
> **Es el mismo reflejo que el `sudo mount -a` de la Fase 6**, con otro nombre.

```bash
sudo testparm
grep -c "^\[" /etc/samba/smb.conf
grep -n "^\[" /etc/samba/smb.conf
```

> [!info] 📖 Qué hace ese código
> - **`testparm`** es el validador que trae Samba: **lee `smb.conf` y te dice si lo entiende**, sin tocar el servicio. Pulsa `Enter` cuando pregunte.
> - **`grep "^\["`** busca las líneas que **empiezan** por un corchete — que son las cabeceras de sección, como `[facturacion]`. El `^` significa *"al principio de línea"*.
> - **`-c`** las **cuenta**; **`-n`** las enseña **con su número de línea**.
>
> Los dos `grep` responden a la misma pregunta desde dos lados: *"¿cuántas secciones hay?"* y *"¿dónde está cada una?"*. **Si el recuento no cuadra con lo que escribiste, la de más está duplicada** — y Samba se queda con la última sin avisar.

- **✅ Bien:** `Loaded services file OK`, y **cada sección aparece una sola vez**.
- **❌ Mal:**
  - Error de sintaxis → [[Fase_7.7_Resolucion_Problemas#E1 · samba-ad-dc no arranca tras editar el smb.conf|caso E1]]
  - Una sección repetida → [[Fase_7.7_Resolucion_Problemas#E7 · Secciones duplicadas en smb.conf|caso E7]]

> [!danger] 🛑 En esta fase, reiniciar Samba a ciegas tumba el DOMINIO
> `samba-ad-dc` **es el controlador de dominio**. Si no arranca por una errata en `smb.conf`, se lleva por delante el DNS, Kerberos y LDAP.
>
> **`testparm` es a `smb.conf` lo que `mount -a` era a `fstab`.** Mismo reflejo, otro servicio.

### **6 · LAS SIETE CARPETAS PUBLICADAS, CON SUS OPCIONES**

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Que Windows va a ver lo que debe y solo lo que debe.**
>
> Los permisos de los puntos anteriores deciden **quién entra**. Estas tres opciones deciden **quién se entera de que la carpeta existe**:
>
> | Opción | Para qué |
> | :--- | :--- |
> | `access based share enum` | Oculta el recurso a quien no tiene acceso |
> | `hide unreadable` | Oculta el contenido que no puede leer |
> | `acl_xattr` | Evita que Windows machaque tus ACL al copiar |
>
> **Sin las dos primeras la protección funciona a medias:** nadie entra donde no debe, pero todos ven que existe una carpeta llamada `rrhh`. Y un nombre de carpeta ya es información.

```bash
for s in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "=== $s"
    testparm -s --section-name="$s" 2>/dev/null | grep -Ei "path|acl_xattr|access based|hide unreadable"
done
testparm -s --section-name=comun 2>/dev/null | grep -Ei "path|acl_xattr"
```

> [!info] 📖 Qué hace ese código
> - **`testparm -s`** saca la configuración **ya interpretada por Samba**, sin esperar a que pulses nada. La `-s` es de *silencioso*.
> - **`--section-name=<recurso>`** pide **solo esa sección**, en vez del fichero entero.
> - **`grep -Ei`** filtra las cuatro opciones que importan. La **`i`** ignora mayúsculas y minúsculas: Samba te devuelve `Yes` aunque tú escribieras `yes`.
> - **La última línea va aparte** porque `comun` **no lleva las opciones de invisibilidad** — todo el mundo tiene acceso, así que no hay nada que ocultarle a nadie.
>
> > [!tip] 💡 Esto NO te enseña lo que escribiste, sino lo que Samba entendió
> > Es la diferencia clave: si duplicaste una sección o te equivocaste de sitio, **el fichero puede decir una cosa y Samba estar aplicando otra**. `testparm -s` te da lo segundo.

- **✅ Bien:** las **seis** de departamento con las tres opciones —`acl_xattr`, `access based share enum = Yes` y `hide unreadable = Yes`— y `comun` con `acl_xattr`.
- **❌ Mal:** falta alguna → [[Fase_7.7_Resolucion_Problemas#E5 · Una carpeta protegida se ve desde Windows|caso E5]] o [[Fase_7.7_Resolucion_Problemas#E8 · Las ACL desaparecen al copiar ficheros desde Windows|caso E8]].

> [!info] 🎓 `testparm -s` te enseña lo que Samba ENTIENDE
> No lo que tú escribiste. Si has duplicado una sección o te has equivocado de sitio, **aquí se ve** — porque muestra la configuración **efectiva**, ya interpretada.

### **7 · LA HERENCIA FUNCIONA DE VERDAD** *(la prueba que importa)*

> [!abstract] 🎯 Qué compruebas aquí, y por qué
> **Que lo que se cree mañana nacerá con los permisos puestos.**
>
> Todo lo anterior comprueba que las ACL **están escritas**. Esto comprueba que **hacen algo**: creas un fichero nuevo y miras si nace con la lista puesta, sin que tú se la pongas.
>
> **Si falla, no se rompe nada hoy.** Los ficheros que ya existen siguen bien. Lo que pasa es que la carpeta **se va degradando sola** durante semanas, hasta que alguien se queja y ya no hay ningún cambio reciente al que señalar.
>
> Es el fallo más difícil de diagnosticar de esta fase, y por eso se prueba en lugar de suponerse.

Los puntos anteriores dicen que las ACL **están escritas**. Este dice que **hacen algo**:

```bash
sudo touch /srv/samba/departamentos/facturacion/prueba_herencia.txt
sudo getfacl -p /srv/samba/departamentos/facturacion/prueba_herencia.txt
```

> [!info] 📖 Qué hace ese código
> - **`touch`** crea un fichero vacío. **No le pones ningún permiso**: esa es la gracia.
> - **`getfacl`** te enseña con qué permisos ha **nacido**.
>
> **Toda la prueba está en no tocar nada.** Si el fichero aparece ya con `comercial` y `contabilidad` en su lista, es porque **la carpeta se los ha puesto sola** — que es exactamente lo que hace la ACL por defecto.
>
> Los dos van con `sudo` **por el mismo motivo**: sin él no puedes ni atravesar una carpeta `2770`.

- **✅ Bien:** el fichero recién creado **ya lleva** `group:comercial` y `group:contabilidad`, sin que tú se los hayas puesto.
- **❌ Mal:** no los lleva → falta la ACL por defecto → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]].

> [!warning] ⚠️ Fíjate en que los DOS comandos llevan `sudo`. Y no es por costumbre
> Prueba a quitárselo al `getfacl`:
> ```bash
> getfacl -p /srv/samba/departamentos/facturacion/prueba_herencia.txt
> ```
> ```
> getfacl: ...: Permission denied
> ```
>
> **Y está bien que falle.** Tú, como `boochan`, no eres `root` ni perteneces al grupo `facturacion`: caes en *otros*, que en una carpeta `2770` tiene **`---`**. Ni siquiera puedes **atravesarla** para llegar al fichero.
>
> **Acabas de comprobar tu propia protección funcionando contra ti mismo.** Sin `sudo`, un administrador es un usuario más.

> [!info] 🎓 Por qué el `getfacl` de la CARPETA sí funcionaba sin `sudo`
> | Qué consultas | ¿Sin `sudo`? | Por qué |
> | :--- | :---: | :--- |
> | La ACL de **la carpeta** | ✅ Sí | Leer los permisos de una carpeta no exige entrar en ella |
> | La ACL de **un fichero de dentro** | ❌ No | Para llegar al fichero hay que **atravesar** la carpeta, y eso pide la `x` |
>
> Ese permiso `x` en un directorio no significa "ejecutar": significa **"puedes pasar por aquí"**. Es de las cosas de Unix que más se malinterpretan, y acabas de tropezarte con ella en vivo.

**Y bórralo:**
```bash
sudo rm -f /srv/samba/departamentos/facturacion/prueba_herencia.txt
```

---

> [!warning] 🛑 LO QUE ESTA LISTA NO PUEDE COMPROBAR
> Todo lo de arriba dice que **el servidor está bien configurado**. Ninguno de esos comandos demuestra que una carpeta sea **invisible** para quien no tiene permiso: eso ocurre en el listado de red que ve un cliente Windows.
>
> **Anota estas cuatro pruebas en tu entrada de apuntes como pendientes.** Las tacharás en la Fase 8:
>
> - [ ] `shinnosuke.nohara` *(becario)* → **no ve** `contabilidad` en el listado de red.
> - [ ] `shinnosuke.nohara` → **no puede borrar** nada en su propia carpeta.
> - [ ] `masao.sato` *(comercial)* → **abre** una factura pero **no puede borrarla**.
> - [ ] `misae.nohara` *(contabilidad)* → **no ve** `rrhh`.
>
> **Una fase que se da por verificada sin haber probado esto está afirmando algo que no ha comprobado.**

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los siete puntos de arriba tú. **En el vídeo tienes que explicarlos.**

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase7.sh
> chmod +x verificar_fase7.sh
> less verificar_fase7.sh
> sudo ./verificar_fase7.sh
> ```

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase7.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase7.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**
> *(El `less` se sale con `q`.)*
>
> **Sube el informe** `verificacion-fase-7.txt` a tu repositorio.

> [!question] 🤔 Para tu entrada de apuntes
> 1. El script tiene una lista `CRUCES` y otra `PROHIBIDOS`. **¿Por qué comprueba también lo que NO debe existir?**
> 2. Anota **dos comprobaciones que hace y que tú no habías hecho a mano**.
> 3. La difícil: **el script dice explícitamente que hay algo que no puede comprobar. ¿Qué es, y por qué no puede?**

---

### ✅ Checklist de este apartado

- [ ] Los seis grupos visibles, los dos volúmenes montados, cada carpeta con su dueño.
- [ ] 🔴 Los **ocho permisos cruzados** puestos, **con su línea `default:`**.
- [ ] 🔴 **`rrhh` y `contabilidad` sin ningún grupo ajeno** en su ACL.
- [ ] 🔴 `#effective` aparece **solo en `becarios`** *(ahí es correcto: lo provoca el `chmod 2750`)* y **en ninguna otra carpeta**.
- [ ] `becarios` en **`2750`** *(sin `w` para su grupo)*.
- [ ] `comun` en **`1777`**, con la **`t`**.
- [ ] 🔴 `sudo testparm` → **`Loaded services file OK`**, y ninguna sección duplicada.
- [ ] Las **seis** de departamento con `acl_xattr`, `access based share enum` y `hide unreadable`.
- [ ] Prueba de herencia hecha, y el fichero **borrado** después.
- [ ] Las **cuatro pruebas pendientes de la Fase 8** anotadas en la entrada.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.7_Resolucion_Problemas]] | [[Fase_7]] | [[Fase_7.8.b_Punto_de_Control]] |
