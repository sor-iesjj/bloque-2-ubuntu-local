## Fase 5 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué es mejor y más profesional dar permisos a **un grupo** que a un usuario individual? Contesta pensando en qué pasa el día que `masao.sato` cambia de departamento.
> 2. ¿Qué es el servicio **winbind** y por qué decimos que es el "traductor" del sistema?
> 3. 🔬 **Reto práctico:** ejecuta `id hiroshi.nohara` e `id misae.nohara`. Anota UID y GID de cada uno. Ahora crea un fichero en su nombre y mira de quién es:
>    ```bash
>    sudo mkdir -p /tmp/pruebas_fase5
>    sudo -u 'BOOCHANLAB\hiroshi.nohara' touch /tmp/pruebas_fase5/hola.txt
>    ls -l  /tmp/pruebas_fase5/
>    ls -ln /tmp/pruebas_fase5/
>    ```
>    ¿A qué usuario y grupo pertenece? ¿Coincide con lo que anotaste? **¿Y qué diferencia hay entre lo que enseña `ls -l` y lo que enseña `ls -ln`?**
> 4. 🔬 **Reto práctico:** crea un usuario **sin** especificar UID y mira qué número le toca:
>    ```bash
>    sudo samba-tool user create prueba.temporal 'P@ssw0rd'
>    id prueba.temporal
>    sudo samba-tool user delete prueba.temporal
>    ```
>    ¿Podrías predecir qué UID tendría el siguiente? ¿Por qué eso es un problema en un servidor donde hay permisos sobre carpetas?
> 5. **Los becarios.** `shinnosuke.nohara` y `himawari.nohara` están solo en el grupo `becarios`. En la Fase 7 no van a poder acceder a nada más. **¿Qué habría pasado si por error los hubieras metido también en `contabilidad`?** ¿Cuándo te habrías dado cuenta?
> 6. **La pregunta del escenario:** contabilidad lleva las cuentas de toda la empresa, pero **no tiene acceso a RRHH**. Léelo en [[Escenario_Boochan_SL]] y explica con tus palabras por qué esa decisión es correcta, aunque parezca contradictoria.
> 7. Has creado seis grupos y doce usuarios, y **la mitad con un bucle**. ¿Qué ventaja tiene automatizarlo? ¿Y qué riesgo, si el bucle estuviera mal escrito?

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.8.b_Punto_de_Control]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.10.a_Laboratorio_de_Averias]] |
