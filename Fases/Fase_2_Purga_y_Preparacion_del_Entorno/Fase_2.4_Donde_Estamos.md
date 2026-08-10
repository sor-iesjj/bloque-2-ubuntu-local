## Fase 2 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2_Purga_y_Preparacion_del_Entorno]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 1
> Creaste una máquina virtual con Ubuntu Server 26.04 LTS en VirtualBox, con dos adaptadores de red: uno de **Red Solo Anfitrión** con la IP estática `10.10.10.10/24` (para hablar con la futura VM cliente Windows 11 y con tu propio ordenador) y otro **NAT** (para salir a internet y actualizar paquetes). La VM está encendida y accesible. Pero viene "de fábrica" con software innecesario: servicios antiguos, demonios durmiendo, paquetes que consumirán RAM y podrían ser puertas de seguridad.

> [!warning] El Problema
> Ubuntu instala de serie Samba básico (para "compartir archivos entre amigos"). Este Samba primitivo ocupa el puerto 445, que tu futuro **Controlador de Dominio profesional** (Fase 4) necesitará. Además, servicios como CUPS (impresoras) o IMAP (correo) están dormidos pero activos, consumiendo recursos. El servidor tampoco sabe su identidad: `/etc/hosts` dice "localhost" sin un verdadero nombre de dominio.

> [!success] Objetivo de esta Fase
> **Purga:** Eliminar completamente Samba viejo, impresoras, CUPS, servicios heredados. **Identidad:** Configurar `/etc/hosts` para que el servidor sepa que se llama `UbuntuServer.BOOCHANLAB.LOCAL`. Esto es imprescindible porque Kerberos (Fase 4) valida identidades por nombre de dominio completo (FQDN).

> [!tip] Hoja de Ruta
> 1. Ejecutar `apt update && apt upgrade -y` (actualizar repositorio y parches de seguridad, usando el adaptador NAT)
> 2. Usar `apt purge` (no solo `remove`) para borrar Samba viejo, CUPS, servicios heredados
> 3. Ejecutar `apt autoremove` para limpiar dependencias huérfanas
> 4. Editar `/etc/hosts` e insertar: `10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer`
> 5. Verificar con `hostname -f` que devuelve exactamente `UbuntuServer.BOOCHANLAB.LOCAL`
> 6. Validar resolución: `ping UbuntuServer` y `ping UbuntuServer.BOOCHANLAB.LOCAL` responden
>
> **Resultado Final:** Servidor limpio, sin ruido de servicios heredados, con identidad de dominio establecida.
> **Siguiente:** Fase 3 (Conectividad VPN) — instalarás WireGuard para cifrar la comunicación con la futura VM cliente Windows 11.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.3_Obligaciones_Grabacion]] | [[Fase_2_Purga_y_Preparacion_del_Entorno]] | [[Fase_2.5_Fundamento_Teorico]] |
