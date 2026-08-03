	## 🔌 Fase 1.2: La Red del Laboratorio

### Dos tarjetas, dos trabajos distintos

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~45 min
> **Requisitos:** la VM `UbuntuServer` creada en la [[Fase_1.1_La_Maquina_Virtual]] y **apagada**

---

> [!abstract] 📋 Qué se te evalúa en esta sub-fase
> **Resultado de Aprendizaje — `RA.01`** *(35 % del módulo · UD1-UD4)*
> *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.a` | Se ha realizado el estudio de compatibilidad del sistema informático. | Elegir el modo de cada adaptador **según lo que el servidor necesita hacer**, y diseñar el direccionamiento del laboratorio |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | Dejar preparada la red por la que, en la 1.4, tu ordenador y la VM se hablarán |

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta sub-fase** en Obsidian: fichero `v1-fase-1-2-la-red-del-laboratorio.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 1.2 de Boochan V1 — La Red del Laboratorio."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 1.2 — La Red del Laboratorio`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** La Fase 1 va en cuatro sub-fases precisamente para que cada vídeo sea corto: ve al grano, pero no te saltes pasos.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta sub-fase y otras**; te llegará notificación con fecha límite.
>
> > [!danger] ⚠️ Los nombres NO son orientativos
> > El fichero se llama **exactamente** `v1-fase-1-2-la-red-del-laboratorio.md` y el vídeo **exactamente** `V1 · Fase 1.2 — La Red del Laboratorio`. No es una manía: con cuatro sub-fases por alumno y un grupo entero, si cada uno pone el nombre que le apetece, corregir se vuelve imposible y **tu entrega se pierde**. Un nombre distinto es una entrega no localizada.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de la 1.1
> Tienes una máquina virtual creada y apagada, con su disco y su memoria. Todavía no tiene sistema operativo — y tampoco tiene forma de comunicarse con nada.

> [!warning] El problema
> Tu servidor necesita hacer **dos cosas incompatibles entre sí**: salir a Internet para descargar paquetes, y hablar con el futuro cliente Windows 11 en una red privada que no toque la Wi-Fi del instituto. Una sola tarjeta no puede hacer las dos bien. Por eso vas a ponerle dos.

> [!success] Objetivo de esta sub-fase
> Dejar la VM con **dos adaptadores de red** configurados: uno NAT para Internet y uno sólo-anfitrión conectado a una red privada `10.10.10.0/24` con el host en `10.10.10.1` y **sin DHCP**.

> [!tip] Hoja de ruta
> 1. Entender los modos de red de VirtualBox
> 2. Crear y configurar la red sólo-anfitrión del laboratorio
> 3. Asignar los dos adaptadores a la VM
> 4. Verificar antes de seguir
>
> **Siguiente:** [[Fase_1.3_Instalar_Ubuntu_Server]] — instalar el sistema.

---

### 📚 Fundamento Teórico

> [!note] 1. Los modos de red de VirtualBox
> Cada tarjeta virtual se puede conectar a un "modo" distinto. Usamos dos, y entender la diferencia es el núcleo de esta sub-fase:
>
> | Modo | Qué hace | Analogía |
> | :--- | :--- | :--- |
> | **NAT** | Da salida a Internet compartiendo la conexión de tu ordenador. La VM puede salir; nadie de fuera puede entrar a ella. | La VM llama por teléfono usando tu línea: puede llamar hacia fuera, pero nadie puede llamarla a ella — solo a tu número. |
> | **Sólo anfitrión** *(host-only)* | Crea una red privada **entre tu ordenador y las VMs**, aislada de Internet y de la red del instituto. | Un cable de red que une tu PC y tus máquinas virtuales dentro de una habitación cerrada con llave. Los de fuera no entran; los de dentro se ven perfectamente. |
> | *(Existe también **Red interna**)* | *Conecta VMs entre sí **sin** que el host participe.* | *Un cable entre dos invitados, desenchufado del anfitrión.* **No la usamos**: en la 1.4 necesitamos que tu ordenador haga ping al servidor. |
>
> **Por qué las dos a la vez:** la NAT le da Internet (para `apt`), y la sólo-anfitrión le da una red privada y estable donde más adelante conectarás también el Windows 11. Así servidor y cliente se ven entre sí sin exponer nada a la Wi-Fi del centro.

