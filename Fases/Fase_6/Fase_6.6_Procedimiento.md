## Fase 6 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b2-f6-almacenamiento-virtual.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Creación de los Puntos de Montaje
> Antes de crear los discos virtuales, necesitamos las carpetas donde se "conectarán". Creamos las carpetas para las dos unidades de almacenamiento del proyecto:
> ```bash
> sudo mkdir -p /srv/samba/prueba1
> sudo mkdir -p /srv/samba/prueba3
> ```
>
> > [!tip] 💡 ¿Qué hace `-p`?
> > El parámetro `-p` (de *parents*) crea todas las carpetas del camino que no existan. Si `/srv/samba/` no existiera, lo crearía también automáticamente. Sin `-p`, daría error si la carpeta padre no existe.

> [!example] Paso 2: Creación de los Archivos de Disco Virtual
> Creamos dos archivos que actuarán como discos duros independientes:
>
> > [!info] 📚 Diccionario de Comandos: Para entender cómo funciona el comando `dd` creando discos virtuales, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Disco virtual para "prueba1" (carpeta compartida general)
> sudo dd if=/dev/zero of=/samba_p1.img bs=1M count=5120
>
> # Disco virtual para "prueba3" (carpeta protegida con permisos en la Fase 7)
> sudo dd if=/dev/zero of=/samba_p3.img bs=1M count=5120
> ```
> Este comando tarda aproximadamente **1-2 minutos** por cada disco. Verás el progreso en pantalla.
>
> > [!caution] ⚠️ Comprueba el disco virtual (.vdi) de la VM antes de empezar
> > Estos dos archivos de 5GB se guardan dentro del disco duro virtual (.vdi/.vmdk) que VirtualBox asignó a tu máquina en la Fase 1. Si el disco de la VM tiene poco espacio libre, `dd` fallará a mitad de escritura con "No space left on device". Verifica antes con `df -h /` que tienes al menos 11 GB libres.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`if=/dev/zero`:** El origen de los datos es un generador infinito de ceros.
> > - **`of=/samba_p1.img`:** El archivo de destino que se convertirá en nuestro disco.
> > - **`bs=1M`:** "Block Size". Escribimos en bloques de 1 Megabyte.
> > - **`count=5120`:** Multiplicamos 1MB x 5120 para obtener exactamente 5 Gigabytes.

> [!example] Paso 3: Formateo y Preparación
> Ahora le damos "formato" a cada archivo para que Linux pueda guardar archivos dentro:
> ```bash
> # Formateamos el disco de prueba1
> sudo mkfs.ext4 /samba_p1.img
>
> # Formateamos el disco de prueba3
> sudo mkfs.ext4 /samba_p3.img
> ```

> [!example] Paso 4: Montaje Persistente (fstab)
> Editamos la tabla de discos del sistema para que ambos discos se monten automáticamente al reiniciar:
> ```bash
> sudo nano /etc/fstab
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Añade estas dos líneas **al final del archivo** (sin borrar nada de lo que ya hay):
> ```
> /samba_p1.img  /srv/samba/prueba1  ext4  loop,defaults  0  0
> /samba_p3.img  /srv/samba/prueba3  ext4  loop,defaults  0  0
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`). Ahora monta los discos sin necesidad de reiniciar:
> ```bash
> sudo mount -a
> ```
>
> > [!caution] ⚠️ La palabra `loop` es obligatoria
> > Si olvidas escribir `loop` en las opciones del fstab, Linux intentará tratar el archivo como una partición física real y el servidor **entrará en pánico al arrancar**. Comprueba dos veces que la has escrito.
>
> > [!important] 🪂 El Paracaídas Púrpura (Comprobación de Vida)
> > Ejecutar `sudo mount -a` es tu paracaídas. Este comando simula el arranque del servidor leyendo el archivo `fstab`. Si la terminal **no devuelve ningún texto** (silencio), ¡enhorabuena! Tu sintaxis es perfecta. Si devuelve **texto rojo o un aviso de error**, tienes un fallo tipográfico grave. **¡BAJO NINGÚN CONCEPTO REINICIES!** Vuelve a editar el `fstab` hasta que `sudo mount -a` no devuelva errores, o de lo contrario tu máquina virtual dejará de arrancar.

> [!example] Paso 5: Permisos de Acceso
> Asignamos los permisos correctos para que los usuarios del dominio puedan escribir en las carpetas:
> ```bash
> # prueba1: accesible por todos los usuarios del dominio
> sudo chown root:root /srv/samba/prueba1
> sudo chmod 777 /srv/samba/prueba1
>
> # prueba3: solo accesible por el grupo "policia" (lo protegeremos en la Fase 7)
> sudo chown root:policia /srv/samba/prueba3
> sudo chmod 2770 /srv/samba/prueba3
> ```
> > [!caution] ⚠️ Verifica que el grupo `policia` fue reconocido
> > Si el servicio `winbind` no estaba activo, el `chown` falla con `invalid group: 'policia'` y la carpeta queda mal configurada sin aviso visible. Compruébalo:
> > ```bash
> > ls -la /srv/samba/ | grep prueba3
> > ```
> > La columna de grupo debe mostrar `policia`, no `root`. Si muestra `root`, arranca winbind y repite:
> > ```bash
> > sudo systemctl enable winbind --now
> > sudo chown root:policia /srv/samba/prueba3
> > ```
>
> > [!tip] 💡 ¿Qué es el `chmod 2770`?
> > - **`2`:** Es el **bit setgid**. Hace que todos los archivos nuevos creados dentro de la carpeta hereden automáticamente el grupo `policia`, en lugar del grupo personal de quien lo creó. Así todos los archivos de la carpeta siempre pertenecen al grupo correcto.
> > - **`770`:** El propietario y el grupo tienen acceso total (rwx), pero el resto del mundo no tiene ningún acceso (---).

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.5_Fundamento_Teorico]] | [[Fase_6]] | [[Fase_6.7_Resolucion_Problemas]] |
