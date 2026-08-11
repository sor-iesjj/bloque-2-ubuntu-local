## Fase 8 · Apartado 7 — 🛑 E9 bis · Diagnóstico avanzado de VBS

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** solo si has aplicado **todos** los pasos del [[Fase_8.7_Resolucion_Problemas#E9 · La VM de Windows se cuelga y VirtualBox muestra una tortuga|E9]] —`bcdedit`, OptionalFeatures, Memory Integrity, reinicio— y `msinfo32` **sigue** diciendo «Seguridad basada en virtualización: En ejecución».

---

> [!info] 🎯 Objetivo real
> Desactivar los componentes del hipervisor de Windows que la GUI de OptionalFeatures **no alcanza**, identificar las políticas de plataforma que fuerzan VBS, y **saber cuándo parar** — porque a veces la tortuga se queda y la VM funciona igual.

> [!warning] 🧩 El problema que resuelve
> Has agotado los pasos del E9 y no ha funcionado. No es que lo hayas hecho mal: el E9 cubre el 80 % de los casos. Este documento cubre el 20 % restante.
>
> **Y lo último es lo más importante:** que la VM funcione no equivale a que la tortuga desaparezca. **Son dos cosas distintas**, y mezclarlas te hace desinstalar cosas que no necesitas tocar.

---

## 🗺️ Índice rápido

| Lo que ves | Paso |
| :--- | :--- |
| Quiero saber **exactamente** qué mantiene VBS encendido | [[#1 · Diagnóstico en profundidad\|A1]] |
| OptionalFeatures no quita el hipervisor — `dism` sí | [[#2 · Desactivar con dism\|A2]] |
| `hypervisorlaunchtype` ya está `Off` pero VBS sigue | [[#3 · Verificar bcdedit\|A3]] |
| ¿Puede el Secure Boot de la BIOS ser el culpable? | [[#4 · Secure Boot en la BIOS\|A4]] |
| Ya está todo hecho, `msinfo32` **sigue** diciendo `Running` | [[#5 · Cuando la tortuga se queda — y la VM funciona\|A5]] 🟢 |

---

## 1 · Diagnóstico en profundidad

Antes de tocar nada, mira **qué está forzando VBS**. PowerShell como administrador:

```powershell
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
```

Busca en la salida estas líneas:

| Línea | Lo que significa |
| :--- | :--- |
| `Virtualisation-based security: Running` | VBS está activa. Ya lo sabías |
| `App Control for Business policy: Enforced` | 🟠 Hay políticas de control de aplicaciones que **pueden mantener VBS encendida** sin que aparezcan servicios debajo |
| `Virtualisation-based security services configured:` *(vacío)* | No hay Credential Guard ni HVCI. **VBS corre sin ningún servicio encima** — nadie la necesita |
| `Virtualisation-based security services running:` *(vacío)* | Igual. Ni un solo servicio de seguridad usa VBS |

> [!warning] ⚠️ Si `App Control for Business policy` dice `Enforced`
> No es un virus ni un malware: es una política de Microsoft que viene **de fábrica** en muchos equipos (especialmente portátiles con Windows 11 Pro preinstalado). Si además los servicios salen **vacíos**, VBS está corriendo sin razón — encendida por configuración de arranque, no porque algo la necesite.

Para ver **qué políticas concretas** están forzando la máquina:

```powershell
citool --list-policies
```

Busca las que digan `Is Currently Enforced: true`. Un equipo con VBS forzada de fábrica suele mostrar:

| Política (ejemplo real, 11/08/2026) | Qué es |
| :--- | :--- |
| `Microsoft Windows Virtualization Based Security Policy` | 🔴 **La que fuerza VBS.** Firmada por Microsoft, parte de la imagen base de Windows |
| `Microsoft Windows Endpoint Security Policy` | Refuerzo de seguridad del sistema |
| `Microsoft Windows Driver Policy` | Control de integridad de drivers |

Las tres son `Platform Policy: true`, `Is Signed: true`, y `Is Currently Enforced: true`. **No las puedes borrar ni desactivar desde Windows.** Forman parte del sistema base.

---

## 2 · Desactivar con `dism`

La GUI de OptionalFeatures (`Windows + R` → `OptionalFeatures`) **no siempre quita todos los componentes del hipervisor**. `dism` es más fiable.

En **PowerShell como administrador**, en este orden y sin reiniciar entre medias:

```powershell
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart
```

> Respuesta esperada: `The operation completed successfully.`

```powershell
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart
```

> Respuesta esperada: `The operation completed successfully.`

```powershell
dism /online /disable-feature /featurename:Windows-Subsystem-Linux /norestart
```

> ⚠️ Si esta última da `Feature name Windows-Subsystem-Linux is unknown`, no pasa nada: WSL no está instalado en tu equipo. Es una de las tres palancas y no siempre está presente. Las otras dos son las que importan.

> [!danger] 🛑 El `/norestart` es crítico
> Sin él, Windows reinicia **al terminar el primer `dism`** y los siguientes no se ejecutan. Los tres comandos se lanzan seguidos, **sin reiniciar**, y el reinicio va al final.

---

## 3 · Verificar `bcdedit`

Aunque ya lo hiciste en el E9, verifícalo **después del `dism`**, porque `dism` a veces lo resetea:

```powershell
bcdedit /set hypervisorlaunchtype off
```

Comprueba que se aplicó:

```powershell
bcdedit /enum '{current}'
```

> 💡 **Las comillas en PowerShell no son decorativas.** Sin ellas, `{current}` es un bloque de código y el comando no hace lo que esperas.

Debe aparecer: `hypervisorlaunchtype    Off`.

---

## 4 · Secure Boot en la BIOS

VBS se apoya en Secure Boot para cargar antes que cualquier otra cosa. Si el firmware tiene Secure Boot activado, VBS puede arrancar aunque todo lo demás esté desactivado.

Reinicia y entra en la BIOS/UEFI (suele ser `F2`, `Del`, `Esc` o `F10`). Busca **Secure Boot** y ponlo en **Disabled**.

> [!warning] ⚠️ No todos los equipos dejan tocar esto
> En un portátil de Consellería o de empresa, la BIOS suele estar bloqueada. Si no puedes desactivarlo, no es tu culpa — sigue al paso 5.

Guarda, sal, y deja que Windows arranque.

---

## 5 · Cuando la tortuga se queda — y la VM funciona 🟢

> [!success] 🔑 LA CLAVE DE TODO ESTE DOCUMENTO
> Llegados aquí, abre `msinfo32`. Si sigue diciendo `Running`, **no importa**. Lo que importa es **si la VM funciona**.
>
> **Son dos cosas distintas:**
> - Que `msinfo32` diga `Running` → significa que el hipervisor de Windows **está cargado**.
> - Que la VM **funcione** → significa que el hipervisor **ha aflojado lo suficiente**.
>
> Tras los pasos A2-A4, aunque `msinfo32` no cambie, el hipervisor de Windows **ya no acapara VT-x como antes**. VirtualBox tiene más acceso al hardware.
>
> **Prueba real (11/08/2026):** en un Huawei MateBook con Windows 11 Pro, VBS seguía `Running` tras los pasos 2-4, con tres políticas de Microsoft forzadas desde la imagen base… y la VM de Windows 11 **arrancó**. La tortuga se quedó en la barra de estado, pero el invitado funciona.

> [!danger] ⚠️ Si la VM SIGUE sin arrancar después de todo esto
> **Aquí se acaba tu margen.** Si el equipo es tuyo y tienes Plan C (Hyper-V): úsalo. El hipervisor ya está corriendo — que trabaje para ti en vez de contra ti.
>
> Si es un equipo del centro, **avisa al profesor**. Hay soluciones (cliente en Hyper-V, reconfiguración de red) pero ninguna la decides tú.

---

> [!summary] 🎓 Qué has aprendido
> 1. **Que `msinfo32` diga «Running» no es una sentencia.** Después de aflojar el hipervisor con `dism` + `bcdedit` + Secure Boot, el comportamiento real puede cambiar aunque la etiqueta no.
> 2. **`dism` llega donde OptionalFeatures no llega.** La GUI desmarca cosas; `dism` las quita del todo.
> 3. **Leer políticas con `citool` y `Get-CimInstance` antes de tocar nada.** Sin el diagnóstico, cada cambio es un disparo a ciegas.
> 4. **Hay políticas de Microsoft que no se pueden desactivar** — vienen firmadas en la imagen base y no hay palanca en Windows que las mueva. No es un fallo de configuración: es la decisión del fabricante.

---

| ← Volver al E9 | 🧭 Resolución de problemas |
| :--- | :--- |
| [[Fase_8.7_Resolucion_Problemas#E9 · La VM de Windows se cuelga y VirtualBox muestra una tortuga\|E9 — La tortuga]] | [[Fase_8.7_Resolucion_Problemas]] |
