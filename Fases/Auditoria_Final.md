## 🛡️ Auditoría Final y Hardening

### Cierre de seguridad del proyecto

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **Profesor:** Pedro Navarro Miralles · IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas
> **Requisitos:** las ocho fases terminadas · túnel WireGuard operativo · instantánea `Fase 8 terminada`
>
> **📦 Entrega:** una entrada de apuntes + un vídeo + la instantánea `Proyecto terminado`

---

## 🧭 Índice

> [!warning] 📖 La última pieza del itinerario
> Aquí no se construye nada nuevo: **se cierra lo que ya existe.** Un servidor se endurece cuando está terminado, no a mitad de obra.

| # | Apartado | Cuándo se lee |
| :--- | :--- | :--- |
| **1** | [[Auditoria_Final.1_Que_Se_Evalua]] | Antes de empezar — qué se te evalúa |
| **2** | [[Auditoria_Final.2_Entregables]] | Antes de empezar — qué debes producir |
| **3** | [[Auditoria_Final.3_Obligaciones_Grabacion]] | Antes de arrancar OBS |
| **4** | [[Auditoria_Final.4_Fundamento_Teorico]] | Antes de teclear — Zero Trust y `ufw` |
| **5** | [[Auditoria_Final.5_Procedimiento]] | **Con la VM delante — el trabajo** |
| **6** | [[Auditoria_Final.6_Punto_de_Control]] | Al terminar, con la grabación en marcha |
| **7** | [[Auditoria_Final.7_Preguntas]] | Después de la instantánea |
| **8** | [[Auditoria_Final.8_Cierre]] | Lo último del proyecto entero |

---

> [!success] 🏁 Qué cierras aquí
> El servidor pasa de *"todo funciona"* a *"solo funciona lo que debe, y solo para quien debe"*:
> - Firewall `ufw` con política de denegar por defecto y lista blanca
> - Revisión del reenvío de puertos que pudieras haber abierto por comodidad
> - **El SSH directo se cierra** y se deja solo por el túnel WireGuard
> - Auditoría de servicios: qué está escuchando y por qué

**Siguiente:** nada. Has terminado el Bloque 2. 🎉
