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
> 3. Pulsa el botón **`Instantáneas`** (arriba, junto a `Detalles`). En algunas versiones es un icono con tres líneas o un menú desplegable junto al nombre de la máquina.
> 4. Pulsa **`Tomar`** (el icono de la cámara, o `Máquina → Tomar instantánea`).
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

### 📏 La regla del proyecto

> [!important] Al terminar CADA fase, antes de cerrar la grabación
> | Al acabar | Instantánea |
> | :--- | :--- |
> | Fase 1.4 (Fase 1 completa) | `Fase 1 terminada` |
> | Fase 2 | `Fase 2 terminada` |
> | Fase 3 | `Fase 3 terminada` |
> | Fase 4 | `Fase 4 terminada` |
> | Fase 5 | `Fase 5 terminada` |
> | Fase 6 | `Fase 6 terminada` |
> | Fase 7 | `Fase 7 terminada` |
> | Fase 8 | `Fase 8 terminada` |
>
> **Especialmente antes de la Fase 4.** Es la fase más larga, la que más piezas mueve y la que más se rompe. Llegar a ella sin un `Fase 3 terminada` es jugársela sin motivo.

> [!question] 🎬 Que se te vea en el vídeo
> Toma la instantánea **con la grabación aún en marcha**, como último paso de la fase. Son quince segundos y demuestra que has cerrado la fase como se debe.

---

> [!summary] 🎓 Qué has aprendido
> Que **antes de tocar algo importante, se guarda el estado al que poder volver**. En una VM se llama instantánea; en un servidor físico es una copia de seguridad; en el código es un `commit` — que es exactamente lo que llevas haciendo desde la Fase 0 con Git.
>
> Es la misma idea en tres sitios distintos: **no avances sin poder retroceder.**
