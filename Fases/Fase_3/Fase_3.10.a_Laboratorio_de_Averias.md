## Fase 3 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper cosas a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 3 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_3.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script que descargaste en [[Fase_3.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase3.sh
> chmod +x verificar_fase3.sh
> ```

> > [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> > Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
> >
> > **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
> >
> > **La comprobación cuesta dos segundos:**
> > ```bash
> > ls -l verificar_fase3.sh
> > ```
> > **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
> >
> > **Y si sospechas que estás con una versión vieja:**
> > ```bash
> > rm -f verificar_fase3.sh          # bórralo primero: así, si falla el curl, lo ves
> > curl -H 'Cache-Control: no-cache' -O <la URL>
> > ```
> >
> > > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> > >
> > > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**
> Allí está explicado qué es `curl` y por qué se descarga así.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Hasta ahora has comprobado que **todo va bien**. Y eso enseña la mitad.
>
> La otra mitad es saber **qué se ve cuando va mal**. Un técnico no se distingue por montar sistemas — se distingue por **reconocer un síntoma** y saber de dónde viene.
>
> No estás perdiendo el tiempo: estás aprendiendo a leer un sistema roto **en condiciones controladas**, en vez de la primera vez que te pase de verdad y con prisa.

> [!tip] 💡 Las seis averías siguen siempre el mismo guion
> | Paso | Qué se hace |
> | :--- | :--- |
> | **🎯 Objetivo** | Qué vas a aprender y por qué merece la pena |
> | **🤔 Predice** | Escribes qué crees que va a pasar, **antes** de ejecutar |
> | **1. Romper** | El comando que provoca la avería |
> | **2. Comprobar** | Qué comando lo detecta y **cómo se interpreta** |
> | **3. Consecuencias** | Qué daño hace, a corto, medio y largo plazo |
> | **4. Reparar** | El comando que lo arregla y **cómo confirmar** que se arregló |
> | **🎓 La lección** | La idea que te llevas |
>
> **Predecir es lo más importante.** Acertar no puntúa; haber pensado, sí. **Grábalo todo**: este apartado es de lo mejor que puedes enseñar en el vídeo.

---

# **AVERÍA 1 · BAJAR EL TÚNEL**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** detener el servicio de WireGuard **dejando su configuración intacta**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. Desaparece la interfaz `wg0` del sistema
> 2. Al desaparecer, **nadie escucha en el puerto UDP 51820**
> 3. Sin nadie escuchando, el cliente no puede completar el saludo criptográfico
> 4. Sin saludo, **las direcciones `10.20.20.1` y `10.20.20.2` dejan de existir**
> 5. Todo lo que viajara por el túnel queda inalcanzable
>
> **Por qué provocamos esta:** porque el fichero `wg0.conf` **sigue perfecto** mientras nada de eso funciona. Es la avería que separa *"está configurado"* de *"está funcionando"*.

> [!question] 🤔 Predice antes de ejecutar
> Al bajar el túnel:
> 1. ¿Sigue existiendo el fichero `/etc/wireguard/wg0.conf`?
> 2. ¿Sigue existiendo la interfaz `wg0`?
> 3. ¿Sigue ocupado el puerto `51820`?
>
> **Escribe tus tres respuestas antes de seguir.**

### **1 · Romper**
```bash
sudo wg-quick down wg0
```

### **2 · Comprobar**
```bash
sudo wg show
sudo ss -ulnp | grep 51820
ls -l /etc/wireguard/wg0.conf
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `wg show` | **Nada** | No hay ninguna interfaz WireGuard activa |
| `ss -ulnp` | **Nada** | Nadie escucha en el `51820`: el servicio no está corriendo |
| `ls` del fichero | **Sigue ahí, intacto** | La configuración **no se ha perdido** |

**El verificador dirá:** `[FALLO] B1`, `[FALLO] B2` y `[FALLO] B4`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Inmediato** | El cliente pierde la VPN. Si ya hubieras restringido SSH al túnel, **perderías el acceso remoto ahora mismo** |
| **Medio** | Ninguna, porque **se nota enseguida**. Esta avería es de las honestas: falla de forma visible |
| **En producción** | Es lo que ocurre al parar un servicio para mantenimiento y olvidarse de volver a levantarlo |

