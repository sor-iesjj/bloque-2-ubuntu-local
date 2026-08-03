## Fase 5 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría y Evaluación (RA.02)
> El alumno debe demostrar que el servidor reconoce a los usuarios del dominio como si fueran locales. **Validación:** El comando `id user1` debe devolver el UID y GID configurados manualmente.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de verificar los usuarios, comprueba que el servicio traductor está activo. Si no lo está, el comando `id` devolverá vacío aunque los usuarios existan perfectamente:
> ```bash
> sudo systemctl status winbind
> ```
> Busca la línea `Active: active (running)`. Si dice `inactive` o `failed`, arráncalo:
> ```bash
> sudo systemctl enable winbind --now
> ```
> - [ ] ¿El comando `id user1` devuelve correctamente `uid=10001` y `gid=3001`?
> - [ ] ¿El comando `id user2` devuelve correctamente `uid=10002` y `gid=3002`?
> - [ ] ¿El archivo `/etc/nsswitch.conf` tiene `winbind` en las líneas `passwd` y `group`?
> - [ ] 💾 **Instantánea `Fase 5 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.9_Preguntas]] | [[Fase_5]] | **Fase 6** |
