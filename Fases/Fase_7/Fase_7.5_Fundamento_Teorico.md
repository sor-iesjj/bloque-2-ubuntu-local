## Fase 7 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. Las Dos Capas de la Seguridad Profesional
> No basta con poner una contraseña. Para que un servidor de archivos sea profesional, usamos dos capas de protección:
> 1.  **Capa Física (ACLs):** Son los permisos granulares de Linux. Dicen: *"Tú puedes entrar y leer esto"*. Es el candado real del archivo.
> 2.  **Capa Visual (ABE):** *Access Based Enumeration*. Es la "Capa de Invisibilidad". Si un usuario no tiene permiso físico (ACL), Samba simplemente **le oculta la carpeta**. Si no puedes entrar, no hace falta que sepas que existe.

> [!tip] 2. Herencia de ACLs
> Usamos la **herencia (-d)** para que el administrador no tenga que poner permisos cada vez que alguien crea un archivo nuevo. Todo lo que se cree dentro de una carpeta heredará automáticamente las reglas de su "padre".

### 📖 Diccionario de Conceptos Clave

> [!quote] Seguridad y Privacidad
> - **ACL (Access Control List):** Lista detallada de permisos para múltiples usuarios y grupos en un solo objeto.
> - **ABE:** Función de Samba que filtra la visibilidad de carpetas según los permisos del usuario.
> - **Herencia:** Característica que hace que los archivos nuevos copien los permisos de la carpeta superior.
> - **setfacl:** El comando maestro para gestionar las listas de control de acceso en Linux.

### 🔓 Red Solo Anfitrión de VirtualBox

> [!info] ℹ️ Sin cambios de red en esta fase
> Esta fase trabaja íntegramente dentro del servidor — permisos de ficheros, ACLs y configuración de Samba. No requiere tocar el adaptador de red ni el firewall: todo lo necesario para el acceso desde Windows (SMB 445, Kerberos, LDAP…) ya está activo desde la Fase 4 sobre la Red Solo Anfitrión 10.10.10.0/24.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.4_Donde_Estamos]] | [[Fase_7]] | [[Fase_7.6_Procedimiento]] |
