# 🚀 Bloque 2 · Ubuntu en local — Infraestructura de servidores sobre VirtualBox

> **Módulo:** Sistemas Operativos en Red (SOR) · 2.º Curso SMR
> **Profesor:** Pedro Navarro Miralles · IES Jorge Juan (Alicante)
> **Correo:** p.navarromiralles2@edu.gva.es
> **Entorno:** VirtualBox (máquina virtual local, sin cuenta cloud) — adaptación local del Bloque 4 (Ubuntu en la nube: Azure y AWS)
> **RA cubiertos:** RA.01, RA.02, RA.03, RA.04, RA.05, RA.06
> **⏱️ Tiempo estimado total:** ~14-15 horas repartidas en 9 sesiones (ver desglose por fase más abajo)

---

## ¿Qué es este proyecto?

El Bloque 2 es un itinerario práctico de **8 fases + auditoría final** en el que el alumno construye, desde cero y **dentro de su propio ordenador** (sin cuenta cloud, sin coste, sin depender de la conexión del aula), una infraestructura profesional completa: un servidor Ubuntu con **Controlador de Dominio (Samba AD DC)**, **VPN WireGuard**, **cuotas de disco**, **permisos avanzados (ACL + ABE)** y un **cliente Windows 11** integrado en el dominio — todo ello ejecutado como máquinas virtuales dentro de **VirtualBox**.

Es la versión **local** del proyecto Boochan. La teoría, los comandos y los ejercicios son los mismos que en el **Bloque 4 · Ubuntu en la nube** (Azure y AWS), pero adaptados al ecosistema de virtualización de escritorio: **VirtualBox, Red Solo Anfitrión (Host-Only), adaptador NAT y snapshots**, en lugar de EC2/VM cloud, Security Groups/NSG e IPs públicas.

---

## ¿Por qué una versión local? Diferencias con el Bloque 4 (Ubuntu en la nube)

**El itinerario pedagógico es idéntico** en las tres versiones: mismo dominio Active Directory con Samba, misma VPN WireGuard, mismas cuotas con Loop Devices, mismas ACL + ABE, mismo cliente Windows 11 integrado. Un alumno que complete el Bloque 2 ha aprendido exactamente los mismos conceptos y comandos que uno que haga el Bloque 4 en Azure o en AWS — samba-tool, setfacl, wg-quick, fstab con `loop`, RSAT, todo se reutiliza sin cambios de fondo.

Lo que cambia es **dónde vive la infraestructura y quién es responsable de que funcione**. En el Bloque 4 el alumno "alquila" un servidor real en Azure o AWS: hay una IP pública, un firewall perimetral gestionado por el proveedor (NSG / Security Group) y una cuenta cloud con crédito limitado (AWS Academy Learner Lab). En el **Bloque 2 no hay proveedor, no hay factura, no hay cuenta que crear ni credencial que perder**: el alumno es "el superordenador" — VirtualBox reparte la RAM y CPU de su propio portátil entre el sistema anfitrión (host) y dos máquinas virtuales (servidor Ubuntu + cliente Windows 11), conectadas entre sí por una **Red Solo Anfitrión** privada y aislada de la red del instituto. No hay Security Group que abrir: el filtrado de tráfico se hace *dentro* del propio servidor con `ufw`, como se ve en la Auditoría Final.

Esto hace que el Bloque 2 sea la opción preferible cuando no hay presupuesto para una cuenta cloud por alumno, cuando la conexión a internet del aula no es fiable, o simplemente como **primer contacto** con virtualización antes de dar el salto a la nube: entender cómo se construye un hipervisor de Tipo 2 en el propio hardware es la base sobre la que después se entiende, por comparación, qué hace realmente un proveedor cloud con un hipervisor de Tipo 1. Las limitaciones son las lógicas de trabajar con hardware compartido de aula: RAM limitada (portátiles de 8 GB compartidos entre turnos), dependencia de que VirtualBox esté ya instalado (los alumnos no tienen permisos de administrador) y el hecho de que, a diferencia de la nube, si el portátil se apaga o se queda sin batería, el "datacenter" del alumno se apaga con él.

---

## ⚠️ Antes de empezar: requisitos del equipo del aula (LÉEME)

