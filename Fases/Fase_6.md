## 💾 Fase 6: Almacenamiento Virtual (Cuotas con Loop Devices)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5: Administración en Linux - Cuotas de Discos]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 4 GB RAM | 11 GB disco libre | SSH (o consola de VirtualBox)
>
> **📦 Entrega:** una entrada de apuntes + **tres vídeos** + la instantánea `Fase 6 terminada` + la copia `.ova`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_6/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase son TRES entregas de vídeo** —procedimiento, punto de control y laboratorio de averías— sobre **una sola entrada de apuntes**.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-f6-almacenamiento-virtual.md
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
| **1** | [[Fase_6.1_Que_Se_Evalua]] | Antes de encender la VM — qué se te evalúa |
| **2** | [[Fase_6.2_Entregables]] | Antes de encender la VM — qué debes producir |
| **3** | [[Fase_6.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega |
| **4** | [[Fase_6.4_Donde_Estamos]] | Antes de empezar — de dónde vienes y a dónde llegas |
| **5** | [[Fase_6.5_Fundamento_Teorico]] | Antes de teclear — los conceptos |
| **6** | [[Fase_6.6_Procedimiento]] | **Con la VM delante — aquí está el trabajo** |
| **7** | [[Fase_6.7_Resolucion_Problemas]] | Cuando algo no salga — búscate por el síntoma |
| **8.a** | [[Fase_6.8.a_Verificacion]] | 🔍 Al terminar el procedimiento — **antes** de guardar y de reiniciar |
| **8.b** | [[Fase_6.8.b_Punto_de_Control]] | 💾 Después de verificar — la instantánea y la copia |
| **9** | [[Fase_6.9_Preguntas]] | Después de la instantánea — trabajo de mesa |
| **10.a** | [[Fase_6.10.a_Laboratorio_de_Averias]] | 🔨 Romper el almacenamiento a propósito, y repararlo |
| **10.b** | [[Fase_6.10.b_Auditoria_y_Cierre]] | Lo último — la checklist antes de seguir |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - El **8.a y el 8.b van en ese orden y no se intercambian**: primero se comprueba, después se guarda.
> - El **9** es trabajo de mesa, y el **10.a** es donde de verdad se aprende: rompes lo que acabas de construir, con la red de seguridad ya puesta.

> [!danger] 🛑 Esta fase tiene el fallo más aparatoso del proyecto
> Es el único sitio donde **una errata impide que el servidor arranque**: `/etc/fstab` se ejecuta en cada encendido, y si está mal, la máquina se queda en modo emergencia.
>
> Por eso el **8.a es obligatorio antes de apagar o reiniciar**, y por eso existe `sudo mount -a`: es un ensayo del arranque que puedes hacer **sin arrancar**.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.01 · RA.04 · RA.05** — CE.01.d · CE.04.b · CE.05.b
>
> El detalle, con dónde demuestras cada criterio: [[Fase_6.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** Fase 7.
