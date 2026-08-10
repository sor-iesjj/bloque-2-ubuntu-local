## Fase 7 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 8 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que la protección **está puesta, se aplica y se hereda**. Las tres cosas, y las tres se leen en la misma salida de `getfacl` si sabes mirarla.
>
> Y una cuarta que **no se puede auditar desde aquí**: que la carpeta sea invisible para quien no tiene permiso. Eso se demuestra en la Fase 8, y esta fase no está cerrada del todo hasta entonces.

---

## **1 · LAS ACL ESTÁN Y SE APLICAN**

- [ ] Los **ocho permisos cruzados** de la matriz, puestos y **ninguno de más**:

```bash
for d in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "=== $d"; getfacl -p "/srv/samba/departamentos/$d" | grep -E "^group:"
done
```

| Carpeta | Debe tener, además del suyo | Ojo |
| :--- | :--- | :--- |
| `facturacion` | `comercial:r-x` · `contabilidad:rwx` | comercial **sin `w`** |
| `comercial` | `facturacion:r-x` · `contabilidad:r-x` · `logistica:r-x` | |
| `logistica` | `contabilidad:r-x` · `comercial:r-x` | |
| `becarios` | `rrhh:r-x` | |
| `contabilidad` · `rrhh` | **nada** | son islas |

- [ ] 🔴 **`#effective` solo en `becarios`** *(ahí es correcto: lo provoca el `chmod 2750` del Paso 3.b)* y en **ninguna otra carpeta**.
- [ ] `ls -ld` muestra el **`+`** al final de los permisos en las carpetas con ACL.

> [!danger] ⚠️ Si aparece `#effective` FUERA de `becarios`, PARA AQUÍ
> El permiso está escrito y **no se aplica**. Arréglalo con el [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]] antes de seguir.
>
> **En `becarios` sí es correcto:** ahí la máscara está haciendo lo que le pediste — impedir que escriban en su propia carpeta. **El mismo mecanismo es un acierto en una carpeta y un fallo en otra**, y saber distinguirlo es lo que se evalúa.

## **2 · 🔴 LA HERENCIA FUNCIONA**

- [ ] Cada permiso cruzado tiene **su línea `default:`** correspondiente.
- [ ] Probado con un fichero nuevo: **lo hereda** sin que se lo pongas.
- [ ] El fichero de prueba **borrado** después.

## **3 · 🔴 LA CONFIGURACIÓN DE SAMBA ES VÁLIDA**

- [ ] `sudo testparm` → **`Loaded services file OK`**.
- [ ] `grep -n "^\[" /etc/samba/smb.conf` → **una sola línea por recurso**.
- [ ] Los **siete** recursos aparecen en `testparm -s`.

> [!danger] ⚠️ Aquí `smb.conf` no es solo el servidor de ficheros
> `samba-ad-dc` **es el controlador de dominio**. Una errata en ese fichero no te deja sin carpetas compartidas: te deja **sin DNS, sin Kerberos y sin autenticación** en el próximo arranque. Y el servicio puede seguir funcionando hoy con el fichero ya roto.

## **4 · LA INVISIBILIDAD ESTÁ CONFIGURADA**

- [ ] Las **seis** de departamento con **`access based share enum = Yes`**.
- [ ] Las **seis** con **`hide unreadable = Yes`**.
- [ ] Las siete con **`vfs objects = acl_xattr`**.

## **4.b · 🔴 LOS CASOS ESPECIALES**

- [ ] `becarios` en **`2750`**: su grupo lee pero **no escribe**. Es la única excepción de la matriz.
- [ ] `comun` en **`1777`**, con la **`t`** del sticky bit intacta desde la Fase 6.

## **5 · LA BASE DE LAS FASES ANTERIORES SIGUE EN PIE**

