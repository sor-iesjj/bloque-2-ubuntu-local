## Fase 1 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las comprobaciones de [[Fase_1.8.a_Verificacion]] —**las dos partes, la de dentro y la de tu Windows**— vuelve allí. Guardar ahora sería fijar un estado que no sabes si es bueno.

---

## **1 · ESTA FASE TIENE DOS INSTANTÁNEAS**

Es la única del bloque que lleva dos, y se toman en momentos distintos:

| Instantánea | Cuándo se toma | Para qué sirve |
| :--- | :--- | :--- |
| **`Sistema base`** | Al terminar [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu\|6.c]] | **La más valiosa del curso.** Evita reinstalar Ubuntu nunca más |
| **`Fase 1 terminada`** | **Aquí**, tras verificar | Punto de partida limpio para la Fase 2, y **origen del clon** de la 6.f |

> [!danger] 💾 Por qué `Sistema base` se guarda sin verificar del todo
> Es la excepción de la regla *"primero verificar, después guardar"*, y tiene una razón:
>
> | Rehacer… | Cuesta |
> | :--- | :--- |
> | Instalar Ubuntu desde la ISO | **20-30 minutos** delante de la pantalla, contestando |
> | Todo lo demás del proyecto | minutos, y son comandos que se pegan |
>
> **Todo lo que viene después son comandos. Esto no.** Es la única parte del curso que no se puede automatizar ni acelerar.
>
> Guardarla nada más instalar te asegura que **jamás repetirás esa media hora**, pase lo que pase después. El coste de guardar algo imperfecto es cero; el de perder la instalación, media clase.

---

## **2 · TOMA LA INSTANTÁNEA `Fase 1 terminada`**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```

En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 1 terminada`**.

Por comando, si el botón no aparece:
```
VBoxManage snapshot "UbuntuServer" take "Fase 1 terminada"
```

Y comprueba que se ha creado:
```
VBoxManage snapshot "UbuntuServer" list
```

- **✅ Bien:** salen **las dos**, `Sistema base` y `Fase 1 terminada`, y la segunda cuelga de la primera.

> [!info] 🌳 Las instantáneas forman un ÁRBOL, no una lista
> `Fase 1 terminada` **cuelga de** `Sistema base`. Y eso tiene una consecuencia que tranquiliza:
>
> **Volver a `Sistema base` NO borra `Fase 1 terminada`.** Puedes restaurar la de atrás, mirar algo, y volver adelante. Las instantáneas no se pisan unas a otras.
>
> Lo que sí las borra es borrarlas tú a mano.

> Cómo se hace paso a paso, qué es un UUID y qué **no** conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper cosas a propósito**. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

---

## **3 · LA COPIA DE SEGURIDAD EN TU DISCO EXTERNO**

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> Las dos instantáneas que acabas de tomar **viven dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco duro, **se va todo con ellas**: máquina e instantáneas.
>
> Y en esta fase te llevarías por delante `Sistema base`, que es media hora de tu vida.

### **3A — Exporta la máquina**

Con la VM **apagada**, en VirtualBox:

`Archivo` → **`Exportar servicio virtualizado`** → selecciona `UbuntuServer` → formato **OVF 2.0** → guarda.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_1\B2-F1-infraestructura-virtual.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

### **3B — Dónde va y cómo se llama**

**Estructura de carpetas en el disco** — la misma que la del material:

```
SOR/
└── Bloque_2/
    └── Fases/
        └── Fase_1/
            └── B2-F1-infraestructura-virtual.ova
```

**El nombre y la ruta no son orientativos.** Cuando tengas ocho copias, la estructura es lo único que te dejará encontrar la que buscas.

### **3C — Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño del fichero**. Debe rondar los 3-5 GB.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**. Nadie quiere ver una barra de progreso durante ocho minutos.

> [!info] 🎓 Por qué exportamos y no copiamos la carpeta
> Podrías copiar la carpeta `VirtualBox VMs/UbuntuServer/` al disco y funcionaría. Pero un `.ova` es **un solo fichero, comprimido y autocontenido**: se importa con doble clic en cualquier VirtualBox, incluso de otro sistema operativo.

> [!warning] ⚠️ El `.ova` NO se lleva las instantáneas
> Exportar aplana la máquina: te llevas **el estado actual**, no el historial. Si restauras este `.ova`, tendrás un servidor con la Fase 1 hecha, **pero sin `Sistema base` dentro**.
>
> No es un problema —el `.ova` *es* tu Fase 1 terminada—, pero conviene saberlo antes de contar con algo que no está.

> [!question] 🔮 Para qué te va a servir esto
> Más adelante se te va a pedir **destruir tu servidor y recuperarlo desde esta copia**. No es una amenaza: es la única forma de saber si una copia de seguridad sirve.
>
> **Una copia que nunca se ha restaurado no es una copia: es una suposición.**

---

## **4 · Y AHORA, LA ENTREGA POR PAREJAS**

> [!important] 👉 Con `Fase 1 terminada` tomada, te queda [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar|la 6.f]]
> Esa instantánea no sirve solo para volver atrás: **es el punto desde el que se clona**. En la 6.f la conviertes en una máquina que le das a un compañero, y descubres —chocándote— qué partes de un servidor **no se pueden duplicar**.
>
> Necesitas un compañero que también haya llegado hasta aquí. Ve poniéndote de acuerdo.

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff`, **grabándolo**.
- [ ] 💾 Instantánea **`Fase 1 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **las dos** instantáneas.
- [ ] 💿 **`B2-F1-infraestructura-virtual.ova` exportado** a `SOR/Bloque_2/Fases/Fase_1/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (3-5 GB).
- [ ] Todo ello grabado en el vídeo **`B2 · F1 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.8.a_Verificacion]] | [[Fase_1]] | [[Fase_1.9_Preguntas]] |
