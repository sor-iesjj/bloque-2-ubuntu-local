## Fase 2 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2_Purga_y_Preparacion_del_Entorno]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper cosas a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 2 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_2.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script que descargaste en [[Fase_2.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase2.sh
> chmod +x verificar_fase2.sh
> ```

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase2.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase2.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**

> [!warning] 💾 Antes de la primera avería, copia de seguridad del fichero
> Tres de las cinco tocan `/etc/hosts`. Es lo que hace un administrador **antes** de editar cualquier configuración:
> ```bash
> sudo cp /etc/hosts /tmp/hosts.bak
> ```
> Con eso, cualquier avería se revierte con un solo comando.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Hasta ahora has comprobado que **todo va bien**. Y eso enseña la mitad.
>
> La otra mitad es saber **qué se ve cuando va mal**. Un técnico no se distingue por montar sistemas — se distingue por **reconocer un síntoma** y saber de dónde viene.

> [!tip] 💡 Las cinco averías siguen siempre el mismo guion
> | Paso | Qué se hace |
> | :--- | :--- |
> | **🎯 Objetivo** | Qué provocamos y qué dejará de funcionar, en cadena |
> | **🤔 Predice** | Escribes qué crees que va a pasar, **antes** de ejecutar |
> | **1. Romper** | El comando |
> | **2. Comprobar** | Qué lo detecta y cómo se interpreta |
> | **3. Consecuencias** | El daño, por plazos |
> | **4. Reparar** | El arreglo y cómo confirmarlo |
> | **🎓 La lección** | La idea que te llevas |
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.
>
> **Y al final hay tres averías CRÍTICAS y opcionales**, que destruyen de verdad y de las que a veces solo se sale restaurando la instantánea. Están marcadas en rojo.

---

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 5 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **1** | [[#**AVERÍA 1 · VACIAR /etc/hosts**\|VACIAR `/etc/hosts`]] |
> | **2** | [[#**AVERÍA 2 · INVERTIR EL ORDEN DE LAS COLUMNAS**\|INVERTIR EL ORDEN DE LAS COLUMNAS]] |
> | **3** | [[#**AVERÍA 3 · AÑADIR UNA LÍNEA 127.0.1.1**\|AÑADIR UNA LÍNEA `127.0.1.1`]] |
> | **4** | [[#**AVERÍA 4 · PARAR EL SERVICIO smbd**\|PARAR EL SERVICIO `smbd`]] |
> | **5** | [[#**AVERÍA 5 · QUITAR EL ARRANQUE AUTOMÁTICO DE smbd**\|QUITAR EL ARRANQUE AUTOMÁTICO DE `smbd`]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 1 · VACIAR /etc/hosts**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar el fichero de identidades de red completamente vacío — **exactamente el estado en que viene Ubuntu Server 26.04 de fábrica**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. `hostname -f` deja de devolver el nombre completo y devuelve solo el corto
> 2. El servidor **ya no se reconoce** como `UbuntuServer.BOOCHANLAB.LOCAL`
> 3. La resolución de `localhost` por **IPv4** desaparece: solo queda `::1`
> 4. En la **Fase 4**, `samba-tool` aprovisionaría el dominio con un nombre incorrecto
> 5. Y el fallo aparecería allí, **sin mencionar `/etc/hosts` por ninguna parte**
>
> **Por qué provocamos esta:** porque **no es un error que cometas tú — es el estado inicial del sistema**. Si no lo rellenas en el Paso 3, ya estás aquí.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá funcionando el servidor con `/etc/hosts` vacío?
> 2. ¿Podrás seguir entrando por SSH?
> 3. ¿Resolverá todavía `localhost`?

### **1 · Romper**
```bash
sudo truncate -s 0 /etc/hosts
```

### **2 · Comprobar**
```bash
hostname -f
getent hosts localhost
cat /etc/hosts
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `hostname -f` | **`UbuntuServer`** | Perdiste el nombre completo |
| `getent hosts localhost` | Solo **`::1  localhost`** | La resolución IPv4 ha desaparecido; la tapa `systemd-resolved` |
| `cat` | **Nada** | El fichero está vacío |

**El verificador dirá:** `[FALLO] B2` y `[FALLO] B3`.

