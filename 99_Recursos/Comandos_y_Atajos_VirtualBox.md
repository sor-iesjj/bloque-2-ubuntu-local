# 🖥️ Comandos y Atajos de VirtualBox

Esta guía no existe en BoochanV2 (Azure) ni en BoochanV3 (AWS), porque allí la "máquina" ya viene creada por el proveedor cloud. En **BoochanV1 tú eres quien crea, configura y administra el hipervisor**, así que necesitas dominar la interfaz de VirtualBox tanto como los comandos de Linux. Úsala como referencia rápida a lo largo de las Fases 1 y 8 (creación de VMs) y en cualquier momento que necesites un snapshot de seguridad.

> [!info] Interfaz gráfica, no terminal
> A diferencia del resto del Diccionario de Comandos (que son órdenes de texto), la mayoría de las acciones de esta guía se hacen con el **VirtualBox Manager**, la ventana principal del programa. Se indican las rutas de menú tal como aparecen en VirtualBox 7.x — en versiones distintas el texto exacto puede variar ligeramente, pero la ubicación es la misma.

---

## 🏗️ 1. Crear y configurar una VM

### Crear una máquina virtual nueva
> **Ruta:** `Máquina → Nueva` (o el botón `Nueva` en la barra superior)

> [!example] Valores usados en BoochanV1 (Fase 1 y Fase 8)
> | VM | RAM | vCPU | Disco (VDI dinámico) | Uso |
> | :--- | :--- | :--- | :--- | :--- |
> | `UbuntuServer` | 2048 MB (subir a 3072-4096 MB en Fase 4) | 2 | 20 GB | Servidor Samba AD DC |
> | `Cliente-Windows11` | 4096 MB (6144 MB si el host tiene ≥16 GB) | 2 | 40 GB | Cliente de dominio |
>
> El tipo de disco **VDI de asignación dinámica** es el recomendado siempre: el archivo empieza pequeño y crece según se necesita, en vez de reservar de golpe todo el espacio.

### Cambiar la RAM o CPU asignada (VM apagada)
> **Ruta:** Selecciona la VM → `Configuración` (icono de rueda dentada) → pestaña `Sistema` → `Placa base` (RAM) o `Procesador` (CPU)

> [!caution] ⚠️ Solo con la VM apagada
> VirtualBox no permite cambiar la RAM base ni el número de CPUs mientras la VM está encendida. Debes apagarla primero (`Cerrar → Apagar la máquina` o `sudo poweroff` desde dentro de Linux).

### Montar/desmontar una ISO en la unidad óptica virtual
> **Ruta:** `Configuración → Almacenamiento` → selecciona el icono de disquete/CD bajo el controlador → icono de disco a la derecha → `Elegir un archivo de disco...`

> [!example] Uso en BoochanV1
> - Fase 1: montar la ISO de Ubuntu Server 26.04 LTS para instalar el servidor.
> - Fase 8: montar la ISO de Windows 11 para instalar la VM cliente.
> - Al terminar la instalación, VirtualBox expulsa la ISO automáticamente cuando el instalador te lo pide (pulsa Enter).

---

## 🌐 2. Redes: NAT y Red Solo Anfitrión (Host-Only)

Esta es la parte más importante y la que más errores genera en BoochanV1. Repásala junto con la Fase 1.

### Habilitar y configurar un adaptador de red
> **Ruta:** Selecciona la VM (apagada) → `Configuración → Red` → pestañas `Adaptador 1`, `Adaptador 2`, etc.

> [!example] Configuración estándar del proyecto
> | Adaptador | Conectado a | Uso |
> | :--- | :--- | :--- |
> | **Adaptador 1** | `NAT` | Salida a internet (apt, git clone, activación de Windows) |
> | **Adaptador 2** | `Red Solo Anfitrión` (Host-only Adapter), red `vboxnet0` | Comunicación aislada servidor ↔ cliente ↔ host, `10.10.10.0/24` |

### Crear o editar una red Solo Anfitrión (Host-Only Network)
> **Ruta:** `Herramientas → Redes` (icono en la parte superior del VirtualBox Manager) → pestaña `Redes solo-anfitrión` → botón `+` (crear) o icono de lápiz (editar)
>
> *(En versiones más antiguas: `Archivo → Herramientas → Administrador de red del anfitrión`)*

> [!example] Configuración de `vboxnet0` en BoochanV1 (Fase 1)
> 1. Pestaña **Adaptador**:
>    - Dirección IPv4: `10.10.10.1`
>    - Máscara de subred: `255.255.255.0`
> 2. Pestaña **Servidor DHCP**: **desmarcar** "Habilitar servidor" — la IP del servidor (`10.10.10.10`) y del cliente (`10.10.10.20`) se fijan a mano dentro de cada VM, no por DHCP.
>
> > [!important] 💡 Por qué evitamos el rango por defecto
> > VirtualBox suele crear `vboxnet0` con el rango `192.168.56.0/24` de fábrica. En BoochanV1 lo cambiamos deliberadamente a `10.10.10.0/24` para que nunca se confunda con una red Wi-Fi doméstica típica (`192.168.x.x`).

