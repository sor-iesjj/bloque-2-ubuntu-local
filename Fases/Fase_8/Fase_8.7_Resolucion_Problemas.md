## Fase 8 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿No puedes unirte?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | "No se encuentra el dominio". | El adaptador de Red Solo Anfitrión no está bien configurado o no apunta a la red del laboratorio (`10.10.10.0/24`). | Revisa el Paso 0.1: el Adaptador 1 debe estar en modo `Red Solo Anfitrión` con la red del laboratorio (`10.10.10.0/24`) seleccionada, igual que en el servidor. |
> | "No se encuentra el dominio" aunque la red parece bien. | El DNS del cliente apunta al adaptador NAT en vez de al servidor. | Comprueba que el DNS preferido del adaptador de Red Solo Anfitrión es `10.10.10.10` (Paso 1). |
> | "Error de relación de confianza". | Desfase horario (Clock Skew) superior a 5 minutos — muy típico tras reanudar una VM pausada. | Ejecuta `w32tm /resync /force` (Paso 2) antes de reintentar. |
> | La unidad `Z:` no aparece al reiniciar. | El mapeo no es persistente. | Añade `/persistent:yes` al final del comando `net use`. |
> | RSAT no se descarga / se queda "buscando actualizaciones". | El adaptador NAT no está activo o no tiene salida a Internet. | Comprueba que el Adaptador 2 (NAT) está conectado en la configuración de la VM y que el host tiene Internet. |
> | Las dos VMs no se ven entre sí aunque ambas tienen "Red Solo Anfitrión". | El cliente está conectado a una red host-only distinta en lugar de la del laboratorio. | Corrígelo en VirtualBox → Configuración → Red → Adaptador 1 → Nombre: selecciona la red que tiene la IP `10.10.10.1`, la misma que usa el servidor. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.6_Procedimiento]] | [[Fase_8]] | [[Fase_8.8_Punto_de_Control]] |