- **VirtualBox debe estar ya instalado** en el equipo del aula. Instalarlo requiere permisos de administrador del sistema operativo anfitrión, y **los alumnos no tienen esos permisos**. Si VirtualBox no está instalado y el alumno no puede instalarlo, la práctica **no es viable en ese equipo** — hay que avisar al profesor para que el departamento de informática del centro lo instale de antemano en la imagen del equipo, o usar un equipo personal con permisos completos. Ver el detalle completo en la advertencia de la **[Fase 1](Fases/Fase_1_Infraestructura_Virtual_Local.md)**.
- **RAM mínima recomendada:** 2 GB libres para la VM del servidor en las Fases 1-3 (subir a 3-4 GB a partir de la Fase 4, cuando se provisiona Samba AD DC), más 4 GB adicionales para la VM cliente Windows 11 a partir de la Fase 8. En un portátil de aula de 8 GB totales, es fácil quedarse justo si ambas VMs están encendidas a la vez — cierra el resto de aplicaciones del host antes de trabajar.
- **Disco libre:** al menos 20 GB para la VM del servidor (disco VDI dinámico) + 40 GB para la VM cliente Windows 11 + margen para los discos virtuales de cuotas de la Fase 6 (**8 GB + 2 GB = 10 GB**).
- **Virtualización por hardware (VT-x/AMD-V) activada en la BIOS** del equipo anfitrión. En equipos de aula gestionados centralizadamente puede estar bloqueada — si el instalador de VirtualBox no arranca la VM, es la primera causa a descartar con el profesor.
- **ISOs necesarias:** Ubuntu Server 26.04 LTS (Fase 1) y Windows 11 (Fase 8).

---

## 🗺️ Índice de fases

| Fase | Título | Concepto VirtualBox / Linux clave |
|------|--------|-------------------------------------|
| [1](Fases/Fase_1_Infraestructura_Virtual_Local.md) | Infraestructura Virtual Local (VirtualBox) | Hipervisor Tipo 2, VM, red NAT + Red Solo Anfitrión (`10.10.10.0/24`), IP estática |
| [2](Fases/Fase_2_Purga_y_Preparacion_del_Entorno.md) | Purga y Preparación del Entorno | Limpieza Ubuntu, FQDN, `/etc/hosts`, dominio `.LOCAL` |
| [3](Fases/Fase_3_Conectividad_VPN_WireGuard.md) | Conectividad VPN (WireGuard) | Túnel cifrado sobre red ya aislada, defensa en profundidad, cierre SSH directo |
| [4](Fases/Fase_4_Aprovisionamiento_del_Dominio.md) | Aprovisionamiento del Dominio (Samba AD DC) | Active Directory, Kerberos, DNS interno, sin firewall perimetral que abrir |
| [5](Fases/Fase_5_Gestion_de_Identidades.md) | Gestión de Identidades (Usuarios y Grupos) | winbind, RFC 2307, UID/GID |
| [6](Fases/Fase_6_Almacenamiento_Virtual_Cuotas.md) | Almacenamiento Virtual (Cuotas) | Loop Devices, `fstab` con `loop`, cuota física infranqueable |
| [7](Fases/Fase_7_Seguridad_Avanzada_ACL_y_ABE.md) | Seguridad Avanzada (ACLs y ABE) | Permisos granulares, carpetas invisibles (Access Based Enumeration) |
| [8](Fases/Fase_8_Integracion_del_Cliente_Windows_11.md) | Integración del Cliente (Windows 11) | Segunda VM en la misma Red Solo Anfitrión, unión al dominio, RSAT, mapeo de unidades |
| [Final](Fases/Auditoria_Final.md) | Auditoría Final y Hardening | Zero Trust con `ufw` local (sin Security Group externo que restringir) |

### Resumen de cada fase

**[Fase 1 — Infraestructura Virtual Local](Fases/Fase_1_Infraestructura_Virtual_Local.md):** se crea la VM `UbuntuServer` en VirtualBox (2 GB RAM, 2 vCPU, disco de 20 GB sin preasignar) con dos adaptadores de red — NAT para salida a internet y Red Solo Anfitrión (`10.10.10.0/24`, DHCP desactivado) para la comunicación aislada servidor-cliente-host — y se instala Ubuntu Server 26.04 LTS con IP estática `10.10.10.10`. Se fija el nombre del dominio de todo el proyecto: `BOOCHANLAB` / `BOOCHANLAB.LOCAL`.

**[Fase 2 — Purga y Preparación del Entorno](Fases/Fase_2_Purga_y_Preparacion_del_Entorno.md):** se elimina el Samba preinstalado (libera el puerto 445), se instalan las dependencias de Samba AD DC/Kerberos/winbind, y se configura el FQDN completo del servidor (`UbuntuServer.BOOCHANLAB.LOCAL`) en `/etc/hostname` y `/etc/hosts`, requisito imprescindible para que Kerberos funcione en la Fase 4.

