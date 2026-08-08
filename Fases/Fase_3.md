## 🔒 Fase 3: Conectividad VPN (WireGuard)

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 9: Gestión remota e Integración en Red]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM VirtualBox con Red Solo Anfitrión operativa | Cliente WireGuard | SSH
>
> **📦 Entrega:** una entrada de apuntes + un vídeo + la instantánea `Fase 3 terminada`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en diez documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_3/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase completa es UNA sola entrega:** una entrada de apuntes y un vídeo, no diez.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-3-conectividad-vpn.md
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
| **1**    | [[Fase_3.1_Que_Se_Evalua]]             | Antes de encender la VM — qué se te evalúa                              |
| **2**    | [[Fase_3.2_Entregables]]               | Antes de encender la VM — qué debes producir                            |
| **3**    | [[Fase_3.3_Obligaciones_Grabacion]]    | Antes de arrancar OBS — cómo se graba y se entrega                      |
| **4**    | [[Fase_3.4_Donde_Estamos]]             | Antes de empezar — de dónde vienes y a dónde llegas                     |
| **5**    | [[Fase_3.5_Fundamento_Teorico]]        | Antes de teclear — los conceptos                                        |
| **6**    | [[Fase_3.6_Procedimiento]]             | *(índice)* **Con la VM delante — aquí está el trabajo**, en 3 partes ↓  |
| **6.a**  | [[Fase_3.6.a_Procedimiento_Servidor]]  | Llaves del servidor y su `wg0.conf`                                     |
| **6.b**  | [[Fase_3.6.b_Procedimiento_Cliente_e_Intercambio]] | El cliente y el **cruce de llaves públicas**                |
| **6.c**  | [[Fase_3.6.c_Procedimiento_Levantar_el_Tunel]] | Levantar el túnel y comprobar qué lleva dentro              |
| **7**    | [[Fase_3.7_Resolucion_Problemas]]      | Cuando algo no salga — búscate por el síntoma                           |
| **8.a**  | [[Fase_3.8.a_Verificacion]]            | 🔍 **Verificar** que el túnel funciona — antes de guardar nada          |
| **8.b**  | [[Fase_3.8.b_Punto_de_Control]]        | 💾 Instantánea **y copia al disco externo**                             |
| **9**    | [[Fase_3.9_Preguntas]]                 | Después de la instantánea — trabajo de mesa                             |
| **10.a** | [[Fase_3.10.a_Laboratorio_de_Averias]] | 🔨 Romper cosas a propósito para entender qué detecta cada comprobación |
| **10.b** | [[Fase_3.10.b_Auditoria_y_Cierre]]     | 🏁 Checklist final antes de la Fase 4                                   |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - Los apartados **8, 9 y 10** cierran, **en ese orden**: primero aseguras la máquina, luego escribes, luego compruebas que no te dejas nada.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.01 · RA.04 · RA.06** — CE.01.i · CE.04.f · CE.06.b · CE.06.h
>
> El detalle, con dónde demuestras cada criterio: [[Fase_3.1_Que_Se_Evalua]]

**Siguiente al terminar los diez apartados:** Fase 4.
