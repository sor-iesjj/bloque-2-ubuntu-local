## Fase 7 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper la seguridad a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 7 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_7.8.b_Punto_de_Control]].
>
> **En esta fase el requisito es serio:** la avería 5 toca el fichero que sostiene el dominio entero.

> [!info] 🤖 Vas a usar el verificador en cada avería
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase7.sh
> chmod +x verificar_fase7.sh
> ```

> [!warning] 🖥️ Ninguna avería te corta el SSH, pero una tira el dominio
> Entras con tu usuario local `boochan`, que no depende del dominio. **La avería 5 deja `samba-ad-dc` sin arrancar**, y con él caen el DNS y la autenticación — pero tu sesión por IP sigue funcionando.
>
> Es exactamente lo que viste en la Fase 4: **entraste por una IP, no por un nombre.**

---

> [!info] 🎓 Por qué se rompe algo que funciona
> La seguridad tiene una propiedad incómoda: **cuando está mal puesta, se comporta igual que cuando está bien puesta** — hasta que aparece alguien que no debía entrar y entra.
>
> Un permiso que no se aplica, una carpeta que se ve cuando no debería, una ACL que no se hereda: ninguna de esas tres cosas da un error. **Aquí vas a provocarlas para aprender a reconocerlas**, porque en producción nadie te va a avisar.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3** | Los **permisos**: lo que se aplica y lo que no |
> | **2.ª** | **4 · 5 · 6** | La **publicación**: Samba, el dominio y la invisibilidad |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F7 · Laboratorio de averías`, con sus seis timestamps.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada.

> [!tip] 💡 Las seis averías siguen siempre el mismo guion
> **🎯 Objetivo** → **🤔 Predice** → **1. Romper** → **2. Comprobar** → **3. Consecuencias** → **4. Reparar** → **🎓 La lección**
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.

---

# **AVERÍA 1 · QUITAR LA ACL DEL GRUPO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** eliminar el permiso del grupo `policia` sobre `prueba3`, dejando la carpeta y el grupo intactos.
>
> **Por qué provocamos esta:** para ver el fallo **ruidoso** de los permisos y tenerlo como referencia. Las averías 2 y 3 producen el mismo daño **sin ningún ruido**, y solo se aprecia la diferencia habiendo visto esta primero.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Cambiará algo en `ls -ld`?
> 2. ¿Seguirá `user1` perteneciendo al grupo?
> 3. ¿Podrá `user1` escribir en la carpeta?

