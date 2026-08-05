## Fase 3 · Apartado 2 — ✅ Qué tienes que entregar

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Antes de encender la VM.** Qué tienes que producir.

---

> [!danger] 🛑 ESTO ES UN KIT. SI FALTA UNA PIEZA, LA FASE NO SE CORRIGE
> No hay entregas parciales ni elementos orientativos. **O está todo, o la fase queda anulada.**
>
> No es rigidez por gusto: cada pieza demuestra algo que las demás no. Un vídeo sin apuntes no demuestra que lo hayas entendido; unos apuntes sin vídeo no demuestran que lo hayas hecho tú.

---

## 📦 LOS CINCO ENTREGABLES

### **1 · LA ENTRADA DE APUNTES**

| | |
| :--- | :--- |
| **Dónde** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/` |
| **Nombre exacto** | `b2-f3-conectividad-vpn.md` |
| **Qué contiene** | El procedimiento con tus palabras · respuestas a las preguntas críticas · las predicciones del laboratorio de averías · **los cuatro enlaces de vídeo** |
| **Cómo se entrega** | A tu repositorio: `git add` → `commit` → `push` |

### **2 · VÍDEO DEL PROCEDIMIENTO**

| | |
| :--- | :--- |
| **Nombre exacto** | `B2 · F3 · Conectividad VPN` |
| **Duración** | ~8-10 min |
| **Qué se ve** | El apartado 6 entero: generar llaves, configurar servidor y cliente, levantar el túnel |

### **3 · VÍDEO DE VERIFICACIÓN**

| | |
| :--- | :--- |
| **Nombre exacto** | `B2 · F3 · Verificación` |
| **Duración** | ~4-6 min |
| **Qué se ve** | Las cinco comprobaciones del apartado 8.a, **explicando qué dice cada una** |

### **4 · VÍDEO DEL LABORATORIO DE AVERÍAS**

| | |
| :--- | :--- |
| **Nombre exacto** | `B2 · F3 · Laboratorio de averías` |
| **Duración** | ~10-15 min |
| **Qué se ve** | Las seis averías del apartado 10.a: **tu predicción en voz alta**, la rotura, la comprobación y el arreglo |

### **5 · VÍDEO DEL PUNTO DE CONTROL Y LA COPIA DE SEGURIDAD**

| | |
| :--- | :--- |
| **Nombre exacto** | `B2 · F3 · Punto de control` |
| **Duración** | ~2-3 min |
| **Qué se ve** | La instantánea `Fase 3 terminada` tomada en VirtualBox **y** la máquina exportada a tu disco externo |

> [!danger] 💾 La copia en el disco externo NO es opcional
> Una instantánea de VirtualBox **vive dentro de VirtualBox**. Si el programa se corrompe, si formatean el equipo del aula o si falla el disco, **se va todo con ella**.
>
> **Una copia que vive en el mismo sitio que el original no es una copia.**
>
> Por eso cada fase termina exportando la máquina a un disco externo. Y no es un trámite: más adelante se te pedirá **destruir tu servidor y recuperarlo desde esa copia**. Sin ella, esa práctica no la puedes hacer.

---

## 💾 LA COPIA DE SEGURIDAD: DÓNDE Y CÓMO SE LLAMA

**Material necesario:** un **disco externo USB de 2 TB**. Cada fase ocupa entre 5 y 8 GB.

**Estructura de carpetas en el disco** — la misma que la del material, para que nunca dudes dónde va nada:

```
SOR/
└── Bloque_2/
    └── Fases/
        ├── Fase_1/
        │   └── B2-F1-infraestructura-virtual.ova
        ├── Fase_2/
        │   └── B2-F2-purga-y-preparacion.ova
        └── Fase_3/
            └── B2-F3-conectividad-vpn.ova
```

**Nombre del fichero de esta fase:** `B2-F3-conectividad-vpn.ova`

> [!tip] ⏸️ En el vídeo puedes pausar
> La exportación tarda varios minutos. **Pausa la grabación** mientras trabaja y reanúdala al terminar.
>
> Lo que tiene que verse es que **arrancas la exportación** y que **el fichero existe en el disco** al acabar. Nadie quiere ver una barra de progreso durante ocho minutos.

---

## 🎬 LOS CUATRO VÍDEOS

Todos van a la **misma playlist**: `B2_Ubuntu_Local` (No listado).

| # | Nombre exacto |
| :--- | :--- |
| 1 | `B2 · F3 · Conectividad VPN` |
| 2 | `B2 · F3 · Verificación` |
| 3 | `B2 · F3 · Laboratorio de averías` |
| 4 | `B2 · F3 · Punto de control` |

> [!danger] ⚠️ Los nombres NO son orientativos
> `B2` es el bloque · `F3` la fase · y después, qué se hace en ese vídeo. **Se llaman exactamente así.**
>
> Con un grupo entero entregando cuatro vídeos por fase, si cada uno pone lo que le apetece corregir se vuelve imposible. **Un nombre distinto es una entrega no localizada — y una entrega no localizada es una entrega no presentada.**

---

> [!success] 🎯 Criterio de éxito
> Abro tu repositorio, encuentro `b2-f3-conectividad-vpn.md`, y dentro está: qué has hecho, qué has entendido, qué dudas te quedaron y **los cuatro enlaces de vídeo**.
>
> Entro a los vídeos por sus timestamps y contrasto con lo que dicen tus apuntes.
>
> **Si falta cualquiera de las cinco piezas, la fase no se corrige.**

> [!question] ✅ Repásalo antes de entregar
> - [ ] Entrada de apuntes con el nombre exacto, subida al repositorio.
> - [ ] Los **cuatro** vídeos en la playlist, con sus nombres exactos y sus timestamps.
> - [ ] Los **cuatro enlaces** dentro de la entrada de apuntes.
> - [ ] Instantánea `Fase 3 terminada` en VirtualBox.
> - [ ] `B2-F3-conectividad-vpn.ova` en tu disco externo, en su carpeta.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.1_Que_Se_Evalua]] | [[Fase_3]] | [[Fase_3.3_Obligaciones_Grabacion]] |