### Comprobar qué redes host-only existen y su estado
> **Ruta:** Misma ventana que arriba (`Herramientas → Redes → Redes solo-anfitrión`). Muestra el nombre (`vboxnet0`, `vboxnet1`...), la IP del adaptador y si el DHCP está activo.

> [!tip] 💡 Diagnóstico rápido: ¿por qué dos VMs no se ven?
> La causa más común de que el servidor y el cliente Windows no se vean entre sí es que **cada uno esté conectado a una red host-only distinta** (por ejemplo, el cliente creó sin querer una `vboxnet1` nueva en lugar de reutilizar `vboxnet0`). Verifica en `Configuración → Red → Adaptador [Solo Anfitrión]` de ambas VMs que el nombre de red coincide exactamente.

---

## 📸 3. Snapshots (instantáneas)

Los snapshots son la red de seguridad de BoochanV1: te permiten volver atrás si rompes algo en una fase, sin repetir toda la práctica desde cero. En la nube (V2/V3) esto lo resolvían los discos EBS/managed disks del proveedor; aquí lo resuelve VirtualBox directamente.

### Crear un snapshot
> **Ruta:** Selecciona la VM → `Máquina → Instantánea → Tomar...` (o el icono de cámara en la pestaña "Instantáneas" del panel derecho)

> [!tip] 💡 Cuándo tomar un snapshot en BoochanV1
> - Justo después de terminar la **Fase 1** (VM instalada y con red verificada) — así nunca tienes que reinstalar Ubuntu desde cero.
> - Justo después de terminar la **Fase 4** (dominio provisionado) — es el paso más largo y más propenso a fallos; si algo se rompe en la Fase 5 o 6, puedes volver aquí sin re-provisionar el AD.
> - Antes de cualquier paso marcado como `⚠️ crítico` en las tablas de troubleshooting de las fases (por ejemplo, antes de editar `/etc/fstab` en la Fase 6).

### Restaurar (volver a) un snapshot
> **Ruta:** Panel derecho, pestaña "Instantáneas" → clic derecho sobre el snapshot deseado → `Restaurar instantánea...`

> [!caution] ⚠️ Restaurar borra el estado posterior
> Al restaurar un snapshot, **todo lo que hiciste después de tomarlo se pierde** (a menos que también hayas tomado un snapshot posterior). Es como una máquina del tiempo de un solo sentido salvo que guardes puntos intermedios.

### Eliminar un snapshot antiguo
> **Ruta:** Clic derecho sobre el snapshot → `Eliminar instantánea`

> [!tip] 💡 ¿Por qué borrar snapshots?
> Cada snapshot ocupa espacio en disco (guarda los cambios del disco virtual desde ese punto). Si el disco del host anda justo de espacio, borra los snapshots de fases ya superadas y verificadas — por ejemplo, una vez completada y evaluada la Fase 8, ya no necesitas el snapshot de la Fase 1.

---

## ⚡ 4. Otros comandos útiles del VirtualBox Manager

### Apagar una VM de forma segura vs. forzada
> **Ruta:** Clic derecho sobre la VM en ejecución → `Cerrar`
> - **`Enviar señal de apagado`** (ACPI Shutdown): equivalente a pulsar el botón de apagado de un PC real — Linux/Windows se apagan de forma ordenada, guardando el estado de servicios como Samba. **Es la opción recomendada siempre que sea posible**, especialmente antes de la Fase 6 (discos con fstab).
> - **`Apagar la máquina`** (Power Off): equivalente a desenchufar el cable de corriente. Solo úsalo si la VM está congelada y no responde — puede corromper datos si había escrituras pendientes en disco.

### Ver la dirección MAC y otros detalles del adaptador
> **Ruta:** `Configuración → Red → Adaptador [X] → Avanzadas`
> Útil si necesitas identificar qué interfaz de red (`enp0s3`, `enp0s8`...) corresponde a qué adaptador de VirtualBox al hacer `ip a` dentro de la VM.

### Exportar/Importar una VM completa (Appliance OVA)
> **Ruta:** `Archivo → Exportar servicio virtualizado...` / `Archivo → Importar servicio virtualizado...`

> [!tip] 💡 Uso potencial en el aula
> Si el profesor prepara una VM base ya purgada (Fase 2 completada) para ahorrar tiempo de clase, la forma de distribuirla a los equipos del aula es exportarla a un archivo `.ova` e importarla en cada VirtualBox — mucho más rápido que repetir la instalación de Ubuntu Server en cada puesto.
