## Fase 1 · Apartado 6.b — 🔌 Procedimiento — La Red del Laboratorio

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Con el ordenador delante.** Los dos adaptadores y la red privada `10.10.10.0/24`. Es **una entrega**: ~8-10 min

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~45 min |
> | **Entrada de apuntes** | `b2-1.2-la-red-del-laboratorio.md` |
> | **Vídeo** | `B2 · F1 · La red del laboratorio` · ~8-10 min |
>
> Las obligaciones de grabación están en [[Fase_1.3_Obligaciones_Grabacion]]. La teoría que necesitas, en el bloque *"Las redes virtuales de VirtualBox"* de [[Fase_1.5_Fundamento_Teorico]].

---

> [!danger] 🧭 La regla de oro de esta sub-fase
> **Identifica la red sólo-anfitrión por su DIRECCIÓN IP, nunca por su nombre.**
>
> Los nombres cambian según el sistema operativo del anfitrión y según cuántas redes hayas creado antes:
> - En **Mac y Linux** se llaman `vboxnet0`, `vboxnet1`…
> - En **Windows** se llaman `VirtualBox Host-Only Ethernet Adapter`, y si ya existía una, la siguiente es `#2`, `#3`…
>
> Si tu equipo ya tenía VirtualBox instalado, **es muy probable que acabes con dos redes sólo-anfitrión**. Se parecen tanto que enchufar la VM a la equivocada es facilísimo — y el fallo no se nota hasta la 1.4, cuando el ping no responde y todo *parece* estar bien configurado.
>
> Así que en cada pantalla, mira la **IP**, no el nombre.

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes.
> 2. Léete los cuatro pasos.
> 3. **Comprueba que la VM está APAGADA.** Con la VM encendida o guardada, VirtualBox no deja tocar la red.
>
> Cuando lo tengas: arranca la grabación y preséntate.

> [!example] Paso 1: Crear y configurar la red del laboratorio
> Esto se hace en la ventana principal de VirtualBox, **no** en la configuración de la VM.
>
> 1. Menú **`Archivo`** → **`Herramientas`** → **`Administrador de red`**.
> 2. Pestaña **`Redes sólo-anfitrión`**.
> 3. Mira lo que hay:
>    - Si la lista está **vacía**, pulsa **`Crear`** (el icono `+`).
>    - Si ya hay una (probablemente con `192.168.56.1`), **crea otra igualmente** con `+`. No reutilices la existente: puede estar en uso por otras máquinas del equipo.
> 4. Selecciona la red nueva y pulsa **`Propiedades`**.
> 5. Pestaña **`Adaptador`**:
>    - Marca **`Configurar adaptador manualmente`**
>    - **Dirección IPv4:** `10.10.10.1`
>    - **Máscara de red IPv4:** `255.255.255.0`
> 6. Pestaña **`Servidor DHCP`**: **desmarca** `Habilitar servidor`.
> 7. **`Aplicar`**.
> 8. **Apunta el nombre exacto** que muestra esa red. Lo necesitas en el Paso 2 y no vale el de al lado.
>
> > [!warning] ⚠️ La máscara viene mal por defecto
> > VirtualBox crea la red con máscara **`255.255.0.0`** (un `/16`). Nuestro laboratorio es `/24`. **Cámbiala a `255.255.255.0`** en el paso 5, y comprueba después que se ha guardado: es un campo que se resiste y a veces revierte al valor anterior si no pulsas `Aplicar`.

> [!example] Paso 2: Asignar los dos adaptadores a la VM
> Ahora sí, con la VM seleccionada → **`Configuración`** → **`Red`**.
>
> Verás pestañas: `Adaptador 1`, `Adaptador 2`, `Adaptador 3`, `Adaptador 4`. Las tres últimas parecen vacías porque están **deshabilitadas**, no porque no existan.
>
> **Adaptador 1:**
> 1. Marca **`Habilitar adaptador de red`**.
> 2. En **`Conectado a`**, selecciona **`NAT`**.
> 3. El resto, por defecto.
>
> **Adaptador 2:**
> 1. Haz clic en la **pestaña `Adaptador 2`**.
> 2. Marca **`Habilitar adaptador de red`** — hasta que no la marques, todo lo demás está en gris.
> 3. En **`Conectado a`**, selecciona **`Adaptador sólo-anfitrión`**.
> 4. En **`Nombre`**, elige **la red que apuntaste en el Paso 1** (la del `10.10.10.1`).
> 5. Despliega **`Avanzadas`** y comprueba que **`Cable conectado`** está marcado. VirtualBox permite tener el adaptador habilitado con el cable "desenchufado", y entonces todo parece bien pero no pasa tráfico.
> 6. **`Aceptar`**.

> [!example] Paso 3: Verificar desde tu ordenador ANTES de instalar nada
> Este paso no existía en versiones anteriores del manual y se pagó caro. **Hazlo ahora**, que corregir aquí cuesta dos minutos y corregirlo en la 1.3 cuesta una tarde.
>
> **En Windows**, abre `cmd`:
> ```
> ipconfig
> ```
> **En Mac o Linux**, abre `Terminal`:
> ```
> ifconfig | grep 10.10.10
> ```
>
> Busca un adaptador con la dirección **`10.10.10.1`** y **máscara `255.255.255.0`**.
>
> - **Si aparece con esa IP y esa máscara** → la red del laboratorio existe en tu ordenador. Sigue.
> - **Si aparece con máscara `255.255.0.0`** → vuelve al Paso 1.6 y corrígela.
> - **Si no aparece** → la red no se creó. Repite el Paso 1.
> - **Si aparecen VARIAS** con `10.10.10.1` o parecidas → tienes redes duplicadas. Quédate con una y borra el resto en el Administrador de red.
>
> Y ahora hazte ping a ti mismo:
> ```
> ping 10.10.10.1
> ```
> Debe responder. Estás comprobando que **tu propio ordenador** tiene un pie dentro de la red del laboratorio. Si esto no responde, no sigas: nada de lo que viene después funcionará.

> [!question] 🔬 Antes de cerrar la grabación
> Contesta en el vídeo, con tus palabras:
> 1. ¿Por qué tu servidor necesita **dos** tarjetas y no una?
> 2. Si conectaras el Adaptador 2 en modo **Red interna** en lugar de **sólo-anfitrión**, ¿podrías hacerle ping desde tu ordenador? Razónalo.
> 3. Tu red es `10.10.10.0/24`. **Sin usar ninguna herramienta**, di: dirección de red, broadcast, cuántos equipos caben, y cuál es la primera y la última dirección utilizable. *(En la 1.4 lo comprobarás contra una API — no hagas trampa ahora.)*

---

---

### ✅ Checklist de esta parte

- [ ] Red sólo-anfitrión creada con IP `10.10.10.1` y máscara `255.255.255.0`.
- [ ] Servidor DHCP **deshabilitado** en esa red.
- [ ] Nombre exacto de la red anotado.
- [ ] Adaptador 1 habilitado en modo **NAT**.
- [ ] Adaptador 2 habilitado en modo **sólo-anfitrión**, apuntando a la red del `10.10.10.1`.
- [ ] `Cable conectado` marcado en Avanzadas del Adaptador 2.
- [ ] `ipconfig` / `ifconfig` en tu ordenador muestra el `10.10.10.1` con máscara `/24`.
- [ ] `ping 10.10.10.1` responde desde tu propio ordenador.

---

> ¿Algo no ha salido? → [[Fase_1.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio (casos `E1` a `E13`), no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6.a_Procedimiento_Maquina_Virtual]] | [[Fase_1]] | [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]] |
