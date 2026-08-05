## Fase 6 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper el almacenamiento a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 6 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_6.8.b_Punto_de_Control]].
>
> **En esta fase el requisito es más serio que en las anteriores.** La avería 6 toca el fichero que decide si el servidor arranca.

> [!info] 🤖 Vas a usar el verificador en cada avería
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase6.sh
> chmod +x verificar_fase6.sh
> ```

> [!warning] 🖥️ Ninguna de estas averías te corta el acceso SSH
> No se toca la red ni el servicio SSH. Puedes trabajar cómodamente por sesión remota.
>
> **La única que exige cuidado es la 6**, y no por el acceso: por el arranque. Se explica ahí.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> El almacenamiento falla de una forma muy particular: **los datos parecen desaparecer sin que nadie los haya borrado.** Un disco desmontado, una carpeta tapada por un montaje, una cuota llena — y en los tres casos el usuario dice lo mismo: *"se han borrado mis archivos"*.
>
> Aquí vas a aprender a distinguir **"no está"** de **"no lo veo"**, que en almacenamiento es la diferencia entre un susto y un desastre.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3** | El **montaje**: datos que se ven y no se ven |
> | **2.ª** | **4 · 5 · 6** | Los **permisos y la persistencia**: lo que no se nota hoy |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F6 · Laboratorio de averías`, con sus seis timestamps.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada.

> [!tip] 💡 Las seis averías siguen siempre el mismo guion
> | Paso | Qué se hace |
> | :--- | :--- |
> | **🎯 Objetivo** | Qué vas a provocar y qué dejará de funcionar, en cadena |
> | **🤔 Predice** | Escribes qué crees que va a pasar, **antes** de ejecutar |
> | **1. Romper** | El comando que provoca la avería |
> | **2. Comprobar** | Qué comando lo detecta y **cómo se interpreta** |
> | **3. Consecuencias** | Qué daño hace |
> | **4. Reparar** | El comando que lo arregla y **cómo confirmar** que se arregló |
> | **🎓 La lección** | La idea que te llevas |
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.

---

# **AVERÍA 1 · DESMONTAR EL DISCO CON DATOS DENTRO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** guardar un fichero en `facturacion`, desmontar el disco y ver qué pasa con él.
>
> **Por qué provocamos esta:** porque es **la llamada de teléfono más frecuente** que recibe un administrador de almacenamiento: *"se han borrado los archivos de la carpeta compartida"*. Casi nunca se han borrado.

> [!question] 🤔 Predice antes de ejecutar
> 1. Tras desmontar, ¿existirá la carpeta `/srv/samba/departamentos/facturacion`?
> 2. ¿Estará dentro el fichero que has creado?
> 3. ¿Se habrá borrado?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
Primero deja una huella reconocible:
```bash
echo "Este fichero vive DENTRO del disco virtual" | sudo tee /srv/samba/departamentos/facturacion/importante.txt
ls -l /srv/samba/departamentos/facturacion/
```
Y ahora desmonta:
```bash
sudo umount /srv/samba/departamentos/facturacion
```

### **2 · Comprobar**
```bash
ls -la /srv/samba/departamentos/facturacion/
df -h | grep facturacion
mountpoint /srv/samba/departamentos/facturacion
ls -l /samba_deptos.img
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ls -la` | **La carpeta existe, y está VACÍA** | Estás viendo la carpeta del sistema, no el disco |
| `df` | Ya no aparece | El disco no está montado |
| `mountpoint` | `is not a mountpoint` | Confirmado |
| `ls -l /samba_deptos.img` | **Sigue midiendo 5 GB** | **Tus datos están ahí dentro, intactos** |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> La carpeta **no ha desaparecido**. El fichero **no se ha borrado**. Lo único que ha pasado es que has quitado el disco de detrás de la puerta, y ahora ves la puerta vacía.
>
> Si en este momento alguien copiara ficheros nuevos en `/srv/samba/departamentos/facturacion`, irían al **disco del sistema**. Y al volver a montar, desaparecerían de la vista — tapados debajo del montaje.

