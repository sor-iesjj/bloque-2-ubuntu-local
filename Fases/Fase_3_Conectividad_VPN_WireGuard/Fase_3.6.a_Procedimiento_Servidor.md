## Fase 3 · Apartado 6.a — 🛠️ Procedimiento — El servidor: llaves y túnel

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]] · ↩️ Procedimiento completo: [[Fase_3.6_Procedimiento]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Pasos 1 y 2 — la identidad criptográfica del servidor y su `wg0.conf`

> [!important] 📦 Las tres partes del apartado 6 son UN SOLO vídeo
> `B2 · F3 · Conectividad VPN`, de 8-10 minutos, cubre **6.a + 6.b + 6.c**. No grabes tres.
>
> Están separadas para que puedas seguirlas sin perderte, no porque sean tres entregas.

---
> [!example] Paso 1: Generación de Llaves Criptográficas del Servidor
> Ejecuta estos comandos en el servidor para generar la identidad digital del servidor.
> *El comando `umask 077` es vital: asegura que nadie más pueda leer tu llave.*
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta de `wg` y repasar otros comandos de Linux, consulta el [[Diccionario_Comandos_Sistema]].
>
> > [!danger] ⚠️ Estos comandos NO se pegan de golpe. Uno a uno.
> > `sudo -i` **abre una shell nueva**. Si pegas el bloque entero, las líneas siguientes llegan antes de que esa shell esté lista para leerlas y **se ejecutan donde no toca**: acabas con las llaves creadas en `/root` en vez de en `/etc/wireguard`, sin ningún mensaje de error que te avise.
> >
> > Es un fallo silencioso y desconcertante: los comandos "funcionan", pero el `cat` posterior te dice `No such file or directory` y no entiendes por qué.
> >
> > **Ejecuta cada línea por separado, y comprueba dónde estás antes de generar nada.**
>
> **1.** Conviértete en administrador. Ejecuta **solo esta línea** y espera a ver el nuevo prompt:
> ```bash
> sudo -i
> ```
>
> **2.** Sitúate en el directorio de WireGuard **y comprueba que estás ahí**:
> ```bash
> cd /etc/wireguard
> pwd
> ```
> El `pwd` tiene que devolver exactamente `/etc/wireguard`. **Si devuelve `/root`, no sigas** — el `cd` no ha funcionado y las llaves acabarían en el sitio equivocado.
>
> > [!tip] 💡 El prompt también te lo dice
> > Fíjate en la línea de comandos: `root@UbuntuServer:~#` significa que estás en `/root` (el `~` es tu carpeta personal). Cuando el `cd` funcione verás `root@UbuntuServer:/etc/wireguard#`. **Acostúmbrate a leer el prompt: te está diciendo dónde estás en todo momento.**
>
> **3.** Ahora sí, genera las llaves:
> ```bash
> umask 077
> wg genkey | tee privatekey | wg pubkey > publickey
> ls -l
> ```
> El `ls -l` debe mostrar `privatekey` y `publickey` con permisos **`-rw-------`**: solo el propietario puede leerlas. Si ves otros permisos, el `umask` no se aplicó.
>
> **4.** Ahora **lee y anota** la llave pública del servidor. La necesitarás cuando configures el cliente en el Paso 3:
> ```bash
> # Muestra la llave PÚBLICA del servidor (esta se comparte con el cliente)
> cat /etc/wireguard/publickey
> ```
> **5.** Cuando hayas copiado el valor, vuelve al usuario normal:
> ```bash
> exit
> ```
>
> > [!bug] 🆘 ¿El `cat` te dice `No such file or directory`?
> > Las llaves se crearon en otro directorio, casi seguro en `/root`, porque el bloque se pegó de golpe. Compruébalo:
> > ```bash
> > ls -l /root/privatekey /root/publickey
> > ```
> > Si están ahí, **bórralas** (son llaves privadas sueltas donde no deben estar) y repite desde el punto 1, línea a línea:
> > ```bash
> > rm -f /root/privatekey /root/publickey
> > ```
>
> > [!tip] 💡 ¿Qué hace este comando? (La tubería avanzada)
> > - **El Pipe (`|`):** Imagina que es una tubería. La salida de un comando entra directamente al siguiente.
> > - **El comando `tee`:** Es como una **"T"** en una tubería de agua. Permite que los datos sigan su camino por la tubería pero, al mismo tiempo, guarda una copia en un archivo (`privatekey`).
> > - **`umask 077`:** Es como echar la llave a la habitación antes de escribir un secreto. Asegura que solo tú puedas leer las llaves que vas a generar.

> [!example] Paso 2: Configuración del Túnel en el Servidor (`wg0.conf`)
> Crea el archivo `/etc/wireguard/wg0.conf` con el editor `nano`.
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
>
> **1.** Primero, **saca a pantalla la llave PRIVADA del servidor**, que es la que necesitas ahora. Es el otro fichero que generaste en el Paso 1:
> ```bash
> sudo cat /etc/wireguard/privatekey
> ```
> Cópiala. Es una cadena larga terminada en `=`, parecida a la pública pero **distinta**.
>
> > [!danger] 🔑 No confundas las dos llaves
> > | Fichero | Qué es | Dónde va |
> > | :--- | :--- | :--- |
> > | `privatekey` | El secreto del servidor | **Solo** en el `wg0.conf` del servidor. **No sale de la máquina jamás** |
> > | `publickey` | La identidad pública del servidor | Se le da al **cliente**, en su configuración |
> >
> > Si metes la pública donde va la privada, el túnel no levantará y el error no te dirá que has confundido las llaves. **Compruébalo antes de guardar.**
> >
> > Que la privada aparezca en pantalla mientras grabas es aceptable en un laboratorio aislado. En un servidor real sería un incidente de seguridad — y la primera medida sería regenerar las llaves.
>
> **2.** Ahora crea el fichero:
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
>
> **3.** Escribe **solo esto**, sustituyendo `<TU_PRIVATEKEY>` por lo que acabas de copiar:
> ```ini
> [Interface]
> PrivateKey = <TU_PRIVATEKEY>
> Address = 10.20.20.1/24
> ListenPort = 51820
> ```
>
> Guarda con `Ctrl + O`, `Enter`, `Ctrl + X`.
>
> > [!warning] ⚠️ La sección `[Peer]` todavía NO
> > El túnel tiene dos extremos y aún no existe el segundo: **la llave pública del cliente se genera en el Paso 3.**
> >
> > Podrías escribir el bloque `[Peer]` ahora con un marcador tipo `<LLAVE_DEL_CLIENTE>` y rellenarlo después, pero **no lo hagas**: un `wg0.conf` con un marcador dentro es un fichero **inválido**, y si arrancas WireGuard por error te dará un error de sintaxis críptico que te hará perder el tiempo buscando dónde está el fallo.
> >
> > Mejor un fichero **incompleto pero correcto** que uno completo y roto. Añadirás el `[Peer]` en el Paso 4, cuando tengas la llave de verdad:
> > ```ini
> > [Peer]
> > PublicKey = <la llave pública del cliente>
> > AllowedIPs = 10.20.20.2/32
> > ```
>
> **4.** Comprueba lo que has escrito antes de seguir:
> ```bash
> sudo cat /etc/wireguard/wg0.conf
> ```
> Y verifica que la línea `PrivateKey` coincide **carácter por carácter** con la salida del punto 1. Un solo carácter de más al copiar y pegar, y el túnel no levanta.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.5_Fundamento_Teorico]] | [[Fase_3.6_Procedimiento]] | [[Fase_3.6.b_Procedimiento_Cliente_e_Intercambio]] |
