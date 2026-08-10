## Fase 3 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> Montar un túnel cifrado toca **tres** resultados de aprendizaje, porque es a la vez conectividad, seguridad de acceso e integración entre máquinas distintas:
>
> **`RA.01`** *(35 % del módulo · UD1-UD4)* — *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
> **`RA.04`** *(12 % del módulo · UD7)* — *Gestiona los recursos compartidos del sistema, interpretando especificaciones y determinando niveles de seguridad.*
> **`RA.06`** *(12 % del módulo · UD7)* — *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | El `ping` a través del túnel `10.20.20.0/24`, que es una conectividad distinta de la del Paso 7 de la Fase 1 |
> | `CE.04.f` | Se han establecido niveles de seguridad para controlar el acceso del cliente a los recursos compartidos. | El túnel **es** un nivel de seguridad: decide quién puede llegar al servidor y quién no |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | El cliente WireGuard corre en tu ordenador (Windows/macOS) y el servidor en Ubuntu: dos sistemas distintos hablando |
> | `CE.06.h` | Se han establecido niveles de seguridad para controlar el acceso del usuario a los recursos compartidos. | Claves pública/privada por cliente: cada peer tiene su identidad criptográfica |
>
> > [!info] 🤔 ¿Por qué una VPN no tiene un resultado de aprendizaje propio?
> > Porque el título de SMR es de **2007** y sus resultados de aprendizaje **no contemplan las VPN** — sencillamente no eran lo que son hoy. Por eso esta fase se evalúa por lo que el título sí contempla: conectividad, control de acceso e integración entre sistemas distintos. Que es, exactamente, lo que una VPN hace.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_3_Conectividad_VPN_WireGuard]] | [[Fase_3.2_Entregables]] |
