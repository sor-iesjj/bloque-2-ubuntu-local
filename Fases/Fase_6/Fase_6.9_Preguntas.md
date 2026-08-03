## Fase 6 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué un **Loop Device** es más seguro que una cuota de software tradicional?
> 2. ¿Qué representa exactamente el parámetro `bs=1M` en el comando `dd`?
> 3. ¿Qué pasaría con los archivos de los usuarios si el servidor se reinicia y no hemos configurado el `fstab`?
> 4. 🔬 **Reto práctico:** Intenta llenar el disco virtual ejecutando: `dd if=/dev/zero of=/srv/samba/prueba1/lleno.img bs=1M count=6000 2>&1`. ¿Qué mensaje de error aparece cuando el disco se queda sin espacio? Borra el archivo con `rm /srv/samba/prueba1/lleno.img` y comprueba con `df -h` que el espacio se ha liberado. Acabas de ver en acción la cuota física — y por qué el resto del servidor no se ve afectado.
> 5. 🔬 **Reto práctico:** Ejecuta `df -h | grep samba`. ¿Cuánto espacio queda libre en cada disco? Ahora ejecuta `df -h /` (la raíz del sistema). ¿Qué ocurriría con la raíz si no hubieras usado Loop Devices y los usuarios hubieran llenado el disco del servidor?

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.8_Punto_de_Control]] | [[Fase_6]] | [[Fase_6.10_Auditoria_y_Cierre]] |
