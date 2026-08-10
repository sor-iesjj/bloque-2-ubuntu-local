## Fase 6 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6_Almacenamiento_Virtual_Cuotas]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. Evitando el Colapso por Llenado
> La gestión de cuotas de disco es vital para evitar el "Denegación de Servicio" por llenado de disco. Si un usuario (o un atacante) llena todo el disco duro del servidor, los logs no podrán escribirse y el sistema operativo colapsará.

> [!tip] 2. Cuota Física Infranqueable (Loop Devices)
> En lugar de usar cuotas de software (que a veces fallan o son difíciles de configurar), usaremos **Loop Devices**: archivos que actúan como discos duros virtuales. 
> *   **La Lógica:** Si creamos un archivo de 5GB y lo montamos como disco, el sistema de archivos simplemente **no puede crecer más allá de eso**. Es una barrera física que protege el resto del servidor de usuarios que intenten guardar datos masivos.

### 📖 Diccionario de Conceptos Clave

> [!quote] Almacenamiento Avanzado
> - **dd:** Comando para copiar datos a bajo nivel (usado aquí para "dibujar" el tamaño de nuestro disco virtual).
> - **ext4:** El sistema de archivos estándar de Linux que vamos a "formatear" dentro de nuestro archivo `.img`.
> - **fstab:** La tabla maestra que le dice a Linux qué discos debe montar automáticamente al arrancar.
> - **Punto de Montaje:** La carpeta de Linux donde se hace accesible el contenido del disco virtual.

---

### 🔓 Red Solo Anfitrión de VirtualBox

> [!info] ℹ️ Sin cambios de red en esta fase
> El puerto **123 UDP (NTP)** circula sin problema por la Red Solo Anfitrión desde que se levantó el dominio en la **Fase 4** (Kerberos necesita sincronía horaria). El firewall local (`ufw`) del servidor sigue **inactivo** en este punto — no se activa hasta la Auditoría Final — así que no hay nada que tocar ni comprobar en él todavía.
>
> Recuerda: si el reloj de la VM del servidor y el del cliente Windows difieren más de 5 minutos, Kerberos invalida los tickets y nadie puede autenticarse. Si sospechas un problema horario, verifica en el servidor con `timedatectl status`.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.4_Donde_Estamos]] | [[Fase_6_Almacenamiento_Virtual_Cuotas]] | [[Fase_6.6_Procedimiento]] |