### **4 · Reparar**
```bash
sudo wg-quick up wg0
```

**Cómo confirmar que se arregló:**
```bash
sudo wg show
```
Debe volver a aparecer la interfaz, y al cabo de unos segundos el `latest handshake`.

> [!warning] ⏱️ Espera medio minuto antes de dar por bueno el arreglo
> Al levantar el túnel, **los contadores se ponen a cero** y el cliente tarda unos segundos en volver a saludar — hasta 25, por el `PersistentKeepalive` que configuraste.
>
> Si verificas de inmediato verás *"nunca hubo handshake"* y creerás que lo has roto del todo. **No es un fallo: es que aún no ha llegado el saludo.**
>
> Y esto también se aprende: **hay comprobaciones que necesitan tiempo antes de ser válidas.** Verificar demasiado pronto da falsos negativos.

> [!summary] 🎓 La lección
> **Configurado no es lo mismo que funcionando.** El `wg0.conf` seguía ahí, intacto y perfecto, mientras el túnel no existía.
>
> Es la misma diferencia que entre tener contratada la luz y tener la luz encendida.

---

# **AVERÍA 2 · QUITAR LA PERSISTENCIA**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** quitarle al servicio el arranque automático, **sin detenerlo**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. **Ahora mismo: nada.** El servicio sigue corriendo y el túnel va perfecto
> 2. Lo que cambia es que `systemd` **ya no lo lanzará en el próximo arranque**
> 3. Al reiniciar: no hay `wg0`, no hay puerto `51820`, no hay túnel
> 4. Y si para entonces SSH solo escucha por la VPN, **no hay forma de entrar al servidor**
>
> **Por qué provocamos esta:** porque es **invisible**. Ninguna prueba de funcionamiento la detecta — solo una comprobación de estado. Es la avería más cara que existe, y llega siempre en el peor momento: después de un corte de luz.

> [!question] 🤔 Predice antes de ejecutar
> Al desactivar el arranque automático del túnel:
> 1. ¿Se cae el túnel ahora mismo?
> 2. ¿Notarías algo si no miraras el estado del servicio?
> 3. ¿Cuándo se manifestaría el problema?

### **1 · Romper**
```bash
sudo systemctl disable wg-quick@wg0
```

### **2 · Comprobar**
```bash
systemctl is-enabled wg-quick@wg0
sudo wg show
ping -c2 10.20.20.2
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `is-enabled` | **`disabled`** | No arrancará solo la próxima vez |
| `wg show` | **Funciona perfectamente** | El servicio **sigue corriendo**: desactivar el arranque no lo para |
| El túnel en general | **Todo normal** | **No hay ningún síntoma** |

**El verificador dirá:** `[FALLO] D1`. **Él lo ve; tú, no.**

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | **Nada.** Cero síntomas. El túnel va perfecto |
| **Al primer reinicio** | El túnel no levanta. Si ya hiciste la Auditoría Final y SSH solo escucha por la VPN, **pierdes el acceso remoto**: solo entras por la ventana de VirtualBox |
| **En una empresa** | Un corte de luz de 30 segundos se convierte en horas de incidencia. Los servicios que "estaban funcionando" no vuelven — y quien lo montó ya no trabaja allí |

### **4 · Reparar**
```bash
sudo systemctl enable wg-quick@wg0
```

**Cómo confirmar que se arregló:**
```bash
systemctl is-enabled wg-quick@wg0
```
Debe devolver **`enabled`**.

> [!tip] 🔬 La comprobación de verdad es reiniciar
> `is-enabled` te dice lo que el sistema **promete** hacer. Si quieres la prueba real:
> ```bash
> sudo reboot
> ```
> Espera un minuto y vuelve a entrar. `sudo wg show` debe responder **sin que tú hayas levantado nada**.

> [!summary] 🎓 La lección
> **Funcionar hoy no garantiza funcionar mañana.** Un servicio arrancado a mano y un servicio habilitado son cosas distintas, y solo la segunda sobrevive a un reinicio.
>
> **Este tipo de avería no se detecta probando: se detecta auditando.**

---

# **AVERÍA 3 · ROMPER LA MÁSCARA DEL CLIENTE**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** cambiar el rango de direcciones que el servidor asocia a ese cliente, de `/32` (una sola) a `/24` (256).
>
> **Qué dejará de funcionar, en cadena:**
> 1. El servidor instala una ruta: *"todo lo que vaya a `10.20.20.0/24`, mándalo a este cliente"*
> 2. **Con un solo cliente: nada falla.** Es el único candidato posible
> 3. En la **Fase 8** añadirás un segundo cliente, y **los dos reclamarán el mismo rango**
> 4. El sistema no puede tener dos rutas idénticas: se queda con **la última**
> 5. El tráfico destinado a un cliente **se envía al otro**, y este lo descarta
> 6. Resultado: uno de los dos deja de responder — **y cuál, cambia según quién saludó el último**
>
> **Por qué provocamos esta:** porque es un error que **no da ningún error**. No aparece en ningún registro, no rompe nada hoy, y estalla dos fases más tarde.

> [!warning] 💾 Antes de tocar, copia de seguridad
> Es lo que hace un administrador antes de editar cualquier fichero de configuración:
> ```bash
> sudo cp /etc/wireguard/wg0.conf /tmp/wg0.conf.bak
> ```

> [!question] 🤔 Predice antes de ejecutar
> Vas a cambiar el `AllowedIPs` del cliente de `/32` a `/24`:
> 1. ¿Se cae el túnel?
> 2. ¿Dará algún error el sistema?
> 3. ¿Cuándo empezaría a notarse?

### **1 · Romper**
```bash
sudo nano /etc/wireguard/wg0.conf
```
Dentro del bloque `[Peer]`, cambia la línea por:
```ini
AllowedIPs = 10.20.20.0/24
```
Guarda y recarga el túnel:
```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

