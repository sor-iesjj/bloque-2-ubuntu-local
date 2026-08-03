## Fase 6 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría de Persistencia (RA.04)
> **Riesgo Crítico:** Si el alumno olvida la palabra `loop` en las opciones del `fstab`, Linux intentará tratar el archivo como una partición física real y el servidor entrará en pánico al arrancar.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿Aparecen los discos `/samba_p1.img` y `/samba_p3.img` al ejecutar `df -h`?
> - [ ] Reinicia el servidor para comprobar que los discos se montan solos al arrancar:
> - [ ] 💾 **Instantánea `Fase 6 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.
>   ```bash
>   sudo reboot
>   ```
>   > [!caution] ⚠️ La conexión SSH se cortará al instante — es normal
>   > La máquina virtual se está reiniciando. **Espera 1-2 minutos** y vuelve a conectarte con el mismo comando SSH (o abre la ventana de VirtualBox y espera a ver el prompt de login). No es un error. Cuando veas el prompt de nuevo, ejecuta `df -h` y confirma que los discos de 5 GB aparecen montados.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.9_Preguntas]] | [[Fase_6]] | **Fase 7** |
