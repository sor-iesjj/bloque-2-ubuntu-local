## Fase 10 · Apartado 6 — 🛠️ Procedimiento

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Con el Mac delante.** Aquí está el trabajo.

---

> [!example] Paso 0 — Prepárate y empieza a grabar
> 1. Léete el procedimiento entero.
> 2. Ten OBS listo y comprueba pantalla y micrófono.
> 3. Arranca la grabación, **preséntate y muestra tu identidad**. Todo lo que sigue queda grabado.
>
> **Lo que ya tienes:** el servidor encendido con el dominio y las carpetas publicadas (Fases 1-7), y los clientes Windows y Ubuntu ya integrados (Fases 8-9). No toques nada del servidor.

> [!example] Paso 1 — Comprueba que el Mac llega al servidor
> Abre **Terminal** (Aplicaciones → Utilidades) y comprueba la red:
> ```bash
> ping -c 2 10.10.10.10
> ```
> - **✅ Bien:** el servidor responde.
> - **❌ Mal:** el Mac no está en la red del laboratorio. El Mac tiene que poder llegar a `10.10.10.10` — igual que llegaban Windows y Ubuntu.

> [!warning] ⚠️ ¿Y si el Mac está en otra red?
> En un aula, el Mac y el servidor pueden no estar en la misma red física. Para esta fase, el Mac necesita **alcanzar** el servidor: por la red del laboratorio (si está en ella) o por el túnel WireGuard. Si no llega, avisa al profesor.

> [!example] Paso 2 — Comprueba que resuelve el dominio
> ```bash
> ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
> ```
> - **✅ Bien:** responde con la IP del servidor.
> - **❌ Mal:** el Mac no resuelve `BOOCHANLAB.LOCAL`. Prueba a usar la IP directa en el Paso 3, o avisa al profesor. *(La resolución de nombres del dominio la da el servidor DNS; un Mac de fuera puede no tenerla configurada.)*

> [!example] Paso 3 — Comprueba la hora del Mac (el fallo nº1)
> **Ajustes del sistema → Fecha y hora** → comprueba que la hora es la correcta y que está **automática**.
>
> - **✅ Bien:** la hora coincide con la de España y con la del servidor.
> - **❌ Mal:** está desfasada → actívala automática o ajústala a mano. **Si no, Kerberos te rechazará el acceso con un error que no habla de la hora.**

> [!example] Paso 4 — Accede a las carpetas del servidor desde el Finder
> 1. Abre el **Finder**.
> 2. Menú **Ir → Conectarse al servidor…** (o `Cmd + K`).
> 3. En el campo *Dirección del servidor*, escribe:
> ```
> smb://UbuntuServer.BOOCHANLAB.LOCAL
> ```
> 4. Pulsa **Conectar**.
> 5. Cuando pida sesión, elige **usuario registrado** y entra con:
>    - **Nombre:** `masao.sato` (o `BOOCHANLAB\masao.sato`)
>    - **Contraseña:** `P@ssw0rd`
> 6. Se abre una ventana con las carpetas compartidas.

> [!example] Paso 5 — Verifica qué ves (la matriz)
> Con `masao.sato`, debes ver **exactamente** las carpetas de su matriz:
> - **✅ Bien:** `comercial`, `facturacion`, `logistica`, `comun` — y **no** `contabilidad` ni `rrhh`.
> - **❌ Mal:** si ves lo ajeno, hay un permiso de más (pero no debería: el ABE lo oculta).

> [!example] Paso 6 — Cierra la grabación y súbela
> Detén OBS, nombra el vídeo **`B2 · F10 · Procedimiento`**, súbelo a `B2_Ubuntu_Local` como No listado y añade timestamps.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.5_Fundamento_Teorico]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.7_Resolucion_Problemas]] |