> 💡 **Fíjate:** el servidor sigue funcionando. SSH sigue entrando. **Nada parece roto.**

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | Casi nada visible. Todo sigue funcionando |
| **En la Fase 4** | El dominio se aprovisiona con un nombre incorrecto, o falla sin explicar por qué |
| **En un servidor real** | Cualquier programa que se conecte a `localhost` por IPv4 puede fallar, y el error **no menciona este fichero** |

### **4 · Reparar**
```bash
sudo cp /tmp/hosts.bak /etc/hosts
```

**Cómo confirmar:**
```bash
hostname -f
```
Debe volver a `UbuntuServer.BOOCHANLAB.LOCAL`.

> [!summary] 🎓 La lección
> **Un fichero de configuración vacío no siempre significa que alguien lo borró.** Aquí viene así de fábrica, y la fecha del fichero lo demuestra.
>
> Y un sistema puede parecer sano mientras le falta algo básico, **porque otro componente lo está compensando en silencio**. Hasta que deja de hacerlo.

---

# **AVERÍA 2 · INVERTIR EL ORDEN DE LAS COLUMNAS**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** escribir el nombre corto **antes** que el completo en la línea del dominio.
>
> **Qué dejará de funcionar, en cadena:**
> 1. La línea sigue siendo **sintácticamente válida**: nadie protesta
> 2. Pero `hostname -f` devuelve **el segundo campo** de la línea, sea cual sea
> 3. Al invertirlos, ese segundo campo es ahora `UbuntuServer`
> 4. El servidor pierde su nombre completo **sin que falte nada en el fichero**
>
> **Por qué provocamos esta:** porque enseña que **en un fichero de configuración el orden es sintaxis, no presentación**. Está todo lo que tiene que estar, y aun así está mal.

> [!question] 🤔 Predice antes de ejecutar
> El fichero seguirá teniendo la IP, el FQDN y el nombre corto. No falta nada.
> **¿Puede fallar algo si solo cambia el orden?**

### **1 · Romper**
```bash
sudo nano /etc/hosts
```
Cambia la línea del dominio por esta:
```
10.10.10.10     UbuntuServer   UbuntuServer.BOOCHANLAB.LOCAL
```

### **2 · Comprobar**
```bash
hostname -f
cat /etc/hosts
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `hostname -f` | **`UbuntuServer`** | Devuelve el segundo campo, que ahora es el corto |
| `cat` | La línea **completa**, con todo | No falta ningún dato: **solo está en otro orden** |

**El verificador dirá:** `[FALLO] B2` y `[AVISO] B5`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | Nada visible |
| **En la Fase 4** | El dominio se aprovisiona con el nombre corto. **El cliente Windows de la Fase 8 no encontrará el servidor** |
| **Para diagnosticar** | Miras el fichero, ves que está todo, y **descartas** este fichero como causa. Es lo peor que puede pasarte |

### **4 · Reparar**
```bash
sudo cp /tmp/hosts.bak /etc/hosts
```

**Cómo confirmar:**
```bash
hostname -f
```

> [!summary] 🎓 La lección
> **El formato es `IP · nombre completo · alias`, y el orden importa.**
>
> Que un fichero contenga todos los datos correctos no significa que esté bien escrito. **La sintaxis es tan parte del contenido como los datos.**

---

# **AVERÍA 3 · AÑADIR UNA LÍNEA 127.0.1.1**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** añadir la línea `127.0.1.1 UbuntuServer`, que **Ubuntu pone por defecto en muchas instalaciones** y que aquí sobra.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Ahora hay **dos líneas** que contienen el nombre `UbuntuServer`
> 2. La resolución se queda con **la primera coincidencia**, y esta va antes
> 3. Esa línea solo lleva el nombre corto → `hostname -f` devuelve el corto
> 4. Y peor: el nombre de tu servidor pasa a apuntar a **`127.0.1.1`**, una dirección de **bucle local**
> 5. Un controlador de dominio anunciado en bucle local **no lo alcanza nadie desde la red**
>
> **Por qué provocamos esta:** porque es **un error real que ya ha ocurrido en este curso**. Y porque enseña que añadir algo puede romper tanto como quitarlo.

> [!question] 🤔 Predice antes de ejecutar
> 1. No vas a borrar nada, solo **añadir** una línea. ¿Puede eso romper algo?
> 2. ¿A qué dirección crees que resolverá `UbuntuServer` después?

### **1 · Romper**
```bash
sudo nano /etc/hosts
```
Añade esta línea **justo debajo** de la de `localhost`:
```
127.0.1.1       UbuntuServer
```

### **2 · Comprobar**
```bash
hostname -f
getent hosts UbuntuServer
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `hostname -f` | **`UbuntuServer`** | Encontró la línea nueva antes que la buena |
| `getent hosts UbuntuServer` | Una dirección **de bucle local** | Tu servidor se anuncia a sí mismo en una dirección que **nadie más puede alcanzar** |

