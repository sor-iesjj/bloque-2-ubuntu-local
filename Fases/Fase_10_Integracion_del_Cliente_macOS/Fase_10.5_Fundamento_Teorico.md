## Fase 10 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. ¿Por qué esta fase? — el tercer sistema del RA.06
> Ya integraste Windows (propietario) y Ubuntu (libre). El RA.06 habla de *"integración de sistemas operativos libres y propietarios"* — y en el mundo real, el tercer sistema que más aparece es **macOS**: el portátil del jefe, el MacBook del turista, el de un diseñador.
>
> El objetivo es que **una VM de macOS acceda al servidor de Boochan igual que los otros dos clientes**, y vea lo mismo. Si lo consigues, has demostrado que el modelo de permisos **no depende del sistema del cliente**. **Y de paso, has montado una VM de macOS en VirtualBox** — que es el reto técnico de la fase.

> [!important] 2. Por qué macOS es distinto de Windows y Ubuntu en VirtualBox
> **Apple no deja que macOS se ejecute en cualquier hardware.** Solo en hardware Apple, o en una VM dentro de un Mac. VirtualBox, además, **no soporta macOS oficialmente**. Resultado: para meter macOS en VirtualBox sobre un PC hay que **saltarse dos muros**:
>
> | Muro | Qué es | Cómo se salta |
> | :--- | :--- | :--- |
> | **El firmware** | macOS exige EFI y CPU de Intel concretos. VirtualBox por defecto no los emula | Crear la VM con **`--firmware efi`**, y ajustar la CPU con `--cpuidset` para que macOS "crea" que está en hardware válido |
> | **El hipervisor** | macOS **no funciona si el hipervisor de Windows (VBS/NEM) está activo** — se corrompe | El host tiene que dar a VirtualBox el **VT-x real** (sin la tortuga). Es la misma exigencia de la Fase 8 |
>
> **Y este es el límite que hay que conocer:** se consigue (hay quien lo hace con scripts que bajan el instalador de los servidores de Apple), pero **es un hackintosh virtual** — Apple no lo autoriza, y solo tiene sentido como práctica educativa.

> [!important] 3. Acceso SMB — no es lo mismo que unirse
> En las Fases 8 y 9, el cliente se **unió al dominio** (se le creó una cuenta de equipo). En esta, la VM de macOS **accede** a las carpetas con un usuario del dominio, pero **no se une**.
>
> **La analogía:** una empresa tiene un servidor de archivos. Los empleados fijos tienen **cuenta de equipo** (se unen). Un visitante o un portátil ajeno **entra con su usuario y contraseña** cuando necesita un archivo — sin instalarse nada, sin pertenecer. Eso es lo que hace la VM de macOS.
>
> | | Unirse (Fases 8-9) | Acceder (esta fase) |
> | :--- | :--- | :--- |
> | Crea cuenta de equipo en el dominio | ✅ | ❌ |
> | Puede iniciar sesión con el usuario del dominio | ✅ | ✅ (contra el servidor) |
> | Ve las carpetas según la matriz | ✅ | ✅ |
> | Herramienta | `realm join` / asistente Windows | `smb://` en el Finder |

> [!warning] 4. Los dos servicios que necesita (y que ya montaste)
> Para que el Mac vea las carpetas, detrás trabajan dos servicios del servidor:
>
> | Servicio | Qué hace | Dónde vive |
> | :--- | :--- | :--- |
> | **SMB** | Sirve las carpetas compartidas (`[facturacion]`, `[comercial]`…) | Servidor (Fases 6-7) |
> | **Kerberos** | Autentica al usuario — **el reloj del Mac tiene que estar en hora** | Servidor (Fase 4) |
>
> **El Mac no inventa nada**: consume los recursos que el servidor ya publica.

> [!warning] 5. El fallo nº1: **la hora del Mac**
> Igual que en Windows y Ubuntu, **Kerberos rechaza más de 5 minutos de desfase**. Y un Mac tiene un añadido que lo pilla:
>
> > [!danger] 🛑 Si el reloj del Mac no está sincronizado, el acceso a las carpetas falla con un error de credenciales que no menciona la hora
> > Un Mac recién arrancado puede tener la hora desfasada (sobre todo si estuvo apagado o en suspensión). **Antes de intentar entrar**, comprueba que la hora del Mac es la correcta (Ajustes del sistema → Fecha y hora).
> >
> > **El error de acceso no dirá "es la hora"** — dirá que el nombre de usuario o la contraseña son incorrectos. Si la contraseña es correcta y no entra, revisa la hora.

> [!important] 6. El comando clave — `smb://`
> El Mac accede a las carpetas de red con el protocolo **SMB**, y en el Finder se escribe así:
>
> ```
> smb://UbuntuServer.BOOCHANLAB.LOCAL
> ```
>
> Es lo mismo que el `net use` de Windows (Fase 8) y el `smb://` de Nautilus (Fase 9), pero en el Finder de macOS. **La URL es la misma en los tres sistemas** — el servidor es el mismo.

> [!info] 7. Quién ve qué — la matriz, una vez más
> Con `masao.sato`, el Mac verá las **mismas** carpetas que vio en Windows y en Ubuntu: `comercial`, `facturacion`, `logistica`, `comun`. Y **no** verá `contabilidad` ni `rrhh` — porque el ABE lo oculta, y el ABE lo decide el servidor, no el cliente.

---

### 📖 Diccionario de Conceptos Clave

> [!quote] Integración de Clientes (macOS)
> - **SMB:** el protocolo de compartición de archivos en red (el de Samba y Windows).
> - **`smb://`:** la forma de escribir una carpeta de red en el Finder de macOS.
> - **Finder:** el gestor de archivos de macOS (equivalente al Explorador de Windows y a Nautilus).
> - **Acceso vs. unión:** entrar con un usuario del dominio (acceso) frente a tener cuenta de equipo (unirse).
> - **Clock Skew:** el desfase máximo (5 minutos) que Kerberos tolera.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.4_Donde_Estamos]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.6_Procedimiento]] |