- [ ] `systemctl is-active samba-ad-dc` → **`active`**.
- [ ] `host -t A ubuntuserver.boochanlab.local 127.0.0.1` → **`10.10.10.10`**.
- [ ] Los **seis grupos** con GID **`3001`**-**`3006`**; `id masao.sato` → `uid=10005`, con `comercial` en `groups=`.
- [ ] `mountpoint /srv/samba/departamentos` y `/srv/samba/comun` → **son puntos de montaje**.

## **6 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **siete averías** provocadas y reparadas, **en dos sesiones** (1-3 permisos, 4-6 publicación).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Restos borrados: ficheros de prueba y `smb.conf.bak`.
- [ ] Verificador pasado al final: **`FASE 7 SUPERADA`**.

## **7 · LAS COPIAS**

- [ ] 💾 Instantánea **`Fase 7 terminada`** tomada **con la VM apagada** y comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F7-seguridad-avanzada.ova`** en `SOR/Bloque_2/Fases/Fase_7_Seguridad_Avanzada_ACL_y_ABE/` de tu **disco externo**.

## **8 · LA ENTREGA**

- [ ] Las **tres entradas** de apuntes, con sus **tres enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

## **9 · 🔮 LO QUE QUEDA PENDIENTE PARA LA FASE 8**

> [!important] Esta fase no se puede cerrar del todo desde el servidor
> Anota estas **cuatro pruebas** en tu entrada de apuntes. Las tacharás en la Fase 8, con el cliente Windows delante:
>
> - [ ] **`shinnosuke.nohara`** *(becario)* → **no ve** `contabilidad` en el listado de red.
> - [ ] **`shinnosuke.nohara`** → **no puede borrar** nada en su propia carpeta.
> - [ ] **`masao.sato`** *(comercial)* → **abre** una factura pero **no puede borrarla**.
> - [ ] **`misae.nohara`** *(contabilidad)* → **no ve** `rrhh`.
>
> Si alguna de las de invisibilidad falla, el problema es de esta fase → [[Fase_7.7_Resolucion_Problemas#E5 · Una carpeta protegida se ve desde Windows|caso E5]], y se arregla aquí, no allí.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_7.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 7
> Que **hay dos sistemas de permisos conviviendo** sobre la misma carpeta: los clásicos de Unix, que solo permiten un dueño y un grupo, y las **ACL**, que permiten dar permisos distintos a varios grupos y usuarios a la vez. `ls -l` solo enseña los primeros, y el **`+`** es el aviso de que hay más.
>
> Que **lo que está escrito y lo que se aplica pueden ser cosas distintas.** La máscara de una ACL recorta permisos sin borrarlos, y el sistema te lo dice en una columna —`#effective`— que casi nadie mira. Es el fallo más fino que has visto en todo el proyecto.
>
> Que **la herencia es lo que evita tener que acordarse.** Un permiso puesto a mano funciona una vez; uno heredado funciona siempre. Y que un fallo de herencia no rompe nada hoy: va degradando la carpeta poco a poco, hasta que alguien se queja semanas después y ya no hay ningún cambio reciente al que señalar.
>
> Que **denegar el acceso y ocultar la existencia son dos capas distintas.** Los nombres de las carpetas son información: `nominas`, `expedientes`, `direccion` dicen mucho a quien no debería estar mirando.
>
> Que un **fichero de configuración roto no rompe nada hasta que el servicio lo relee** — y que eso te da una ventana para descubrirlo, si usas el validador. `testparm` aquí, `mount -a` en la Fase 6, `nginx -t` el día de mañana. **Un servicio que sigue funcionando no demuestra que su configuración sea válida.**
>
> Y la que más te va a costar aceptar: **hay configuraciones que no se pueden verificar desde donde se escriben.** Esta fase se termina de comprobar en la siguiente, y por eso se te ha pedido anotar cuatro pruebas pendientes en lugar de dar el trabajo por cerrado.
>
> **Siguiente:** Fase 8 — El cliente Windows se une al dominio. Ahí se comprueba, por fin, todo lo que llevas construido.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.10.a_Laboratorio_de_Averias]] | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | **Fase 8** |
