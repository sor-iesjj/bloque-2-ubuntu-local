## Fase 6 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6_Almacenamiento_Virtual_Cuotas]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las comprobaciones de [[Fase_6.8.a_Verificacion]], **vuelve allí**.
>
> Y en esta fase el requisito es más literal que nunca: **si `sudo mount -a` no está en silencio, apagar la máquina puede dejarla sin arrancar.** No es que guardes un fallo — es que el siguiente arranque falla.

---

## **1 · TOMA LA INSTANTÁNEA Fase 6 terminada**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```

> [!danger] 🛑 Este apagado es también una prueba
> En las fases anteriores, apagar era un trámite. **Aquí no.** Acabas de tocar `/etc/fstab`, y el siguiente arranque va a ejecutarlo de verdad.
>
> **Después de tomar la instantánea, enciende la máquina y comprueba que arranca** antes de dar la fase por cerrada:
> ```bash
> df -h | grep prueba
> ```
> Si arranca y los dos discos están montados **sin que hayas hecho nada**, el `fstab` es correcto. Esa es la prueba real, y ahora la puedes hacer sin miedo: tienes la instantánea justo antes.

> [!danger] 🛑 La VM tiene que estar APAGADA DEL TODO. No "guardada"
> No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`**. Tiene que apagarse de verdad, con `sudo poweroff` o con `Apagar por ACPI`.
>
> **Por qué:** una instantánea tomada con la máquina encendida guarda también **el contenido de la RAM**, y con ella **el reloj congelado**. Al restaurarla, el servidor despierta creyendo que sigue siendo hoy — y **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**. Tendrías un dominio intacto en el que nadie puede entrar.
>
> **Y en esta fase hay un motivo añadido:** con la RAM guardada, los discos quedan montados "en caliente". Restaurarías un estado en el que el montaje viene de la memoria, no del `fstab`, y **nunca sabrías si el `fstab` funciona**.
>
> Compruébalo:
> ```
> VBoxManage snapshot "UbuntuServer" list --details
> ```

En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 6 terminada`**.

Por comando, si el botón no aparece:
```
VBoxManage snapshot "UbuntuServer" take "Fase 6 terminada"
```

Y comprueba que se ha creado:
```
VBoxManage snapshot "UbuntuServer" list
```

- **✅ Bien:** aparece toda la cadena, desde `Sistema base` hasta la nueva.

> [!info] 🌳 Restaurar hacia atrás no borra lo de delante
> Cada fase cuelga de la anterior. Si el `fstab` te da problemas, **restaurar `Fase 5 terminada` te devuelve un servidor que arranca** — y es la salida del [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]] cuando no consigues arreglarlo a mano.

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper el almacenamiento a propósito**, incluido el `fstab`. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, qué es un UUID y qué **no** conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

## **2 · LA COPIA DE SEGURIDAD EN TU DISCO EXTERNO**

> [!danger] 🛑 Una copia que vive en el mismo sitio que el original NO es una copia
> Las instantáneas **viven dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ellas**.

### **2A — Exporta la máquina**

Con la VM **apagada**:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_6\B2-F6-almacenamiento-virtual.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

> [!warning] ⏱️ Esta exportación tarda MÁS que las anteriores
> Acabas de meter **10 GB de discos virtuales** dentro de la máquina. Aunque estén casi vacíos, el `.vdi` ha crecido y hay más que empaquetar.
>
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.

### **2B — Dónde va y cómo se llama**

```
SOR/
└── Bloque_2/
    └── Fases/
        ├── Fase_1/  B2-F1-infraestructura-virtual.ova
        ├── Fase_2/  B2-F2-purga-y-preparacion.ova
        ├── Fase_3/  B2-F3-conectividad-vpn.ova
        ├── Fase_4/  B2-F4-aprovisionamiento-del-dominio.ova
        ├── Fase_5/  B2-F5-gestion-de-identidades.ova
        └── Fase_6/  B2-F6-almacenamiento-virtual.ova
```

**El nombre y la ruta no son orientativos.** Ya llevas seis copias: la estructura es lo único que te dejará encontrar la que buscas.

### **2C — Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño**. Será **mayor que el de la Fase 5** — los discos virtuales pesan aunque estén vacíos.

> [!question] 🔮 ¿Y si el disco externo se te queda corto?
> Va a pasar: seis copias de una VM ocupan mucho. **No borres las antiguas a lo loco.** Si tienes que hacer sitio, la regla es conservar siempre **`Sistema base`, la Fase 4** *(el dominio, lo que no se reconstruye copiando comandos)* **y la última**.
>
> Decidir qué copia se borra es parte del trabajo de un administrador. Anótalo en tu entrada con el criterio que hayas usado.

---

### ✅ Checklist de este apartado

- [ ] `sudo mount -a` **en silencio** antes de apagar.
- [ ] VM apagada con `sudo poweroff` —**apagada, no "estado guardado"**— y grabándolo.
- [ ] 💾 Instantánea **`Fase 6 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **toda la cadena**.
- [ ] 🔴 **Arranque comprobado después:** la máquina enciende y `df -h` muestra los dos discos **sin tocar nada**.
- [ ] 💿 **`B2-F6-almacenamiento-virtual.ova`** exportado a `SOR/Bloque_2/Fases/Fase_6_Almacenamiento_Virtual_Cuotas/` de tu disco externo.
- [ ] Tamaño del fichero comprobado.
- [ ] Todo ello grabado en el vídeo **`B2 · F6 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.8.a_Verificacion]] | [[Fase_6_Almacenamiento_Virtual_Cuotas]] | [[Fase_6.9_Preguntas]] |
