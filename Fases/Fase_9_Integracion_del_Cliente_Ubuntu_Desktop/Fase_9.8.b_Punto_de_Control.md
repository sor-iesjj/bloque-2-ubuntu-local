## Fase 9 · Apartado 8.b — 💾 Punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Solo si el 8.a va limpio.** Instantáneas y copias.

---

> [!danger] 🛑 Si no has verificado, no guardes
> El 8.a va **primero**. Guardar sin verificar guarda los fallos. No se toman instantáneas de un trabajo sin comprobar.

---

> [!example] 💾 Toma las instantáneas
> Con las dos VMs **APAGADAS de verdad** (no en pausa):
>
> | Máquina | Nombre de la instantánea |
> | :--- | :--- |
> | `UbuntuDesktop` | **`Fase 9 terminada`** |
> | `UbuntuServer` | **`Fase 9 terminada`** |
>
> > [!warning] ⚠️ Apagadas de verdad, no en pausa
> > Una instantánea con la máquina en pausa guarda la RAM y el reloj congelado — y ya sabes lo que le hace eso a Kerberos (Fase 8, caso E3).

> [!example] 💿 Exporta el cliente a `.ova`
> Con `UbuntuDesktop` apagada, expórtala a tu **disco externo**:
>
> ```
> SOR/Bloque_2/Fases/Fase_9_Integracion_del_Cliente_Ubuntu_Desktop/
>     └── B2-F9-cliente-ubuntu-desktop.ova
> ```
>
> > [!danger] 🛑 El `.ova` va al disco externo, **nunca a GitHub**
> > Es una VM completa de varios GB. Las copias `.ova` viven fuera del repositorio, en el disco externo.

---

### ✅ Comprueba que guardaste

- [ ] Instantánea `Fase 9 terminada` en `UbuntuDesktop`.
- [ ] Instantánea `Fase 9 terminada` en `UbuntuServer`.
- [ ] `.ova` del cliente en el disco externo, con la ruta correcta.

> [!success] ✅ Con las instantáneas tomadas, el trabajo de máquina está hecho. El 9 y el 10 son de mesa y de averías.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.8.a_Verificacion]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.9_Preguntas]] |
