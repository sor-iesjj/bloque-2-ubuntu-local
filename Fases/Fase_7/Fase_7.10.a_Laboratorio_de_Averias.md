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
> | **1.ª** | **0 · 1 · 2 · 3** | Los **permisos**: lo que se aplica, lo que no, y lo que sobra |
> | **2.ª** | **4 · 5 · 6** | La **publicación**: Samba, el dominio y la invisibilidad |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F7 · Laboratorio de averías`, con sus siete timestamps.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada.

> [!tip] 💡 Las averías siguen siempre el mismo guion
> **🎯 Objetivo** → **🤔 Predice** → **1. Romper** → **2. Comprobar** → **3. Consecuencias** → **4. Reparar** → **🎓 La lección**
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí.

---

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 7 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **0** | [[#**AVERÍA 0 · 🔴 EL PERMISO QUE SOBRA**\|🔴 EL PERMISO QUE SOBRA]] |
> | **1** | [[#**AVERÍA 1 · QUITAR LA ACL DEL GRUPO**\|QUITAR LA ACL DEL GRUPO]] |
> | **2** | [[#**AVERÍA 2 · LA MÁSCARA QUE ANULA EL PERMISO**\|LA MÁSCARA QUE ANULA EL PERMISO]] |
> | **3** | [[#**AVERÍA 3 · 🔴 QUITAR LA HERENCIA**\|🔴 QUITAR LA HERENCIA]] |
> | **4** | [[#**AVERÍA 4 · 🔴 QUITAR LA INVISIBILIDAD (ABE)**\|🔴 QUITAR LA INVISIBILIDAD (ABE)]] |
> | **5** | [[#**AVERÍA 5 · ROMPER EL `smb.conf`** *(la que tira el dominio)*\|ROMPER EL `smb.conf`]] |
> | **6** | [[#**AVERÍA 6 · EL RECURSO DUPLICADO**\|EL RECURSO DUPLICADO]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 0 · 🔴 EL PERMISO QUE SOBRA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dar a `comercial` acceso a la carpeta de **RRHH**. Un permiso que **no está en la matriz**.
>
> **Por qué va la primera:** porque es el fallo más grave que puede tener una política de permisos, y **el único que nadie te va a reportar nunca**.

> [!danger] 🛑 Un permiso de MÁS es peor que uno de menos
> **El de menos se nota enseguida:** alguien no puede trabajar, te llama, lo arreglas en dos minutos.
>
> **El de más no lo nota nadie.** Nadie llama para decir *"oye, puedo entrar en un sitio donde no debería"*. Se descubre el día que alguien lee lo que no tenía que leer — o no se descubre nunca.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se quejará el sistema al dar un permiso que no está en la política?
> 2. ¿Notará algo `ume.matsuzaka`, que trabaja en RRHH?
> 3. ¿Lo detectará el verificador? ¿Cómo podría saber que ese permiso sobra?

### **1 · Romper**
```bash
sudo setfacl -m g:comercial:rx /srv/samba/departamentos/rrhh
sudo setfacl -d -m g:comercial:rx /srv/samba/departamentos/rrhh
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/departamentos/rrhh
sudo -u 'BOOCHANLAB\masao.sato' ls /srv/samba/departamentos/rrhh
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| El `setfacl` | **Ni un mensaje** | El sistema no sabe cuál es tu política |
| `getfacl` | `group:comercial:r-x` en RRHH | El permiso está puesto |
| El `ls` como `masao.sato` | **Funciona** | Un comercial leyendo nóminas |
| El verificador | **FALLO en el bloque `C`** | Lo detecta porque **conoce la matriz** |

> [!danger] 🤯 Fíjate en por qué el verificador SÍ puede detectarlo
> El sistema no tiene ni idea de cuál es la política de Boochan S.L.: para él, `comercial` leyendo RRHH es tan válido como cualquier otra cosa.
>
> **El verificador lo detecta porque lleva la matriz escrita dentro**, en dos listas: `CRUCES` *(lo que debe existir)* y `PROHIBIDOS` *(lo que no)*. Ábrelo y míralas:
> ```bash
> grep -A 12 "^CRUCES=" verificar_fase7.sh
> grep -A 10 "^PROHIBIDOS=" verificar_fase7.sh
> ```
>
> **Una política que no está escrita en ningún sitio no se puede auditar.** Y si no se puede auditar, no existe.

