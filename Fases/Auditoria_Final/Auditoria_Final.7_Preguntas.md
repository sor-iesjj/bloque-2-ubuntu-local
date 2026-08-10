## Auditoría Final · Apartado 7 — ❓ Preguntas críticas de cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Auditoría Final y Hardening**
> 🧭 Índice: [[Auditoria_Final]]
>
> **📍 Cuándo se lee:** Después de la instantánea

---

1. ¿Por qué en este proyecto el hardening final se hace con `ufw` dentro del servidor, y no con un firewall externo como en el Bloque 4 (la nube)?
2. ¿Qué diferencia de seguridad hay entre dejar el puerto `51820/udp` abierto "a cualquiera" y dejar el puerto `445` (SMB) abierto "a cualquiera"? ¿Por qué el primero es aceptable y el segundo no?
3. Si después de activar `ufw` ya no puedes conectar por SSH al servidor, ¿qué es lo primero que deberías comprobar sobre tu propia conexión?
4. ¿Qué significa que un servidor esté "bastionado" (*Hardened*)?
5. ¿Qué proceso es el dueño del puerto 445 según el comando `ss -tunlp`?
6. Si en algún momento configuraste un reenvío de puertos (*Port Forwarding*) en el adaptador NAT del servidor para administrarlo desde el host, ¿por qué debe revisarse esa regla en una auditoría final, aunque `ufw` ya esté activo dentro de la VM?

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Auditoria_Final.6_Punto_de_Control]] | [[Auditoria_Final]] | [[Auditoria_Final.8_Cierre]] |
