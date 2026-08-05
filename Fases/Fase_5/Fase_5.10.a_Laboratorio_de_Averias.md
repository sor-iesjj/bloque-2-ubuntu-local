## Fase 5 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper las identidades a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 5 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_5.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script del apartado [[Fase_5.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase5.sh
> chmod +x verificar_fase5.sh
> ```

> [!warning] 🖥️ Estas averías NO te cortan el acceso SSH
> Entras con tu usuario local de Linux (`boochan`), que no depende del dominio ni de winbind. Puedes romper la identidad de los usuarios de dominio sin quedarte fuera.
>
> **Y esa es ya una lección:** por eso un servidor bien montado conserva **un usuario local de administración**. El día que el dominio falle, es tu única puerta.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Las identidades son la parte del sistema que **peor avisa cuando falla**. Los síntomas que produce —*"no existe el usuario"*, *"permiso denegado"*, una carpeta que aparece a nombre de un número— **no señalan nunca a la causa real**.
>
> Aquí no vas a aprender a crear usuarios: eso ya lo has hecho. Vas a aprender a **reconocer una identidad rota**, que es lo que te encontrarás de verdad.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3** | La **visibilidad**: el usuario existe y el sistema no lo ve |
> | **2.ª** | **4 · 5 · 6** | Los **fallos silenciosos**: los que no se notan hoy |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F5 · Laboratorio de averías`, con sus seis timestamps.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada. Si no sale `FASE 5 SUPERADA`, algo quedó sin reparar y lo confundirías con la avería nueva.

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

# **AVERÍA 1 · PARAR EL TRADUCTOR**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** detener `winbind` **dejando el dominio y los usuarios intactos**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Se para el traductor
> 2. Linux deja de poder convertir "usuario del dominio" en "usuario que entiendo"
> 3. `id user1` empieza a decir que no existe
> 4. Y los usuarios **siguen ahí**, perfectamente creados, en la base de datos del dominio
>
> **Por qué provocamos esta:** porque el síntoma —*"se han borrado los usuarios"*— es **falso**. No se ha borrado nada. Y quien no lo sepa, empezará a recrearlos encima.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá funcionando tu conexión SSH?
> 2. ¿Seguirá `samba-tool user list` mostrando a `user1`?
> 3. ¿Se habrá borrado algo?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
```bash
sudo systemctl stop winbind
```

### **2 · Comprobar**
```bash
systemctl is-active winbind
id user1
sudo samba-tool user list | grep user1
getent passwd user1
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-active` | `inactive` | El traductor está parado |
| `id user1` | `no such user` | Linux no puede resolverlo |
| `samba-tool user list` | **Aparece `user1`** | El usuario **existe**. No se ha perdido nada |
| `getent passwd` | Nada | La vía normal tampoco lo encuentra |

**Y tu sesión SSH sigue funcionando**, porque `boochan` es un usuario **local**, no del dominio.

### **3 · Consecuencias**
Un servidor con todos sus usuarios intactos y **ninguno utilizable**. Nadie podría iniciar sesión con una cuenta del dominio. Y si alguien te dijera *"se han borrado los usuarios"*, tendrías que llegar tú solo hasta aquí para saber que no es verdad.

### **4 · Reparar**
```bash
sudo systemctl start winbind
sleep 3
id user1
```
- **✅ Reparado:** `id user1` vuelve a devolver `uid=10001 gid=3001`.

> [!success] 🎓 La lección
> **"No existe" y "no lo veo" son cosas distintas**, y el sistema te dice siempre la segunda.
>
> De ahí una regla de diagnóstico que vale para cualquier servidor: **antes de recrear algo que parece perdido, comprueba en el origen si sigue estando.** Recrear encima de lo que ya existe es como se convierte un problema pequeño en uno grande.

---

# **AVERÍA 2 · EL TRADUCTOR AL QUE NADIE PREGUNTA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** quitar `winbind` de `/etc/nsswitch.conf` **dejando el servicio funcionando perfectamente**.
>
> **Por qué provocamos esta:** porque produce **exactamente el mismo síntoma que la avería 1** con una causa completamente distinta. Es el ejercicio de diagnóstico de la fase: dos causas, un solo síntoma.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Dirá `systemctl is-active winbind` que algo va mal?
> 2. ¿Y `wbinfo -u`?
> 3. ¿En qué se diferenciará esto de la avería 1?

