## Fase 10 · Apartado 10.b — 📋 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Lo último.** La checklist antes de la Auditoría Final.

---

> [!caution] 🧾 Con qué te quedas de esta fase
> Con que **un sistema no necesita estar "unido" al dominio para acceder a sus recursos**. El acceso con un usuario válido es una forma legítima de integración — la que usa el mundo real para portátiles ajenos. Y con que la matriz de permisos se respeta **igual** desde los tres sistemas: Windows, Ubuntu y macOS.

---

### ✅ Checklist de la Fase 10

**La entrega:**

- [ ] Entrada de apuntes `b2-10-integracion-del-cliente-macos.md` con la estructura completa.
- [ ] Tres vídeos en `B2_Ubuntu_Local`: `B2 · F10 · Procedimiento` · `Verificación` · `Averías`, con identificación y timestamps.
- [ ] Instantánea `Fase 10 terminada` en el servidor.

**La verificación (8.a):**

- [ ] El Mac `ping` al servidor y resuelve el nombre.
- [ ] Hora del Mac correcta.
- [ ] Las 7 pruebas de la matriz desde el Finder, con cambio de usuario.
- [ ] *(Opcional)* Verificador del servidor en verde.

**La reflexión:**

- [ ] Respuestas a las preguntas del 9 en la entrada, con tus palabras.

---

> [!danger] 🛑 ¿Has restaurado algo con la instantánea? Repítelo
> Si en el laboratorio tuviste que restaurar porque no lograbas reparar, vuelve a hacerlo hasta que lo arregles sin restaurar.

---

> [!success] 🎓 Qué has demostrado con la tríada completa
> - **Windows** (Fase 8) se une al dominio y ve la matriz.
> - **Ubuntu Desktop** (Fase 9) se une al dominio y ve la misma matriz.
> - **macOS** (Fase 10) accede sin unirse y ve la misma matriz.
>
> Tres sistemas operativos, el mismo servidor, las mismas carpetas, los mismos permisos. **Eso es el RA.06 entero.** El modelo de permisos de Boochan S.L. no depende del sistema del cliente: lo decide el servidor, y ya lo has demostrado desde los tres lados.

> **Siguiente:** la [[Auditoria_Final]]. Con los tres clientes integrados, toca cerrar el laboratorio como se cierra un proyecto de verdad: el endurecimiento del servidor.

---

| ← Anterior | 🧭 Índice |
| :--- | :---: |
| [[Fase_10.10.a_Laboratorio_de_Averias]] | [[Fase_10_Integracion_del_Cliente_macOS]] |
