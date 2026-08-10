## Fase 3 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo, en tres partes.

---

## 🗺️ **LAS TRES PARTES DEL PROCEDIMIENTO**

> [!important] 📦 Las tres son UN SOLO vídeo
> `B2 · F3 · Conectividad VPN`, de 8-10 minutos, cubre las tres. **No grabes tres vídeos.**
>
> Están separadas para que puedas seguirlas sin perderte en un documento de nueve páginas — no porque sean tres entregas.

| | Parte | Qué haces | Pasos |
| :--- | :--- | :--- | :--- |
| 🔑 | **[[Fase_3.6.a_Procedimiento_Servidor\|6.a · El servidor]]** | Generas las llaves del servidor y escribes su `wg0.conf` | 1 y 2 |
| 💻 | **[[Fase_3.6.b_Procedimiento_Cliente_e_Intercambio\|6.b · El cliente y las llaves]]** | Configuras el otro extremo y **cruzas las llaves públicas** | 3 y 4 |
| 🚀 | **[[Fase_3.6.c_Procedimiento_Levantar_el_Tunel\|6.c · Levantar y comprobar]]** | Activas el túnel y compruebas **qué viaja por dentro** | 5 |

> [!tip] 💡 Hazlas en orden y sin saltarte la 6.b
> El error más caro de esta fase está ahí: **cruzar mal las llaves**. Es el único paso donde una confusión no da error — simplemente el túnel no levanta, y parece que falla otra cosa.

---

### 🔒 ¿Y cerrar el acceso directo por `10.10.10.10`?

> [!info] 👆 Ya te lo he contestado, en el Paso 4
> **No se cierra en esta fase.** Los tres motivos y cuándo se hace los tienes arriba, en el aviso del Paso 4.
>
> Si has llegado aquí preguntándotelo otra vez, es buena señal: significa que has entendido que tener dos puertas abiertas es algo que hay que resolver. **Y se resuelve — en la [[Auditoria_Final]].**

---

### ✅ Checklist de esta parte

- [ ] Llaves del servidor generadas **con `umask 077`**, y el `ls -l` muestra `-rw-------`.
- [ ] `wg0.conf` del servidor escrito, con su `[Peer]` apuntando al cliente.
- [ ] Llaves y configuración del **cliente** creadas.
- [ ] Llaves **públicas** intercambiadas: cada lado tiene la del otro, **ninguno la privada ajena**.
- [ ] `sudo wg-quick up wg0` levanta el túnel sin errores.
- [ ] `sudo systemctl enable wg-quick@wg0` ejecutado, para que arranque solo.
- [ ] `ping 10.20.20.1` responde desde el cliente.
- [ ] Las preguntas de la API contestadas en la entrada de apuntes.
- [ ] 🛑 **Instantánea NO tomada todavía.**

---

> [!important] 🛑 Aquí no has terminado la fase
> Que el túnel funcione **ahora mismo** no significa que la fase esté bien hecha: falta comprobar que **sobrevive a un reinicio** y que no has roto nada de las fases anteriores. Eso es el [[Fase_3.8.a_Verificacion|apartado 8.a]], cinco puntos.
>
> **Orden correcto:** [[Fase_3.8.a_Verificacion|8.a · verificar]] → [[Fase_3.8.b_Punto_de_Control|8.b · guardar]]. Una VPN que se cae en el próximo arranque es una VPN que no está configurada — solo encendida.

> ¿Algo no ha salido? → [[Fase_3.7_Resolucion_Problemas]] — **búscate por el síntoma** en el índice del principio, no leas el documento entero.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.5_Fundamento_Teorico]] | [[Fase_3_Conectividad_VPN_WireGuard]] | [[Fase_3.7_Resolucion_Problemas]] |
