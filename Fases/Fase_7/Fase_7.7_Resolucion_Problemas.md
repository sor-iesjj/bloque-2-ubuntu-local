## Fase 7 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿La seguridad falla?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Las ACLs no funcionan (Access Denied). | El sistema de archivos no tiene activado el soporte. | Verifica que el disco esté montado con la opción `acl` en el fstab (aunque en ext4 es por defecto). |
> | El usuario ve la carpeta pero no puede entrar. | Samba no se ha reiniciado tras el cambio. | Ejecuta `sudo systemctl restart samba-ad-dc` y vuelve a intentarlo. |
> | `samba-ad-dc` no arranca tras editar el smb.conf. | Error de sintaxis en el archivo. | Ejecuta `sudo testparm` para que Samba te indique exactamente en qué línea está el error. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.6_Procedimiento]] | [[Fase_7]] | [[Fase_7.8_Punto_de_Control]] |
