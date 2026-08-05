## Fase 2 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
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

---

# **AVERÍA 1 · VACIAR `/etc/hosts`**

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

# **AVERÍA 3 · AÑADIR UNA LÍNEA `127.0.1.1`**

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

# **AVERÍA 4 · PARAR EL SERVICIO `smbd`**

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

# **AVERÍA 5 · QUITAR EL ARRANQUE AUTOMÁTICO DE `smbd`**

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
| [[Fase_2.9_Preguntas]] | [[Fase_2]] | [[Fase_2.10.b_Auditoria_y_Cierre]] |
