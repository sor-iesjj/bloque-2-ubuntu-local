## Fase 3 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma. No hace falta leerlo antes.

---

> [!important] 🎓 La cadena de diagnóstico
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> En una VPN esto importa más que en ningún otro sitio, porque **casi nada da un error claro**: un túnel mal configurado no protesta, simplemente no transmite.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Ve a |
| :--- | :--- |
| `Address already in use` al levantar el túnel | [[#E1 · Address already in use al levantar el túnel\|E1]] |
| No hay ping entre `10.20.20.1` y `10.20.20.2` | [[#E2 · No hay ping entre el servidor y el cliente\|E2]] |
| El túnel dice **activo** pero no pasa nada por él | [[#E3 · El túnel dice activo pero no pasa nada\|E3]] |
| El cliente no encuentra el `Endpoint` | [[#E4 · El cliente no encuentra el Endpoint\|E4]] |
| **Activo la VPN y me quedo sin internet** | [[#E5 · Activo la VPN y me quedo sin internet\|E5]] |
| Cerré WireGuard y se perdió lo que había escrito | [[#E6 · Cerré la ventana y perdí la configuración\|E6]] |

---

### E1 · Address already in use al levantar el túnel

> [!bug] Síntoma
> `sudo wg-quick up wg0` falla con `Address already in use` o `RTNETLINK answers: File exists`.

**Hipótesis.** El túnel **ya está levantado** de un intento anterior. `wg-quick up` no es idempotente: si la interfaz ya existe, falla.

**Comprobación.**

```bash
ip a show wg0
sudo wg show
```

**Arreglo.** Bájalo y vuelve a subirlo:

```bash
sudo wg-quick down wg0
sudo wg-quick up wg0
```

> [!summary] Qué aprendes
> Que **levantar dos veces no es lo mismo que levantar una**. Muchos comandos de administración asumen un estado de partida limpio y fallan si ya hiciste el trabajo. Ante la duda: bajar y volver a subir.

---

### E2 · No hay ping entre el servidor y el cliente

> [!bug] Síntoma
> El túnel parece levantado en los dos lados, pero `ping 10.20.20.1` desde el cliente no responde.

**Hipótesis.** Los dos extremos **no se alcanzan por la red de debajo**. El túnel viaja *dentro* de la Red Solo Anfitrión: si esa no funciona, el túnel tampoco.

> [!info] 🧅 Dos redes, una encima de la otra
> - **Red de abajo (real):** `10.10.10.0/24`, la Solo Anfitrión. Por ahí viajan los paquetes cifrados.
> - **Red de arriba (el túnel):** `10.20.20.0/24`. Solo existe si la de abajo funciona.
>
> **Nunca diagnostiques la de arriba sin comprobar la de abajo.**

**Comprobación.** De abajo hacia arriba, en este orden:

```bash
ping 10.10.10.10        # ¿llega el cliente al servidor por la red real?
sudo wg show            # ¿hay handshake? (en el servidor)
ping 10.20.20.1         # ¿funciona el túnel?
```

**Arreglo.** Si falla el primero, el problema **no es WireGuard**: revisa el adaptador de Red Solo Anfitrión en VirtualBox y que el servidor conserva la `10.10.10.10` (`hostname -I`).

> [!summary] Qué aprendes
> Que una VPN es **una red encima de otra**, y que el diagnóstico va siempre **de la capa de abajo hacia arriba**. Empezar por el túnel es perder el tiempo.

---

### E3 · El túnel dice activo pero no pasa nada

> [!bug] Síntoma
> El indicador está **verde** en el cliente, `wg show` responde… pero no hay ping y los contadores de tráfico no suben, o solo sube el de envío.

**Hipótesis.** Las **llaves están cruzadas**, o el servidor todavía no conoce al cliente.

> [!danger] ⚠️ El fallo más traicionero de esta fase
> **WireGuard no avisa de que no te conoce.** Si le llegan paquetes de alguien cuya llave no tiene, los **descarta en silencio** — es una decisión de diseño, para no revelar nada a quien anda sondeando el puerto.
>
> Resultado: la interfaz dice "activo", los contadores de envío suben, los de recepción se quedan a cero, y **ningún mensaje explica nada**.

**Comprobación.** Mira el **handshake**, que es la única prueba real:

```bash
sudo wg show
```

| Lo que ves | Significa |
| :--- | :--- |
| `latest handshake: hace X segundos` | ✅ Los dos se reconocen. El túnel funciona |
| **No aparece `latest handshake`** | ❌ Nunca se han saludado. Llaves mal |
| `transfer: X received, 0 sent` o al revés | ❌ Va en un solo sentido |

**Arreglo.** Verifica el cruce de llaves. La regla es simple y se equivoca todo el mundo:

> **En cada fichero, `[Interface]` habla de TI y `[Peer]` habla DEL OTRO.**

- En el **servidor**, `[Peer] PublicKey` = la pública **del cliente**.
- En el **cliente**, `[Peer] PublicKey` = la pública **del servidor**.

Compáralas carácter por carácter. En el servidor:

```bash
sudo wg show wg0 public-key                    # la pública del SERVIDOR
sudo grep PublicKey /etc/wireguard/wg0.conf    # la que tiene guardada del CLIENTE
```

> [!summary] Qué aprendes
> Que **"activo" no significa "funcionando"**. Y que en criptografía el silencio es una respuesta: un sistema que no contesta a un desconocido está haciendo bien su trabajo, aunque a ti te complique el diagnóstico. El **handshake** es el único dato que no miente.

---

### E4 · El cliente no encuentra el Endpoint

> [!bug] Síntoma
> El cliente no consigue contactar con el servidor. Nunca hay handshake.

**Hipótesis.** El `Endpoint` está mal escrito, el servidor no tiene esa IP, o el túnel no está levantado en el servidor.

**Comprobación.** En el servidor:

```bash
hostname -I                          # ¿sigue teniendo 10.10.10.10?
sudo wg show                         # ¿está levantado?
sudo ss -ulnp | grep 51820           # ¿escucha en el puerto?
```

**Arreglo.** El `Endpoint` del cliente debe ser exactamente `10.10.10.10:51820`.

> [!warning] ⚠️ El `Endpoint` va SOLO en el cliente
> El servidor **nunca** lo lleva. Lo aprende solo: en cuanto recibe un saludo válido, anota de dónde vino y responde ahí.
>
> Si lo pones en el servidor apuntando a `10.10.10.10`, le estás diciendo que para hablar con el cliente **se envíe los paquetes a sí mismo**.

> [!summary] Qué aprendes
> Que en una conexión **alguien tiene que dar el primer paso**, y solo ese necesita saber la dirección del otro. El que espera aprende de quien llama. Es el mismo patrón que un servidor web: tú sabes su dirección, él no sabía la tuya.

---

### E5 · Activo la VPN y me quedo sin internet

> [!bug] Síntoma
> Activas el túnel y **dejas de navegar** en el equipo cliente. Al desactivarlo, vuelve a funcionar.

**Hipótesis.** Tienes una línea **`DNS = 10.20.20.1`** en el `[Interface]` del cliente, y en esa dirección **todavía no hay ningún servidor DNS**.

> [!danger] ⚠️ Apuntar el DNS a un servicio que aún no existe
> Esa línea le dice a tu equipo: *"mientras el túnel esté activo, pregunta los nombres al servidor"*. Y está bien… **a partir de la Fase 4**, cuando Samba levante su DNS interno.
>
> En la Fase 3 no hay nadie escuchando ahí. Tus consultas se van a un sitio mudo y **la resolución de nombres deja de funcionar en todo el equipo**. Sigues teniendo conexión —el tráfico por IP funciona— pero sin nombres no navegas.
>
> Verás esta línea en muchos manuales de WireGuard. **No la copies sin preguntarte si el DNS al que apunta existe ya.**

**Comprobación.** Distingue *"no hay red"* de *"no hay DNS"*:

```
ping 8.8.8.8            ← ¿hay camino?
ping google.com         ← ¿hay resolución de nombres?
```

Si el primero responde y el segundo no, es DNS. Confirmado.

**Arreglo.** Desactiva el túnel, edita la configuración del cliente, **borra la línea `DNS`**, guarda y vuelve a activar.

Se añade en la **Fase 8**, cuando el cliente tenga que resolver nombres del dominio `BOOCHANLAB.LOCAL`.

> [!summary] Qué aprendes
> Que **el orden en que se activan los servicios importa tanto como su configuración**. Es el mismo error que evita el script de la Fase 4 aprovisionando el dominio *antes* de tocar el DNS: apuntar a un servicio que todavía no existe te deja peor que no apuntar a nada.

---

### E6 · Cerré la ventana y perdí la configuración

> [!bug] Síntoma
> Escribiste la configuración del cliente, cerraste la ventana, y al volver el túnel está vacío o no aparece en la lista.

**Hipótesis.** No pulsaste **`Guardar`**. La aplicación de WireGuard **no guarda sola**: hasta que no pulsas el botón, lo que escribes vive únicamente en pantalla.

**Comprobación.** Abre la aplicación: si el túnel no está en la lista de la izquierda, no llegó a guardarse.

**Arreglo.** Vuelve a crearlo. **Y esta vez anota primero la clave pública**: si se pierde, la que tenga el servidor ya no vale y hay que rehacer el intercambio entero.

> [!tip] 💡 Cómo no repetirlo
> Escribe la configuración del cliente **en un fichero de texto aparte** antes de pegarla en la aplicación. Si algo se pierde, no vuelves a empezar de cero.
>
> Es lo mismo que hacer un `commit` antes de tocar nada: **guardar es barato, rehacer no.**

> [!summary] Qué aprendes
> Que **una interfaz gráfica no garantiza que lo que ves esté guardado**. Igual que en `nano` con `Ctrl+O`: escribir y guardar son dos acciones distintas, y solo la segunda cuenta.

---

> [!summary] 🎓 Lo que se llevan estos seis casos
> En una VPN **casi ningún fallo da un error claro**:
>
> - Un túnel puede decir *"activo"* y no transmitir nada.
> - Un servidor que no te conoce **te ignora en silencio**, y eso es correcto.
> - El **handshake** es el único dato que no miente.
> - Se diagnostica **de la red de abajo hacia el túnel**, nunca al revés.
> - Un DNS apuntando a un servicio inexistente rompe más que no ponerlo.
>
> **Cuando un sistema falla sin quejarse, la única salida es comprobar capa por capa.**

> [!tip] 💾 La red de seguridad
> Si te lías con las llaves, restaurar la instantánea **`Fase 2 terminada`** y repetir la fase cuesta menos que perseguir una llave mal pegada. Ver [[Fase_3.8_Punto_de_Control]].

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.6_Procedimiento]] | [[Fase_3]] | [[Fase_3.8_Punto_de_Control]] |
