## Fase 6 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Aquí compruebas. En el [[Fase_6.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ En esta fase hay algo más urgente que la instantánea
> **El punto 3 comprueba que el servidor podrá arrancar.** Si `/etc/fstab` tiene una errata, el próximo reinicio deja la máquina en modo emergencia.
>
> **No reinicies, no apagues y no tomes la instantánea hasta que ese punto esté en verde.**

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`ubuntuserver`** → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · LOS DISCOS EXISTEN Y TIENEN FORMATO**

```bash
ls -lh /samba_p1.img /samba_p3.img
sudo blkid /samba_p1.img /samba_p3.img
```

- **Qué hacen:** el `ls` comprueba que los ficheros están y **cuánto miden**; el `blkid`, que tienen sistema de ficheros dentro.
- **✅ Bien:** **5,0G** cada uno, y `TYPE="ext4"` en los dos.
- **❌ Mal:**
  - Miden menos → el `dd` se cortó → [[Fase_6.7_Resolucion_Problemas#E4 · dd falla por falta de espacio|caso E4]]
  - `blkid` no dice nada → sin formatear → [[Fase_6.7_Resolucion_Problemas#E3 · wrong fs type al montar|caso E3]]

> [!info] 🎓 Un disco pasa por tres estados, y no se puede saltar ninguno
> **Existir** (`dd`) → **tener formato** (`mkfs`) → **estar montado** (`mount`). Este punto comprueba los dos primeros; el siguiente, el tercero.

### **2 · ESTÁN MONTADOS Y CADA UNO TIENE SU LÍMITE**

```bash
df -h | grep prueba
mountpoint /srv/samba/prueba1
mountpoint /srv/samba/prueba3
```

- **✅ Bien:** dos líneas de **5,0G** en `df`, y los dos `mountpoint` dicen `is a mountpoint`.
- **❌ Mal:** no aparecen → [[Fase_6.7_Resolucion_Problemas#E2 · df -h no muestra los discos|caso E2]].

> [!warning] ⚠️ Una carpeta y un punto de montaje se ven EXACTAMENTE igual
> `ls` no distingue si detrás de `/srv/samba/prueba1` hay un disco de 5 GB o es una carpeta normal del sistema. `mountpoint` y `df` sí.
>
> Y esto no es teórico: si escribes datos con el disco desmontado y luego lo montas encima, **los datos desaparecen de la vista**. No se borran — quedan tapados debajo del montaje.

### **3 · 🔴 EL SERVIDOR PODRÁ ARRANCAR**

```bash
cat /etc/fstab
sudo mount -a
```

- **Qué hace `mount -a`:** **ensaya el arranque sin arrancar.** Lee el `fstab` entero e intenta montar todo lo que dice.
- **✅ Bien:** **silencio absoluto.** Ni una línea de salida.
- **❌ Mal:** cualquier mensaje → **NO REINICIES** → [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]].

Y comprueba que las dos líneas llevan la palabra clave:
```bash
grep samba /etc/fstab
```
- **✅ Bien:** las dos contienen **`loop`**.

> [!danger] 🛑 ESTA ES LA COMPROBACIÓN MÁS IMPORTANTE DE LA FASE
> `/etc/fstab` es de los poquísimos ficheros de Linux donde **una errata impide arrancar el sistema**. No es un servicio que falla: es la máquina que no llega al login.
>
> **`sudo mount -a` es tu paracaídas.** Es la única forma de saber si el arranque va a funcionar **sin jugártela reiniciando**.
>
> Regla que vale para siempre: **cuando toques algo que se ejecuta en el arranque, pruébalo antes de reiniciar.** El reinicio no es la prueba, es el examen final.

### **4 · 🔴 LOS PERMISOS SON LOS QUE PEDISTE**

```bash
ls -ld /srv/samba/prueba1 /srv/samba/prueba3
stat -c '%U %G %a' /srv/samba/prueba3
```

- **✅ Bien:**
  - `prueba1` → permisos **`777`**
  - `prueba3` → **`root policia 2770`**, y en `ls -ld` se ve `drwxrws---`
- **❌ Mal:**
  - El grupo dice `root` → [[Fase_6.7_Resolucion_Problemas#E6 · La carpeta prueba3 pertenece a root y no a policia|caso E6]]
  - Pone `770` en vez de `2770` → falta el setgid → [[Fase_6.7_Resolucion_Problemas#E7 · Los ficheros nuevos no heredan el grupo|caso E7]]

> [!danger] 🛑 Y este es el fallo que no da error
> Si `winbind` no estaba levantado cuando ejecutaste el `chown`, la carpeta se quedó a nombre de `root`. **Funciona igual:** se monta, se escribe, se lee.
>
> Se rompe en la **Fase 7**, cuando protejas `prueba3` para el grupo `policia` y esa protección no alcance a nadie. Con un error que hablará de accesos denegados, sin mencionar esta fase.
>
> **Después de un `chown`, se mira el resultado.** Que el comando no proteste no significa que hiciera lo que querías.

> [!info] 🎓 La `s` que ves en `drwxrws---` no es un adorno
> Es el **setgid**. Significa que todo lo que se cree dentro heredará el grupo `policia`, en vez del grupo personal de su autor. Sin él, una carpeta "del grupo policía" se llena de ficheros que el resto del grupo no puede tocar.

### **5 · LA IDENTIDAD DE LA FASE 5 SIGUE EN PIE**

```bash
getent group policia
id user1
```

- **Por qué:** los permisos de esta fase se apoyan en el grupo. Si el grupo se deja de ver, los permisos apuntan a un número sin dueño.
- **✅ Bien:** `policia:*:3001:` e `id user1` con `uid=10001 gid=3001`.
- **❌ Mal:** vuelve a la [[Fase_5.7_Resolucion_Problemas|resolución de problemas de la Fase 5]].

### **6 · EL LÍMITE FRENA DE VERDAD** *(la prueba que importa)*

Las cinco comprobaciones anteriores dicen que el disco **está**. Esta dice que **sirve para algo**:

```bash
sudo dd if=/dev/zero of=/srv/samba/prueba1/relleno.tmp bs=1M count=6000
```

- **✅ Bien:** el comando **falla** con `No space left on device` después de escribir unos 5 GB.
- **❌ Mal:** escribe los 6 GB sin protestar → **no estás escribiendo en el disco virtual**, sino en el del sistema → vuelve al punto 2.

**Y ahora borra el relleno, que si no te dejas el disco lleno:**
```bash
sudo rm -f /srv/samba/prueba1/relleno.tmp
df -h | grep prueba1
```

> [!success] 🎯 Esto es la fase entera en un comando
> Acabas de comprobar que **una carpeta puede tener un límite propio, independiente del disco del servidor**. El servidor tiene sitio de sobra y aun así esa carpeta se ha llenado.
>
> Eso es una **cuota**. Es lo que impide que un usuario llene el disco de todos, y es exactamente lo que hace tu proveedor de correo cuando te dice que tu buzón está lleno mientras sus servidores tienen petabytes libres.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los seis puntos de arriba tú, comando a comando, entendiendo qué dice cada uno. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase6.sh
> chmod +x verificar_fase6.sh
> less verificar_fase6.sh
> sudo ./verificar_fase6.sh
> ```
> *(El `less` se sale con `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído.**
>
> **Sube el informe** `verificacion-fase-6.txt` a tu repositorio, junto con la entrada de apuntes.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. Y una más difícil: **¿por qué el verificador comprueba el `fstab` aunque los discos ya estén montados?**

---

### ✅ Checklist de este apartado

- [ ] Los dos `.img` existen, miden **5,0G** y `blkid` dice **`ext4`**.
- [ ] `df -h` muestra las dos carpetas con **5,0G** cada una.
- [ ] 🔴 `sudo mount -a` **en silencio**, y las dos líneas del `fstab` con **`loop`**.
- [ ] 🔴 `prueba3` → **`root policia 2770`**, con la **`s`** visible en `ls -ld`.
- [ ] `prueba1` → permisos **`777`**.
- [ ] `getent group policia` e `id user1` siguen respondiendo.
- [ ] Prueba de la cuota hecha: el `dd` de 6 GB **falla**, y el relleno **borrado después**.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_6.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.7_Resolucion_Problemas]] | [[Fase_6]] | [[Fase_6.8.b_Punto_de_Control]] |
