## Fase 5 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las comprobaciones de [[Fase_5.8.a_Verificacion]], **vuelve allí**. Guardar ahora sería fijar un estado que no sabes si es bueno.
>
> Y en esta fase eso significa algo muy concreto: **si los UID no son los tuyos y tomas la instantánea, ese fallo se queda guardado.** Cada vez que restaures, volverá — y seguirá sin dar error hasta la Fase 7.

---

## **1 · TOMA LA INSTANTÁNEA `Fase 5 terminada`**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```

> [!danger] 🛑 La VM tiene que estar APAGADA DEL TODO. No "guardada"
> No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`**. Tiene que apagarse de verdad, con `sudo poweroff` o con `Apagar por ACPI`.
>
> **Por qué, y aquí no es una manía:** una instantánea tomada con la máquina encendida guarda también **el contenido de la RAM** — y con ella, **el reloj congelado**. Cuando la restaures dentro de tres semanas, el servidor despertará creyendo que sigue siendo hoy.
>
> **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase horario.** Restaurarías un punto de retorno en el que el dominio existe, los usuarios existen… y nadie puede autenticarse. Con un error que habla de tickets, no de relojes.
>
> **Cómo distinguirlas:** en el árbol de instantáneas de VirtualBox, las tomadas con la VM encendida llevan un icono distinto y arrastran un fichero `.sav` de varios cientos de MB. Compruébalo:
> ```
> VBoxManage snapshot "UbuntuServer" list --details
> ```

En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 5 terminada`**.

Por comando, si el botón no aparece:
```
VBoxManage snapshot "UbuntuServer" take "Fase 5 terminada"
```

Y comprueba que se ha creado:
```
VBoxManage snapshot "UbuntuServer" list
```

- **✅ Bien:** aparece toda la cadena — `Sistema base`, `Fase 1 terminada`, `Fase 2 terminada`, `Fase 3 terminada`, `Fase 4 terminada` y la nueva.

> [!info] 🌳 El árbol ya tiene seis niveles, y eso tranquiliza
> Cada fase cuelga de la anterior. **Restaurar una de atrás NO borra las de delante:** puedes volver a la Fase 4, mirar algo, y regresar aquí.
>
> En esta fase te puede hacer falta: el [[Fase_5.7_Resolucion_Problemas#E5 · addunixattrs da error de esquema LDAP|caso E5]] se resuelve **restaurando `Fase 3 terminada`** y rehaciendo el dominio, no parcheando a mano.

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper las identidades a propósito**. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, qué es un UUID y qué **no** conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

## **2 · LA COPIA DE SEGURIDAD EN TU DISCO EXTERNO**

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> Las instantáneas **viven dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ellas**.
>
> Y a estas alturas ya son **cinco fases**, con un dominio y sus identidades dentro.

### **2A — Exporta la máquina**

**Es el mismo procedimiento de la Fase 1.** Con la VM **apagada**:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda.

> [!tip] 💡 Si no recuerdas alguna pantalla
> Lo tienes paso a paso en [[Fase_1.8.b_Punto_de_Control]], incluido **por qué se marca el manifiesto** y **por qué la máquina tiene que estar apagada** para aparecer en la lista.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_5\B2-F5-gestion-de-identidades.ova"
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
        ├── Fase_4/  B2-F4-aprovisionamiento-del-dominio.ova
        └── Fase_5/  B2-F5-gestion-de-identidades.ova
```

**El nombre y la ruta no son orientativos.** Ya llevas cinco copias: la estructura es lo único que te dejará encontrar la que buscas.

### **2C — Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño**. Debe rondar los 6-9 GB, parecido al de la Fase 4: los usuarios ocupan muy poco, lo que pesa es el dominio.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.

---

### ✅ Checklist de este apartado

- [ ] VM apagada con `sudo poweroff` —**apagada, no "estado guardado"**— y grabándolo.
- [ ] 💾 Instantánea **`Fase 5 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **toda la cadena**.
- [ ] Comprobado que la instantánea **no arrastra estado de RAM** (`list --details`).
- [ ] 💿 **`B2-F5-gestion-de-identidades.ova`** exportado a `SOR/Bloque_2/Fases/Fase_5_Gestion_de_Identidades/` de tu disco externo.
- [ ] Tamaño del fichero comprobado (6-9 GB).
- [ ] Todo ello grabado en el vídeo **`B2 · F5 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.8.a_Verificacion]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.9_Preguntas]] |
