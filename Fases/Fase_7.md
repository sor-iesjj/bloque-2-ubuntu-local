## 🕵️ Fase 7: Seguridad Avanzada (ACLs y ABE)

### Infraestructura de Servidor Virtual (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5 y 8: Gestión avanzada de permisos / Compartición SAMBA]**
> **[RA.04]** Gestiona los recursos compartidos del sistema interpretando especificaciones y determinando niveles de seguridad.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 4 GB RAM | Discos virtuales montados | Samba activo

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 6
> Tienes dos discos virtuales montados con cuotas físicas. Los usuarios pueden crear archivos con permisos básicos (chmod), pero no hay control granular por grupo. Cualquiera que llegue a la carpeta puede ver su contenido, aunque no tenga permiso para acceder.

> [!warning] El Problema
> Con solo permisos POSIX (chmod 755), no puedes crear un modelo seguro para múltiples departamentos. Si necesitas que el grupo `policia` tenga acceso total a `prueba3` pero `bomberos` no vea ni que existe, `chmod` no es suficiente. Necesitas dos capas: (1) una física (ACL) que controle quien realmente accede, y (2) una visual (ABE) que oculte las carpetas de los que no tienen permiso.

> [!success] Objetivo de esta Fase
> Implementar **dos capas de seguridad profesional:** Las **ACLs** (listas de control de acceso granulares) que otorgan permisos reales a grupos específicos, y **ABE** (*Access Based Enumeration*) que oculta visualmente las carpetas que no puedes acceder. El resultado: `user2` (bomberos) simplemente no ve la carpeta `prueba3` en el navegador de red.

> [!tip] Hoja de Ruta
> 1. Aplicar ACL al grupo `policia` en `/srv/samba/prueba3` con permisos rwx (lectura, escritura, ejecución)
> 2. Configurar herencia (-d flag) para que nuevos archivos en esa carpeta hereden los permisos automáticamente
> 3. Editar `/etc/samba/smb.conf` para declarar las secciones [prueba1] (sin ABE) y [prueba3] (con ABE activado)
> 4. Activar `access based share enum = yes` y `hide unreadable = yes` en [prueba3]
> 5. Reiniciar el servicio `samba-ad-dc`
> 6. Desde Windows: iniciar como `user1` (policia) y verificar que ve `prueba3`
> 7. Desde Windows: iniciar como `user2` (bomberos) y verificar que NO ve `prueba3`
>
> **Resultado Final:** Carpeta `prueba3` completamente protegida — invisible para quienes no tienen permiso, accesible solo para el grupo `policia`. Los archivos nuevos heredan automáticamente los permisos del grupo.
> **Siguiente:** Fase 8 (Integración del Cliente) — unirás Windows 11 al dominio y probarás el acceso desde el aula.

---

### 📚 Fundamento Teórico

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

### 🛠️ Procedimiento Práctico (Permisos y Visibilidad)

> [!example] Paso 1: Configuración de los Candados (ACLs)
> Aplicamos permisos granulares al grupo `policia` sobre la carpeta `prueba3` y configuramos la herencia para que todos los archivos nuevos los hereden:
>
> > [!info] 📚 Diccionario de Comandos: Para repasar los operadores exactos de `setfacl`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Aplicamos el permiso al grupo "policia"
> sudo setfacl -m g:policia:rwx /srv/samba/prueba3
>
> # Configuramos la HERENCIA para el futuro
> sudo setfacl -d -m g:policia:rwx /srv/samba/prueba3
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`-m`:** Significa "Modify". Estamos modificando la lista de permisos.
> > - **`g:policia:rwx`:** Le damos permisos de Lectura, Escritura y Ejecución (rwx) al **Grupo (g)** policia.
> > - **`-d`:** Significa "Default" (Herencia). Indica que cualquier archivo nuevo que se cree ahí dentro heredará este permiso automáticamente.

