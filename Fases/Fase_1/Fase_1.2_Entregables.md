## Fase 1 · Apartado 2 — ✅ Qué tienes que entregar

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Antes de encender nada.** Te dice qué tienes que producir.

---

> [!danger] 🛑 ESTO ES UN KIT. SI FALTA UNA PIEZA, LA FASE NO SE CORRIGE
> No hay entregas parciales ni elementos orientativos. **O está todo, o la fase queda anulada.**
>
> No es rigidez por gusto: cada pieza demuestra algo que las demás no. Un vídeo sin apuntes no demuestra que lo hayas entendido; unos apuntes sin vídeo no demuestran que lo hayas hecho tú.

> [!warning] ⚠️ Esta fase se entrega en SIETE partes
> La Fase 1 son unas 5 horas de trabajo. Un solo vídeo saldría de una hora y no lo vería nadie — ni tú al repasarlo.
>
> Por eso va partida en **siete entregas independientes**: cada una con su entrada de apuntes y su vídeo corto.

---

## 📦 LAS SIETE ENTREGAS

**En este orden. Cada una necesita la anterior terminada.**

| # | Apartado | Entrada de apuntes | Vídeo | Duración |
| :--- | :--- | :--- | :--- | :--- |
| **1** | [[Fase_1.6.a_Procedimiento_Maquina_Virtual\|6.a]] | `b2-f1-1-la-maquina-virtual.md` | `B2 · F1 · La máquina virtual` | ~6-8 min |
| **2** | [[Fase_1.6.b_Procedimiento_Red_Laboratorio\|6.b]] | `b2-f1-2-la-red-del-laboratorio.md` | `B2 · F1 · La red del laboratorio` | ~8-10 min |
| **3** | [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu\|6.c]] | `b2-f1-3-instalar-ubuntu-server.md` | `B2 · F1 · Instalar Ubuntu Server` | ~8-10 min |
| **4** | [[Fase_1.6.d_Procedimiento_Verificacion_SSH\|6.d]] **+** [[Fase_1.8.a_Verificacion\|8.a]] | `b2-f1-4-verificacion-y-acceso-remoto.md` | `B2 · F1 · Verificación y acceso remoto` | ~12-15 min |
| **5** | [[Fase_1.8.b_Punto_de_Control\|8.b]] | `b2-f1-5-punto-de-control.md` | `B2 · F1 · Punto de control` | ~3-4 min |
| **6** | [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar\|6.f]] | `b2-f1-6-clonar-e-intercambiar.md` | `B2 · F1 · Clonar e intercambiar` | ~10-12 min |
| **7** | [[Fase_1.10.a_Laboratorio_de_Averias\|10.a]] | `b2-f1-7-laboratorio-de-averias.md` | `B2 · F1 · Laboratorio de averías` | ~15-20 min · **en 2 sesiones** |

Todas las entradas van en `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/` y todos los vídeos en la playlist **`B2_Ubuntu_Local`** (No listado).

> [!info] 💡 Por qué la entrega 4 lleva dos apartados
> Porque en esta fase **verificar es el procedimiento**. El 6.d ya consiste en comprobar que la máquina existe y es alcanzable; el 8.a lo remata desde tu Windows. Partirlos en dos vídeos sería inventarse una frontera que no existe.

> [!note] 📌 ¿Y el 6.e? Es opcional y no se entrega
> [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]] solo lo necesitas si administras el servidor desde **otro ordenador** de la red. En el aula, no. Si lo haces, lo cuentas dentro de la entrada de la entrega 4.

> [!warning] ⚠️ La entrega 6 se hace **por parejas**
> Necesita la instantánea `Fase 1 terminada` **y un compañero** que haya llegado hasta ahí. Ponte de acuerdo con alguien antes de empezarla.

---

## 💾 Y ADEMÁS: DOS INSTANTÁNEAS Y UNA COPIA

| Qué | Cuándo | Por qué |
| :--- | :--- | :--- |
| 💾 Instantánea **`Sistema base`** | Al terminar la entrega **3** | Protege lo caro: instalar Ubuntu son 20-30 min. Con ella no lo repites nunca |
| 💾 Instantánea **`Fase 1 terminada`** | En la entrega **5** | Punto de partida limpio para la Fase 2, y **origen del clon** de la entrega 6 |
| 💿 **`B2-F1-infraestructura-virtual.ova`** | En la entrega **5** | La copia fuera de VirtualBox, en tu disco externo |

El detalle está en [[Fase_1.8.b_Punto_de_Control]].

> [!danger] 💾 La copia en el disco externo NO es opcional
> Una instantánea de VirtualBox **vive dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ella** — incluida `Sistema base`, que es media hora de tu vida.
>
> **Una copia que vive en el mismo sitio que el original no es una copia.**
>
> Y no es un trámite: más adelante se te pedirá **destruir tu servidor y recuperarlo desde esa copia**. Sin ella, esa práctica no la puedes hacer.

**Material necesario:** un **disco externo USB**. La estructura de carpetas es la misma que la del material:

```
SOR/
└── Bloque_2/
    └── Fases/
        └── Fase_1/
            └── B2-F1-infraestructura-virtual.ova
```

---

> [!danger] ⚠️ Los nombres NO son orientativos
> `B2` es el **bloque** · `F1` la **fase** · y después, qué se hace en ese vídeo. **Se llaman exactamente así.**
>
> Con un grupo entero entregando siete vídeos por fase, si cada uno pone lo que le apetece, corregir se vuelve imposible. **Un nombre distinto es una entrega no localizada — y una entrega no localizada es una entrega no presentada.**

> [!success] 🎯 Criterio de éxito
> Abro tu repositorio, encuentro las siete entradas, y en cada una está: qué has hecho, qué has entendido, qué dudas te quedaron y el enlace al vídeo donde se te ve haciéndolo.
>
> **Si falta cualquiera de las piezas, la fase no se corrige.**

> [!question] ✅ Repásalo antes de entregar
> - [ ] Las **siete entradas** de apuntes, con sus nombres exactos, subidas al repositorio.
> - [ ] Los **siete vídeos** en la playlist, con sus nombres exactos y sus timestamps.
> - [ ] Los **siete enlaces** dentro de sus entradas de apuntes.
> - [ ] Instantáneas **`Sistema base`** y **`Fase 1 terminada`** en VirtualBox.
> - [ ] `B2-F1-infraestructura-virtual.ova` en tu disco externo, en su carpeta.
> - [ ] Preguntas críticas contestadas.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.1_Que_Se_Evalua]] | [[Fase_1]] | [[Fase_1.3_Obligaciones_Grabacion]] |
