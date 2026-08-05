## 🏢 El escenario: Boochan S.L.

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Referencia común de las fases 5 a 8**
>
> **📍 Cuándo se lee:** **Antes de la Fase 5**, y se vuelve a él cada vez que dudes de un nombre, un número o un permiso.

---

> [!abstract] 📌 Qué es este documento
> A partir de la Fase 5 dejas de montar un laboratorio abstracto y empiezas a montar **la infraestructura de una empresa concreta**: seis departamentos, doce trabajadores y un conjunto de reglas de acceso que no te has inventado tú.
>
> **Esta es la fuente de verdad.** Los nombres, los números y los permisos que aparecen en las fases 5, 6, 7 y 8 salen todos de aquí. Si en algún sitio hay una discrepancia, **manda esta página**.

---

## **1 · LA EMPRESA**

**Boochan S.L.** es una distribuidora de tamaño medio. Tiene cinco departamentos operativos y un programa de prácticas:

| Departamento | Qué hace |
| :--- | :--- |
| **Facturación** | Emite y custodia las facturas |
| **Contabilidad** | Lleva las cuentas y cierra los balances |
| **Comercial** | Vende, gestiona clientes y pedidos |
| **Logística** | Almacén, envíos y transporte |
| **RRHH** | Nóminas, contratos y expedientes personales |
| **Becarios** | Estudiantes en prácticas |

---

## **2 · LOS GRUPOS Y SUS GID**

```
facturacion   3001
contabilidad  3002
comercial     3003
logistica     3004
rrhh          3005
becarios      3006
```

---

## **3 · LOS DOCE USUARIOS**

Formato de nombre de usuario: **`nombre.apellido`**, todo en minúsculas.

| Usuario | Nombre completo | Grupo | UID |
| :--- | :--- | :--- | :--- |
| `hiroshi.nohara` | Hiroshi Nohara | facturacion | 10001 |
| `nene.sakurada` | Nene Sakurada | facturacion | 10002 |
| `misae.nohara` | Misae Nohara | contabilidad | 10003 |
| `toru.kazama` | Toru Kazama | contabilidad | 10004 |
| `masao.sato` | Masao Sato | comercial | 10005 |
| `ai.suotome` | Ai Suotome | comercial | 10006 |
| `bo.suzuki` | Bo Suzuki | logistica | 10007 |
| `midori.yoshinaga` | Midori Yoshinaga | logistica | 10008 |
| `ume.matsuzaka` | Ume Matsuzaka | rrhh | 10009 |
| `bunta.takakura` | Bunta Takakura | rrhh | 10010 |
| `shinnosuke.nohara` | Shinnosuke Nohara | becarios | 10011 |
| `himawari.nohara` | Himawari Nohara | becarios | 10012 |

**Contraseña de todos:** `P@ssw0rd`

> [!warning] ⚠️ Los UID y GID no son decorativos
> Son **exactamente** los que se usan en las fases 6, 7 y 8. Si un usuario acaba con otro número, los permisos que le des después no le alcanzarán — y no dará ningún error.

---

## **4 · LAS CARPETAS**

```
/srv/samba/
├── departamentos/          ← disco virtual de 8 GB
│   ├── facturacion/
│   ├── contabilidad/
│   ├── comercial/
│   ├── logistica/
│   ├── rrhh/
│   └── becarios/
└── comun/                  ← disco virtual de 2 GB, aparte
```

**Dos discos, no siete.** Los seis departamentos comparten un volumen de 8 GB y la carpeta común tiene el suyo, de 2 GB.

> [!info] 🎓 Por qué la común tiene un disco pequeño y aparte
> Porque una carpeta donde todo el mundo puede escribir **se convierte en un vertedero**. Es una ley no escrita de la administración de sistemas.
>
> Dándole su propio volumen de 2 GB, cuando se llene **solo se llena ella**: los departamentos siguen funcionando. Si compartiera disco con ellos, un usuario subiendo vídeos a la común dejaría sin espacio a contabilidad.
>
> **Aislar lo que se puede descontrolar** es una decisión de diseño, no una limitación técnica.

---

## **5 · 🔴 LA MATRIZ DE PERMISOS**

**Esta tabla es el corazón del proyecto.** Todo lo que hagas en las fases 6, 7 y 8 sirve para que esta tabla se cumpla exactamente.

| Grupo ↓ · Carpeta → | factur. | contab. | comerc. | logíst. | rrhh | becarios | comun |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **facturacion** | **RW** | — | R | — | — | — | RW* |
| **contabilidad** | **RW** | **RW** | R | R | — | — | RW* |
| **comercial** | R | — | **RW** | R | — | — | RW* |
| **logistica** | — | — | R | **RW** | — | — | RW* |
| **rrhh** | — | — | — | — | **RW** | R | RW* |
| **becarios** | — | — | — | — | — | **R** | — |

