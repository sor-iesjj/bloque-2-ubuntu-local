## Fase 7 · Apartado 3 — 📹 Obligaciones de grabación

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Antes de arrancar OBS.** Cómo se graba y se entrega.

---

> [!danger] 🛑 ESTA FASE SON TRES VÍDEOS, NO UNO
> Cada uno cubre una actividad distinta y **los tres son obligatorios**. Si falta uno, la fase no se corrige.
>
> | # | Vídeo | Qué apartado cubre | Duración |
> | :--- | :--- | :--- | :--- |
> | 1 | `B2 · F7 · Seguridad avanzada` | Apartados **6 y 8.a** | ~10-12 min |
> | 2 | `B2 · F7 · Laboratorio de averías` | Apartado **10.a** — las seis averías | ~15-20 min |
> | 3 | `B2 · F7 · Punto de control` | Apartado **8.b** — instantánea y copia al disco | ~3-4 min |
>
> **Por qué tres y no uno largo:** porque son cosas distintas. Configurar, romper y guardar se corrigen por separado.

---

## **1 · REGLAS COMUNES A LOS TRES**

**1A — Antes de grabar**
- Léete el apartado entero primero. **Grabar leyendo por primera vez no sale bien.**
- **Tu entrada ya debería estar abierta** desde el índice de la fase (`b2-7-seguridad-avanzada.md`). Repasa lo que llevas escrito **antes** de grabar: es lo que te evita improvisar delante del micrófono.

**1B — Al empezar cada vídeo: preséntate**
> *"Hola, me llamo [Nombre], 2.º SMR. En este vídeo voy a configurar la seguridad avanzada de la Fase 7 del Bloque 2."*

Y **muestra algo que demuestre que eres tú**: tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`.

**1C — Mientras grabas**
- **Explica en voz alta lo que haces**, no solo lo hagas. Quiero oír el razonamiento.
- Si algo falla, **no cortes**: enseña el error y cómo lo resuelves. **Eso puntúa más que un vídeo donde todo sale a la primera.**

**1D — Timestamps SIEMPRE**
En la descripción de cada vídeo: `00:00 Presentación` y uno por cada paso o avería.

**Sin timestamps no se corrige.**

**1E — Al terminar**
- Nómbralo **exactamente** como pone la tabla.
- Súbelo a la playlist **`B2_Ubuntu_Local`** (No listado).
- **Pega el enlace en tu entrada de apuntes**, en el apartado `🔗 Enlaces`.

---

## **2 · LO ESPECÍFICO DE CADA VÍDEO**

**2A — Seguridad avanzada** · `B2 · F7 · Seguridad avanzada`

> [!danger] 🔍 La parte que más puntúa es leer bien el `getfacl`
> Cuando lo ejecutes, **detente en la línea del grupo y léela entera, hasta el final**. Di en voz alta si aparece o no un `#effective` y qué significaría que apareciera.
>
> Explica también la diferencia entre la línea `group:` y la línea `default:`: una es el permiso de ahora, la otra es lo que heredará lo que se cree después. Si eso no se oye, se corrige como si no lo supieras.

- 🪂 **El `sudo testparm` tiene que verse ANTES del reinicio.** Explica por qué: `samba-ad-dc` es el controlador de dominio, y reiniciarlo con el fichero roto tumba el DNS y la autenticación, no solo las carpetas.
- Después del reinicio, enseña que el dominio ha vuelto **entero**: el `host` y el `id`.
- Y sin cortar, **las seis comprobaciones del apartado 8.a**, incluida la prueba de herencia con un fichero nuevo.
- **Al final, di en voz alta las cuatro pruebas que quedan pendientes para la Fase 8.** Es parte de la fase reconocer lo que no se ha podido comprobar.

**2B — Laboratorio de averías** · `B2 · F7 · Laboratorio de averías`
- **Tu predicción, en voz alta, ANTES de cada rotura.** Es lo que más se valora de este vídeo.
- **Un timestamp por avería**, las seis.
- En la **avería 2** —la máscara— para el vídeo, señala el `#effective` en pantalla y di *"pone rwx y significa r--"*. Es el momento más importante de la fase.
- En la **avería 4** —quitar el ABE— comenta que **ningún comando del servidor detecta el problema**, y que por eso hace falta la Fase 8.

> [!danger] 🛑 En la avería 5 NO reinicies con el `smb.conf` roto
> El objetivo es enseñar que **`testparm` te avisa antes**. Repáralo primero y **después** reinicia para comprobar que el dominio vuelve.

> [!important] 🗓️ Este vídeo se graba en DOS SESIONES
> | Sesión | Averías | |
> | :--- | :--- | :--- |
> | **1.ª** | 1 · 2 · 3 | Los **permisos** |
> | **2.ª** | 4 · 5 · 6 | La **publicación** |
>
> **Es UN SOLO vídeo, no dos.** Pausa OBS al terminar la avería 3 y reanuda en la siguiente sesión.

**2C — Punto de control** · `B2 · F7 · Punto de control`
- Que se vea el **`sudo testparm` en verde** antes de apagar.
- Que se vea el **`sudo poweroff`** y la máquina apagándose. **No vale "guardar el estado".**
- Que se vea la instantánea `Fase 7 terminada` **creada y en la lista**.
- Que se vea **el fichero `.ova` en tu disco externo**, con su tamaño.
- ⏸️ **Puedes pausar** mientras exporta.

---

## **3 · SI ALGO SE ALARGA**

> [!tip] 💡 Un vídeo largo se parte; una fase no se parte
> Si un vídeo se te va de 20 minutos, **pártelo en dos** y llámalos `(1 de 2)` y `(2 de 2)`. Pon los dos enlaces en la entrada.
>
> Lo que **no** se hace es juntar dos actividades distintas en un vídeo.

> [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> **Una fase, una entrada de apuntes.** No crees un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**.

---

> [!info] 🏷️ Por qué los vídeos se llaman `B2 · F7 · …`
> `B2` es el **bloque** y `F7` la **fase**. Es el mismo formato que usan el Bloque 1 (`B1.5 · …`) y el Bloque 6 (`B6.1.1 · …`).

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
| [[Fase_7.2_Entregables]] | [[Fase_7]] | [[Fase_7.4_Donde_Estamos]] |
