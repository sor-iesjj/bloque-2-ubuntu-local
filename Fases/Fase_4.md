## 👑 Fase 4: Aprovisionamiento del Dominio (Samba AD DC)

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Integración de Sistemas Operativos - Servidor de Dominio]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM con 3072-4096 MB RAM asignados en VirtualBox (según la nota de dimensionado de la Fase 1) | Git | Samba disponible
>
> **📦 Entrega:** una entrada de apuntes + un vídeo + la instantánea `Fase 4 terminada`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_4/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase completa es UNA sola entrega:** una entrada de apuntes y un vídeo, no diez.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-4-aprovisionamiento-del-dominio.md
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

| #        | Apartado                               | Cuándo se lee                                                           |
| :------- | :------------------------------------- | :---------------------------------------------------------------------- |
| **1**    | [[Fase_4.1_Que_Se_Evalua]]             | Antes de encender la VM — qué se te evalúa                              |
| **2**    | [[Fase_4.2_Entregables]]               | Antes de encender la VM — qué debes producir                            |
| **3**    | [[Fase_4.3_Obligaciones_Grabacion]]    | Antes de arrancar OBS — cómo se graba y se entrega                      |
| **4**    | [[Fase_4.4_Donde_Estamos]]             | Antes de empezar — de dónde vienes y a dónde llegas                     |
| **5**    | [[Fase_4.5_Fundamento_Teorico]]        | Antes de teclear — los conceptos                                        |
| **6**    | [[Fase_4.6_Procedimiento]]             | **Con la VM delante — aquí está el trabajo**                            |
| **7**    | [[Fase_4.7_Resolucion_Problemas]]      | Cuando algo no salga — 10 incidentes reales, búscate por el síntoma     |
| **8.a**  | [[Fase_4.8.a_Verificacion]]            | 🔍 Al terminar el 6 — comprobar **antes** de guardar · va en el vídeo 1 |
| **8.b**  | [[Fase_4.8.b_Punto_de_Control]]        | 💾 **Entrega 3** — instantánea y copia al disco externo                 |
| **9**    | [[Fase_4.9_Preguntas]]                 | Trabajo de mesa — las preguntas críticas                                |
| **10.a** | [[Fase_4.10.a_Laboratorio_de_Averias]] | 🔨 **Entrega 2** — romper el dominio seis veces · **en 2 sesiones**     |
| **10.b** | [[Fase_4.10.b_Auditoria_y_Cierre]]     | Lo último — la checklist antes de la Fase 5                             |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - Los apartados **8, 9 y 10** cierran, **en ese orden**: primero aseguras la máquina, luego escribes, luego compruebas que no te dejas nada.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.03** — CE.03.a · CE.03.b · CE.03.c · CE.03.d · CE.03.e · CE.03.f · CE.03.g · CE.03.h
>
> El detalle, con dónde demuestras cada criterio: [[Fase_4.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** Fase 5.
