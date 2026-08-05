## Fase 1 · Apartado 3 — 📹 Obligaciones de grabación

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Antes de arrancar OBS.** Cómo se graba y se entrega. Vale para las siete partes.

---

> [!danger] 🛑 ESTA FASE SON SIETE VÍDEOS, NO UNO
> Cada uno cubre una actividad distinta y **los siete son obligatorios**. Si falta uno, la fase no se corrige.
>
> | # | Vídeo | Qué apartado cubre | Duración |
> | :--- | :--- | :--- | :--- |
> | 1 | `B2 · F1 · La máquina virtual` | **6.a** | ~6-8 min |
> | 2 | `B2 · F1 · La red del laboratorio` | **6.b** | ~8-10 min |
> | 3 | `B2 · F1 · Instalar Ubuntu Server` | **6.c** | ~8-10 min |
> | 4 | `B2 · F1 · Verificación y acceso remoto` | **6.d + 8.a** | ~12-15 min |
> | 5 | `B2 · F1 · Punto de control` | **8.b** | ~3-4 min |
> | 6 | `B2 · F1 · Clonar e intercambiar` | **6.f** | ~10-12 min |
> | 7 | `B2 · F1 · Laboratorio de averías` | **10.a** | ~15-20 min |
>
> **Por qué siete y no uno largo:** porque son cosas distintas. Montar, comprobar, guardar, clonar y romper se corrigen por separado — y si algo te sale mal en uno, no arrastra a los demás.

---

## **1 · REGLAS COMUNES A LOS SIETE**

**1A — Antes de grabar**
- Léete el apartado entero primero. **Grabar leyendo por primera vez no sale bien.**
- Crea la entrada de apuntes **vacía**, con la estructura de la Fase 0.1, en `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`.

**1B — Al empezar cada vídeo: preséntate**
> *"Hola, me llamo [Nombre], 2.º SMR. En este vídeo voy a hacer el punto de control de la Fase 1 del Bloque 2."*

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
- **Pega el enlace en su entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`.

---

## **2 · LO ESPECÍFICO DE CADA VÍDEO**

**2A — Los tres primeros** · `La máquina virtual` · `La red del laboratorio` · `Instalar Ubuntu Server`
- Se graban **enteros**, de principio a fin.
- En el 3, **puedes pausar** mientras se instala Ubuntu. Se ve que lo arrancas y se ve el resultado.
- El 3 **termina tomando la instantánea `Sistema base`**: que se vea creada y en la lista.

**2B — Verificación y acceso remoto** · `B2 · F1 · Verificación y acceso remoto`
- Es el vídeo **más largo y el más importante** de la fase. Lleva dos apartados.
- Las comprobaciones **una a una**. En cada una, di **qué esperas ver antes de ejecutarla**. Después, si coincide.
- **Tiene que verse la parte de tu Windows**: el `ping`, el `ssh` y la ventana del administrador de red de VirtualBox. Sin eso, no está verificada la fase.
- Si usas el script, **enséñalo leído antes de ejecutarlo**: un administrador no lanza con `sudo` lo que no ha leído.

**2C — Punto de control** · `B2 · F1 · Punto de control`
- Que se vea la instantánea `Fase 1 terminada` **creada y en la lista**, junto a `Sistema base`.
- Que se vea **el fichero `.ova` en tu disco externo**, en su carpeta, con su tamaño.
- ⏸️ **Puedes pausar** mientras exporta.

**2D — Clonar e intercambiar** · `B2 · F1 · Clonar e intercambiar`
- Se hace **por parejas**. Que se vean **las dos máquinas**, la tuya y la de tu compañero.
- El momento importante es **la colisión**: dos servidores con la misma IP. Que se vea y que lo expliques.

**2E — Laboratorio de averías** · `B2 · F1 · Laboratorio de averías`
- **Tu predicción, en voz alta, ANTES de cada rotura.** Es lo que más se valora de este vídeo.
- Acertar no puntúa. **Haber razonado, sí.** Si te equivocas, dilo y explica por qué creías lo otro.
- **Un timestamp por avería**, las seis.
- Se graba desde **la ventana de VirtualBox**, no por SSH: las averías te cortan el acceso remoto.

---

## **3 · SI ALGO SE ALARGA**

> [!tip] 💡 Un vídeo largo se parte; una fase no se parte
> Si un vídeo se te va de 20 minutos, **pártelo en dos** y llámalos `B2 · F1 · Laboratorio de averías (1 de 2)` y `(2 de 2)`. Pon los dos enlaces en la entrada.
>
> Lo que **no** se hace es juntar dos actividades distintas en un vídeo.

> [!tip] 💡 ¿Y si una parte te ha llevado dos clases?
> **Una parte, una entrada de apuntes.** No crees un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**, para no perder nunca más de un día de trabajo.

---

> [!info] 🏷️ Por qué los vídeos se llaman `B2 · F1 · …`
> `B2` es el **bloque** y `F1` la **fase**. Es el mismo formato que usan el Bloque 1 (`B1.5 · …`) y el Bloque 6 (`B6.1.1 · …`).
>
> **Y resuelve una confusión real:** el proyecto Boochan existe en varias versiones —VirtualBox, Hyper-V, Azure, AWS— y todas tienen una Fase 1. Si el vídeo se llamara solo `Fase 1`, no habría forma de distinguirlas. **Con el bloque delante, sí**: la de Azure es del Bloque 4 y la de AWS del Bloque 5.
>
> Así, mirando el nombre de un vídeo suelto, **se sabe de dónde sale sin abrirlo**. Y ordenándolos alfabéticamente, salen en el orden del curso.

> [!important] 📤 Cómo se entrega
> **Por la TAREA de Teams.** Abriré una tarea que cubre esta fase y alguna más; te llegará notificación con fecha límite.
>
> En la tarea entregas, **en este orden**:
> 1. El enlace a tu **repositorio**
> 2. Los **siete enlaces de vídeo**, numerados
>
> Todo lo demás —apuntes, respuestas, predicciones— ya está dentro del repositorio.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.2_Entregables]] | [[Fase_1]] | [[Fase_1.4_Donde_Estamos]] |