### **2 · Comprobar**
```bash
sudo wg show
ping -c2 10.20.20.2
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `wg show` | **Handshake y tráfico normales** | El túnel funciona igual de bien que antes |
| `ping` | **Responde** | Con **un solo** cliente, el fallo es invisible |
| Cualquier registro del sistema | **Nada** | **No hay ningún error que consultar** |

**El verificador dirá:** `[FALLO] C2`. Es el único que se entera.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy, con un cliente** | **Nada** |
| **En la Fase 8, con el cliente Windows 11** | Los **dos** peers reclaman el mismo rango. WireGuard enruta hacia el último que coincida: el tráfico de un cliente **puede irse al otro**. Uno de los dos deja de responder, y cambia según quién haya saludado el último |
| **En una VPN de empresa** | El clásico *"a veces no me va la VPN"* **sin patrón reproducible**. Nadie lo relaciona con una línea escrita meses atrás |

> ⚠️ **Es la más traicionera de las seis:** el síntoma aparece **dos fases más tarde**, cuando ya nadie recuerda haber tocado ese fichero.

### **4 · Reparar**
```bash
sudo cp /tmp/wg0.conf.bak /etc/wireguard/wg0.conf
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

**Cómo confirmar que se arregló:**
```bash
sudo grep AllowedIPs /etc/wireguard/wg0.conf
```
Debe poner **`10.20.20.2/32`**.

> [!summary] 🎓 La lección
> **Hay errores que no dan error.** Con `/32` cada cliente declara *"soy exactamente esta dirección"*; con `/24` dice *"soy toda la red"*, y el servidor deja de poder decidir a quién enviar cada paquete.
>
> Lo peor no es el fallo: es que **se manifiesta más tarde, en otro sitio y de forma aleatoria**.

---

# **AVERÍA 4 · METER UN `Endpoint` EN EL SERVIDOR**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** fijar a mano en el servidor la dirección del cliente, en lugar de dejar que la aprenda.
>
> **Qué dejará de funcionar, en cadena:**
> 1. El servidor deja de anotar **de dónde llegó** el último saludo del cliente
> 2. Pasa a enviar siempre a la dirección escrita en el fichero
> 3. **Mientras el cliente esté en esa IP: funciona.** El fallo queda oculto
> 4. En cuanto el cliente cambia de red —otro Wi-Fi, otro puerto, una reconexión— el servidor **sigue enviando al sitio viejo**
> 5. El túnel se rompe **y no se recupera solo**: hay que editar el servidor a mano
>
> **Por qué provocamos esta:** porque los dos ficheros se parecen muchísimo y es facilísimo pegar el bloque en el que no es. Aquí ves **qué se pierde exactamente** al hacerlo.

