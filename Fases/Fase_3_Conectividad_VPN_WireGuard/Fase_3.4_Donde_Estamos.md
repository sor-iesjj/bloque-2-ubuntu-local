## Fase 3 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 2
> Completaste la purga del servidor y le diste identidad de dominio (`UbuntuServer.BOOCHANLAB.LOCAL`). Ahora tienes un servidor limpio, profesional, con identidad, accesible por SSH en `10.10.10.10` a través de la Red Solo Anfitrión de VirtualBox.

> [!warning] El Problema... ¿o no?
> En las versiones cloud de este proyecto (Azure/AWS), esta fase resuelve un problema real: el servidor tiene una IP pública expuesta a todo internet, y sin VPN cualquier bot podría intentar entrar por fuerza bruta al puerto 22. **Aquí, en tu laboratorio local, ese problema físicamente no existe:** tu servidor vive dentro de una Red Solo Anfitrión de VirtualBox, aislada de internet y de la red del instituto por diseño — nadie fuera de tu propio PC puede ni siquiera verla, y mucho menos atacarla desde internet.

> [!success] Objetivo de esta Fase (y por qué la hacemos igualmente)
> Vamos a instalar **WireGuard** igualmente, aunque no exista una amenaza real de internet que blindar. ¿Por qué? Porque el objetivo pedagógico de esta fase no es "protegerte de internet" sino **aprender a construir y verificar un túnel VPN cifrado punto a punto** — una habilidad profesional que se necesita tanto si el otro extremo está a un clic (como aquí) como si está a miles de kilómetros (como en las versiones cloud). Cuando más adelante crees la VM cliente Windows 11 en la misma Red Solo Anfitrión, ese cliente se conectará al servidor **a través de este túnel WireGuard**, no directamente por `10.10.10.10` — replicando exactamente el mismo modelo de seguridad "Zero Trust" que usarías en un entorno real, aunque técnicamente pudieras saltártelo por estar en la misma red virtual.

> [!tip] Hoja de Ruta
> 1. Instalar WireGuard en el servidor
> 2. Generar pares de llaves criptográficas (servidor + cliente)
> 3. Crear archivo de configuración `wg0.conf` en el servidor, con el rango de túnel `10.20.20.0/24`
> 4. Preparar la configuración del lado cliente (la usará la futura VM Windows 11, o un cliente de prueba mientras tanto)
> 5. Activar el túnel y verificar con `ping 10.20.20.1` desde el cliente
> 6. Verificar el `latest handshake` en el servidor — la prueba criptográfica de que el túnel está vivo
>
> **Resultado Final:** Túnel WireGuard montado, autenticado y verificado desde el cliente. *(El cierre del acceso directo se hace en la **Auditoría Final**: aquí el servidor sigue accesible por `10.10.10.10` porque quedan cinco fases de trabajo.)*
> **Siguiente:** Fase 4 (Dominio) — provisionar el Active Directory. Ahora que hay conexión VPN cifrada, puedes instalar servicios críticos.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.3_Obligaciones_Grabacion]] | [[Fase_3_Conectividad_VPN_WireGuard]] | [[Fase_3.5_Fundamento_Teorico]] |