### **1 · Romper**
```bash
sudo setfacl -x g:policia /srv/samba/prueba3
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/prueba3
ls -ld /srv/samba/prueba3
id -nG user1
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `getfacl` | Ya no está `group:policia` | El permiso se ha ido |
| `ls -ld` | **Casi igual que antes** | Los permisos clásicos no han cambiado |
| `id -nG user1` | Sigue en `policia` | El usuario está bien; el permiso no |
| El verificador | **FALLO en `B1`** | Lo detecta |

> [!important] ✍️ Fíjate en el `ls -ld`
> Con ACL puestas, `ls -l` muestra un **`+`** al final de los permisos: `drwxrws---+`. Al quitar la ACL, ese `+` desaparece.
>
> **Anota en tu entrada si lo has visto**, porque es la única pista que da `ls` de que hay permisos avanzados detrás. Quien no sepa que ese `+` existe, no sabrá que tiene que mirar el `getfacl`.

### **3 · Consecuencias**
Los usuarios de `policia` pierden el acceso por la vía de la ACL. Quedan solo los permisos clásicos de grupo — que aquí siguen funcionando, y por eso el daño real depende de cómo esté montado el conjunto.

### **4 · Reparar**
```bash
sudo setfacl -m g:policia:rwx /srv/samba/prueba3
getfacl -p /srv/samba/prueba3
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** vuelve `group:policia:rwx` y el verificador da `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> Que **hay dos sistemas de permisos conviviendo** sobre la misma carpeta: los clásicos de Unix (`rwx` para dueño, grupo y otros) y las ACL, que permiten dar permisos a **varios** grupos y usuarios distintos.
>
> Y que `ls -l` solo te enseña los primeros. **El `+` es el aviso de que hay más**, y hay que ir a buscarlo con `getfacl`.

---

# **AVERÍA 2 · LA MÁSCARA QUE ANULA EL PERMISO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** bajar la máscara de la ACL, dejando el permiso del grupo **escrito y visible** pero sin efecto.
>
> **Por qué provocamos esta:** porque es **la trampa más fina de toda la fase**. El permiso sigue ahí, se lee `rwx`, y no funciona. Es el [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]].

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá apareciendo `group:policia:rwx` en el `getfacl`?
> 2. ¿Podrá escribir alguien del grupo?
> 3. ¿Qué crees que va a cambiar en la salida?

### **1 · Romper**
```bash
sudo setfacl -m m::r-- /srv/samba/prueba3
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/prueba3
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Dónde miras | Qué verás |
| :--- | :--- |
| La línea del grupo | `group:policia:rwx` — **igual que antes** |
| Al final de esa línea | `#effective:r--` — **esto es nuevo** |
| La línea `mask::` | `mask::r--` |
| El verificador | **FALLO en `B2`** |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> **Pone `rwx` y significa `r--`.** El permiso está escrito, es correcto, y no se aplica.
>
> Si leyeras esta ACL con prisa —y todo el mundo lee las ACL con prisa— verías `group:policia:rwx` y darías el problema por descartado. **La información que lo desmiente está a la derecha, en una columna que casi nadie mira.**

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia la línea completa en tu entrada de apuntes**, con su `#effective`. Y responde: si un compañero te enseña esta salida diciendo *"el permiso está puesto y no funciona"*, ¿qué le dirías en diez segundos?

### **3 · Consecuencias**
Nadie del grupo puede escribir, y la ACL parece correcta. El diagnóstico se va a los sitios equivocados —el usuario, el grupo, Samba, el montaje— porque el permiso "ya está comprobado".

### **4 · Reparar**
```bash
sudo setfacl -m m::rwx /srv/samba/prueba3
getfacl -p /srv/samba/prueba3
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** desaparece el `#effective` y el verificador da `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> **Lo que está escrito y lo que se aplica pueden ser cosas distintas.** Es la versión más pura de una idea que llevas arrastrando desde la Fase 4, y aquí no hace falta ni equivocarse al escribir: basta con **leer mal una salida**.
>
> La regla práctica: **cuando una salida trae una columna que no entiendes, entiéndela.** El `#effective` lleva ahí todo el curso esperando a que alguien lo mire.

---

# **AVERÍA 3 · 🔴 QUITAR LA HERENCIA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** eliminar la ACL **por defecto**, dejando intacta la de la carpeta.
>
> **Por qué provocamos esta:** porque es un fallo que **no afecta a nada de lo que existe hoy**. Todo lo que ya está dentro sigue funcionando. Solo falla **lo que se cree a partir de ahora** — y eso puede tardar semanas en notarse.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Cambiará el acceso a los ficheros que ya existen?
> 2. ¿Y a los que se creen después?
> 3. ¿Cuánto tiempo crees que tardaría alguien en darse cuenta?