> [!question] 🤔 Predice antes de ejecutar
> El cliente lleva una línea `Endpoint`. Parece razonable que el servidor también la tenga.
> 1. ¿Por qué crees que el servidor **no** la lleva?
> 2. Si le pones `Endpoint = 10.10.10.1`, ¿a quién le estarías diciendo que envíe los paquetes?

### **1 · Romper**
```bash
sudo nano /etc/wireguard/wg0.conf
```
Añade esta línea **dentro del bloque `[Peer]`**:
```ini
Endpoint = 10.10.10.1:51820
```
Guarda y recarga:
```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

### **2 · Comprobar**
```bash
sudo cat /etc/wireguard/wg0.conf
sudo wg show
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `cat` | La línea `Endpoint` en el `[Peer]` | El servidor tiene una dirección fija anotada para el cliente |
| `wg show` | Puede seguir funcionando | El cliente sigue iniciando él la conexión, así que **el fallo se disimula** |

**El verificador dirá:** `[FALLO] C1`.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy** | Poco o nada: el cliente da el primer paso y el servidor le responde |
| **Si el cliente cambia de red** | El servidor sigue enviando a la dirección vieja. **El túnel se rompe y no se recupera solo** |
| **En movilidad real** | Un portátil que va del Wi-Fi de casa al de la oficina cambia de IP. Con `Endpoint` fijo en el servidor, **cada cambio de red exige tocar el servidor a mano** |

