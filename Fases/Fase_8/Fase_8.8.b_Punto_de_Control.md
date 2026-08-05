## Fase 8 · Apartado 8.b — 💾 Punto de control y copia de seguridad

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Después de verificar** en el apartado 8.a, con la grabación aún en marcha.

---

> [!danger] 🛑 Requisito: la verificación del 8.a en verde
> Y en particular **las siete pruebas de la matriz** del punto 5. Si `shinnosuke.nohara` ve `contabilidad`, o `misae.nohara` ve `rrhh`, o `masao.sato` puede borrar una factura, **tienes un fallo de la Fase 7 sin arreglar**.
>
> No lo guardes dentro de la instantánea: cada vez que restaures, volverá.

> [!warning] ⚠️ Esta fase tiene DOS máquinas, y hay que guardar las dos
> Hasta ahora todas las instantáneas eran del servidor. **Aquí el trabajo está en el cliente Windows**, pero el conjunto solo funciona si las dos máquinas están en el estado correcto **a la vez**.
>
> Un cliente unido al dominio y un servidor restaurado a antes del dominio **no se entienden**: la relación de confianza se rompe y hay que volver a unir el equipo.

---

## **1 · APAGA LAS DOS MÁQUINAS, EN ESTE ORDEN**

**Primero el cliente Windows.** Menú Inicio → Apagar.

**Después el servidor Ubuntu:**
```bash
sudo poweroff
```

> [!info] 🎓 Por qué en ese orden
> Es el orden de un apagado real: **primero los clientes, después la infraestructura.** Si apagas el controlador de dominio con clientes conectados, esos clientes se quedan colgados esperando respuestas que no llegan.
>
> Para encender, al revés: **primero el servidor, y cuando esté arrancado del todo, el cliente.** Si el cliente arranca sin dominio disponible, tirará de credenciales en caché y algunas cosas no funcionarán hasta el siguiente inicio de sesión.
>
> **Este orden es el mismo en un centro de datos de verdad.** Anótalo.

> [!danger] 🛑 Las dos VMs, APAGADAS DEL TODO. No "estado guardado"
> No vale cerrar la ventana eligiendo **`Guardar el estado de la máquina`** en ninguna de las dos.
>
> **Por qué, y en esta fase es literal:** una instantánea con la máquina encendida guarda **el contenido de la RAM**, y con ella **el reloj congelado**. Al restaurarla dentro de un mes, la máquina despierta creyendo que sigue siendo hoy.
>
> Y **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase**. Restaurarías un dominio intacto, unas credenciales correctas, y ningún usuario podría entrar — con el mensaje *"El nombre de usuario o la contraseña son incorrectos"* que acabas de aprender a diagnosticar en el [[Fase_8.7_Resolucion_Problemas#E3 · Relacion de confianza o credenciales incorrectas|caso E3]].
>
> **No es teoría: es exactamente el fallo que has estudiado en esta fase.** Compruébalo:
> ```
> VBoxManage snapshot "UbuntuServer" list --details
> VBoxManage snapshot "Windows11" list --details
> ```

## **2 · TOMA LAS DOS INSTANTÁNEAS**

Con las dos VMs apagadas, en VirtualBox:

**Cliente:** selecciona la VM de Windows → `Instantáneas` → `Tomar` → **`Fase 8 terminada`**

**Servidor:** selecciona `UbuntuServer` → `Instantáneas` → `Tomar` → **`Fase 8 terminada`**

Por comando:
```
VBoxManage snapshot "Windows11" take "Fase 8 terminada"
VBoxManage snapshot "UbuntuServer" take "Fase 8 terminada"
```

Y comprueba las dos:
```
VBoxManage snapshot "Windows11" list
VBoxManage snapshot "UbuntuServer" list
```

> [!important] 🤝 Las dos instantáneas son una pareja, y hay que tratarlas así
> **Si algún día restauras una, restaura la otra.** Volver el servidor a la Fase 8 con el cliente en un estado posterior —o al revés— rompe la relación de confianza entre los dos.
>
> Anota en tu entrada de apuntes que **estas dos instantáneas van juntas**. Dentro de tres meses no te acordarás.

## **3 · LA COPIA DE SEGURIDAD**

### **3A — Exporta las dos máquinas**

Con las VMs **apagadas**, `Archivo` → `Exportar servicio virtualizado…` para cada una.

O por comando:
```
VBoxManage export "UbuntuServer" --output "E:\SOR\Bloque_2\Fases\Fase_8\B2-F8-servidor.ova"
VBoxManage export "Windows11" --output "E:\SOR\Bloque_2\Fases\Fase_8\B2-F8-cliente-windows.ova"
```
*(Cambia `E:` por la letra de tu disco externo.)*

> [!warning] ⏱️ El cliente Windows es GRANDE
> Bastante más que el servidor: un Windows 11 instalado ocupa lo suyo. Cuenta con que esta exportación tarde, y **comprueba antes que te queda sitio en el disco externo**.
>
> Arranca la exportación **grabando**, pausa mientras trabaja, y reanuda para enseñar **los ficheros ya creados**.

### **3B — Dónde van y cómo se llaman**

```
SOR/
└── Bloque_2/
    └── Fases/
        ├── Fase_1/  …
        ├── …
        ├── Fase_7/  B2-F7-seguridad-avanzada.ova
        └── Fase_8/  B2-F8-servidor.ova
                     B2-F8-cliente-windows.ova
```

**Dos ficheros en la carpeta de la Fase 8.** Es la única fase con dos, y tiene su motivo: es la única con dos máquinas.

### **3C — Comprueba que existen de verdad**

Abre la carpeta y **mira los dos tamaños**. Si alguno es sospechosamente pequeño, la exportación se cortó.

> [!question] 🔮 Esta es la copia que de verdad importa conservar
> Es el **proyecto entero terminado**: servidor y cliente, dominio, identidades, almacenamiento, seguridad e integración. Ocho fases.
>
> Si algún día tienes que borrar copias para hacer sitio, **esta es la última que se toca.**

---

### ✅ Checklist de este apartado

- [ ] Cliente Windows apagado **primero**, servidor **después**.
- [ ] Las dos VMs **apagadas del todo**, no en "estado guardado".
- [ ] 💾 Instantánea **`Fase 8 terminada`** del **cliente**.
- [ ] 💾 Instantánea **`Fase 8 terminada`** del **servidor**.
- [ ] Las dos comprobadas con `VBoxManage snapshot … list`.
- [ ] Comprobado que **ninguna arrastra estado de RAM** (`list --details`).
- [ ] Anotado en la entrada que **las dos instantáneas van en pareja**.
- [ ] 💿 **`B2-F8-servidor.ova`** y **`B2-F8-cliente-windows.ova`** en `SOR/Bloque_2/Fases/Fase_8/`.
- [ ] Tamaños comprobados.
- [ ] Todo ello grabado en el vídeo **`B2 · F8 · Punto de control`**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.8.a_Verificacion]] | [[Fase_8]] | [[Fase_8.9_Preguntas]] |
