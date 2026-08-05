## Fase 4 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las comprobaciones de [[Fase_4.8.a_Verificacion]], **vuelve allí**. Guardar ahora sería fijar un estado que no sabes si es bueno.
>
> Y en esta fase eso significa algo muy concreto: **si el dominio se anunció en la tarjeta equivocada y tomas la instantánea, ese fallo se queda guardado.** Cada vez que restaures, volverá — y seguirá sin dar error.

---

## **1 · TOMA LA INSTANTÁNEA `Fase 4 terminada`**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```

En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 4 terminada`**.

Por comando, si el botón no aparece:
```
VBoxManage snapshot "UbuntuServer" take "Fase 4 terminada"
```

Y comprueba que se ha creado:
```
VBoxManage snapshot "UbuntuServer" list
```

- **✅ Bien:** aparece toda la cadena — `Sistema base`, `Fase 1 terminada`, `Fase 2 terminada`, `Fase 3 terminada` y la nueva.

> [!info] 🌳 Ya tienes un árbol de instantáneas, y eso tranquiliza
> Cada fase cuelga de la anterior. **Restaurar una de atrás NO borra las de delante:** puedes volver a la Fase 3, mirar algo, y regresar aquí.
>
> En esta fase te va a hacer falta de verdad. El [[Fase_4.7_Resolucion_Problemas#E3 · El aprovisionamiento falló a medias y quiero repetirlo|caso E3]] dice exactamente eso: si el aprovisionamiento se corta a medias, **no lo repares a mano** — restaura `Fase 3 terminada` y empieza de cero.

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper el dominio a propósito**. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, qué es un UUID y qué **no** conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

## **2 · LA COPIA DE SEGURIDAD EN TU DISCO EXTERNO**

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> Las instantáneas **viven dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ellas**.
>
> Y a estas alturas ya no es media hora de trabajo: son **cuatro fases**.

### **2A — Exporta la máquina**

**Es el mismo procedimiento de la Fase 1.** Con la VM **apagada**:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda.

> [!tip] 💡 Si no recuerdas alguna pantalla
> Lo tienes paso a paso en [[Fase_1.8.b_Punto_de_Control]], incluido **por qué se marca el manifiesto** y **por qué la máquina tiene que estar apagada** para aparecer en la lista.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_4\B2-F4-aprovisionamiento-del-dominio.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

### **2B — Dónde va y cómo se llama**

```
SOR/
└── Bloque_2/
    └── Fases/
        ├── Fase_1/  B2-F1-infraestructura-virtual.ova
        ├── Fase_2/  B2-F2-purga-y-preparacion.ova
        ├── Fase_3/  B2-F3-conectividad-vpn.ova
        └── Fase_4/  B2-F4-aprovisionamiento-del-dominio.ova
```

**El nombre y la ruta no son orientativos.** Ya llevas cuatro copias: la estructura es lo único que te dejará encontrar la que buscas.

### **2C — Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño**. Debe rondar los 6-9 GB — más que las anteriores, porque el dominio añade su base de datos.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.

> [!question] 🔮 Esta copia es la primera que vale de verdad
> Hasta ahora, si perdías el servidor, rehacer las fases 1 a 3 eran comandos que se pegan. **Un dominio no.** Aquí hay una base de datos LDAP, un reino Kerberos y unos registros DNS que no se reconstruyen copiando y pegando.
>
> **A partir de esta fase, perder la máquina sin copia significa repetir el curso entero.**

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff`, **grabándolo**.
- [ ] 💾 Instantánea **`Fase 4 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **toda la cadena**.
- [ ] 💿 **`B2-F4-aprovisionamiento-del-dominio.ova`** exportado a `SOR/Bloque_2/Fases/Fase_4/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (6-9 GB).
- [ ] Todo ello grabado en el vídeo **`B2 · F4 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.8.a_Verificacion]] | [[Fase_4]] | [[Fase_4.9_Preguntas]] |
