## Fase 1 · Apartado 8 — 💾 Punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Al terminar 6.c y al terminar 6.d**, con la grabación aún en marcha.

---

> [!important] 💾 Esta fase tiene DOS instantáneas
> | Instantánea | Cuándo | Para qué sirve |
> | :--- | :--- | :--- |
> | **`Sistema base`** | Al terminar [[Fase_1.6.c_Procedimiento_Instalar_Ubuntu]] | **La más importante del proyecto.** Evita reinstalar Ubuntu nunca más, y es el punto de partida de los simulacros |
> | **`Fase 1 terminada`** | Al terminar [[Fase_1.6.d_Procedimiento_Verificacion_SSH]] | Punto de partida limpio para la Fase 2 |

> [!danger] ⚠️ `Sistema base` protege lo caro
> Piensa en lo que cuesta rehacer cada cosa:
>
> | Rehacer… | Cuesta |
> | :--- | :--- |
> | Instalar Ubuntu desde la ISO | **20-30 minutos**, y hay que estar delante contestando pantallas |
> | Cualquier otra parte del proyecto | minutos, y son comandos que se pegan |
>
> **Todo lo que viene después son comandos. Esto no.** Es la única parte que no se puede automatizar ni acelerar. Con `Sistema base` guardada, **nunca más tendrás que reinstalar Ubuntu**, pase lo que pase.

> [!example] Cómo se toma
> Con la grabación en marcha, apaga la VM:
> ```bash
> sudo poweroff
> ```
> En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → ponle el nombre exacto de la tabla.
>
> Por comando, si el botón no aparece:
> ```
> VBoxManage snapshot "UbuntuServer" take "Sistema base" --description "Ubuntu Server 26.04 recien instalado"
> ```
>
> Y comprueba que se ha creado:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!note] 📌 El detalle completo
> Cómo restaurarlas, cómo verificar que existen, qué es un UUID y por qué el fichero no lleva el nombre que le pusiste: **[[Fase_0.S_Instantaneas_Puntos_de_Control]]**

> [!important] 👉 Con `Fase 1 terminada` tomada, te queda la última entrega
> Esa instantánea no sirve solo para volver atrás: **es el punto desde el que se clona**. En [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar]] la conviertes en una máquina que le das a un compañero — y descubres, chocándote, qué partes de un servidor **no se pueden duplicar**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.7_Resolucion_Problemas]] | [[Fase_1]] | [[Fase_1.9_Preguntas]] |
