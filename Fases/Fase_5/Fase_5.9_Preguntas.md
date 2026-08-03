## Fase 5 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué es mejor y más profesional dar permisos a un grupo que a un usuario individual?
> 2. ¿Qué es el servicio **winbind** y por qué decimos que es el "traductor" del sistema?
> 3. 🔬 **Reto práctico:** Ejecuta `id user1` e `id user2` en el servidor. Anota el UID y GID de cada uno. Ahora crea un archivo vacío dentro de `/srv/samba/prueba1/` con `sudo -u 'BOOCHANLAB\user1' touch /srv/samba/prueba1/test_user1.txt` y ejecuta `ls -la /srv/samba/prueba1/`. ¿A qué usuario y grupo pertenece el archivo? ¿Coincide con los IDs que anotaste?
> 4. 🔬 **Reto práctico:** Intenta crear un usuario sin especificar UID: `sudo samba-tool user create user3 'P@ssw0rd'`. Luego ejecuta `id user3`. ¿Qué UID recibe? ¿Puedes predecir qué UID tendrá el próximo usuario sin especificarlo? ¿Por qué esto es un problema en un servidor de producción con permisos de carpetas?
> 5. ¿Cómo verificarías en la terminal que un usuario de Samba es reconocido por el comando `ls -l`?

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.8_Punto_de_Control]] | [[Fase_5]] | [[Fase_5.10_Auditoria_y_Cierre]] |
