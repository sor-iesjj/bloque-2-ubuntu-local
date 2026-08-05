## Fase 4 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 3
> Tienes un servidor con identidad de dominio (`UbuntuServer.BOOCHANLAB.LOCAL`), accesible de forma cifrada a través de un túnel WireGuard (`10.20.20.1`). Ahora necesitas darle la funcionalidad de un verdadero **Controlador de Dominio** — el "cerebro" que gestiona usuarios, grupos, autenticación y autorización.

> [!warning] El Problema
> Sin un dominio, Windows 11 en tu laboratorio es un equipo aislado. Los usuarios se loguean localmente (usuario/contraseña guardados en el PC). No hay forma centralizada de gestionar identidades, no hay Single Sign-On, no hay políticas de grupo. Si necesitas cambiar la contraseña de un usuario, debes hacerlo en cada PC manualmente. Además, Kerberos (el protocolo de seguridad profesional) requiere un dominio para funcionar.

> [!success] Objetivo de esta Fase
> Provisionar **Samba AD DC** (Active Directory Domain Controller) en el servidor. Esto creará el dominio **`BOOCHANLAB`** (NetBIOS) / **`BOOCHANLAB.LOCAL`** (Realm) como un "reino" Kerberos con servicios interdependientes: LDAP (directorio), DNS interno (registros SRV), Kerberos (autenticación), y replicación. Desde ahora, los usuarios se autenticarán contra el dominio, no contra máquinas individuales.

> [!tip] Hoja de Ruta
> 1. Comprobar que no hace falta abrir ningún puerto en un firewall cloud (aquí no existe)
> 2. Ejecutar el script `provision_boochan.sh` adaptado a `BOOCHANLAB.LOCAL`, que automatiza la creación del dominio (tarda 2-3 minutos)
> 3. Verificar que el servicio `samba-ad-dc` está activo: `sudo systemctl status samba-ad-dc`
> 4. Comprobar que el DNS interno apunta a `127.0.0.1`: `cat /etc/resolv.conf`
> 5. Hacer inmutable `/etc/resolv.conf` con `chattr +i` para que `systemd-resolved` no lo rompa en reinicios
> 6. Validar que Kerberos funciona: `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL 127.0.0.1`
> 7. Listar usuarios creados automáticamente: `samba-tool user list` (verás Administrator, krbtgt, etc.)
>
> **Resultado Final:** Dominio `BOOCHANLAB.LOCAL` completamente provisionado y operativo. El servidor es ahora un verdadero Controlador de Dominio profesional, listo para que la futura VM Windows 11 se una a él.
> **Siguiente:** Fase 5 (Gestión de Identidades) — darás de alta a los **doce trabajadores de Boochan S.L.** en seis departamentos, con sus UID y GID mapeados a Linux. El escenario completo está en [[Escenario_Boochan_SL]].

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.3_Obligaciones_Grabacion]] | [[Fase_4]] | [[Fase_4.5_Fundamento_Teorico]] |
