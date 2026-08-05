## Fase 2 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las cinco comprobaciones de [[Fase_2.8.a_Verificacion]], **vuelve allí**. Guardar ahora sería fijar un estado que no sabes si es bueno.

---

## 💾 PARTE 1 — La instantánea

> [!important] 💾 Guarda el estado dentro de VirtualBox
> Con la grabación todavía en marcha, apaga la máquina:
>
> ```bash
> sudo poweroff
> ```
>
> En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 2 terminada`**, con la descripción *"Samba purgado y reinstalado, sistema actualizado, `/etc/hosts` con el FQDN"*.
>
> Por comando:
> ```
> VBoxManage snapshot "UbuntuServer" take "Fase 2 terminada"
> ```
>
> Y comprueba que se ha creado:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay otra razón: en el apartado 10 vas a **romper cosas a propósito**. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

---

## 💿 PARTE 2 — La copia de seguridad en tu disco externo

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> La instantánea que acabas de tomar **vive dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco duro, **se va todo con ella**: máquina e instantáneas.
>
> Sacar la información fuera es lo que la convierte en una copia de seguridad de verdad.

### **1 · Exporta la máquina**

Con la VM **apagada**, en VirtualBox:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda como `B2-F2-purga-y-preparacion.ova`.

> [!tip] 💡 Es el mismo procedimiento de la Fase 1
> Si no te acuerdas de alguna pantalla, lo tienes paso a paso en [[Fase_1.8.b_Punto_de_Control]], incluido **por qué se marca el manifiesto** y **por qué la máquina tiene que estar apagada** para aparecer en la lista.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_2\B2-F2-purga-y-preparacion.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

### **2 · Dónde va y cómo se llama**

```
SOR/
└── Bloque_2/
    └── Fases/
        └── Fase_2/
            └── B2-F2-purga-y-preparacion.ova
```

**El nombre y la ruta no son orientativos.** Cuando tengas ocho copias, la estructura es lo único que te permitirá encontrar la que buscas.

### **3 · Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño**. Debe rondar los 5-8 GB.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.

> [!question] 🔮 Para qué te va a servir esto
> Más adelante se te va a pedir **destruir tu servidor y recuperarlo desde esta copia**.
>
> **Una copia que nunca se ha restaurado no es una copia: es una suposición.**

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff`, **grabándolo**.
- [ ] 💾 Instantánea **`Fase 2 terminada`** tomada.
- [ ] Comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F2-purga-y-preparacion.ova` exportado** a `SOR/Bloque_2/Fases/Fase_2/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (5-8 GB).
- [ ] Todo grabado en el vídeo **`B2 · F2 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.8.a_Verificacion]] | [[Fase_2]] | [[Fase_2.9_Preguntas]] |
