## 🍎 Fase 10: Integración del Cliente (macOS)

### Infraestructura de Laboratorio Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Linux como servidor de dominio / Linux como cliente de dominio]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos)
> **Requisitos:** un **Mac real** (ver el aviso de abajo) | acceso a la red del laboratorio `10.10.10.0/24` | Samba completo (Fases 1-9)
>
> **📦 Entrega:** una entrada de apuntes + **tres vídeos** + instantánea `Fase 10 terminada` (servidor)

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_10_Integracion_del_Cliente_macOS/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase son TRES entregas de vídeo** —procedimiento, verificación y laboratorio de averías— sobre **una sola entrada de apuntes**.

> [!danger] 🛑 ANTES DE NADA — qué necesita esta fase, y qué NO sirve
> **Esta fase necesita un Mac real.** No una VM de macOS en un PC Windows: eso es un *hackintosh* — viola la licencia de Apple, y en un PC con VBS activada choca con el mismo muro de la tortuga que ya viste en la Fase 8.
>
> - ✅ **Sí vale:** tu Mac (o una VM de macOS **dentro de tu Mac**, que Apple sí permite).
> - ❌ **No vale:** una VM de macOS en un equipo Windows o Linux.
>
> **Y esta fase NO se une al dominio** (eso ya lo hiciste con Windows y Ubuntu). El macOS **accede** a las carpetas compartidas como un cliente, igual que accede un turista con su MacBook a una red de empresa. Es la vía legal y real.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-10-integracion-del-cliente-macos.md
> ```
>
> | Mientras lees… | Anota |
> | :--- | :--- |
> | **1 · Qué se evalúa** | Los CE que toca esta fase |
> | **2 · Entregables** | Lo particular de esta fase: nombres de vídeo, que NO hay VM que guardar |
> | **3 · Grabación** | Lo que hay que decir en voz alta |
> | **4 · Dónde estamos** | De qué depende esta fase |
> | **5 · Fundamento** | 🔴 Los conceptos y las preguntas |
> | **6 · Procedimiento** | Los pasos, errores y cómo los resuelves |
> | **7 al 10** | Comprobaciones y respuestas |

| # | Apartado | Cuándo se lee |
| :--- | :--- | :--- |
| **1** | [[Fase_10.1_Que_Se_Evalua]] | Antes de empezar — qué se te evalúa |
| **2** | [[Fase_10.2_Entregables]] | Antes de empezar — qué debes producir |
| **3** | [[Fase_10.3_Obligaciones_Grabacion]] | Antes de arrancar OBS |
| **4** | [[Fase_10.4_Donde_Estamos]] | Antes de empezar — de dónde vienes |
| **5** | [[Fase_10.5_Fundamento_Teorico]] | Antes de teclear — los conceptos |
| **6** | [[Fase_10.6_Procedimiento]] | **Con el Mac delante — aquí está el trabajo** |
| **7** | [[Fase_10.7_Resolucion_Problemas]] | Cuando algo no salga |
| **8.a** | [[Fase_10.8.a_Verificacion]] | 🔍 Al terminar — comprueba, después guarda |
| **8.b** | [[Fase_10.8.b_Punto_de_Control]] | 💾 Instantánea del servidor |
| **9** | [[Fase_10.9_Preguntas]] | Después — trabajo de mesa |
| **10.a** | [[Fase_10.10.a_Laboratorio_de_Averias]] | 🔨 Romper el acceso a propósito |
| **10.b** | [[Fase_10.10.b_Auditoria_y_Cierre]] | Lo último — checklist antes de la Auditoría |

> [!tip] 💡 Cómo se recorre
> - El **4 y el 5** te preparan. El **6** es el trabajo. El **7** solo si algo falla.
> - El **8.a y el 8.b** en orden: primero comprueba, después guarda.
> - El **10.a** es donde de verdad se aprende.

> [!success] 🎯 Esta fase cierra el RA.06
> Windows (Fase 8), Ubuntu (Fase 9) y ahora **macOS** (Fase 10) — tres sistemas operativos distintos accediendo al mismo servidor y viendo lo mismo. Es la integración de sistemas operativos libres y propietarios en su forma más completa: **el mismo modelo de permisos, tres clientes.**

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.06** — CE.06.a · CE.06.b · CE.06.e · CE.06.i
>
> El detalle, con dónde demuestras cada criterio: [[Fase_10.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** la Auditoría Final.