### **3 · Consecuencias**
Un usuario diría *"se han borrado 5 GB de datos"*. Un administrador que se lo crea puede llegar a restaurar una copia de seguridad encima **sobre datos que estaban perfectamente**, y ahí sí se pierde información.

### **4 · Reparar**
```bash
sudo mount -a
ls -l /srv/samba/departamentos/facturacion/
```
- **✅ Reparado:** `importante.txt` vuelve a estar ahí, con su contenido.

> [!success] 🎓 La lección
> **"No está" y "no lo veo" son cosas distintas**, y en almacenamiento confundirlas cuesta datos de verdad.
>
> La regla práctica: **ante una pérdida de datos, lo primero es NO escribir nada.** Comprueba el montaje antes de restaurar copias. Un `mountpoint` y un `df` de diez segundos separan un susto de un desastre.

---

# **AVERÍA 2 · ESCRIBIR EN LA CARPETA CON EL DISCO DESMONTADO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar datos "fantasma" debajo de un punto de montaje.
>
> **Por qué provocamos esta:** porque es la continuación natural de la avería 1 y explica un misterio clásico: **un disco que dice estar lleno y se ve vacío.**

> [!question] 🤔 Predice antes de ejecutar
> 1. Si escribo con el disco desmontado, ¿dónde va el fichero?
> 2. Al montar encima, ¿qué pasará con él?
> 3. ¿Ocupará espacio en algún sitio?

### **1 · Romper**
```bash
sudo umount /srv/samba/departamentos/facturacion
echo "Fichero fantasma: escrito con el disco desmontado" | sudo tee /srv/samba/departamentos/facturacion/fantasma.txt
ls -l /srv/samba/departamentos/facturacion/
sudo mount -a
```

### **2 · Comprobar**
```bash
ls -l /srv/samba/departamentos/facturacion/
```

**Cómo se interpreta lo que sale:**

| Qué verás | Qué significa |
| :--- | :--- |
| `importante.txt` **sí** aparece | Es el que estaba dentro del disco |
| `fantasma.txt` **no** aparece | Está debajo del montaje, tapado |

Y ahora **destápalo**:
```bash
sudo umount /srv/samba/departamentos/facturacion
ls -l /srv/samba/departamentos/facturacion/
sudo mount -a
```

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes las dos listas de ficheros**, con el disco montado y desmontado. Y responde: si esa carpeta escondida acumulase 20 GB, ¿lo verías con `df -h /srv/samba/departamentos/facturacion`?

### **3 · Consecuencias**
Espacio ocupado en el disco del sistema que **no aparece en ningún sitio** donde lo busques. Es una de las causas más desconcertantes de *"el disco está lleno y no encuentro qué lo llena"*, y puede tirar un servidor entero.

### **4 · Reparar**
```bash
sudo umount /srv/samba/departamentos/facturacion
sudo rm -f /srv/samba/departamentos/facturacion/fantasma.txt
ls -la /srv/samba/departamentos/facturacion/
sudo mount -a
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** la carpeta de debajo, vacía; el disco montado y el verificador en `FASE 6 SUPERADA`.

> [!success] 🎓 La lección
> **Un punto de montaje tapa lo que hay debajo, no lo borra.** Y lo que queda debajo sigue ocupando espacio, sin salir en el `df` de esa carpeta.
>
> Por eso, cuando un servidor se queda sin disco y las cuentas no cuadran, uno de los primeros sitios donde mirar es **debajo de los montajes**.

---

# **AVERÍA 3 · LLENAR LA CUOTA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** llenar `facturacion` hasta el tope, con el servidor teniendo espacio de sobra.
>
> **Por qué provocamos esta:** porque es **la fase entera en un comando**. Vas a ver un `No space left on device` mientras `df -h /` dice que hay gigas libres.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se parará el `dd` al llegar a 5 GB, o seguirá?
> 2. ¿Qué dirá `df -h /` mientras tanto?
> 3. ¿Podrá el servidor seguir funcionando con esa carpeta llena?

### **1 · Romper**
```bash
sudo dd if=/dev/zero of=/srv/samba/departamentos/facturacion/relleno.tmp bs=1M count=6000
```

### **2 · Comprobar**
```bash
df -h | grep facturacion
df -h /
sudo systemctl is-active samba-ad-dc
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| El `dd` | **Falla** a los ~5 GB | La cuota ha hecho su trabajo |
| `df` de `facturacion` | **100 %** | Esa carpeta está llena |
| `df /` | **Con espacio libre** | El servidor está perfectamente |
| `samba-ad-dc` | `active` | El dominio ni se ha enterado |

