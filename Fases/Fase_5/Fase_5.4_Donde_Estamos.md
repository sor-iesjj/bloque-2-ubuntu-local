## Fase 5 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 4
> Tienes un Active Directory completamente provisionado (Samba AD DC) dentro de tu máquina virtual de VirtualBox, el dominio BOOCHANLAB.LOCAL existe como un "reino" Kerberos, y DNS + LDAP están operativos en la Red Solo Anfitrión (10.10.10.10). Sin embargo, el servidor no sabe aún "traducir" usuarios de Windows (que hablan en SIDs) a usuarios Linux (que hablan en números UID/GID). Los usuarios del dominio existen en AD, pero el servidor no los reconoce como entidades válidas del sistema de archivos.

> [!warning] El Problema
> Sin mapeo RFC 2307, los usuarios del dominio son "fantasmas" para Linux. Si un usuario intenta crear un archivo, el servidor dirá "¿Quién eres?". Además, aunque logres que se autentiquen, los archivos que creen no tendrán propietario válido — aparecerán con UIDs numéricos inválidos en lugar de nombres legibles. En producción, esto significa que nadie puede acceder a los archivos de sus compañeros porque el sistema no comprende las relaciones de grupo.

> [!success] Objetivo de esta Fase
> Integrar el servicio **winbind** (el "traductor") en el servidor para que Linux reconozca a los usuarios de Windows como ciudadanos de primer nivel del sistema de archivos. Cada usuario y grupo tendrá un UID/GID permanente, y cualquier archivo creado podrá ser compartido y editado por sus compañeros de grupo con permisos claros.

> [!tip] Hoja de Ruta
> 1. Configurar **nsswitch.conf** para añadir winbind en las búsquedas de usuarios y grupos (el servidor preguntará a Samba primero)
> 2. Crear dos grupos del dominio: `policia` (GID 3001) y `bomberos` (GID 3002) — para demostrar después segregación de datos
> 3. Crear dos usuarios: `user1` (UID 10001, grupo policia) y `user2` (UID 10002, grupo bomberos) — con sus atributos RFC 2307
> 4. Verificar que `id user1` e `id user2` devuelven los UIDs y GIDs esperados
> 5. Probar creación de archivo: verificar que los permisos y propietarios se asignan correctamente en ext4
> 6. Comprobar que `getent passwd user1` y `getent group policia` muestran los usuarios del dominio como si fueran locales
>
> **Resultado Final:** El servidor reconoce a los usuarios del dominio como entidades Linux válidas, con UIDs/GIDs estables y heredables. Los archivos que creen llevarán sus identidades de forma permanente.
> **Siguiente:** Fase 6 (Almacenamiento Virtual) — crearás discos virtuales con cuotas para controlar que no llenen el servidor.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.3_Obligaciones_Grabacion]] | [[Fase_5]] | [[Fase_5.5_Fundamento_Teorico]] |
