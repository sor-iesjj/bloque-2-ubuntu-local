## Fase 1 · Apartado 6.c — 💿 Procedimiento — Instalar Ubuntu Server

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Con el ordenador delante.** El instalador, decisión a decisión. Es **una entrega**: ~8-10 min

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~1 h |
> | **Entrada de apuntes** | `v1-fase-1-3-instalar-ubuntu-server.md` |
> | **Vídeo** | `V1 · Fase 1.3 — Instalar Ubuntu Server` · ~8-10 min |
>
> Las obligaciones de grabación están en [[Fase_1.3_Obligaciones_Grabacion]]. La teoría que necesitas, en el bloque *"El instalador y el mapa del teclado"* de [[Fase_1.5_Fundamento_Teorico]].

---

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. **Léete las once pantallas enteras** antes de arrancar. En un instalador no puedes "volver atrás" cómodamente.
> 3. Ten OBS listo.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso único: el instalador, pantalla a pantalla
> Enciende la VM (`Iniciar`). Arrancará el instalador desde la ISO.
>
> **1. Idioma.** `English` o `Español`. El instalador en español a veces tiene menos opciones traducidas; `English` es algo más estable, pero cualquiera sirve.
>
> **2. Actualizar el instalador.** Si te lo ofrece, acepta. *(Si se queda mucho rato aquí, es red: ver [[Fase_1.7_Resolucion_Problemas]].)*
>
> **3. Distribución del teclado → `Spanish`.**
>
> > [!danger] ⌨️ Esta es LA pantalla que más caro se paga
> > Si te la saltas o eliges mal, dentro de diez minutos estarás escribiendo una contraseña **a ciegas** con el mapa equivocado. Y no lo descubrirás hasta mucho después, cuando intentes escribir una `@` y salgan comillas.
> > **Compruébalo aquí mismo:** el instalador tiene un campo de prueba. Escribe `@` con `AltGr+2` y mira que sale una arroba. Diez segundos ahora, una hora menos luego.
>
> **4. Tipo de instalación** → `Ubuntu Server`, la normal, **no** la *minimized*.
>
> **5. Configuración de red.** La pantalla más importante de todo el instalador.
>
> > [!danger] 🛑 PARA AQUÍ Y CUENTA LAS TARJETAS
> > Tienes que ver **DOS**: `enp0s3` (la NAT) y `enp0s8` (la sólo-anfitrión). Los nombres exactos pueden variar ligeramente.
> >
> > **Si solo ves UNA, no sigas.** Significa que el Adaptador 2 no llegó a la máquina. Aborta la instalación, apaga la VM y vuelve a la [[Fase_1.6.b_Procedimiento_Red_Laboratorio]] a revisar el Adaptador 2 y su casilla `Cable conectado`.
> >
> > Continuar con una sola tarjeta parece que funciona — la instalación termina, el sistema arranca, todo va bien. Y tres pasos después descubres que tu servidor no tiene la IP `10.10.10.10`, que nadie le hace ping, y que la Fase 4 no puede funcionar. **Dos minutos aquí frente a una tarde después.**
>
> Con las dos delante:
> - **La primera (NAT):** déjala en **automático (DHCP)**. No la toques.
> - **La segunda (sólo-anfitrión):** configúrala **manualmente**:
>   - **Subnet:** `10.10.10.0/24`
>   - **Address:** `10.10.10.10`
>   - **Gateway:** **en blanco** *(esta tarjeta no da salida a Internet; para eso está la NAT)*
>   - **Name servers:** **en blanco** *(el DNS lo pondrá el propio dominio en la Fase 4)*
>
> **6. Proxy y espejo de Ubuntu.** Valores por defecto.
>
> **7. Configuración del disco.** `Use an entire disk`, con el LVM que propone por defecto. Es todo el disco virtual de 20 GB de la 1.1 — no estás tocando el disco real de tu ordenador.
>
> **8. Perfil del usuario.** Cuatro campos en una pantalla:
>
> | Campo | Qué pones | ¿Se puede cambiar? |
> | :--- | :--- | :--- |
> | **Your name** | El que quieras (ej. `Alumno`) | Sí, es decorativo |
> | **Your server's name** (hostname) | `UbuntuServer` | **No.** Las fases siguientes lo usan tal cual |
> | **Pick a username** | `boochan` | **No.** Todos los comandos del manual asumen este usuario |
> | **Choose a password** | `P@ssw0rd` | **No.** Es la contraseña de laboratorio de todo el módulo |
>
> `boochan` será tu **administrador**: el instalador lo mete en el grupo `sudo`. Ubuntu, a diferencia de Windows, **no crea una cuenta `root` con contraseña** — no la busques, no existe.
>
> > [!important] 🔐 Por qué toda la clase usa la misma contraseña — y por qué eso sería inaceptable en una empresa
> > No es pereza. En un laboratorio donde montamos y destruimos servidores todo el curso, que cada uno tenga la suya significa que media clase se queda fuera de su propia VM el segundo día, y las horas se van en resetear contraseñas en vez de administrar sistemas.
> >
> > Dicho eso, quiero que sepas lo que estás haciendo: **`P@ssw0rd` es una de las contraseñas más comprometidas del mundo.** Está en los primeros puestos de cualquier diccionario de ataque. Cumple las reglas de complejidad —mayúscula, minúscula, número, símbolo— y aun así es basura. **Que una contraseña cumpla la política no significa que sea segura.**
> >
> > La regla: vale **porque tu servidor vive dentro de tu portátil, en una red aislada, y no lo ve nadie**. En cuanto un servidor tiene IP pública (lo verás en las versiones cloud) deja de ser aceptable — de hecho Azure directamente la rechaza. Ahí se usan contraseñas largas y únicas, o **claves SSH**, como las que generaste en la Fase 0.2.1.
>
> > [!warning] ⌨️ La escribes a ciegas: dos trampas
> > - **La `@`:** en teclado **español** es `AltGr+2`; en **inglés** es `Shift+2`. Si el teclado quedó en inglés, tu `AltGr+2` **no escribe una arroba** y tu contraseña no es la que crees.
> > - **El `0`** es un **cero**, no una `o`. `P@ssw0rd`, no `P@ssword`.
> >
> > **Truco:** escríbela primero en el campo de *nombre de usuario*, donde **sí** se ven los caracteres. Comprueba con tus ojos que pone `P@ssw0rd`, bórralo, y solo entonces escríbela en los dos campos de contraseña.
>
> **9. OpenSSH Server** → **marca `Install OpenSSH server`**.
>
> > [!important] 🔑 No es opcional, es el objetivo de la fase siguiente
> > Sin esto no podrás entrar al servidor desde tu terminal y tendrás que trabajar siempre dentro de la ventana de VirtualBox: sin copiar y pegar, con la letra minúscula, y con una sola pantalla.
> > Nadie administra un servidor así en la vida real. **Márcala.** Si se te olvida, tiene arreglo — está en [[Fase_1.7_Resolucion_Problemas]] — pero es un rato perdido.
>
> **10. Featured Server Snaps** → no instales ninguno. Lo que haga falta se instalará cuando toque.
>
> **11. Espera y reinicia.** Cuando termine, pulsa **`Reboot Now`**. Si te pide quitar el medio de instalación, pulsa `Enter`: VirtualBox expulsa la ISO solo.
>
> > [!tip] ⏱️ ¿Y si tarda muchísimo?
> > Entre 15 y 30 minutos es normal. **Si pasa de 40**, casi siempre está en `Downloading and installing security updates`, bajando parches por la NAT. Hay un botón **`Cancel update and reboot`** que puedes pulsar sin miedo: el sistema queda instalado y perfectamente usable, y los parches se aplican en la Fase 2, que es donde tocan. Detalle completo en [[Fase_1.7_Resolucion_Problemas]].