### **3 · Consecuencias**
Los usuarios de esa carpeta no pueden guardar nada más. **Y el resto del servidor sigue funcionando con normalidad** — que es exactamente lo que se buscaba al ponerle un límite.

### **4 · Reparar**
```bash
sudo rm -f /srv/samba/departamentos/facturacion/relleno.tmp
df -h | grep facturacion
```
- **✅ Reparado:** la carpeta vuelve a estar casi vacía.

> [!success] 🎓 La lección
> **Esto es una cuota, y esto es para lo que sirve.** Sin ella, un solo usuario descargando películas llenaría el disco del servidor y **tiraría el dominio, el correo y todo lo demás**.
>
> Con ella, el que se pasa se queda sin sitio **él**, y nadie más se entera. Es exactamente lo que hace tu proveedor de correo cuando te dice que tu buzón está lleno mientras sus servidores tienen petabytes libres.

---

# **AVERÍA 4 · 🔴 LA CARPETA QUE PIERDE SU GRUPO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** devolver `contabilidad` al grupo `root`, como si el `chown` hubiera fallado.
>
> **Por qué provocamos esta:** porque es **el fallo silencioso de la fase**, el [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento|caso E6]], provocado a propósito.
>
> No da ningún error. La carpeta se monta, se escribe y se lee igual. Y **rompe la Fase 7** dentro de una semana.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se quejará el sistema al cambiar el grupo?
> 2. ¿Seguirá funcionando la carpeta?
> 3. ¿Lo detectará el verificador?
>
> **La 2 es la importante.** Escríbela antes de mirar.

### **1 · Romper**
Primero **mira y anota** lo que hay ahora:
```bash
ls -ld /srv/samba/departamentos/contabilidad
```
Y ahora rómpelo:
```bash
sudo chown root:root /srv/samba/departamentos/contabilidad
```

### **2 · Comprobar**
```bash
ls -ld /srv/samba/departamentos/contabilidad
stat -c '%U %G %a' /srv/samba/departamentos/contabilidad
df -h | grep contabilidad
sudo touch /srv/samba/departamentos/contabilidad/prueba_escritura.txt
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ls -ld` | `root root` | El grupo se ha perdido |
| `df` | **Sigue montado** | El almacenamiento está perfecto |
| `touch` | **Funciona** | Se puede escribir sin problemas |
| El verificador | **FALLO en `D2`** | Es lo único que te avisa |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> Has roto la pieza que sostiene la protección de la Fase 7 y **el sistema no ha protestado en ningún momento**. Ni un error, ni un aviso.
>
> Si no hubieras pasado el verificador, habrías guardado la instantánea tan tranquilo.

### **3 · Consecuencias**
En la **Fase 7** protegerás esta carpeta para que solo la vea el grupo `contabilidad`. Con el grupo puesto a `root`, esa protección **no alcanza a nadie**: o no entra ningún usuario del dominio, o la restricción no filtra nada. Y el error hablará de accesos denegados, sin mencionar esta fase.

