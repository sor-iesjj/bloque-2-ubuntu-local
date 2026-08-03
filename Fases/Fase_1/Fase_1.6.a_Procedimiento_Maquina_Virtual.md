## Fase 1 · Apartado 6.a — 🖥️ Procedimiento — La Máquina Virtual

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Con el ordenador delante.** Instalar VirtualBox, descargar la ISO y crear la VM bien dimensionada. Es **una entrega**: ~6-8 min

---

> [!abstract] 📦 Esta parte es una entrega
> | | |
> | :--- | :--- |
> | **Tiempo** | ~40 min |
> | **Entrada de apuntes** | `v1-fase-1-1-la-maquina-virtual.md` |
> | **Vídeo** | `V1 · Fase 1.1 — La Máquina Virtual` · ~6-8 min |
>
> Las obligaciones de grabación están en [[Fase_1.3_Obligaciones_Grabacion]]. La teoría que necesitas, en el bloque *"Virtualización: el hipervisor y tu hardware"* de [[Fase_1.5_Fundamento_Teorico]].

---

> [!danger] ⚠️ LÉEME ANTES: permisos de administrador en el equipo del aula
> Instalar VirtualBox requiere permisos de administrador **del sistema operativo anfitrión**.
> - **Si ya está instalado** (mira el menú de aplicaciones o pregunta al profesor): salta al Paso 2.
> - **Si no lo está y no tienes permisos:** esta práctica **no es viable en ese equipo**. No intentes saltarte los permisos ni usar instaladores "portables" no autorizados. Avísame: lo instala el departamento en la imagen del aula, o se usa un equipo personal.

> [!example] 🎬 Antes de empezar (sin grabar todavía)
> 1. Crea vacía la entrada de apuntes de esta sub-fase.
> 2. Léete los tres pasos enteros.
> 3. Ten OBS listo, con pantalla y micrófono comprobados.
>
> Cuando lo tengas: **arranca la grabación y preséntate.** A partir de ahí, todo queda grabado.

> [!example] Paso 1: Instalar VirtualBox (solo si no está ya)
> 1. Entra en la web oficial: `virtualbox.org` → **Downloads**.
> 2. Descarga el instalador de tu sistema operativo.
> 3. Ejecútalo con permisos de administrador y acepta las opciones por defecto.
> 4. Ábrelo. Si ves la ventana del *VirtualBox Manager* con la lista de máquinas vacía, ha ido bien.
>
> > [!tip] 💡 Qué versión
> > La estable más reciente que ofrezca la web oficial. No hace falta anotar el número exacto.

> [!example] Paso 2: Descargar la ISO de Ubuntu Server 26.04 LTS
> 1. Entra en `ubuntu.com/download/server`.
> 2. Descarga **Ubuntu Server 26.04 LTS**. *LTS* significa **Long Term Support**: recibe actualizaciones de seguridad durante años, y es lo que se usa siempre en producción.
> 3. Guarda el `.iso` en una carpeta que recuerdes. Pesa 2-3 GB.
>
> > [!warning] ⚠️ "Server", no "Desktop"
> > Ubuntu **Desktop** trae escritorio gráfico y está pensado para uso personal. Ubuntu **Server** no tiene entorno gráfico (*headless*) y está pensado para máquinas que dan servicio. Comprueba que pone **Server** en el nombre del fichero.

> [!example] Paso 3: Crear la máquina virtual
> Con VirtualBox abierto, pulsa **`Nueva`** y rellena:
>
> | Campo | Valor | Por qué |
> | :--- | :--- | :--- |
> | **Nombre** | `UbuntuServer` | Coherencia con V2/V3 y con el resto del manual |
> | **Carpeta** | La que sugiera VirtualBox | Evita rutas con espacios o caracteres raros |
> | **Imagen ISO** | El `.iso` del Paso 2 | Es el "disco de instalación" que arrancará la VM |
> | **⚠️ `Omitir instalación desatendida`** | **MARCADA** | **Lee el aviso de abajo. Es el paso más importante de toda la Fase 1.** |
> | **Tipo** | `Linux` | — |
> | **Versión** | `Ubuntu (64-bit)` | Ubuntu Server 26.04 es de 64 bits |
> | **Memoria base (RAM)** | `2048 MB` | Ver la nota de dimensionado |
> | **Procesadores** | `2 vCPU` | Suficiente, y no bloquea el host |
> | **Tamaño de disco** | `20 GB`, con **`Preasignar tamaño completo` SIN marcar** | Margen para sistema, Samba y prácticas, creciendo según se usa |
>
> Revisa el resumen y pulsa **`Finalizar`**.