> [!example] Primer arranque
> 1. Verás el `login:`. Entra con `boochan` y `P@ssw0rd`.
> 2. Puede que aparezcan mensajes del sistema **encima** del prompt — incluido alguno que dice `error`. Escribe igualmente: los mensajes no interrumpen lo que tecleas.
>
> > [!info] ℹ️ Sobre el mensaje `vmwgfx ... DRM error`
> > Si lo ves, **no es una avería**. Es el driver gráfico de VMware protestando porque corre sobre VirtualBox. En un servidor sin escritorio no afecta a nada. Aprender a distinguir **el error que rompe algo** del **error que solo habla** es media asignatura. Si te molesta, en [[Fase_1.7_Resolucion_Problemas]] está cómo quitarlo.

---

> [!important] 💾 ÚLTIMO PASO: la instantánea más importante de todo el proyecto
> Acabas de instalar el sistema operativo. **Guárdalo ahora**, antes de tocar nada más:
>
> ```bash
> sudo poweroff
> ```
>
> Y toma una instantánea llamada **`Sistema base`**, con la descripción *"Ubuntu Server 26.04 recién instalado: teclado ES, dos tarjetas, 10.10.10.10, usuario boochan, OpenSSH"*.
>
> Por comando, si el botón no aparece:
> ```
> VBoxManage snapshot "UbuntuServer" take "Sistema base" --description "Ubuntu Server 26.04 recien instalado"
> ```
>
> > [!danger] ⚠️ Esta es la que protege lo caro
> > Piensa en lo que cuesta rehacer cada cosa:
> >
> > | Rehacer… | Cuesta |
> > | :--- | :--- |
> > | Instalar Ubuntu desde la ISO | **20-30 minutos**, y hay que estar delante contestando pantallas |
> > | Cualquier fase posterior | minutos, y son comandos que se pegan |
> >
> > **Todo lo que viene después son comandos. Esto no.** Es la única parte del proyecto que no se puede automatizar ni acelerar, y la única que da pereza de verdad repetir.
> >
> > Con `Sistema base` guardada, **nunca más tendrás que reinstalar Ubuntu en este proyecto**, pase lo que pase. Sin ella, cualquier catástrofe seria te devuelve a la casilla de salida.
>
> Cómo se hace y cómo comprobar que se ha creado: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

---

### ✅ Checklist de esta parte

- [ ] Teclado `Spanish`, **comprobado escribiendo una `@`** en el instalador.
- [ ] Las **dos** tarjetas visibles en la pantalla de red.
- [ ] `enp0s3` en DHCP · `enp0s8` manual con `10.10.10.10/24`, sin gateway ni DNS.
- [ ] Disco: `Use an entire disk` con LVM.
- [ ] Hostname `UbuntuServer` · usuario `boochan` · contraseña `P@ssw0rd`.
- [ ] **`Install OpenSSH server` marcado.**
- [ ] Ningún snap instalado.
- [ ] El sistema arranca y puedes iniciar sesión.
- [ ] 💾 **Instantánea `Sistema base` tomada** con la VM apagada, y **grabándolo**.

---

> [!important] 💾 Al terminar esta parte, toma la instantánea **`Sistema base`**
> Es la más importante de todo el proyecto: te evita volver a instalar Ubuntu nunca más. Cómo hacerlo: [[Fase_1.8_Punto_de_Control]]

> ¿Algo no ha salido? → [[Fase_1.7_Resolucion_Problemas]]

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.b_Procedimiento_Red_Laboratorio]] | [[Fase_1]] | [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] |
