## Fase 1 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Al terminar [[Fase_1.6.d_Procedimiento_Verificacion_SSH|6.d]]**, con la grabación aún en marcha. **Antes** de tomar la instantánea `Fase 1 terminada`.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Aquí compruebas. En el [[Fase_1.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!important] 🎬 Esto NO lleva vídeo propio
> Se graba **dentro del vídeo `B2 · F1 · Verificación y acceso remoto`**, seguido del procedimiento 6.d.
>
> **Por qué:** en esta fase verificar *es* el procedimiento. El 6.d ya consiste en comprobar que la máquina existe, arranca y es alcanzable. Partirlo en dos vídeos sería inventarse una frontera que no existe.

---

> [!danger] ⚠️ Esta fase se verifica DESDE DOS SITIOS, y no es opcional
> | Desde dónde | Qué prueba |
> | :--- | :--- |
> | **Dentro del servidor** | Que el sistema está bien configurado |
> | **Desde tu Windows** | Que el servidor es **alcanzable**, que es otra cosa |
>
> Un servidor siempre te dirá lo que **él cree** de sí mismo. Puede tener la IP puesta, la tarjeta levantada y SSH escuchando, y aun así no llegarle nadie — porque el fallo está en VirtualBox, que el servidor no ve.
>
> **Las dos tandas, o la verificación no vale.**

---

# PARTE 1 — DESDE DENTRO DEL SERVIDOR

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · LA RED DEL LABORATORIO EXISTE Y ESTÁ LEVANTADA**

```bash
ip -brief addr show enp0s8
```

