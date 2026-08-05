## Fase 6 · Apartado 3 — 📹 Obligaciones de grabación

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Antes de arrancar OBS.** Cómo se graba y se entrega.

---

> [!danger] 🛑 ESTA FASE SON TRES VÍDEOS, NO UNO
> Cada uno cubre una actividad distinta y **los tres son obligatorios**. Si falta uno, la fase no se corrige.
>
> | # | Vídeo | Qué apartado cubre | Duración |
> | :--- | :--- | :--- | :--- |
> | 1 | `B2 · F6 · Almacenamiento virtual` | Apartados **6 y 8.a** | ~12-15 min |
> | 2 | `B2 · F6 · Laboratorio de averías` | Apartado **10.a** — las seis averías | ~15-20 min |
> | 3 | `B2 · F6 · Punto de control` | Apartado **8.b** — instantánea, arranque y copia | ~4-5 min |
>
> **Por qué tres y no uno largo:** porque son cosas distintas. Montar, romper y guardar se corrigen por separado — y si algo te sale mal en uno, no arrastra a los demás.

---

## **1 · REGLAS COMUNES A LOS TRES**

**1A — Antes de grabar**
- Léete el apartado entero primero. **Grabar leyendo por primera vez no sale bien.**
- Crea la entrada de apuntes **vacía**: `b2-f6-almacenamiento-virtual.md`, en `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`.

**1B — Al empezar cada vídeo: preséntate**
> *"Hola, me llamo [Nombre], 2.º SMR. En este vídeo voy a montar el almacenamiento con cuotas de la Fase 6 del Bloque 2."*

Y **muestra algo que demuestre que eres tú**: tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`.

**1C — Mientras grabas**
- **Explica en voz alta lo que haces**, no solo lo hagas. Quiero oír el razonamiento.
- Si algo falla, **no cortes**: enseña el error y cómo lo resuelves. **Eso puntúa más que un vídeo donde todo sale a la primera.**

**1D — Timestamps SIEMPRE**
En la descripción de cada vídeo: `00:00 Presentación` y uno por cada paso o avería.

**Sin timestamps no se corrige.** Es lo que me permite entrar directo al punto que quiero comprobar.

**1E — Al terminar**
- Nómbralo **exactamente** como pone la tabla.
- Súbelo a la playlist **`B2_Ubuntu_Local`** (No listado).
- **Pega el enlace en tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`.

---

## **2 · LO ESPECÍFICO DE CADA VÍDEO**

**2A — Almacenamiento virtual** · `B2 · F6 · Almacenamiento virtual`

> [!danger] 🪂 La parte que más puntúa es el `sudo mount -a`
> No es un comando más: es **el ensayo del arranque**. En el vídeo tienes que ejecutarlo y **decir en voz alta qué significa que no devuelva nada**.
>
> Explica también qué pasaría si reiniciaras con el `fstab` mal escrito, y por qué la palabra `loop` es obligatoria. Si eso no se oye, se corrige como si no lo supieras.

- ⏸️ **Puedes pausar** durante los `dd`, que tardan 1-2 minutos cada uno.
- Que se vea el `fstab` **antes y después** del cambio.
- Después del `chown` de `prueba3`, **enseña el `ls -ld`** y di si el grupo es `policia` o `root`. Es el fallo silencioso de la fase.
- Y sin cortar, **las seis comprobaciones del apartado 8.a**, incluida la prueba de la cuota con el `dd` de 6 GB.
- **La prueba de la cuota explícala despacio:** que se vea el `df -h /` con espacio libre mientras la carpeta está al 100 %. Es la fase entera en una pantalla.

**2B — Laboratorio de averías** · `B2 · F6 · Laboratorio de averías`
- **Tu predicción, en voz alta, ANTES de cada rotura.** Es lo que más se valora de este vídeo.
- Acertar no puntúa. **Haber razonado, sí.**
- **Un timestamp por avería**, las seis.
- En la **avería 1**, detente al ver la carpeta vacía y di en voz alta: *"esto no está borrado"*. Y enseña el `.img` de 5 GB.
- En la **avería 4** —la carpeta que pierde su grupo— comenta que **el sistema no ha dado ningún error**. Ese silencio es la lección.

> [!danger] 🛑 En la avería 6 NO reinicies con el `fstab` roto
> El objetivo es justo el contrario: enseñar que **`mount -a` te avisa sin reiniciar**. Repáralo primero, y **después** graba el reinicio de comprobación.

> [!important] 🗓️ Este vídeo se graba en DOS SESIONES
> | Sesión | Averías | |
> | :--- | :--- | :--- |
> | **1.ª** | 1 · 2 · 3 | El **montaje** |
> | **2.ª** | 4 · 5 · 6 | **Permisos y persistencia** |
>
> **Es UN SOLO vídeo, no dos.** Pausa OBS al terminar la avería 3 y reanuda en la siguiente sesión.

**2C — Punto de control** · `B2 · F6 · Punto de control`
- Que se vea el **`sudo poweroff`** y la máquina apagándose. **No vale "guardar el estado".**
- Que se vea la instantánea `Fase 6 terminada` **creada y en la lista**.
- 🔴 **Y que se vea el arranque de comprobación:** enciende la máquina y enseña `df -h` con los dos discos montados **sin haber tocado nada**. Esa es la prueba de que el `fstab` funciona.
- Que se vea **el fichero `.ova` en tu disco externo**, con su tamaño.
- ⏸️ **Puedes pausar** mientras exporta.

---

## **3 · SI ALGO SE ALARGA**

> [!tip] 💡 Un vídeo largo se parte; una fase no se parte
> Si un vídeo se te va de 20 minutos, **pártelo en dos** y llámalos `B2 · F6 · Laboratorio de averías (1 de 2)` y `(2 de 2)`. Pon los dos enlaces en la entrada.
>
> Lo que **no** se hace es juntar dos actividades distintas en un vídeo.

> [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> **Una fase, una entrada de apuntes.** No crees un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**.

---

> [!info] 🏷️ Por qué los vídeos se llaman `B2 · F6 · …`
> `B2` es el **bloque** y `F6` la **fase**. Es el mismo formato que usan el Bloque 1 (`B1.5 · …`) y el Bloque 6 (`B6.1.1 · …`).

> [!important] 📤 Cómo se entrega
> **Por la TAREA de Teams.** Abriré una tarea que cubre esta fase y alguna más; te llegará notificación con fecha límite.
>
> En la tarea entregas, **en este orden**:
> 1. El enlace a tu **repositorio**
> 2. Los **tres enlaces de vídeo**, numerados
>
> Todo lo demás —apuntes, respuestas, predicciones— ya está dentro del repositorio.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.2_Entregables]] | [[Fase_6]] | [[Fase_6.4_Donde_Estamos]] |
