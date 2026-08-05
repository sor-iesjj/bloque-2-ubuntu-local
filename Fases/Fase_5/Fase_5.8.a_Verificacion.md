## Fase 5 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Aquí compruebas. En el [[Fase_5.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ El fallo de esta fase tampoco da error
> Los usuarios pueden existir, responder y tener **los números equivocados**. Nada protesta hoy, y **la Fase 7 se cae** cuando pongas permisos sobre esos números.
>
> Si tomas la instantánea sin comprobar el punto 4, estarás guardando ese fallo.

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`ubuntuserver`**. Si responde el nombre de tu ordenador, la sesión SSH se cerró y estás comprobando **tu propia máquina** → [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · EL DOMINIO DE LA FASE 4 SIGUE EN PIE**

```bash
systemctl is-active samba-ad-dc
sudo samba-tool domain level show
```

- **Qué hacen:** confirman que hay dominio. **Sin dominio no hay usuarios de dominio**, y todo lo demás de esta lista sobra.
- **✅ Bien:** `active`, y el nivel funcional sin errores.
- **❌ Mal:** vuelve a la [[Fase_4.7_Resolucion_Problemas|resolución de problemas de la Fase 4]]. El fallo está allí, no aquí.

> [!info] 🎓 Por qué se empieza comprobando la fase anterior
> A partir de aquí, cada fase se apoya en la de antes. **Un fallo heredado se disfraza de fallo nuevo**: pasarías una hora buscando en winbind un problema que está en el DNS del dominio.
>
> Verificar hacia atrás antes de verificar lo tuyo te ahorra esa hora.

### **2 · EL TRADUCTOR ESTÁ VIVO Y SEGUIRÁ ESTÁNDOLO**

```bash
systemctl is-active winbind
systemctl is-enabled winbind
```

- **Qué hacen:** el primero dice si `winbind` corre **ahora**; el segundo, si arrancará **solo** la próxima vez.
- **✅ Bien:** `active` y `enabled`.
- **❌ Mal:**
  - `inactive` → [[Fase_5.7_Resolucion_Problemas#E1 · id user1 no devuelve nada|caso E1]]
  - `disabled` → [[Fase_5.7_Resolucion_Problemas#E8 · Tras reiniciar los usuarios han desaparecido|caso E8]]

> [!warning] ⚠️ `active` sin `enabled` es una bomba de relojería
> Los usuarios funcionarían hoy y desaparecerían en el próximo arranque. Y el síntoma —*"se han borrado los usuarios"*— no menciona a winbind por ningún sitio.

### **3 · LINUX SABE A QUIÉN PREGUNTAR**

```bash
grep -E "^passwd:|^group:" /etc/nsswitch.conf
```

- **Qué hace:** enseña las dos líneas que le dicen a Linux dónde buscar identidades.
- **✅ Bien:** las dos terminan en `winbind`:
  ```
  passwd:         files systemd winbind
  group:          files systemd winbind
  ```
- **❌ Mal:** falta en alguna → vuelve al Paso 1 del procedimiento.

> [!info] 🎓 Winbind puede estar perfecto y no servir de nada
> Este punto y el anterior parecen lo mismo y no lo son: el 2 comprueba que **el traductor existe**; el 3, que **alguien le pregunta**. Un traductor al que nadie consulta es un traductor inútil.

### **4 · 🔴 LOS USUARIOS TIENEN EXACTAMENTE LOS NÚMEROS QUE PUSISTE**

```bash
id user1
id user2
```

- **Qué hace:** pregunta al sistema **quién es** cada usuario, en términos de Unix.
- **✅ Bien:** `uid=10001 ... gid=3001` para `user1` y `uid=10002 ... gid=3002` para `user2`. **Los números, exactos.**
- **❌ Mal:**
  - No devuelve nada → [[Fase_5.7_Resolucion_Problemas#E1 · id user1 no devuelve nada|caso E1]]
  - Devuelve **otros números** → [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los que yo puse|caso E7]]

> [!danger] 🛑 ESTA ES LA COMPROBACIÓN MÁS IMPORTANTE DE LA FASE
> Que `id` responda **no basta**. Tiene que responder **con tus números**.
>
> Si winbind asignó IDs automáticos, todo funciona hoy: el usuario entra, crea ficheros, nada falla. Pero en la **Fase 7** vas a dar permisos sobre carpetas usando `3001` y `3002` — y si los usuarios no llevan esos números, **los permisos no se aplicarán a nadie**.
>
> Peor aún: si algún día rehaces el dominio, los números automáticos pueden salir distintos, y los ficheros de `user1` quedarán a nombre de un número sin dueño.
>
> **En Unix, un usuario no es su nombre: es su número.** Diez segundos ahora te ahorran la Fase 7 entera.

### **5 · LOS GRUPOS EXISTEN EN LOS DOS MUNDOS**

```bash
getent group policia
getent group bomberos
sudo samba-tool group listmembers policia
```

- **Qué hacen:** el `getent` comprueba que **Linux** ve el grupo con su GID; el `listmembers`, que **Active Directory** sabe quién pertenece a él.
- **✅ Bien:** `policia:*:3001:` y `bomberos:*:3002:`, y `user1` aparece como miembro de `policia`.
- **❌ Mal:**
  - `getent` no devuelve nada → falta el `addunixattrs` → [[Fase_5.7_Resolucion_Problemas#E5 · addunixattrs da error de esquema LDAP|caso E5]]
  - El usuario no sale en `listmembers` → [[Fase_5.7_Resolucion_Problemas#E6 · El usuario no está en su grupo|caso E6]]

> [!info] 🎓 Dos comandos porque son dos mundos
> `getent` pregunta al **Linux**. `samba-tool` pregunta al **dominio**. La misma pertenencia vive en los dos sitios y puede estar bien en uno y mal en el otro.
>
> Ese desajuste es la fuente número uno de problemas en entornos mixtos, y por eso se comprueban los dos.

### **6 · DOS USUARIOS, DOS IDENTIDADES DISTINTAS**

```bash
id -u user1
id -u user2
```

- **Qué hace:** confirma que los dos números son **diferentes**.
- **✅ Bien:** `10001` y `10002`.
- **❌ Mal:** el mismo número en los dos → para el sistema de ficheros **son el mismo usuario**, y la Fase 7 no podrá distinguirlos por mucho que se llamen distinto.

> [!info] 🎓 Esto ya lo viviste
> Es la misma lección del choque de máquinas de la [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|Fase 1]]: **dos cosas con la misma identidad no son dos cosas.** Allí eran dos servidores con la misma clave de host; aquí, dos personas con el mismo número.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los seis puntos de arriba tú, comando a comando, entendiendo qué dice cada uno. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.
>
> El script sirve **después**, para confirmar que no se te ha escapado nada.

> [!example] Cómo se descarga y se ejecuta
> **1. Descárgalo en el servidor:**
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase5.sh
> ```
>
> **2. Dale permiso de ejecución:**
> ```bash
> chmod +x verificar_fase5.sh
> ```
>
> **3. Léelo antes de ejecutarlo:**
> ```bash
> less verificar_fase5.sh
> ```
> *(Se sale con `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído.**
>
> **4. Ejecútalo:**
> ```bash
> sudo ./verificar_fase5.sh
> ```
>
> **5. Sube el informe** `verificacion-fase-5.txt` a tu repositorio, junto con la entrada de apuntes.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. Y una pregunta más difícil: **¿por qué el script comprueba primero cosas de la Fase 4 antes de mirar nada de la 5?**

---

### ✅ Checklist de este apartado

- [ ] `samba-ad-dc` → `active` y el dominio responde.
- [ ] `winbind` → `active` **y** `enabled`.
- [ ] `nsswitch.conf` → `winbind` en las líneas `passwd` **y** `group`.
- [ ] 🔴 `id user1` → **`uid=10001 gid=3001`**, exactamente esos números.
- [ ] 🔴 `id user2` → **`uid=10002 gid=3002`**, exactamente esos números.
- [ ] `getent group policia` → **`3001`**; `getent group bomberos` → **`3002`**.
- [ ] `samba-tool group listmembers policia` incluye a `user1`.
- [ ] Los dos UID son **distintos entre sí**.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_5.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.7_Resolucion_Problemas]] | [[Fase_5]] | [[Fase_5.8.b_Punto_de_Control]] |