### **4 · Reparar**
```bash
sudo rm -f /srv/samba/departamentos/contabilidad/prueba_escritura.txt
sudo chown root:contabilidad /srv/samba/departamentos/contabilidad
sudo chmod 2770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** `root contabilidad`, permisos `2770`, y el verificador en `FASE 6 SUPERADA`.

> [!success] 🎓 La lección
> **El fallo que no da error es el caro.** Van cuatro fases con la misma idea, en cuatro disfraces distintos.
>
> Y la consecuencia práctica: **después de un `chown` o un `chmod`, se mira el resultado con `ls -ld`.** Que el comando no proteste no significa que hiciera lo que querías — solo que no encontró un motivo para quejarse.

---

# **AVERÍA 5 · QUITAR EL BIT SETGID**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** cambiar `2770` por `770` en `contabilidad`.
>
> **Por qué provocamos esta:** porque enseña qué hace ese cuarto dígito que casi nadie mira, y porque el daño **solo aparece con los ficheros que se creen a partir de ahora**.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Cambiará algo en los ficheros que ya existen?
> 2. ¿Y en los nuevos?
> 3. ¿Verás alguna diferencia en `ls -ld`?

### **1 · Romper**
```bash
sudo chmod 770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
```

### **2 · Comprobar**
Fíjate en la letra que ha cambiado y crea un fichero nuevo:
```bash
ls -ld /srv/samba/departamentos/contabilidad
sudo touch /srv/samba/departamentos/contabilidad/sin_setgid.txt
ls -l /srv/samba/departamentos/contabilidad/
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Dónde miras | Antes | Ahora |
| :--- | :--- | :--- |
| `ls -ld` | `drwxrw**s**---` | `drwxrw**x**---` |
| Grupo del fichero nuevo | `contabilidad` | El grupo de quien lo creó |
| El verificador | OK | **FALLO en `D3`** |

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes las dos salidas de `ls -ld`**, la de antes y la de ahora, y **señala la letra exacta que cambia**. Es un solo carácter, y decide el comportamiento de toda la carpeta.

### **3 · Consecuencias**
Una carpeta compartida que se va llenando de ficheros que **los demás miembros del grupo no pueden modificar**. El síntoma llega semanas después y en forma de *"no puedo editar el documento de mi compañero"*, que no suena en absoluto a un permiso de carpeta.

### **4 · Reparar**
```bash
sudo rm -f /srv/samba/departamentos/contabilidad/sin_setgid.txt
sudo chmod 2770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** vuelve la **`s`** y el verificador da `FASE 6 SUPERADA`.

> [!success] 🎓 La lección
> Que los permisos de Unix **no son solo `rwx`**: hay un cuarto dígito que no controla quién entra, sino **cómo se comporta lo que se crea dentro**.
>
> Y que **leer una salida de `ls -l` es una habilidad**. Una `s` donde esperabas una `x` es información, y quien no la sabe leer no puede diagnosticar esto ni buscándolo.

---

# **AVERÍA 6 · EL FSTAB ROTO** *(la que da miedo, y por eso se hace aquí)*

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar `/etc/fstab` con una línea mal escrita — y **detectarlo antes de reiniciar**.
>
> **Por qué provocamos esta:** porque el [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]] es el fallo más aparatoso del proyecto, y hay una diferencia enorme entre encontrártelo por accidente y provocarlo tú con una instantánea reciente.
>
> **Vas a aprender que el paracaídas funciona.**

> [!danger] 🛑 NO REINICIES DURANTE ESTA AVERÍA
> El objetivo es exactamente el contrario: **comprobar que `sudo mount -a` te avisa sin necesidad de reiniciar.**
>
> Si reinicias con el `fstab` roto, la máquina se queda en modo emergencia y tendrás que arreglarlo desde la ventana de VirtualBox — que se puede, pero no es lo que toca hoy.
>
> **Y antes de empezar, confirma que tienes la instantánea:**
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Dará `mount -a` algún mensaje?
> 2. ¿Se desmontará el disco que ya estaba montado?
> 3. Si reiniciases ahora, ¿qué pasaría?

### **1 · Romper**
Copia de seguridad primero — **siempre, antes de tocar un fichero de arranque**:
```bash
sudo cp /etc/fstab /etc/fstab.bak
```
Y ahora quita la palabra `loop` de la línea de `contabilidad`:
```bash
sudo sed -i 's|\(/samba_comun.img.*\)loop,defaults|\1defaults|' /etc/fstab
grep samba /etc/fstab
```

### **2 · Comprobar**
```bash
sudo umount /srv/samba/departamentos/contabilidad
sudo mount -a
df -h | grep contabilidad
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `mount -a` | **Un mensaje de error** | El paracaídas ha funcionado |
| `df` | `contabilidad` no aparece | No ha podido montarse |
| El verificador | **FALLO en `C2-ter`** | Y te dice que no reinicies |

