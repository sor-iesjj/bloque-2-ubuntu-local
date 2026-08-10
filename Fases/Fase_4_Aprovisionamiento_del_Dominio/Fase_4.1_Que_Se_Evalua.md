## Fase 4 · Apartado 1 — 📋 Qué se te evalúa en esta fase

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4_Aprovisionamiento_del_Dominio]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué se te va a evaluar.

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.03`** *(pesa un **18 %** del módulo, el segundo más alto · UD6)*
> *Realiza tareas de gestión sobre dominios identificando necesidades y aplicando herramientas de administración.*
>
> Esta es **la fase central del RA.03**: toca **6 de sus 8 criterios**.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.03.a` | Se ha identificado la función del servicio de directorio, sus elementos y nomenclatura. | El fundamento teórico: qué es un directorio, y el porqué de `BOOCHANLAB` / `BOOCHANLAB.LOCAL` (NetBIOS y Realm) |
> | `CE.03.b` | Se ha reconocido el concepto de dominio y sus funciones. | Explicar en el vídeo qué gana el laboratorio al tener dominio frente a máquinas sueltas |
> | `CE.03.d` | Se ha realizado la instalación del servicio de directorio. | El aprovisionamiento de Samba AD DC |
> | `CE.03.e` | Se ha realizado la configuración básica del servicio de directorio. | `smb.conf`, el DNS interno y `resolv.conf` inmutable |
> | `CE.03.g` | Se ha analizado la estructura del servicio de directorio. | Recorrer el árbol del dominio recién creado y reconocer sus contenedores |
> | `CE.03.h` | Se han utilizado herramientas de administración de dominios. | `samba-tool` de principio a fin |
>
> **Los 2 que NO se evalúan aquí:** `CE.03.f` (agrupaciones para modelos administrativos) se trabaja en la **Fase 5** al crear las unidades organizativas; `CE.03.c` (relaciones de confianza entre dominios) **requiere dos dominios** y queda fuera del alcance de este laboratorio de un solo servidor.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| — | [[Fase_4_Aprovisionamiento_del_Dominio]] | [[Fase_4.2_Entregables]] |
