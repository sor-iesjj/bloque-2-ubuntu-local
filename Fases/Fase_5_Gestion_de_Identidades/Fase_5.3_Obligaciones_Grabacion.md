## Fase 5 · Apartado 3 — 📹 Obligaciones de grabación

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Antes de arrancar OBS.** Cómo se graba y se entrega.

---

> [!danger] 🛑 ESTA FASE SON TRES VÍDEOS, NO UNO
> Cada uno cubre una actividad distinta y **los tres son obligatorios**. Si falta uno, la fase no se corrige.
>
> | # | Vídeo | Qué apartado cubre | Duración |
> | :--- | :--- | :--- | :--- |
> | 1 | `B2 · F5 · Gestión de identidades` | Apartados **6 y 8.a** | ~8-10 min |
> | 2 | `B2 · F5 · Laboratorio de averías` | Apartado **10.a** — las seis averías | ~15-20 min |
> | 3 | `B2 · F5 · Punto de control` | Apartado **8.b** — instantánea y copia al disco | ~3-4 min |
>
> **Por qué tres y no uno largo:** porque son cosas distintas. Montar, romper y guardar se corrigen por separado — y si algo te sale mal en uno, no arrastra a los demás.

---

## **1 · REGLAS COMUNES A LOS TRES**

**1A — Antes de grabar**
- Léete el apartado entero primero. **Grabar leyendo por primera vez no sale bien.**
- **Tu entrada ya debería estar abierta** desde el índice de la fase (`b2-5-gestion-de-identidades.md`). Repasa lo que llevas escrito **antes** de grabar: es lo que te evita improvisar delante del micrófono.

**1B — Al empezar cada vídeo: preséntate**
> *"Hola, me llamo [Nombre], 2.º SMR. En este vídeo voy a crear los usuarios y grupos del dominio, en la Fase 5 del Bloque 2."*

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
- **Pega el enlace en tu entrada de apuntes**, en el apartado `🔗 Enlaces`.

---

## **2 · LO ESPECÍFICO DE CADA VÍDEO**

**2A — Gestión de identidades** · `B2 · F5 · Gestión de identidades`

> [!danger] 🔢 La parte que más puntúa NO es crear los usuarios
> Es **enseñar que llevan los números correctos**. Cuando ejecutes `id hiroshi.nohara`, detente y di en voz alta qué número esperabas ver y cuál ves.
>
> Explica también, con tus palabras, **por qué llevan `--uid-number`** y qué pasaría sin él. Si eso no se oye en el vídeo, se corrige como si no lo supieras.

- Que se vea el `nsswitch.conf` **antes y después** del cambio.
- Los grupos y los usuarios creados, con sus comandos completos a la vista.
- Y sin cortar, **las seis comprobaciones del apartado 8.a**, una a una, diciendo qué esperas ver **antes** de ejecutar cada una.
- **La comprobación 4 —`id hiroshi.nohara`— explícala despacio.** Es la que evita que la Fase 7 falle.

**2B — Laboratorio de averías** · `B2 · F5 · Laboratorio de averías`
- **Tu predicción, en voz alta, ANTES de cada rotura.** Es lo que más se valora de este vídeo.
- Acertar no puntúa. **Haber razonado, sí.** Si te equivocas, dilo y explica por qué creías lo otro.
- **Un timestamp por avería**, las seis.
- En las averías **1 y 2**, compara: el síntoma es el mismo y la causa no. Di en voz alta **qué comando las distingue** y por qué.
- En la **avería 4** —el usuario creado sin número— detente y comenta que **el sistema no ha dado ningún error**. Ese silencio es la lección.

> [!important] 🗓️ Este vídeo se graba en DOS SESIONES
> | Sesión | Averías | |
> | :--- | :--- | :--- |
> | **1.ª** | 1 · 2 · 3 | La **visibilidad** |
> | **2.ª** | 4 · 5 · 6 | Los **fallos silenciosos** |
>
> **Es UN SOLO vídeo, no dos.** Pausa OBS al terminar la avería 3 y reanuda en la siguiente sesión. Los seis timestamps van en la misma descripción.
>
> Y **al empezar la segunda sesión, pasa el verificador antes de romper nada**: si algo quedó sin reparar del día anterior, lo descubres ahora y no lo confundes con la avería nueva.

**2C — Punto de control** · `B2 · F5 · Punto de control`
- Que se vea el **`sudo poweroff`** y la máquina apagándose. **No vale "guardar el estado":** enséñalo apagada.
- Que se vea la instantánea `Fase 5 terminada` **creada y en la lista**, junto a las de las fases anteriores.
- Que se vea **el fichero `.ova` en tu disco externo**, en su carpeta, con su tamaño.
- ⏸️ **Puedes pausar** mientras exporta.

---

## **3 · SI ALGO SE ALARGA**

> [!tip] 💡 Un vídeo largo se parte; una fase no se parte
> Si un vídeo se te va de 20 minutos, **pártelo en dos** y llámalos `B2 · F5 · Laboratorio de averías (1 de 2)` y `(2 de 2)`. Pon los dos enlaces en la entrada.
>
> Lo que **no** se hace es juntar dos actividades distintas en un vídeo.

> [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> **Una fase, una entrada de apuntes.** No crees un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**.

---

> [!info] 🏷️ Por qué los vídeos se llaman `B2 · F5 · …`
> `B2` es el **bloque** y `F5` la **fase**. Es el mismo formato que usan el Bloque 1 (`B1.5 · …`) y el Bloque 6 (`B6.1.1 · …`).
>
> **Y resuelve una confusión real:** el proyecto Boochan existe en varias versiones —VirtualBox, Hyper-V, Azure, AWS— y todas tienen una Fase 5. Con el bloque delante se distinguen.

> [!important] 📤 Cómo se entrega
> **Por la TAREA de Teams.** Abriré una tarea que cubre esta fase y alguna más; te llegará notificación con fecha límite.
>
> En la tarea pegas **solo tres enlaces**:
> 1. Tu **repositorio de apuntes**
> 2. Tu **repositorio de la práctica**
> 3. Tu **playlist** `B2_Ubuntu_Local`
>
> **Los enlaces de vídeo NO se pegan aquí:** cada uno ya está dentro de su entrada de apuntes, con sus respuestas. Si falta una entrada, me falta una entrega — y eso lo veo abriendo tu repositorio.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.2_Entregables]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.4_Donde_Estamos]] |
