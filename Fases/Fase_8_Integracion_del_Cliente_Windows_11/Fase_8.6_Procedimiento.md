## Fase 8 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] Paso 1: Configuración de IP y DNS en Windows
> Con Windows 11 ya instalado y arrancado, configura el adaptador de Red Solo Anfitrión con una IP fija dentro del rango del servidor:
>
> 1. Haz clic en el icono de **Red** de la barra de tareas → **"Configuración de red e Internet"**.
> 2. Verás dos adaptadores (uno por cada tarjeta de red virtual). Identifica el que corresponde a la **Red Solo Anfitrión** — normalmente el que no tiene salida a Internet — y haz clic en **"Editar"** junto a "Asignación de IP".
> 3. Cambia "Automático (DHCP)" a **"Manual"**, activa **IPv4** e introduce:
>    - **Dirección IP:** `10.10.10.20`
>    - **Máscara de subred:** `255.255.255.0` (equivalente a `/24`)
>    - **Puerta de enlace:** déjala en blanco (no la necesitas para el adaptador de Red Solo Anfitrión; la salida a Internet la da el otro adaptador, el NAT)
>    - **DNS preferido:** `10.10.10.10`
>    - **DNS alternativo:** déjalo vacío en este adaptador
> 4. Pulsa **"Guardar"**.
>
> > [!tip] 💡 ¿Por qué IP fija y no DHCP?
> > El servidor Samba AD DC de este proyecto no está configurado como servidor DHCP (ver Fases 1-7). Por eso asignamos la IP manualmente. Si en una fase anterior activaste un rango DHCP en el servidor, puedes usarlo, pero asegúrate de que la IP resultante siga en el rango `10.10.10.0/24` y de fijar el DNS a `10.10.10.10`.
>
> > [!tip] 💡 Verifica que el DNS funciona
> > Abre el Símbolo del sistema (`cmd`) y ejecuta:
> > ```cmd
> > nslookup BOOCHANLAB.LOCAL
> > ```
> > Si devuelve la IP `10.10.10.10`, el DNS está funcionando. Si dice "no se encuentra el servidor", revisa que el adaptador de Red Solo Anfitrión esté bien configurado (Paso 0.c) y que el servidor esté encendido.

