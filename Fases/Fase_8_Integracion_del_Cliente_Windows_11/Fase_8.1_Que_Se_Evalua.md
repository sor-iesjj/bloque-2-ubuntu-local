## Fase 8 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.06`** *(pesa un **12 %** del módulo · UD7)*
> *Realiza tareas de integración de sistemas operativos libres y propietarios, describiendo las ventajas de compartir recursos.*
>
> Esta es **la fase central del RA.06**, y la única de todo el itinerario donde un Windows y un Linux trabajan juntos de verdad. Toca **6 de los 9 criterios** del RA.06, y de paso cierra un criterio del `RA.02` y otro del `RA.04` que quedaban pendientes.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.06.a` | Se ha identificado la necesidad de compartir recursos en red entre diferentes sistemas operativos. | El caso de partida: por qué el cliente Windows necesita los datos que vive en el servidor Linux |
> | `CE.06.b` | Se ha comprobado la conectividad de la red en un escenario heterogéneo. | `ping` Windows ↔ Ubuntu por la Red Solo Anfitrión antes de unir nada |
> | `CE.06.c` | Se ha descrito la funcionalidad de los servicios que permiten compartir recursos en red. | Explicar qué hacen SMB, LDAP y Kerberos en esta unión |
> | `CE.06.d` | Se han instalado y configurado servicios para compartir recursos en red. | Unir el Windows 11 al dominio y montar los recursos compartidos |
> | `CE.06.e` | Se ha accedido a sistemas de archivos en red desde equipos con diferentes sistemas operativos. | Abrir desde el Explorador de Windows las carpetas que sirve el Samba de Ubuntu |
> | `CE.06.i` | Se ha comprobado el funcionamiento de los servicios instalados. | Iniciar sesión como `masao.sato` del dominio y comprobar que ve lo suyo y no lo ajeno |
> | `CE.02.c` | Se han configurado y gestionado cuentas de equipo. | **Unir el PC al dominio crea una cuenta de equipo**, no de usuario. Es el **primer** sitio del itinerario donde se ve *(el segundo es la Fase 9, Ubuntu Desktop)* |
> | `CE.04.e` | Se ha utilizado el entorno gráfico para compartir recursos. | Toda la parte de Windows: el Explorador, no la consola |
>
> **Los 3 del RA.06 que NO se evalúan aquí:** `CE.06.f` (impresoras entre sistemas distintos) y `CE.06.g` (trabajo en grupo) no se trabajan en este itinerario; `CE.06.h` (niveles de seguridad de acceso) se demuestra en la **Fase 3** y en la **Auditoría Final**.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.2_Entregables]] |
