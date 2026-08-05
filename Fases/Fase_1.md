## 🏗️ Fase 1: Infraestructura Virtual Local (VirtualBox)

### Construir el servidor dentro de tu propio ordenador

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~5 horas repartidas en varias sesiones
> **Requisitos:** VirtualBox instalado · ~2 GB de RAM libres · ~20 GB de disco libres · **disco externo USB**
>
> **📦 Entrega:** **siete** entradas de apuntes + **siete** vídeos + **dos** instantáneas + **una copia `.ova`**

---

## 🧭 Índice de la fase

> [!warning] 📖 El procedimiento de esta fase va en PARTES
> Son ~5 horas de trabajo. Un solo vídeo saldría de una hora y no lo vería nadie.
>
> Por eso el **apartado 6 se abre en `6.a`, `6.b`, `6.c`, `6.d` y `6.f`** — cada una es una entrega independiente con su vídeo corto. El `6.e` es opcional y no se entrega.
>
> Y hay **dos entregas más** que no son procedimiento: el **punto de control** (8.b) y el **laboratorio de averías** (10.a). Siete en total.

| # | Apartado | Cuándo se lee |
| :--- | :--- | :--- |
| **1** | [[Fase_1.1_Que_Se_Evalua]] | Antes de encender nada — qué se te evalúa |
| **2** | [[Fase_1.2_Entregables]] | Antes de encender nada — qué debes producir |
| **3** | [[Fase_1.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega |
| **4** | [[Fase_1.4_Donde_Estamos]] | Antes de empezar — el recorrido completo |
| **5** | [[Fase_1.5_Fundamento_Teorico]] | Antes de teclear — los conceptos de cada parte |
| **6.a** | [[Fase_1.6.a_Procedimiento_Maquina_Virtual]] | 🖥️ **Entrega 1** — crear la VM · ~40 min |
| **6.b** | [[Fase_1.6.b_Procedimiento_Red_Laboratorio]] | 🔌 **Entrega 2** — las dos tarjetas de red · ~45 min |
| **6.c** | [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]] | 💿 **Entrega 3** — instalar el sistema · ~1 h |
| **6.d** | [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] | ✅ **Entrega 4** — verificar y entrar por SSH · ~45 min |
| **6.e** | [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]] | 🌐 *Opcional* — solo si administras desde otro equipo de la red · ~20 min |
| **7** | [[Fase_1.7_Resolucion_Problemas]] | Cuando algo no salga — 13 incidentes reales |
| **8.a** | [[Fase_1.8.a_Verificacion]] | 🔍 Al terminar 6.d — comprobar **antes** de guardar · va en el vídeo de la entrega 4 |
| **8.b** | [[Fase_1.8.b_Punto_de_Control]] | 💾 **Entrega 5** — instantánea y copia al disco externo · ~20 min |
| **6.f** | [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar]] | 👥 **Entrega 6** — exportar tu servidor e intercambiarlo con un compañero · ~50 min |
| **9** | [[Fase_1.9_Preguntas]] | Trabajo de mesa — las preguntas críticas |
| **10.a** | [[Fase_1.10.a_Laboratorio_de_Averias]] | 🔨 **Entrega 7** — romper seis cosas a propósito · **en 2 sesiones** |
| **10.b** | [[Fase_1.10.b_Auditoria_y_Cierre]] | Lo último — la checklist antes de la Fase 2 |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - Las partes **6.a → 6.d son el trabajo**, y van **en orden**. Cada una necesita la anterior terminada.
> - El **6.e es opcional** y no se entrega: solo lo necesitas si administras el servidor desde **otro ordenador** de la red. En el aula, no.
> - El **7** solo si algo falla.
> - El **8.a y el 8.b** van seguidos y en ese orden: **primero se comprueba, después se guarda**.
> - El **6.f** necesita la instantánea del 8.b y **se hace por parejas**. Por eso aparece aquí abajo aunque su número sea 6.
> - El **10.a** necesita también la instantánea: sin punto de retorno no se rompe nada.

> [!warning] ⚠️ El orden de los números NO es el orden de trabajo
> Fíjate en la tabla: el **6.f va después del 8.b**. No es un error.
>
> Los números indican **qué tipo de apartado** es (el 6 es procedimiento, el 8 es punto de control). El orden de la tabla indica **cuándo se hace**. Cuando los dos no coinciden, manda la tabla.
>
> **Orden real de trabajo:** `6.a` → `6.b` → `6.c` → 💾 `Sistema base` → `6.d` → `8.a` → `8.b` → `6.f` → `9` → `10.a` → `10.b`

---

### 🎯 Qué vas a conseguir

> [!success] El resultado de la Fase 1
> Un **servidor Ubuntu Server 26.04 LTS** corriendo en tu propio ordenador, con:
> - Dos tarjetas de red: **NAT** para Internet, **sólo-anfitrión** para el laboratorio
> - IP fija **`10.10.10.10`** en una red privada `10.10.10.0/24`, aislada de la red del instituto
> - Usuario `boochan` y acceso **por SSH desde tu propia terminal**
> - El nombre del dominio del proyecto anotado: `BOOCHANLAB` / `BOOCHANLAB.LOCAL`
>
> Sobre eso se construye todo BoochanV1.

> [!abstract] 📋 Qué se te evalúa (resumen)
> **`RA.01`** *(35 % del módulo, el más alto)* — `CE.01.a` · `CE.01.b` · `CE.01.c` · `CE.01.e` · `CE.01.g` · `CE.01.i`
> **`RA.06`** *(12 %)* — `CE.06.g`, en la entrega **por parejas** del `6.f`
>
> El detalle, con dónde demuestras cada criterio: [[Fase_1.1_Que_Se_Evalua]]

> [!important] 💾 Antes de empezar, lee esto una vez
> **[[Fase_0.S_Instantaneas_Puntos_de_Control]]** — cómo tomar un punto de control para poder volver atrás si algo se rompe. Son dos clics y te ahorra reinstalar el servidor entero.

**Siguiente al terminar todos los apartados:** Fase 2 — Purga y Preparación del Entorno.
