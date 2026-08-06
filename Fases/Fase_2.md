## 🧹 Fase 2: Purga y Preparación del Entorno

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5: Administración en Linux - Instalación y Configuración]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,25 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM VirtualBox encendida | Conectividad a internet vía adaptador NAT | SSH o consola de VirtualBox
>
> **📦 Entrega:** una entrada de apuntes + un vídeo + la instantánea `Fase 2 terminada`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en diez documentos, no en uno
> Cada apartado es un fichero aparte. **Se leen en orden**, pero puedes volver a cualquiera sin perderte el resto — al final de cada uno tienes la navegación.
>
> **La fase completa es UNA sola entrega:** una entrada de apuntes y un vídeo, no diez.

> [!important] ✍️ PASO 0 — Abre tu entrada de apuntes AHORA, antes de leer nada
> **No esperes al apartado 6.** Créala ya, vacía, y tenla abierta en una pestaña mientras lees:
>
> ```
> 00_Apuntes/Trimestre_N/B2_Ubuntu_Local/b2-f2-purga-y-preparacion.md
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

| #      | Apartado                            | Cuándo se lee                                       |
| :----- | :---------------------------------- | :-------------------------------------------------- |
| **1**  | [[Fase_2.1_Que_Se_Evalua]]          | Antes de encender la VM — qué se te evalúa          |
| **2**  | [[Fase_2.2_Entregables]]            | Antes de encender la VM — qué debes producir        |
| **3**  | [[Fase_2.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega  |
| **4**  | [[Fase_2.4_Donde_Estamos]]          | Antes de empezar — de dónde vienes y a dónde llegas |
| **5**  | [[Fase_2.5_Fundamento_Teorico]]     | Antes de teclear — los conceptos                    |
| **6**  | [[Fase_2.6_Procedimiento]]          | **Con la VM delante — aquí está el trabajo**        |
| **7**  | [[Fase_2.7_Resolucion_Problemas]]   | Cuando algo no salga — búscate por el síntoma       |
| **8.a** | [[Fase_2.8.a_Verificacion]] | 🔍 **Verificar** la identidad y los paquetes — antes de guardar nada |
| **8.b** | [[Fase_2.8.b_Punto_de_Control]] | 💾 Instantánea **y copia al disco externo** |
| **9**  | [[Fase_2.9_Preguntas]]              | Después de la instantánea — trabajo de mesa         |
| **10.a** | [[Fase_2.10.a_Laboratorio_de_Averias]] | 🔨 Cinco averías para entender qué detecta cada comprobación |
| **10.b** | [[Fase_2.10.b_Auditoria_y_Cierre]] | 🏁 Checklist final antes de la Fase 3 |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - Los apartados **4 y 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - Los apartados **8, 9 y 10** son el cierre, **en ese orden**: primero aseguras la máquina, luego escribes, luego compruebas que no te dejas nada.

---

### 🎯 Qué vas a conseguir

> [!success] El resultado de la Fase 2
> Un servidor **limpio y con identidad**:
> - Sin el Samba de fábrica ni su configuración vieja, que bloquearían el dominio de la Fase 4
> - Con el sistema actualizado y las dependencias del dominio instaladas (incluidos `samba-ad-dc` y `samba-ad-provision`)
> - Reconociéndose a sí mismo como **`UbuntuServer.BOOCHANLAB.LOCAL`**

> [!abstract] 📋 Qué se te evalúa (resumen)
> **`RA.01`** *(35 % del módulo)* — `CE.01.e` · `CE.01.h`
> **`RA.05`** *(10 % del módulo)* — `CE.05.d` · `CE.05.f`
>
> El detalle, con dónde demuestras cada criterio: [[Fase_2.1_Que_Se_Evalua]]

**Siguiente al terminar los diez apartados:** Fase 3 — Conectividad VPN (WireGuard).