### **1 · Romper**
Primero deja un fichero **de antes**, para comparar:
```bash
sudo touch /srv/samba/prueba3/antes.txt
getfacl -p /srv/samba/prueba3/antes.txt | grep policia
```
Y ahora quita la herencia:
```bash
sudo setfacl -k /srv/samba/prueba3
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/prueba3
sudo touch /srv/samba/prueba3/despues.txt
getfacl -p /srv/samba/prueba3/despues.txt | grep policia
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Qué miras | Resultado |
| :--- | :--- |
| ACL de la carpeta | **Sigue teniendo** `group:policia:rwx` |
| Líneas `default:` | **Han desaparecido** |
| `antes.txt` | **Tiene** el permiso del grupo |
| `despues.txt` | **NO lo tiene** |
| El verificador | **FALLO en `B3`** |

> [!danger] 🤯 Dos ficheros en la misma carpeta con permisos distintos
> Nadie ha tocado los ficheros. Nadie ha cambiado los permisos de la carpeta. **Y sin embargo lo que se crea hoy sale distinto de lo que se creó ayer.**
>
> Este es el tipo de fallo que genera las incidencias más desconcertantes: *"a mí me funciona y a mi compañero no"*, sobre la misma carpeta y el mismo grupo.

### **3 · Consecuencias**
Una carpeta compartida que **se va degradando sola**. Los ficheros antiguos accesibles, los nuevos no. Y como el problema aparece poco a poco, nadie lo relaciona con un cambio concreto.

### **4 · Reparar**
```bash
sudo setfacl -d -m g:policia:rwx /srv/samba/prueba3
sudo setfacl -R -m g:policia:rwx /srv/samba/prueba3
sudo rm -f /srv/samba/prueba3/antes.txt /srv/samba/prueba3/despues.txt
getfacl -p /srv/samba/prueba3
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** vuelven las líneas `default:` y el verificador da `FASE 7 SUPERADA`.

> [!info] 🎓 Fíjate en que ha hecho falta reparar DOS cosas
> El `-d -m` restaura la herencia **para el futuro**. El `-R -m` arregla **lo que ya se creó mal**. Son dos comandos porque son dos problemas: la causa y el daño acumulado.

> [!success] 🎓 La lección
> Que **la herencia es lo que evita tener que acordarse.** Un permiso puesto a mano funciona una vez; un permiso heredado funciona siempre, incluido el día que tú no estés.
>
> Y que hay fallos cuyo daño **crece con el tiempo en lugar de aparecer de golpe**. Son los peores de diagnosticar, porque cuando alguien se queja ya no hay ningún cambio reciente al que señalar.

---

