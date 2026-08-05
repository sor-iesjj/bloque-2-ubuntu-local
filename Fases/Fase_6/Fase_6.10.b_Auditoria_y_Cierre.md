## Fase 6 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 7 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el almacenamiento **existe, tiene límite y sobrevive al arranque**. Las tres cosas, y la tercera es la que puede dejar el servidor sin encender.
>
> Un disco montado a mano funciona perfectamente hasta que apagas. Y un `fstab` mal escrito no es un servicio que falla: es una máquina que no llega al login.

---

## **1 · LOS DISCOS VIRTUALES**

- [ ] `/samba_p1.img` y `/samba_p3.img` existen y miden **~5 GB** cada uno.
- [ ] `sudo blkid` dice **`TYPE="ext4"`** en los dos.
- [ ] `df -h` muestra las dos carpetas con **5,0G**.
- [ ] `mountpoint /srv/samba/prueba1` y `…/prueba3` → **son puntos de montaje**.

## **2 · 🔴 LA PERSISTENCIA**

- [ ] `/etc/fstab` tiene las **dos líneas**, y las dos llevan **`loop`**.
- [ ] `sudo mount -a` devuelve **silencio absoluto**.
- [ ] **Reinicio comprobado:** tras `sudo reboot`, `df -h` muestra los dos discos **sin tocar nada**.

> [!danger] ⚠️ Si `mount -a` da cualquier mensaje, PARA AQUÍ
> No pases a la Fase 7 y **no apagues la máquina**. Un `fstab` roto deja el servidor en modo emergencia en el siguiente arranque. Arréglalo con el [[Fase_6.7_Resolucion_Problemas#E1 · El servidor no arranca tras editar el fstab|caso E1]].

## **3 · 🔴 LOS PERMISOS**

- [ ] `/srv/samba/prueba1` → permisos **`777`**.
- [ ] `/srv/samba/prueba3` → **`root policia`**, permisos **`2770`**.
- [ ] En `ls -ld /srv/samba/prueba3` se ve la **`s`**: `drwxrws---`.

> [!danger] ⚠️ Si el grupo de `prueba3` no es `policia`, PARA AQUÍ
> Es el fallo que hace fracasar la Fase 7 sin dar ninguna pista. Arréglalo con el [[Fase_6.7_Resolucion_Problemas#E6 · La carpeta prueba3 pertenece a root y no a policia|caso E6]] y vuelve a tomar la instantánea.

## **4 · EL LÍMITE FUNCIONA**

- [ ] Probado que un `dd` de 6 GB en `prueba1` **falla** con `No space left on device`.
- [ ] Comprobado que, mientras tanto, `df -h /` **tenía espacio libre**.
- [ ] El fichero de relleno **borrado** después.

## **5 · LA BASE DE LAS FASES ANTERIORES SIGUE EN PIE**

- [ ] `systemctl is-active samba-ad-dc` → **`active`**.
- [ ] `getent group policia` → GID **`3001`**.
- [ ] `id user1` → **`uid=10001 gid=3001`**.

## **6 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **seis averías** provocadas y reparadas, **en dos sesiones** (1-3 montaje, 4-6 permisos y persistencia).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Ficheros de prueba borrados, **`relleno.tmp` incluido**.
- [ ] Verificador pasado al final: **`FASE 6 SUPERADA`**.

## **7 · LAS COPIAS**

- [ ] 💾 Instantánea **`Fase 6 terminada`** tomada **con la VM apagada** y comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F6-almacenamiento-virtual.ova`** en `SOR/Bloque_2/Fases/Fase_6/` de tu **disco externo**.

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
> Que en los permisos de Unix hay **un cuarto dígito** que no decide quién entra, sino cómo se comporta lo que se crea dentro. Una `s` en lugar de una `x`.
>
> Y la más importante para tu vida profesional: **`sudo mount -a` es un ensayo del arranque que puedes hacer sin arrancar.** Existe un equivalente para casi todo lo que se ejecuta al encender una máquina —`nginx -t`, `visudo`, `netplan try`—, y usarlo es la diferencia entre encontrar el error en tu terminal o delante de un servidor que no enciende.
>
> **Siguiente:** Fase 7 — Compartición y permisos avanzados.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.10.a_Laboratorio_de_Averias]] | [[Fase_6]] | **Fase 7** |
