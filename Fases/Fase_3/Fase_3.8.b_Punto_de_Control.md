## Fase 3 · Apartado 8.b — 💾 Punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las cinco comprobaciones de [[Fase_3.8.a_Verificacion]], **vuelve allí**. Guardar ahora sería fijar un estado que no sabes si es bueno.

---

> [!important] 💾 Ahora sí: guarda el estado
> **Solo si las cinco verificaciones han salido bien.** Con la grabación todavía en marcha, apaga la máquina:
>
> ```bash
> sudo poweroff
> ```
>
> En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 3 terminada`**.
>
> Por comando, si el botón no aparece:
> ```
> VBoxManage snapshot "UbuntuServer" take "Fase 3 terminada"
> ```
>
> Y comprueba que se ha creado:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco y la VM en la mano.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper cosas a propósito** para entender qué detecta cada comprobación. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, cómo verificar que existe y qué NO conserva: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff`, **grabándolo**.
- [ ] 💾 Instantánea **`Fase 3 terminada`** tomada.
- [ ] Comprobada con `VBoxManage snapshot "UbuntuServer" list`.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.8.a_Verificacion]] | [[Fase_3]] | [[Fase_3.9_Preguntas]] |
