## Fase 6 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6_Almacenamiento_Virtual_Cuotas]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 7 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el almacenamiento **existe, tiene límite y sobrevive al arranque**. Las tres cosas, y la tercera es la que puede dejar el servidor sin encender.
>
> Un disco montado a mano funciona perfectamente hasta que apagas. Y un `fstab` mal escrito no es un servicio que falla: es una máquina que no llega al login.

---

## **1 · LOS DISCOS VIRTUALES**

- [ ] `/samba_deptos.img` mide **~8 GB** y `/samba_comun.img` **~2 GB**.
- [ ] `sudo blkid` dice **`TYPE="ext4"`** en los dos.
- [ ] `df -h` muestra **8,0G** en `/srv/samba/departamentos` y **2,0G** en `/srv/samba/comun`.
- [ ] `mountpoint` confirma que **los dos** son puntos de montaje.
- [ ] Comprobado que usan **dispositivos distintos**: llenar la común no afecta a los departamentos.

## **2 · 🔴 LA PERSISTENCIA**

- [ ] `/etc/fstab` tiene las **dos líneas**, y las dos llevan **`loop`**.
- [ ] `sudo mount -a` devuelve **silencio absoluto**.
- [ ] **Reinicio comprobado:** tras `sudo reboot`, `df -h` muestra los dos discos **sin tocar nada**.

> [!danger] ⚠️ Si `mount -a` da cualquier mensaje, PARA AQUÍ
> No pases a la Fase 7 y **no apagues la máquina**. Un `fstab` roto deja el servidor en modo emergencia en el siguiente arranque. Arréglalo con el [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]].

## **3 · 🔴 LOS PERMISOS DE LAS SIETE CARPETAS**

- [ ] Las **seis** de departamento con **`root:<su grupo>`** y permisos **`2770`**:

```bash
stat -c '%n  %U:%G  %a' /srv/samba/departamentos/* /srv/samba/comun
```

- [ ] La **`s`** del setgid visible en las seis: `drwxrws---`.
- [ ] `comun` con **`root:root`** y permisos **`1777`**.
- [ ] La **`t`** del sticky bit visible en la común: `drwxrwxrwt`.

> [!danger] ⚠️ Si alguna carpeta pertenece a `root` en vez de a su departamento, PARA AQUÍ
> Es el fallo que hace fracasar la Fase 7 sin dar ninguna pista. Arréglalo con el [[Fase_6.7_Resolucion_Problemas#E6 · La carpeta contabilidad pertenece a root y no a contabilidad|caso E6]] y vuelve a tomar la instantánea.

## **4 · LOS LÍMITES FUNCIONAN**

- [ ] Probado que un `dd` de 3 GB en `comun` **falla** con `No space left on device`.
- [ ] Comprobado que, mientras la común estaba al 100 %, **los departamentos seguían intactos**.
- [ ] Comprobado que `df -h /` **tenía espacio libre**.
- [ ] El fichero de relleno **borrado** después.

## **5 · LA BASE DE LAS FASES ANTERIORES SIGUE EN PIE**

- [ ] `systemctl is-active samba-ad-dc` → **`active`**.
- [ ] `wbinfo -p` → **responde** *(el servicio `winbind` de systemd sigue `inactive`: correcto en un AD DC)*.
- [ ] Los **seis grupos** visibles con GID **`3001`**-**`3006`**.
- [ ] `id hiroshi.nohara` → **`uid=10001`** y **`facturacion` en `groups=`** *(el `gid=` primario es `100(users)`: normal en AD)*.

## **6 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **seis averías** provocadas y reparadas, **en dos sesiones** (1-3 montaje, 4-6 permisos y persistencia).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Ficheros de prueba borrados, **`relleno.tmp` incluido**.
- [ ] Verificador pasado al final: **`FASE 6 SUPERADA`**.

## **7 · LAS COPIAS**

- [ ] 💾 Instantánea **`Fase 6 terminada`** tomada **con la VM apagada** y comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F6-almacenamiento-virtual.ova`** en `SOR/Bloque_2/Fases/Fase_6_Almacenamiento_Virtual_Cuotas/` de tu **disco externo**.

## **8 · LA ENTREGA**

- [ ] Las **tres entradas** de apuntes, con sus **tres enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_6.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 6
> Que **un disco no aparece de la nada**: se crea (`dd`), se formatea (`mkfs`) y se monta (`mount`). Tres estados que no se pueden saltar, y que son exactamente los mismos que sigue un disco duro físico o un volumen de la nube.
>
> Que **una carpeta y un punto de montaje se ven idénticos**, y que confundirlos hace desaparecer datos de la vista sin haber borrado nada. `ls` no lo distingue; `mountpoint` y `df` sí.
>
> Que **un punto de montaje tapa lo que hay debajo**, y que ese espacio escondido sigue ocupando disco sin salir en ningún sitio donde lo busques.
>
> Que eso es una **cuota**: un límite propio para una carpeta, independiente del disco del servidor. Sirve para que quien se pase se quede sin sitio **él**, y no tire el servidor de todos.
>
> Que en los permisos de Unix hay **un cuarto dígito** que no decide quién entra, sino **cómo se comporta lo que hay dentro**. Y que tiene dos caras que has usado las dos:
> - La **`s`** del *setgid*, en las carpetas de departamento: lo que se cree dentro hereda el grupo, no el de su autor.
> - La **`t`** del *sticky bit*, en la carpeta común: puedes crear y leer, pero **solo borrar lo tuyo**. Es el mismo mecanismo de `/tmp`, y existe porque una carpeta compartida sin él acaba con el trabajo de alguien borrado por error.
>
> Que **separar volúmenes es separar riesgos.** La carpeta común tiene disco propio a propósito: cuando se llene —y se llenará—, solo se llena ella. Aislar lo que se puede descontrolar es una decisión de diseño, no una limitación.
>
> Y la más importante para tu vida profesional: **`sudo mount -a` es un ensayo del arranque que puedes hacer sin arrancar.** Existe un equivalente para casi todo lo que se ejecuta al encender una máquina —`nginx -t`, `visudo`, `netplan try`—, y usarlo es la diferencia entre encontrar el error en tu terminal o delante de un servidor que no enciende.
>
> **Siguiente:** Fase 7 — Compartición y permisos avanzados.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.10.a_Laboratorio_de_Averias]] | [[Fase_6_Almacenamiento_Virtual_Cuotas]] | **Fase 7** |
