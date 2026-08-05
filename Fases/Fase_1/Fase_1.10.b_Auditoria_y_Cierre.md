## Fase 1 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 1: Infraestructura Virtual Local (VirtualBox)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 2 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el servidor **existe, arranca y es alcanzable**. Si la red sólo-anfitrión no funciona o la IP no es `10.10.10.10`, todo lo que construyas encima —el dominio de la Fase 4, el cliente de la Fase 8— fallará **sin dar un error que apunte aquí**.
>
> Esta es la fase que menos se nota cuando está bien y más duele cuando está mal.

---

## **1 · LA MÁQUINA**

- [ ] VirtualBox instalado y VM `UbuntuServer` creada: **2048 MB, 2 vCPU, 20 GB sin preasignar**.
- [ ] Casilla **`Omitir instalación desatendida`** marcada al crearla.

## **2 · LA RED**

- [ ] Red sólo-anfitrión con IP `10.10.10.1` y máscara **`255.255.255.0`**.
- [ ] **Servidor DHCP desactivado** en esa red.
- [ ] Adaptador 1 en **NAT** · Adaptador 2 en **sólo-anfitrión**, con `Cable conectado` marcado.

## **3 · EL SISTEMA**

- [ ] Teclado **español**, comprobado escribiendo una `@` **en la ventana de VirtualBox**.
- [ ] Usuario `boochan`, en el grupo `sudo` · hostname `UbuntuServer` · **OpenSSH instalado**.
- [ ] `ip -brief addr show enp0s8` → `UP` con **`10.10.10.10/24`**.
- [ ] La IP está en `/etc/netplan/00-installer-config.yaml`, no puesta a mano.
- [ ] `sudo netplan get` **sin** `Command failed:`.

## **4 · LA CONECTIVIDAD**

- [ ] `ping 8.8.8.8` y `getent hosts archive.ubuntu.com` responden desde la VM.
- [ ] `ping 10.10.10.10` responde **desde tu Windows**.
- [ ] `ssh boochan@10.10.10.10` entra **desde tu Windows**.

## **5 · EL CLON** *(entrega 6)*

- [ ] Clon completo creado desde `Fase 1 terminada`, **con las claves de host limpiadas antes**.
- [ ] Intercambiado con un compañero, importado y **arrancado a la vez que el tuyo** *(`CE.06.g` — trabajo en grupo: sin pareja, este criterio no se puede evaluar)*.
- [ ] Clon renombrado y con IP `10.10.10.11`: las dos máquinas conviven.
- [ ] 🧹 **Clon apagado.** No pases a la Fase 2 con dos servidores encendidos.

## **6 · EL LABORATORIO DE AVERÍAS** *(entrega 7)*

- [ ] Las **seis averías** provocadas y reparadas, en la ventana de VirtualBox, **en dos sesiones** (1-4 de red, 5-6 de SSH).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Verificador pasado al final: **`FASE 1 SUPERADA`**.

## **7 · LAS COPIAS**

- [ ] 💾 Instantáneas **`Sistema base`** y **`Fase 1 terminada`** tomadas y comprobadas con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F1-infraestructura-virtual.ova`** en `SOR/Bloque_2/Fases/Fase_1/` de tu **disco externo**.

## **8 · LA ENTREGA**

- [ ] Las **siete entradas** de apuntes creadas, con sus **siete enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_1.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 1
> Que un hipervisor de Tipo 2 reparte **tu** hardware, y que dimensionar es decidir, no maximizar.
>
> Que NAT y sólo-anfitrión resuelven problemas distintos, y que **los nombres mienten y las direcciones no** — la regla que te sacará de más de un atasco.
>
> Que un instalador no es un formulario: es una cadena de decisiones que condiciona meses de trabajo. Y que **un teclado no envía letras, envía números de tecla**.
>
> Que verificar desde dentro vale menos que verificar desde fuera. Un servidor te dirá siempre lo que **él cree** de sí mismo, y por eso esta fase se comprueba desde los dos lados.
>
> Que **clonar no es copiar**: la identidad de una máquina —su clave de host, su `machine-id`, su MAC— es justo lo que no debe viajar en una plantilla. Lo has visto chocando dos servidores idénticos, que es la única forma de que no se olvide.
>
> Y por encima de todo, rompiendo cosas a propósito: que **"no me responde" no significa "está caído"**, que **un comando que termina bien no ha hecho necesariamente lo que querías**, y que **el fallo que avisa no es el peligroso** — el peligroso es el que se aplica en silencio y aparece tres semanas después.
>
> **Siguiente:** Fase 2 — Purga y Preparación del Entorno.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.10.a_Laboratorio_de_Averias]] | [[Fase_1]] | **Fase 2** |
