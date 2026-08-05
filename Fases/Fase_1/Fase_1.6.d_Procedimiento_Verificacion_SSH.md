## Fase 1 · Apartado 6.d — ✅ Procedimiento — Verificación y Acceso Remoto

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Con el ordenador delante.** Comprobar que funciona de verdad y entrar por SSH. Es **una entrega**: ~8-10 min

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~45 min |
> | **Entrada de apuntes** | `b2-f1-4-verificacion-y-acceso-remoto.md` |
> | **Vídeo** | `B2 · F1 · Verificación y acceso remoto` · ~8-10 min |
>
> Las obligaciones de grabación están en [[Fase_1.3_Obligaciones_Grabacion]]. La teoría que necesitas, en el bloque *"Verificar desde fuera, y por qué SSH"* de [[Fase_1.5_Fundamento_Teorico]].

---

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. Ten a mano **dos ventanas**: la VM y una terminal de tu ordenador.
> 3. Ten OBS listo.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso 1: Las tres comprobaciones
>
> **a) Dentro de la VM — ¿están las dos tarjetas?**
> ```bash
> ip a
> ```
> Tienen que salir **tres** interfaces:
> - `lo` — la de bucle local, `127.0.0.1`
> - `enp0s3` — la NAT, con una IP tipo `10.0.2.15` puesta por DHCP
> - `enp0s8` — la sólo-anfitrión, con **`10.10.10.10`**
>
> **Si solo salen dos**, falta la sólo-anfitrión y hay que arreglarlo antes de seguir → [[Fase_1.7_Resolucion_Problemas#E4 · El instalador solo me muestra una tarjeta de red|caso E4]] (la tarjeta no llega a la VM) o [[Fase_1.7_Resolucion_Problemas#E5 · Mi servidor no tiene la IP 10.10.10.10|caso E5]] (llega pero sin IP).
>
> **b) Dentro de la VM — ¿sale a Internet?**
> ```bash
> ping -c4 google.com
> ```
> Cuatro respuestas sin pérdida. Esto prueba la NAT **y** que la resolución de nombres funciona.
>
> **c) Desde tu ordenador — ¿alcanza al servidor?**
> - **Windows:** `Windows + R` → `cmd`
> - **Mac / Linux:** abre `Terminal`
>
> ```
> ping 10.10.10.10
> ```
>
> > [!warning] ⚠️ Esto se hace en el ordenador que ejecuta VirtualBox. En ningún otro.
> > La red sólo-anfitrión **vive dentro del anfitrión**. No sale por el Wi-Fi, no la ve el router, no existe fuera de esa máquina. Si intentas este ping desde otro ordenador de la misma red, **no va a funcionar nunca**, por muy bien que lo tengas todo.
>
> > [!success] ✅ Si las tres responden, la red está bien de verdad
> > Y no porque un panel lo diga: porque lo has probado desde los dos lados.