### **4 · Reparar**
Borra la línea del fichero y recarga:
```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

**Cómo confirmar que se arregló:**
```bash
sudo grep -c Endpoint /etc/wireguard/wg0.conf
```
Debe devolver **`0`**.

> [!summary] 🎓 La lección
> El servidor **no necesita** `Endpoint` porque **lo aprende solo**: en cuanto recibe un saludo válido, anota de dónde vino y responde ahí. Por eso el cliente puede cambiar de red sin que nadie toque el servidor.
>
> El cliente sí lo necesita, porque **alguien tiene que dar el primer paso** y saber a qué puerta llamar.

---

# **AVERÍA 5 · ABRIR LOS PERMISOS DEL FICHERO**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** relajar los permisos del fichero que contiene **la clave privada del servidor**, de `600` a `644`.
>
> **Qué dejará de funcionar, en cadena:**
> 1. **El túnel: nada.** Sigue funcionando exactamente igual
> 2. El fichero pasa a ser **legible por cualquier usuario** del sistema
> 3. Pero el directorio `/etc/wireguard` sigue cerrado, así que **hoy nadie llega a leerlo**
> 4. En cuanto el fichero **salga de esa carpeta** —una copia de seguridad, un `cp`, un clon de la máquina— la clave queda al alcance de cualquiera
> 5. Quien la tenga puede **hacerse pasar por tu servidor** en la red
>
> **Por qué provocamos esta:** porque un fallo de seguridad **no se parece a una avería**. Nada se rompe, nada avisa. Si esperas a que algo deje de ir, este no lo encuentras jamás.

> [!question] 🤔 Predice antes de ejecutar
> 1. ¿Afecta al funcionamiento del túnel cambiar los permisos del fichero?
> 2. ¿Qué hay dentro de `wg0.conf` que justifique protegerlo?
> 3. Con `644`, ¿crees que **ya** podría leerlo cualquier usuario? *(Ojo con esta: la respuesta obvia no es la correcta.)*

### **1 · Romper**
```bash
sudo chmod 644 /etc/wireguard/wg0.conf
```

### **2 · Comprobar**
```bash
ls -l /etc/wireguard/wg0.conf
sudo wg show
grep PrivateKey /etc/wireguard/wg0.conf
```

**Cómo se interpreta lo que sale:**

| Comando | Qué verás | Qué significa |
| :--- | :--- | :--- |
| `sudo ls -l` | `-rw-r--r--` | El **fichero** ya permite lectura a todo el mundo |
| `wg show` | Funciona perfectamente | **El funcionamiento no cambia en absoluto** |
| `grep PrivateKey` **sin `sudo`** | **`Permiso denegado`** | 🤯 **Sigue protegido. ¿Por qué?** |

> [!danger] 🤯 Sorpresa: has abierto el fichero y NO se puede leer. ¿Por qué?
> Míralo:
> ```bash
> sudo ls -ld /etc/wireguard
> ```
> Sale **`drwx------`**. **El directorio** solo lo puede abrir `root`.
>
> **Para leer un fichero no basta con tener permiso sobre el fichero: hay que poder atravesar todos los directorios del camino.** Si una carpeta del recorrido te cierra la puerta, da igual lo abierto que esté lo que hay dentro.
>
> Esto se llama **defensa en profundidad**: dos barreras independientes protegiendo lo mismo. Has tirado una y la otra ha aguantado.

> [!warning] ⚠️ Entonces, ¿el `644` da igual? NO
> La segunda barrera aguanta **hoy y aquí**. Deja de aguantar en cuanto el fichero **sale de esa carpeta**, que es algo que pasa constantemente:
>
> - Una **copia de seguridad** a otro directorio
> - Un `cp` a `/tmp` para trastear
> - Un **clon de la máquina** entregado a un compañero
>
> **Compruébalo tú mismo:**
> ```bash
> sudo cp /etc/wireguard/wg0.conf /tmp/prueba.conf
> sudo chmod 644 /tmp/prueba.conf
> grep PrivateKey /tmp/prueba.conf
> ```
> **Ahí sí te la muestra, sin `sudo`.** Fuera de su carpeta blindada, el `644` deja la clave privada al alcance de cualquiera.
>
> Limpia después:
> ```bash
> sudo rm /tmp/prueba.conf
> ```

**El verificador dirá:** `[AVISO] C3` — en amarillo, no en rojo, porque no impide funcionar.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Hoy, en tu laboratorio** | **Nada**, y con un solo usuario el riesgo es casi teórico |
| **En un servidor con varios usuarios** | Cualquiera lee la **clave privada del servidor**. Con ella puede **hacerse pasar por tu servidor** desde otra máquina: tus clientes conectarían al impostor creyendo que es el legítimo |
| **Al clonar o entregar la máquina** | 🔴 **Aquí deja de ser teórico.** En el ejercicio [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar]] entregas tu VM a un compañero. Con los permisos abiertos, **le entregas la clave privada dentro** |

> [!info] 🔐 Un matiz que conviene saber
> WireGuard tiene *forward secrecy*: usa claves temporales distintas en cada sesión. Así que **el tráfico ya capturado NO se puede descifrar** aunque roben esa clave.
>
> Lo que sí permite es **suplantar de ahí en adelante**. Es robo de identidad, no de historial. Grave igual, pero conviene saber exactamente qué se pierde.

### **4 · Reparar**
```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

**Cómo confirmar que se arregló:**
```bash
sudo ls -l /etc/wireguard/wg0.conf
```
Debe mostrar **`-rw-------`**: solo `root` lo lee.

> [!summary] 🎓 La lección
> Dos ideas, y la segunda no la esperabas al empezar:
>
> **1. Un fallo de seguridad no se manifiesta como un fallo de funcionamiento.** El túnel iba perfecto con el fichero abierto.
>
> **2. La seguridad se construye por capas, no por una barrera.** Aquí había dos —los permisos del fichero y los del directorio— y al tirar una, la otra aguantó. Eso es **defensa en profundidad**, y es la razón de que un solo fallo rara vez baste para comprometer un sistema bien montado.
>
> Pero **una capa que aguanta hoy no es una capa que aguante siempre**: en cuanto el fichero se copia fuera de su carpeta, la protección que quedaba desaparece.

---

# **AVERÍA 6 · DESCONECTAR EL CLIENTE**

> [!abstract] 🎯 Objetivo de esta avería
> **Qué vamos a provocar:** interrumpir el extremo cliente, **sin tocar nada en el servidor**.
>
> **Qué dejará de funcionar, en cadena:**
> 1. El cliente deja de enviar los saludos periódicos (`PersistentKeepalive`)
> 2. En el servidor, el `latest handshake` **empieza a envejecer**
> 3. El bloque `peer` **sigue estando ahí**, con su clave y su rango: eso viene del fichero, no de la conexión
> 4. El tráfico hacia `10.20.20.2` sale del servidor y **no llega a ninguna parte**
> 5. **El servidor nunca recibe aviso de la desconexión**
>
> **Por qué provocamos esta:** para ver que un servidor **no sabe quién está conectado**. Solo sabe **cuánto hace que no le hablan**, y alguien tuvo que decidir cuánto silencio es demasiado.