**El verificador dirá:** `[FALLO] B2` y `[FALLO] B4`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | Nada. El servidor va perfecto |
| **En la Fase 4** | Samba puede anunciar el dominio en `127.0.1.1`. Se aprovisiona **sin dar ningún error** |
| **En la Fase 8** | El cliente Windows busca el servidor, obtiene una dirección de bucle local **y se busca a sí mismo**. No encuentra el dominio |

> ⚠️ Es el mismo problema que resuelve la opción `--host-ip` del script de la Fase 4: **anunciar un servicio en una dirección que nadie puede alcanzar**.

### **4 · Reparar**
```bash
sudo sed -i '/^127\.0\.1\.1/d' /etc/hosts
```

**Cómo confirmar:**
```bash
hostname -f
getent hosts UbuntuServer
```
Debe devolver el FQDN y resolver a **`10.10.10.10`**.

> [!summary] 🎓 La lección
> **Añadir puede romper tanto como quitar.** Y cuando hay dos respuestas posibles, gana la primera — no la mejor.
>
> Ubuntu pone esa línea por una razón legítima en un equipo de escritorio. **En un controlador de dominio, sobra.** Copiar configuraciones sin preguntarse para qué entorno se pensaron es de los errores más comunes que existen.

---

# **AVERÍA 4 · PARAR EL SERVICIO smbd**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** detener el servicio de Samba **sin desinstalar nada**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. `systemctl is-active smbd` pasa a `inactive`
> 2. Los puertos **139 y 445** dejan de estar en escucha
> 3. Ningún equipo podría acceder a recursos compartidos
> 4. Pero **el paquete sigue instalado** y **su configuración intacta**
>
> **Por qué provocamos esta:** para separar **paquete**, **configuración** y **proceso**. Son tres cosas distintas y se confunden constantemente.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se desinstalará algo?
> 2. ¿Qué dirá `dpkg -s samba` después?
> 3. ¿Y `ss -tlnp` sobre los puertos 139 y 445?

### **1 · Romper**
```bash
sudo systemctl stop smbd
```

### **2 · Comprobar**
```bash
systemctl is-active smbd
dpkg -s samba | grep ^Status
sudo ss -tlnp | grep -E ':(139|445)'
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-active` | **`inactive`** | El proceso no está corriendo |
| `dpkg -s` | **`install ok installed`** | El paquete **sigue instalado** |
| `ss` en 139/445 | **Nada** | Los puertos se han liberado |

**El verificador dirá:** `[AVISO] E1` — aviso, no fallo: la Fase 4 usará `samba-ad-dc`, no `smbd`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | Ninguna para este itinerario. Aún no compartes nada |
| **En un servidor de ficheros** | Nadie puede acceder a las carpetas compartidas. Se nota **inmediatamente** |
| **Para el diagnóstico** | Si buscas el problema en el fichero de configuración, **pierdes el tiempo**: está perfecto |

### **4 · Reparar**
```bash
sudo systemctl start smbd
```

**Cómo confirmar:**
```bash
systemctl is-active smbd
sudo ss -tlnp | grep -cE ':(139|445)'
```
Debe decir `active` y volver a haber puertos en escucha.

> [!summary] 🎓 La lección
> **Paquete, configuración y proceso son tres cosas distintas.** El paquete vive en el disco, la configuración en un fichero, y el proceso en la memoria.
>
> Desinstalar no mata un proceso. Parar un proceso no desinstala nada. Y un fichero de configuración perfecto no sirve de nada si nadie lo está ejecutando.

---

