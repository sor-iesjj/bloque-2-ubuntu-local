## Fase 4 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. El "Cerebro" de la Red: Active Directory (AD)
> Estamos creando el **Active Directory**. Este es el "Cerebro" que gestiona la base de datos de todos los objetos de la red: usuarios, grupos y ordenadores. Samba AD DC emula tres servicios vitales para que esto funcione:
> *   **LDAP:** El protocolo para consultar la base de datos de usuarios.
> *   **Kerberos:** El sistema de "tickets" de seguridad (como un pase VIP de un festival).
> *   **DNS Interno:** Samba gestiona sus propios registros SRV que indican dónde están los servicios de red.

> [!important] 2. Inmutabilidad y Persistencia (aquí también hace falta, aunque no haya "nube" de por medio)
> Podrías pensar que el problema de `resolv.conf` sobrescrito es exclusivo de la nube (Azure/AWS inyectando su propio DNS). **No es así.** Ubuntu Server 26.04 gestiona el DNS mediante `systemd-resolved` de forma nativa, tanto si la VM corre en AWS como si corre en tu VirtualBox local. Cada vez que la interfaz de red se reconfigura (por ejemplo, en cada arranque, al renovar la IP del adaptador NAT), `systemd-resolved` puede reescribir `/etc/resolv.conf` y borrar nuestra configuración manual. El comando `chattr +i` lo hace **inmutable** (imposible de borrar o cambiar ni por el propio root), garantizando que el servidor siempre se consulte a sí mismo (`127.0.0.1`) para resolver nombres del dominio.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Dominio
> - **Reino (Realm):** El nombre de dominio completo (ej. `BOOCHANLAB.LOCAL`). Siempre se escribe en **MAYÚSCULAS** para que Kerberos lo entienda.
> - **NetBIOS Domain:** El nombre corto del dominio (ej. `BOOCHANLAB`), usado por protocolos Windows heredados y como prefijo de inicio de sesión (`BOOCHANLAB\usuario`).
> - **Provisionamiento:** El acto de generar la base de datos del dominio desde cero.
> - **SRV Record:** Un registro DNS especial que indica qué servidor ofrece un servicio específico (ej. "el servidor de tickets está en esta IP").
> - **chattr +i:** El "cemento armado" de Linux. Hace que un archivo no se pueda modificar ni por el administrador.

---

### 🔓 Firewall Local: por qué esta fase no tiene sección de puertos cloud

> [!info] En BoochanV2/V3 aquí había 13 reglas que abrir en Azure/AWS — en local, cero
> Active Directory es un ecosistema de servicios que se hablan entre sí: Kerberos (88), DNS (53), LDAP (389/636), RPC (135 y el rango dinámico 49152-65535), SMB (445), cambio de contraseñas (464) y NTP (123). En las versiones cloud del proyecto, cada uno de esos puertos debía abrirse manualmente en el Security Group/NSG del proveedor, porque el tráfico entrante estaba bloqueado por defecto.
>
> **En tu Red Solo Anfitrión de VirtualBox no hay ningún firewall perimetral que bloquee ese tráfico entre VMs.** Todo el ecosistema de puertos de Active Directory funcionará entre el servidor (`10.10.10.10`) y la futura VM cliente Windows 11 sin que tengas que configurar nada adicional — el propio hecho de compartir el mismo segmento de Red Solo Anfitrión ya permite esa comunicación.
>
> > [!tip] 💡 ¿Merece la pena entender esos 13 puertos igualmente?
> > Sí, y mucho. Aunque aquí no los "abras" en ningún portal, siguen siendo los mismos puertos que un Controlador de Dominio real usa en producción. Cuando en el futuro despliegues un dominio en una red corporativa con firewall perimetral, necesitarás saber exactamente qué puertos pedir que se abran. Consulta la tabla de referencia de BoochanV3 (`SOR/BoochanV3/Fases/Fase_4.md`) si quieres repasar el propósito de cada uno — Kerberos (88), DNS (53), RPC (135), LDAP (389/636), SMB (445), RPC dinámico (49152-65535), cambio de contraseñas (464) y NTP (123).

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.4_Donde_Estamos]] | [[Fase_4]] | [[Fase_4.6_Procedimiento]] |
