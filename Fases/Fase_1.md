## 🏗️ Fase 1: Infraestructura Virtual Local (VirtualBox)

### Construir el servidor dentro de tu propio ordenador

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~3 horas repartidas en cuatro sesiones
> **Requisitos:** VirtualBox instalado · ~2 GB de RAM libres · ~20 GB de disco libres
>
> **📦 Entrega:** **cuatro** entradas de apuntes + **cuatro** vídeos + **dos** instantáneas

---

## 🧭 Índice de la fase

> [!warning] 📖 El procedimiento de esta fase va en CUATRO partes
> Son ~3 horas de trabajo. Un solo vídeo saldría de 40 minutos y no lo vería nadie.
>
> Por eso el **apartado 6 se abre en `6.a`, `6.b`, `6.c` y `6.d`** — cada una es una entrega independiente con su vídeo corto. **El resto de apartados son comunes a las cuatro.**

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
| **7** | [[Fase_1.7_Resolucion_Problemas]] | Cuando algo no salga — 10 incidentes reales |
| **8** | [[Fase_1.8_Punto_de_Control]] | Al terminar 6.c y 6.d — las dos instantáneas |
| **9** | [[Fase_1.9_Preguntas]] | Después de las instantáneas — trabajo de mesa |
| **10** | [[Fase_1.10_Auditoria_y_Cierre]] | Lo último — la checklist antes de la Fase 2 |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - Las **cuatro partes del 6 son el trabajo**, y van **en orden**. Cada una necesita la anterior terminada.
> - El **7** solo si algo falla.
> - Los apartados **8, 9 y 10** cierran, **en ese orden**: primero aseguras la máquina, luego escribes, luego compruebas que no te dejas nada.

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
>
> El detalle, con dónde demuestras cada criterio: [[Fase_1.1_Que_Se_Evalua]]

> [!important] 💾 Antes de empezar, lee esto una vez
> **[[Fase_0.S_Instantaneas_Puntos_de_Control]]** — cómo tomar un punto de control para poder volver atrás si algo se rompe. Son dos clics y te ahorra reinstalar el servidor entero.

**Siguiente al terminar los diez apartados:** Fase 2 — Purga y Preparación del Entorno.
