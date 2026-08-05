## Fase 6 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 5
> Tienes usuarios y grupos del dominio completamente mapeados a UIDs/GIDs de Linux. El servidor ahora reconoce a los usuarios como si fueran locales, y pueden crear archivos con propietario válido. Sin embargo, no existe ningún límite sobre cuánto espacio pueden usar en el disco duro virtual de la máquina.

> [!warning] El Problema
> Sin cuotas de disco, un usuario malintencionado (o simplemente desprevenido) podría llenar el disco duro completamente. Cuando el disco llena, el sistema operativo colapsa: los logs dejan de escribirse, las nuevas conexiones se rechazan, y el servidor se vuelve irrecuperable sin intervención manual. En empresas, esto es un "Denegación de Servicio" (DoS) involuntaria pero devastadora.

> [!success] Objetivo de esta Fase
> Crear **discos virtuales independientes** (Loop Devices) con tamaños limitados (5GB cada uno) para que el servidor tenga **cuotas físicas infranqueables**. Si un disco llena, solo ese "usuario" o "departamento" se ve afectado — el resto del servidor continúa funcionando.

> [!tip] Hoja de Ruta
> 1. Crear carpetas de montaje en `/srv/samba/` para los discos virtuales (`facturacion` y `contabilidad`)
> 2. Generar dos archivos imagen de 5GB cada uno con `dd` (archivo binario lleno de ceros)
> 3. Formatear cada imagen con el sistema de archivos ext4
> 4. Editar `/etc/fstab` para que los discos se monten automáticamente al reiniciar (con la palabra clave `loop`)
> 5. Montar los discos con `mount -a` (sin reiniciar)
> 6. Asignar permisos: `facturacion` accesible para todos (777), `contabilidad` solo para el grupo `contabilidad` (2770)
> 7. Verificar con `df -h` que aparecen los discos de 5GB; intentar llenarlos para comprobar que la barrera física es infranqueable
>
> **Resultado Final:** Dos discos virtuales independientes montados en `/srv/samba/departamentos/facturacion` y `/srv/samba/departamentos/contabilidad`, cada uno con límite físico de 5GB. El servidor está protegido contra llenado de disco.
> **Siguiente:** Fase 7 (Seguridad Avanzada) — aplicarás ACLs y ABE para controlar quién ve y accede a cada carpeta.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.3_Obligaciones_Grabacion]] | [[Fase_6]] | [[Fase_6.5_Fundamento_Teorico]] |