**[Fase 3 — Conectividad VPN (WireGuard)](Fases/Fase_3_Conectividad_VPN_WireGuard.md):** se instala un túnel WireGuard (`10.20.20.0/24`) aunque la Red Solo Anfitrión ya esté aislada de internet por diseño — el objetivo es puramente pedagógico: aprender a construir y verificar un túnel VPN cifrado punto a punto, la misma habilidad que en el Bloque 4 (nube) sí resuelve un problema real de exposición pública.

**[Fase 4 — Aprovisionamiento del Dominio (Samba AD DC)](Fases/Fase_4_Aprovisionamiento_del_Dominio.md):** se ejecuta el script `provision_boochan.sh` (variables `BOOCHANLAB` / `BOOCHANLAB.LOCAL`) que provisiona el Active Directory con LDAP, Kerberos y DNS interno, y hace inmutable `/etc/resolv.conf` (`chattr +i`) para que apunte siempre a `127.0.0.1`. Aquí no hay ningún Security Group ni NSG que abrir: la Red Solo Anfitrión no filtra tráfico entre VMs.

**[Fase 5 — Gestión de Identidades (Usuarios y Grupos)](Fases/Fase_5_Gestion_de_Identidades.md):** se activa `winbind` como traductor de identidades (SID de Windows ↔ UID/GID de Linux) mediante RFC 2307, y se crean los **seis grupos departamentales** de Boochan S.L. (`facturacion`, `contabilidad`, `comercial`, `logistica`, `rrhh`, `becarios` — GID 3001-3006) y sus **doce usuarios** (UID 10001-10012), que se usarán en las Fases 6-8 para demostrar segregación de datos.

**[Fase 6 — Almacenamiento Virtual (Cuotas)](Fases/Fase_6_Almacenamiento_Virtual_Cuotas.md):** se crean **dos discos virtuales** mediante Loop Devices (`dd` + `mkfs.ext4` + `fstab` con la opción `loop`): `/samba_deptos.img` (8 GB) montado en `/srv/samba/departamentos` y `/samba_comun.img` (2 GB) en `/srv/samba/comun`. Son una **cuota física infranqueable** frente a un llenado accidental o malicioso del disco: un departamento que se descontrola no se lleva por delante a los demás.

**[Fase 7 — Seguridad Avanzada (ACLs y ABE)](Fases/Fase_7_Seguridad_Avanzada_ACL_y_ABE.md):** se aplican ACLs (`setfacl`) con herencia (`-d`) para los **cruces entre departamentos** de la matriz de permisos (contabilidad escribe en facturación, comercial solo la consulta…), y se activa Access Based Enumeration (`access based share enum = yes`, `hide unreadable = yes`) en `smb.conf`, de modo que un becario **ni siquiera ve** las carpetas a las que no tiene acceso.

**[Fase 8 — Integración del Cliente (Windows 11)](Fases/Fase_8_Integracion_del_Cliente_Windows_11.md):** se crea una **segunda VM** en VirtualBox (`Windows11`, 4 GB RAM, 40 GB disco, TPM 2.0 y Secure Boot activados) conectada a la misma Red Solo Anfitrión del laboratorio (`10.10.10.0/24`) con IP fija `10.10.10.20`, se une al dominio `BOOCHANLAB.LOCAL`, se instala RSAT y se mapean las carpetas compartidas como unidades de red — demostrando que el modelo de permisos definido en Linux se respeta desde el cliente Windows.

**[Auditoría Final — Hardening](Fases/Auditoria_Final.md):** cierre de seguridad con el principio Zero Trust aplicado mediante `ufw` **dentro** del propio servidor (política `deny incoming` por defecto, permitiendo solo `10.10.10.0/24`, `10.20.20.0/24` y el puerto WireGuard `51820/udp`), ya que en un laboratorio local no existe un firewall externo tipo Security Group que restringir.

---

## 📊 Datos clave del proyecto