> [!important] 2. Por qué NO usamos el `192.168.56.0/24` que trae VirtualBox
> VirtualBox crea de fábrica una red sólo-anfitrión en el rango `192.168.56.0/24`. **Vamos a usar otro a propósito:** `192.168.x.x` es exactamente el rango que tienen los routers domésticos, y tarde o temprano un alumno se lía entre "la red de mi casa" y "la red de mi laboratorio". Con `10.10.10.0/24` esa confusión no puede ocurrir.

> [!warning] 3. Por qué desactivamos el DHCP
> Un servidor **no puede tener una IP que cambie**. Todo lo que construyas encima — el dominio de la Fase 4, el DNS, los recursos compartidos — apunta a una dirección concreta. Si un DHCP se la cambia un lunes por la mañana, se cae todo y no sabes por qué. Por eso la red del laboratorio va sin DHCP y la IP del servidor se pone a mano.

### 📖 Diccionario

> [!quote] Cinco palabras
> - **NAT (Network Address Translation):** técnica que permite a varias máquinas salir a Internet compartiendo una sola dirección pública.
> - **Adaptador sólo-anfitrión:** tarjeta virtual que crea una red privada entre el host y sus VMs, sin salida a Internet.
> - **DHCP:** servicio que reparte direcciones IP automáticamente. Cómodo para clientes, peligroso para servidores.
> - **Máscara de subred:** define qué parte de la IP identifica la red y cuál el equipo. `255.255.255.0` = `/24`.
> - **Segmento:** conjunto de máquinas que se ven directamente entre sí sin pasar por un router.

---

### 🛠️ Procedimiento

> [!danger] 🧭 La regla de oro de esta sub-fase
> **Identifica la red sólo-anfitrión por su DIRECCIÓN IP, nunca por su nombre.**
>
> Los nombres cambian según el sistema operativo del anfitrión y según cuántas redes hayas creado antes:
> - En **Mac y Linux** se llaman `vboxnet0`, `vboxnet1`…
> - En **Windows** se llaman `VirtualBox Host-Only Ethernet Adapter`, y si ya existía una, la siguiente es `#2`, `#3`…
>
> Si tu equipo ya tenía VirtualBox instalado, **es muy probable que acabes con dos redes sólo-anfitrión**. Se parecen tanto que enchufar la VM a la equivocada es facilísimo — y el fallo no se nota hasta la 1.4, cuando el ping no responde y todo *parece* estar bien configurado.
>
> Así que en cada pantalla, mira la **IP**, no el nombre.

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. Léete los cuatro pasos.
> 3. **Comprueba que la VM está APAGADA.** Con la VM encendida o guardada, VirtualBox no deja tocar la red.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso 1: Crear y configurar la red del laboratorio
> Esto se hace en la ventana principal de VirtualBox, **no** en la configuración de la VM.
>
> 1. Menú **`Archivo`** → **`Herramientas`** → **`Administrador de red`**.
> 2. Pestaña **`Redes sólo-anfitrión`**.
> 3. Mira lo que hay:
>    - Si la lista está **vacía**, pulsa **`Crear`** (el icono `+`).
>    - Si ya hay una (probablemente con `192.168.56.1`), **crea otra igualmente** con `+`. No reutilices la existente: puede estar en uso por otras máquinas del equipo.
> 4. Selecciona la red nueva y pulsa **`Propiedades`**.
> 5. Pestaña **`Adaptador`**:
>    - Marca **`Configurar adaptador manualmente`**
>    - **Dirección IPv4:** `10.10.10.1`
>    - **Máscara de red IPv4:** `255.255.255.0`
> 6. Pestaña **`Servidor DHCP`**: **desmarca** `Habilitar servidor`.
> 7. **`Aplicar`**.
> 8. **Apunta el nombre exacto** que muestra esa red. Lo necesitas en el Paso 2 y no vale el de al lado.
>
> > [!warning] ⚠️ La máscara viene mal por defecto
> > VirtualBox crea la red con máscara **`255.255.0.0`** (un `/16`). Nuestro laboratorio es `/24`. **Cámbiala a `255.255.255.0`** en el paso 5, y comprueba después que se ha guardado: es un campo que se resiste y a veces revierte al valor anterior si no pulsas `Aplicar`.

