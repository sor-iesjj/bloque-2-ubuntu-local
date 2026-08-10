## Auditoría Final · Apartado 4 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Auditoría Final y Hardening**
> 🧭 Índice: [[Auditoria_Final]]
>
> **📍 Cuándo se lee:** Antes de teclear — Zero Trust

---

Para terminar el proyecto, debemos aplicar la filosofía **Zero Trust** (Confianza Cero). Hasta ahora, hemos priorizado que todo funcione: hemos dejado el servidor accesible desde cualquier interfaz de red para facilitar la configuración inicial. Un administrador profesional, una vez terminado el trabajo, debe "cerrar el castillo" y solo permitir el paso a quien esté dentro de la muralla — en este proyecto, eso significa la Red Solo Anfitrión del laboratorio (`10.10.10.0/24`) y el túnel VPN de administración (`10.20.20.0/24`).

> [!info] Diferencia con el Bloque 4 (la nube)
> En los proyectos en la nube (Azure/AWS), este hardening se hacía **fuera** del servidor, restringiendo el Grupo de Seguridad (NSG/Security Group) del proveedor cloud. Aquí no existe ese firewall externo: **VirtualBox no filtra el tráfico entre el host y las VMs de una misma Red Solo Anfitrión**, así que el filtrado tiene que hacerse **dentro** del propio Ubuntu Server, con su firewall local: **`ufw`** (*Uncomplicated Firewall*).

### 📖 Diccionario de Conceptos Clave

- **Hardening:** El proceso de "endurecer" un servidor eliminando servicios innecesarios y cerrando puertos.
- **Whitelist (Lista Blanca):** Configuración que bloquea todo por defecto y solo permite el paso a IPs u orígenes específicos.
- **Zero Trust:** Estrategia de seguridad que asume que la red ya está comprometida y exige verificación constante.
- **ufw (Uncomplicated Firewall):** Interfaz simplificada sobre `iptables`/`nftables` para gestionar el firewall de un servidor Linux con reglas legibles.
- **Adaptador NAT (VirtualBox):** Adaptador de red del servidor que le da salida a Internet (para actualizaciones, `apt`, etc.). Es también, potencialmente, la puerta que quedó abierta durante el desarrollo del proyecto si en algún momento reenviaste puertos desde el host hacia la VM (*Port Forwarding*).

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Auditoria_Final.3_Obligaciones_Grabacion]] | [[Auditoria_Final]] | [[Auditoria_Final.5_Procedimiento]] |
