## Fase 10 · Apartado 10.b — 📋 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Lo último.** La checklist antes de la Auditoría Final.

---

> [!caution] 🧾 Con qué te quedas de esta fase
> Con **dos cosas**. Primera: que montar una VM de macOS en VirtualBox es un reto técnico real — exige firmware EFI, simular la CPU y un host con VT-x, y aun así es un hackintosh con sus límites. Y segunda: que **un sistema no necesita estar "unido" al dominio para acceder a sus recursos** — el acceso con un usuario válido es una forma legítima de integración. La matriz se respeta **igual** desde los tres sistemas.

---

### ✅ Checklist de la Fase 10

**La entrega:**

- [ ] Entrada de apuntes `b2-10-integracion-del-cliente-macos.md` con la estructura completa.
- [ ] Tres vídeos en `B2_Ubuntu_Local`: `B2 · F10 · Procedimiento` · `Verificación` · `Averías`, con identificación y timestamps.
- [ ] Instantáneas `Fase 10 terminada` en `macOS` y en el servidor.
- [ ] `.ova` del cliente macOS en el disco externo.

**La verificación (8.a):**

- [ ] La VM de macOS arranca al escritorio (sin tortuga, sin pantalla negra).
- [ ] La VM `ping` al servidor y resuelve el nombre.
- [ ] Hora de la VM correcta.
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
> - **macOS** (Fase 10) se monta como VM en VirtualBox, accede sin unirse y ve la misma matriz.
>
> Tres sistemas operativos, el mismo servidor, las mismas carpetas, los mismos permisos. **Eso es el RA.06 entero.** El modelo de permisos de Boochan S.L. no depende del sistema del cliente: lo decide el servidor, y ya lo has demostrado desde los tres lados.
>
> **Y el reto técnico extra:** conseguir que una VM de macOS arranque en VirtualBox — algo que ni el propio VirtualBox soporta oficialmente. Si lo lograste, sabes más que la mayoría.

> **Siguiente:** la [[Auditoria_Final]]. Con los tres clientes integrados, toca cerrar el laboratorio como se cierra un proyecto de verdad: el endurecimiento del servidor.

---

| ← Anterior | 🧭 Índice |
| :--- | :---: |
| [[Fase_10.10.a_Laboratorio_de_Averias]] | [[Fase_10_Integracion_del_Cliente_macOS]] |