> [!example] Paso 2: Asignar los dos adaptadores a la VM
> Ahora sí, con la VM seleccionada → **`Configuración`** → **`Red`**.
>
> Verás pestañas: `Adaptador 1`, `Adaptador 2`, `Adaptador 3`, `Adaptador 4`. Las tres últimas parecen vacías porque están **deshabilitadas**, no porque no existan.
>
> **Adaptador 1:**
> 1. Marca **`Habilitar adaptador de red`**.
> 2. En **`Conectado a`**, selecciona **`NAT`**.
> 3. El resto, por defecto.
>
> **Adaptador 2:**
> 1. Haz clic en la **pestaña `Adaptador 2`**.
> 2. Marca **`Habilitar adaptador de red`** — hasta que no la marques, todo lo demás está en gris.
> 3. En **`Conectado a`**, selecciona **`Adaptador sólo-anfitrión`**.
> 4. En **`Nombre`**, elige **la red que apuntaste en el Paso 1** (la del `10.10.10.1`).
> 5. Despliega **`Avanzadas`** y comprueba que **`Cable conectado`** está marcado. VirtualBox permite tener el adaptador habilitado con el cable "desenchufado", y entonces todo parece bien pero no pasa tráfico.
> 6. **`Aceptar`**.

> [!example] Paso 3: Verificar desde tu ordenador ANTES de instalar nada
> Este paso no existía en versiones anteriores del manual y se pagó caro. **Hazlo ahora**, que corregir aquí cuesta dos minutos y corregirlo en la 1.3 cuesta una tarde.
>
> **En Windows**, abre `cmd`:
> ```
> ipconfig
> ```
> **En Mac o Linux**, abre `Terminal`:
> ```
> ifconfig | grep 10.10.10
> ```
>
> Busca un adaptador con la dirección **`10.10.10.1`** y **máscara `255.255.255.0`**.
>
> - **Si aparece con esa IP y esa máscara** → la red del laboratorio existe en tu ordenador. Sigue.
> - **Si aparece con máscara `255.255.0.0`** → vuelve al Paso 1.6 y corrígela.
> - **Si no aparece** → la red no se creó. Repite el Paso 1.
> - **Si aparecen VARIAS** con `10.10.10.1` o parecidas → tienes redes duplicadas. Quédate con una y borra el resto en el Administrador de red.
>
> Y ahora hazte ping a ti mismo:
> ```
> ping 10.10.10.1
> ```
> Debe responder. Estás comprobando que **tu propio ordenador** tiene un pie dentro de la red del laboratorio. Si esto no responde, no sigas: nada de lo que viene después funcionará.

> [!question] 🔬 Antes de cerrar la grabación
> Contesta en el vídeo, con tus palabras:
> 1. ¿Por qué tu servidor necesita **dos** tarjetas y no una?
> 2. Si conectaras el Adaptador 2 en modo **Red interna** en lugar de **sólo-anfitrión**, ¿podrías hacerle ping desde tu ordenador? Razónalo.
> 3. Tu red es `10.10.10.0/24`. **Sin usar ninguna herramienta**, di: dirección de red, broadcast, cuántos equipos caben, y cuál es la primera y la última dirección utilizable. *(En la 1.4 lo comprobarás contra una API — no hagas trampa ahora.)*

---

### ✅ Checklist de la 1.2

- [ ] Red sólo-anfitrión creada con IP `10.10.10.1` y máscara `255.255.255.0`.
- [ ] Servidor DHCP **deshabilitado** en esa red.
- [ ] Nombre exacto de la red anotado.
- [ ] Adaptador 1 habilitado en modo **NAT**.
- [ ] Adaptador 2 habilitado en modo **sólo-anfitrión**, apuntando a la red del `10.10.10.1`.
- [ ] `Cable conectado` marcado en Avanzadas del Adaptador 2.
- [ ] `ipconfig` / `ifconfig` en tu ordenador muestra el `10.10.10.1` con máscara `/24`.
- [ ] `ping 10.10.10.1` responde desde tu propio ordenador.

---

### ✅ Entregables

> [!abstract] Qué tienes que tener al acabar
> | Entregable | Dónde | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `.../v1-fase-1-2-la-red-del-laboratorio.md` | El procedimiento + **respuesta a las 3 preguntas** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` | `V1 · Fase 1.2 — La Red del Laboratorio`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes | La entrada subida con `add` → `commit` → `push` |

> [!summary] 🎓 Qué has aprendido
> Que NAT y sólo-anfitrión resuelven problemas distintos, que un servidor no puede depender de DHCP, y una regla que te va a servir toda la vida profesional: **los nombres mienten, las direcciones no.** Cuando dos cosas se llaman parecido, identifícalas por lo que las hace únicas.
>
> **Siguiente:** [[Fase_1.3_Instalar_Ubuntu_Server]] — ahora sí, el sistema operativo.
>
> ¿Algo no ha salido? → [[Fase_1.E_Cuando_Algo_Falla]]