# **AVERÍA 5 · QUITAR EL ARRANQUE AUTOMÁTICO DE smbd**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** quitarle al servicio el arranque automático, **sin detenerlo**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. **Ahora mismo: nada.** El servicio sigue corriendo
> 2. Lo que cambia es que `systemd` **ya no lo lanzará en el próximo arranque**
> 3. Al reiniciar, el servicio no está — y nada lo avisa
> 4. Descubres el problema **cuando alguien no puede acceder**, no cuando lo provocaste
>
> **Por qué provocamos esta:** porque es **invisible**. Ninguna prueba de funcionamiento la detecta, solo una comprobación de estado.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se para el servicio al desactivarlo?
> 2. Si no miras el estado, **¿notarías algo?**
> 3. ¿Cuándo se manifestaría?

### **1 · Romper**
```bash
sudo systemctl disable smbd
```

### **2 · Comprobar**
```bash
systemctl is-enabled smbd
systemctl is-active smbd
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-enabled` | **`disabled`** | No arrancará en el próximo inicio |
| `is-active` | **`active`** | **Sigue corriendo ahora mismo** |

**El verificador dirá:** `[AVISO] E2`. **Él lo ve; tú, no.**

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | **Nada.** Cero síntomas |
| **Al primer reinicio** | El servicio no está. Y como no diste ninguna orden hoy, **no lo relacionas** |
| **En una empresa** | Un corte de luz de 30 segundos deja un servicio caído que nadie sabe por qué no vuelve |

### **4 · Reparar**
```bash
sudo systemctl enable smbd
```

**Cómo confirmar:**
```bash
systemctl is-enabled smbd
```
Debe devolver `enabled`.

> [!summary] 🎓 La lección
> **Funcionar hoy no garantiza funcionar mañana.** Un servicio arrancado y un servicio habilitado son cosas distintas: solo la segunda sobrevive a un reinicio.
>
> Es la misma idea que la avería 2 del laboratorio de la Fase 3, con otro servicio. **No es casualidad: es un patrón que se repite en toda la administración de sistemas.**

---

---

# 🔴 **AVERÍAS CRÍTICAS** *(opcionales — solo si te atreves)*

> [!danger] 🛑 LEE ESTO ENTERO ANTES DE TOCAR NADA
> Las cinco averías anteriores se revierten con un comando. **Estas tres, no.**
>
> Aquí vas a **destruir de verdad** partes del servidor. Se recuperan, pero hace falta saber cómo — y en un caso, **la única salida es la instantánea**.
>
> **Son opcionales.** Nadie suspende por no hacerlas. Pero si las haces, entiendes en una tarde lo que a mucha gente le cuesta una avería real en el trabajo.

> [!important] ✅ Requisitos antes de empezar
> 1. **Instantánea `Fase 2 terminada` hecha y comprobada:**
>    ```
>    VBoxManage snapshot "UbuntuServer" list
>    ```
> 2. **Copia `.ova` en tu disco externo.** Es tu segunda red de seguridad.
> 3. **Sabes entrar por la ventana de VirtualBox.** No por SSH: **por la ventana**. Vas a necesitarla.

---

## 🌳 ANTES DE EMPEZAR: CÓMO FUNCIONAN LAS INSTANTÁNEAS

> [!info] 🎓 Es un árbol, no una pila
> Tus instantáneas están encadenadas así:
>
> ```
> Sistema base
>  └── Fase 1 terminada
>       └── Fase 2 terminada
>            └── Fase 2 terminada
> ```
>
> **Restaurar una anterior NO borra las posteriores.** Vuelves atrás en el árbol, pero las ramas siguen ahí y puedes avanzar de nuevo cuando quieras.
>
> Lo único que se pierde es **el trabajo no guardado** desde la última instantánea. En un laboratorio de averías, eso es justo lo que quieres tirar.

> [!warning] ⚠️ Al restaurar, VirtualBox te preguntará algo
> Sale un aviso ofreciéndose a **guardar el estado actual** antes de restaurar. En este laboratorio, di que **no**: ese estado es precisamente el que has roto.
>
> Las instantáneas **con nombre** no se tocan nunca.

> [!question] 🔬 Compruébalo tú, que es gratis
> **Antes** de restaurar nada:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Anota lo que sale. Restaura `Fase 2 terminada`. Y vuelve a ejecutarlo.
>
> **La lista es la misma.** No has perdido ninguna instantánea. Verlo con tus ojos vale más que creerme.

