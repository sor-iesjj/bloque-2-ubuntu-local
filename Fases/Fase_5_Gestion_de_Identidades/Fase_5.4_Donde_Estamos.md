## Fase 5 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 4
> Tienes un Active Directory completamente provisionado (Samba AD DC) dentro de tu máquina virtual de VirtualBox, el dominio BOOCHANLAB.LOCAL existe como un "reino" Kerberos, y DNS + LDAP están operativos en la Red Solo Anfitrión (10.10.10.10). Sin embargo, el servidor no sabe aún "traducir" usuarios de Windows (que hablan en SIDs) a usuarios Linux (que hablan en números UID/GID). Los usuarios del dominio existen en AD, pero el servidor no los reconoce como entidades válidas del sistema de archivos.

> [!warning] El Problema
> Sin mapeo RFC 2307, los usuarios del dominio son "fantasmas" para Linux. Si un usuario intenta crear un archivo, el servidor dirá "¿Quién eres?". Además, aunque logres que se autentiquen, los archivos que creen no tendrán propietario válido — aparecerán con UIDs numéricos inválidos en lugar de nombres legibles. En producción, esto significa que nadie puede acceder a los archivos de sus compañeros porque el sistema no comprende las relaciones de grupo.

> [!success] Objetivo de esta Fase
> Integrar el servicio **winbind** (el "traductor") en el servidor para que Linux reconozca a los usuarios de Windows como ciudadanos de primer nivel del sistema de archivos. Cada usuario y grupo tendrá un UID/GID permanente, y cualquier archivo creado podrá ser compartido y editado por sus compañeros de grupo con permisos claros.

> [!abstract] 🏢 A partir de aquí, el laboratorio tiene nombre: **Boochan S.L.**
> Aquí no hay usuarios de juguete. Vas a dar de alta a **una plantilla entera**: seis departamentos y doce trabajadores, con nombres, apellidos y un puesto.
>
> **Todo el escenario —nombres, UID, GID y la matriz de permisos que aplicarás en la Fase 7— está en [[Escenario_Boochan_SL]].** Léelo antes de empezar: es la fuente de verdad de las fases 5 a 8.

> [!tip] Hoja de Ruta
> 1. Configurar **nsswitch.conf** para añadir winbind en las búsquedas de usuarios y grupos.
> 2. Crear los **seis departamentos** como grupos del dominio, con GID **3001** a **3006**: `facturacion`, `contabilidad`, `comercial`, `logistica`, `rrhh` y `becarios`.
> 3. Crear los **doce trabajadores**, con UID **10001** a **10012** y sus atributos RFC 2307 — los dos primeros a mano, el resto con un bucle que tendrás que leer y explicar.
> 4. Asignar cada trabajador **a su departamento**.
> 5. Verificar que `id` devuelve **exactamente** los números del escenario para los doce.
> 6. Comprobar que cada departamento tiene **dos personas** y que los becarios **no están en ningún otro grupo**.
>
> **Resultado Final:** el servidor reconoce a los doce trabajadores como entidades Linux válidas, con UID/GID estables. Todavía no hay carpetas ni permisos — eso llega en las fases 6 y 7.
>
> **Siguiente:** Fase 6 (Almacenamiento Virtual) — crearás las carpetas de cada departamento sobre discos con cuota.

> [!info] 🎓 Por qué doce personas y no dos
> Con dos usuarios se puede demostrar que winbind traduce. **Con doce en seis departamentos se puede demostrar algo mucho más importante:** que los permisos se dan a **grupos**, y que mover a alguien de grupo cambia lo que ve sin tocar ni una carpeta.
>
> Y hay una razón práctica: en la **Fase 8** vas a iniciar sesión con usuarios distintos para comprobar que cada uno ve **solo lo suyo**. Con dos usuarios, esa prueba no demuestra nada.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.3_Obligaciones_Grabacion]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.5_Fundamento_Teorico]] |
