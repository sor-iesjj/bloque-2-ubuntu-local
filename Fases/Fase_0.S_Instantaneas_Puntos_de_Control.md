## 💾 Instantáneas: tus puntos de control

### Cómo volver atrás cuando algo sale mal

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **Profesor:** Pedro Navarro Miralles · IES Jorge Juan (ALICANTE)

---

> [!warning] 📖 Cómo se usa este documento
> **Esto no es una fase y no se entrega.** Es una técnica que vas a aplicar **al terminar cada fase**, y una instrucción que verás repetida en el cierre de todas ellas.
>
> Léelo **una vez, antes de empezar la Fase 1**. Después ya solo tendrás que hacer dos clics cuando el manual te lo pida.

---

### 🎯 El problema que resuelve

> [!danger] La situación que te vas a encontrar
> Estás en la Fase 4, provisionando el dominio. Algo sale mal: un comando a medias, un fichero editado con un error, un servicio que no arranca. Intentas arreglarlo y lo empeoras. Al cabo de una hora, tu servidor está en un estado que no entiendes y que no se parece a nada de lo que describe el manual.
>
> ¿Qué haces?
>
> **Sin puntos de control, solo tienes una opción: reinstalar desde cero.** Volver a la Fase 1.1, crear la VM otra vez, instalar Ubuntu otra vez, rehacer las tres fases anteriores. Una tarde entera para volver a donde ya habías estado.
>
> **Con un punto de control al final de cada fase, tienes otra: volver al último estado bueno en treinta segundos** y repetir solo la fase que se torció.

> [!success] Y sirve para algo más: para comprobar
> Un punto de control no es solo un seguro contra catástrofes. Es lo que te permite **probar cosas sin miedo**.
>
> ¿Quieres saber qué pasa si te saltas un paso? ¿Si pones la máscara mal a propósito? ¿Si ejecutas la purga sin parar los servicios antes? Hazlo. Mira qué se rompe. Aprende de ello. Y vuelve al punto de control.
>
> **Un administrador que puede volver atrás experimenta. Uno que no, obedece instrucciones sin entenderlas por miedo a romper algo.** Esa diferencia es todo lo que separa a un técnico de alguien que copia comandos.

---

### 📚 Qué es una instantánea

> [!abstract] La foto del estado completo
> Una **instantánea** (*snapshot*) de VirtualBox guarda el estado **completo** de la máquina virtual en un momento dado: el disco entero, la configuración, y si la tomas encendida, hasta la memoria RAM y los procesos en marcha.
>
> Volver a ella deja la VM **exactamente** como estaba. No "parecido": igual.

> [!warning] Lo que NO es
> - **No es una copia de seguridad.** Vive dentro del mismo fichero de la VM, en el mismo disco. Si se estropea tu portátil, se pierden la VM y todas sus instantáneas a la vez. Una copia de seguridad de verdad vive en **otro sitio**.
> - **No es gratis en espacio.** Cada instantánea guarda las diferencias respecto a la anterior. Muchas instantáneas ocupan mucho, y ralentizan la VM.
> - **No conserva lo que hiciste después.** Si vuelves a la instantánea de la Fase 2, **pierdes todo el trabajo de la Fase 3**. Por eso se toman al **terminar** una fase, no a mitad.

---

### 🛠️ Cómo se hace