---

## 🔴 **CRÍTICA 1 · PURGAR SAMBA ENTERO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** eliminar Samba y **todos** los paquetes del dominio, incluidos `samba-ad-dc` y `samba-ad-provision`.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Desaparece `samba-tool`, la herramienta con la que se crea el dominio
> 2. Desaparece el servicio `samba-ad-dc`
> 3. Desaparecen los ficheros de esquema de Active Directory
> 4. **La Fase 4 pasa a ser imposible**, y su error no dirá que falta un paquete
> 5. El servidor sigue funcionando perfectamente: red, SSH, todo
>
> **Por qué provocamos esta:** porque **le pasó de verdad a alguien en este curso**. Un diagnóstico equivocado —creer que la purga del Paso 1A había fallado— llevó a purgar de nuevo lo que el Paso 2 acababa de instalar. El servidor parecía sano y la fase siguiente era ya imposible.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se caerá el servidor?
> 2. ¿Podrás seguir entrando por SSH?
> 3. ¿Cómo te darías cuenta de que falta algo, si todo sigue funcionando?

### **1 · Romper**
```bash
sudo apt purge -y samba samba-common samba-common-bin samba-ad-dc samba-ad-provision winbind
```

### **2 · Comprobar**
```bash
which samba-tool
dpkg -s samba-ad-dc 2>&1 | head -2
systemctl is-active ssh
ping -c2 google.com
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `which samba-tool` | **Nada** | La herramienta del dominio ya no existe |
| `dpkg -s samba-ad-dc` | `no está instalado` | El paquete se fue |
| `systemctl is-active ssh` | **`active`** | Sigues pudiendo entrar |
| `ping google.com` | **Responde** | La red está intacta |

**El verificador dirá:** `[FALLO] C1`.

> 💡 **Fíjate:** el servidor está perfecto. **Solo que la Fase 4 ya no se puede hacer.**

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | **Nada visible.** Todo responde |
| **En la Fase 4** | `samba-tool: command not found`, o un error de esquema que no menciona paquetes |
| **Si además tomaste instantánea** | Guardaste este estado como bueno. **Cada vez que restaures, volverás aquí** |

### **4 · Reparar — PLAN A**
```bash
sudo apt update
sudo apt install -y acl attr samba samba-ad-dc samba-ad-provision krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config
```

**Cómo confirmar:**
```bash
which samba-tool
dpkg -s samba-ad-dc samba-ad-provision | grep -E '^Package|^Status'
```

> [!warning] ⚠️ Esta reparación NECESITA INTERNET
> Se descargan paquetes. Si la red no funciona, **este plan no sirve** — y ahí entra la crítica 3.
>
> Volverá a salir la pantalla azul de Kerberos: `BOOCHANLAB.LOCAL`, **en mayúsculas**.

### **5 · Reparar — PLAN B, si el A falla**
Restaura la instantánea **`Fase 2 terminada`** y repite la fase desde el Paso 2.

> [!summary] 🎓 La lección
> **Un servidor puede estar perfectamente sano y ser inservible para su propósito.** Red, SSH, disco, memoria: todo bien. Y la función para la que existe, imposible.
>
> Por eso la verificación de una fase no comprueba *"¿arranca?"* sino *"¿tiene lo que la fase siguiente necesita?"*.

---

## 🔴 **CRÍTICA 2 · ROMPER LA RED Y APLICARLO**

> [!danger] 🛑 Esta avería TE ECHA DEL SERVIDOR
> Vas a perder la conexión SSH. **No es un fallo del ejercicio: es el ejercicio.**
>
> **Antes de empezar, ten la ventana de VirtualBox abierta y comprueba que puedes hacer login en ella.** Va a ser tu única puerta.

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar la configuración de red sin la tarjeta `enp0s8` y aplicarla.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Al aplicar, el sistema retira la dirección `10.10.10.10`
> 2. **Tu sesión SSH se corta en el acto**
> 3. El servidor **sigue encendido y funcionando**: solo ha perdido esa dirección
> 4. Desde tu equipo, `ping 10.10.10.10` deja de responder
> 5. La única forma de entrar es **la ventana de VirtualBox**, que no usa la red
>
> **Por qué provocamos esta:** porque es **el accidente más común** administrando servidores remotos, y porque enseña que **siempre tiene que haber una vía de acceso que no dependa de lo que estás tocando**.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se apagará el servidor?
> 2. ¿Podrás recuperarlo, y por dónde?
> 3. Si el servidor estuviera en otro edificio, **¿qué harías?**

### **1 · Romper**

**Paso 1 — copia de seguridad primero** *(esto es lo que hace un profesional)*:
```bash
sudo cp /etc/netplan/00-installer-config.yaml /tmp/netplan.bak
```

**Paso 2 — quita el bloque de `enp0s8`:**
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
Borra las líneas de `enp0s8` y su dirección. Guarda.

> [!info] 💡 Hasta aquí NO ha pasado nada
> Has editado un fichero, pero **la red sigue funcionando**. Un fichero de configuración no cambia el sistema hasta que alguien lo aplica.
>
> Compruébalo: `ip a` sigue mostrando `10.10.10.10`. **Todavía estás a tiempo.**

**Paso 3 — aplícalo:**
```bash
sudo netplan apply
```

**Aquí pierdes la sesión SSH.**

### **2 · Comprobar** *(desde la ventana de VirtualBox)*

Entra con `boochan` / `P@ssw0rd` en la ventana y ejecuta:
```bash
ip -4 addr show
systemctl is-active ssh
```

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `ip -4 addr show` | **Sin `10.10.10.10`** | La dirección se ha retirado |
| `systemctl is-active ssh` | **`active`** | 🤯 **SSH funciona.** Lo que falta es la dirección por la que llegabas |

> 💡 **Esa es la clave:** el servicio no se ha caído. **Se ha caído el camino.**

**El verificador dirá:** `[FALLO] A1`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Inmediato** | Pierdes el acceso remoto. El servidor sigue vivo |
| **Si fuera un servidor real en un centro de datos** | No hay "ventana de VirtualBox". Se resuelve con acceso físico, consola serie o KVM — y si no lo tienes contratado, **con un viaje** |
| **Si además hubieras restringido SSH al túnel** | Dos puertas cerradas a la vez |

### **4 · Reparar** *(desde la ventana de VirtualBox)*
```bash
sudo cp /tmp/netplan.bak /etc/netplan/00-installer-config.yaml
sudo netplan apply
ip -4 addr show
```

**Cómo confirmar:** vuelve a aparecer `10.10.10.10`, y desde tu equipo:
```
ssh boochan@10.10.10.10
```

> [!summary] 🎓 La lección
> **Nunca toques la red por la única vía que tienes para entrar** sin tener otra puerta abierta y comprobada.
>
> Y algo más fino: **editar un fichero no cambia nada; aplicarlo, sí.** Entre las dos cosas hay una ventana para darse cuenta del error — la única que vas a tener.

---

## 🔴 **CRÍTICA 3 · LAS DOS A LA VEZ (el punto sin retorno)**

> [!danger] 🛑 De esta avería NO se sale sin la instantánea
> Es la única del curso donde **no hay reparación manual posible**. Léela entera aunque no la hagas.

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** purgar Samba **y después** romper la red.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Sin Samba, la Fase 4 es imposible → la reparación es `apt install`
> 2. Pero `apt install` **descarga de internet**
> 3. Y sin red, no hay descarga
> 4. **La reparación de la primera avería depende de lo que rompió la segunda**
> 5. Puedes entrar por la ventana de VirtualBox, sí — **pero no hay nada que puedas hacer desde ahí**
>
> **Por qué provocamos esta:** porque enseña que **las averías no se suman: se multiplican**. Dos problemas que por separado se arreglan en cinco minutos, juntos son irrecuperables.

> [!question] 🤔 Predice antes de ejecutar
> 1. Si puedes entrar por la ventana de VirtualBox, **¿por qué no puedes arreglarlo?**
> 2. ¿En qué orden habría que reparar las dos cosas?
> 3. Y la pregunta buena: **¿se puede?**

### **1 · Romper**
```bash
sudo apt purge -y samba samba-ad-dc samba-ad-provision
sudo cp /etc/netplan/00-installer-config.yaml /tmp/netplan.bak
sudo nano /etc/netplan/00-installer-config.yaml    # quita enp0s8
sudo netplan apply
```

### **2 · Comprobar** *(desde la ventana de VirtualBox)*
```bash
which samba-tool          # nada
ip -4 addr show           # sin 10.10.10.10
ping -c2 google.com       # ¿hay internet?
```

> [!info] 🤔 Aquí depende de qué hayas roto exactamente
> Si solo quitaste `enp0s8`, la tarjeta **NAT** sigue dando internet y **sí podrías reinstalar**. Repáralo en este orden: **primero la red, después los paquetes**.
>
> Si te llevaste también la NAT, **no hay internet**, y entonces sí: no hay nada que hacer.

### **3 · Reparar — el orden importa**

**Si conservas internet:**
```bash
sudo cp /tmp/netplan.bak /etc/netplan/00-installer-config.yaml
sudo netplan apply
sudo apt update && sudo apt install -y samba samba-ad-dc samba-ad-provision
```
**Primero el camino, después la carga.** Al revés no funciona.

**Si NO hay internet:** restaura la instantánea **`Fase 2 terminada`**. No hay plan B.

### **4 · Y aquí entra tu copia de seguridad**

> [!danger] 💾 Si además hubieras perdido las instantáneas
> Un disco que falla, un VirtualBox corrupto, un equipo del aula formateado. Entonces la única salida es **el `.ova` de tu disco externo**.
>
> Importas la máquina y vuelves al final de la Fase 2. **Eso es exactamente para lo que la exportaste.**
>
> Y si no la exportaste: **has perdido el curso hasta aquí.**

> [!summary] 🎓 La lección
> **Las averías no se suman: se multiplican.** Dos fallos de cinco minutos, juntos, pueden ser irreparables.
>
> Y hay un orden de reparación que no es negociable: **primero se restaura el camino, después la carga**. Intentar reinstalar sin red es perder el tiempo con mucha confianza.
>
> Por eso se hace copia **de cada fase**, y por eso vive **fuera de la máquina**.

---

> [!success] ✅ Al terminar las críticas
> ```bash
> sudo ./verificar_fase2.sh
> ```
> Todo en verde. Si no, restaura `Fase 2 terminada` sin pensarlo más: **para eso está**.

> [!question] 📝 Lo que va a tu entrada de apuntes *(si has hecho las críticas)*
> 1. En la crítica 2, el servidor seguía funcionando y SSH estaba activo. **¿Por qué no podías entrar?**
> 2. ¿Por qué en la crítica 3 hay que reparar la red **antes** que los paquetes?
> 3. Restauraste una instantánea anterior. **¿Se perdieron las posteriores?** Compruébalo y explica qué es un árbol de instantáneas.
> 4. Describe una situación en la que **ni la instantánea te salvaría**, y qué te salvaría entonces.


> [!important] 🎯 La lección que une las averías 1, 2, 3 y 5
> En las cuatro, **el servidor sigue funcionando perfectamente**. Entras por SSH, todo responde, ningún registro se queja.
>
> Y en las cuatro, **el verificador las detecta**.
>
> Ese es el motivo de que exista una herramienta de comprobación de estado: **"funciona" no es lo mismo que "está bien"**.

> [!success] ✅ Deja el sistema como estaba
> ```bash
> sudo ./verificar_fase2.sh
> ```
> Todo debe volver a estar en verde. Si algo no vuelve a su sitio, **restaura la instantánea `Fase 2 terminada`**.

> [!question] 📝 Lo que va a tu entrada de apuntes
> 1. De las cinco averías, **¿cuáles NO se notaban?** ¿Por qué son las más peligrosas?
> 2. Las averías 1, 2 y 3 tocan el mismo fichero y rompen lo mismo por tres motivos distintos. **Explica cada motivo.**
> 3. En la avería 2 el fichero tenía todos los datos correctos y aun así estaba mal. **¿Qué te enseña eso sobre revisar configuraciones?**
> 4. La avería 5 es idéntica en concepto a una de la Fase 3. **¿A cuál, y por qué se repite el patrón?**
> 5. Escribe **una avería nueva** que se te ocurra para esta fase, con su objetivo, su rotura y su reparación.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.9_Preguntas]] | [[Fase_2_Purga_y_Preparacion_del_Entorno]] | [[Fase_2.10.b_Auditoria_y_Cierre]] |
