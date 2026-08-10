## Fase 3 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3_Conectividad_VPN_WireGuard]]
>
> **📍 Cuándo se lee:** **Lo último de la fase.** No pases a la Fase 4 sin repasarlo.

---


> [!caution] 🛑 Qué se audita en esta fase
> Que el túnel **existe, funciona y sobrevive a un reinicio**. Y que la clave privada del servidor está protegida: quien la copie podrá suplantarlo en la red.

> [!success] ✅ Checklist final: no pases a la Fase 4 sin esto
> **El túnel**
> - [ ] `sudo wg show` → handshake reciente y tráfico en los dos sentidos.
> - [ ] `sudo ss -ulnp` → el `51820` ocupado.
> - [ ] `ping 10.20.20.1` responde **desde Windows**.
> - [ ] El `Address` del cliente es **`/32`**, no `/24` ni `/25`.
>
> **La persistencia**
> - [ ] `systemctl is-enabled wg-quick@wg0` → `enabled`.
> - [ ] Comprobado **reiniciando de verdad**, no solo leyendo el comando.
>
> **La seguridad**
> - [ ] `/etc/wireguard/wg0.conf` con permisos **`600`**.
>
> **La base**
> - [ ] `10.10.10.10` presente · `hostname -f` correcto.
>
> **El laboratorio**
> - [ ] Las **seis averías** hechas, con su predicción escrita antes.
> - [ ] Verificador en verde al terminar.
>
> **La entrega**
> - [ ] Informe `verificacion-fase-3.txt` subido al repositorio.
> - [ ] 💾 Instantánea **`Fase 3 terminada`** tomada.
> - [ ] Entrada de apuntes con enlace al vídeo · preguntas contestadas · `commit` y `push`.

> [!important] 🔓 SSH sigue como estaba. No lo toques todavía
> Sigues entrando con `ssh boochan@10.10.10.10`.
>
> Restringir el acceso al túnel se hace en la **[[Auditoria_Final]]**, cuando ya sepas que el túnel es fiable — y la avería 2 te acaba de enseñar por qué esperar.
>
> Anótalo en tu entrada como **puerta pendiente de cerrar**. Un administrador lleva la cuenta de las que deja abiertas.

> [!summary] 🎓 Qué has aprendido en la Fase 3
> Que una VPN es **una red construida encima de otra**: si la de abajo falla, la de arriba no puede funcionar.
>
> Que **"activo" no significa "funcionando"** — el handshake es el único dato que no miente.
>
> Que un sistema que **ignora en silencio** a quien no reconoce está haciendo bien su trabajo, aunque te complique el diagnóstico.
>
> Que hay **errores que no dan error**, y por eso existen las auditorías.
>
> Y que un servicio que funciona hoy pero **no arranca solo** es una avería aplazada.
>
> **Siguiente:** Fase 4 — Despliegue del Dominio.
---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.10.a_Laboratorio_de_Averias]] | [[Fase_3_Conectividad_VPN_WireGuard]] | **Fase 4** |
