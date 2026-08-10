## Fase 3 · Apartado 6.c — 🛠️ Procedimiento — Levantar el túnel y comprobar qué hace

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]] · ↩️ Procedimiento completo: [[Fase_3.6_Procedimiento]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Paso 5 — activar, verificar y entender qué viaja por dentro

> [!important] 📦 Las tres partes del apartado 6 son UN SOLO vídeo
> `B2 · F3 · Conectividad VPN`, de 8-10 minutos, cubre **6.a + 6.b + 6.c**. No grabes tres.
>
> Están separadas para que puedas seguirlas sin perderte, no porque sean tres entregas.

---
> [!success] ▶️ **AHORA SÍ: activa el túnel en el cliente**
> Los dos extremos ya se conocen. Ve a la aplicación WireGuard de tu PC físico y pulsa **`Activar`**.
>
> El indicador pasa a **verde** y aparecen contadores de tráfico. Si no cambia nada, revisa el [[Fase_3.7_Resolucion_Problemas]].
>
> **El orden importa y es el mismo siempre:** primero se configuran los dos lados, después se levanta. Un túnel activado a medias no da error — simplemente no pasa nada por él.
>
> Verifica que el túnel está activo. En el servidor:
> ```bash
> # Muestra el estado del túnel y los peers conectados
> sudo wg show
> ```
>
> **Y ahora busca esta línea**, que es la que importa:
> ```
> latest handshake: 29 seconds ago
> ```
>
> - **✅ Bien:** aparece, con **pocos segundos o minutos**. Los dos extremos se reconocen.
> - **❌ Mal:** **no aparece ninguna línea de `latest handshake`** → nunca se han saludado, las llaves no cuadran → [[Fase_3.7_Resolucion_Problemas]].
>
> > [!danger] 🤝 Sin handshake no hay túnel, aunque todo diga "activo"
> > Es el concepto del [[Fase_3.5_Fundamento_Teorico|punto 4 del fundamento teórico]], y aquí lo ves por primera vez con tus datos.
> >
> > WireGuard **descarta en silencio** los paquetes de quien no reconoce: puedes tener `wg0` levantada, el puerto abierto y el fichero perfecto, **y que no pase ni un byte**. No hay error, no hay aviso, no hay registro.
> >
> > **`latest handshake` es el único dato que no miente**, porque lo firman los dos extremos. Todo lo demás lo dice el servidor de sí mismo.
>
> Y desde el cliente:
> ```bash
> # Si recibes respuestas, el túnel funciona correctamente
> ping 10.20.20.1
> ```
>
> > [!important] 🔒 Ya tienes una puerta mejor. Cerrar la antigua se hace AL FINAL
> > Con el túnel funcionando, tu servidor tiene ahora **dos vías de acceso**: la Red Solo Anfitrión (`10.10.10.10`) y la VPN (`10.20.20.1`). La segunda es mucho mejor: va cifrada y solo entra quien tenga una llave criptográfica.
> >
> > Lo lógico sería cerrar la primera. **Y se hará — pero no hoy.**
> >
> > **NO cambies nada de SSH en esta fase.** Sigues entrando exactamente igual que hasta ahora:
> > ```bash
> > ssh boochan@10.10.10.10
> > ```
> >
> > **¿Por qué no ahora?** Por tres motivos:
> >
> > 1. **Acabas de construir ese túnel hace cinco minutos** y aún no sabes si aguanta un reinicio. Si cierras la vía directa y el túnel no levanta al arrancar, **te quedas sin ninguna forma de entrar** salvo la ventana de VirtualBox.
> > 2. **Te quedan cinco fases más de administrar este servidor.** Cerrarlo ahora te complica todo el camino que queda: cada instantánea que restaures, cada cambio de cliente, cada llave mal copiada te deja fuera.
> > 3. **Un servidor se endurece cuando está terminado**, no a mitad de construcción. Igual que no se pone la alarma en una casa a la que todavía le faltan puertas.
> >
> > **¿Cuándo entonces?** En la **[[Auditoria_Final]]**, que es donde toca: allí se revisan **todas las puertas que abriste durante el proyecto** y se cierran las que sobran, junto con el firewall `ufw`. Con el procedimiento completo, con la comprobación **antes** de cerrar la sesión actual y —esto importa— **con la forma de recuperar el acceso si algo sale mal**.
> >
> > Eso se llama **endurecimiento** *(hardening)*, y es una fase del trabajo, no un paso suelto.
> >
> > Apúntalo en tu entrada de apuntes: *"queda pendiente restringir SSH al túnel — se hará en la Auditoría Final"*. Un administrador anota las puertas que deja abiertas.
>
> > [!warning] ⚠️ Cuidado: hay DOS cosas distintas que se llaman "2222"
> > | Dónde | Qué es |
> > | :--- | :--- |
> > | **[[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]]** *(opcional)* | Un **reenvío de puertos** del anfitrión: `anfitrión:2222 → VM:22`. Solo si administras desde otro equipo de la red |
> > | **[[Auditoria_Final]]** | El **puerto en el que escucha SSH** dentro del servidor, cambiado del 22 al 2222 |
> >
> > **No tienen nada que ver.** Coinciden en el número por casualidad, y confundirlos hace perder mucho tiempo: puedes estar entrando por el reenvío y creer que el endurecimiento ya está aplicado.

---

> [!example] 🔌 Paso 5 — EJERCICIO DE VERIFICACIÓN: qué hace de verdad tu VPN
> Tienes el túnel levantado y `wg show` dice que hay tráfico. Bien. Pero **¿sabes qué hace exactamente esa VPN, y sobre todo qué NO hace?** Vamos a comprobarlo con fuentes externas.
>
> > [!info] Recordatorio: por qué usamos APIs
> > Una **API** es una web hecha para que la consulte un programa: devuelve **datos limpios** en JSON en vez de una página. Un administrador las usa para **comprobar desde fuera lo que desde dentro no puede ver**. La teoría completa está en la práctica **B1.9b** del Bloque 1.
>
> **a) La red del túnel.** Tu túnel es **`10.20.20.0/24`**. Antes de mirar nada, escribe en tu entrada de apuntes cuántos clientes VPN caben en él. Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.20.20.0/24"
> ```
>
> **b) Y ahora la pregunta buena: ¿por qué el cliente lleva `/32`?**
> Fíjate en tu configuración: el servidor tiene `Address = 10.20.20.1/24` pero el cliente tiene `Address = 10.20.20.2/32`. **No es un error.** Míralo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.20.20.2/32"
> ```
> ```json
> "subnet_mask": "255.255.255.255",   "network_address": "10.20.20.2",
> "broadcast_address": "10.20.20.2",       "assignable_hosts": 0
> ```
>
> > [!success] 🤔 Léelo y explícalo en el vídeo
> > Una máscara `/32` significa **una sola dirección**: red, broadcast y host son la misma. **Cero hosts asignables.**
> > Traducido: *"yo soy exactamente esta IP y ninguna más"*. Por eso WireGuard usa `/32` en los clientes — cada uno declara **su** dirección exacta, y el servidor sabe sin ambigüedad a quién enviar cada paquete. Si pusieras `/24` en el cliente, estarías diciendo *"yo soy toda la red"*, y el enrutado se rompería.
>
> **c) El experimento que desmonta un mito.** Tu servidor no tiene IP pública: sale por el NAT de tu equipo, como comprobaste en la Fase 1.
>
> 1. Con la VPN **desconectada**, en el cliente:
>    ```bash
>    curl "https://api.ipify.org?format=json"
>    ```
>    Anota la IP.
> 2. **Conecta el túnel** y comprueba que funciona: `ping 10.20.20.1`
> 3. Con la VPN **conectada**, repite exactamente el mismo comando.
>
> > [!danger] 🤯 Sale la MISMA IP. Y está bien.
> > Casi todo el mundo cree que "conectarse a una VPN" cambia tu IP pública — es lo que venden los anuncios de NordVPN y compañía. **Tu VPN no hace eso, y es a propósito.**
> >
> > Mira tu configuración: `AllowedIPs = 10.20.20.0/24`. Le has dicho al cliente: *"manda por el túnel **solo** lo que vaya a esa red"*. Todo lo demás —YouTube, Google, ipify— **sigue saliendo por tu conexión normal**. Eso se llama **split tunnel** (túnel partido).
> >
> > | | Qué manda por el túnel | Tu IP pública |
> > | :--- | :--- | :--- |
> > | **Split tunnel** (`AllowedIPs = 10.20.20.0/24`) ← el tuyo | Solo el tráfico hacia el servidor | **No cambia** |
> > | **Full tunnel** (`AllowedIPs = 0.0.0.0/0`) | **Todo** tu tráfico de Internet | Sí: sale la del servidor |
> >
> > **¿Y por qué split y no full?** Porque tu VPN existe para **llegar a tu servidor de forma segura**, no para ocultarte. Si mandaras todo el tráfico por el túnel, cargarías tu servidor con el YouTube de todos los clientes, y si el túnel cae te quedas sin Internet. Un administrador elige *split* salvo que tenga una razón concreta para lo contrario.
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Cuántos clientes VPN caben en tu túnel? ¿Coincidió con tu cálculo?
> > 2. ¿Por qué el cliente lleva `/32` y el servidor `/24`? Explícalo con lo que devolvió la API.
> > 3. Tu IP pública **no cambió** al conectar la VPN. **¿Por qué?** ¿Qué habría que cambiar en la configuración para que sí cambiara?
> > 4. Un compañero dice: *"si uso VPN nadie sabe lo que hago en Internet"*. Con lo que acabas de comprobar, **¿tiene razón?**

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.6.b_Procedimiento_Cliente_e_Intercambio]] | [[Fase_3.6_Procedimiento]] | [[Fase_3.7_Resolucion_Problemas]] |
