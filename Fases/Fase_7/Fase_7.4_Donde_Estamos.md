## Fase 7 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 6
> Tienes dos discos virtuales montados con cuotas físicas. Los usuarios pueden crear archivos con permisos básicos (chmod), pero no hay control granular por grupo. Cualquiera que llegue a la carpeta puede ver su contenido, aunque no tenga permiso para acceder.

> [!warning] El Problema
> Con solo permisos POSIX (chmod 755), no puedes crear un modelo seguro para múltiples departamentos. Si necesitas que el grupo `comercial` tenga acceso total a `facturacion` pero `bomberos` no vea ni que existe, `chmod` no es suficiente. Necesitas dos capas: (1) una física (ACL) que controle quien realmente accede, y (2) una visual (ABE) que oculte las carpetas de los que no tienen permiso.

> [!success] Objetivo de esta Fase
> Implementar **dos capas de seguridad profesional:** Las **ACLs** (listas de control de acceso granulares) que otorgan permisos reales a grupos específicos, y **ABE** (*Access Based Enumeration*) que oculta visualmente las carpetas que no puedes acceder. El resultado: `shinnosuke.nohara` (bomberos) simplemente no ve la carpeta `facturacion` en el navegador de red.

> [!tip] Hoja de Ruta
> 1. Aplicar ACL al grupo `comercial` en `/srv/samba/departamentos/facturacion` con permisos rwx (lectura, escritura, ejecución)
> 2. Configurar herencia (-d flag) para que nuevos archivos en esa carpeta hereden los permisos automáticamente
> 3. Editar `/etc/samba/smb.conf` para declarar las secciones [comercial] (sin ABE) y [facturacion] (con ABE activado)
> 4. Activar `access based share enum = yes` y `hide unreadable = yes` en [facturacion]
> 5. Reiniciar el servicio `samba-ad-dc`
> 6. Desde Windows: iniciar como `masao.sato` (comercial) y verificar que ve `facturacion`
> 7. Desde Windows: iniciar como `shinnosuke.nohara` (bomberos) y verificar que NO ve `facturacion`
>
> **Resultado Final:** Carpeta `facturacion` completamente protegida — invisible para quienes no tienen permiso, accesible solo para el grupo `comercial`. Los archivos nuevos heredan automáticamente los permisos del grupo.
> **Siguiente:** Fase 8 (Integración del Cliente) — unirás Windows 11 al dominio y probarás el acceso desde el aula.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.3_Obligaciones_Grabacion]] | [[Fase_7]] | [[Fase_7.5_Fundamento_Teorico]] |
