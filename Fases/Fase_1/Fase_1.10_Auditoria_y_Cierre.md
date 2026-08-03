## Fase 1 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 2 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el servidor **existe, arranca y es alcanzable**. Si la red sólo-anfitrión no funciona o la IP no es `10.10.10.10`, todo lo que construyas encima —el dominio de la Fase 4, el cliente de la Fase 8— fallará sin dar un error que apunte aquí.

> [!success] ✅ Checklist final: no sigas a la Fase 2 sin esto
> **La máquina**
> - [ ] VirtualBox instalado y VM `UbuntuServer` creada: 2048 MB, 2 vCPU, 20 GB sin preasignar.
> - [ ] Casilla **`Omitir instalación desatendida`** marcada al crearla.
>
> **La red**
> - [ ] Red sólo-anfitrión con IP `10.10.10.1` y máscara **`255.255.255.0`**, sin DHCP.
> - [ ] Adaptador 1 en **NAT** · Adaptador 2 en **sólo-anfitrión**, con `Cable conectado` marcado.
>
> **El sistema**
> - [ ] Teclado **español**, comprobado escribiendo una `@`.
> - [ ] Usuario `boochan` · hostname `UbuntuServer` · **OpenSSH instalado**.
> - [ ] `ip a` muestra `lo`, `enp0s3` y `enp0s8` con **`10.10.10.10`**.
>
> **La conectividad**
> - [ ] `ping google.com` responde desde la VM.
> - [ ] `ping 10.10.10.10` responde **desde el ordenador anfitrión**.
> - [ ] Entras por **SSH** desde la terminal del anfitrión.
>
> **La entrega**
> - [ ] 💾 Instantáneas **`Sistema base`** y **`Fase 1 terminada`** tomadas.
> - [ ] Las **cuatro entradas** de apuntes creadas, con sus **cuatro enlaces de vídeo**.
> - [ ] Preguntas críticas contestadas.
> - [ ] `commit` y `push` hechos.

> [!summary] 🎓 Qué has aprendido en la Fase 1
> Que un hipervisor de Tipo 2 reparte **tu** hardware, y que dimensionar es decidir, no maximizar.
>
> Que NAT y sólo-anfitrión resuelven problemas distintos, y que **los nombres mienten y las direcciones no** — la regla que te sacará de más de un atasco.
>
> Que un instalador no es un formulario: es una cadena de decisiones que condiciona meses de trabajo. Y que **un teclado no envía letras, envía números de tecla**.
>
> Y que verificar desde dentro vale menos que verificar desde fuera. Un servidor te dirá siempre lo que él cree de sí mismo.
>
> **Siguiente:** Fase 2 — Purga y Preparación del Entorno.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.9_Preguntas]] | [[Fase_1]] | **Fase 2** |