# **AVERÍA 4 · 🔴 QUITAR LA INVISIBILIDAD (ABE)**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** desactivar `access based share enum` en `[prueba3]`.
>
> **Por qué provocamos esta:** porque es **el fallo invisible de la fase**, el [[Fase_7.7_Resolucion_Problemas#E5 · La carpeta protegida se ve desde Windows|caso E5]]. Desde el servidor **no vas a notar absolutamente nada**, y ese es justo el ejercicio.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrá `user2` entrar en la carpeta después de esto?
> 2. ¿Podrá **verla** en el listado de red?
> 3. ¿Habrá algún comando en el servidor que te diga que algo va mal?

### **1 · Romper**
Copia de seguridad primero — **siempre, antes de tocar `smb.conf`**:
```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo sed -i 's/^\( *access based share enum *=\) *yes/\1 no/I' /etc/samba/smb.conf
sudo testparm -s --section-name=prueba3 | grep -i "access based"
```
Y aplica el cambio, **validando antes**:
```bash
sudo testparm
sudo systemctl restart samba-ad-dc
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/prueba3
ls -ld /srv/samba/prueba3
systemctl is-active samba-ad-dc
testparm -s --section-name=prueba3
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `getfacl` | **Perfecto** | Los permisos siguen bien |
| `ls -ld` | **Perfecto** | La carpeta está igual |
| `is-active` | `active` | El servicio va bien |
| `testparm -s` | `access based share enum = No` | **Aquí está** |
| El verificador | **FALLO en `D1`** | Es lo único que avisa |

> [!danger] 🤯 Fíjate en lo que NO ha pasado
> **Nada.** El acceso sigue perfectamente protegido: `user2` no puede entrar en la carpeta. Los permisos son correctos, las ACL son correctas, el servicio funciona.
>
> Lo único que has roto es que ahora `user2` **ve que la carpeta existe**. Y eso no se puede comprobar desde Ubuntu por ningún medio: hace falta un cliente Windows mirando el listado de red.

### **3 · Consecuencias**
Un usuario sin autorización ve una lista de carpetas con nombres como `prueba3` —o, en un servidor real, `nominas`, `expedientes`, `direccion`—. No puede abrirlas, pero **ya sabe qué hay, dónde está y a quién pedírselo**.

Y hay algo peor: el administrador cree que la protección está completa, porque desde su lado **lo parece**.

### **4 · Reparar**
```bash
sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
testparm -s --section-name=prueba3 | grep -i "access based"
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** vuelve `= Yes` y el verificador da `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> Que **denegar el acceso y ocultar la existencia son dos capas distintas de seguridad**, y que la segunda importa más de lo que parece: los nombres de las carpetas son información.
>
> Y una idea incómoda que te vas a encontrar toda tu vida profesional: **hay configuraciones que no se pueden verificar desde donde se escriben.** Por eso el apartado 8.a te dejó dos pruebas anotadas para la Fase 8 en vez de fingir que todo estaba comprobado.

---

# **AVERÍA 5 · ROMPER EL `smb.conf`** *(la que tira el dominio)*

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar `smb.conf` con un error de sintaxis — y **detectarlo con `testparm` antes de reiniciar**.
>
> **Por qué provocamos esta:** porque en esta fase `samba-ad-dc` no es un servidor de ficheros cualquiera: **es el controlador de dominio**. Un error aquí no te quita las carpetas compartidas — te quita el DNS, Kerberos y LDAP de golpe.

> [!danger] 🛑 NO reinicies el servicio con el fichero roto
> El objetivo es exactamente el contrario: **comprobar que `testparm` te avisa antes.**
>
> **Y antes de empezar, confirma que tienes la instantánea y la copia del fichero.**

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Te dirá `testparm` en qué línea está el error?
> 2. Si reiniciaras ahora, ¿qué dejaría de funcionar además de las carpetas?
> 3. ¿Seguirías pudiendo entrar por SSH?

### **1 · Romper**
```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo "[prueba3" | sudo tee -a /etc/samba/smb.conf
tail -3 /etc/samba/smb.conf
```
*(Fíjate en lo que falta: el corchete de cierre.)*

### **2 · Comprobar**
```bash
sudo testparm
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `testparm` | **Un error con su línea** | El validador ha hecho su trabajo |
| El verificador | **FALLO en `C1`** | Y te dice que no reinicies |
| `samba-ad-dc` | **Sigue `active`** | Porque no lo has reiniciado |

> [!success] 🎯 Esto es lo que tenías que ver
> **El servicio sigue funcionando con el fichero roto.** Samba lee la configuración al arrancar, no continuamente: el fichero está mal y el dominio sigue en pie **hasta el próximo reinicio**.
>
> Y ese reinicio no lo eliges tú necesariamente. Llega con una actualización, un corte de luz o el `restart` de un compañero.

### **3 · Consecuencias**
Una bomba de relojería. El servidor funciona perfectamente hoy y **no levanta el dominio** la próxima vez que arranque. Sin DNS, sin autenticación, con los clientes Windows diciendo *"no se encuentra el dominio"* y sin ninguna pista que apunte a un corchete.

### **4 · Reparar**
```bash
sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
systemctl is-active samba-ad-dc
host -t A ubuntuserver.boochanlab.local 127.0.0.1
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** `Loaded services file OK`, servicio `active`, el DNS responde y `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> **`testparm` es a `smb.conf` lo que `mount -a` era a `fstab`.** Mismo reflejo, otro servicio.
>
> Y la generalización, que es lo que de verdad te llevas: **un fichero de configuración roto no rompe nada hasta que el servicio lo relee.** Eso te da una ventana para descubrirlo — si la usas. Los validadores existen para eso: `nginx -t`, `visudo`, `named-checkconf`, `sshd -t`.
>
> **Un servicio que sigue funcionando no demuestra que su configuración sea válida.** Solo que todavía no la ha vuelto a leer.

---

# **AVERÍA 6 · EL RECURSO DUPLICADO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** declarar `[prueba3]` dos veces en `smb.conf`, con configuraciones distintas.
>
> **Por qué provocamos esta:** porque produce el síntoma más frustrante que existe: **cambias algo, reinicias, y no pasa nada.** Es el [[Fase_7.7_Resolucion_Problemas#E7 · Secciones duplicadas en smb.conf|caso E7]].

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se quejará `testparm` de que hay una sección repetida?
> 2. Si las dos dicen cosas distintas, ¿cuál gana?
> 3. ¿Cómo lo comprobarías?

### **1 · Romper**
```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo tee -a /etc/samba/smb.conf > /dev/null <<'EOF'

[prueba3]
    path = /srv/samba/prueba3
    read only = no
    access based share enum = no
EOF
grep -n "^\[prueba3\]" /etc/samba/smb.conf
```

### **2 · Comprobar**
```bash
sudo testparm
testparm -s --section-name=prueba3
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `grep -n` | **Dos líneas** con `[prueba3]` | Está duplicada |
| `testparm` | **No da error grave** | La sintaxis es correcta |
| `testparm -s --section-name` | La configuración **de la última** | Samba se queda con una |
| El verificador | **FALLO en `C4`** | Lo cuenta y lo dice |

> [!important] ✍️ Aquí anota tú lo que veas
> **Compara lo que dice `testparm -s --section-name=prueba3` con lo que tú escribiste al principio en el `smb.conf`.** ¿Coinciden? ¿Qué opciones se han perdido por el camino?

### **3 · Consecuencias**
Una configuración que dice una cosa y un servicio que hace otra. El administrador edita la primera sección, reinicia, no pasa nada; vuelve a editarla, reinicia, no pasa nada. **Y el fichero, leído de arriba abajo, parece correcto.**

### **4 · Reparar**
```bash
sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
grep -n "^\[prueba3\]" /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** una sola sección y `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> Que **el fichero de configuración y la configuración efectiva no son lo mismo**, y que hay una forma de preguntar por la segunda.
>
> `testparm -s` te enseña **lo que Samba entiende**, no lo que tú escribiste. Cuando un cambio "no hace nada", esa es la primera pregunta: *¿el servicio está leyendo lo que yo creo?*

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase7.sh
```

- **✅ Bien:** `VEREDICTO: FASE 7 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien. Vuelve a ella.

> [!warning] ⚠️ Comprueba que no te dejas restos
> ```bash
> ls -la /srv/samba/prueba3/
> ls -l /etc/samba/smb.conf*
> ```
> No deben quedar `antes.txt`, `despues.txt` ni ficheros `.bak` sueltos. **Un `.bak` olvidado no rompe nada, pero un servidor con seis copias de seguridad de la configuración es un servidor que nadie entiende.**

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y `FASE 7 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotado si viste el **`+`** de `ls -ld` en la avería 1.
- [ ] Copiada la línea con **`#effective`** de la avería 2.
- [ ] Anotado que en la avería 3 los ficheros **de antes y de después** salían distintos.
- [ ] Anotado que en la avería 4 **ningún comando del servidor** detectaba el problema.
- [ ] Avería 5 hecha **sin reiniciar con el fichero roto**.
- [ ] Comparada la configuración efectiva con la escrita, en la avería 6.
- [ ] Restos borrados: ficheros de prueba y `.bak`.
- [ ] Verificador pasado al final: `FASE 7 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F7 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.9_Preguntas]] | [[Fase_7]] | [[Fase_7.10.b_Auditoria_y_Cierre]] |
