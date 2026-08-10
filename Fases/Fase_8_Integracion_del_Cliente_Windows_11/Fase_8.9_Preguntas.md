## Fase 8 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué en este proyecto el cliente Windows no necesita el túnel WireGuard para unirse al dominio, a diferencia del Bloque 4 (la nube)?
> 2. ¿Qué sucede técnica y exactamente si hay más de 5 minutos de diferencia horaria entre cliente y servidor?
> 3. ¿Para qué sirven las herramientas **RSAT** en esta infraestructura híbrida, y por qué necesitas el adaptador NAT para instalarlas?
> 4. ¿Qué riesgo de seguridad existiría si, en lugar de un segundo adaptador NAT, hubieras usado un único adaptador en modo "Adaptador Puente" (*Bridged*) conectado directamente a la red del centro?
> 5. 🔬 **Reto práctico:** Con `masao.sato` iniciado en Windows, crea un archivo de texto en la unidad `Z:` (por ejemplo `prueba_masao.txt`). Sin cerrar Windows, entra al servidor por SSH desde tu propio ordenador (`ssh boochan@10.10.10.10`) y ejecuta `ls -la /srv/samba/departamentos/comercial/`. ¿Ves el archivo? ¿A qué usuario Linux pertenece según la columna de propietario? ¿Coincide con el UID que configuraste en la Fase 5?
> 6. 🔬 **Reto práctico:** Con `masao.sato` logueado y la unidad `Z:` mapeada, **apaga el Adaptador 1 (Red Solo Anfitrión)** de la VM cliente desde VirtualBox (Dispositivos → Red → sin conectar), sin cerrar sesión de Windows. Intenta abrir un archivo de la unidad `Z:`. ¿Qué error aparece? ¿Qué diferencia hay con lo que le pasaría a un usuario real de empresa cuya "carpeta compartida desaparece" por caerse la VPN?

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas no son decorativas: son la parte de la fase que demuestra que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
>
> Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.8.b_Punto_de_Control]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.10.a_Laboratorio_de_Averias]] |
