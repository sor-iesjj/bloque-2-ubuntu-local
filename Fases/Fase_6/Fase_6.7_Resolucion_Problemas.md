## Fase 6 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿El disco no aparece?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | El servidor no arranca tras editar el fstab. | Error de sintaxis crítico en `/etc/fstab`. No ejecutaste `sudo mount -a` antes de reiniciar. | Abre la **ventana de la máquina virtual en VirtualBox** (no hace falta SSH, ni SSM, ni consola serie: al ser una VM local tienes la pantalla completa disponible). Inicia sesión con el usuario local del servidor y ejecuta `sudo nano /etc/fstab`, corrige la línea, guarda y ejecuta `sudo reboot`. |
> | `df -h` no muestra los discos de 5GB. | No se ha ejecutado el comando de montaje. | Ejecuta `sudo mount -a` para forzar el montaje de lo definido en el fstab. |
> | Error "wrong fs type" al montar. | El archivo `.img` no se formateó correctamente. | Vuelve a ejecutar `sudo mkfs.ext4 /samba_p1.img` y luego `sudo mount -a`. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.6_Procedimiento]] | [[Fase_6]] | [[Fase_6.8_Punto_de_Control]] |
