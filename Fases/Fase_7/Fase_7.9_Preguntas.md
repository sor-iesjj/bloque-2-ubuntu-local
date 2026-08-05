## Fase 7 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Qué diferencia fundamental hay entre un permiso `chmod` básico y una **ACL**?
> 2. ¿Cómo mejora el sistema **ABE** la privacidad de los datos en una empresa con muchos departamentos?
> 3. ¿Qué significa exactamente la opción **-d** en el comando `setfacl`?
> 4. 🔬 **Reto práctico:** Crea un archivo dentro de `prueba3` desde el servidor: `sudo touch /srv/samba/prueba3/heredado.txt`. Luego ejecuta `getfacl /srv/samba/prueba3/heredado.txt`. ¿Qué permisos tiene el archivo nuevo? ¿De dónde vienen esos permisos si no los has asignado explícitamente? ¿Qué habría pasado si no hubieras configurado la herencia con `-d`?
> 5. 🔬 **Reto práctico:** En Windows, inicia sesión como `user2` (bomberos) y navega a `\\UbuntuServer.BOOCHANLAB.LOCAL\` desde el Explorador de Archivos. ¿Ves la carpeta `prueba3`? Cierra sesión e inicia como `user1` (policia) y repite. ¿Qué diferencia hay? Haz una captura de pantalla de ambas vistas — eso es ABE trabajando en producción.

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.8.b_Punto_de_Control]] | [[Fase_7]] | [[Fase_7.10.a_Laboratorio_de_Averias]] |
