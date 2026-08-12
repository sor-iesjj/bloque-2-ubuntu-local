## Fase 9 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. ¿Por qué esta fase existe? — el RA.06
> En el mundo real, una oficina no es solo Windows. Un diseñador usa un Mac, un taller de informática tiene Linux, un turista alemán trae su MacBook. Todos necesitan **acceder a los mismos datos** del servidor. Eso es el `RA.06`: *integración de sistemas operativos libres y propietarios*.
>
> La Fase 8 integró Windows (propietario). Esta integra **Ubuntu Desktop (libre)**. El servidor es el mismo y la matriz de permisos es la misma — lo que cambia es el **lado cliente**. **Esa es la lección: el modelo de permisos no depende del sistema del cliente.**

> [!important] 2. La diferencia con la Fase 8 — unirse NO es lo mismo que acceder
> **La Fase 8 se unió al dominio con un asistente gráfico de Windows.** Esta fase se une con **herramientas de Linux**:
>
> | Fase 8 (Windows) | Fase 9 (Ubuntu Desktop) |
> | :--- | :--- |
> | Unirse con asistente gráfico (`Configuración → Sistema → Acerca de`) | Unirse con **`realm join`** (línea de comandos) |
> | RSAT para administrar | **SSSD** para autenticar contra el dominio |
> | Mapear carpetas con `net use` | Acceder con **Nautilus** (gestor de archivos) |
>
> **Son dos mundos resolviendo lo mismo** — y saber hacerlo en los dos es el valor de la fase.

> [!warning] 3. Los tres servicios que hacen posible la unión (y que ya montaste en las Fases 4-7)
> Cuando un Ubuntu Desktop se une al dominio, detrás hay **tres servicios hablando**:
>
> | Servicio | Qué hace | Dónde vive |
> | :--- | :--- | :--- |
> | **DNS** | Encontrar al controlador de dominio (`BOOCHANLAB.LOCAL` → `10.10.10.10`) | Servidor (Fase 4) |
> | **Kerberos** | Emitir los "tickets" de autenticación — **el reloj tiene que estar en hora** o falla todo | Servidor (Fase 4) |
> | **SMB** | Servir las carpetas compartidas | Servidor (Fase 6-7) |
>
> **El cliente no inventa nada**: consume lo que ya montaste. Por eso esta fase **no instala nada en el servidor**.

> [!warning] 4. `realm join` y SSSD — los dos protagonistas
> - **`realm join`**: la herramienta de Ubuntu que registra el equipo en el dominio. Es el equivalente a unirse por el asistente de Windows, pero por comandos. Le decimos qué dominio (`BOOCHANLAB.LOCAL`) y él negocia con el controlador.
> - **SSSD** *(System Security Services Daemon)*: el "traductor" que queda corriendo en el cliente. Cuando un usuario del dominio inicia sesión, SSSD pregunta al servidor *"¿quién es `masao.sato` y a qué grupo pertenece?"* y traduce la identidad del dominio a una identidad local (UID/GID). **Es el equivalente a `winbind`**, que ya usaste en el servidor en la Fase 5.
>
> > [!tip] 💡 El mismo `winbind` que configuraste en la Fase 5, pero en el cliente
> > En el **servidor**, winbind traduce las identidades del dominio para que el sistema Linux las entienda. En este **cliente**, **SSSD hace lo mismo** — pero para los usuarios que inician sesión en la máquina. Es la misma idea, en la otra punta del cable.

> [!warning] 5. NTP — el mismo reloj de siempre, y el fallo nº1 de esta fase
> **Kerberos rechaza cualquier autenticación con más de 5 minutos de desfase.** Es lo mismo que en la Fase 8, pero con un añadido que NO te avisa:
>
> > [!danger] 🛑 El fallo nº1 de esta fase: **la zona horaria del Ubuntu Desktop**
> > Una VM de Ubuntu Desktop recién instalada suele arrancar en hora **UTC**, no en hora española. Si el reloj está en UTC, el desfase con el servidor es de **2 horas en verano / 1 en invierno** — muy por encima de los 5 minutos.
> >
> > **El comando `realm join` no te avisa.** Te da un error de credenciales o de Kerberos que no menciona la hora. Si falla la unión "sin razón", lo primero: comprueba la hora.
> >
> > ```bash
> > timedatectl
> > ```
> > Si el `Time zone` no es `Europe/Madrid`, arréglalo antes de seguir:
> > ```bash
> > sudo timedatectl set-timezone Europe/Madrid
> > ```

> [!important] 6. El comando clave — `realm join` con `Administrator`
> Para unirse al dominio hace falta **una cuenta con permisos de administrador del dominio**: la de `BOOCHANLAB\Administrator` (la misma con la que te uniste en la Fase 8). **No sirve la de `boochan`** (la del servidor) ni la del usuario local del cliente — la unión la autoriza el dominio, y en el dominio el administrador es `Administrator`.
>
> ```bash
> sudo realm join --user=Administrator BOOCHANLAB.LOCAL
> ```

> [!warning] 7. Acceder a las carpetas — igual que en Windows, pero con Nautilus
> Ya unido, **no se ven solas**: hay que ir a buscar las carpetas compartidas, igual que en la Fase 8. En el gestor de archivos de Ubuntu (Nautilus), escribes la dirección:
>
> ```
> smb://UbuntuServer.BOOCHANLAB.LOCAL
> ```
>
> Y ahí aparecen **solo las carpetas a las que tiene permiso el usuario con el que has iniciado sesión** — la misma regla del ABE que viste desde Windows. `masao.sato` verá sus 4 carpetas y no las otras 3.

---

### 📖 Diccionario de Conceptos Clave

> [!quote] Integración de Clientes (Ubuntu)
> - **Unirse al dominio:** registrar el equipo en la base de datos del directorio. En Linux se hace con `realm join`.
> - **SSSD:** el demonio que traduce identidades del dominio a identidades locales (el "winbind del cliente").
> - **realm:** la herramienta de Linux para gestionar la pertenencia a un dominio.
> - **Nautilus:** el gestor de archivos de Ubuntu. Accede a carpetas de red con `smb://…`.
> - **Clock Skew:** el desfase máximo (5 minutos) que Kerberos tolera. El fallo nº1 de esta fase es la **zona horaria UTC**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.4_Donde_Estamos]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.6_Procedimiento]] |