### **3 · Consecuencias**
El departamento comercial puede leer nóminas, contratos y expedientes personales. **Nadie se entera**, porque nadie tiene motivo para mirarlo: los de RRHH no ven quién entra, y los de comercial no van a avisar.

En una empresa real esto no es un error técnico: es una **brecha de datos personales**, con su multa correspondiente.

### **4 · Reparar**
```bash
sudo setfacl -x g:comercial /srv/samba/departamentos/rrhh
sudo setfacl -d -x g:comercial /srv/samba/departamentos/rrhh
getfacl -p /srv/samba/departamentos/rrhh
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** RRHH vuelve a no tener ningún grupo ajeno, y `FASE 7 SUPERADA`.

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia el `getfacl` de RRHH antes y después.** Y contesta: **¿cómo detectarías este fallo en un servidor que no fuera tuyo, sin tener la matriz delante?**
>
> *(Pista incómoda: no podrías. Solo podrías listar quién tiene acceso a qué y preguntarle a alguien si eso es lo correcto.)*

> [!success] 🎓 La lección
> **El sistema aplica permisos; no juzga políticas.** `setfacl` hace exactamente lo que le pides, y lo que le pides puede ser un disparate.
>
> Y de ahí sale la idea más importante de toda la fase: **una política de permisos tiene que estar escrita fuera del sistema** —en un documento como [[Escenario_Boochan_SL]]— para poder comparar lo que hay contra lo que debería haber.
>
> Sin ese documento, la única respuesta posible a *"¿están bien los permisos de este servidor?"* es **"no lo sé"**.

---

# **AVERÍA 1 · QUITAR LA ACL DEL GRUPO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** eliminar el permiso del grupo `comercial` sobre `facturacion`, dejando la carpeta y el grupo intactos.
>
> **Por qué provocamos esta:** para ver el fallo **ruidoso** de los permisos y tenerlo como referencia. Las averías 2 y 3 producen el mismo daño **sin ningún ruido**, y solo se aprecia la diferencia habiendo visto esta primero.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Cambiará algo en `ls -ld`?
> 2. ¿Seguirá `masao.sato` perteneciendo al grupo?
> 3. ¿Podrá `masao.sato` escribir en la carpeta?

### **1 · Romper**
```bash
sudo setfacl -x g:comercial /srv/samba/departamentos/facturacion
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/departamentos/facturacion
ls -ld /srv/samba/departamentos/facturacion
id -nG masao.sato
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `getfacl` | Ya no está `group:comercial` | El permiso se ha ido |
| `ls -ld` | **Casi igual que antes** | Los permisos clásicos no han cambiado |
| `id -nG masao.sato` | Sigue en `comercial` | El usuario está bien; el permiso no |
| El verificador | **FALLO en `B1`** | Lo detecta |

> [!important] ✍️ Fíjate en el `ls -ld`
> Con ACL puestas, `ls -l` muestra un **`+`** al final de los permisos: `drwxrws---+`. Al quitar la ACL, ese `+` desaparece.
>
> **Anota en tu entrada si lo has visto**, porque es la única pista que da `ls` de que hay permisos avanzados detrás. Quien no sepa que ese `+` existe, no sabrá que tiene que mirar el `getfacl`.

### **3 · Consecuencias**
Los usuarios de `comercial` pierden el acceso por la vía de la ACL. Quedan solo los permisos clásicos de grupo — que aquí siguen funcionando, y por eso el daño real depende de cómo esté montado el conjunto.

### **4 · Reparar**
```bash
sudo setfacl -m g:comercial:rx /srv/samba/departamentos/facturacion
getfacl -p /srv/samba/departamentos/facturacion
sudo ./verificar_fase7.sh
```
- **✅ Reparado:** vuelve `group:comercial:r-x` y el verificador da `FASE 7 SUPERADA`.

