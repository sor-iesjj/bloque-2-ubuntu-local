## Fase 8 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Lo último.** Cierra la Fase 8 y te deja listo para la Auditoría Final.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el cliente **encuentra el dominio, autentica con Kerberos y ve exactamente lo que le corresponde**. Las tres cosas.
>
> Y algo más: esta fase audita **todo lo anterior**. Un cliente que funciona del todo es la prueba de que las siete fases previas están bien hechas.

---

## **1 · RED Y LOCALIZACIÓN DEL DOMINIO**

- [ ] Cliente con IP **`10.10.10.20`** y `ping 10.10.10.10` respondiendo.
- [ ] DNS del adaptador host-only apuntando a **`10.10.10.10`**.
- [ ] `nslookup ubuntuserver.boochanlab.local` → **`10.10.10.10`**, y **NO** una `10.0.2.x`.
- [ ] Adaptador NAT activo *(para RSAT e internet)*, **sin** DNS del dominio puesto en él.

## **2 · UNIÓN Y AUTENTICACIÓN**

- [ ] `systeminfo` muestra el dominio **`BOOCHANLAB.LOCAL`**.
- [ ] Inicio de sesión con un usuario del dominio, en formato **`BOOCHANLAB\usuario`**.
- [ ] `klist` muestra tickets de **Kerberos**, incluido `krbtgt`.
- [ ] Desfase horario con el servidor **por debajo de 5 minutos**.

> [!danger] ⚠️ Si `klist` no muestra tickets, estás usando NTLM
> Conéctate al servidor **por nombre**, no por IP. Kerberos necesita el nombre; con la IP, Windows cae al protocolo antiguo — y entonces no estás probando lo que crees.

## **3 · 🔴 LA PRUEBA DE LA FASE 7**

Las **siete pruebas de la matriz**, cada una con el trabajador que le toca:

- [ ] **5.1** `shinnosuke.nohara` ve **solo** `becarios`.
- [ ] **5.2** El becario **lee** pero **no puede escribir** en su carpeta.
- [ ] **5.3** `masao.sato` **abre** una factura.
- [ ] **5.4** `masao.sato` **NO puede borrarla**.
- [ ] **5.5** `misae.nohara` **sí escribe** en facturación.
- [ ] **5.6** `misae.nohara` **NO ve** `rrhh`.
- [ ] **5.7** Un usuario **no puede borrar** en `comun` el fichero de otro.
- [ ] Las **tres salidas de `net view`** pegadas en la entrada de apuntes.

> [!success] 🎯 Esto es lo que quedó pendiente en la Fase 7
> Allí se te pidió anotarlo como pendiente porque **desde el servidor no se podía comprobar**. Si las siete casillas de arriba están marcadas, la Fase 7 queda cerrada de verdad.
>
> Y fíjate en lo que demuestra cada pareja: **5.3 + 5.4** son *ver ≠ modificar*. **5.1 + 5.6** son *no puedes ni saber que existe*. **5.2 y 5.7** son *puedes mirar, no destruir*.
>
> Si la segunda falla, el fallo **está en la Fase 7**, no aquí → [[Fase_8.7_Resolucion_Problemas#E6 · shinnosuke.nohara ve la carpeta que no debería ver|caso E6]].

## **4 · ACCESO A LOS RECURSOS**

- [ ] Unidad de red mapeada **con `/persistent:yes`**, y comprobado que sobrevive al reinicio.
- [ ] La unidad muestra la **capacidad de la cuota**, no la del disco del servidor *(Fase 6)*.
- [ ] Fichero creado desde Windows y **comprobado en el servidor** con el `uid` correcto *(Fase 5)*.
- [ ] Fichero de prueba borrado.

## **5 · RSAT**

- [ ] RSAT instalado y **"Usuarios y equipos de Active Directory"** abre.
- [ ] Comprobado que se ven los usuarios y grupos creados en la Fase 5.

## **6 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **seis averías** provocadas y reparadas, **en dos sesiones**.
- [ ] **Predicción escrita antes** de cada una, **con la máquina donde creías que estaba el problema**.
- [ ] Verificadores pasados al final **en las dos máquinas**.

## **7 · LAS COPIAS** *(esta fase son DOS máquinas)*

- [ ] 💾 Instantánea **`Fase 8 terminada`** del **cliente Windows**, con la VM apagada.
- [ ] 💾 Instantánea **`Fase 8 terminada`** del **servidor**, con la VM apagada.
- [ ] Anotado que **las dos van en pareja**: restaurar una sola rompe la relación de confianza.
- [ ] 💿 **`B2-F8-servidor.ova`** y **`B2-F8-cliente-windows.ova`** en el disco externo.

## **8 · LA ENTREGA**

- [ ] **La entrada** de apuntes (`b2-8-integracion-del-cliente.md`), con sus **tres enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_8.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 8
> Que **un dominio no se demuestra desde el servidor: se demuestra desde el cliente.** Todo lo que llevabas construido era una promesa; hoy la has comprobado.
>
> Que **el mensaje de error te dice la consecuencia, no la causa.** *"No se encuentra el dominio"* puede ser la red, el DNS del cliente o un fallo de la Fase 4 de hace tres semanas. *"La contraseña es incorrecta"* casi siempre es **el reloj**. Ninguno de los dos mensajes menciona su causa, y esa distancia entre síntoma y causa es exactamente el trabajo de un administrador.
>
> Que **la autenticación moderna depende del tiempo.** Kerberos rechaza más de 5 minutos de desfase porque sus tickets caducan, y sin relojes de acuerdo no hay caducidad que valga. De ahí viene toda la insistencia del proyecto en apagar las VMs antes de guardar.
>
> Que **denegar el acceso y ocultar la existencia son dos capas distintas**, y que la segunda solo se ve desde aquí. Lo has comprobado viendo desaparecer una carpeta de la pantalla al cambiar de grupo, sin tocar ni un permiso.
>
> Que **un equipo también tiene identidad en el dominio**, con su cuenta y su relación de confianza — y que romperla es tan fácil como restaurar una instantánea desincronizada.
>
> Y la más importante de las ocho fases: **el fallo aparece donde se ve, no donde está.** Te van a llamar desde el cliente y el problema estará en el servidor; te van a decir "no hay internet" y no habrá DNS; te van a decir "la contraseña falla" y será la hora. **Traducir eso es el oficio.**
>
> **Siguiente:** [[Auditoria_Final]] — cerrar el laboratorio como se cierra un proyecto de verdad.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.10.a_Laboratorio_de_Averias]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Auditoria_Final]] |
