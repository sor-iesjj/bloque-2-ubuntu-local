## Fase 3 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué la llave privada **NUNCA** debe salir de tu servidor ni enviarse por correo?
> 2. ¿Qué ventaja tiene WireGuard sobre protocolos antiguos en términos de rendimiento?
> 3. ¿Para qué sirve el parámetro `AllowedIPs` en la configuración del Peer?
> 4. Si tu Red Solo Anfitrión de VirtualBox ya está aislada de internet por diseño, ¿qué aporta realmente montar una VPN encima? Argumenta con el concepto de "Defensa en Profundidad".
> 5. 🔬 **Reto práctico:** Con el túnel activo, ejecuta `sudo wg show` en el servidor y localiza la línea `latest handshake`. ¿Hace cuántos segundos fue el último intercambio? Ahora desactiva el túnel desde el cliente y vuelve a ejecutar el comando 30 segundos después. ¿Qué cambió en esa línea? ¿Qué te dice eso sobre el estado de la conexión?
> 6. 🔬 **Reto práctico:** con el túnel **desactivado**, intenta conectarte por SSH a `10.10.10.10`. **Entras sin problema.** ¿Por qué? Mira `sudo ss -tlnp | grep ssh`: el servidor sigue escuchando en `0.0.0.0:22`, es decir, en todas sus interfaces. Ahora responde: **¿qué habría que cambiar para que solo se pudiera entrar por el túnel?** *(Lo harás de verdad en la Auditoría Final — aquí solo razónalo.)*
> 7. 🔬 **Reto de diagnóstico:** edita `/etc/ssh/sshd_config`, pon `Port 9999`, reinicia con `sudo systemctl restart ssh` y ejecuta `sudo ss -tlnp | grep ssh`. **El puerto no cambia.** ¿Por qué? ¿Quién está escuchando en realidad? *(Pista: mira quién aparece como propietario del socket.)* Deshaz el cambio después.
>    **Esta es la pregunta importante de toda la fase:** un fichero de configuración puede estar diciendo una cosa mientras el sistema hace otra. Y si te fías del fichero, crees tener cerrado algo que sigue abierto.

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.8.b_Punto_de_Control]] | [[Fase_3_Conectividad_VPN_WireGuard]] | [[Fase_3.10.a_Laboratorio_de_Averias]] |
