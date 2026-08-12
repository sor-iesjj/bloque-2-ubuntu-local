## Fase 10 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.06`** *(pesa un **12 %** del módulo · UD7)*
> *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> Es el **cierre del RA.06**. La Fase 8 integró Windows, la 9 integró Ubuntu, y esta integra **macOS** — el tercer sistema. La lección que cierra la fase: **el modelo de permisos no depende del sistema del cliente.** El mismo `masao.sato`, el mismo servidor, las mismas carpetas — desde el sistema de Apple.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.06.a` | Se ha identificado la necesidad de compartir recursos en red entre diferentes sistemas operativos. | El caso de partida: un Mac (de un empleado, de un turista) necesita los datos del servidor |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | El Mac llega al servidor por la red (ping) y resuelve el dominio |
> | `CE.06.e` | Se ha accedido a sistemas de archivos en red desde equipos con diferentes sistemas operativos. | Acceder desde el Finder a `smb://…` y ver las carpetas compartidas |
> | `CE.06.i` | Se ha comprobado el funcionamiento de los servicios instalados. | Comprobar que `masao.sato` ve lo suyo y no lo ajeno desde el Mac |
>
> **Los que NO se evalúan aquí:** esta fase **no se une al dominio**, así que no toca `CE.02.c` (cuentas de equipo) — eso lo hiciste en las Fases 8 y 9. Y `CE.06.c`/`CE.06.d` (instalar servicios) se demostraron en la Fase 8.

> [!success] ✅ La diferencia con las Fases 8 y 9, en una frase
> Windows y Ubuntu se **unieron** al dominio (crearon cuenta de equipo). El macOS, en cambio, se monta como **VM nueva en VirtualBox** y **accede** a las carpetas sin estar unido — igual que un portátil ajeno a la empresa entra en sus recursos. Las dos formas son integración real, y esta fase demuestra la segunda. **El reto técnico está en que la VM de macOS arranque; conectar es lo de siempre.**

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.2_Entregables]] |
