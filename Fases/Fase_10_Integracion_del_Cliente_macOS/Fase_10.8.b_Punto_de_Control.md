## Fase 10 · Apartado 8.b — 💾 Punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Solo si el 8.a va limpio.** Instantánea del servidor.

---

> [!danger] 🛑 Si no has verificado, no guardes
> El 8.a va **primero**. Guardar sin verificar guarda los fallos.

---

> [!example] 💾 Toma la instantánea del servidor
> Con el **servidor apagado de verdad**:
>
> | Máquina | Nombre de la instantánea |
> | :--- | :--- |
> | `UbuntuServer` | **`Fase 10 terminada`** |

> [!info] 💡 No hay instantánea de cliente
> En las Fases 8 y 9 guardabas la instantánea de la VM cliente. Aquí **el cliente es tu Mac real** — no hay VM que guardar. Solo se guarda el servidor, que es lo que podría tocarse.

> [!warning] ⚠️ Apagado de verdad, no en pausa
> Una instantánea con la máquina en pausa guarda la RAM y el reloj congelado — y ya sabes lo que le hace eso a Kerberos (Fase 8, caso E3).

---

### ✅ Comprueba que guardaste

- [ ] Instantánea `Fase 10 terminada` en `UbuntuServer`.
- [ ] *(El cliente macOS no se exporta: es un Mac real.)*

> [!success] ✅ Con la instantánea tomada, el trabajo de máquina está hecho. El 9 y el 10 son de mesa y de averías.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.8.a_Verificacion]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.9_Preguntas]] |
