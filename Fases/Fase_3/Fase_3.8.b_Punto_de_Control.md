## Fase 3 · Apartado 8.b — 💾 Punto de control y copia de seguridad

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
> > [!danger] 🛑 La VM tiene que estar APAGADA DEL TODO. No "guardada"
> > No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`**. Tiene que apagarse de verdad, con `sudo poweroff` o con `Apagar por ACPI`.
> >
> > **Por qué:** una instantánea tomada con la máquina encendida guarda también **el contenido de la RAM** — y con ella, **el reloj congelado**. Al restaurarla dentro de unas semanas, el servidor despierta creyendo que sigue siendo hoy.
> >
> > Y eso importa más de lo que parece: a partir de la **Fase 4** este servidor será un controlador de dominio, y **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**. Una instantánea con el reloj congelado se convierte, más adelante, en un dominio en el que nadie puede entrar.
> >
> > **Cómo distinguirlas:** en el árbol de VirtualBox llevan un icono distinto y arrastran un fichero `.sav` de varios cientos de MB. Compruébalo:
> > ```
> > VBoxManage snapshot "UbuntuServer" list --details
> > ```
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

## 💾 PARTE 2 — La copia de seguridad en tu disco externo

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> La instantánea que acabas de tomar **vive dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco duro, **se va todo con ella**: máquina e instantáneas.
>
> Sacar la información fuera es lo que convierte esto en una copia de seguridad de verdad.

### **1 · Exporta la máquina**

Con la VM **apagada**, en VirtualBox:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda como `B2-F3-conectividad-vpn.ova`.

> [!tip] 💡 Es el mismo procedimiento de la Fase 1
> Si no te acuerdas de alguna pantalla, lo tienes paso a paso en [[Fase_1.8.b_Punto_de_Control]], incluido **por qué se marca el manifiesto** y **por qué la máquina tiene que estar apagada** para aparecer en la lista.

O por comando:
```


VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_3\B2-F3-conectividad-vpn.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

### **2 · Dónde va y cómo se llama**

**Estructura de carpetas en el disco** — la misma que la del material:

```
SOR/
└── Bloque_2/
    └── Fases/
        └── Fase_3/
            └── B2-F3-conectividad-vpn.ova
```

**El nombre y la ruta no son orientativos.** Cuando en unas semanas tengas ocho copias, la estructura es lo único que te permitirá encontrar la que buscas.

### **3 · Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño del fichero**. Debe rondar los 5-8 GB.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.
>
> Es lo mismo que haces con una instalación larga: se ve el principio y se ve el resultado.

> [!info] 🎓 Por qué exportamos y no copiamos la carpeta
> Podrías copiar la carpeta `VirtualBox VMs/UbuntuServer/` al disco y funcionaría. Pero un `.ova` es **un solo fichero, comprimido y autocontenido**: se importa con doble clic en cualquier VirtualBox, incluso de otro sistema operativo.
>
> Y ocupa bastante menos, porque comprime el disco virtual.

> [!question] 🔮 Para qué te va a servir esto
> Más adelante se te va a pedir **destruir tu servidor y recuperarlo desde esta copia**. No es una amenaza: es la única forma de saber si una copia de seguridad sirve.
>
> **Una copia que nunca se ha restaurado no es una copia: es una suposición.**

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff` —**apagada, no "estado guardado"**— y grabándolo.
- [ ] Comprobado que la instantánea **no arrastra estado de RAM** (`list --details`).
- [ ] 💾 Instantánea **`Fase 3 terminada`** tomada.
- [ ] Comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F3-conectividad-vpn.ova` exportado** a `SOR/Bloque_2/Fases/Fase_3/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (5-8 GB).
- [ ] Todo ello grabado en el vídeo **`B2 · F3 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.8.a_Verificacion]] | [[Fase_3]] | [[Fase_3.9_Preguntas]] |