- **Qué hace:** muestra en una línea el nombre de la tarjeta, su estado y sus direcciones.
- **✅ Bien:** `enp0s8   UP   10.10.10.10/24`
- **❌ Mal:**
  - No existe la tarjeta → falta el Adaptador 2 en VirtualBox → [[Fase_1.7_Resolucion_Problemas#E4 · El instalador solo me muestra una tarjeta de red|caso E4]]
  - Sale `DOWN` y sin IP → el enlace está caído. **Ojo: la configuración puede estar perfecta.** Una tarjeta caída no enseña su IP aunque la tenga asignada.
  - Sale `UP` pero sin `10.10.10.10` → [[Fase_1.7_Resolucion_Problemas#E5 · Mi servidor no tiene la IP 10.10.10.10|caso E5]]

> [!tip] 💡 `-brief` existe para esto
> `ip addr` sin más escupe veinte líneas por tarjeta. `-brief` da una línea por tarjeta con lo que importa. Cuando busques un dato concreto, úsalo.

### **2 · LA IP SOBREVIVE A UN REINICIO**

```bash
sudo cat /etc/netplan/00-installer-config.yaml
```

- **Qué hace:** enseña el fichero donde vive la configuración de red **de verdad**.
- **Por qué:** una IP puesta a mano con `ip addr add` **funciona hoy y desaparece mañana**. Solo lo que está en `netplan` sobrevive al apagado.
- **✅ Bien:** aparece `enp0s8` con `addresses: - 10.10.10.10/24`.
- **❌ Mal:** no aparece → tienes un apaño, no una configuración.

> [!warning] ⚠️ El fichero se llama `00-installer-config.yaml`
> No `50-cloud-init.yaml`, que es lo que verás en la mitad de los tutoriales de internet. Ese nombre es de versiones anteriores de Ubuntu. Si sigues un tutorial a ciegas, editarás un fichero que no existe y no entenderás por qué no cambia nada.

### **3 · EL FICHERO DE RED NO TIENE ERRORES DE SINTAXIS**

```bash
sudo netplan get
```

- **Qué hace:** pide a `netplan` que lea toda su configuración y te la devuelva ordenada.
- **✅ Bien:** te muestra la configuración en formato YAML, sin mensajes de error.
- **❌ Mal:** aparece `Command failed:` seguido de fichero, línea y columna.

> [!danger] 🛑 Esta comprobación caza el fallo más traicionero de la fase
> `netplan` **valida antes de aplicar**. Si el fichero está mal indentado, `netplan apply` lo **rechaza** y deja la configuración anterior funcionando.
>
> Resultado: **la red va perfectamente y tú crees que has guardado los cambios.** El fallo aparece al reiniciar, días después, cuando ya no te acuerdas de qué tocaste.
>
> **Un fichero que no compila no te avisa mientras la red funciona.** Por eso se mira aquí.

> [!warning] ⚠️ No te fíes de que el comando "no dé error"
> `netplan get` **imprime el error pero termina como si todo hubiera ido bien**. Comprobado en Ubuntu 26.04. Lo que tienes que hacer es **leer la salida**, no mirar si el comando ha fallado.
>
> Es un buen recordatorio general: *un comando que termina bien no significa que haya hecho lo que querías*.

### **4 · HAY SALIDA A INTERNET**

```bash
ping -c3 8.8.8.8
getent hosts archive.ubuntu.com
```

- **Qué hacen:** el primero prueba que **llegas**; el segundo, que **resuelves nombres**.
- **Por qué separados:** son dos fallos distintos. Puedes tener red y no tener DNS, y el síntoma —"no funciona internet"— es el mismo. Separarlos te dice **cuál de los dos**.
- **✅ Bien:** tres respuestas del `ping`, y una línea con la IP de `archive.ubuntu.com`.
- **❌ Mal:**
  - Falla el `ping` → revisa que el **Adaptador 1 esté en NAT**.
  - Va el `ping` pero falla el `getent` → hay red, no hay DNS. **Sin DNS, `apt update` fallará en la Fase 2.**

> [!info] 💡 Por qué `getent hosts` y no `nslookup`
> Porque `nslookup` pregunta **directamente al servidor DNS**, saltándose la configuración del sistema. `getent hosts` pregunta **como lo haría cualquier programa**: mirando primero `/etc/hosts` y después el DNS.
>
> Verificar con `nslookup` puede darte un OK mientras `apt` sigue fallando. Comprueba lo que usa el sistema, no lo que usa la herramienta.

### **5 · LA IDENTIDAD Y EL ACCESO REMOTO**

```bash
hostname
id boochan
systemctl is-active ssh
sudo ss -tlnp | grep ":22 "
```

| Comando | Qué comprueba | ✅ Bien |
| :--- | :--- | :--- |
| `hostname` | El nombre del servidor | `UbuntuServer` |
| `id boochan` | Que el usuario existe y **está en el grupo `sudo`** | Aparece `(sudo)` entre sus grupos |
| `systemctl is-active ssh` | Que el servicio está en marcha | `active` |
| `ss -tlnp` | Que **alguien escucha** en el puerto 22 | Una línea con `0.0.0.0:22` |

- **❌ Mal:** el nombre no es `UbuntuServer` → [[Fase_1.7_Resolucion_Problemas#E12 · Mi servidor no se llama UbuntuServer|caso E12]]. Nadie escucha en el 22 → SSH no está instalado o no arrancó.

> [!info] 🎓 `is-active` y `ss` no dicen lo mismo, y por eso están los dos
> En Ubuntu 26.04, SSH funciona por **activación por socket**: `systemd` es quien escucha en el puerto 22, y solo arranca el programa `sshd` cuando alguien llama de verdad.
>
> **Consecuencia práctica:** el servicio `ssh` puede figurar como parado y **el puerto seguir abierto y aceptando conexiones**. Lo verás con tus propios ojos en el [[Fase_1.10.a_Laboratorio_de_Averias|laboratorio de averías]].
>
> Por eso se comprueban las dos cosas: *el servicio* y *el puerto*.

### **6 · EL TECLADO**

```bash
grep XKBLAYOUT /etc/default/keyboard
```

- **✅ Bien:** `XKBLAYOUT="es"`
- **❌ Mal:** cualquier otra cosa → [[Fase_1.7_Resolucion_Problemas#E2 · No me sale la arroba ni el punto y coma|caso E2]]

> [!warning] ⚠️ Esto no lo puedes comprobar por SSH
> Por SSH el teclado que manda es **el de tu Windows**, no el del servidor. El mapa del servidor solo se nota **en la ventana de VirtualBox**.
>
> **Compruébalo ahí:** abre la consola de la VM y escribe una `@`. Si sale `"`, el mapa está en inglés.
>
> Parece una tontería y no lo es: una contraseña tecleada con el mapa equivocado **se guarda con los caracteres equivocados**, y lo descubres al reiniciar, cuando ya no puedes entrar.

---

# PARTE 2 — DESDE TU WINDOWS

> [!danger] 🛑 Esta parte es la que de verdad demuestra que la Fase 1 está hecha
> Todo lo anterior lo ha dicho el servidor **de sí mismo**. Lo que sigue lo dice **alguien de fuera**, que es el único testigo que vale.

### **7 · LA RED SÓLO-ANFITRIÓN ESTÁ BIEN CONFIGURADA**

En VirtualBox: `Archivo` → **`Herramientas`** → **`Administrador de red`** → pestaña de redes **sólo-anfitrión**.

| Campo | Valor correcto |
| :--- | :--- |
| Dirección IPv4 | `10.10.10.1` |
| Máscara IPv4 | `255.255.255.0` |
| Servidor DHCP | **Desactivado** |

- **❌ Mal:** la máscara es lo que más falla. Con `255.255.0.0` o con la casilla en blanco, el anfitrión y el servidor **creen estar en redes distintas** y no se ven, aunque las direcciones parezcan correctas.

> [!warning] ⚠️ El DHCP activado te romperá la Fase 4
> Si el DHCP de VirtualBox está encendido, reparte direcciones por su cuenta. Puede acabar dando otra IP al servidor, o chocando con la que le pusiste tú.
>
> Un controlador de dominio **necesita una dirección que no cambie nunca**. Déjalo desactivado.

### **8 · EL ANFITRIÓN LLEGA AL SERVIDOR**

Abre `PowerShell` o `cmd` en tu Windows:

```
ping 10.10.10.10
```

- **✅ Bien:** cuatro respuestas.
- **❌ Mal:** `Tiempo de espera agotado` → repasa el punto 7 y el estado de `enp0s8`.

### **9 · ENTRAS POR SSH**

```
ssh boochan@10.10.10.10
```

- **✅ Bien:** te pide la contraseña y entras. La primera vez te preguntará si aceptas la huella del servidor: escribe `yes` **entero**.
- **❌ Mal:** `Connection refused` → hay red pero nadie escucha en el 22. `Connection timed out` → ni siquiera hay red: vuelve al punto 8.

> [!info] 🎓 `refused` y `timed out` no son el mismo fallo
> - **`refused`** → **llegaste**, y alguien te dijo que no. El servicio no está escuchando.
> - **`timed out`** → **no llegaste**. Nadie contestó nada. Es un problema de red.
>
> Distinguir estos dos mensajes te ahorra horas: te dice **en qué mitad del camino** está el problema.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los puntos de arriba tú, comando a comando, entendiendo qué dice cada uno. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.
>
> El script sirve **después**, para confirmar que no se te ha escapado nada.

> [!danger] ⚠️ Y este script ve MENOS que tú
> Corre **dentro** de Ubuntu, así que **no puede ver nada de la Parte 2**: ni la red sólo-anfitrión, ni las instantáneas, ni si tu Windows llega al servidor. El propio script te lo recuerda al terminar.
>
> **La Parte 2 se hace a mano siempre.** No hay atajo.

> [!example] Cómo se descarga y se ejecuta
> **1. Descárgalo directamente en el servidor:**
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase1.sh
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
>
> **2. Dale permiso de ejecución:**
> ```bash
> chmod +x verificar_fase1.sh
> ```
>
> **3. Léelo antes de ejecutarlo:**
> ```bash
> less verificar_fase1.sh
> ```
> *(Se sale con la tecla `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído.**
>
> **4. Ejecútalo:**
> ```bash
> sudo ./verificar_fase1.sh
> ```
>
> **5. Sube el informe** `verificacion-fase-1.txt` a tu repositorio, junto con la entrada de apuntes.

> [!info] 🌐 Qué es `curl` y por qué esa dirección tan rara
> **`curl` es un navegador sin ventana.** Descarga una dirección de internet desde la línea de comandos. Viene instalado en Ubuntu Server.
>
> Cuando ves un fichero en GitHub, lo ves **envuelto** en su página web. `raw.githubusercontent.com` devuelve **el fichero desnudo**. Se construye con dos cambios:
>
> | | Dirección |
> | :--- | :--- |
> | **Página web** | `github.com/sor-iesjj/…/**blob**/main/99_Recursos/verificar_fase1.sh` |
> | **Fichero crudo** | `**raw.githubusercontent.com**/sor-iesjj/…/main/99_Recursos/verificar_fase1.sh` |
>
> 1. `github.com` → `raw.githubusercontent.com`
> 2. Desaparece el `/blob/`
>
> **Funciona sin usuario ni contraseña porque el repositorio del curso es público.**
>
> **¿Y por qué no clonar el repositorio aquí?** Porque traería cientos de ficheros para usar **uno solo**. Además lo clonaste en tu **Windows**, para leer los apuntes en Obsidian: en el servidor no está.
>
> **La `-O` mayúscula** significa *"guárdalo con el mismo nombre que tiene en el servidor"*.

> [!question] 🤔 Para tu entrada de apuntes
> Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**. Y otra pregunta: **¿por qué el script no puede comprobar la Parte 2?**

---

---

### ✅ Checklist de este apartado

**Dentro del servidor**
- [ ] `ip -brief addr show enp0s8` → `UP` con `10.10.10.10/24`.
- [ ] La IP aparece en `/etc/netplan/00-installer-config.yaml`.
- [ ] `sudo netplan get` **sin** `Command failed:`.
- [ ] `ping 8.8.8.8` y `getent hosts archive.ubuntu.com` responden.
- [ ] `hostname` = `UbuntuServer` · `boochan` en el grupo `sudo` · algo escuchando en el 22.
- [ ] `XKBLAYOUT="es"`, y la `@` comprobada **en la ventana de VirtualBox**.

**Desde tu Windows**
- [ ] Red sólo-anfitrión: `10.10.10.1` / `255.255.255.0` / **DHCP desactivado**.
- [ ] `ping 10.10.10.10` responde.
- [ ] `ssh boochan@10.10.10.10` entra.

**Y además**
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.
- [ ] Todo grabado dentro del vídeo **`B2 · F1 · Verificación y acceso remoto`**.

> [!success] ✅ Con todo en verde, pasa al [[Fase_1.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.7_Resolucion_Problemas]] | [[Fase_1]] | [[Fase_1.8.b_Punto_de_Control]] |
