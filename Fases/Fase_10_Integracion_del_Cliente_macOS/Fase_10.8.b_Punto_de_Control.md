## Fase 10 · Apartado 8.b — 💾 Punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Solo si el 8.a va limpio.** Instantánea del servidor.

---

> [!danger] 🛑 Si no has verificado, no guardes
> El 8.a va **primero**. Guardar sin verificar guarda los fallos.

---

> [!example] 💾 Toma las instantáneas
> Con las **dos VMs apagadas de verdad**:
>
> | Máquina | Nombre de la instantánea |
> | :--- | :--- |
> | `macOS` | **`Fase 10 terminada`** |
> | `UbuntuServer` | **`Fase 10 terminada`** |

> [!info] 💡 Esta fase SÍ tiene instantánea de cliente
> El cliente es una **VM de macOS** en VirtualBox (como las de las Fases 8 y 9), así que se guarda su instantánea **y** se exporta su `.ova`.

> [!warning] ⚠️ Apagado de verdad, no en pausa
> Una instantánea con la máquina en pausa guarda la RAM y el reloj congelado — y ya sabes lo que le hace eso a Kerberos (Fase 8, caso E3).

---

### ✅ Comprueba que guardaste

- [ ] Instantánea `Fase 10 terminada` en `macOS`.
- [ ] Instantánea `Fase 10 terminada` en `UbuntuServer`.
- [ ] `.ova` del cliente macOS en el disco externo (ruta correcta).

> [!success] ✅ Con la instantánea tomada, el trabajo de máquina está hecho. El 9 y el 10 son de mesa y de averías.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.8.a_Verificacion]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.9_Preguntas]] |
