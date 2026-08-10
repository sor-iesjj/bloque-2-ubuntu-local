## Fase 1 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1_Infraestructura_Virtual_Local]]
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
| **`Fase 1 terminada`** | **Aquí**, tras verificar | Punto de partida limpio para la Fase 2, y **el punto al que vuelves** tras entregar tu copia en la 6.f |

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

## **2 · TOMA LA INSTANTÁNEA Fase 1 terminada**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```



> [!danger] 🛑 La VM tiene que estar APAGADA DEL TODO. No "guardada"
> No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`**. Tiene que apagarse de verdad, con `sudo poweroff` o con `Apagar por ACPI`.
>
> **Por qué:** una instantánea tomada con la máquina encendida guarda también **el contenido de la RAM** — y con ella, **el reloj congelado**. Al restaurarla dentro de unas semanas, el servidor despierta creyendo que sigue siendo hoy.
>
> Y eso importa más de lo que parece: a partir de la **Fase 4** este servidor será un controlador de dominio, y **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**. Una instantánea con el reloj congelado se convierte, más adelante, en un dominio en el que nadie puede entrar.
>
> **Cómo distinguirlas:** en el árbol de VirtualBox llevan un icono distinto y arrastran un fichero `.sav` de varios cientos de MB. Compruébalo:
> ```
> VBoxManage snapshot "UbuntuServer" list --details
> ```


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

### **3A — Exporta la máquina (procedimiento completo)**

> [!danger] ⚠️ La máquina tiene que estar APAGADA
> Una máquina encendida **no aparece en la lista** del asistente. Si no la ves, es que sigue corriendo: apágala con `sudo poweroff` y vuelve a entrar.

> [!info] 🎓 Exportar NO es clonar. No los confundas
> | | **Clonar** | **Exportar** ← lo de aquí |
> | :--- | :--- | :--- |
> | Qué produce | **Otra máquina virtual**: una carpeta con muchos ficheros | **UN solo fichero** `.ova` |
> | Dónde queda | Dentro de tu VirtualBox, en la lista | Donde tú digas: el disco externo |
> | Para qué | Trabajar con una copia sin tocar la original | **Sacar la máquina fuera** |
>
> Una máquina virtual **es una carpeta**, no un fichero. El `.ova` solo existe cuando exportas: es esa carpeta empaquetada y comprimida en uno solo.
>
> **Para una copia de seguridad quieres un fichero.** Por eso se exporta.

**Paso a paso, en VirtualBox:**

**1.** Menú **`Archivo`** → **`Exportar servicio virtualizado…`**

**2.** *(Máquinas virtuales)* — Selecciona **`UbuntuServer`** y pulsa `Siguiente`.

> Aquí ves **todas tus máquinas apagadas**. Si tienes más de una, asegúrate de marcar la tuya y no otra.

**3.** *(Configuración del formato)* — Tres cosas que decidir:

| Campo | Qué pones | Por qué |
| :--- | :--- | :--- |
| **Formato** | **`Open Virtualization Format 2.0`** | El `1.0` es de 2009 y existe por compatibilidad con herramientas antiguas. Todos usáis VirtualBox |
| **Archivo** | La ruta de tu disco externo *(punto 3B)* | Que no se quede en el equipo del aula |
| **Escribir archivo de manifiesto** | ✅ **Márcalo** | Ver abajo |

> [!tip] 💡 Qué es el "archivo de manifiesto" y por qué se marca
> Es una lista de **sumas de verificación** del contenido, que viaja dentro del `.ova`. Al importar, VirtualBox comprueba con ella que **el fichero no se ha corrompido** por el camino.
>
> No cuesta nada y te da algo importante: **una copia que no puedes comprobar no es una copia, es una esperanza.** Un disco externo que se cae al suelo, un pendrive que se saca sin expulsar o una copia interrumpida producen ficheros que parecen buenos y no lo son.

**4.** *(Configuración del servicio virtualizado)* — Datos descriptivos: nombre del producto, fabricante, versión. **Puedes dejarlo como está**; no afectan al funcionamiento. Pulsa **`Exportar`**.

**5.** Espera. Tarda varios minutos y **no hay que tocar nada**.

**Y si prefieres la línea de comandos**, en `cmd` o PowerShell de tu Windows:
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

> [!important] 👉 Con `Fase 1 terminada` tomada, te queda [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|la 6.f]]
> Esa instantánea no sirve solo para volver atrás: **es el punto al que volverás**. En la 6.f vas a limpiar la identidad de tu servidor, exportarlo para dárselo a un compañero, y después **restaurar esta instantánea para recuperar el tuyo intacto**.
>
> Y descubrirás, chocándote, qué partes de un servidor **no se pueden duplicar**.
>
> Necesitas un compañero que también haya llegado hasta aquí. Ve poniéndote de acuerdo.

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff` —**apagada, no "estado guardado"**— y grabándolo.
- [ ] Comprobado que la instantánea **no arrastra estado de RAM** (`list --details`).
- [ ] 💾 Instantánea **`Fase 1 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **las dos** instantáneas.
- [ ] 💿 **`B2-F1-infraestructura-virtual.ova` exportado** a `SOR/Bloque_2/Fases/Fase_1_Infraestructura_Virtual_Local/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (3-5 GB).
- [ ] Todo ello grabado en el vídeo **`B2 · F1 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.8.a_Verificacion]] | [[Fase_1_Infraestructura_Virtual_Local]] | [[Fase_1.9_Preguntas]] |
