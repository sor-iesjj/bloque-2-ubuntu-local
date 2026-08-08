## Fase 3 · Apartado 6.b — 🛠️ Procedimiento — El cliente y el intercambio de llaves

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]] · ↩️ Procedimiento completo: [[Fase_3.6_Procedimiento]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Pasos 3 y 4 — configurar el otro extremo y cruzar las llaves públicas

> [!important] 📦 Las tres partes del apartado 6 son UN SOLO vídeo
> `B2 · F3 · Conectividad VPN`, de 8-10 minutos, cubre **6.a + 6.b + 6.c**. No grabes tres.
>
> Están separadas para que puedas seguirlas sin perderte, no porque sean tres entregas.

---
> [!example] Paso 3: Configuración del Lado Cliente
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"Cerré la ventana y perdí lo escrito"* → [[Fase_3.7_Resolucion_Problemas#E6 · Cerré la ventana y perdí la configuración|caso E6]]
> > · *"Activo la VPN y pierdo internet"* → [[Fase_3.7_Resolucion_Problemas#E5 · Activo la VPN y me quedo sin internet|caso E5]]
> El túnel VPN necesita dos extremos configurados. En el proyecto final, el "cliente" será la **VM Windows 11** que crearás en una fase posterior de este itinerario. Como esa VM todavía no existe, tienes dos caminos válidos para completar y probar esta fase ahora mismo:
>
> > [!tip] 💡 Opción A (recomendada): usa tu propio PC físico como cliente de prueba
> > Instala temporalmente la aplicación WireGuard en el PC donde corre VirtualBox. Como tu propio ordenador ya forma parte de la Red Solo Anfitrión del laboratorio (con IP `10.10.10.1`, configurada en la Fase 1.2), puedes usarlo directamente como cliente de prueba sin tocar nada más en VirtualBox. Esto te permite verificar el túnel de extremo a extremo *ahora*, sin esperar a tener la VM Windows 11 lista. Cuando más adelante crees esa VM, repetirás estos mismos pasos dentro de ella y usarás su llave pública en lugar de la de tu PC — el resto de la configuración del servidor no cambia.
>
> > [!tip] 💡 Opción B: deja el túnel preparado y sin probar
> > Si prefieres no instalar WireGuard en tu PC físico, puedes completar el archivo `wg0.conf` del servidor con una llave de cliente "provisional" (generada con `wg genkey | wg pubkey`, sin instalarla en ningún sitio todavía) y posponer la verificación del `ping 10.20.20.1` hasta la fase en la que crees la VM Windows 11. Ten en cuenta que en ese caso no podrás completar el Punto de Control de esta fase hasta entonces.
>
> **1. Instala la aplicación WireGuard** (si eliges la Opción A, en tu PC físico; si eliges completarlo más adelante, dentro de la futura VM Windows 11):
> - **Windows:** Ve a `wireguard.com/install`, descarga el instalador `.exe` y ejecútalo.
> - **Mac:** Búscalo en la App Store buscando "WireGuard" o descárgalo desde `wireguard.com/install`.
>
> **2. Crea un nuevo túnel y obtén las llaves del cliente:**
> - Abre la aplicación WireGuard.
> - Haz clic en **"Agregar túnel"** → **"Crear nuevo túnel vacío"** (en Mac: icono `+`).
> - WireGuard genera automáticamente las llaves del cliente. Verás la **Clave Pública** del cliente en la parte superior del cuadro de configuración.
> - **Copia y anota esa Clave Pública**: la necesitarás en el servidor.
>
> **3. Completa el archivo de configuración del cliente** con este contenido:
> ```ini
> [Interface]
> PrivateKey = <SE_RELLENA_AUTOMÁTICAMENTE_por_WireGuard>
> Address = 10.20.20.2/32
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_SERVIDOR_del_Paso_1>
> AllowedIPs = 10.20.20.0/24
> Endpoint = 10.10.10.10:51820
> PersistentKeepalive = 25
> ```
>
> > [!danger] 🛑 Aquí NO va todavía una línea `DNS`
> > Verás en muchos manuales —y en versiones anteriores de esta práctica— una línea `DNS = 10.20.20.1` dentro de `[Interface]`. **Ahora sería un error.**
> >
> > Esa línea le dice a tu ordenador: *"mientras el túnel esté activo, pregunta los nombres al servidor"*. Y tiene todo el sentido… **a partir de la Fase 4**, cuando Samba levante su DNS interno.
> >
> > **Pero hoy, en `10.20.20.1` no hay ningún servidor DNS.** Si la pones y activas el túnel, tu equipo enviará las consultas a un sitio donde no contesta nadie: **dejarás de navegar mientras la VPN esté conectada**. El síntoma es de los que despistan — *"activo la VPN y se me cae internet"* — porque nada apunta al fichero que lo causó.
> >
> > Es el mismo error de orden que evita el script de la Fase 4: **no apuntes el DNS a un servicio que todavía no existe.** La línea se añade en la **Fase 8**, cuando el cliente tenga que resolver nombres del dominio `BOOCHANLAB.LOCAL`.
>
> > [!important] 💾 **4. Pulsa `Guardar`.** Y NO actives el túnel todavía
> > El botón está abajo a la derecha del cuadro de configuración. Sin pulsarlo, **la configuración que acabas de escribir se pierde** al cerrar la ventana.
> >
> > Después de guardar verás el túnel en la lista, con un botón **`Activar`**. **No lo pulses aún.**
> >
> > **¿Por qué no?** Porque un túnel tiene dos extremos y **el servidor todavía no sabe quién eres**: aún no le has dado tu clave pública. Si activas ahora, WireGuard lo intentará, el servidor descartará tus paquetes por venir de un desconocido, y verás un túnel "activo" que no transmite nada — de los fallos más confusos que hay, porque la interfaz dice que todo va bien.
> >
> > Primero el Paso 4 (darle tu llave al servidor). **Activarás al final, y te lo diré.**
>
> > [!important] 💡 ¿Y el `Endpoint`? Aquí es distinto a la versión cloud
> > En BoochanV2/V3 el `Endpoint` era la IP pública del servidor en internet. Aquí, como todo vive dentro de VirtualBox, el `Endpoint` es simplemente la IP de la **Red Solo Anfitrión** del servidor: `10.10.10.10:51820`. El `PersistentKeepalive` sigue siendo una buena práctica a mantener (evita que ciertos firewalls o el propio sistema operativo den por "muerta" una conexión inactiva), aunque en una red local su necesidad real sea menor que atravesando el NAT de un proveedor cloud.

> [!danger] ⚠️ El error más común de esta fase: copiar el bloque del cliente en el servidor
> Los dos ficheros se parecen muchísimo y es facilísimo pegar el que no es. **No son intercambiables.** Así queda cada uno:
>
> | | **Servidor** (`/etc/wireguard/wg0.conf`) | **Cliente** |
> | :--- | :--- | :--- |
> | `[Interface]` `PrivateKey` | la **privada del servidor** | la **privada del cliente** |
> | `[Interface]` `Address` | `10.20.20.1/24` | `10.20.20.2/24` |
> | `[Interface]` `ListenPort` | `51820` | *(no lleva)* |
> | `[Peer]` `PublicKey` | la **pública del CLIENTE** | la **pública del SERVIDOR** |
> | `[Peer]` `AllowedIPs` | `10.20.20.2/32` *(solo ese cliente)* | `10.20.20.0/24` *(toda la red del túnel)* |
> | `[Peer]` `Endpoint` | ❌ **NUNCA** | ✅ `10.10.10.10:51820` |
> | `[Peer]` `PersistentKeepalive` | ❌ **NUNCA** | ✅ `25` |
>
> **Fíjate en el patrón:** en cada fichero, `[Interface]` habla de **ti mismo** y `[Peer]` habla **del otro**. Si en el servidor pones `Endpoint = 10.10.10.10`, le estás diciendo que para hablar con el cliente envíe los paquetes… **a sí mismo**.
>
> > [!info] 🤔 ¿Y por qué el servidor no necesita `Endpoint`?
> > Porque **lo aprende solo**: en cuanto recibe el primer saludo criptográfico válido del cliente, anota de dónde vino y le responde ahí. Eso permite que el cliente cambie de red, de Wi-Fi o de IP sin tocar nada en el servidor.
> >
> > El cliente sí lo necesita, porque alguien tiene que dar el primer paso y saber a qué puerta llamar.

> [!example] Paso 4: Intercambio de Llaves y Activación
>
> > [!bug] 🚩 Si algo falla aquí
> > · *"`Address already in use`"* → [[Fase_3.7_Resolucion_Problemas#E1 · Address already in use al levantar el túnel|caso E1]]
> > · *"Dice activo pero no pasa nada"* → [[Fase_3.7_Resolucion_Problemas#E3 · El túnel dice activo pero no pasa nada|caso E3]] — **el más traicionero**
> > · *"No hay ping a `10.20.20.1`"* → [[Fase_3.7_Resolucion_Problemas#E2 · No hay ping entre el servidor y el cliente|caso E2]]
> > · *"No encuentra el `Endpoint`"* → [[Fase_3.7_Resolucion_Problemas#E4 · El cliente no encuentra el Endpoint|caso E4]]
> Vuelve a la sesión SSH del servidor y completa el archivo `wg0.conf` con la llave pública del cliente que anotaste en el Paso 3:
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
> Sustituye `<LLAVE_PÚBLICA_DEL_CLIENTE>` por la llave pública real. Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!caution] ⚠️ Atención al Portapapeles (Copia-Pega)
> > Al borrar el texto de ejemplo `<LLAVE...>`, asegúrate de eliminar también los símbolos `<` y `>`. Un espacio extra, un salto de línea invisible o una letra comida arruinará la conexión VPN de forma silenciosa.
> >
> > **Antes de guardar**, verifica que la clave quedó bien pegada ejecutando:
> > ```bash
> > sudo grep PublicKey /etc/wireguard/wg0.conf
> > ```
> > La salida debe ser una sola línea limpia, sin espacios al principio ni al final, parecida a esto:
> > ```
> > PublicKey = aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890abcde=
> > ```
> > Si ves dos líneas, espacios raros o caracteres `<` o `>` sueltos, vuelve a editar el archivo antes de continuar.
>
> Ahora levanta el túnel en el servidor y hazlo persistente:
> ```bash
> # Levantar el túnel
> sudo wg-quick up wg0
> # Hacerlo persistente al reinicio
> sudo systemctl enable wg-quick@wg0
> ```
>

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.6.a_Procedimiento_Servidor]] | [[Fase_3.6_Procedimiento]] | [[Fase_3.6.c_Procedimiento_Levantar_el_Tunel]] |