### **1 · Romper**
Primero haz copia, que es lo que hace un administrador antes de tocar un fichero de configuración:
```bash
sudo cp /etc/nsswitch.conf /etc/nsswitch.conf.bak
sudo sed -i 's/^\(passwd:.*\) winbind/\1/; s/^\(group:.*\) winbind/\1/' /etc/nsswitch.conf
grep -E "^passwd:|^group:" /etc/nsswitch.conf
```

### **2 · Comprobar**
```bash
systemctl is-active winbind
wbinfo -u
id user1
getent passwd user1
sudo ./verificar_fase5.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-active` | **`active`** | El traductor está **perfecto** |
| `wbinfo -u` | **Lista los usuarios** | Y además está hablando con el dominio |
| `id user1` | `no such user` | Pero nadie le pregunta a él |
| El verificador | **FALLO en `B3`/`B4`** | Señala el fichero exacto |

> [!danger] 🤯 Compara esto con la avería 1
> **El mismo síntoma. Otra causa.** En la 1, winbind estaba muerto. Aquí está vivo y respondiendo — solo que Linux no le consulta.
>
> Si te limitas a mirar `id user1`, las dos averías son idénticas. **`wbinfo` es lo que las separa**, porque pregunta por un camino distinto.

### **3 · Consecuencias**
Idénticas a la avería 1 de cara al usuario: nadie del dominio puede entrar. Pero quien diagnostique mirando el servicio dirá *"winbind está bien"* y se quedará atascado, porque está mirando la pieza equivocada.

### **4 · Reparar**
```bash
sudo mv /etc/nsswitch.conf.bak /etc/nsswitch.conf
grep -E "^passwd:|^group:" /etc/nsswitch.conf
id user1
sudo ./verificar_fase5.sh
```
- **✅ Reparado:** las dos líneas vuelven a terminar en `winbind` y el verificador en `FASE 5 SUPERADA`.

> [!success] 🎓 La lección
> **Un mismo síntoma puede tener varias causas, y el síntoma nunca te dice cuál.** Diagnosticar es recorrer el camino por tramos hasta encontrar dónde se corta.
>
> Y la técnica concreta, que te va a servir siempre: **cuando dos herramientas preguntan lo mismo por caminos distintos, compararlas te localiza el tramo roto.** Aquí `wbinfo` contra `getent`; en la Fase 4 era `ping` contra `getent hosts`.

---

# **AVERÍA 3 · EL USUARIO QUE YA NO PERTENECE A SU GRUPO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** sacar a `user1` del grupo `policia` dentro del dominio.
>
> **Por qué provocamos esta:** porque es la avería que **prepara la Fase 7**. Allí los permisos se darán al grupo; un usuario fuera del grupo tendrá una cuenta perfecta y no verá sus carpetas.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá existiendo `user1`?
> 2. ¿Cambiará algo en `id -u user1`?
> 3. ¿Y en `id -nG user1`?

### **1 · Romper**
```bash
sudo samba-tool group removemembers policia user1
```