> [!example] Paso 2: Entrar por SSH — el salto de esta fase
> Desde la terminal de tu ordenador (el `cmd` de Windows sirve):
>
> ```
> ssh boochan@10.10.10.10
> ```
>
> 1. La primera vez avisa de que no conoce la **huella** del servidor y pregunta si confías. Escribe `yes` y `Enter`. *(Es la misma idea que viste con GitHub en la Fase 0.2.1: tu cliente guarda la huella para detectar si algún día alguien suplanta al servidor.)*
> 2. Escribe la contraseña. **No se ve nada mientras escribes** — es normal, no está colgado.
> 3. Si aparece el prompt `boochan@UbuntuServer:~$`, **estás dentro**.
>
> A partir de aquí, **trabaja siempre así**. La ventana de VirtualBox queda para arrancar la máquina y para emergencias.
>
> > [!bug] Si dice `Connection timed out` o `Connection refused`
> > Casi seguro que OpenSSH no está instalado — la casilla del paso 9 de la 1.3. Compruébalo **en la VM**:
> > ```bash
> > systemctl status ssh
> > ```
> > Si responde `Unit ssh.service could not be found`, ve a [[Fase_1.7_Resolucion_Problemas#E7 · SSH dice Connection timed out o Connection refused|caso E7]]: tiene arreglo en dos comandos.

> [!example] Paso 3: El dominio de todo el proyecto
> No hay que ejecutar nada. Es información que debes **anotar en tu entrada**, porque la usarás en la Fase 2 (`/etc/hosts`) y sobre todo en la Fase 4 (creación del dominio):
>
> | Concepto | Valor en BoochanV1 |
> | :--- | :--- |
> | **Nombre NetBIOS** | `BOOCHANLAB` |
> | **Realm (dominio completo)** | `BOOCHANLAB.LOCAL` |
> | **IP del servidor** | `10.10.10.10` |
> | **IP de tu ordenador en esa red** | `10.10.10.1` |
> | **Reservada para el futuro cliente Windows 11** | `10.10.10.20` |
>
> > [!info] ¿Por qué `.LOCAL` y no un dominio real de Internet?
> > En BoochanV2/V3 se usa un dominio real (`BOOCHAN.SPACE`) porque el servidor tiene IP pública. Aquí no: tu servidor vive dentro de tu portátil, en una red invisible desde fuera. Un dominio de Active Directory privado **no necesita ser resoluble en Internet**, y usar terminaciones reservadas como `.LOCAL` es práctica estándar en redes internas de empresa — precisamente para dejar claro que ese nombre nunca debe salir a Internet.

> [!example] 🔌 Paso 4 — EJERCICIO: comprueba tu red desde fuera
> Hasta aquí has comprobado tu red **con tus propias herramientas**. Ahora vas a contrastarla con fuentes **externas e independientes**, que es como se hace de verdad.
>
> **a) Verifica tu cálculo de subred.** Tu red es `10.10.10.0/24`.
> Primero, **a mano y sin ayuda**, escribe en tu entrada: máscara decimal, dirección de red, broadcast, número de hosts asignables, primero y último. *(Si ya lo hiciste en la 1.2, compara con lo que escribiste entonces.)*
>
> Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.10.10.0/24"
> ```
> Si no coincide, **no borres tu respuesta**: déjala y explica en el vídeo dónde te equivocaste. Eso enseña más que acertar.
>
> **b) La IP pública: aquí cae el NAT.** Desde **dentro de la VM**:
> ```bash
> curl "https://api.ipify.org?format=json"
> ```
> Y ahora lo mismo **desde tu ordenador anfitrión**, en otra terminal.
>
> > [!danger] 🤔 Para y explícalo antes de seguir
> > **Sale la MISMA IP en los dos sitios.** Tu VM y tu ordenador comparten la salida a Internet.
> > ¿Por qué? Porque el adaptador **NAT** que configuraste en la 1.2 hace exactamente eso: la VM sale **disfrazada de tu ordenador**. Para Internet, tu servidor no existe como máquina independiente.
> > **Dilo en voz alta:** ¿podría alguien de fuera conectarse a tu servidor con esa IP? ¿Por qué no?
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Coincidió tu cálculo de subred con el de la API? Si no, ¿en qué fallaste?
> > 2. ¿Cuál es la IP privada de tu servidor y cuál la pública? ¿Por qué no son la misma?
> > 3. ¿Por qué una comprobación hecha **desde el propio servidor** vale menos que una hecha desde fuera?
> > 4. ¿Qué ventaja concreta le has notado a trabajar por SSH frente a la ventana de VirtualBox?
>
> > [!note] 📌 Para saber más
> > La teoría completa está en **B1.9b — Verificar tu red con APIs públicas** del Bloque 1. Aquí lo aplicas a tu servidor de verdad.
> > Y explica por qué en las versiones **cloud** (V2 y V3) cambia todo: allí el servidor **sí** tiene IP pública propia y **sí** se puede alcanzar desde fuera. Con eso vienen las ventajas… y los problemas de seguridad.

---

### 🚩 Preguntas críticas

> [!help] Autoevaluación
> 1. ¿Qué diferencia hay entre un hipervisor de Tipo 1 (Azure, AWS) y uno de Tipo 2 (VirtualBox)?
> 2. ¿Por qué la VM necesita dos adaptadores en lugar de uno?
> 3. Si el Adaptador 2 estuviera en modo **Red interna** en vez de sólo-anfitrión, ¿respondería el `ping` desde tu ordenador? Razónalo.
> 4. ¿Por qué el dominio termina en `.LOCAL` y no en `.COM` o `.ES`?
> 5. 🔬 **Reto:** apaga la VM, entra en `Configuración → Sistema → Placa base` y mira cuánta RAM tiene. Súbela a 3072 MB, arranca y ejecuta `free -h`. Compara con lo que había antes. Vuelve a dejarla en 2048 MB hasta que la Fase 4 lo pida de verdad.

---

---

### ✅ Checklist de esta parte

- [ ] `ip a` muestra `lo`, `enp0s3` y `enp0s8` con `10.10.10.10`.
- [ ] `ping google.com` responde desde la VM.
- [ ] `ping 10.10.10.10` responde desde el ordenador anfitrión.
- [ ] Conexión SSH establecida desde la terminal del anfitrión.
- [ ] `BOOCHANLAB` y `BOOCHANLAB.LOCAL` anotados.
- [ ] Ejercicio de las APIs hecho, con el cálculo de subred **escrito antes** de consultarla.
- [ ] Las 5 preguntas críticas respondidas en la entrada.
- [ ] 💾 **Instantánea `Fase 1 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.

---

> [!important] 💾 Al terminar esta parte, toma la instantánea **`Fase 1 terminada`**
> Antes de guardar nada, verifica: [[Fase_1.8.a_Verificacion]]. Después se toma la instantánea en [[Fase_1.8.b_Punto_de_Control]].

> ¿Algo no ha salido? → [[Fase_1.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio (casos `E1` a `E13`), no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]] | [[Fase_1]] | [[Fase_1.7_Resolucion_Problemas]] |

> [!tip] 🌐 ¿Administras desde OTRO ordenador de la red?
> Si el equipo desde el que quieres trabajar **no es** el que ejecuta VirtualBox (el servidor está en el sobremesa y tú vas con el portátil, o el servidor está en un Windows y tú en un Mac), `10.10.10.10` no te va a responder nunca — y no es culpa tuya.
>
> Hay un apartado opcional que lo resuelve y explica por qué: [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]].
>
> **Si trabajas en el mismo PC —el caso del aula—, no lo necesitas.** Sigue al apartado 7.