> [!example] Paso 2: Sincronización de Tiempo
> Ejecuta este comando en el **Símbolo del sistema (CMD) como Administrador**:
>
> *(Para abrirlo como Administrador: pulsa `Windows + X` → "Terminal de Windows (Administrador)" o busca "cmd" en el menú inicio, haz clic derecho → "Ejecutar como administrador")*
>
> > [!info] 📚 Diccionario de Comandos: Recuerda que también tienes explicados los comandos vitales de Windows (`w32tm`, `nslookup`) en el [[Diccionario_Comandos_Sistema]].
>
> ```cmd
> w32tm /resync /force
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`w32tm`:** Es la herramienta de gestión del tiempo de Windows. El parámetro `/resync /force` obliga al PC a emparejar su reloj con el del Controlador de Dominio inmediatamente, ignorando cualquier restricción.
>
> > [!caution] ⚠️ VMs pausadas o congeladas
> > Si dejaste la VM del cliente en pausa (Guardar estado) durante días, su reloj interno se habrá quedado "congelado" en el momento en que la pausaste. Al reanudarla, ejecuta este paso sin falta antes de intentar unirte al dominio.

> [!example] Paso 3: Unión al Dominio
> 1. Abre **Configuración** (tecla `Windows + I`).
> 2. Ve a **Sistema** → **Acerca de**.
> 3. Haz clic en **"Cambiar nombre de este PC (avanzado)"** → pestaña **"Nombre de equipo"** → botón **"Cambiar..."**.
> 4. Selecciona **"Dominio"** e introduce: `BOOCHANLAB.LOCAL`
> 5. Pulsa **Aceptar**. Te pedirá credenciales: introduce **`BOOCHANLAB\Administrator`** y `P@ssw0rd`.
>
>    > [!danger] 🛑 El `BOOCHANLAB\` de delante no es opcional
>    > Este equipo **todavía no es del dominio** — se está uniendo ahora mismo. Si escribes `Administrator` a secas, Windows lo busca **en su propia lista local**, no la del servidor. Y ahí esa cuenta no existe con esa contraseña.
>    >
>    > Resultado: *"nombre de usuario o contraseña incorrectos"* con la contraseña correcta. Es el fallo nº1 de esta fase.
> 6. Si aparece el mensaje **"Bienvenido al dominio BOOCHANLAB"**, el proceso ha sido correcto.
> 7. **Reinicia el equipo** cuando te lo pida. Este paso es obligatorio.
>
> > [!important] 💡 El reinicio es obligatorio
> > Sin reiniciar, Windows no aplica los cambios del dominio. Al volver a encender el PC, en la pantalla de inicio de sesión verás la opción de iniciar sesión con un usuario del dominio.

> [!example] Paso 4: Primer Inicio de Sesión con Usuario del Dominio
> > [!caution] ⚠️ El servidor debe estar encendido y la Red Solo Anfitrión conectada
> > Al iniciar sesión con `BOOCHANLAB\masao.sato`, Windows necesita contactar con el servidor en `10.10.10.10` para validar las credenciales. Comprueba que la VM del servidor está arrancada y que el Adaptador 1 (Red Solo Anfitrión) del cliente sigue conectado (icono de red sin aspa roja) antes de introducir el usuario y la contraseña.
>
> En la pantalla de inicio de sesión de Windows, introduce las credenciales del usuario del dominio. Fíjate en el formato correcto:
>
> - **Usuario:** `BOOCHANLAB\masao.sato`  *(el nombre NetBIOS del dominio, una barra invertida `\`, y el nombre de usuario)*
> - **Contraseña:** `P@ssw0rd`
>
> > [!warning] ⚠️ La barra invertida `\`, no la barra normal `/`
> > La barra invertida se escribe con la tecla que tiene el símbolo `\` en tu teclado (normalmente junto al `Intro` o junto al `0`). Si usas la barra normal `/`, no funcionará.

> [!example] Paso 5: Instalación de RSAT (Herramientas de Administración)
> RSAT permite gestionar usuarios y grupos del dominio directamente desde Windows, con una interfaz gráfica. Requiere el adaptador NAT activo (Paso 0.c) para descargar el paquete desde Internet. Instálalo así:
>
> 1. Ve a **Configuración** → **Aplicaciones** → **Características opcionales**.
> 2. Haz clic en **"Ver características"**.
> 3. Busca `RSAT` en el cuadro de búsqueda.
> 4. Instala **"RSAT: Herramientas de Servicios de dominio de Active Directory y Lightweight Directory Services"**.
> 5. Pulsa **"Instalar"** y espera a que termine.
>
> Una vez instalado, encontrarás las herramientas buscando **"Usuarios y equipos de Active Directory"** en el menú Inicio.

> [!example] Paso 6: Mapeo de la carpeta de tu departamento
> Con el usuario del dominio iniciado, conecta **la carpeta de su departamento** como si fuera un disco local. Con `masao.sato`, que es de comercial:
> ```cmd
> net use Z: \\UbuntuServer.BOOCHANLAB.LOCAL\comercial /persistent:yes
> ```
> Y la carpeta común, que es de todos:
> ```cmd
> net use Y: \\UbuntuServer.BOOCHANLAB.LOCAL\comun /persistent:yes
> ```
>
> > [!warning] ⚠️ Fíjate en que NO lleva `/user:`
> > Ya has iniciado sesión como `masao.sato`: **Windows usa tu identidad actual**, con su ticket de Kerberos. Poner `/user:` te pediría credenciales otra vez y podría acabar autenticando por NTLM.
> >
> > Y **el `/persistent:yes` no es opcional**: sin él, la unidad desaparece al cerrar sesión → [[Fase_8.7_Resolucion_Problemas#E4 · La unidad Z: desaparece al reiniciar|caso E4]].
>
> > [!info] 🎓 Cada trabajador monta lo suyo
> > `hiroshi.nohara` mapearía `facturacion`; `ume.matsuzaka`, `rrhh`. **La letra de unidad es local a cada persona**, y lo que hay detrás depende de quién ha iniciado sesión.
> >
> > Prueba a mapear una carpeta que **no** te corresponde y mira qué pasa:
> > ```cmd
> > net use W: \\UbuntuServer.BOOCHANLAB.LOCAL\rrhh
> > ```
> > Con `masao.sato` tiene que **fallar**. Anota el mensaje.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`Z:`**: Asigna una letra de unidad libre (como un disco duro más).
> > - **`\\UbuntuServer.BOOCHANLAB.LOCAL\comercial`**: Es la ruta UNC (la dirección de la carpeta en la red). Usamos el nombre del servidor en lugar de la IP para que Windows use Kerberos (el sistema de tickets seguro) en lugar de un protocolo más antiguo y menos fiable.
> > - **`/user:BOOCHANLAB\masao.sato`**: Especifica con qué identidad del dominio queremos entrar.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.5_Fundamento_Teorico]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.7_Resolucion_Problemas]] |
