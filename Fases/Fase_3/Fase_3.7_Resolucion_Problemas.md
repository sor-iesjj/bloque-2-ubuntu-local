## Fase 3 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿No hay conexión?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `Address already in use`. | Ya hay otra interfaz VPN activa con esa IP. | Ejecuta `sudo wg-quick down wg0` antes de volver a levantarla. |
> | No hay ping entre `10.20.20.1` y `10.20.20.2`. | El cliente no está en la misma Red Solo Anfitrión que el servidor, o el adaptador de red del cliente está mal seleccionado en VirtualBox. | Comprueba en VirtualBox que el adaptador usado por el cliente apunta a la misma red Solo Anfitrión (la del `10.10.10.1`, la que configuraste en la Fase 1.2). |
> | WireGuard no conecta pero no hay firewall de por medio. | Las llaves públicas están intercambiadas incorrectamente. | Verifica que la llave pública del cliente en el servidor y la del servidor en el cliente son exactas. |
> | El cliente no encuentra el `Endpoint`. | Escribiste mal la IP `10.10.10.10` o el servidor no tiene esa IP activa. | Ejecuta `hostname -I` en el servidor y confirma que `10.10.10.10` sigue asignada al adaptador de Red Solo Anfitrión. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.6_Procedimiento]] | [[Fase_3]] | [[Fase_3.8_Punto_de_Control]] |
