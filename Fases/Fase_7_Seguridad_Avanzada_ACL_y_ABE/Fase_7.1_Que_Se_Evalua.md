## Fase 7 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.04`** *(pesa un **12 %** del módulo · UD7)*
> *Gestiona los recursos compartidos del sistema, interpretando especificaciones y determinando niveles de seguridad.*
>
> Esta es **la fase central del RA.04**: toca **4 de sus 7 criterios**, y entre ellos el más conceptual de todo el módulo.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.04.a` | Se ha reconocido la diferencia entre permiso y derecho. | La distinción entre lo que el sistema de archivos **permite** (ACL) y lo que el usuario **puede ver que existe** (ABE). Es la pregunta de examen clásica |
> | `CE.04.b` | Se han identificado los recursos del sistema que se van a compartir y en qué condiciones. | Decidir qué carpeta ve `comercial`, cuál ve `becarios` y cuál no ve nadie |
> | `CE.04.c` | Se han asignado permisos a los recursos del sistema que se van a compartir. | `setfacl` sobre las carpetas compartidas |
> | `CE.04.f` | Se han establecido niveles de seguridad para controlar el acceso del cliente a los recursos compartidos. | Access Based Enumeration en `smb.conf`: que el recurso ni siquiera aparezca a quien no tiene acceso |
>
> **Los 3 que NO se evalúan aquí:** `CE.04.d` (impresoras en red) y `CE.04.g` (trabajo en grupo) no se trabajan en este itinerario; `CE.04.e` (entorno gráfico para compartir recursos) se ve en la **Fase 8**, desde el Windows 11 cliente.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | [[Fase_7.2_Entregables]] |
