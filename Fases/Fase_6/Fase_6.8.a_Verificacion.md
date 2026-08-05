## Fase 6 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás al mismo problema.
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

> Todos los comandos de aquí **solo leen**, salvo el punto 6 y el 7, que avisan de lo que crean y lo borran después.

### **1 · LOS DOS DISCOS EXISTEN Y TIENEN FORMATO**

```bash
ls -lh /samba_deptos.img /samba_comun.img
sudo blkid /samba_deptos.img /samba_comun.img
```

- **✅ Bien:** **8,0G** y **2,0G**, y `TYPE="ext4"` en los dos.
- **❌ Mal:**
  - Miden menos → el `dd` se cortó → [[Fase_6.7_Resolucion_Problemas#E4 · dd falla por falta de espacio|caso E4]]
  - `blkid` no dice nada → sin formatear → [[Fase_6.7_Resolucion_Problemas#E3 · wrong fs type al montar|caso E3]]

> [!info] 🎓 Un disco pasa por tres estados, y no se puede saltar ninguno
> **Existir** (`dd`) → **tener formato** (`mkfs`) → **estar montado** (`mount`). Este punto comprueba los dos primeros; el siguiente, el tercero.

### **2 · ESTÁN MONTADOS Y SON VOLÚMENES DISTINTOS**

```bash
df -h | grep srv
mountpoint /srv/samba/departamentos
mountpoint /srv/samba/comun
```

- **✅ Bien:** dos líneas en `df` —una de **8,0G** y otra de **2,0G**— y los dos `mountpoint` dicen `is a mountpoint`.
- **❌ Mal:** no aparecen → [[Fase_6.7_Resolucion_Problemas#E2 · df -h no muestra los discos|caso E2]].

> [!warning] ⚠️ Una carpeta y un punto de montaje se ven EXACTAMENTE igual
> `ls` no distingue si detrás de `/srv/samba/departamentos` hay un disco de 8 GB o es una carpeta normal del sistema. `mountpoint` y `df` sí.
>
> Y no es teórico: si escribes datos con el disco desmontado y luego lo montas encima, **los datos desaparecen de la vista**. No se borran — quedan tapados debajo del montaje.

> [!info] 🎓 Fíjate en que son DOS volúmenes, y ese es el objetivo
> Si llenas la carpeta común, **los departamentos no se enteran**. Si compartieran disco, un usuario subiendo vídeos a la común dejaría sin espacio a contabilidad.
>
> Compruébalo tú mismo:
> ```bash
> df --output=source,size,target /srv/samba/departamentos /srv/samba/comun
> ```
> Las dos líneas tienen que mostrar **dispositivos distintos**.

### **3 · 🔴 EL SERVIDOR PODRÁ ARRANCAR**

```bash
cat /etc/fstab
sudo mount -a
grep samba /etc/fstab
```

- **Qué hace `mount -a`:** **ensaya el arranque sin arrancar.**
- **✅ Bien:** **silencio absoluto**, y las dos líneas del `fstab` contienen **`loop`**.
- **❌ Mal:** cualquier mensaje → **NO REINICIES** → [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]].

> [!danger] 🛑 ESTA ES LA COMPROBACIÓN MÁS IMPORTANTE DE LA FASE
> `/etc/fstab` es de los poquísimos ficheros de Linux donde **una errata impide arrancar el sistema**. No es un servicio que falla: es la máquina que no llega al login.
>
> **`sudo mount -a` es tu paracaídas.** Es la única forma de saber si el arranque va a funcionar **sin jugártela reiniciando**.
>
> Regla que vale para siempre: **cuando toques algo que se ejecuta en el arranque, pruébalo antes de reiniciar.** El reinicio no es la prueba, es el examen final.

### **4 · 🔴 LAS SEIS CARPETAS SON DE SU DEPARTAMENTO**

```bash
stat -c '%n  %U:%G  %a' /srv/samba/departamentos/*
```

- **✅ Bien:** las seis, cada una con **su grupo** y permisos **`2770`**:
  ```
  /srv/samba/departamentos/becarios      root:becarios      2770
  /srv/samba/departamentos/comercial     root:comercial     2770
  /srv/samba/departamentos/contabilidad  root:contabilidad  2770
  /srv/samba/departamentos/facturacion   root:facturacion   2770
  /srv/samba/departamentos/logistica     root:logistica     2770
  /srv/samba/departamentos/rrhh          root:rrhh          2770
  ```
- **❌ Mal:**
  - Alguna dice `root:root` → [[Fase_6.7_Resolucion_Problemas#E6 · Una carpeta pertenece a root y no a su departamento|caso E6]]
  - Alguna pone `770` en vez de `2770` → falta el setgid → [[Fase_6.7_Resolucion_Problemas#E7 · Los ficheros nuevos no heredan el grupo|caso E7]]

Y que se vea la **`s`** en las seis:
```bash
ls -ld /srv/samba/departamentos/*
```
- **✅ Bien:** `drwxrws---` en todas.

> [!danger] 🛑 Y este es el fallo que no da error
> Si `winbind` no estaba levantado cuando ejecutaste el `chown`, la carpeta se quedó a nombre de `root`. **Funciona igual:** se monta, se escribe, se lee.
>
> Se rompe en la **Fase 7**, cuando des permisos al departamento y esos permisos no alcancen a nadie. Con un error que hablará de accesos denegados, sin mencionar esta fase.
>
> **Después de un `chown`, se mira el resultado.**

### **5 · LA CARPETA COMÚN TIENE SU STICKY BIT**

```bash
stat -c '%n  %U:%G  %a' /srv/samba/comun
ls -ld /srv/samba/comun
```

- **✅ Bien:** `root:root  1777`, y en `ls -ld` se ve **`drwxrwxrwt`** — con la **`t`** al final.
- **❌ Mal:** pone `777` sin el `1` → falta el sticky bit.

> [!info] 🎓 Compara la `s` y la `t`
> ```bash
> ls -ld /srv/samba/departamentos/facturacion /srv/samba/comun /tmp
> ```
> - Las carpetas de departamento llevan **`s`** → *setgid*: lo que se cree dentro hereda el grupo.
> - La común lleva **`t`** → *sticky bit*: solo puedes borrar lo tuyo.
> - Y `/tmp` lleva la misma **`t`**, por el mismo motivo, desde hace décadas.
>
> **Son los dos el cuarto dígito de los permisos**, y hacen cosas distintas.

### **6 · EL LÍMITE FRENA DE VERDAD** *(la prueba que importa)*

Los puntos anteriores dicen que los discos **están**. Este dice que **sirven para algo**:

```bash
sudo dd if=/dev/zero of=/srv/samba/comun/relleno.tmp bs=1M count=3000
```

- **✅ Bien:** **falla** con `No space left on device` tras escribir unos 2 GB.
- **❌ Mal:** escribe los 3 GB sin protestar → no estás escribiendo en el disco virtual → vuelve al punto 2.

**Y ahora mira lo importante, antes de borrarlo:**
```bash
df -h /srv/samba/comun
df -h /srv/samba/departamentos
df -h /
```

- La común, **al 100 %**.
- Los departamentos, **intactos**.
- El disco del servidor, **con espacio libre**.

**Borra el relleno:**
```bash
sudo rm -f /srv/samba/comun/relleno.tmp
df -h /srv/samba/comun
```

> [!success] 🎯 Esto es la fase entera en una pantalla
> Acabas de llenar por completo una carpeta **sin afectar a nadie más**. Los seis departamentos siguen trabajando y el servidor está perfectamente.
>
> Eso es una **cuota**, y eso es exactamente para lo que sirve: que **quien se pasa se quede sin sitio él**, y no tire la infraestructura de todos. Es lo mismo que hace tu proveedor de correo cuando te dice que tu buzón está lleno mientras sus servidores tienen petabytes libres.

### **7 · LA BASE DE LA FASE 5 SIGUE EN PIE**

```bash
for g in facturacion contabilidad comercial logistica rrhh becarios; do
    printf '%-16s ' "$g"; getent group "$g" || echo "NO SE VE"
done
id hiroshi.nohara
```

- **Por qué:** los permisos de esta fase se apoyan en los grupos. Si un grupo se deja de ver, la carpeta apunta a un número sin dueño.
- **✅ Bien:** los seis grupos con GID `3001`-`3006`, e `id hiroshi.nohara` con `uid=10001` y `facturacion` entre sus grupos.
- **❌ Mal:** vuelve a la [[Fase_5.7_Resolucion_Problemas|resolución de problemas de la Fase 5]].

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los siete puntos de arriba tú, comando a comando. **En el vídeo tienes que explicarlos.**

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase6.sh
> chmod +x verificar_fase6.sh
> less verificar_fase6.sh
> sudo ./verificar_fase6.sh
> ```
> *(El `less` se sale con `q`.)*
>
> **Sube el informe** `verificacion-fase-6.txt` a tu repositorio.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. **¿Por qué el verificador comprueba el `fstab` aunque los discos ya estén montados?**
> 3. El script comprueba que los dos puntos de montaje usan **dispositivos distintos**. ¿Qué problema estaría detectando si usaran el mismo?

---

### ✅ Checklist de este apartado

- [ ] `/samba_deptos.img` **8,0G** y `/samba_comun.img` **2,0G**, los dos `ext4`.
- [ ] Los dos montados, y `df` muestra **8,0G** y **2,0G**.
- [ ] Comprobado que son **dispositivos distintos**.
- [ ] 🔴 `sudo mount -a` **en silencio**, y las dos líneas del `fstab` con **`loop`**.
- [ ] 🔴 Las **seis** carpetas con **su grupo** y **`2770`**, con la **`s`** visible.
- [ ] `comun` con **`root:root  1777`** y la **`t`** visible.
- [ ] Prueba de la cuota hecha: el `dd` **falla**, los departamentos **intactos**, y el relleno **borrado**.
- [ ] Los seis grupos y los usuarios de la Fase 5 siguen visibles.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_6.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.7_Resolucion_Problemas]] | [[Fase_6]] | [[Fase_6.8.b_Punto_de_Control]] |
