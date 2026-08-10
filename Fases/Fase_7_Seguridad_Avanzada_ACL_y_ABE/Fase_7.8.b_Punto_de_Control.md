## Fase 7 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Si no has pasado las comprobaciones de [[Fase_7.8.a_Verificacion]], **vuelve allí**.
>
> Y en esta fase hay un requisito que no admite excepciones: **`sudo testparm` tiene que decir `Loaded services file OK`**. Si `smb.conf` está mal, el próximo arranque deja el servidor **sin dominio**, no solo sin carpetas compartidas.

---

## **1 · TOMA LA INSTANTÁNEA `Fase 7 terminada`**

Con la grabación todavía en marcha, apaga la máquina:

```bash
sudo poweroff
```

> [!danger] 🛑 La VM tiene que estar APAGADA DEL TODO. No "guardada"
> No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`**. Tiene que apagarse de verdad, con `sudo poweroff` o con `Apagar por ACPI`.
>
> **Por qué:** una instantánea tomada con la máquina encendida guarda también **el contenido de la RAM**, y con ella **el reloj congelado**. Al restaurarla, el servidor despierta creyendo que sigue siendo hoy — y **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**.
>
> **Y en esta fase importa el doble:** la Fase 8 va a unir un cliente Windows al dominio, y esa unión es puro Kerberos. Restaurar una instantánea con el reloj congelado te daría un *"El nombre de usuario o la contraseña son incorrectos"* con la contraseña correcta.
>
> Compruébalo:
> ```
> VBoxManage snapshot "UbuntuServer" list --details
> ```

En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 7 terminada`**.

Por comando, si el botón no aparece:
```
VBoxManage snapshot "UbuntuServer" take "Fase 7 terminada"
```

Y comprueba que se ha creado:
```
VBoxManage snapshot "UbuntuServer" list
```

- **✅ Bien:** aparece toda la cadena, desde `Sistema base` hasta la nueva.

> [!important] 💾 Esta instantánea es la más valiosa de todo el proyecto
> Es el **servidor terminado**. Dominio, identidades, almacenamiento con cuotas y seguridad avanzada, todo montado y verificado.
>
> A partir de aquí, la Fase 8 trabaja sobre un **cliente Windows nuevo**. Si algo sale mal allí, este es el punto al que vuelves — y volver aquí significa no tener que rehacer nada de lo que llevas hecho.

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper la seguridad a propósito**, incluido el `smb.conf` que sostiene el dominio. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, qué es un UUID y qué **no** conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

## **2 · LA COPIA DE SEGURIDAD EN TU DISCO EXTERNO**

> [!danger] 🛑 Si solo vas a guardar una copia de todo el proyecto, que sea esta
> Las instantáneas **viven dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ellas**.
>
> Y esto ya no son quince minutos de trabajo: son **siete fases**, con un dominio, unas identidades y una configuración de seguridad que no se reconstruyen copiando comandos.

### **2A — Exporta la máquina**

Con la VM **apagada**:

`Archivo` → **`Exportar servicio virtualizado…`** → selecciona `UbuntuServer` → formato **`Open Virtualization Format 2.0`** → **marca el archivo de manifiesto** → guarda.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_7\B2-F7-seguridad-avanzada.ova"
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
        ├── Fase_5/  B2-F5-gestion-de-identidades.ova
        ├── Fase_6/  B2-F6-almacenamiento-virtual.ova
        └── Fase_7/  B2-F7-seguridad-avanzada.ova
```

**El nombre y la ruta no son orientativos.** Ya llevas siete copias: la estructura es lo único que te dejará encontrar la que buscas.

### **2C — Comprueba que existe de verdad**

Abre la carpeta del disco y **mira el tamaño**. Debe ser similar al de la Fase 6 — la seguridad no ocupa espacio, son metadatos.

> [!warning] ⏱️ Tarda varios minutos. Pausa la grabación
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **el fichero ya creado en el disco**.

> [!question] 🔮 Si tienes que hacer sitio en el disco externo
> La regla: conserva siempre **`Sistema base`**, la **Fase 4** *(el dominio)* y **esta, la Fase 7** *(el servidor completo)*. Las intermedias son las prescindibles.
>
> Decidir qué copia se borra es parte del trabajo de un administrador. Anota en tu entrada el criterio que hayas usado.

---

### ✅ Checklist de este apartado

- [ ] `sudo testparm` → **`Loaded services file OK`** antes de apagar.
- [ ] `samba-ad-dc` en `active` antes de apagar.
- [ ] VM apagada con `sudo poweroff` —**apagada, no "estado guardado"**— y grabándolo.
- [ ] 💾 Instantánea **`Fase 7 terminada`** tomada.
- [ ] `VBoxManage snapshot "UbuntuServer" list` muestra **toda la cadena**.
- [ ] Comprobado que la instantánea **no arrastra estado de RAM** (`list --details`).
- [ ] 💿 **`B2-F7-seguridad-avanzada.ova`** exportado a `SOR/Bloque_2/Fases/Fase_7_Seguridad_Avanzada_ACL_y_ABE/` de tu disco externo.
- [ ] Tamaño del fichero comprobado.
- [ ] Todo ello grabado en el vídeo **`B2 · F7 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.8.a_Verificacion]] | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | [[Fase_7.9_Preguntas]] |
