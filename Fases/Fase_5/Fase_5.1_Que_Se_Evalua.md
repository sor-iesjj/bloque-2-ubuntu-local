## Fase 5 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.02`** *(pesa un **13 %** del módulo · UD5-UD6)*
> *Gestiona usuarios y grupos de sistemas operativos en red, interpretando especificaciones y aplicando herramientas del sistema.*
>
> Esta es **la fase central del RA.02**: toca **6 de sus 9 criterios**. Además roza un criterio del `RA.03` *(gestión de dominios, 18 % del módulo)*.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.02.a` | Se han configurado y gestionado cuentas de usuario. | Crear `hiroshi.nohara` y `misae.nohara` con `samba-tool user create` |
> | `CE.02.d` | Se ha distinguido el propósito de los grupos, sus tipos y ámbitos. | Explicar por qué existen `facturacion` y `contabilidad` como grupos y no como usuarios sueltos |
> | `CE.02.e` | Se han configurado y gestionado grupos. | Crear los grupos del dominio con su GID asignado |
> | `CE.02.f` | Se ha gestionado la pertenencia de usuarios a grupos. | Meter cada usuario en su grupo y comprobarlo con `id` |
> | `CE.02.g` | Se han identificado las características de usuarios y grupos predeterminados y especiales. | Reconocer los que Samba crea solo (`Administrator`, `Domain Users`…) y no tocarlos |
> | `CE.02.i` | Se han utilizado herramientas para la administración de usuarios y grupos. | `samba-tool` y `wbinfo` |
> | `CE.03.f` | Se han utilizado agrupaciones de elementos para la creación de modelos administrativos. | Organizar el dominio en contenedores en vez de dejar todo en un montón |
>
> **Los 3 del RA.02 que NO se evalúan aquí:** `CE.02.b` (perfiles de usuario), `CE.02.h` (perfiles móviles) — no se trabajan en este itinerario — y `CE.02.c` (cuentas de equipo), que se demuestra en la **Fase 8** al unir el Windows 11 al dominio.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_5]] | [[Fase_5.2_Entregables]] |
