## Fase 10 · Apartado 3 — 🎬 Obligaciones de grabación

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Antes de arrancar OBS.** Cómo se graba y se entrega.

---

> [!important] 🎬 Las 5 obligaciones — idénticas en TODAS las fases del Bloque 2
> 1. **Identifícate al empezar cada vídeo**: muestra tu identidad (Teams o correo `@alu.edu.gva.es`).
> 2. **Pon timestamps** en la descripción: `00:00 Presentación` y **uno por paso**.
> 3. **La entrega va por la TAREA de Teams.** Ahí pegas el enlace de tu **repositorio de apuntes**.
> 4. **Se graba una sola vez** (no se duplica casa/centro).
> 5. **Nombra cada vídeo con su nombre exacto** (`B2 · F10 · Procedimiento` / `Verificación` / `Averías`) y súbelo a `B2_Ubuntu_Local` como **No listado**.

> [!tip] 💡 En el vídeo de **Procedimiento**, explica lo que haces y por qué
> La parte difícil es **crear la VM de macOS**: los ajustes (`firmware efi`, CPU, VRAM) son lo que hace que arranque. Dilo en voz alta — no es un tutorial mudo.

> [!warning] ⚠️ Antes de grabar el Paso 0 (crear la VM): comprueba el requisito del host
> La VM de macOS **no arranca** si el hipervisor de Windows (VBS/NEM) está activo — el muro de la tortuga de la Fase 8. **Comprueba antes de grabar** que tu VirtualBox usa VT-x real (sin la tortuga). Si aparece la tortuga, es que VBS sigue activa: la VM de macOS **no va a instalar**. Para esta fase hace falta host con VT-x real.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.2_Entregables]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.4_Donde_Estamos]] |
