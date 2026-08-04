## Fase 2 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 3 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el servidor **resuelve su propio FQDN**. Si el `/etc/hosts` no coincide exactamente con el dominio que instalarás en la Fase 4, Kerberos jamás emitirá tickets y el proyecto fallará — **sin dar un error que apunte a esta fase**.

> [!success] ✅ Checklist final: no sigas a la Fase 3 sin esto
> - [ ] `sudo apt upgrade -y` ejecutado y `sudo dpkg --audit` **sin salida**.
- [ ] Reiniciado si `/var/run/reboot-required` existía.
- [ ] **Comprobado lo que hay instalado**, no lo que se pidió: `dpkg -s samba-ad-dc samba-ad-provision`.
- [ ] ¿Comprobaste en el **Paso 1B**, **antes** de reinstalar, que la purga había dejado el sistema limpio?
> - [ ] ¿`hostname -f` devuelve exactamente `UbuntuServer.BOOCHANLAB.LOCAL`?
> - [ ] ¿`hostname -I` muestra la IP estática `10.10.10.10`?
> - [ ] ¿`dpkg -s samba-ad-dc samba-ad-provision` confirma que **los dos** están instalados?
> - [ ] 💾 ¿Tomaste la instantánea **`Fase 2 terminada`**?
> - [ ] ¿Tu entrada de apuntes tiene las **6 preguntas contestadas** y el **enlace del vídeo**?
> - [ ] ¿Hiciste `commit` y `push` de la entrada?

> [!warning] ⚠️ Al terminar esta fase, `smbd` ESTÁ corriendo. Y es lo correcto.
> Si ahora ejecutas `systemctl status smbd` verás `active (running)`. **No es un fallo y no hay que arreglarlo.**
>
> Esta fase hace dos cosas seguidas que parecen contradictorias:
> 1. El **Paso 1A purga** el Samba que Ubuntu trae de fábrica, **con su configuración**.
> 2. El **Paso 2 instala** el Samba que vamos a usar de verdad, limpio y acompañado de Kerberos y winbind.
>
> Demoler y volver a construir. Lo que sobraba no era el programa: era **la configuración vieja** que se habría mezclado con la del dominio.
>
> Por eso la comprobación de que la purga funcionó va **en medio** (Paso 1B) y no al final: al final ya no se puede comprobar, porque el Paso 2 lo ha vuelto a instalar.
>
> **¿Y los puertos 139 y 445?** Los ocupa ahora el Samba nuevo. La **Fase 4** los libera ella misma antes de levantar el controlador de dominio. Ya está previsto — no tienes que hacer nada.

> [!success] 🎯 Criterio de éxito
> Abro tu repositorio, encuentro la entrada de esta fase, y dentro está: qué has hecho, qué has entendido, qué dudas te han quedado y el enlace al vídeo donde se te ve haciéndolo. Si falta el enlace o faltan las respuestas, la fase **no cuenta como entregada**.

> [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> **Una fase, una entrada.** No creas un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**, para no perder nunca más de un día de trabajo.

> [!summary] 🎓 Qué has aprendido
> Que `remove` y `purge` no son lo mismo, y que la diferencia son los ficheros de configuración — los que se quedan escondidos y rompen cosas tres fases después. Que un servidor necesita saber su propio nombre completo antes de poder demostrar quién es. Y que **una comprobación hay que hacerla cuando aún se puede**: la del Paso 1B, después del Paso 2, ya no vale para nada.
>
> **Siguiente:** Fase 3 — Conectividad VPN (WireGuard).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.9_Preguntas]] | [[Fase_2]] | **Fase 3** |
