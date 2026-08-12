## Fase 9 · Apartado 10.b — 📋 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Lo último.** La checklist antes de pasar a la Fase 10.

---

> [!caution] 🧾 Con qué te quedas de esta fase
> Con que **un sistema operativo libre se integra con un servidor de dominio igual que uno propietario** — solo cambian las herramientas. Y con que el modelo de permisos (la matriz) no depende del cliente: lo decide el servidor.

---

### ✅ Checklist de la Fase 9

**La entrega:**

- [ ] Entrada de apuntes `b2-9-integracion-del-cliente-ubuntu-desktop.md` con la estructura completa.
- [ ] Tres vídeos en `B2_Ubuntu_Local`: `B2 · F9 · Procedimiento` · `Verificación` · `Averías`, con identificación y timestamps.
- [ ] Instantáneas `Fase 9 terminada` (cliente y servidor).
- [ ] `.ova` del cliente al disco externo.

**La verificación (8.a):**

- [ ] `realm list` → `configured` · `getent passwd masao.sato` → `uid=10005` · hora en `Europe/Madrid`.
- [ ] Las 7 pruebas de la matriz, desde el cliente Ubuntu, con cambio de sesión.
- [ ] Verificador `verificar_fase9.sh` en verde, con su informe subido.

**La reflexión:**

- [ ] Respuestas a las preguntas del 9 en la entrada, con tus palabras.

---

> [!danger] 🛑 ¿Has restaurado algo con la instantánea? Repítelo
> Si en el laboratorio de averías tuviste que **restaurar la instantánea** porque no lograbas reparar, es que hay un paso que no controlas. **Vuelve a hacerlo** hasta que lo arregles sin restaurar — restaurar es el plan B, no el plan A.

---

> [!success] 🎓 Qué has demostrado
> Que la **matriz de permisos** de Boochan S.L. se respeta desde un cliente **Ubuntu Desktop** — un sistema operativo libre — exactamente igual que desde Windows. Que sabes unir un equipo Linux a un dominio Samba con `realm join` y SSSD. Y que cuando algo falla, el fallo casi nunca está en el cliente: está en la hora, el DNS o el servidor.

> **Siguiente:** la [[Fase_10_Integracion_del_Cliente_macOS|Fase 10 — Integración del Cliente (macOS)]]. Con el Ubuntu Desktop ya integrado, el laboratorio tiene dos clientes libres/propietarios distintos del servidor. Falta el tercero: el de Apple.

---

| ← Anterior | 🧭 Índice |
| :--- | :---: |
| [[Fase_9.10.a_Laboratorio_de_Averias]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] |