### **2 · Comprobar**
```bash
id -u user1
id -nG user1
sudo samba-tool group listmembers policia
sudo ./verificar_fase5.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `id -u user1` | **`10001`** | El usuario está perfecto |
| `id -nG user1` | Ya no sale `policia` | Pero ha perdido su pertenencia |
| `listmembers` | Lista vacía o sin `user1` | El dominio tampoco lo cuenta |

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes qué devuelve `id -nG user1` antes y después.** Y responde: si en la Fase 7 dieras permiso a `policia` sobre una carpeta, ¿qué vería `user1`?

### **3 · Consecuencias**
Una cuenta que funciona, entra y autentica — y **no accede a nada de lo suyo**. El usuario diría *"no tengo permisos"*, el administrador miraría los permisos de la carpeta, los vería correctos, y no encontraría nada raro. El problema no está en la carpeta: está en quién es él.

### **4 · Reparar**
```bash
sudo samba-tool group addmembers policia user1
id -nG user1
sudo ./verificar_fase5.sh
```
- **✅ Reparado:** `policia` vuelve a aparecer y el verificador da `FASE 5 SUPERADA`.

> [!success] 🎓 La lección
> **Los permisos no se dan a personas: se dan a grupos.** Y por eso un problema de permisos casi nunca se arregla mirando el fichero — se arregla mirando **a qué grupos pertenece quien se queja**.
>
> Es el primer reflejo profesional que hay que coger: ante un *"no tengo acceso"*, `id -nG` antes que nada.

---

# **AVERÍA 4 · 🔴 EL USUARIO CREADO SIN NÚMERO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** crear un usuario **sin** `--uid-number`, como lo haría quien copia un comando de internet.
>
> **Por qué provocamos esta:** porque es **el fallo silencioso de la fase**, el [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los que yo puse|caso E7]], provocado a propósito y en condiciones controladas.
>
> No da ningún error. El usuario se crea, funciona, entra. Y arrastra un número que tú no elegiste.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Se creará el usuario sin protestar?
> 2. ¿Devolverá `id user3` algo?
> 3. ¿Qué número crees que le tocará?
>
> **La 3 es la importante.** Escríbela antes de mirar.

### **1 · Romper**
```bash
sudo samba-tool user create user3 'P@ssw0rd'
```
*(Fíjate en lo que NO lleva: ni `--uid-number` ni `--gid-number`.)*

### **2 · Comprobar**
```bash
sudo samba-tool user list | grep user3
id user3
id user1
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `samba-tool user list` | **Aparece `user3`** | Se creó sin ningún error |
| `id user3` | Un UID **enorme y raro** *(o nada)* | Se lo ha inventado el sistema |
| `id user1` | `10001` | El tuyo, el que elegiste |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> **No ha habido ni un solo error.** Ni un aviso, ni una línea en el registro. El comando ha funcionado exactamente igual de bien que el del Paso 3 del procedimiento.
>
> La única diferencia está en un parámetro que no pusiste, y en un número que no volverás a mirar hasta que algo se rompa dentro de dos fases.

### **3 · Consecuencias**
Un usuario con un número asignado por la máquina. Hoy funciona. Pero ese número **puede cambiar** si rehaces el dominio o restauras en otra máquina — y entonces todos sus ficheros quedan a nombre de un número sin dueño. En la Fase 7, los permisos que des a `3001` no le alcanzarán nunca.

### **4 · Reparar**
Este usuario sobra: bórralo, que es lo que harías en un servidor real con una cuenta creada por error.
```bash
sudo samba-tool user delete user3
sudo samba-tool user list | grep user3
sudo ./verificar_fase5.sh
```
- **✅ Reparado:** `user3` ya no aparece y el verificador da `FASE 5 SUPERADA`.

> [!success] 🎓 La lección
> **El fallo que no da error es el caro.** Es la misma idea de la Fase 4 con el dominio anunciado en la tarjeta equivocada, y volverá a aparecer.
>
> Y la regla práctica: **cuando un sistema te deja elegir un identificador, elígelo tú.** Lo que asigna la máquina por su cuenta, la máquina se lo puede volver a asignar de otra manera — y las dos veces tendrá razón.

---

# **AVERÍA 5 · DOS PERSONAS CON EL MISMO NÚMERO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** crear un usuario nuevo con **el mismo UID que `user1`**.
>
> **Por qué provocamos esta:** porque enseña qué es de verdad una identidad en Unix. Y porque el sistema **te va a dejar hacerlo sin rechistar**.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Te dejará el sistema poner un UID repetido?
> 2. Si `user4` crea un fichero, ¿de quién dirá `ls -l` que es?

### **1 · Romper**
```bash
sudo samba-tool user create user4 'P@ssw0rd' --uid-number=10001 --gid-number=3001
sudo systemctl restart winbind
```

