## Fase 7 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría de Seguridad (RA.04)
> **Peligro:** Si no usas herencia, los archivos que cree un usuario no podrán ser editados por sus compañeros de grupo, generando tickets de soporte constantes.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] Comprueba con el comando `getfacl /srv/samba/prueba3` que los permisos del grupo `policia` se han aplicado.
> - [ ] ¿El servicio `samba-ad-dc` está en estado `active (running)` tras el reinicio?
> - [ ] En la Fase 8, cuando te conectes desde Windows, verifica que `user2` (bomberos) no ve la carpeta `prueba3` pero `user1` (policia) sí.
> - [ ] 💾 **Instantánea `Fase 7 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.9_Preguntas]] | [[Fase_7]] | **Fase 8** |
