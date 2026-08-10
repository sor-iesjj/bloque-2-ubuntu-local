## Fase 1 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1_Infraestructura_Virtual_Local]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes, qué construyes y a dónde llegas.

---

> [!success] 🏁 El resultado final de la Fase 1
> Un **servidor Ubuntu Server 26.04 LTS** corriendo dentro de tu propio ordenador, con:
> - Dos tarjetas de red: **NAT** para Internet, **sólo-anfitrión** para el laboratorio
> - IP fija **`10.10.10.10`** en una red privada `10.10.10.0/24`, aislada de la red del instituto
> - Usuario `boochan` y acceso **por SSH desde tu propia terminal**
> - El nombre del dominio del proyecto anotado: `BOOCHANLAB` / `BOOCHANLAB.LOCAL`
>
> Sobre eso se construye todo el Bloque 2.

> [!info] ℹ️ Lo que NO entra en esta fase
> Actualizar el sistema y limpiarlo de software que estorba es la **Fase 2**. Aquí solo se instala y se comprueba. Si al entrar te encuentras actualizaciones pendientes, déjalas: tienen su momento.

> [!important] Las cuatro partes van en orden, y cada una necesita la anterior terminada
> No empieces la **6.c** sin haber verificado la **6.b**. La mitad de los problemas de esta fase vienen de haber seguido adelante con algo a medias.

---

## El recorrido, parte por parte

### 6.a · La máquina virtual

> [!info] El punto de partida
> Esta es la primera piedra del Bloque 2. En el Bloque 4 alquilabas un servidor en la nube; aquí lo vas a construir **dentro de tu propio ordenador**, con VirtualBox.

> [!warning] El problema
> No siempre hay presupuesto ni conexión fiable en el aula para una cuenta cloud por alumno. Y hay algo más de fondo: entender la virtualización **local** — la que corre sobre tu hardware — es lo que luego te permite entender la de la nube. Antes de alquilarle un ordenador virtual a Microsoft, conviene saber crear uno.

> [!success] Objetivo de esta sub-fase
> Tener creada, **apagada y sin sistema operativo todavía**, una máquina virtual llamada `UbuntuServer` correctamente dimensionada. Nada más. La red va en la 1.2 y la instalación en la 1.3.

> [!tip] Hoja de ruta
> 1. Verificar o instalar VirtualBox
> 2. Descargar la ISO de Ubuntu Server 26.04 LTS
> 3. Crear la VM: RAM, CPU y disco
>
> **Siguiente:** [[Fase_1.6.b_Procedimiento_Red_Laboratorio]] — las dos tarjetas de red.

---

➡️ [[Fase_1.6.a_Procedimiento_Maquina_Virtual]]

---

### 6.b · La red del laboratorio

> [!info] Vienes de la 1.1
> Tienes una máquina virtual creada y apagada, con su disco y su memoria. Todavía no tiene sistema operativo — y tampoco tiene forma de comunicarse con nada.

> [!warning] El problema
> Tu servidor necesita hacer **dos cosas incompatibles entre sí**: salir a Internet para descargar paquetes, y hablar con el futuro cliente Windows 11 en una red privada que no toque la Wi-Fi del instituto. Una sola tarjeta no puede hacer las dos bien. Por eso vas a ponerle dos.

> [!success] Objetivo de esta sub-fase
> Dejar la VM con **dos adaptadores de red** configurados: uno NAT para Internet y uno sólo-anfitrión conectado a una red privada `10.10.10.0/24` con el host en `10.10.10.1` y **sin DHCP**.

> [!tip] Hoja de ruta
> 1. Entender los modos de red de VirtualBox
> 2. Crear y configurar la red sólo-anfitrión del laboratorio
> 3. Asignar los dos adaptadores a la VM
> 4. Verificar antes de seguir
>
> **Siguiente:** [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]] — instalar el sistema.

---

➡️ [[Fase_1.6.b_Procedimiento_Red_Laboratorio]]

---

### 6.c · Instalar Ubuntu Server

> [!info] Vienes de la 1.2
> La VM existe, está dimensionada y tiene dos tarjetas de red apuntando a donde deben. Es una máquina completa **sin sistema operativo**: si la enciendes ahora, no sabe hacer nada.

> [!warning] El problema
> Un instalador es una **sucesión de decisiones**, y casi todas son irreversibles sin reinstalar. El teclado, el particionado, el nombre del servidor, el usuario. Ir dándole a "siguiente" es la forma más rápida de tener que empezar de cero mañana.

> [!success] Objetivo de esta sub-fase
> Ubuntu Server 26.04 LTS instalado y arrancando, con teclado español, IP fija `10.10.10.10/24` en la tarjeta sólo-anfitrión, usuario `boochan` y OpenSSH instalado.

> [!tip] Hoja de ruta
> 1. Arrancar el instalador
> 2. Recorrer sus pantallas, entendiendo cada decisión
> 3. Esperar, reiniciar y entrar
>
> **Siguiente:** [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] — comprobar que todo funciona de verdad.

---

➡️ [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]]

---

### 6.d · Verificación y acceso remoto

> [!info] Vienes de la 1.3
> Tienes Ubuntu Server instalado y arrancando. Has tomado una docena de decisiones en el instalador y **crees** que todas se aplicaron.

> [!warning] El problema
> Creer no es saber. Un servidor puede arrancar perfectamente y tener la red mal, el servicio caído o una tarjeta que no existe. **Nada de eso se ve mirando la pantalla de login.** Y si no lo detectas ahora, lo detectarás tres fases más adelante, cuando el dominio no arranque y no sepas por qué.

> [!success] Objetivo de esta sub-fase
> Comprobar, **con pruebas y no con confianza**, que el servidor tiene sus dos tarjetas bien, sale a Internet y es alcanzable desde tu ordenador. Y dar el salto que cambia cómo trabajas el resto del curso: **administrarlo por SSH desde tu propia terminal.**

> [!tip] Hoja de ruta
> 1. Las tres comprobaciones de red
> 2. Entrar por SSH
> 3. Anotar el dominio del proyecto
> 4. Ejercicio: verificar tu red desde fuera con APIs
>
> **Siguiente:** Fase 2 — Purga y Preparación del Entorno.

---

➡️ [[Fase_1.6.d_Procedimiento_Verificacion_SSH]]

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.3_Obligaciones_Grabacion]] | [[Fase_1_Infraestructura_Virtual_Local]] | [[Fase_1.5_Fundamento_Teorico]] |