**Leyenda:** **RW** = leer y escribir · R = solo lectura · — = sin acceso *(y sin verla siquiera)* · RW* = escribir sí, pero **solo puede borrar lo suyo**

---

## **6 · POR QUÉ LA MATRIZ ES ASÍ** *(esto entra en el examen)*

**6A — Comercial lee facturación, pero no escribe.**
Un comercial necesita saber si su cliente ha pagado. **No puede tocar la factura.** Si pudiera, el mismo que cobra la comisión podría modificar el importe facturado — y eso es exactamente lo que impide el control interno de cualquier empresa seria.

**6B — Contabilidad sí escribe en facturación.**
Son el mismo circuito de dinero: contabilidad corrige, ajusta y cierra lo que facturación emite.

**6C — 🔴 RRHH es una isla. Ni contabilidad entra.**
Aquí hay nóminas, contratos y expedientes. **El departamento que ve todo el dinero de la empresa no puede ver los sueldos de sus compañeros**, y esa aparente contradicción es la regla más importante de la tabla.

> [!question] 🤔 La pregunta que te van a hacer
> *"Si contabilidad paga las nóminas, ¿cómo puede ser que no acceda a RRHH?"*
>
> Piénsalo antes de seguir leyendo. **La respuesta:** contabilidad necesita el **importe total** a pagar, no el expediente de cada persona. Acceso a lo que necesitas para tu trabajo, y **nada más**. Se llama **principio de mínimo privilegio**, y es el criterio que sostiene toda esta tabla.

**6D — RRHH sí lee `becarios`.**
Gestiona sus convenios de prácticas y necesita ver su trabajo. Solo lectura: no es su carpeta.

**6E — Logística y comercial se leen entre ellos.**
Logística necesita ver los pedidos que hay que enviar. Comercial necesita ver el estado de los envíos. Ninguno escribe en el del otro.

**6F — Los becarios solo leen, y solo lo suyo.**
No crean, no borran, no editan. Y **no ven ninguna otra carpeta**. Es lo que se le da a alguien que llega la semana que viene y se va en tres meses.

**6G — La carpeta común: todos escriben, cada uno borra lo suyo.**
Para intercambiar ficheros entre departamentos. La restricción de borrado evita el problema clásico de las carpetas compartidas: **que alguien borre, por error o por prisa, el trabajo de otro.**

---

## **7 · LAS PRUEBAS QUE HARÁS EN LA FASE 8**

Todo esto se comprueba **desde el cliente Windows**, iniciando sesión con usuarios distintos:

| # | Quién | Qué intenta | Debe pasar | Qué demuestra |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `shinnosuke.nohara` | Ver `contabilidad` | **Ni siquiera aparece** | Invisibilidad (ABE) |
| 2 | `shinnosuke.nohara` | Borrar en `becarios` | **Denegado** | Solo lectura |
| 3 | `masao.sato` | Abrir una factura | **Funciona** | Lectura cruzada |
| 4 | `masao.sato` | Borrar esa factura | **Denegado** | Ver ≠ modificar |
| 5 | `misae.nohara` | Escribir en `facturacion` | **Funciona** | Permiso cruzado RW |
| 6 | `nene.sakurada` | Borrar en `comun` el fichero de otro | **Denegado** | Sticky bit |
| 7 | `misae.nohara` | Ver `rrhh` | **Ni siquiera aparece** | Mínimo privilegio |

> [!success] 🎯 Ese es el objetivo del proyecto entero
> No es "montar un servidor". Es que **no se pueda hacer nada que no esté autorizado** — y poder demostrarlo, una prueba por regla.

---

## **8 · RESUMEN PARA TENER AL LADO**

```
GRUPOS   facturacion 3001 · contabilidad 3002 · comercial 3003
         logistica 3004 · rrhh 3005 · becarios 3006

UID      10001 hiroshi.nohara      10007 bo.suzuki
         10002 nene.sakurada       10008 midori.yoshinaga
         10003 misae.nohara        10009 ume.matsuzaka
         10004 toru.kazama         10010 bunta.takakura
         10005 masao.sato          10011 shinnosuke.nohara
         10006 ai.suotome          10012 himawari.nohara

CLAVE    P@ssw0rd  (todos)
DOMINIO  BOOCHANLAB.LOCAL   ·   SERVIDOR  10.10.10.10
```

---

> [!info] 📚 Dónde se usa este escenario
> - **Fase 5** — se crean los grupos y los usuarios
> - **Fase 6** — se crean las carpetas y sus discos con cuota
> - **Fase 7** — se aplican los permisos de la matriz
> - **Fase 8** — se comprueban desde Windows, usuario por usuario
