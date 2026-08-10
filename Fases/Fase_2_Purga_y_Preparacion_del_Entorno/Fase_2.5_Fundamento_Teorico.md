## Fase 2 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2_Purga_y_Preparacion_del_Entorno]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas entender.

---

> [!abstract] 1. Idempotencia: "La Pizarra Limpia"
> En la U.T. 5 aprendemos que un servidor profesional debe ser **idempotente** (puedes repetir el proceso y el resultado siempre será el mismo) y **predecible**. No podemos construir un rascacielos sobre los cimientos de una cabaña vieja.

> [!warning] 2. El Conflicto de Puertos (SMB 445)
> Muchas distribuciones Linux incluyen de serie servicios de archivos (Samba) para uso doméstico. Esto genera un conflicto:
> *   **El "Teléfono" de Red:** El puerto 445 (SMB) es el canal por el que Windows pide archivos.
> *   **El Conflicto:** Si un Samba básico ya está "escuchando" ese teléfono, nuestro potente Controlador de Dominio no podrá recibir llamadas y el sistema colapsará. La purga elimina el software viejo y sus configuraciones para liberar el puerto.

> [!tip] 3. Kerberos (krb5): El Taquillero del Cine
> Es el protocolo de autenticación que usa Windows. Imagínalo como un cine:
> *   **El KDC (Taquilla):** No vas directo a la sala. Primero vas a la taquilla, demuestras quién eres y compras un **Ticket (TGT)**.
> *   **El Ticket:** Se lo enseñas al acomodador (servidor de archivos). Él no necesita saber tu contraseña; solo necesita ver que tu ticket es oficial. Esto permite el **Single Sign-On (SSO)**: entrar una vez y acceder a todo.

> [!info] 4. Winbind: El Traductor de la ONU
> Linux y Windows hablan idiomas diferentes para identificar usuarios:
> *   **Windows:** Usa códigos largos (SIDs).
> *   **Linux:** Usa números cortos (UIDs).
> *   **La función:** Winbind actúa como traductor. Cuando llega un usuario de Windows, le dice a Linux: *"Este código raro equivale a nuestro número 10001"*. Sin este puente, Linux ignoraría a los usuarios de Windows.

> [!note] 5. ACLs y Atributos: Cirugía de Permisos
> En Linux básico usamos `rwx`, pero en una empresa eso se queda corto.
> *   **ACL (Access Control Lists):** Permiten permisos específicos: *"Juan lee, María escribe y Pedro borra"*, aunque no estén en el mismo grupo.
> *   **Atributos (attr):** Permiten guardar info extra que Samba necesita para "engañar" a Windows y que crea que el disco es NTFS (el formato de Windows).

> [!important] 6. El FQDN: Nombre y "Apellido" Digital
> Configurar el `/etc/hosts` es vital. Un servidor necesita un **FQDN (Fully Qualified Domain Name)** completo.
> *   **Nombre:** `UbuntuServer` | **Apellido:** `BOOCHANLAB.LOCAL` | **FQDN:** `UbuntuServer.BOOCHANLAB.LOCAL`
> Si Kerberos intenta dar un ticket para el nombre sin el "apellido", el sistema lo rechazará por falta de confianza.

> [!info] 7. `.LOCAL`: un dominio que no existe en internet (y así debe ser)
> A diferencia de `BOOCHAN.SPACE` (usado en las versiones cloud del proyecto, que sí es un dominio real registrado en internet), `BOOCHANLAB.LOCAL` es un **dominio privado**, inventado para este laboratorio, que **no es resoluble fuera de tu red virtual**. Esto es intencionado: un Active Directory de laboratorio no necesita —ni debe— ser accesible desde internet. El sufijo `.LOCAL` es una convención muy usada en redes internas de empresa para dejar claro que ese nombre solo tiene sentido dentro de las cuatro paredes de la organización (o, en tu caso, dentro de VirtualBox).

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología Profesional
> - **Demonio (Daemon):** Un programa que vive y trabaja en segundo plano sin que tú lo veas (ej. `smbd`).
> - **FQDN:** El nombre completo y único de tu servidor en la red.
> - **Apt Purge:** Comando "agresivo" que borra el software Y todos sus archivos de configuración.
> - **Winbind:** El servicio que hace de puente entre identidades Linux y Windows.
> - **Red Solo Anfitrión / Host-Only (VirtualBox):** Un adaptador de red virtual que crea una red privada entre el host (tu propio ordenador) y las VMs que la comparten — no tiene salida a internet, pero sí es visible desde el host. Es el "cable de red" que unirá tu servidor con la futura VM cliente Windows 11 y con tu propio ordenador.
> - **NAT (VirtualBox):** Adaptador que traduce el tráfico de la VM a través de la conexión de red de tu PC físico, dándole salida a internet sin exponerla directamente.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.4_Donde_Estamos]] | [[Fase_2_Purga_y_Preparacion_del_Entorno]] | [[Fase_2.6_Procedimiento]] |
