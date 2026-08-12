## Fase 9 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.06`** *(pesa un **12 %** del módulo · UD7)*
> *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> Es la segunda vuelta del RA.06, **por el lado libre**. La Fase 8 integró un Windows; esta integra un **Ubuntu Desktop**, y el laboratorio deja de ser monótono: el mismo servidor, dos clientes de sistemas operativos distintos, los dos viendo exactamente lo mismo. Toca **4 de los 9 criterios** del RA.06, y de paso cierra un criterio del `RA.02`.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.06.a` | Se ha identificado la necesidad de compartir recursos en red entre diferentes sistemas operativos. | El caso de partida: por qué un equipo Linux de un taller necesita los datos que viven en el servidor |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | `ping` Ubuntu Desktop ↔ servidor por la Red Solo Anfitrión antes de unir nada |
> | `CE.06.e` | Se ha accedido a sistemas de archivos en red desde equipos con diferentes sistemas operativos. | Abrir desde el gestor de archivos de Ubuntu las carpetas que sirve el Samba |
> | `CE.06.i` | Se ha comprobado el funcionamiento de los servicios instalados. | Iniciar sesión como `masao.sato` del dominio y comprobar que ve lo suyo y no lo ajeno |
> | `CE.02.c` | Se han configurado y gestionado cuentas de equipo. | **Unir el Ubuntu al dominio crea una cuenta de equipo**, como en la Fase 8. El segundo sitio del itinerario donde se ve |
>
> **Los del RA.06 que NO se evalúan aquí:** `CE.06.c` y `CE.06.d` (instalar y describir servicios) se demostraron en la **Fase 8** — aquí el servicio ya está montado, y lo que se ve es el **lado cliente**. `CE.06.f` (impresoras entre sistemas) y `CE.06.g` (trabajo en grupo) no se trabajan en este itinerario. `CE.06.h` (niveles de seguridad) se demuestra en la **Auditoría Final**.

---

> [!success] ✅ La diferencia con la Fase 8, en una frase
> La Fase 8 instalaba y configuraba los servicios que comparten recursos (CE.06.c y CE.06.d, del lado del servidor). **Esta fase no instala nada en el servidor**: consume lo que ya existe, desde un cliente de sistema operativo **libre**. Por eso aquí no se evalúan los criterios de instalar, sino los de **acceder** y **comprobar**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.2_Entregables]] |
