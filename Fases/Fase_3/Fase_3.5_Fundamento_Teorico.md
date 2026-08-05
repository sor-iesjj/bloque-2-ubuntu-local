## Fase 3 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. Seguridad en Profundidad, incluso cuando "no hace falta"
> En una empresa real nunca confías en que una red sea segura solo por estar "dentro de las cuatro paredes". Este principio se llama **Defensa en Profundidad**: cada capa (red aislada, VPN, autenticación, cifrado) protege aunque las demás fallen. Aquí, la Red Solo Anfitrión de VirtualBox ya te da una capa de aislamiento; WireGuard añade una segunda capa de cifrado y autenticación mutua **por si acaso** — y, sobre todo, para que practiques la técnica que usarás en un despliegue real.

> [!info] 2. ¿Qué es WireGuard?
> A diferencia de protocolos antiguos (como OpenVPN), WireGuard funciona al nivel del **Kernel** de Linux. Esto lo hace invisible para los atacantes y extremadamente rápido. Utiliza **criptografía de curva elíptica**, asegurando que los datos viajen por un canal 100% blindado — sea ese canal un cable transatlántico o, como en tu caso, un conmutador virtual dentro de tu propio PC.

> [!important] 3. Intercambio de Llaves
> El servidor y el cliente se reconocen mediante un intercambio de llaves:
> *   **Llave Pública:** Se puede compartir (es como la dirección de tu casa).
> *   **Llave Privada:** Es el secreto absoluto. Solo quien posee la llave privada puede descifrar el tráfico que le llega.

> [!danger] 4. El *handshake*: la ÚNICA prueba de que un túnel funciona
> Un saludo criptográfico entre los dos extremos. Cada pocos minutos, cliente y servidor se demuestran mutuamente que tienen las llaves correctas y acuerdan las claves con las que van a cifrar el rato siguiente.
>
> **Por qué es la única prueba que vale:** WireGuard **descarta en silencio** todo paquete que no venga de alguien a quien reconoce. No contesta, no da error, no registra nada. Es una decisión de diseño: para quien no tenga la llave, tu servidor **no existe**.
>
> **Consecuencia práctica:** puedes tener la interfaz `wg0` levantada, el puerto 51820 abierto y el fichero de configuración impecable… **y que no pase ni un byte.** Todo dirá "activo" y nada funcionará.
>
> Por eso, cuando ejecutes `sudo wg show`, el campo que importa es este:
> ```
> latest handshake: 29 seconds ago
> ```
>
> | Qué ves | Qué significa |
> | :--- | :--- |
> | `latest handshake` con **pocos segundos o minutos** | ✅ Los dos extremos **se reconocen**. El túnel funciona |
> | **No aparece la línea** | ❌ **Nunca se han saludado.** Las llaves no cuadran |
> | Aparece pero **va envejeciendo** (30 s → 2 min → 5 min) | ⚠️ Se saludaron y **han dejado de hablarse** |
>
> **Apréndete esta idea, porque vale para todo el módulo:** *"el servicio está activo"* lo dice el propio servicio de sí mismo. **El handshake lo firman los dos.**

> [!note] 5. Dos redes, dos propósitos: no confundas `10.10.10.0/24` con `10.20.20.0/24`
> En este proyecto conviven dos rangos de IP distintos y no deben mezclarse:
> *   **`10.10.10.0/24`** — la Red Solo Anfitrión "física" de VirtualBox (servidor = `10.10.10.10`). Es el cable de red virtual.
> *   **`10.20.20.0/24`** — la red virtual del **túnel WireGuard** (servidor = `10.20.20.1`, cliente = `10.20.20.2`). Es un cable dentro del cable: una capa de cifrado que viaja encapsulada dentro de la primera.
> Usar rangos claramente distintos es una buena práctica profesional: cuando veas una IP `10.20.20.x` en un log, sabrás al instante que ese tráfico pasó por el túnel cifrado.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología VPN
> - **Cifrado Asimétrico:** Sistema que usa una llave para cerrar (pública) y otra distinta para abrir (privada).
> - **wg0.conf:** El "cerebro" o archivo maestro que define la red virtual y quién puede entrar en ella.
> - **Peer:** Cada uno de los extremos de la conexión (el servidor y la futura VM cliente Windows 11 son "Peers").
> - **Endpoint:** Dónde encontrar al peer para llamarle la primera vez. ⚠️ **Solo existe en la configuración del CLIENTE**, apuntando al servidor (`10.10.10.10:51820`). En el fichero del servidor **no se pone nunca** — ver el aviso del Paso 4.
> - **PersistentKeepalive:** Latido periódico para que un firewall no dé la conexión por muerta. También **solo en el cliente**.
> - **Handshake:** El saludo criptográfico entre los dos extremos. **Es la única prueba de que el túnel funciona de verdad** — ver el punto 4.

---

### 🔓 Firewall Local: por qué aquí no hay "Security Group" que configurar

> [!info] Sin NSG, sin Security Group... sin nada que abrir
> En BoochanV2 (Azure) y BoochanV3 (AWS) esta sección se dedicaba a abrir el puerto 51820/UDP en el firewall del proveedor cloud (NSG o Security Group). **En tu laboratorio local no existe ese firewall perimetral**: la Red Solo Anfitrión de VirtualBox no filtra tráfico entre el host y las VMs que la comparten, así que el paquete UDP de WireGuard llega sin obstáculos de un extremo a otro. No tienes ningún portal que abrir.
>
> > [!tip] 💡 Verificación rápida: ¿tiene Ubuntu su propio firewall activo?
> > Ubuntu Server incluye `ufw` (Uncomplicated Firewall), pero **viene desactivado por defecto** tras una instalación limpia. Compruébalo:
> > ```bash
> > sudo ufw status
> > ```
> > Si responde `Status: inactive`, no hay nada que hacer — el tráfico WireGuard pasará sin problema. Si en algún momento activas `ufw` (buena práctica en un servidor real), recuerda permitir el puerto `51820/udp` y el `2222/tcp` con `sudo ufw allow 51820/udp` y `sudo ufw allow 2222/tcp`. (posible práctica futura)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b2-f3-conectividad-vpn.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.


---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.4_Donde_Estamos]] | [[Fase_3]] | [[Fase_3.6_Procedimiento]] |