> [!example] Tomar una instantánea (al terminar cada fase)
> 1. **Apaga la VM** desde dentro:
>    ```bash
>    sudo poweroff
>    ```
>    *(Se puede hacer con la VM encendida, pero apagada ocupa menos y es más fiable. Y al terminar una fase ya no la necesitas encendida.)*
> 2. En la ventana principal de VirtualBox, **selecciona tu VM** en la lista de la izquierda.
> 3. **Cambia a la vista de Instantáneas.** Por defecto estás en `Detalles`, y **ahí el botón `Tomar` no aparece**. En VirtualBox 7.x se cambia con el **icono de tres rayas (☰)** que hay a la derecha del nombre de la VM en la lista → **`Instantáneas`**.
> 4. Ahora sí, en la barra superior del panel derecho: **`Tomar`**.
> 5. Rellena:
>
> | Campo | Qué pones |
> | :--- | :--- |
> | **Nombre** | `Fase N terminada` — por ejemplo `Fase 2 terminada` |
> | **Descripción** | Una línea con lo que hay hecho. Ej: *"Samba purgado y reinstalado, hosts configurado, hostname -f correcto"* |
>
> 6. **`Aceptar`**. Tarda unos segundos.
>
> > [!tip] 💡 El nombre importa más de lo que parece
> > Dentro de tres semanas vas a tener seis o siete instantáneas. Si se llaman `Instantánea 1`, `Instantánea 2`, `prueba`, `prueba buena`, no sabrás a cuál volver. **`Fase N terminada`, siempre igual.**
>
> > [!warning] ⚠️ ¿No encuentras el botón `Tomar`?
> > Es normal, y hay dos motivos posibles:
> > 1. **Sigues en la vista `Detalles`.** El botón solo existe en la vista `Instantáneas` — vuelve al paso 3.
> > 2. **Tu versión coloca ese menú en otro sitio.** La interfaz de VirtualBox se reorganiza cada pocas versiones y esta parte es de las que más se mueven.
> >
> > **No pierdas el tiempo buscándolo: usa el comando.** Está en la sección de verificación, más abajo, y tiene una ventaja que la interfaz no tiene — **funciona igual en cualquier versión y en cualquier sistema operativo**:
> > ```
> > VBoxManage snapshot "UbuntuServer" take "Fase 1 terminada" --description "..."
> > ```
> > Un administrador acaba trabajando así casi siempre. Los botones cambian de sitio; los comandos, no.

> [!example] Volver a una instantánea (cuando algo se ha roto)
> 1. **Apaga la VM.**
> 2. `Instantáneas` → selecciona **`Fase N terminada`**.
> 3. Pulsa **`Restaurar`**.
> 4. VirtualBox preguntará si quieres **crear una instantánea del estado actual antes de restaurar**. Normalmente **desmárcalo**: si vuelves atrás es porque el estado actual no te sirve, y guardarlo solo ocupa espacio.
> 5. Arranca la VM. Está exactamente como cuando terminaste esa fase.
>
> > [!danger] ⚠️ Restaurar BORRA todo lo posterior
> > Si vuelves a `Fase 2 terminada`, pierdes todo lo que hiciste en las Fases 3 y 4. Es lo que quieres cuando algo se ha roto — pero asegúrate de que es lo que quieres.
> >
> > **Lo que NO se pierde:** tu entrada de apuntes y tus vídeos, porque viven en tu ordenador y en YouTube, no dentro de la VM. Otra razón para escribir la entrada mientras trabajas y no al final.

> [!example] Borrar instantáneas viejas
> Cuando termines el proyecto completo, o si el disco se te queda corto:
>
> `Instantáneas` → seleccionar la que sobre → **`Eliminar`**.
>
> Eliminar una instantánea **no deshace nada**: fusiona sus cambios con la siguiente y libera espacio. Es seguro.
>
> **Recomendación:** conserva siempre las dos últimas. Con eso puedes volver a la fase anterior y a la de antes, que es donde de verdad se necesita volver.

---

### 🔍 Verificar que la instantánea existe de verdad

> [!important] No des por hecho que se ha creado porque no dio error
> Es la misma regla de todo el módulo: **lo que no compruebas, no lo sabes.** Y aquí hay tres formas de comprobarlo, de la más fiable a la más visual.

