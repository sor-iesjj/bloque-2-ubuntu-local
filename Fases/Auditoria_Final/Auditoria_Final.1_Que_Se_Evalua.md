## Auditoría Final · Apartado 1 — 📋 Qué se te evalúa

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Auditoría Final y Hardening**
> 🧭 Índice: [[Auditoria_Final]]
>
> **📍 Cuándo se lee:** Antes de empezar — qué se te evalúa

---

> [!abstract] 📋 Qué se te evalúa en esta auditoría
> Cerrar el servidor es la única tarea del itinerario que **repasa todo lo anterior**, así que toca tres resultados de aprendizaje a la vez:
>
> **`RA.04`** *(12 % del módulo · UD7)* — *Gestiona los recursos compartidos del sistema, interpretando especificaciones y determinando niveles de seguridad.*
> **`RA.05`** *(10 % del módulo · UD7)* — *Realiza tareas de monitorización y uso del sistema operativo en red, describiendo las herramientas utilizadas.*
> **`RA.06`** *(12 % del módulo · UD7)* — *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.04.f` | Se han establecido niveles de seguridad para controlar el acceso del cliente a los recursos compartidos. | Las reglas de `ufw`: quién puede llegar al puerto 445 y quién no |
> | `CE.05.c` | Se ha observado la actividad del SO en red a partir de las trazas generadas por el propio sistema. | Leer los registros del firewall y de Samba para comprobar qué se está bloqueando de verdad |
> | `CE.05.f` | Se ha interpretado la información de configuración del sistema operativo en red. | Auditar la configuración final del servidor y saber justificar cada regla abierta |
> | `CE.06.h` | Se han establecido niveles de seguridad para controlar el acceso del usuario a los recursos compartidos. | La lista blanca: solo `10.10.10.0/24` y el túnel `10.20.20.0/24` |
> | `CE.06.i` | Se ha comprobado el funcionamiento de los servicios instalados. | Verificar, después de cerrar, que el cliente Windows **sigue funcionando**. Un hardening que rompe el servicio no es hardening |
>
> > [!warning] ⚠️ El criterio que más se suspende es `CE.06.i`
> > Cerrar puertos es fácil. Cerrarlos **sin romper nada** es la habilidad de verdad. Si terminas la auditoría y el Windows 11 ya no ve las carpetas, no has asegurado el servidor: lo has estropeado. **Comprueba siempre después de cerrar.**

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Auditoria_Final]] | [[Auditoria_Final.2_Entregables]] |
