## 💻 Fase 8: Integración del Cliente (Windows 11)

### Infraestructura de Laboratorio Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Linux como servidor de dominio / Linux como cliente de dominio]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (creación de VM + teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VirtualBox instalado en el equipo | ISO de Windows 11 | 4 GB RAM libres para la nueva VM | 40 GB de disco libres | Samba completo (Fases 1-7)
>
> **📦 Entrega:** una entrada de apuntes + **tres vídeos** + **dos instantáneas** `Fase 8 terminada` (cliente y servidor) + **dos copias** `.ova`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_8/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase son TRES entregas de vídeo** —procedimiento, punto de control y laboratorio de averías— sobre **una sola entrada de apuntes**.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-f8-integracion-del-cliente.md
> ```
>
> **Por qué ahora y no cuando empieces a teclear:** porque **hay cosas que anotar desde el primer apartado**. Si abres el cuaderno cuando ya llevas cinco documentos leídos, o vuelves atrás a buscarlas, o las pierdes.
>
> | Mientras lees… | Anota |
> | :--- | :--- |
> | **1 · Qué se evalúa** | Los CE que toca esta fase, para saber qué te van a mirar |
> | **2 · Entregables** | Lo que tiene de particular **esta** fase: nombres de fichero, número de vídeos |
> | **3 · Grabación** | Lo que hay que decir **en voz alta** en cada vídeo. Es lo que más se olvida |
> | **4 · Dónde estamos** | De qué fase depende esta, por si algo falla luego |
> | **5 · Fundamento teórico** | 🔴 **Los conceptos con tus palabras y las preguntas de comprensión.** Aquí es donde más se escribe |
> | **6 · Procedimiento** | Lo que va pasando, los errores que te salen y cómo los resuelves |
> | **7 al 10** | Comprobaciones, predicciones de las averías y respuestas |
>
> **Una entrada de apuntes no es un formulario que se rellena al final: es el cuaderno donde trabajas.** Si la escribes de memoria cuando ya has terminado, se nota — y se corrige como lo que es.

| # | Apartado | Cuándo se lee |
| :--- | :--- | :--- |
| **1** | [[Fase_8.1_Que_Se_Evalua]] | Antes de encender la VM — qué se te evalúa |
| **2** | [[Fase_8.2_Entregables]] | Antes de encender la VM — qué debes producir |
| **3** | [[Fase_8.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega |
| **4** | [[Fase_8.4_Donde_Estamos]] | Antes de empezar — de dónde vienes y a dónde llegas |
| **5** | [[Fase_8.5_Fundamento_Teorico]] | Antes de teclear — los conceptos |
| **6** | [[Fase_8.6_Procedimiento]] | **Con la VM delante — aquí está el trabajo** |
| **7** | [[Fase_8.7_Resolucion_Problemas]] | Cuando algo no salga — búscate por el síntoma |
| **8.a** | [[Fase_8.8.a_Verificacion]] | 🔍 Al terminar — **la prueba que quedó pendiente en la Fase 7** |
| **8.b** | [[Fase_8.8.b_Punto_de_Control]] | 💾 Después de verificar — instantáneas de **las dos** máquinas |
| **9** | [[Fase_8.9_Preguntas]] | Después de la instantánea — trabajo de mesa |
| **10.a** | [[Fase_8.10.a_Laboratorio_de_Averias]] | 🔨 Romper la integración a propósito, y repararla |
| **10.b** | [[Fase_8.10.b_Auditoria_y_Cierre]] | Lo último — la checklist antes de la Auditoría Final |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - El **8.a y el 8.b van en ese orden y no se intercambian**: primero se comprueba, después se guarda.
> - El **9** es trabajo de mesa, y el **10.a** es donde de verdad se aprende.

> [!success] 🎯 Esta fase es el examen de las siete anteriores
> Todo lo que has construido desde la Fase 1 era una promesa. **Aquí se comprueba desde donde importa: el lado del usuario.**
>
> Y por eso, cuando algo falle aquí, la causa casi nunca estará en esta fase. Aprender a rastrearla hacia atrás es el objetivo.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.02 · RA.04 · RA.06** — CE.02.c · CE.04.e · CE.06.a · CE.06.b · CE.06.c · CE.06.d · CE.06.e · CE.06.f · CE.06.g · CE.06.h · CE.06.i
>
> El detalle, con dónde demuestras cada criterio: [[Fase_8.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** la Auditoría Final.
