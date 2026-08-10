## Fase 4 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4_Aprovisionamiento_del_Dominio]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper el dominio a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 4 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_4.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script del apartado [[Fase_4.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase4.sh
> chmod +x verificar_fase4.sh
> ```

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase4.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase4.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**

> [!warning] 🖥️ Estas averías NO te cortan el acceso SSH
> A diferencia de la Fase 1, aquí puedes trabajar cómodamente por SSH: ninguna de las seis toca la red del laboratorio ni el servicio SSH.
>
> **La única que da un susto es la 3**, que te deja sin resolución de nombres. El acceso por `10.10.10.10` sigue funcionando porque es una IP, no un nombre — y esa es justo la lección.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Un dominio es lo más frágil que has montado hasta ahora, y lo que peor avisa cuando falla. Los errores que da un cliente —*"No se encuentra el dominio"*, *"El nombre de usuario o la contraseña son incorrectos"*— **no señalan nunca a la causa real**.
>
> Por eso aquí no vas a aprender a montar un dominio: eso ya lo has hecho. Vas a aprender a **reconocer un dominio roto**, que es lo que te encontrarás de verdad.

> [!important] 🗓️ Esto va en DOS SESIONES, no en una
> | Sesión | Averías | Qué tienen en común |
> | :--- | :--- | :--- |
> | **1.ª** | **1 · 2 · 3** | El **servicio** y el **DNS**: lo que tira el dominio entero |
> | **2.ª** | **4 · 5 · 6** | Los **fallos silenciosos**: los que no se notan hoy |
>
> **Sigue siendo UN SOLO vídeo**, `B2 · F4 · Laboratorio de averías`, con sus seis timestamps.
>
> **Al empezar la segunda sesión**, pasa el verificador antes de romper nada. Si no sale `FASE 4 SUPERADA`, algo quedó sin reparar y lo confundirías con la avería nueva.

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

---

## 🗺️ **LAS AVERÍAS DE ESTE LABORATORIO**

> [!abstract] 6 averías, y todas siguen el mismo guion: **romper → comprobar → diagnosticar → reparar**
> | # | Qué vas a romper |
> | :--- | :--- |
> | **1** | [[#**AVERÍA 1 · PARAR EL CONTROLADOR DE DOMINIO**\|PARAR EL CONTROLADOR DE DOMINIO]] |
> | **2** | [[#**AVERÍA 2 · LEVANTAR EL SAMBA CLÁSICO A LA VEZ**\|LEVANTAR EL SAMBA CLÁSICO A LA VEZ]] |
> | **3** | [[#**AVERÍA 3 · ROMPER EL DNS DEL SERVIDOR**\|ROMPER EL DNS DEL SERVIDOR]] |
> | **4** | [[#**AVERÍA 4 · 🔴 BORRAR EL REGISTRO DEL SERVIDOR EN SU PROPIO DNS**\|🔴 BORRAR EL REGISTRO DEL SERVIDOR EN SU PROPIO DNS]] |
> | **5** | [[#**AVERÍA 5 · EL REINO DE KERBEROS EN MINÚSCULAS**\|EL REINO DE KERBEROS EN MINÚSCULAS]] |
> | **6** | [[#**AVERÍA 6 · EL DOMINIO QUE NO SOBREVIVE AL REINICIO**\|EL DOMINIO QUE NO SOBREVIVE AL REINICIO]] |
>
> **Hazlas en orden.** Y si vuelves aquí a buscar una concreta, esta tabla es tu atajo.

---

# **AVERÍA 1 · PARAR EL CONTROLADOR DE DOMINIO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** detener `samba-ad-dc` **dejando toda su configuración intacta**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Se para el servicio del dominio
> 2. Con él se para **el DNS**, porque el DNS del dominio lo sirve Samba
> 3. Al caer el DNS, el servidor **deja de resolver nombres** — incluido el suyo propio
> 4. Y como `/etc/resolv.conf` apunta a `127.0.0.1`, tampoco resuelve los de Internet
>
> **Por qué provocamos esta:** porque enseña que en un AD DC **el dominio y el DNS son el mismo servicio**. Parar uno es parar los dos, y el síntoma que ves —*"no hay internet"*— no menciona el dominio por ningún sitio.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Seguirá funcionando tu conexión SSH por `10.10.10.10`?
> 2. ¿Podrás hacer `ping 8.8.8.8`? ¿Y `ping google.com`?
> 3. ¿Se habrá borrado algo de la configuración del dominio?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
```bash
sudo systemctl stop samba-ad-dc
```

### **2 · Comprobar**
```bash
systemctl is-active samba-ad-dc
ping -c2 8.8.8.8
getent hosts archive.ubuntu.com
host -t A ubuntuserver.boochanlab.local 127.0.0.1
sudo samba-tool domain level show
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-active` | `inactive` | El servicio está parado |
| `ping 8.8.8.8` | **Responde** | Hay red. El problema **no es de red** |
| `getent hosts` | **Nada** | No hay quien resuelva nombres |
| `host …` | Error de conexión | El DNS del dominio ha caído con el servicio |
| `samba-tool` | Error | No hay dominio al que preguntar |

**Y tu sesión SSH sigue funcionando**, porque entraste por una **IP**, no por un nombre.

### **3 · Consecuencias**
El servidor está encendido, accesible y **completamente inútil como dominio**. Ningún cliente podría autenticarse. Y si alguien te dijera *"no me va internet en el servidor"*, tendrías que llegar tú solo hasta aquí.

### **4 · Reparar**
```bash
sudo systemctl start samba-ad-dc
sleep 5
systemctl is-active samba-ad-dc
host -t A ubuntuserver.boochanlab.local 127.0.0.1
```
- **✅ Reparado:** `active`, y el `host` vuelve a devolver `10.10.10.10`.

> [!success] 🎓 La lección
> **En un controlador de dominio, el DNS no es un servicio aparte: es parte del dominio.**
>
> Y de ahí sale una regla de diagnóstico que vale para cualquier servidor: **cuando "no hay internet", comprueba primero si hay red.** `ping` a una IP no usa DNS. Si la IP responde y el nombre no, el problema **nunca** es la conexión.

---

# **AVERÍA 2 · LEVANTAR EL SAMBA CLÁSICO A LA VEZ**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** arrancar `smbd`, el Samba clásico, con el controlador de dominio funcionando.
>
> **Por qué provocamos esta:** porque en la Fase 2 comprobabas que `smbd` **estuviera encendido** y era correcto. Aquí es un estorbo. **La misma comprobación cambia de signo según la fase**, y entender eso vale más que memorizar una lista.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Arrancará `smbd` sin protestar?
> 2. ¿Seguirá funcionando el dominio?
> 3. ¿Dirá alguno de los dos que el otro le estorba?

### **1 · Romper**
```bash
sudo systemctl unmask smbd 2>/dev/null
sudo systemctl start smbd
```

### **2 · Comprobar**
```bash
systemctl is-active smbd samba-ad-dc
sudo ss -tlnp | grep -E ":(139|445) "
sudo journalctl -u smbd -n 20 --no-pager
sudo ./verificar_fase4.sh
```

> [!important] ✍️ Aquí anota tú lo que veas
> **Copia en tu entrada de apuntes qué proceso ocupa los puertos 139 y 445**, y si alguno de los dos servicios se queja en el registro.
>
> Lo que **sí** te garantizo es que el verificador lo detectará: el bloque `B3` comprueba justamente que el Samba clásico esté apagado.

### **3 · Consecuencias**
Dos programas peleándose por los mismos puertos. Puede que uno gane, puede que fallen los dos, puede que funcione a ratos. **Los fallos intermitentes son los más caros de diagnosticar** precisamente porque no se reproducen cuando los buscas.

### **4 · Reparar**
```bash
sudo systemctl disable --now smbd
systemctl is-active smbd
sudo systemctl restart samba-ad-dc
sudo ./verificar_fase4.sh
```
- **✅ Reparado:** `smbd` en `inactive` y el verificador en `FASE 4 SUPERADA`.

> [!success] 🎓 La lección
> **`samba` y `samba-ad-dc` son dos formas incompatibles de usar el mismo programa.** No es que uno sea mejor: es que hacen cosas distintas y no caben a la vez.
>
> Y algo más general: **un servicio que estorba casi nunca dice "estorbo".** Dice "puerto ocupado", o no arranca, o va a ratos.

---

# **AVERÍA 3 · ROMPER EL DNS DEL SERVIDOR**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** hacer que el servidor pregunte a Google en vez de a sí mismo.
>
> **Qué dejará de funcionar, en cadena:**
> 1. El servidor resolverá **perfectamente** los nombres de Internet
> 2. Y dejará de resolver **los de su propio dominio**, porque Google no sabe nada de `boochanlab.local`
> 3. Cualquier orden con `samba-tool` que necesite localizar el dominio empezará a fallar
>
> **Por qué provocamos esta:** porque es una avería **al revés de lo que esperas**. Internet va mejor que nunca y el dominio no existe.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Podrás quitar la protección del fichero con `sudo` a la primera?
> 2. Con el DNS apuntando a Google, ¿funcionará `apt update`?
> 3. ¿Y `host -t A ubuntuserver.boochanlab.local`?
> 4. ¿Se te caerá la sesión SSH?

### **1 · Romper**
```bash
sudo chattr -i /etc/resolv.conf
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### **2 · Comprobar**
```bash
cat /etc/resolv.conf
getent hosts archive.ubuntu.com
host -t A ubuntuserver.boochanlab.local
sudo samba-tool domain level show
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `getent hosts` | **Resuelve bien** | Internet va perfectamente |
| `host` del dominio | **No lo encuentra** | Google no sabe qué es `boochanlab.local` |
| Tu sesión SSH | **Sigue viva** | Entraste por IP, no por nombre |

### **3 · Consecuencias**
Un servidor que resuelve el mundo entero **menos a sí mismo**. Ningún cliente podría unirse al dominio, y el mensaje que verían sería *"No se encuentra el dominio"* — sin ninguna pista de que el problema es una línea en un fichero.

### **4 · Reparar**
```bash
sudo rm -f /etc/resolv.conf
printf "nameserver 127.0.0.1\nsearch BOOCHANLAB.LOCAL\n" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
lsattr /etc/resolv.conf
host -t A ubuntuserver.boochanlab.local 127.0.0.1
```
- **✅ Reparado:** aparece la `i` en `lsattr`, y el `host` devuelve `10.10.10.10`.

> [!danger] ⚠️ No te dejes la `i` sin poner
> Si reparas el contenido pero **no vuelves a poner la protección**, el fichero aguanta hasta el próximo reinicio. Y entonces vuelve el problema, sin que lo relaciones con lo de hoy.
>
> **Protección que se quita y no se repone es protección que no existe.**

> [!success] 🎓 La lección
> **"Funciona internet" y "funciona el DNS que necesito" son dos cosas distintas.**
>
> Un servidor de dominio tiene que preguntarse **a sí mismo** por los nombres de su dominio, y reenviar hacia fuera lo demás. Si lo apuntas a un DNS público, ganas internet y pierdes el dominio — que es exactamente lo contrario de lo que necesitas.

---

# **AVERÍA 4 · 🔴 BORRAR EL REGISTRO DEL SERVIDOR EN SU PROPIO DNS**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** que el dominio deje de saber en qué dirección vive su propio servidor.
>
> **Por qué provocamos esta:** porque es **el fallo silencioso de la fase**, el [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5]], provocado a propósito y en condiciones controladas.
>
> Es el que **no da ningún error hoy** y revienta la Fase 8 dentro de tres semanas. Vas a verlo ahora, con el servidor delante y sabiendo qué has tocado, en vez de dentro de un mes sin idea de por dónde empezar.

> [!question] 🤔 Predice antes de ejecutar
> 1. Tras borrar el registro, ¿seguirá `samba-ad-dc` en `active`?
> 2. ¿Dirá algún comando que algo va mal?
> 3. ¿Lo detectará el verificador?
>
> **La 2 es la importante.** Escríbela antes de mirar.

### **1 · Romper**
Primero **mira y anota** lo que hay ahora:
```bash
host -t A ubuntuserver.boochanlab.local 127.0.0.1
```
Y ahora bórralo:
```bash
sudo samba-tool dns delete 127.0.0.1 boochanlab.local ubuntuserver A 10.10.10.10 -U Administrator
```
*(Te pedirá la contraseña de `Administrator`: `P@ssw0rd`.)*

### **2 · Comprobar**
```bash
systemctl is-active samba-ad-dc
sudo samba-tool domain level show
host -t A ubuntuserver.boochanlab.local 127.0.0.1
sudo ./verificar_fase4.sh
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-active` | **`active`** | El dominio sigue en pie |
| `samba-tool domain level show` | **Responde bien** | El dominio existe y funciona |
| `host` | **No encuentra el nombre** | Pero nadie sabe **dónde** está |
| El verificador | **FALLO en `D3`** | Es lo único que te avisa |

> [!danger] 🤯 Fíjate en lo que acaba de pasar
> Has roto algo importante y **el sistema no ha protestado en ningún momento**. Ni un error, ni un aviso, ni una línea en el registro.
>
> Si no hubieras pasado el verificador, habrías guardado la instantánea tan tranquilo.

### **3 · Consecuencias**
El dominio existe, autentica, tiene sus usuarios… y **ningún cliente puede encontrarlo**. En la Fase 8, el Windows diría *"No se encuentra el dominio"*.

### **4 · Reparar**
```bash
sudo samba-tool dns add 127.0.0.1 boochanlab.local ubuntuserver A 10.10.10.10 -U Administrator
host -t A ubuntuserver.boochanlab.local 127.0.0.1
sudo ./verificar_fase4.sh
```
- **✅ Reparado:** el `host` devuelve `10.10.10.10` y el verificador vuelve a `FASE 4 SUPERADA`.

> [!success] 🎓 La lección
> **El fallo que no da error es el caro.** Es la idea que llevas repitiendo desde la Fase 1 con el `netplan`, y aquí la ves en su versión más grave.
>
> Y la consecuencia práctica: **por eso se verifica antes de guardar.** Un sistema no te avisa de lo que le falta; solo se queja de lo que le pides y no puede hacer. Lo que nadie le pide hoy, nadie lo echa en falta hasta que hace falta.

---

# **AVERÍA 5 · EL REINO DE KERBEROS EN MINÚSCULAS**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** cambiar `BOOCHANLAB.LOCAL` por `boochanlab.local` en `/etc/krb5.conf`.
>
> **Por qué provocamos esta:** porque es un cambio que **parece inofensivo** —son las mismas letras— y rompe la autenticación. Y porque el error que da no menciona las mayúsculas por ningún sitio.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Distinguirá Kerberos las mayúsculas de las minúsculas?
> 2. Si falla, ¿te dirá el error que el problema son las mayúsculas?

### **1 · Romper**
```bash
sudo cp /etc/krb5.conf /etc/krb5.conf.bak
sudo sed -i 's/BOOCHANLAB.LOCAL/boochanlab.local/g' /etc/krb5.conf
grep -i default_realm /etc/krb5.conf
```

### **2 · Comprobar**
```bash
kinit Administrator
sudo ./verificar_fase4.sh
```
*(La contraseña es `P@ssw0rd`.)*

> [!important] ✍️ Copia el mensaje de error TAL CUAL
> Pégalo en tu entrada de apuntes y **subraya la parte que menciona las mayúsculas**.
>
> **Pista: no hay ninguna.** Ese es el ejercicio.

### **3 · Consecuencias**
Nadie puede autenticarse contra el dominio. Y quien lo diagnostique irá a mirar contraseñas, usuarios y red antes de sospechar de unas mayúsculas.

### **4 · Reparar**
```bash
sudo mv /etc/krb5.conf.bak /etc/krb5.conf
grep -i default_realm /etc/krb5.conf
sudo ./verificar_fase4.sh
```
- **✅ Reparado:** el reino vuelve a estar en mayúsculas.

> [!success] 🎓 La lección
> **En Kerberos el reino va en MAYÚSCULAS**, y no es una convención estética: el protocolo los trata como cadenas distintas.
>
> Pero la lección de verdad es otra: **el error casi nunca te dice la causa, te dice la consecuencia.** Diagnosticar es el trabajo de recorrer hacia atrás desde la consecuencia hasta la causa, y por eso hiciste una copia antes de tocar.

---

# **AVERÍA 6 · EL DOMINIO QUE NO SOBREVIVE AL REINICIO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** dejar el dominio funcionando **hoy** y muerto **mañana**.
>
> **Por qué provocamos esta:** porque es la avería que no se ve haciendo comprobaciones normales. Todo está bien… hasta que apagas.

> [!question] 🤔 Predice antes de ejecutar
> 1. Tras el `disable`, ¿seguirá funcionando el dominio **ahora**?
> 2. ¿Lo detectaría una comprobación que solo mirase `is-active`?

### **1 · Romper**
```bash
sudo systemctl disable samba-ad-dc
systemctl is-active samba-ad-dc
systemctl is-enabled samba-ad-dc
```

### **2 · Comprobar**
```bash
sudo ./verificar_fase4.sh
```

| Qué mira | Resultado |
| :--- | :--- |
| `is-active` | **`active`** — el dominio funciona perfectamente |
| `is-enabled` | **`disabled`** — no arrancará la próxima vez |
| El verificador | **FALLO en `B2`** |

**Y ahora compruébalo de verdad:** reinicia la máquina.
```bash
sudo reboot
```
Cuando vuelva, entra y mira:
```bash
systemctl is-active samba-ad-dc
```

### **3 · Consecuencias**
Un dominio que funciona hasta el primer corte de luz. Y el primer corte de luz llega siempre en el peor momento — normalmente el día que le enseñas el trabajo a alguien.

### **4 · Reparar**
```bash
sudo systemctl enable --now samba-ad-dc
systemctl is-enabled samba-ad-dc
sudo ./verificar_fase4.sh
```
- **✅ Reparado:** `enabled`, y el verificador en `FASE 4 SUPERADA`.

> [!success] 🎓 La lección
> **`active` es "ahora". `enabled` es "la próxima vez".** Son dos preguntas distintas y hay que hacer las dos.
>
> Es la misma idea que en la Fase 3 con `wg-quick@wg0`, y la misma que en la Fase 1 con la IP puesta a mano en vez de en `netplan`. **Tres fases distintas enseñando lo mismo: lo que no persiste, no está configurado.**

---

## ✅ Al terminar: comprueba que has dejado todo como estaba

```bash
sudo ./verificar_fase4.sh
```

- **✅ Bien:** `VEREDICTO: FASE 4 SUPERADA`.
- **❌ Mal:** el script te dice **exactamente** qué avería no reparaste bien. Vuelve a ella.

> [!tip] 💡 Si algo se te ha quedado torcido, tienes la instantánea
> Restaura `Fase 4 terminada` y vuelves al punto bueno. **Para eso la tomaste antes de empezar.**
>
> Y si el dominio se quedó en un estado raro que no sabes describir, **no lo repares a mano**: eso es justo lo que dice el [[Fase_4.7_Resolucion_Problemas#E3 · El aprovisionamiento falló a medias y quiero repetirlo|caso E3]].

---

### ✅ Checklist de este apartado

- [ ] **Sesión 1:** averías **1, 2 y 3**, y `FASE 4 SUPERADA` al cerrar.
- [ ] **Sesión 2:** verificador **antes** de empezar, y después las averías **4, 5 y 6**.
- [ ] **Predicción escrita antes** de cada una, en la entrada de apuntes.
- [ ] Anotado **qué proceso ocupa los puertos 139/445** en la avería 2.
- [ ] Copiado **el mensaje de error literal** de la avería 5, y comentado que no menciona las mayúsculas.
- [ ] Reinicio hecho en la avería 6, y comprobado el resultado.
- [ ] Verificador pasado al final: `FASE 4 SUPERADA`.
- [ ] Todo grabado en el vídeo **`B2 · F4 · Laboratorio de averías`**, con un timestamp por avería.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.9_Preguntas]] | [[Fase_4_Aprovisionamiento_del_Dominio]] | [[Fase_4.10.b_Auditoria_y_Cierre]] |