> [!success] 🎯 Esto es lo que tenías que ver
> **El error ha salido en tu terminal, no en el arranque.** Has descubierto el problema estando sentado delante de un servidor que funciona, en lugar de delante de uno que no enciende.
>
> **Esa es toda la diferencia**, y son diez segundos de comando.

### **3 · Consecuencias**
Si esto hubiera pasado sin que lo comprobaras, el servidor **no habría arrancado** en el siguiente encendido. Y el siguiente encendido no lo eliges tú: llega con un corte de luz, una actualización o el reinicio de fin de clase.

### **4 · Reparar**
```bash
sudo mv /etc/fstab.bak /etc/fstab
grep samba /etc/fstab
sudo mount -a
df -h | grep prueba
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** `mount -a` en **silencio**, los dos discos montados y `FASE 6 SUPERADA`.

**Y ahora sí, la prueba de verdad:**
```bash
sudo reboot
```
Cuando vuelva:
```bash
df -h | grep prueba
```
- **✅ Bien:** los dos discos montados **sin que hayas hecho nada**.

> [!success] 🎓 La lección
> **`sudo mount -a` es un ensayo del arranque que puedes hacer sin arrancar.** Y por extensión: **cuando toques algo que se ejecuta en el arranque, existe casi siempre una forma de probarlo antes.**
>
> `nginx -t` para un servidor web, `visudo` en lugar de editar `sudoers` a pelo, `netplan try` para la red. **El reinicio no es la prueba: es el examen final.** Y a un examen final no se va sin haber ensayado.

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase6.sh
```

- **✅ Bien:** `VEREDICTO: FASE 6 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien. Vuelve a ella.

> [!warning] ⚠️ Comprueba que no te dejas ficheros de prueba
> Las averías crean `importante.txt`, `fantasma.txt`, `relleno.tmp`, `prueba_escritura.txt` y `sin_setgid.txt`.
> ```bash
> ls -la /srv/samba/departamentos/facturacion/ /srv/samba/departamentos/contabilidad/
> ```
> `importante.txt` puedes dejarlo —sirve para la Fase 7—, **pero el resto tiene que estar borrado**, y sobre todo `relleno.tmp`: son 5 GB.

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y `FASE 6 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotadas las **dos listas de ficheros** de la avería 2 (montado y desmontado).
- [ ] Anotado que en la avería 3 el `df /` **tenía espacio libre** mientras la carpeta estaba al 100 %.
- [ ] Anotada **la letra exacta** que cambia en `ls -ld` en la avería 5.
- [ ] Avería 6 hecha **sin reiniciar con el `fstab` roto**, y reinicio de comprobación **después** de repararlo.
- [ ] Ficheros de prueba borrados, **`relleno.tmp` incluido**.
- [ ] Verificador pasado al final: `FASE 6 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F6 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.9_Preguntas]] | [[Fase_6]] | [[Fase_6.10.b_Auditoria_y_Cierre]] |