> [!example] 1️⃣ Por comando — el método que no falla
> Es el único que **no depende de dónde esté el botón** en tu versión de VirtualBox.
>
> **En Windows** (`cmd` o PowerShell):
> ```
> "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" snapshot "UbuntuServer" list --details
> ```
> **En Mac o Linux:**
> ```bash
> VBoxManage snapshot "UbuntuServer" list --details
> ```
>
> - Si hay instantáneas, te devuelve **nombre y UUID** de cada una.
> - Si no hay ninguna: `This machine does not have any snapshots`.
>
> > [!tip] 💡 También puedes tomarlas así
> > ```
> > VBoxManage snapshot "UbuntuServer" take "Fase 1 terminada" --description "Descripción de lo que hay hecho"
> > ```
> > Y restaurarlas:
> > ```
> > VBoxManage snapshot "UbuntuServer" restore "Fase 1 terminada"
> > ```
> > Si no recuerdas el nombre exacto de tu VM: `VBoxManage list vms`.
> >
> > **Esto es lo que hace un administrador de verdad**, porque se puede meter en un script y aplicar a cincuenta máquinas de golpe. La interfaz gráfica está bien para aprender; la línea de comandos es la que se automatiza.

> [!example] 2️⃣ Por ficheros — mirando el disco
> Abre la carpeta de tu máquina virtual:
>
> ```
> C:\Users\<tu_usuario>\VirtualBox VMs\UbuntuServer\
> ```
>
> **Antes** de tu primera instantánea, ahí solo hay el `.vbox` y el `.vdi`. **Después** aparece una subcarpeta nueva:
>
> ```
> UbuntuServer\
> ├── UbuntuServer.vbox          ← configuración de la VM (XML, se puede leer)
> ├── UbuntuServer.vdi           ← el disco duro virtual
> └── Snapshots\                 ← ¡ESTA es la que aparece al tomar la primera!
>     └── {a1b2c3d4-e5f6-7890-abcd-ef1234567890}.vdi
> ```
>
> Si la carpeta `Snapshots\` existe y tiene ficheros dentro, la instantánea se creó.

> [!example] 3️⃣ Por el fichero de configuración — la prueba documental
> `UbuntuServer.vbox` es un fichero **XML**, así que **se puede abrir con el Bloc de notas**. Búscalo dentro y encontrarás:
>
> ```xml
> <Snapshot uuid="{a1b2c3d4-e5f6-7890-abcd-ef1234567890}" name="Fase 1 terminada" ...>
> ```
>
> Ahí está escrito, con todas las letras, el nombre que le pusiste.

---

> [!abstract] 🔢 Ese nombre raro entre llaves: qué es un UUID
> El fichero del disco **no se llama** `Fase 1 terminada.vdi`. Se llama algo así:
>
> ```
> {a1b2c3d4-e5f6-7890-abcd-ef1234567890}.vdi
> ```
>
> Eso es un **UUID** (*Universally Unique IDentifier*): un identificador de **128 bits**, escrito en **hexadecimal**, agrupado en cinco bloques con el patrón **8-4-4-4-12** y encerrado entre llaves.
>
> | Bloque | Dígitos |
> | :--- | :--- |
> | 1.º | 8 |
> | 2.º | 4 |
> | 3.º | 4 |
> | 4.º | 4 |
> | 5.º | 12 |
> | **Total** | **32 dígitos hexadecimales = 128 bits** |
>
> Cada dígito hexadecimal son 4 bits (`0-9` y `a-f`), y 32 × 4 = 128.
>
> **¿Por qué no usa el nombre que tú pusiste?** Porque el nombre es una **etiqueta para humanos**: lo puedes cambiar, puede repetirse, puede llevar acentos y espacios. El UUID es el **identificador interno**: no cambia nunca, es único en el mundo entero, y es el que usa VirtualBox para saber qué disco es cuál.
>
> **Consecuencia práctica:** mirando la carpeta `Snapshots\` **no puedes saber qué instantánea es cada fichero**. Esa correspondencia solo vive en el `.vbox` y en la salida de `VBoxManage snapshot list --details`.

> [!info] 🎯 Nombre legible ≠ identificador interno — y esto ya lo has visto antes
> Es la misma idea, en tres sitios distintos del curso:
>
> | Dónde | Etiqueta para humanos | Identificador interno |
> | :--- | :--- | :--- |
> | **Git** (Fase 0) | el mensaje del commit | el **hash** (`a3f9c21…`) |
> | **VirtualBox** (aquí) | `Fase 1 terminada` | el **UUID** |
> | **Active Directory** (Fase 4) | el usuario `hiroshi.nohara` | el **SID** |
>
> Los sistemas serios **nunca** identifican las cosas por su nombre visible, porque los nombres cambian. Cuando entiendas esto, entenderás por qué en la Fase 5 hay que traducir SIDs a UIDs con winbind.

> [!note] ℹ️ Si ves un fichero `.sav`
> Significa que tomaste la instantánea **con la VM encendida**: es el volcado de la **memoria RAM** en ese instante. Por eso al restaurarla la máquina vuelve encendida y con los programas donde estaban — y por eso ocupa bastante más.
>
> Con la VM **apagada** no hay `.sav`, solo el disco de diferencias. Otra razón para tomarlas apagadas.

---

> [!example] 🔬 EJERCICIO: el disco que deja de crecer
> Cuando tomas una instantánea, **VirtualBox no copia el disco**. Hace algo más listo: congela el `.vdi` original dejándolo en **solo lectura**, y crea en `Snapshots\` un **disco de diferencias** donde van a parar todos los cambios a partir de ese momento.
>
> Compruébalo tú:
>
> 1. Anota lo que ocupa `UbuntuServer.vdi` **antes** de tomar la instantánea.
> 2. Toma la instantánea.
> 3. Arranca la VM, trabaja un rato (instala algo, crea ficheros), apágala.
> 4. Vuelve a mirar **los dos** ficheros: el `.vdi` original y el de `Snapshots\`.
>
> **El `.vdi` original no ha crecido ni un byte.** Todo lo nuevo está en el disco de diferencias.
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Cuánto ocupaba el `.vdi` antes y después? ¿Y el disco de diferencias?
> > 2. Con eso en la mano, **¿por qué restaurar una instantánea es instantáneo** aunque el disco tenga 20 GB?
> > 3. ¿Qué pasaría con el espacio de tu disco si tomaras una instantánea cada día durante un mes?
>
> *(La respuesta a la 2 es bonita: al restaurar no se recupera nada. Simplemente **se tira el disco de diferencias** y el original vuelve a ser el estado actual. Por eso tarda lo mismo con 20 GB que con 200.)*
>
> Esto enlaza con el ejercicio de la **[[Fase_1.6.a_Procedimiento_Maquina_Virtual]]**, donde comparaste lo que ocupa el `.vdi` con los 20 GB que dice tener. Es el mismo fichero contándote otra parte de la historia.

---

### 🔁 El simulacro: repetir es el objetivo

> [!danger] Hacer una fase una vez NO es saber hacerla
> La primera vez que montas el dominio vas leyendo el manual línea a línea, sin saber muy bien por qué haces cada cosa. Terminas, funciona, y tienes la sensación de haberlo aprendido.
>
> **No lo has aprendido. Has sabido seguir instrucciones.** Que está bien, y es el primer paso — pero no es lo mismo.
>
> Sabes montar un servidor cuando puedes hacerlo **sin el manual delante, en la mitad de tiempo, y sabiendo qué va a pasar antes de que pase**. Y a eso solo se llega repitiendo.

> [!success] Para esto sirven de verdad las instantáneas
> Sin puntos de control, repetir el proyecto significa reinstalar Ubuntu: media hora de pantallas antes de llegar a lo que querías practicar. Con ellas, **estás de vuelta en el punto de partida en treinta segundos**.
>
> Eso convierte la repetición en algo viable. Y una habilidad que se puede repetir barato, se acaba dominando.

> [!example] 🏃 Cómo se hace un simulacro
> 1. **Restaura `Sistema base`** — el sistema operativo recién instalado, sin nada más.
> 2. **Pon un cronómetro.**
> 3. **Rehaz las fases 1.4, 2, 3 y 4** de un tirón. El manual puedes tenerlo, pero **intenta no mirarlo** hasta que te atasques.
> 4. Cuando te atasques, **anota en qué paso** ha sido antes de mirar. Eso es exactamente lo que aún no sabes.
> 5. Apunta el tiempo total.
>
> **Marcas de referencia** *(sin contar la instalación del sistema, que no se repite)*:
>
> | Intento | Tiempo esperable | Qué significa |
> | :--- | :--- | :--- |
> | **1.º** (con el manual) | 4-5 horas | Estás aprendiendo. Normal |
> | **2.º** | 1-1,5 horas | Ya sabes a dónde vas, aunque consultes |
> | **3.º** | **30-40 minutos** | **Lo dominas.** Este es el objetivo |
>
> Si en el tercer intento sigues necesitando el manual para el aprovisionamiento del dominio, no es que seas lento: es que ese paso no lo has entendido, solo lo has copiado. Vuelve a la teoría de esa fase.

> [!question] 🎯 Lo que de verdad mide el simulacro
> No es la velocidad. Es esto:
> - **¿Sabes qué comando viene después sin mirarlo?** → conoces la secuencia.
> - **¿Sabes por qué viene después?** → entiendes las dependencias entre servicios.
> - **¿Reconoces un error nada más verlo?** → has visto suficientes.
> - **¿Puedes explicárselo a un compañero mientras lo haces?** → lo dominas.
>
> El último es el bueno. Si puedes ir narrando lo que haces sin pararte a pensar, has llegado.

> [!tip] 💡 Y una cosa más que solo se puede hacer con puntos de control
> **Rompe cosas a propósito.** Restaura `Sistema base` y prueba:
> - Purgar Samba **sin parar los servicios antes**. ¿Qué cambia?
> - Poner la máscara `/16` en vez de `/24`. ¿Qué deja de funcionar?
> - Saltarte el `chattr +i` del `resolv.conf` de la Fase 4 y reiniciar. ¿Qué pasa?
>
> Cada una de esas preguntas tiene una respuesta que **no se te va a olvidar nunca** si la ves con tus ojos, y que si te la cuento yo se te olvida esta semana.
>
> Un administrador que puede volver atrás **experimenta**. Uno que no, obedece instrucciones por miedo a romper algo. Tú ya puedes elegir cuál ser.

---

### 📏 La regla del proyecto

> [!important] Al terminar CADA fase, antes de cerrar la grabación
> | Al acabar | Instantánea | Para qué sirve |
> | :--- | :--- | :--- |
> | **Fase 1.3** (sistema recién instalado) | **`Sistema base`** | **La más importante.** Evita tener que reinstalar Ubuntu nunca más, y es el punto de partida de los simulacros |
> | Fase 1.4 (Fase 1 completa) | `Fase 1 terminada` | Punto de partida limpio para la Fase 2 |
> | Fase 2 | `Fase 2 terminada` | Servidor limpio y con identidad |
> | Fase 3 | `Fase 3 terminada` | Túnel VPN operativo |
> | Fase 4 | `Fase 4 terminada` | Dominio provisionado — **la que más se necesita** |
> | Fase 5 | `Fase 5 terminada` | Usuarios y grupos creados |
> | Fase 6 | `Fase 6 terminada` | Cuotas aplicadas |
> | Fase 7 | `Fase 7 terminada` | Permisos y visibilidad |
> | Fase 8 | `Fase 8 terminada` | Cliente Windows integrado |
>
> **Especialmente antes de la Fase 4.** Es la fase más larga, la que más piezas mueve y la que más se rompe. Llegar a ella sin un `Fase 3 terminada` es jugársela sin motivo.

> [!question] 🎬 Que se te vea en el vídeo
> Toma la instantánea **con la grabación aún en marcha**, como último paso de la fase. Son quince segundos y demuestra que has cerrado la fase como se debe.

---

> [!summary] 🎓 Qué has aprendido
> Que **antes de tocar algo importante, se guarda el estado al que poder volver**. En una VM se llama instantánea; en un servidor físico es una copia de seguridad; en el código es un `commit` — que es exactamente lo que llevas haciendo desde la Fase 0 con Git.
>
> Es la misma idea en tres sitios distintos: **no avances sin poder retroceder.**