| Concepto | Valor en el Bloque 2 |
| :--- | :--- |
| **Nombre NetBIOS** | `BOOCHANLAB` |
| **Realm (dominio completo)** | `BOOCHANLAB.LOCAL` |
| **FQDN del servidor** | `UbuntuServer.BOOCHANLAB.LOCAL` |
| **Red del servidor / Red Solo Anfitrión** | `10.10.10.0/24` (servidor `10.10.10.10`, host `10.10.10.1`, cliente Windows `10.10.10.20`) |
| **Red del túnel VPN (WireGuard)** | `10.20.20.0/24` (servidor `10.20.20.1`, cliente `10.20.20.2`) |
| **Red host-only de VirtualBox** | `10.10.10.0/24`, host en `10.10.10.1` (creada manualmente en la Fase 1.2, DHCP desactivado). ⚠️ **El nombre depende del anfitrión**: `vboxnetN` en Mac/Linux, `VirtualBox Host-Only Ethernet Adapter` (con `#2`, `#3`…) en Windows. **Identifícala siempre por su IP, nunca por su nombre.** |
| **Usuario administrador Linux** | `boochan` |
| **Grupos de dominio** | `facturacion` · `contabilidad` · `comercial` · `logistica` · `rrhh` · `becarios` (GID 3001-3006) |
| **Usuarios de dominio** | 12 trabajadores, UID 10001-10012. El detalle y la matriz de permisos, en `99_Recursos/Escenario_Boochan_SL.md` |
| **Sistema operativo servidor** | Ubuntu Server 26.04 LTS |
| **Sistema operativo cliente** | Windows 11 (64-bit) |

---

## 📂 Estructura de la carpeta

```
Bloque_2/
├── Manual_Bloque_2.md                     ← este documento (punto de entrada)
├── README.md · LICENSE
├── provision_boochan.sh                   ← script de provisión del dominio (Fase 4)
├── Fases/
│   ├── Fase_N_Nombre.md                   ← índice de cada fase (1-8)
│   ├── Fase_N_Nombre/                     ← sus 12 apartados, uno por fichero
│   │      1 Qué se evalúa · 2 Entregables · 3 Obligaciones de grabación ·
│   │      4 Dónde estamos · 5 Fundamento teórico · 6 Procedimiento ·
│   │      7 Resolución de problemas · 8.a Verificación · 8.b Punto de control ·
│   │      9 Preguntas · 10.a Laboratorio de averías · 10.b Auditoría y cierre
│   ├── Auditoria_Final.md + Auditoria_Final/   ← 8 apartados: hardening con ufw
│   ├── Fase_0.S_Instantaneas_Puntos_de_Control.md   ← cómo se hacen las instantáneas
│   └── Solucionario/                      ← solo el profesor: NO va en tu copia
└── 99_Recursos/
    ├── Escenario_Boochan_SL.md            ← la empresa: departamentos, personas, permisos
    ├── Diccionario_Comandos_Sistema.md
    ├── Guía_Editor_Nano.md
    ├── Comandos_y_Atajos_VirtualBox.md    ← específico de este bloque
    ├── Guía_Errores_y_Resolución.md       ← catálogo de errores por fase
    └── verificar_faseN.sh                 ← los verificadores (fases 1-7) + verificar_fase8.ps1
```

> [!info] 📦 Dos fases parten el apartado 6 porque son largas
> - **Fase 1** → `6.a` a `6.f`. Se entrega en **siete partes** (las seis del 6, más el laboratorio de averías); el detalle está en su apartado 2.
> - **Fase 3** → `6.a`, `6.b` y `6.c`, con un `Fase_3.6_Procedimiento.md` que hace de índice de las tres. **Las tres son un solo vídeo.**
>
> El resto de fases tienen el apartado 6 en un único fichero.

---

## 🧭 Recomendación de uso

1. Lee este manual y la advertencia de requisitos (VirtualBox instalado, RAM, disco, BIOS).
2. Sigue las fases **en orden** — son dependientes entre sí (las Fases 4, 5, 7 y 8 son secuenciales; la Fase 8 requiere las Fases 1-7 completas).
3. Si algo falla, antes de bloquearte consulta **[99_Recursos/Guía_Errores_y_Resolución.md](99_Recursos/Guía_Errores_y_Resolución.md)**, organizada por fase, e incluye los problemas específicos de VirtualBox (BIOS, redes host-only, RAM).
4. Para repasar comandos Linux/Samba, el editor `nano` o los comandos propios de VirtualBox, consulta las guías de `99_Recursos/`.
5. Usa **snapshots de VirtualBox** al terminar cada fase (ver `99_Recursos/Comandos_y_Atajos_VirtualBox.md`) — permiten volver atrás sin repetir toda la práctica si algo se rompe en una fase posterior.

---

> **Nota sobre IPs:** a lo largo del proyecto conviven **tres** rangos, no los confundas: la **Red Solo Anfitrión `10.10.10.0/24`** (el "cable" físico virtual entre servidor, cliente y host, configurado en la Fase 1), la **red del túnel WireGuard `10.20.20.0/24`** (una capa de cifrado adicional dentro de la anterior, Fase 3) y la **red NAT** (dinámica, típicamente `10.0.2.x`, solo para salida a internet de cada VM — nunca se usa para direccionar servicios del dominio).
