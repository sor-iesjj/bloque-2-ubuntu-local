## 👥 Fase 5: Gestión de Identidades (Usuarios y Grupos)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5 y 6: Administración de usuarios y grupos en Linux y Windows]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **[Estimación de Implementación]**
> - **Tiempo total:** ~0,5 horas (30 minutos)
> - **RAM del servidor:** 4 GB (winbind demanda ~200 MB adicional)
> - **Desglose:** Configurar nsswitch.conf (5 min) + Crear grupos con GID (5 min) + Crear usuarios con UID (5 min) + Verificaciones (10 min) + Troubleshooting (5 min)
> - **Dependencias externas:** Samba AD DC operativo desde Fase 4, winbind activado
>
> **📦 Entrega:** una entrada de apuntes + **tres vídeos** + la instantánea `Fase 5 terminada` + la copia `.ova`

---

## 🧭 Índice de la fase

> [!warning] 📖 Esta fase va en doce documentos, no en uno
> Cada apartado es un fichero aparte, dentro de la carpeta `Fase_5/`. **Se leen en orden**, pero puedes volver a cualquiera sin perderte: al final de cada uno tienes la navegación.
>
> **La fase son TRES entregas de vídeo** —procedimiento, punto de control y laboratorio de averías— sobre **una sola entrada de apuntes**.

| # | Apartado | Cuándo se lee |
| :--- | :--- | :--- |
| **1** | [[Fase_5.1_Que_Se_Evalua]] | Antes de encender la VM — qué se te evalúa |
| **2** | [[Fase_5.2_Entregables]] | Antes de encender la VM — qué debes producir |
| **3** | [[Fase_5.3_Obligaciones_Grabacion]] | Antes de arrancar OBS — cómo se graba y se entrega |
| **4** | [[Fase_5.4_Donde_Estamos]] | Antes de empezar — de dónde vienes y a dónde llegas |
| **5** | [[Fase_5.5_Fundamento_Teorico]] | Antes de teclear — los conceptos |
| **6** | [[Fase_5.6_Procedimiento]] | **Con la VM delante — aquí está el trabajo** |
| **7** | [[Fase_5.7_Resolucion_Problemas]] | Cuando algo no salga — búscate por el síntoma |
| **8.a** | [[Fase_5.8.a_Verificacion]] | 🔍 Al terminar el procedimiento — **antes** de guardar |
| **8.b** | [[Fase_5.8.b_Punto_de_Control]] | 💾 Después de verificar — la instantánea y la copia |
| **9** | [[Fase_5.9_Preguntas]] | Después de la instantánea — trabajo de mesa |
| **10.a** | [[Fase_5.10.a_Laboratorio_de_Averias]] | 🔨 Romper las identidades a propósito, y repararlas |
| **10.b** | [[Fase_5.10.b_Auditoria_y_Cierre]] | Lo último — la checklist antes de seguir |

> [!tip] 💡 Cómo se recorre
> - Los apartados **1, 2 y 3** se leen **antes de encender nada**: son las reglas del juego.
> - El **4 y el 5** te preparan: contexto y conceptos.
> - El **6 es el trabajo**. El **7** solo si algo falla.
> - El **8.a y el 8.b van en ese orden y no se intercambian**: primero se comprueba, después se guarda. Una instantánea de un trabajo sin verificar convierte el fallo en tu punto de retorno.
> - El **9** es trabajo de mesa, y el **10.a** es donde de verdad se aprende: rompes lo que acabas de construir, con la red de seguridad ya puesta.

> [!danger] 🛑 El fallo de esta fase no da ningún error
> Los usuarios pueden existir, responder a `id` y llevar **números que tú no elegiste**. Hoy no pasa nada. **La Fase 7 se cae** cuando los permisos que des a `3001` no alcancen a nadie.
>
> Por eso el **8.a existe y es obligatorio**: mira los números, no los nombres.

---

> [!abstract] 📋 Qué se te evalúa (resumen)
> **RA.02 · RA.03** — CE.02.a · CE.02.b · CE.02.c · CE.02.d · CE.02.e · CE.02.f · CE.02.g · CE.02.h · CE.02.i · CE.03.f
>
> El detalle, con dónde demuestras cada criterio: [[Fase_5.1_Que_Se_Evalua]]

**Siguiente al terminar los doce apartados:** Fase 6.