### **2 · Comprobar**
```bash
id -u user1
id -u user4
sudo -u user1 touch /tmp/prueba_identidad 2>/dev/null || sudo touch /tmp/prueba_identidad
ls -ln /tmp/prueba_identidad
ls -l /tmp/prueba_identidad
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| Los dos `id -u` | **El mismo número** | Para el sistema son la misma identidad |
| `ls -ln` | El número `10001` | Lo que el sistema guarda **de verdad** |
| `ls -l` | **Un solo nombre** | El nombre es una traducción, y solo cabe uno |

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes qué nombre muestra `ls -l`.** ¿Sale `user1` o `user4`? ¿Y por qué crees que sale ese y no el otro?

### **3 · Consecuencias**
Dos cuentas distintas, con dos contraseñas distintas, que para el sistema de ficheros **son la misma persona**. Cualquiera de las dos puede leer, modificar y borrar los ficheros de la otra. Y ninguna auditoría podría distinguir quién hizo qué: los registros guardan el número.

### **4 · Reparar**
```bash
sudo samba-tool user delete user4
sudo rm -f /tmp/prueba_identidad
id -u user1
sudo ./verificar_fase5.sh
```
- **✅ Reparado:** `user4` ya no existe y el verificador da `FASE 5 SUPERADA`.

> [!success] 🎓 La lección
> **En Unix, un usuario no es su nombre: es su número.** El nombre es una etiqueta que se consulta en una tabla para mostrártelo bonito.
>
> Es la misma lección del choque de máquinas de la [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|Fase 1]]: **dos cosas con la misma identidad no son dos cosas.** Allí eran dos servidores clonados con la misma clave de host; aquí, dos personas con el mismo UID. El sistema no lo impide, y por eso te toca a ti no hacerlo.

---

# **AVERÍA 6 · LAS IDENTIDADES QUE NO SOBREVIVEN AL REINICIO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar los usuarios funcionando **hoy** y desaparecidos **mañana**.
>
> **Por qué provocamos esta:** porque es la avería que no se ve haciendo comprobaciones normales. Todo está bien… hasta que apagas.

> [!question] 🤔 Predice antes de ejecutar
> 1. Tras el `disable`, ¿seguirá funcionando `id user1` **ahora**?
> 2. ¿Lo detectaría una comprobación que solo mirase `is-active`?

### **1 · Romper**
```bash
sudo systemctl disable winbind
systemctl is-active winbind
systemctl is-enabled winbind
```

### **2 · Comprobar**
```bash
id user1
sudo ./verificar_fase5.sh
```

| Qué mira | Resultado |
| :--- | :--- |
| `is-active` | **`active`** — winbind funciona perfectamente |
| `is-enabled` | **`disabled`** — no arrancará la próxima vez |
| `id user1` | **Responde bien** — hoy no pasa nada |
| El verificador | **FALLO en `B2`** |

**Y ahora compruébalo de verdad:** reinicia la máquina.
```bash
sudo reboot
```
Cuando vuelva, entra y mira:
```bash
systemctl is-active winbind
id user1
```

### **3 · Consecuencias**
Un servidor de identidades que funciona hasta el primer corte de luz. Y el primer corte de luz llega siempre en el peor momento — normalmente el día que le enseñas el trabajo a alguien.

### **4 · Reparar**
```bash
sudo systemctl enable --now winbind
systemctl is-enabled winbind
id user1
sudo ./verificar_fase5.sh
```
- **✅ Reparado:** `enabled`, y el verificador en `FASE 5 SUPERADA`.

> [!success] 🎓 La lección
> **`active` es "ahora". `enabled` es "la próxima vez".** Son dos preguntas distintas y hay que hacer las dos.
>
> Es la misma idea que en la Fase 1 con el `netplan`, en la Fase 3 con `wg-quick@wg0` y en la Fase 4 con `samba-ad-dc`. **Cuatro fases distintas enseñando lo mismo: lo que no persiste, no está configurado.** Si a estas alturas ya lo habías predicho, has aprendido justo lo que había que aprender.

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase5.sh
```

- **✅ Bien:** `VEREDICTO: FASE 5 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien. Vuelve a ella.

> [!tip] 💡 Si algo se te ha quedado torcido, tienes la instantánea
> Restaura `Fase 5 terminada` y vuelves al punto bueno. **Para eso la tomaste antes de empezar.**

> [!warning] ⚠️ Comprueba que no te dejas usuarios de prueba
> Las averías 4 y 5 crean `user3` y `user4`. **Los dos tienen que estar borrados** antes de pasar a la Fase 6, o te los encontrarás en los permisos de la Fase 7 sin acordarte de dónde salieron:
> ```bash
> sudo samba-tool user list
> ```
> Solo deben aparecer los usuarios del sistema, `user1` y `user2`.

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y `FASE 5 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotada la diferencia entre la avería 1 y la 2, **con el papel de `wbinfo`**.
- [ ] Anotado qué devuelve `id -nG user1` antes y después de la avería 3.
- [ ] Anotado **qué nombre muestra `ls -l`** en la avería 5, y por qué.
- [ ] Reinicio hecho en la avería 6, y comprobado el resultado.
- [ ] `user3` y `user4` **borrados**.
- [ ] Verificador pasado al final: `FASE 5 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F5 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.9_Preguntas]] | [[Fase_5]] | [[Fase_5.10.b_Auditoria_y_Cierre]] |
