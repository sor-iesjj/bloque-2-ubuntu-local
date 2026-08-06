## 🕵️ Fase 7: Seguridad Avanzada (ACLs y ABE)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5 y 8: Gestión avanzada de permisos / Compartición SAMBA]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 4 GB RAM | Discos virtuales montados | Samba activo
>
> **📦 Entrega:** una entrada de apuntes + **tres vídeos** + la instantánea `Fase 7 terminada` + la copia `.ova`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_7/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase son TRES entregas de vídeo** —procedimiento, punto de control y laboratorio de averías— sobre **una sola entrada de apuntes**.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-f7-seguridad-avanzada.md
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
| **1** | [[Fase_7.1_Que_Se_Evalua]] | Antes de encender la VM — qué se te evalúa |
| **2** | [[Fase_7.2_Entregables]] | Antes de encender la VM — qué debes producir |
| **3** | [[Fase_7.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega |
| **4** | [[Fase_7.4_Donde_Estamos]] | Antes de empezar — de dónde vienes y a dónde llegas |
| **5** | [[Fase_7.5_Fundamento_Teorico]] | Antes de teclear — los conceptos |
| **6** | [[Fase_7.6_Procedimiento]] | **Con la VM delante — aquí está el trabajo** |
| **7** | [[Fase_7.7_Resolucion_Problemas]] | Cuando algo no salga — búscate por el síntoma |
| **8.a** | [[Fase_7.8.a_Verificacion]] | 🔍 Al terminar el procedimiento — **antes** de guardar |
| **8.b** | [[Fase_7.8.b_Punto_de_Control]] | 💾 Después de verificar — la instantánea y la copia |
| **9** | [[Fase_7.9_Preguntas]] | Después de la instantánea — trabajo de mesa |
| **10.a** | [[Fase_7.10.a_Laboratorio_de_Averias]] | 🔨 Romper la seguridad a propósito, y repararla |
| **10.b** | [[Fase_7.10.b_Auditoria_y_Cierre]] | Lo último — la checklist antes de seguir |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - El **8.a y el 8.b van en ese orden y no se intercambian**: primero se comprueba, después se guarda.
> - El **9** es trabajo de mesa, y el **10.a** es donde de verdad se aprende: rompes lo que acabas de construir, con la red de seguridad ya puesta.

> [!danger] 🛑 Esta fase NO se puede verificar entera desde el servidor
> La mitad del trabajo es hacer **invisible** una carpeta para quien no tiene permiso — y la invisibilidad solo se ve **desde un cliente Windows**, que es la Fase 8.
>
> Desde Ubuntu, una carpeta bien protegida y una protegida a medias **se comportan igual**. Por eso el 8.a te deja dos pruebas anotadas como pendientes en lugar de dar el trabajo por cerrado.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.04** — CE.04.a · CE.04.b · CE.04.c · CE.04.d · CE.04.e · CE.04.f · CE.04.g
>
> El detalle, con dónde demuestras cada criterio: [[Fase_7.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** Fase 8.