> [!success] 🎓 La lección
> Que **hay dos sistemas de permisos conviviendo** sobre la misma carpeta: los clásicos de Unix (`rwx` para dueño, grupo y otros) y las ACL, que permiten dar permisos a **varios** grupos y usuarios distintos.
>
> Y que `ls -l` solo te enseña los primeros. **El `+` es el aviso de que hay más**, y hay que ir a buscarlo con `getfacl`.

---

# **AVERÍA 2 · LA MÁSCARA QUE ANULA EL PERMISO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** bajar la máscara de la ACL, dejando el permiso del grupo **escrito y visible** pero sin efecto.
>
> **Por qué provocamos esta:** porque es **la trampa más fina de toda la fase**. El permiso sigue ahí, se lee `r-x`, y no funciona. Es el [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]].

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá apareciendo `group:comercial:r-x` en el `getfacl`?
> 2. ¿Podrá escribir alguien del grupo?
> 3. ¿Qué crees que va a cambiar en la salida?

### **1 · Romper**
```bash
sudo setfacl -m m::r-- /srv/samba/departamentos/facturacion
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/departamentos/facturacion
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Dónde miras | Qué verás |
| :--- | :--- |
| La línea del grupo | `group:comercial:r-x` — **igual que antes** |
| Al final de esa línea | `#effective:r--` — **esto es nuevo** |
| La línea `mask::` | `mask::r--` |
| El verificador | **FALLO en `B2`** |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> **Pone `r-x` y significa `r--`.** El permiso está escrito, es correcto, y no se aplica.
>
> Si leyeras esta ACL con prisa —y todo el mundo lee las ACL con prisa— verías `group:comercial:r-x` y darías el problema por descartado. **La información que lo desmiente está a la derecha, en una columna que casi nadie mira.**

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia la línea completa en tu entrada de apuntes**, con su `#effective`. Y responde: si un compañero te enseña esta salida diciendo *"el permiso está puesto y no funciona"*, ¿qué le dirías en diez segundos?

### **3 · Consecuencias**
Nadie del grupo puede escribir, y la ACL parece correcta. El diagnóstico se va a los sitios equivocados —el usuario, el grupo, Samba, el montaje— porque el permiso "ya está comprobado".

### **4 · Reparar**
```bash
sudo setfacl -m m::rwx /srv/samba/departamentos/facturacion
getfacl -p /srv/samba/departamentos/facturacion
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
sudo touch /srv/samba/departamentos/facturacion/antes.txt
sudo getfacl -p /srv/samba/departamentos/facturacion/antes.txt | grep comercial
```
Y ahora quita la herencia:
```bash
sudo setfacl -k /srv/samba/departamentos/facturacion
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/departamentos/facturacion
sudo touch /srv/samba/departamentos/facturacion/despues.txt
sudo getfacl -p /srv/samba/departamentos/facturacion/despues.txt | grep comercial
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Qué miras | Resultado |
| :--- | :--- |
| ACL de la carpeta | **Sigue teniendo** `group:comercial:r-x` |
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
sudo setfacl -d -m g:comercial:rx /srv/samba/departamentos/facturacion
sudo setfacl -R -m g:comercial:rx /srv/samba/departamentos/facturacion
sudo rm -f /srv/samba/departamentos/facturacion/antes.txt /srv/samba/departamentos/facturacion/despues.txt
getfacl -p /srv/samba/departamentos/facturacion
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
> **Qué vamos a provocar:** desactivar `access based share enum` en `[facturacion]`.
>
> **Por qué provocamos esta:** porque es **el fallo invisible de la fase**, el [[Fase_7.7_Resolucion_Problemas#E5 · Una carpeta protegida se ve desde Windows|caso E5]]. Desde el servidor **no vas a notar absolutamente nada**, y ese es justo el ejercicio.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrá `shinnosuke.nohara` entrar en la carpeta después de esto?
> 2. ¿Podrá **verla** en el listado de red?
> 3. ¿Habrá algún comando en el servidor que te diga que algo va mal?

### **1 · Romper**
Copia de seguridad primero — **siempre, antes de tocar `smb.conf`**:
```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo sed -i 's/^\( *access based share enum *=\) *yes/\1 no/I' /etc/samba/smb.conf
sudo testparm -s --section-name=facturacion | grep -i "access based"
```
Y aplica el cambio, **validando antes**:
```bash
sudo testparm
sudo systemctl restart samba-ad-dc
```

### **2 · Comprobar**
```bash
getfacl -p /srv/samba/departamentos/facturacion
ls -ld /srv/samba/departamentos/facturacion
systemctl is-active samba-ad-dc
testparm -s --section-name=facturacion
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
> **Nada.** El acceso sigue perfectamente protegido: `shinnosuke.nohara` no puede entrar en la carpeta. Los permisos son correctos, las ACL son correctas, el servicio funciona.
>
> Lo único que has roto es que ahora `shinnosuke.nohara` **ve que la carpeta existe**. Y eso no se puede comprobar desde Ubuntu por ningún medio: hace falta un cliente Windows mirando el listado de red.

