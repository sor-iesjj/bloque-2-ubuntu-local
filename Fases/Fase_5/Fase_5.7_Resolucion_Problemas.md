## Fase 5 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿Los usuarios no funcionan?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `id user1` no devuelve nada. | El `winbind` no está en `/etc/nsswitch.conf` o el servicio no está activo. | Comprueba el Paso 1 y verifica que las líneas `passwd` y `group` incluyen `winbind`. Luego ejecuta `sudo systemctl status winbind`. |
> | Error: "Password too weak". | La política de AD exige complejidad. | Usa una contraseña con mayúsculas, números y símbolos como `P@ssw0rd`. |
> | Error: "Group already exists". | El grupo se creó en un intento anterior. | Ejecuta `sudo samba-tool group delete policia` y vuelve a crearlo. |
> | Error de esquema LDAP en `addunixattrs` ("no such attribute" o similar). | El dominio se provisionó sin el flag RFC 2307. | El script de la Fase 4 debe haberse ejecutado con `--use-rfc2307`. Vuelve a la Fase 4, borra el dominio con `sudo samba-tool domain demote` y ejecuta de nuevo el script. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.6_Procedimiento]] | [[Fase_5]] | [[Fase_5.8_Punto_de_Control]] |
