## Fase 5 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. La "Traducción de Mundos"
> En esta fase ocurre la magia de la interoperabilidad. Windows identifica usuarios con un **SID** (una cadena alfanumérica muy larga e ilegible). Linux, por el contrario, usa un **UID** (un número corto de 4 o 5 cifras). 

> [!info] 2. El Estándar RFC 2307
> Para que un usuario de Windows pueda guardar un archivo en el disco duro de nuestro servidor Linux, necesitamos el estándar **RFC 2307**. Esto permite añadir atributos técnicos de Unix (como el número de usuario o la carpeta /home) directamente en la ficha del Active Directory. Es la única forma de que los permisos de archivo sean consistentes y no haya errores de "Acceso Denegado".

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Identidades
> - **UID-Number:** El identificador numérico único que el Kernel de Linux asigna a un usuario.
> - **GID-Number:** El identificador numérico para un grupo de usuarios.
> - **Mapeo:** La relación 1 a 1 entre un usuario de Windows y un ID de Linux.
> - **samba-tool:** La "Navaja Suiza" para gestionar todos los aspectos del dominio desde la terminal.

---

### 🔓 Red Solo Anfitrión de VirtualBox

> [!info] ℹ️ Sin cambios de red en esta fase
> El puerto **445 (SMB)** que necesita esta fase circula sin problema por la Red Solo Anfitrión de VirtualBox (no hay firewall perimetral entre servidor y cliente). El firewall local (`ufw`) del servidor sigue **inactivo** en este punto del proyecto — no se activa hasta la Auditoría Final — así que tampoco hay ninguna regla que comprobar ni tocar todavía.
>
> Si al conectarte desde el cliente Windows la carpeta no aparece y sospechas que es un problema de red, verifica en el servidor que el firewall permite el tráfico SMB:
> ```bash
> sudo ufw status
> ```
> Debe aparecer una regla `445/tcp ALLOW`. Recuerda también que servidor y cliente deben estar en el mismo adaptador de Red Solo Anfitrión de VirtualBox (10.10.10.0/24) para verse entre sí.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.4_Donde_Estamos]] | [[Fase_5]] | [[Fase_5.6_Procedimiento]] |
