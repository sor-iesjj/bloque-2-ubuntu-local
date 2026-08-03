## 🏗️ Fase 1: Infraestructura Virtual Local (VirtualBox)

### Índice de la fase

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
>
> **Profesor:** Pedro Navarro Miralles
> **Correo:** p.navarromiralles2@edu.gva.es
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo total estimado:** ~3 horas repartidas en cuatro sesiones
> **Requisitos:** VirtualBox instalado · ~2 GB de RAM libres · ~20 GB de disco libres

---

> [!warning] 📖 Esta fase va en cuatro documentos, no en uno
> Construir el servidor desde cero son cuatro trabajos distintos, cada uno con su propia teoría y sus propios fallos típicos. Meterlos en un solo documento hacía un texto de cuarenta minutos de vídeo que nadie se lee entero.
>
> **Cada sub-fase se entrega por separado:** su entrada de apuntes y su vídeo de 8-10 minutos.

---

### 🗺️ Las cuatro sub-fases

| # | Sub-fase | Qué haces | Tiempo | RA / CE |
| :--- | :--- | :--- | :--- | :--- |
| **1.1** | [[Fase_1.1_La_Maquina_Virtual]] | Instalar VirtualBox, descargar la ISO y crear la VM bien dimensionada | ~40 min | `RA.01` · `CE.01.a`, `CE.01.b` |
| **1.2** | [[Fase_1.2_La_Red_del_Laboratorio]] | Las dos tarjetas de red y la red privada `10.10.10.0/24` | ~45 min | `RA.01` · `CE.01.a`, `CE.01.i` |
| **1.3** | [[Fase_1.3_Instalar_Ubuntu_Server]] | El instalador, decisión a decisión | ~1 h | `RA.01` · `CE.01.c`, `CE.01.e`, `CE.01.g` |
| **1.4** | [[Fase_1.4_Verificacion_y_Acceso_Remoto]] | Comprobar que funciona y entrar por SSH | ~45 min | `RA.01` · `CE.01.e`, `CE.01.i` |
| **1.E** | [[Fase_1.E_Cuando_Algo_Falla]] | Catálogo de incidentes. **No se entrega** | — | — |

> [!important] 💾 Antes de empezar, lee esto una vez
> **[[Fase_0.S_Instantaneas_Puntos_de_Control]]** — cómo tomar un punto de control al terminar cada fase para poder volver atrás si algo se rompe. Son dos clics y te ahorra reinstalar el servidor entero. Léelo **antes** de la 1.1; después solo tendrás que aplicarlo cuando el manual te lo pida.

> [!important] Van en orden, y cada una necesita la anterior terminada
> No empieces la 1.3 sin haber verificado la 1.2. La mitad de los problemas de esta fase vienen de haber seguido adelante con algo a medias.

---

> [!abstract] 📋 Qué se te evalúa en toda la Fase 1
> **Resultado de Aprendizaje — `RA.01`** *(pesa un **35 %** del módulo, el más alto de los seis · UD1-UD4)*
> *Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.*
>
> Entre las cuatro sub-fases se cubren **6 de los 9 criterios** del `RA.01`:
>
> | Código | Criterio de evaluación | Sub-fase |
> | :--- | :--- | :--- |
> | `CE.01.a` | Se ha realizado el estudio de compatibilidad del sistema informático. | 1.1 y 1.2 |
> | `CE.01.b` | Se han diferenciado los modos de instalación. | 1.1 |
> | `CE.01.c` | Se ha planificado y realizado el particionado del disco del servidor. | 1.3 |
> | `CE.01.e` | Se han seleccionado los componentes a instalar. | 1.3 y 1.4 |
> | `CE.01.g` | Se han aplicado preferencias en la configuración del entorno personal. | 1.3 |
> | `CE.01.i` | Se ha comprobado la conectividad del servidor con los equipos cliente. | 1.2 y 1.4 |
>
> **Los 3 restantes:** `CE.01.d` (sistemas de archivos) y `CE.01.h` (actualización del sistema) se trabajan en la **Fase 2**; `CE.01.f` (automatización de instalaciones) tiene práctica propia en el **Bloque 1 (B1.12, autoinstall)**.
>
> > [!note] 🎓 ¿De dónde salen estos códigos?
> > De la programación didáctica del módulo, que desarrolla el **Real Decreto 1691/2007** y la **Orden de 29 de julio de 2009**. Un RA se aprueba demostrando **más del 50 % de sus criterios**, y todos pesan igual. Tienes derecho a saber por qué se te evalúa lo que se te evalúa.

---

### 🎯 ¿Dónde vas a llegar?

> [!success] El resultado final de la Fase 1
> Un **servidor Ubuntu Server 26.04 LTS** corriendo en tu propio ordenador, con:
> - Dos tarjetas de red: NAT para Internet, sólo-anfitrión para el laboratorio
> - IP fija **`10.10.10.10`** en una red privada `10.10.10.0/24`, aislada de la red del instituto
> - Usuario `boochan` y acceso **por SSH desde tu propia terminal**
> - El nombre del dominio del proyecto anotado: `BOOCHANLAB` / `BOOCHANLAB.LOCAL`
>
> Sobre eso se construye todo BoochanV1.

> [!info] ℹ️ Lo que NO entra en esta fase
> Actualizar el sistema y limpiarlo de software que estorba es la **Fase 2**. Aquí solo se instala y se comprueba. Si te encuentras actualizaciones pendientes al entrar, déjalas: tienen su momento.

**Siguiente al terminar las cuatro:** Fase 2 — Purga y Preparación del Entorno.
