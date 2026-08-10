## Fase 2 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2_Purga_y_Preparacion_del_Entorno]]
>
> **📍 Cuándo se lee:** **Lo último de la fase.** No pases a la Fase 3 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el servidor **tiene identidad propia y las herramientas del dominio**. Todo lo de la Fase 4 se construye sobre eso: si el nombre está mal o falta un paquete, el dominio se levanta mal **y el error aparece allí, no aquí**.

> [!success] ✅ Checklist final: no pases a la Fase 3 sin esto
> **La identidad**
> - [ ] `hostname -f` devuelve `UbuntuServer.BOOCHANLAB.LOCAL`.
> - [ ] `/etc/hosts` tiene `127.0.0.1 localhost` y la línea del dominio.
> - [ ] **NO** hay ninguna línea `127.0.1.1`.
> - [ ] El orden de columnas es `IP · FQDN · nombre corto`.
>
> **Los paquetes**
> - [ ] `samba-ad-dc` y `samba-ad-provision` instalados — **sin ellos la Fase 4 es imposible**.
> - [ ] `default_realm = BOOCHANLAB.LOCAL`, en **MAYÚSCULAS**.
>
> **El sistema**
> - [ ] `sudo dpkg --audit` sin salida.
> - [ ] `apt upgrade` ejecutado y reiniciado si lo pedía.
>
> **La base de la Fase 1**
> - [ ] `10.10.10.10` sigue presente · SSH activo.
>
> **El laboratorio**
> - [ ] Las **cinco averías** hechas, con su predicción escrita antes.
> - [ ] *(Opcional)* Alguna de las **tres críticas**, con la recuperación documentada.
> - [ ] Verificador en verde al terminar.
>
> **La entrega**
> - [ ] Informe `verificacion-fase-2.txt` subido al repositorio.
> - [ ] 💾 Instantánea **`Fase 2 terminada`** tomada.
> - [ ] 💿 **`B2-F2-purga-y-preparacion.ova`** en tu disco externo.
> - [ ] Entrada de apuntes con **los cuatro enlaces de vídeo** · preguntas contestadas · `commit` y `push`.

> [!warning] ⚠️ Que `smbd` esté activo al terminar es CORRECTO
> Lo purgaste en el Paso 1A y el Paso 2 **lo reinstaló a propósito**. Verlo activo y volver a purgarlo es el error de diagnóstico más caro de esta fase → [[Fase_2.7_Resolucion_Problemas#E10 · Al terminar la fase smbd sigue activo|caso E10]].

> [!summary] 🎓 Qué has aprendido en la Fase 2
> Que **`purge` y `remove` no son lo mismo**: uno se lleva la configuración y el otro la deja esperando para estorbar.
>
> Que **un comodín no es una lista**, y que en un borrado se escribe lo que se va a borrar.
>
> Que la identidad de un servidor vive en **dos ficheros**, y que el orden de las columnas de uno de ellos **es sintaxis**.
>
> Y que *"no dio error"* no es lo mismo que *"funcionó"*: `apt` puede seguir adelante dejándose un paquete por el camino.
>
> **Siguiente:** Fase 3 — Conectividad VPN (WireGuard).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.10.a_Laboratorio_de_Averias]] | [[Fase_2_Purga_y_Preparacion_del_Entorno]] | **Fase 3** |
