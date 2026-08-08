## Fase 1 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper cosas a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 1 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_1.8.b_Punto_de_Control]].

> [!danger] 🖥️ ESTE APARTADO SE HACE ENTERO EN LA VENTANA DE VIRTUALBOX
> **No lo hagas por SSH.** Cinco de las seis averías **cortan tu propio acceso remoto** — es justo lo que enseñan.
>
> Si las lanzas por SSH, la conexión se te caerá a mitad y no podrás ni comprobar ni reparar. Tendrás que ir a la ventana de VirtualBox igualmente, pero a ciegas y con el vídeo ya empezado.
>
> **La consola de VirtualBox es el salvavidas de un servidor.** Hoy lo vas a usar seis veces seguidas.

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script del apartado [[Fase_1.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase1.sh
> chmod +x verificar_fase1.sh
> ```

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase1.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase1.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Hasta ahora has comprobado que **todo va bien**. Y eso enseña la mitad.
>
> La otra mitad es saber **qué se ve cuando va mal**. Un técnico no se distingue por montar sistemas — se distingue por **reconocer un síntoma** y saber de dónde viene.
>
> No estás perdiendo el tiempo: estás aprendiendo a leer un sistema roto **en condiciones controladas**, en vez de la primera vez que te pase de verdad y con prisa.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> Seis averías con predicción, rotura, comprobación y reparación son **cerca de una hora**. En una sesión de clase no caben, y hacerlas con prisa es justo lo contrario de lo que se busca aquí.
>
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3 · 4** | Todas son de **red**. Y la pareja **3+4** hay que hacerla seguida: el contraste entre el fallo que calla y el que grita es la idea que más lejos llega |
> | **2.ª** | **5 · 6** | Las dos son de **SSH**. La 6 acaba tocando tu propio Windows |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F1 · Laboratorio de averías`, con sus seis timestamps. Solo lo grabas en dos ratos: pausa OBS al terminar la avería 4 y reanuda al día siguiente.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada:
> ```bash
> sudo ./verificar_fase1.sh
> ```
> Si no sale `FASE 1 SUPERADA`, es que algo de la sesión anterior quedó sin reparar. **Arréglalo antes de seguir**, o arrastrarás un fallo y creerás que lo ha causado la avería 5.

> [!tip] 💡 Las seis averías siguen siempre el mismo guion
> | Paso | Qué se hace |
> | :--- | :--- |
> | **🎯 Objetivo** | Qué vas a aprender y por qué merece la pena |
> | **🤔 Predice** | Escribes qué crees que va a pasar, **antes** de ejecutar |
> | **1. Romper** | El comando que provoca la avería |
> | **2. Comprobar** | Qué comando lo detecta y **cómo se interpreta** |
> | **3. Consecuencias** | Qué daño hace |
> | **4. Reparar** | El comando que lo arregla y **cómo confirmar** que se arregló |
> | **🎓 La lección** | La idea que te llevas |
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.

---

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 6 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **1** | [[#**AVERÍA 1 · TUMBAR LA TARJETA DEL LABORATORIO**\|TUMBAR LA TARJETA DEL LABORATORIO]] |
> | **2** | [[#**AVERÍA 2 · DESCONECTAR EL CABLE VIRTUAL**\|DESCONECTAR EL CABLE VIRTUAL]] |
> | **3** | [[#**AVERÍA 3 · BORRAR LA IP DEL `netplan` — EL FALLO SILENCIOSO**\|BORRAR LA IP DEL `netplan` — EL FALLO SILENCIOSO]] |
> | **4** | [[#**AVERÍA 4 · ROMPER LA INDENTACIÓN — EL FALLO RUIDOSO**\|ROMPER LA INDENTACIÓN — EL FALLO RUIDOSO]] |
> | **5** | [[#**AVERÍA 5 · PARAR SSH (Y LA SORPRESA DEL PUERTO ABIERTO)**\|PARAR SSH (Y LA SORPRESA DEL PUERTO ABIERTO)]] |
> | **6** | [[#**AVERÍA 6 · BORRAR LAS CLAVES DE HOST**\|BORRAR LAS CLAVES DE HOST]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 1 · TUMBAR LA TARJETA DEL LABORATORIO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** bajar la tarjeta `enp0s8` **dejando su configuración intacta**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. La tarjeta pasa a estado `DOWN`
> 2. Al caer, **la IP `10.10.10.10` desaparece de la vista**
> 3. Tu Windows deja de llegar al servidor: `ping` y `ssh` fallan
>
> **Por qué provocamos esta:** porque el servicio SSH **sigue funcionando perfectamente** mientras nada de eso llega. Es la avería que separa *"el servicio está caído"* de *"no llego a él"* — y confundir las dos cosas es el error de diagnóstico más caro que existe.

> [!question] 🤔 Predice antes de ejecutar
> Con la tarjeta caída:
> 1. ¿Seguirá `10.10.10.10` en `/etc/netplan/`?
> 2. ¿Seguirá `sshd` escuchando en el puerto 22?
> 3. Desde tu Windows, ¿qué error dará `ssh`: `refused` o `timed out`?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
```bash
sudo ip link set enp0s8 down
```

### **2 · Comprobar**
```bash
ip -brief addr show enp0s8
ip a show enp0s8
sudo ss -tlnp | grep ":22 "
sudo grep -r 10.10.10.10 /etc/netplan/
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ip -brief addr` | `enp0s8   DOWN` **y ninguna IP** | La IP no se ha borrado: no se enseña porque el enlace está caído |
| `ip a` | `<BROADCAST,MULTICAST>` y `state DOWN` | Han desaparecido las marcas `UP` y `LOWER_UP` |
| `ss -tlnp` | **`sshd` SIGUE escuchando en el 22** | El servicio está perfecto. El problema no es suyo |
| `grep` en netplan | La IP **sigue en el fichero** | La configuración está intacta |

**Y desde tu Windows:**
```
ping 10.10.10.10
ssh boochan@10.10.10.10
```
Los dos fallan. El `ssh` dará **`timed out`**, no `refused`: no es que te rechacen, es que **no llegas**.

### **3 · Consecuencias**
El servidor está **vivo y sano** y es **completamente inalcanzable**. Si esto pasara en la Fase 8, el cliente Windows no encontraría el dominio y el error que vería el usuario sería *"no se puede contactar con el controlador"* — que no apunta a esta tarjeta ni de lejos.

### **4 · Reparar**
```bash
sudo ip link set enp0s8 up
```
Espera unos segundos y confirma:
```bash
ip -brief addr show enp0s8
```
- **✅ Reparado:** vuelve a salir `UP` **con `10.10.10.10/24`**, sin que hayas tenido que escribir la IP.

> [!info] 💡 ¿Por qué vuelve sola la IP?
> Porque nunca se fue del fichero. `netplan` había dejado la dirección **asociada a la tarjeta**; al levantarla, el sistema se la vuelve a poner. **No has reconfigurado nada: solo has encendido la luz.**

> [!success] 🎓 La lección
> **"No me responde" no significa "está caído".**
>
> Un servicio puede estar impecable y no llegarle nadie. Antes de tocar el servicio, comprueba si el problema está en el camino: `ss` te dice si escucha, y `timed out` frente a `refused` te dice en qué mitad del camino está el fallo.

---

# **AVERÍA 2 · DESCONECTAR EL CABLE VIRTUAL**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** desmarcar `Cable conectado` del Adaptador 2 **en VirtualBox**, sin tocar nada dentro de Ubuntu.
>
> **Por qué provocamos esta:** porque el síntoma se parece muchísimo al de la avería 1 —la red no va— pero **la causa está fuera del sistema operativo**. Vas a aprender a distinguirlas mirando la salida, que es lo que tendrás cuando te pase de verdad.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrá Ubuntu **saber** que el cable no está, o solo verá la tarjeta caída?
> 2. ¿Se parecerá la salida a la de la avería 1, o habrá alguna diferencia?
> 3. ¿Serviría de algo hacer `sudo ip link set enp0s8 up`?

### **1 · Romper**
Con la VM **encendida**, en VirtualBox:

`Configuración` → **`Red`** → **`Adaptador 2`** → **desmarca `Cable conectado`** → `Aceptar`.

*(Se puede hacer en caliente: no hace falta apagar la máquina.)*

### **2 · Comprobar**
```bash
ip a show enp0s8
ip -brief addr show enp0s8
```

> [!important] ✍️ Aquí no te doy la salida: cópiala tú
> **Anota en tu entrada de apuntes la línea completa de estado** que devuelve `ip a show enp0s8`, la de las marcas entre `<` y `>`.
>
> Después **compárala con la que anotaste en la avería 1**. Hay una diferencia, y encontrarla tú vale mucho más que leerla aquí.
>
> **Pista de dónde mirar:** en las marcas entre `<` y `>`, y en si aparece la palabra `UP` en algún sitio.

### **3 · Consecuencias**
Las mismas que la avería 1 de puertas afuera: nadie llega al servidor. Pero **la reparación es distinta**, y por eso importa distinguirlas.

### **4 · Reparar**
Vuelve a **marcar `Cable conectado`** en VirtualBox. Después:
```bash
ip -brief addr show enp0s8
```
- **✅ Reparado:** `UP` con `10.10.10.10/24`.

> [!question] 🤔 Y ahora responde
> ¿Sirvió de algo `sudo ip link set enp0s8 up`? **Pruébalo con el cable aún desconectado** y anota qué pasa.

> [!success] 🎓 La lección
> **El sistema operativo puede saber que el fallo no es suyo, y te lo dice — si sabes leerlo.**
>
> En una máquina virtual, "el cable" es una casilla del hipervisor. En una máquina física es un cable de verdad, un puerto de switch o una tarjeta muerta. El síntoma que ve el sistema es **el mismo**.
>
> Cuando la red no va, **mira una capa más abajo antes de reconfigurar nada**.

---

# **AVERÍA 3 · BORRAR LA IP DEL `netplan` — EL FALLO SILENCIOSO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** quitar la dirección del fichero de configuración y aplicarlo.
>
> **Por qué provocamos esta:** porque **no vas a ver ningún error**. El comando no protesta, termina bien, y te deja el servidor sin dirección. Es la clase de fallo que más caro sale: el que se aplica en silencio.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Dirá algo `netplan apply`?
> 2. ¿Quedará la tarjeta `UP` o `DOWN`?
> 3. ¿Podrá el servidor hacerse `ping` a sí mismo en `10.10.10.10`?

### **1 · Romper**
Primero **guarda una copia**, que es lo que harías siempre antes de tocar una configuración:
```bash
sudo cp /etc/netplan/00-installer-config.yaml ~/netplan.bak
```
Ahora edita el fichero y **borra las dos líneas de la dirección**:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
Deja el bloque de `enp0s8` así:
```yaml
    enp0s8:
       dhcp4: false
```
Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y aplica:
```bash
sudo netplan apply
```

### **2 · Comprobar**
```bash
ip -brief addr show enp0s8
ping -c2 10.10.10.10
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `netplan apply` | **NADA. Ni una línea.** Y termina bien | Ha hecho exactamente lo que le pediste. El error es tuyo, no suyo |
| `ip -brief addr` | `enp0s8   UP   fe80::…/64` | La tarjeta está **levantada y sin dirección IPv4**. Solo le queda la dirección local IPv6, que no sirve aquí |
| `ping` a sí mismo | `100% packet loss` | El servidor **no se encuentra ni a sí mismo** en esa dirección, porque ya no es suya |

### **3 · Consecuencias**
El servidor arranca, funciona, sale a internet por NAT… y **es invisible en la red del laboratorio**. Y como no hay ningún mensaje de error en ningún sitio, puedes tardar mucho en mirar aquí.

### **4 · Reparar**
```bash
sudo cp ~/netplan.bak /etc/netplan/00-installer-config.yaml
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
```
Confirma:
```bash
ip -brief addr show enp0s8
```
- **✅ Reparado:** vuelve `10.10.10.10/24`.

> [!warning] ⚠️ El `chmod 600` no es adorno
> Si el fichero queda con permisos abiertos, `netplan` avisará en cada ejecución de que la configuración es legible por cualquiera. Al copiar un fichero desde tu carpeta personal, los permisos que viajan son los de la copia. **Devuélveselos.**

> [!success] 🎓 La lección
> **Un comando que termina bien no significa que haya hecho lo que querías.**
>
> `netplan apply` hizo su trabajo impecablemente: aplicó una configuración incorrecta. Los ordenadores no distinguen entre lo que pides y lo que necesitas.
>
> Por eso se verifica **después** de aplicar, siempre. La ausencia de error no es una comprobación.

---

# **AVERÍA 4 · ROMPER LA INDENTACIÓN — EL FALLO RUIDOSO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** desalinear una línea del fichero YAML.
>
> **Por qué provocamos esta:** porque es **la pareja opuesta de la avería 3**, y hay que hacerlas seguidas para ver el contraste. Aquí el sistema **grita**, te dice fichero, línea y columna… y **no rompe nada**.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se quedará el servidor sin IP, como en la avería 3?
> 2. ¿Cuál de las dos averías es más peligrosa: la que avisa o la que calla?

### **1 · Romper**
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
Añade **un espacio de más** delante de `addresses:`, para que quede desalineado respecto a `dhcp4:`:
```yaml
    enp0s8:
       dhcp4: false
         addresses:
           - 10.10.10.10/24
```
Guarda y aplica:
```bash
sudo netplan apply
```

### **2 · Comprobar**
```bash
ip -brief addr show enp0s8
sudo netplan get
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `netplan apply` | `Invalid YAML: inconsistent indentation:` con **fichero, línea y columna**, y una flecha `^` señalando | Ha **rechazado** el fichero. No ha aplicado nada |
| `ip -brief addr` | **`10.10.10.10/24` SIGUE AHÍ** | La red no se ha tocado. Sigue viva la configuración anterior |
| `netplan get` | El mismo mensaje de error | El fichero sigue roto, esperando |

### **3 · Consecuencias**
**Ninguna hoy.** Y ese es exactamente el peligro: la red funciona, tú crees que guardaste los cambios, y **al primer reinicio te quedas sin configuración de red**. El fallo llega días después, cuando ya no recuerdas qué tocaste.

### **4 · Reparar**
Quita el espacio sobrante y vuelve a aplicar:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
sudo netplan apply
sudo netplan get
```
- **✅ Reparado:** `netplan apply` no dice nada y `netplan get` te devuelve la configuración **sin mensajes de error**.

> [!danger] ⚠️ Cuidado: `netplan get` te miente si solo miras si "ha fallado"
> `netplan get` **imprime el error pero termina como si todo hubiera ido bien**. Comprobado en Ubuntu 26.04.
>
> Si automatizas una comprobación mirando solo si el comando falló, **te dirá que todo está correcto con el fichero roto**. Hay que **leer la salida**.
>
> El script del apartado 8.a lo hace así por este motivo exacto.

> [!success] 🎓 La lección
> **El fallo que te avisa no es el peligroso. El peligroso es el que se aplica en silencio.**
>
> Compara las dos averías:
>
> | | Avería 3 (silenciosa) | Avería 4 (ruidosa) |
> | :--- | :--- | :--- |
> | ¿Avisa? | **No** | Sí, con línea y columna |
> | ¿Rompe la red? | **Sí, al instante** | No |
> | ¿Cuándo lo descubres? | Cuando algo deja de funcionar | Inmediatamente |
>
> **La que da miedo es la de la izquierda.** Un error de sintaxis se arregla en diez segundos; una configuración válida pero equivocada puede costarte una tarde.

---

---

> [!important] ⏸️ FIN DE LA PRIMERA SESIÓN
> Hasta aquí, las cuatro averías **de red**. Antes de cerrar:
>
> 1. **Comprueba que has reparado todo:**
>    ```bash
>    sudo ./verificar_fase1.sh
>    ```
>    Tiene que salir **`FASE 1 SUPERADA`**. Si no, vuelve a la avería que corresponda: el informe te dice cuál.
> 2. **Pausa la grabación de OBS.** No cierres el vídeo: las dos que quedan van en el mismo.
> 3. **Escribe ya tus cuatro predicciones y lo que pasó**, mientras lo tienes fresco. Dentro de dos días no te acordarás de por qué predijiste lo que predijiste.
>
> **Lo que viene son las dos de SSH**, y son de otra naturaleza: la 5 desmonta una creencia y la 6 acaba tocando tu Windows.

---

# **AVERÍA 5 · PARAR SSH (Y LA SORPRESA DEL PUERTO ABIERTO)**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** detener el servicio de acceso remoto.
>
> **Por qué provocamos esta:** porque en Ubuntu 26.04 **no pasa lo que esperas**. Es la avería que enseña cómo arrancan hoy los servicios en Linux, y por qué mirar `systemctl is-active` no siempre basta.

> [!question] 🤔 Predice antes de ejecutar
> 1. Al parar el servicio `ssh`, ¿se cerrará el puerto 22?
> 2. ¿Podrá tu Windows conectarse todavía?
>
> **Escríbelo. Casi seguro que fallas, y aquí fallar es lo interesante.**

### **1 · Romper**
```bash
sudo systemctl stop ssh
```

### **2 · Comprobar**
```bash
systemctl is-active ssh
systemctl is-active ssh.socket
sudo ss -tlnp | grep ":22 "
nc -vz localhost 22
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `systemctl stop ssh` | `Stopping 'ssh.service', but its triggering units are still active: ssh.socket` | **El propio sistema te avisa** de que no has parado todo |
| `is-active ssh` | `inactive` | El servicio está parado, sí |
| `is-active ssh.socket` | **`active`** | Pero hay **otra unidad** en marcha |
| `ss -tlnp` | El 22 sigue en `LISTEN`, ocupado por **`systemd`**, no por `sshd` | El puerto **sigue abierto**, lo sostiene el sistema |
| `nc -vz localhost 22` | **`succeeded!`** | **Y las conexiones siguen funcionando.** Desde tu Windows entrarías igual |

> [!info] 🎓 Esto se llama activación por socket
> En Ubuntu 26.04, `systemd` **escucha él mismo en el puerto 22** y solo arranca el programa `sshd` cuando alguien llama de verdad.
>
> **Para qué sirve:** el servidor no gasta memoria en un programa que quizá no use nadie, y aun así responde al instante cuando hace falta.
>
> **Qué implica para ti:** que `ssh.service` parado **no significa** SSH cerrado. La unidad que abre el puerto es `ssh.socket`.

**Ahora sí, para el que manda:**
```bash
sudo systemctl stop ssh.socket
sudo ss -tlnp | grep ":22 "
nc -vz localhost 22
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ss -tlnp` | **Nada** | Ahora sí, el puerto 22 está cerrado |
| `nc -vz` | `Connection refused` | Llegas al servidor, pero **nadie atiende** |

### **3 · Consecuencias**
El servidor está sano, en su red, con su IP… y **no puedes administrarlo desde ningún sitio salvo esta ventana**. En un servidor real, en un armario o en un centro de datos, eso significa **ir físicamente hasta él**.

### **4 · Reparar**
```bash
sudo systemctl start ssh.socket
sudo systemctl start ssh
sudo ss -tlnp | grep ":22 "
```
- **✅ Reparado:** vuelve a aparecer el 22 en escucha. Confirma desde tu Windows con `ssh boochan@10.10.10.10`.

> [!success] 🎓 La lección
> **Comprobar que un servicio está "parado" no demuestra que el puerto esté cerrado.**
>
> Y al revés: `Connection refused` significa que **has llegado** al servidor y no hay nadie atendiendo. Es una respuesta, no un silencio. Compáralo con el `timed out` de la avería 1.
>
> Cuando quieras saber si un puerto está abierto, **pregúntaselo al puerto** (`ss`, `nc`), no al gestor de servicios.

---

# **AVERÍA 6 · BORRAR LAS CLAVES DE HOST**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** borrar la identidad criptográfica del servidor.
>
> **Qué dejará de funcionar, en cadena:**
> 1. `sshd` **no puede arrancar**: sin clave, no puede presentarse
> 2. Al regenerarlas, el servidor tiene **una identidad nueva**
> 3. Tu Windows, que recordaba la anterior, **se niega a conectarse** y te avisa de un posible ataque
>
> **Por qué provocamos esta:** porque provoca a propósito el [[Fase_1.7_Resolucion_Problemas#E11 · Aviso REMOTE HOST IDENTIFICATION HAS CHANGED|caso E11]] del catálogo de errores, y porque es exactamente lo que te encontrarás al clonar una máquina en [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|la 6.f]].

> [!question] 🤔 Predice antes de ejecutar
> 1. Si borras las claves y reinicias el servicio, ¿se regenerarán solas?
> 2. ¿Arrancará `sshd` sin ellas?
> 3. Tras regenerarlas, ¿qué crees que te dirá tu Windows al conectarse?

### **1 · Romper**
Primero **apunta la huella actual**, que la vas a necesitar para comparar:
```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```
Cópiala en tu entrada de apuntes. Ahora:
```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo systemctl restart ssh
```

### **2 · Comprobar**
```bash
systemctl is-active ssh
sudo systemctl status ssh --no-pager | head -15
ls /etc/ssh/ | grep host_
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `restart ssh` | `Job for ssh.service failed because the control process exited with error code` | **El servicio no arranca** |
| `is-active` | **`failed`** | No es que esté parado: ha intentado arrancar y no ha podido |
| `ls` de `/etc/ssh` | **No hay ninguna clave** | **No se regeneran solas.** Esto sorprende a mucha gente |

> [!warning] ⚠️ Aquí se cae una creencia muy extendida
> *"Bórralas y al reiniciar el servicio se crean solas"* es **falso**. Comprobado en Ubuntu 26.04: `sshd` **no arranca**.
>
> Las claves se generan al **instalar** el paquete, no al arrancar el servicio.

### **3 · Consecuencias**
Sin acceso remoto de ninguna clase. Y cuando lo repares, **todos los ordenadores que se hubieran conectado antes te rechazarán** por seguridad.

### **4 · Reparar**
```bash
sudo ssh-keygen -A
sudo systemctl restart ssh
systemctl is-active ssh
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```
- **✅ Reparado:** `active`, y aparecen las tres claves.
- **⚠️ Pero fíjate en la huella: ES DISTINTA** de la que apuntaste. Compáralas.

**Y ahora prueba desde tu Windows:**
```
ssh boochan@10.10.10.10
```
Te saltará un aviso grande: `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`

**Se arregla en tu Windows, no en el servidor**, olvidando la identidad vieja:
```
ssh-keygen -R 10.10.10.10
```
Y vuelve a conectar. Te preguntará de nuevo si aceptas la huella: **compárala con la que acabas de ver en el servidor antes de decir `yes`.**

> [!info] 🎓 `ssh-keygen -A` significa "genera las que falten"
> La `-A` crea todas las claves de host que no existan, con los tipos y nombres estándar. Es lo que hace el instalador del paquete por dentro.

> [!success] 🎓 La lección
> **Un servidor tiene una identidad, y no es su nombre ni su IP: es su clave.**
>
> El aviso de tu Windows no es un fastidio: es **la protección funcionando**. Está diciendo *"esta dirección responde, pero ya no es quien era"*. Eso es exactamente lo que pasaría si alguien suplantara al servidor.
>
> Por eso se compara la huella antes de aceptar. Y por eso, en [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|la 6.f]], **lo primero que se borra antes de clonar son estas claves**: si viajaran en el clon, dos máquinas distintas afirmarían ser la misma.

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase1.sh
```

- **✅ Bien:** `VEREDICTO: FASE 1 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien. Vuelve a ella.

> [!tip] 💡 Si algo se te ha quedado torcido, tienes la instantánea
> Restaura `Fase 1 terminada` en VirtualBox y vuelves al punto bueno. **Para eso la tomaste antes de empezar.**
>
> No es rendirse: restaurar es una herramienta de administración, no una derrota.

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2, 3 y 4**, y `FASE 1 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **5 y 6**.
- [ ] Las seis hechas en la **ventana de VirtualBox**, no por SSH.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotada la diferencia de salida entre la **avería 1** y la **avería 2**.
- [ ] Anotada la huella **antes y después** de la avería 6.
- [ ] Verificador pasado al final: `FASE 1 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F1 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.9_Preguntas]] | [[Fase_1]] | [[Fase_1.10.b_Auditoria_y_Cierre]] |
