## Fase 7 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 6
> Tienes dos discos virtuales montados con cuotas físicas. Los usuarios pueden crear archivos con permisos básicos (chmod), pero no hay control granular por grupo. Cualquiera que llegue a la carpeta puede ver su contenido, aunque no tenga permiso para acceder.

> [!warning] El Problema
> Con solo permisos POSIX (`chmod`) no puedes montar la matriz de Boochan S.L. **`chmod` solo sabe hablar de tres:** el dueño, **un** grupo y el resto. Y aquí una misma carpeta necesita permisos distintos para **varios** grupos a la vez: `facturacion` es de su departamento, **contabilidad escribe en ella** y **comercial solo la consulta**.
>
> Necesitas dos capas: (1) una **real** (ACL), que decide quién accede y con qué permiso, y (2) una **visual** (ABE), que además oculta lo que no puedes abrir.

> [!success] Objetivo de esta Fase
> Implementar **dos capas de seguridad profesional:** Las **ACLs** (listas de control de acceso granulares) que otorgan permisos reales a grupos específicos, y **ABE** (*Access Based Enumeration*) que oculta visualmente las carpetas que no puedes acceder. El resultado: `shinnosuke.nohara` (becarios) simplemente no ve la carpeta `facturacion` en el navegador de red.

> [!tip] Hoja de Ruta
> 1. Aplicar las **ACL de los cruces de la matriz**, cada una con su permiso exacto: `contabilidad` **rwx** sobre `facturacion`, `comercial` **r-x** sobre `facturacion`… **El permiso no es el mismo para todos, y ahí está la fase.**
> 2. Configurar la **herencia** (`-d`) para que lo que se cree mañana nazca con los permisos de hoy
> 3. Declarar en `/etc/samba/smb.conf` las **seis secciones de departamento + `[comun]`**
> 4. Activar `access based share enum = yes` y `hide unreadable = yes` **en las seis** — y `valid users` en `[comun]`, que es el caso especial
> 5. Validar con `testparm` **antes** de reiniciar `samba-ad-dc`
> 6. Comprobar en el servidor con `getfacl` que cada cruce tiene su permiso
> 7. Dejar anotado lo que **no se puede probar desde aquí**: la invisibilidad real se ve en la Fase 8, desde Windows
>
> **Resultado final:** la matriz de Boochan S.L. aplicada carpeta a carpeta. `contabilidad` escribe en `facturacion`, `comercial` la lee **y no puede tocarla**, RRHH es una isla, y un becario **ni siquiera ve** lo que no le corresponde.
> **Siguiente:** Fase 8 (Integración del Cliente) — unirás Windows 11 al dominio y probarás el acceso desde el aula.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.3_Obligaciones_Grabacion]] | [[Fase_7_Seguridad_Avanzada_ACL_y_ABE]] | [[Fase_7.5_Fundamento_Teorico]] |
