## Fase 6 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Almacenamiento Virtual (Cuotas con Loop Devices)**
> 🧭 Índice de la fase: [[Fase_6_Almacenamiento_Virtual_Cuotas]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué un **Loop Device** es más seguro que una cuota de software tradicional?
> 2. ¿Qué representa exactamente el parámetro `bs=1M` en el comando `dd`?
> 3. ¿Qué pasaría con los ficheros de los seis departamentos si el servidor se reinicia y no has configurado el `fstab`?
> 4. **La decisión de diseño:** los seis departamentos comparten un volumen de 8 GB y la carpeta común tiene el suyo de 2 GB, aparte. **¿Por qué se separó precisamente esa?** Contéstalo pensando en qué pasaría si compartiera disco con contabilidad.
> 5. 🔬 **Reto práctico:** llena la carpeta común y mira quién se entera:
>    ```bash
>    sudo dd if=/dev/zero of=/srv/samba/comun/lleno.img bs=1M count=3000
>    df -h /srv/samba/comun /srv/samba/departamentos /
>    sudo rm /srv/samba/comun/lleno.img
>    ```
>    ¿Qué mensaje da el `dd`? ¿Qué decían los otros dos `df` mientras tanto? **Acabas de ver la cuota en acción, y por qué la empresa siguió trabajando.**
> 6. 🔬 **Reto práctico:** compara los dos tipos de carpeta que has creado:
>    ```bash
>    ls -ld /srv/samba/departamentos/facturacion /srv/samba/comun /tmp
>    ```
>    Una lleva **`s`** y las otras dos llevan **`t`**. ¿Qué hace cada una? ¿Y por qué `/tmp` lleva la misma que tu carpeta común?
> 7. **El cuarto dígito:** `2770` y `1777` se parecen mucho y hacen cosas distintas. Explica con tus palabras qué aporta el `2` y qué aporta el `1`, **y por qué no se podrían intercambiar** entre las carpetas de departamento y la común.

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_6.8.b_Punto_de_Control]] | [[Fase_6_Almacenamiento_Virtual_Cuotas]] | [[Fase_6.10.a_Laboratorio_de_Averias]] |