> [!danger] ⚠️ MARCA `Omitir instalación desatendida`. Si no, arrastrarás fallos durante horas.
> En cuanto seleccionas la ISO, **VirtualBox 7.x reconoce que es Ubuntu y se ofrece a instalarlo él solo**: te pide un usuario y una contraseña en el propio asistente, arranca la VM e instala el sistema entero sin que tú toques nada.
>
> Suena cómodo. Y es exactamente lo que no queremos, porque **VirtualBox se salta la Fase 1.3 completa** y decide por ti. Esto es lo que ocurre de verdad cuando se deja marcada (probado, no teórico):
>
> | Lo que VirtualBox decide por su cuenta | La consecuencia que te encuentras después |
> | :--- | :--- |
> | El teclado, que deja en **inglés** | No puedes escribir `@` ni `;`. Y tu contraseña puede no ser la que crees |
> | La red: deja las **dos tarjetas en DHCP** | Tu servidor se queda **sin la IP fija `10.10.10.10`**, y la Fase 4 no funciona sin ella |
> | El usuario, que **no será `boochan`** | Todos los comandos del manual dejan de encajar |
> | **No instala OpenSSH** | No puedes entrar desde tu terminal: te toca trabajar en la ventana de VirtualBox |
>
> Un solo *checkbox* sin marcar genera cuatro problemas que aparecen **más tarde y por separado**, cuando ya no los relacionas con su causa. Ese es el tipo de fallo más caro que existe.
>
> Y hay un motivo de fondo: **instalar sistemas operativos en red es literalmente el `RA.01` de este módulo.** Es lo que se evalúa. No se delega en un asistente.
>
> **Dónde está:** primera página del asistente, **`Nombre y sistema operativo`**, justo debajo del selector de la ISO. Se llama `Omitir instalación desatendida` (*Skip Unattended Installation*). Al marcarla verás que **desaparece** la página siguiente, la que pedía usuario y contraseña: ya no hace falta, porque esos datos los pondrás tú en la 1.3.
>
> 🎥 **Que se te vea marcarla en el vídeo.**

> [!note] 💡 Sobre el disco: ¿y el "VDI de asignación dinámica"?
> Otros manuales hablan de elegir **VDI** y **asignación dinámica**. En el asistente de VirtualBox 7.x **esas opciones ya no aparecen**: solo hay el tamaño y una casilla `Preasignar tamaño completo`. No te has saltado nada — VirtualBox ya decide:
> - **VDI** es el formato por defecto (VMDK y VHD solo se eligen si necesitas abrir el disco con VMware o Hyper-V).
> - **Dejar `Preasignar tamaño completo` sin marcar ES la asignación dinámica.** Marcarla reservaría los 20 GB de golpe aunque Ubuntu use 6.
>
> **🔬 Compruébalo tú.** Al terminar de crear la VM, abre el explorador de archivos y busca la carpeta de la máquina (`VirtualBox VMs/UbuntuServer/`). Dentro está `UbuntuServer.vdi`. **Mira lo que ocupa y anótalo.** Dice tener 20 GB y ocupa unos pocos MB: eso es la asignación dinámica, vista con tus ojos en vez de creída.
>
> Vuelve a mirarlo al acabar la Fase 1.3, con Ubuntu ya instalado, y anota los dos tamaños.

---

---

### ✅ Checklist de esta parte

- [ ] VirtualBox instalado o verificado.
- [ ] ISO de Ubuntu Server 26.04 LTS descargada (comprobado que pone **Server**).
- [ ] Casilla **`Omitir instalación desatendida`** marcada.
- [ ] VM `UbuntuServer` creada: 2048 MB, 2 vCPU, 20 GB sin preasignar.
- [ ] Tamaño real del `.vdi` anotado en la entrada.

---

> ¿Algo no ha salido? → [[Fase_1.7_Resolucion_Problemas]]

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.5_Fundamento_Teorico]] | [[Fase_1]] | [[Fase_1.6.b_Procedimiento_Red_Laboratorio]] |
