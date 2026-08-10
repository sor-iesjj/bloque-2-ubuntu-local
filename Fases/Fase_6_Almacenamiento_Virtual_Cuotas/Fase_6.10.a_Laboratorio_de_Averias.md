## Fase 6 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6_Almacenamiento_Virtual_Cuotas]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper el almacenamiento a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 6 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada:
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

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase6.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase6.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**

> [!warning] 🖥️ Ninguna avería te corta el acceso SSH
> No se toca la red ni el servicio SSH. **La única que exige cuidado es la 6**, y no por el acceso: por el arranque.

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
> **🎯 Objetivo** → **🤔 Predice** → **1. Romper** → **2. Comprobar** → **3. Consecuencias** → **4. Reparar** → **🎓 La lección**
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.

---

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 6 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **1** | [[#**AVERÍA 1 · DESMONTAR EL DISCO CON DATOS DENTRO**\|DESMONTAR EL DISCO CON DATOS DENTRO]] |
> | **2** | [[#**AVERÍA 2 · ESCRIBIR CON EL DISCO DESMONTADO**\|ESCRIBIR CON EL DISCO DESMONTADO]] |
> | **3** | [[#**AVERÍA 3 · LLENAR LA CARPETA COMÚN**\|LLENAR LA CARPETA COMÚN]] |
> | **4** | [[#**AVERÍA 4 · 🔴 LA CARPETA QUE PIERDE SU DEPARTAMENTO**\|🔴 LA CARPETA QUE PIERDE SU DEPARTAMENTO]] |
> | **5** | [[#**AVERÍA 5 · QUITAR EL STICKY BIT DE LA CARPETA COMÚN**\|QUITAR EL STICKY BIT DE LA CARPETA COMÚN]] |
> | **6** | [[#**AVERÍA 6 · EL FSTAB ROTO** *(la que da miedo, y por eso se hace aquí)*\|EL FSTAB ROTO]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 1 · DESMONTAR EL DISCO CON DATOS DENTRO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** guardar ficheros en las carpetas de departamento, desmontar el volumen y ver qué pasa con ellos.
>
> **Por qué provocamos esta:** porque es **la llamada de teléfono más frecuente** que recibe un administrador de almacenamiento: *"se han borrado los archivos de contabilidad"*. Casi nunca se han borrado.

> [!question] 🤔 Predice antes de ejecutar
> 1. Tras desmontar, ¿existirán las carpetas de los seis departamentos?
> 2. ¿Estarán dentro los ficheros que has creado?
> 3. ¿Se habrán borrado?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
Primero deja huellas reconocibles en dos departamentos:
```bash
echo "Factura 2026-001 de Boochan S.L." | sudo tee /srv/samba/departamentos/facturacion/factura-001.txt
echo "Balance del primer trimestre"     | sudo tee /srv/samba/departamentos/contabilidad/balance-Q1.txt
ls -l /srv/samba/departamentos/facturacion/ /srv/samba/departamentos/contabilidad/
```
Y ahora desmonta **el volumen entero**:
```bash
sudo umount /srv/samba/departamentos
```

### **2 · Comprobar**
```bash
ls -la /srv/samba/departamentos/
df -h | grep departamentos
mountpoint /srv/samba/departamentos
ls -lh /samba_deptos.img
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ls -la` | La carpeta existe y está **VACÍA** | Ni las seis subcarpetas están |
| `df` | Ya no aparece | El volumen no está montado |
| `mountpoint` | `is not a mountpoint` | Confirmado |
| `ls -lh /samba_deptos.img` | **Sigue midiendo 8 GB** | **Todo está ahí dentro, intacto** |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> Han desaparecido **los seis departamentos de golpe**. Las carpetas, los ficheros, todo. Y no se ha borrado nada: lo único que has hecho es **quitar el disco de detrás de la puerta**.
>
> Y ojo con lo siguiente: si en este momento alguien copiara ficheros en `/srv/samba/departamentos`, irían al **disco del sistema**. Al volver a montar, desaparecerían de la vista.

### **3 · Consecuencias**
Un usuario diría *"se han borrado 8 GB de datos de toda la empresa"*. Un administrador que se lo crea puede llegar a **restaurar una copia de seguridad encima de datos que estaban perfectamente**, y ahí sí se pierde información.

### **4 · Reparar**
```bash
sudo mount -a
ls -l /srv/samba/departamentos/
cat /srv/samba/departamentos/facturacion/factura-001.txt
```
- **✅ Reparado:** vuelven las seis carpetas y los ficheros, con su contenido.

> [!success] 🎓 La lección
> **"No está" y "no lo veo" son cosas distintas**, y en almacenamiento confundirlas cuesta datos de verdad.
>
> La regla práctica: **ante una pérdida de datos, lo primero es NO escribir nada.** Comprueba el montaje antes de restaurar copias. Un `mountpoint` y un `df` de diez segundos separan un susto de un desastre.

---

# **AVERÍA 2 · ESCRIBIR CON EL DISCO DESMONTADO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar datos "fantasma" debajo de un punto de montaje.
>
> **Por qué provocamos esta:** porque explica un misterio clásico: **un disco que dice estar lleno y se ve vacío.**

> [!question] 🤔 Predice antes de ejecutar
> 1. Si escribo con el volumen desmontado, ¿dónde va el fichero?
> 2. Al montar encima, ¿qué pasará con él?
> 3. ¿Ocupará espacio en algún sitio?

### **1 · Romper**
```bash
sudo umount /srv/samba/departamentos
sudo mkdir -p /srv/samba/departamentos/facturacion
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
| `factura-001.txt` **sí** aparece | Estaba dentro del disco |
| `fantasma.txt` **no** aparece | Está debajo del montaje, tapado |

Y ahora **destápalo**:
```bash
sudo umount /srv/samba/departamentos
ls -lR /srv/samba/departamentos/
sudo mount -a
```

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes las dos listas de ficheros**, con el volumen montado y desmontado. Y responde: si esa carpeta escondida acumulase 20 GB, **¿lo verías con `df -h /srv/samba/departamentos`?**

### **3 · Consecuencias**
Espacio ocupado en el disco del sistema que **no aparece en ningún sitio** donde lo busques. Es una de las causas más desconcertantes de *"el disco está lleno y no encuentro qué lo llena"*, y puede tirar un servidor entero.

### **4 · Reparar**
```bash
sudo umount /srv/samba/departamentos
sudo rm -rf /srv/samba/departamentos/facturacion
ls -la /srv/samba/departamentos/
sudo mount -a
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** la carpeta de debajo, vacía; el volumen montado y `FASE 6 SUPERADA`.

> [!danger] ⚠️ Fíjate en que el `rm -rf` va con el disco DESMONTADO
> Si lo ejecutaras montado, **borrarías la carpeta real de facturación con sus datos dentro**. El mismo comando, el mismo camino, y dos resultados completamente distintos según haya un disco detrás o no.
>
> **Comprueba siempre el montaje antes de un borrado recursivo.** Esta es la avería donde eso se entiende de verdad.

> [!success] 🎓 La lección
> **Un punto de montaje tapa lo que hay debajo, no lo borra.** Y lo que queda debajo sigue ocupando espacio, sin salir en el `df` de esa carpeta.
>
> Por eso, cuando un servidor se queda sin disco y las cuentas no cuadran, uno de los primeros sitios donde mirar es **debajo de los montajes**.

---

# **AVERÍA 3 · LLENAR LA CARPETA COMÚN**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** llenar `comun` hasta el tope, con el resto de la empresa trabajando.
>
> **Por qué provocamos esta:** porque es **la razón de que la carpeta común tenga su propio disco**. Vas a comprobar que el vertedero se llena y **no se lleva a nadie por delante**.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se parará el `dd` al llegar a 2 GB, o seguirá?
> 2. ¿Qué les pasará a los seis departamentos mientras tanto?
> 3. ¿Podrá el servidor seguir funcionando?

### **1 · Romper**
```bash
sudo dd if=/dev/zero of=/srv/samba/comun/vertedero.tmp bs=1M count=3000
```

### **2 · Comprobar**
```bash
df -h /srv/samba/comun
df -h /srv/samba/departamentos
df -h /
sudo touch /srv/samba/departamentos/logistica/pedido-nuevo.txt
sudo systemctl is-active samba-ad-dc
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| El `dd` | **Falla** a los ~2 GB | La cuota ha hecho su trabajo |
| `df` de `comun` | **100 %** | Esa carpeta está llena |
| `df` de `departamentos` | **Con sitio de sobra** | Los seis departamentos, intactos |
| `df /` | **Con espacio libre** | El servidor está perfectamente |
| El `touch` en logística | **Funciona** | Se puede seguir trabajando |

> [!success] 🎯 Esto es la decisión de diseño funcionando
> La carpeta donde todo el mundo escribe está **completamente llena**, y la empresa **sigue trabajando**. Logística acaba de crear un fichero sin enterarse de nada.
>
> Si la común hubiera compartido disco con los departamentos, **un usuario subiendo vídeos habría parado a contabilidad, a facturación y a RRHH.**

### **3 · Consecuencias**
Nadie puede dejar nada más en la carpeta común. Y **eso es todo**. Que es exactamente lo que se buscaba al darle un volumen aparte.

### **4 · Reparar**
```bash
sudo rm -f /srv/samba/comun/vertedero.tmp /srv/samba/departamentos/logistica/pedido-nuevo.txt
df -h /srv/samba/comun
```

> [!success] 🎓 La lección
> **Aislar lo que se puede descontrolar.** No se trata de impedir que la carpeta común se llene —se va a llenar—, sino de que cuando pase **no arrastre a nada más**.
>
> Es el mismo criterio por el que un servidor serio pone `/var/log` en su propia partición: los registros crecen sin control, y cuando lo hacen, que llenen **lo suyo**.

---

# **AVERÍA 4 · 🔴 LA CARPETA QUE PIERDE SU DEPARTAMENTO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** devolver la carpeta de `contabilidad` al grupo `root`, como si el `chown` hubiera fallado.
>
> **Por qué provocamos esta:** porque es **el fallo silencioso de la fase**, el [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento|caso E6]], provocado a propósito.
>
> No da ningún error. La carpeta se monta, se escribe y se lee igual. Y **rompe la Fase 7**.

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
stat -c '%U:%G %a' /srv/samba/departamentos/contabilidad
df -h /srv/samba/departamentos
sudo touch /srv/samba/departamentos/contabilidad/prueba_escritura.txt
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ls -ld` | `root root` | El departamento se ha perdido |
| `df` | **Sigue montado** | El almacenamiento está perfecto |
| `touch` | **Funciona** | Se puede escribir sin problemas |
| El verificador | **FALLO en `D2`** | Es lo único que te avisa |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> Has roto la pieza que sostiene la protección de la Fase 7 y **el sistema no ha protestado en ningún momento**. Ni un error, ni un aviso.
>
> Si no hubieras pasado el verificador, habrías guardado la instantánea tan tranquilo.

### **3 · Consecuencias**
En la **Fase 7** darás permisos sobre esta carpeta al grupo `contabilidad` — y también a `facturacion`, que según la matriz puede escribir en ella. Con el grupo puesto a `root`, **nada de eso alcanza a nadie**. Y el error hablará de accesos denegados, sin mencionar esta fase.

### **4 · Reparar**
```bash
sudo rm -f /srv/samba/departamentos/contabilidad/prueba_escritura.txt
sudo chown root:contabilidad /srv/samba/departamentos/contabilidad
sudo chmod 2770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** `root contabilidad`, permisos `2770`, y `FASE 6 SUPERADA`.

> [!success] 🎓 La lección
> **El fallo que no da error es el caro.** Van tres fases con la misma idea, en tres disfraces distintos: el dominio en la tarjeta NAT, los UID automáticos y ahora esto.
>
> Y la consecuencia práctica: **después de un `chown` o un `chmod`, se mira el resultado con `ls -ld`.** Que el comando no proteste no significa que hiciera lo que querías — solo que no encontró motivo para quejarse.

---

# **AVERÍA 5 · QUITAR EL STICKY BIT DE LA CARPETA COMÚN**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** quitar el `1` de `1777` en la carpeta común, y **comprobar con dos trabajadores de verdad** qué cambia.
>
> **Por qué provocamos esta:** porque el sticky bit no protege el acceso —todos pueden entrar igual—, sino **el trabajo de los demás**. Y eso solo se ve haciendo la prueba con dos personas distintas.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrá `misae.nohara` seguir entrando en la común?
> 2. ¿Podrá **borrar** un fichero de `hiroshi.nohara`?
> 3. ¿Qué letra cambia en `ls -ld`?

### **1 · Romper**
Antes de nada, monta el escenario: un fichero de cada uno.
```bash
sudo -u 'BOOCHANLAB\hiroshi.nohara' touch /srv/samba/comun/de-hiroshi.txt
sudo -u 'BOOCHANLAB\misae.nohara'   touch /srv/samba/comun/de-misae.txt
ls -l /srv/samba/comun/
```

**Prueba primero CON el sticky bit puesto** — que `misae` intente borrar lo de `hiroshi`:
```bash
sudo -u 'BOOCHANLAB\misae.nohara' rm /srv/samba/comun/de-hiroshi.txt
```
- **✅ Correcto:** `Operation not permitted`. **El sticky bit la ha frenado.**

Y ahora quítalo:
```bash
sudo chmod 777 /srv/samba/comun
ls -ld /srv/samba/comun
```

### **2 · Comprobar**
Repite exactamente el mismo intento:
```bash
sudo -u 'BOOCHANLAB\misae.nohara' rm /srv/samba/comun/de-hiroshi.txt
ls -l /srv/samba/comun/
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Momento | El `rm` de `misae` sobre el fichero de `hiroshi` |
| :--- | :--- |
| Con `1777` | **Falla:** `Operation not permitted` |
| Con `777` | **Funciona.** El fichero desaparece |
| En `ls -ld` | `drwxrwxrw**t**` pasa a `drwxrwxrw**x**` |
| El verificador | **FALLO en `E1`/`E2`** |

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia las dos salidas del mismo comando `rm`**, la de antes y la de después. Es el mismo comando, el mismo usuario y el mismo fichero — y **un carácter de diferencia en los permisos de la carpeta** decide si funciona.

### **3 · Consecuencias**
Una carpeta compartida entre seis departamentos donde **cualquiera puede borrar el trabajo de cualquiera**. Por error casi siempre, y sin forma de saber quién fue: el fichero simplemente ya no está.

### **4 · Reparar**
```bash
sudo chmod 1777 /srv/samba/comun
ls -ld /srv/samba/comun
sudo -u 'BOOCHANLAB\hiroshi.nohara' touch /srv/samba/comun/de-hiroshi.txt
sudo -u 'BOOCHANLAB\misae.nohara' rm /srv/samba/comun/de-hiroshi.txt
```
- **✅ Reparado:** vuelve la **`t`**, y el `rm` vuelve a fallar con `Operation not permitted`.

**Y limpia los ficheros de prueba:**
```bash
sudo rm -f /srv/samba/comun/de-hiroshi.txt /srv/samba/comun/de-misae.txt
sudo ./verificar_fase6.sh
```

> [!success] 🎓 La lección
> Que los permisos de Unix **no son solo `rwx`**: hay un cuarto dígito que no controla quién entra, sino **qué puede hacerle a lo que hay dentro**.
>
> Y que **una `t` donde esperabas una `x`** es información, no adorno. Míralo:
> ```bash
> ls -ld /tmp
> ```
> `/tmp` lleva la misma `t` desde hace décadas, y por el mismo motivo exacto: es la carpeta donde todo el mundo escribe.

---

# **AVERÍA 6 · EL FSTAB ROTO** *(la que da miedo, y por eso se hace aquí)*

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar `/etc/fstab` con una línea mal escrita — y **detectarlo antes de reiniciar**.
>
> **Por qué provocamos esta:** porque el [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]] es el fallo más aparatoso del proyecto, y hay una diferencia enorme entre encontrártelo por accidente y provocarlo tú con una instantánea reciente.
>
> **Vas a aprender que el paracaídas funciona.**

> [!danger] 🛑 NO REINICIES DURANTE ESTA AVERÍA
> El objetivo es el contrario: **comprobar que `sudo mount -a` te avisa sin necesidad de reiniciar.**
>
> Si reinicias con el `fstab` roto, la máquina se queda en modo emergencia y tendrás que arreglarlo desde la ventana de VirtualBox.
>
> **Antes de empezar, confirma que tienes la instantánea:**
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Dará `mount -a` algún mensaje?
> 2. ¿Se desmontará el volumen que ya estaba montado?
> 3. Si reiniciases ahora, ¿qué pasaría?

### **1 · Romper**
Copia de seguridad primero — **siempre, antes de tocar un fichero de arranque**:
```bash
sudo cp /etc/fstab /etc/fstab.bak
```
Y quita la palabra `loop` de la línea de la carpeta común:
```bash
sudo sed -i 's|\(/samba_comun.img.*\)loop,defaults|\1defaults|' /etc/fstab
grep samba /etc/fstab
```

### **2 · Comprobar**
```bash
sudo umount /srv/samba/comun
sudo mount -a
df -h | grep comun
sudo ./verificar_fase6.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `mount -a` | **Un mensaje de error** | El paracaídas ha funcionado |
| `df` | `comun` no aparece | No ha podido montarse |
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
df -h | grep srv
sudo ./verificar_fase6.sh
```
- **✅ Reparado:** `mount -a` en **silencio**, los dos volúmenes montados y `FASE 6 SUPERADA`.

**Y ahora sí, la prueba de verdad:**
```bash
sudo reboot
```
Cuando vuelva:
```bash
df -h | grep srv
ls -ld /srv/samba/departamentos/*
```
- **✅ Bien:** los dos volúmenes montados y las seis carpetas con su grupo, **sin que hayas hecho nada**.

> [!success] 🎓 La lección
> **`sudo mount -a` es un ensayo del arranque que puedes hacer sin arrancar.** Y por extensión: **cuando toques algo que se ejecuta en el arranque, existe casi siempre una forma de probarlo antes.**
>
> `nginx -t` para un servidor web, `visudo` en lugar de editar `sudoers` a pelo, `netplan try` para la red, y `testparm` que verás en la Fase 7. **El reinicio no es la prueba: es el examen final.** Y a un examen final no se va sin haber ensayado.

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase6.sh
```

- **✅ Bien:** `VEREDICTO: FASE 6 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien.

> [!tip] 💡 Si algo se te ha quedado torcido, tienes la instantánea
> Restaura `Fase 6 terminada` y vuelves al punto bueno. **Para eso la tomaste antes de empezar.**

> [!warning] ⚠️ Comprueba que no te dejas ficheros de prueba
> ```bash
> ls -lR /srv/samba/departamentos/ /srv/samba/comun/
> ```
> Puedes dejar `factura-001.txt` y `balance-Q1.txt` —sirven para la Fase 7—, **pero el resto tiene que estar borrado**, y sobre todo `vertedero.tmp`: son 2 GB.

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y `FASE 6 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotadas las **dos listas de ficheros** de la avería 2 (montado y desmontado).
- [ ] Anotado que en la avería 3 los **departamentos seguían trabajando** con la común al 100 %.
- [ ] Anotadas **las dos salidas del mismo `rm`** en la avería 5, con y sin sticky bit.
- [ ] Avería 6 hecha **sin reiniciar con el `fstab` roto**, y reinicio de comprobación **después** de repararlo.
- [ ] Ficheros de prueba borrados, **`vertedero.tmp` incluido**.
- [ ] Verificador pasado al final: `FASE 6 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F6 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.9_Preguntas]] | [[Fase_6_Almacenamiento_Virtual_Cuotas]] | [[Fase_6.10.b_Auditoria_y_Cierre]] |