### **3 · Consecuencias**
Un usuario sin autorización ve una lista de carpetas con nombres como `facturacion` —o, en un servidor real, `nominas`, `expedientes`, `direccion`—. No puede abrirlas, pero **ya sabe qué hay, dónde está y a quién pedírselo**.

Y hay algo peor: el administrador cree que la protección está completa, porque desde su lado **lo parece**.

### **4 · Reparar**
```bash
sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
sudo testparm
sudo systemctl restart samba-ad-dc
testparm -s --section-name=facturacion | grep -i "access based"
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
echo "[facturacion" | sudo tee -a /etc/samba/smb.conf
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
> **Qué vamos a provocar:** declarar `[facturacion]` dos veces en `smb.conf`, con configuraciones distintas.
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

[facturacion]
    path = /srv/samba/departamentos/facturacion
    read only = no
    access based share enum = no
EOF
grep -n "^\[facturacion\]" /etc/samba/smb.conf
```

### **2 · Comprobar**
```bash
sudo testparm
testparm -s --section-name=facturacion
sudo ./verificar_fase7.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `grep -n` | **Dos líneas** con `[facturacion]` | Está duplicada |
| `testparm` | **No da error grave** | La sintaxis es correcta |
| `testparm -s --section-name` | La configuración **de la última** | Samba se queda con una |
| El verificador | **FALLO en `C4`** | Lo cuenta y lo dice |

> [!important] ✍️ Aquí anota tú lo que veas
> **Compara lo que dice `testparm -s --section-name=facturacion` con lo que tú escribiste al principio en el `smb.conf`.** ¿Coinciden? ¿Qué opciones se han perdido por el camino?

### **3 · Consecuencias**
Una configuración que dice una cosa y un servicio que hace otra. El administrador edita la primera sección, reinicia, no pasa nada; vuelve a editarla, reinicia, no pasa nada. **Y el fichero, leído de arriba abajo, parece correcto.**

### **4 · Reparar**
```bash
sudo mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
grep -n "^\[facturacion\]" /etc/samba/smb.conf
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
> ls -la /srv/samba/departamentos/facturacion/
> ls -l /etc/samba/smb.conf*
> ```
> No deben quedar `antes.txt`, `despues.txt` ni ficheros `.bak` sueltos. **Un `.bak` olvidado no rompe nada, pero un servidor con seis copias de seguridad de la configuración es un servidor que nadie entiende.**

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **0, 1, 2 y 3**, y `FASE 7 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] 🔴 Anotado el `getfacl` de **RRHH antes y después** de la avería 0, y por qué el verificador sí puede detectar un permiso que sobra.
- [ ] Anotado si viste el **`+`** de `ls -ld` en la avería 1.
- [ ] Copiada la línea con **`#effective`** de la avería 2.
- [ ] Anotado que en la avería 3 los ficheros **de antes y de después** salían distintos.
- [ ] Anotado que en la avería 4 **ningún comando del servidor** detectaba el problema.
- [ ] Avería 5 hecha **sin reiniciar con el fichero roto**.
- [ ] Comparada la configuración efectiva con la escrita, en la avería 6.
- [ ] Restos borrados: ficheros de prueba y `.bak`.
- [ ] Verificador pasado al final: `FASE 7 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F7 · Laboratorio de averías`**, con un timestamp por avería (siete).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.9_Preguntas]] | [[Fase_7]] | [[Fase_7.10.b_Auditoria_y_Cierre]] |
