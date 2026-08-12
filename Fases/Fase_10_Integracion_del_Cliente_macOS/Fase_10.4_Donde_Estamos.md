## Fase 10 · Apartado 4 — 📍 Dónde estamos

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] 🧭 Punto de partida — el laboratorio ya tiene DOS clientes integrados
>
> | Máquina | SO | IP | Estado |
> | :--- | :--- | :--- | :--- |
> | **Servidor** `UbuntuServer` | Ubuntu Server | `10.10.10.10` | Dominio + Samba + carpetas + ACL + ABE (Fases 1-7) |
> | **Cliente** `Windows11` | Windows 11 | `10.10.10.20` | Unido al dominio (Fase 8) |
> | **Cliente** `UbuntuDesktop` | Ubuntu Desktop | `10.10.10.30` | Unido al dominio (Fase 9) |
> | **Cliente** (hoy) | **macOS** | — | **Accede** al dominio, sin unirse |

> [!success] 🎯 Lo que vas a conseguir
> Que un **Mac** acceda a las carpetas del servidor como lo hacen los otros dos clientes — pero **sin unirse al dominio**. Es la forma de integración que se usa en la vida real cuando un portátil ajeno a la empresa (de un empleado, de un turista) necesita los datos sin "pertenecer" a la red.

> [!warning] ⚠️ La diferencia: acceso, no unión
> - Windows y Ubuntu **se unieron** (tienen cuenta de equipo en el servidor).
> - El macOS **no se une**: entra con un usuario del dominio (`masao.sato`) contra el servidor, igual que se conecta a una carpeta compartida.
>
> **No es que falte algo — es el alcance elegido.** Demuestra la misma matriz de permisos desde el sistema de Apple, sin necesidad de dar al Mac una identidad de dominio.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.3_Obligaciones_Grabacion]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.5_Fundamento_Teorico]] |