> [!question] 🤔 Predice antes de ejecutar
> Al desactivar el túnel en Windows:
> 1. ¿Desaparecerá el peer de la lista del servidor?
> 2. ¿Sabrá el servidor que te has desconectado?
> 3. ¿Qué dato cambiará?

### **1 · Romper**
> Esto se hace **en Windows**, no en el servidor.

En la aplicación de WireGuard, pulsa **`Desactivar`**.

### **2 · Comprobar**
En el servidor, ejecútalo **dos veces separadas por un minuto**:
```bash
sudo wg show
```

**Cómo se interpreta lo que sale:**

| Qué mirar | Qué verás | Qué significa |
| :--- | :--- | :--- |
| El bloque `peer:` | **Sigue ahí**, con su clave y sus `AllowedIPs` | El servidor **no borra** a nadie: esa información viene del fichero |
| `latest handshake` | **Envejece**: 30 s… 90 s… 3 minutos | Es el **único** dato que revela la ausencia |
| `transfer` | Se queda congelado | No entra ni sale nada más |

**El verificador dirá:** primero `[AVISO] B2` cuando pasen 5 minutos. Nunca un `[FALLO]`, porque **no está roto: está ausente**.

### **3 · Consecuencias**

| Plazo | Qué pasa |
| :--- | :--- |
| **Inmediato** | El cliente pierde acceso a la red del túnel. El servidor sigue tan tranquilo |
| **Para el diagnóstico** | Si solo miras *"¿está el peer configurado?"*, dirás que todo va bien. **La configuración no te dice quién está conectado** |
| **En monitorización real** | Por esto los sistemas usan *timeouts*: nadie avisa de que se va, así que hay que **decidir cuánto silencio significa "se ha ido"** |

### **4 · Reparar**
En Windows, pulsa **`Activar`**.

**Cómo confirmar que se arregló:**
```bash
sudo wg show
```
El `latest handshake` debe volver a contar desde pocos segundos. Dale hasta 25 segundos.

> [!summary] 🎓 La lección
> **El servidor no sabe que te has ido: solo mide silencio.**
>
> Es cómo funcionan casi todos los sistemas en red. No hay una despedida — hay un contador que crece, y un umbral decidido por alguien.

---

> [!important] 🎯 La lección que une las averías 2, 3 y 5
> En las tres, **el sistema sigue funcionando perfectamente**. No hay error, no hay registro, no hay síntoma.
>
> Y en las tres, **el verificador las detecta**.
>
> Ese es el motivo de que exista una herramienta de comprobación de estado: **"funciona" no es lo mismo que "está bien"**. Si esperas a que algo deje de ir para revisarlo, estos tres fallos no los encuentras nunca — los encuentras el día que explotan, que siempre es el peor.

> [!success] ✅ Deja el sistema como estaba
> Al terminar las seis, pasa el verificador y comprueba que **todo vuelve a estar en verde**:
> ```bash
> sudo ./verificar_fase3.sh
> ```
>
> Si algo no vuelve a su sitio, **restaura la instantánea `Fase 3 terminada`**. Para eso está.

> [!question] 📝 Lo que va a tu entrada de apuntes
> 1. De las seis averías, **¿cuáles NO se notaban?** ¿Por qué son las más peligrosas?
> 2. Las averías 2 y 5 tienen algo en común. ¿Qué es?
> 3. En la avería 3 el túnel siguió funcionando con la configuración mal. **¿Cómo detectarías un fallo así en un sistema que no has montado tú?**
> 4. ¿Qué avería te ha sorprendido más y por qué?
> 5. Escribe **una avería nueva** que se te ocurra para esta fase, con su objetivo, su comando de rotura y su reparación.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.9_Preguntas]] | [[Fase_3]] | [[Fase_3.10.b_Auditoria_y_Cierre]] |