> [!example] Paso 2: Publicación de las Carpetas (smb.conf)
> Para que los usuarios puedan ver y acceder a las carpetas desde Windows, debemos declarar cada una como un "recurso compartido" en el archivo de configuración de Samba.
>
> Antes de editar, comprueba que el script de la Fase 4 no añadió ya estas secciones:
> ```bash
> sudo grep -n "prueba" /etc/samba/smb.conf
> ```
> Si el comando no devuelve nada, continúa. Si devuelve líneas con `[prueba1]` o `[prueba3]`, esas secciones ya existen: **no las añadas de nuevo**; en su lugar edítalas para completar los parámetros que falten.
>
> Abre el archivo de configuración:
> ```bash
> sudo nano /etc/samba/smb.conf
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
> Desplázate hasta el **final del archivo** (puedes usar `Ctrl + End` en nano) y añade estos dos bloques:
> ```ini
> [prueba1]
>     path = /srv/samba/prueba1
>     read only = no
>     vfs objects = acl_xattr
>
> [prueba3]
>     path = /srv/samba/prueba3
>     read only = no
>     vfs objects = acl_xattr
>     access based share enum = yes
>     hide unreadable = yes
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!tip] 💡 ¿Qué diferencia hay entre `prueba1` y `prueba3`?
> > - **`prueba1`:** Es una carpeta de acceso general para todos los usuarios del dominio. No tiene ABE.
> > - **`prueba3`:** Es la carpeta protegida. Los parámetros `access based share enum = yes` y `hide unreadable = yes` activan la doble capa de invisibilidad: la primera oculta el recurso del listado de red a quien no tiene acceso, y la segunda oculta el contenido interno a quien logra verlo pero no tiene permiso sobre los archivos.

> [!example] Paso 3: Aplicar los Cambios (Reinicio de Samba)
> Cada vez que se modifica el `smb.conf`, es obligatorio reiniciar el servicio para que los cambios surtan efecto:
> ```bash
> sudo systemctl restart samba-ad-dc
> ```
> Comprueba que el servicio ha arrancado correctamente:
> ```bash
> sudo systemctl status samba-ad-dc
> ```
> Busca la línea `Active: active (running)`. Si ves `failed`, revisa que no hay errores de sintaxis en el `smb.conf`.

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿La seguridad falla?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Las ACLs no funcionan (Access Denied). | El sistema de archivos no tiene activado el soporte. | Verifica que el disco esté montado con la opción `acl` en el fstab (aunque en ext4 es por defecto). |
> | El usuario ve la carpeta pero no puede entrar. | Samba no se ha reiniciado tras el cambio. | Ejecuta `sudo systemctl restart samba-ad-dc` y vuelve a intentarlo. |
> | `samba-ad-dc` no arranca tras editar el smb.conf. | Error de sintaxis en el archivo. | Ejecuta `sudo testparm` para que Samba te indique exactamente en qué línea está el error. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Qué diferencia fundamental hay entre un permiso `chmod` básico y una **ACL**?
> 2. ¿Cómo mejora el sistema **ABE** la privacidad de los datos en una empresa con muchos departamentos?
> 3. ¿Qué significa exactamente la opción **-d** en el comando `setfacl`?
> 4. 🔬 **Reto práctico:** Crea un archivo dentro de `prueba3` desde el servidor: `sudo touch /srv/samba/prueba3/heredado.txt`. Luego ejecuta `getfacl /srv/samba/prueba3/heredado.txt`. ¿Qué permisos tiene el archivo nuevo? ¿De dónde vienen esos permisos si no los has asignado explícitamente? ¿Qué habría pasado si no hubieras configurado la herencia con `-d`?
> 5. 🔬 **Reto práctico:** En Windows, inicia sesión como `user2` (bomberos) y navega a `\\UbuntuServer.BOOCHANLAB.LOCAL\` desde el Explorador de Archivos. ¿Ves la carpeta `prueba3`? Cierra sesión e inicia como `user1` (policia) y repite. ¿Qué diferencia hay? Haz una captura de pantalla de ambas vistas — eso es ABE trabajando en producción.

---

> [!caution] 🛑 Auditoría de Seguridad (RA.04)
> **Peligro:** Si no usas herencia, los archivos que cree un usuario no podrán ser editados por sus compañeros de grupo, generando tickets de soporte constantes.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] Comprueba con el comando `getfacl /srv/samba/prueba3` que los permisos del grupo `policia` se han aplicado.
> - [ ] ¿El servicio `samba-ad-dc` está en estado `active (running)` tras el reinicio?
> - [ ] En la Fase 8, cuando te conectes desde Windows, verifica que `user2` (bomberos) no ve la carpeta `prueba3` pero `user1` (policia) sí.
