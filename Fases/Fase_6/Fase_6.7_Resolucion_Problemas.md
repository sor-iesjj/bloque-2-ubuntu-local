## Fase 6 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> No saltes a la solución. **La comprobación es la parte que te enseña a diagnosticar**, y es la que vas a necesitar el día que el fallo no esté en ninguna lista.

> [!danger] 🛑 Esta fase tiene DOS fallos serios, y son de tipos opuestos
> | | Cuál | Cómo se manifiesta |
> | :--- | :--- | :--- |
> | **El ruidoso** | [[#E1 · El servidor no arranca tras editar el fstab\|E1]] | El servidor **no arranca**. Imposible no verlo |
> | **El silencioso** | [[#E6 · Una carpeta pertenece a root y no a su departamento\|E6]] | Todo funciona. **La Fase 7 se cae** |
>
> El primero da miedo y se arregla en cinco minutos. El segundo no da miedo y cuesta una tarde. **Léete los dos.**

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| **El servidor no arranca tras tocar el fstab** | [[#E1 · El servidor no arranca tras editar el fstab\|E1]] 🔥 |
| `df -h` no muestra los discos de 5 GB | [[#E2 · df -h no muestra los discos\|E2]] |
| `wrong fs type` al montar | [[#E3 · wrong fs type al montar\|E3]] |
| `dd` falla: `No space left on device` | [[#E4 · dd falla por falta de espacio\|E4]] |
| `chown: invalid group: 'contabilidad'` | [[#E5 · invalid group contabilidad\|E5]] |
| **Todo va bien pero contabilidad es de `root`** | [[#E6 · Una carpeta pertenece a root y no a su departamento\|E6]] ⚠️ |
| Los ficheros nuevos no heredan el grupo | [[#E7 · Los ficheros nuevos no heredan el grupo\|E7]] |
| Tras reiniciar, los discos no están montados | [[#E8 · Tras reiniciar los discos no estan montados\|E8]] |

---

### E1 · El servidor no arranca tras editar el fstab

> [!bug] Síntoma
> Reinicias y el servidor **no llega al login**. Se queda colgado, o aparece algo como:
> ```
> You are in emergency mode
> Give root password for maintenance
> ```

**Hipótesis.** Hay un error en `/etc/fstab`. El arranque intenta montar lo que dice ese fichero, no puede, y se detiene. La causa más habitual en esta fase: **falta la palabra `loop`**, o hay una errata en una ruta.

> [!danger] 🛑 Que no cunda el pánico: NO has perdido nada
> Los discos están intactos, el dominio está intacto, los usuarios están intactos. **Lo único roto es una línea de texto en un fichero.**
>
> Y tienes algo que en un servidor real no siempre está: **la ventana de VirtualBox**. No necesitas SSH, ni consola serie, ni rescatar nada. Tienes la pantalla del servidor delante.

**Comprobación y arreglo.**

1. Abre la **ventana de la máquina virtual en VirtualBox**.
2. Inicia sesión con tu usuario local (`boochan`). Si pide contraseña de mantenimiento, es la de `root` o la tuya según el modo.
3. Mira qué has escrito:
   ```bash
   cat /etc/fstab
   ```
4. Corrige la línea:
   ```bash
   sudo nano /etc/fstab
   ```
   Las dos líneas correctas son exactamente:
   ```
   /samba_deptos.img  /srv/samba/departamentos/facturacion  ext4  loop,defaults  0  0
   /samba_comun.img  /srv/samba/departamentos/contabilidad  ext4  loop,defaults  0  0
   ```
5. **Antes de reiniciar**, comprueba en seco:
   ```bash
   sudo mount -a
   ```
   **Silencio = correcto.** Cualquier mensaje = todavía está mal.
6. Solo entonces:
   ```bash
   sudo reboot
   ```

> [!tip] 💡 Si no consigues arreglarlo, tienes la instantánea
> Restaura `Fase 5 terminada` y vuelves a un servidor que arranca. Pierdes el trabajo de esta fase, que son quince minutos. **Para eso están los puntos de control.**

> [!summary] Qué aprendes
> **`/etc/fstab` es de los pocos ficheros de Linux donde una errata impide arrancar.** Por eso existe el `sudo mount -a`: es un ensayo del arranque que puedes hacer **sin arrancar**.
>
> Y la regla profesional que sale de aquí: **cuando toques algo que se ejecuta en el arranque, prueba antes de reiniciar.** El reinicio no es la prueba: es el examen final. Lo mismo vale para configuraciones de red, de firewall y de servicios.

---

### E2 · `df -h` no muestra los discos

> [!bug] Síntoma
> Has hecho todos los pasos, pero `df -h` no enseña ninguna línea de 5 GB con `/srv/samba/…`.

**Hipótesis.** Los discos existen y están formateados, pero **no están montados**. Escribir en esas carpetas ahora mismo escribe en el disco del sistema, no en el disco virtual.

**Comprobación.**
```bash
ls -l /samba_deptos.img /samba_comun.img      # ¿existen los ficheros?
mountpoint /srv/samba/departamentos/facturacion          # ¿es un punto de montaje?
grep samba /etc/fstab                  # ¿está declarado?
```

**Arreglo.**
```bash
sudo mount -a
df -h | grep prueba
```

> [!summary] Qué aprendes
> Que **una carpeta y un punto de montaje se ven exactamente igual.** `ls` no distingue si detrás hay un disco o no; `mountpoint` y `df` sí.
>
> Es un error clásico y caro: se copian datos a `/srv/samba/departamentos/facturacion` con el disco desmontado, luego se monta encima… **y los datos desaparecen de la vista.** No se han borrado: están debajo del montaje, tapados.

---

### E3 · `wrong fs type` al montar

> [!bug] Síntoma
> ```
> mount: /srv/samba/departamentos/facturacion: wrong fs type, bad option, bad superblock...
> ```

**Hipótesis.** El fichero `.img` no llegó a formatearse, o el `mkfs.ext4` se ejecutó sobre un fichero incompleto.

**Comprobación.** Pregúntale al sistema qué hay dentro del fichero:
```bash
sudo blkid /samba_deptos.img
```
- **✅ Bien:** dice `TYPE="ext4"`.
- **❌ Mal:** no devuelve nada → no tiene sistema de ficheros.

**Arreglo.**
```bash
sudo mkfs.ext4 /samba_deptos.img
sudo mount -a
```

> [!summary] Qué aprendes
> Que **un disco pasa por tres estados** y no se pueden saltar: existir *(el `dd`)* → tener formato *(el `mkfs`)* → estar montado *(el `mount`)*.
>
> Es exactamente lo mismo que hace VirtualBox con tu `.vdi`, o lo que harías con un disco duro nuevo: crear la partición, formatearla y asignarle una letra o un punto de montaje. **Aquí lo has hecho a mano, y por eso lo entiendes.**

---

### E4 · `dd` falla por falta de espacio

> [!bug] Síntoma
> ```
> dd: error writing '/samba_comun.img': No space left on device
> ```

**Hipótesis.** El disco virtual de la VM —el `.vdi` que creaste en la Fase 1— **se ha quedado sin sitio**. Estás pidiendo 10 GB en dos ficheros sobre un disco de 20 GB que ya lleva el sistema y el dominio dentro.

**Comprobación.**
```bash
df -h /
ls -lh /samba_deptos.img /samba_comun.img
```

**Arreglo.** Primero, **borra el fichero a medias**, que ocupa sin servir:
```bash
sudo rm -f /samba_comun.img
df -h /
```
Si aun así no hay 11 GB libres, tienes dos caminos:
- **Limpiar:** `sudo apt clean` y `sudo journalctl --vacuum-time=2d` liberan bastante.
- **Ampliar el disco de la VM** desde VirtualBox *(la VM apagada, `Herramientas` → `Medios`)*.

> [!summary] Qué aprendes
> Que **un disco virtual no es magia: sale del disco real.** Los 5 GB de `facturacion` no aparecen de la nada — se los quitas al `.vdi`, que a su vez se los quita a tu disco físico.
>
> Es la misma idea que la sobreventa de almacenamiento en la nube, y la razón de que un proveedor te cobre por gigabyte: **abajo del todo siempre hay un disco de verdad con un límite de verdad.**

---

### E5 · `invalid group: 'contabilidad'`

> [!bug] Síntoma
> ```
> chown: invalid group: 'root:contabilidad'
> ```

**Hipótesis.** El sistema **no ve** el grupo. No es que no exista: es que `winbind` está parado o `nsswitch.conf` no le pregunta. El grupo vive en el dominio, no en `/etc/group`.

**Comprobación.**
```bash
getent group contabilidad
systemctl is-active winbind
```

**Arreglo.**
```bash
sudo systemctl enable --now winbind
getent group contabilidad
sudo chown root:contabilidad /srv/samba/departamentos/contabilidad
```
Si `getent` sigue sin devolver nada, el problema es de la Fase 5 → [[Fase_5.7_Resolucion_Problemas#E1 · Un usuario no aparece con id|caso E1 de la Fase 5]].

> [!summary] Qué aprendes
> Que **las fases se apoyan unas en otras de formas que no son evidentes.** Aquí estás dando permisos sobre carpetas —tema de la Fase 6— y el fallo está en el traductor de identidades de la Fase 5.
>
> **Este error, al menos, te avisa.** El siguiente caso es el mismo problema sin aviso, y es mucho peor.

---

### E6 · La carpeta `contabilidad` pertenece a `root` y no a `contabilidad`

> [!bug] Síntoma
> **Ninguno.** Los comandos pasaron, no hubo errores, la carpeta existe.
>
> Pero al mirarla:
> ```bash
> ls -ld /srv/samba/departamentos/contabilidad
> drwxrws--- 2 root root 4096 ... /srv/samba/departamentos/contabilidad
> ```
> Pone `root root`, y debería poner `root contabilidad`.

**Hipótesis.** Cuando ejecutaste el `chown`, `winbind` no estaba levantado. Y aquí está lo grave: **si el `chown` se hizo en dos pasos o el grupo se resolvió a medias, la carpeta se queda con el grupo por defecto sin que el resultado final proteste.**

**Comprobación.**
```bash
ls -ld /srv/samba/departamentos/contabilidad
stat -c '%U %G %a' /srv/samba/departamentos/contabilidad
getent group contabilidad
```
- **✅ Bien:** `root contabilidad 2770`.
- **❌ Mal:** cualquier otra cosa en la columna del grupo.

**Arreglo.**
```bash
sudo systemctl is-active winbind
getent group contabilidad
sudo chown root:contabilidad /srv/samba/departamentos/contabilidad
sudo chmod 2770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
```

> [!danger] ⚠️ Por qué esto es el fallo caro de la fase
> La carpeta **funciona**. Se puede montar, escribir y leer. `df` la muestra. Nada indica que haya un problema.
>
> El problema llega en la **Fase 7**, cuando protejas `contabilidad` para que solo la vea el grupo `contabilidad`. Si la carpeta pertenece a `root`, esa protección **no se aplica a nadie**: o no entra ningún usuario, o entran todos. Y el error que verás allí hablará de permisos denegados, sin mencionar esta fase.
>
> **Y hay una segunda trampa:** si tomas la instantánea con la carpeta mal, el fallo queda guardado dentro de tu punto de retorno.

> [!summary] Qué aprendes
> **El fallo que no da error es el caro.** Es la misma idea de la Fase 4 con el dominio anunciado en la tarjeta equivocada y de la Fase 5 con los UID automáticos.
>
> Y la consecuencia práctica: **después de un `chown` o un `chmod`, mira el resultado.** No basta con que el comando no proteste. `ls -ld` cuesta dos segundos y es la única prueba de que hizo lo que querías.

---

### E7 · Los ficheros nuevos no heredan el grupo

> [!bug] Síntoma
> La carpeta es del grupo `contabilidad`, pero al crear un fichero dentro, el fichero sale con **otro grupo** — el personal de quien lo creó.

**Hipótesis.** Falta el **bit setgid**: la carpeta tiene permisos `770` en lugar de `2770`.

**Comprobación.**
```bash
stat -c %a /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
```
- **✅ Bien:** `2770`, y en `ls -ld` aparece una **`s`** donde iría la `x` del grupo: `drwxrws---`.
- **❌ Mal:** `770`, y en `ls -ld` una `x` normal: `drwxrwx---`.

**Arreglo.**
```bash
sudo chmod 2770 /srv/samba/departamentos/contabilidad
ls -ld /srv/samba/departamentos/contabilidad
```

> [!info] 🎓 Para qué sirve de verdad el setgid
> Sin él, cada usuario que cree un fichero en la carpeta compartida lo dejará **a nombre de su propio grupo**. Resultado: una carpeta "del grupo policía" llena de ficheros que los demás miembros del grupo no pueden tocar.
>
> El setgid dice: *"todo lo que nazca aquí dentro pertenece al grupo de la carpeta, no al de su autor"*. Es lo que convierte una carpeta compartida en algo realmente compartido.

> [!summary] Qué aprendes
> Que en los permisos de Unix **hay un cuarto dígito** que casi nadie mira, y que decide comportamientos, no accesos. `777` y `2777` no son lo mismo.
>
> Y que **una `s` en lugar de una `x`** en la salida de `ls -l` es información, no adorno. Leer permisos es una habilidad, y aquí la estás usando.

---

### E8 · Tras reiniciar, los discos no están montados

> [!bug] Síntoma
> Ayer funcionaba. Hoy, tras encender la máquina, `df -h` no muestra los discos y las carpetas están vacías.

**Hipótesis.** Los montaste a mano con `mount` y **no añadiste las líneas al `/etc/fstab`**, o las añadiste comentadas.

**Comprobación.**
```bash
grep samba /etc/fstab
mountpoint /srv/samba/departamentos/facturacion
```

**Arreglo.** Añade las dos líneas al `fstab` *(Paso 4 del procedimiento)* y **comprueba en seco antes de volver a reiniciar**:
```bash
sudo mount -a
df -h | grep prueba
```

> [!danger] ⚠️ Y comprueba si has escrito datos con el disco desmontado
> Si trabajaste en `/srv/samba/departamentos/facturacion` sin el disco montado, esos ficheros están en el **disco del sistema**, y al montar encima quedan **tapados**. Para verlos hay que desmontar:
> ```bash
> sudo umount /srv/samba/departamentos/facturacion
> ls -la /srv/samba/departamentos/facturacion
> ```

> [!summary] Qué aprendes
> **`active` es "ahora"; `enabled` es "la próxima vez"** — aquí en su versión de almacenamiento: *montado* es ahora, *`fstab`* es la próxima vez.
>
> Es la quinta fase seguida en la que aparece la misma idea: el `netplan` de la Fase 1, el `wg-quick@wg0` de la Fase 3, el `samba-ad-dc` de la 4, el `winbind` de la 5 y el `fstab` de la 6. **Lo que no persiste, no está configurado.**

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. **Pasa el verificador:** `sudo ./verificar_fase6.sh`. Te dice qué comprobación falla, y eso ya acota el problema a un bloque.
> 2. **Mira el registro del montaje:** `sudo journalctl -xe | grep -i mount`.
> 3. **Anota el mensaje literal** en tu entrada de apuntes, aunque lo resuelvas. Los mensajes de error se repiten, y el tuyo de hoy es el de un compañero de la semana que viene.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.6_Procedimiento]] | [[Fase_6]] | [[Fase_6.8.a_Verificacion]] |
