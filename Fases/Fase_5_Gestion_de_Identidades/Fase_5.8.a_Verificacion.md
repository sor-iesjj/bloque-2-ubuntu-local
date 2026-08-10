## Fase 5 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5_Gestion_de_Identidades]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> Aquí compruebas. En el [[Fase_5.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ El fallo de esta fase no da error
> Los doce trabajadores pueden existir, responder y tener **los números equivocados**. Nada protesta hoy, y **la Fase 7 se cae** cuando los permisos que des a `3001`-`3006` no alcancen a nadie.
>
> Si tomas la instantánea sin comprobar el punto 4, estarás guardando ese fallo.

> [!info] 📋 Ten delante el escenario
> Todos los números de esta lista salen de [[Escenario_Boochan_SL]]. **No los verifiques de memoria.**

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`UbuntuServer`** → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · EL DOMINIO DE LA FASE 4 SIGUE EN PIE**

```bash
systemctl is-active samba-ad-dc
sudo samba-tool domain level show
```

- **Por qué:** **sin dominio no hay usuarios de dominio**, y todo lo demás de esta lista sobra.
- **✅ Bien:** `active`, y el nivel funcional sin errores.
- **❌ Mal:** vuelve a la [[Fase_4.7_Resolucion_Problemas|resolución de problemas de la Fase 4]]. El fallo está allí, no aquí.

> [!info] 🎓 Por qué se empieza comprobando la fase anterior
> A partir de aquí, cada fase se apoya en la de antes. **Un fallo heredado se disfraza de fallo nuevo**: pasarías una hora buscando en winbind un problema que está en el DNS.

### **2 · EL TRADUCTOR ESTÁ VIVO Y SEGUIRÁ ESTÁNDOLO**

```bash
wbinfo -p
getent passwd hiroshi.nohara
systemctl is-active winbind
```

- **✅ Bien:** `Ping to winbindd succeeded`, el `getent` resuelve al usuario, y el servicio dice **`inactive`**.
- **❌ Mal:** `wbinfo -p` falla → [[Fase_5.7_Resolucion_Problemas#E1 · Un usuario no aparece con id|caso E1]].

> [!danger] 🛑 Que el servicio diga `inactive` es LO CORRECTO. No lo arranques
> En un **controlador de dominio**, `winbindd` va **dentro** del proceso `samba`. El servicio `winbind` de systemd es el del **Samba clásico**, el que apagaste en la Fase 4 junto a `smbd` y `nmbd`.
>
> Por eso aquí no se pregunta *"¿está el servicio corriendo?"* sino **"¿responde el traductor?"**. Son cosas distintas, y solo la segunda importa.
>
> **Fíjate en la contradicción aparente:** servicio parado, `wbinfo` respondiendo y usuarios resolviéndose. Si sabes leer eso, sabes cómo está montado tu servidor.

### **3 · LINUX SABE A QUIÉN PREGUNTAR**

```bash
grep -E "^passwd:|^group:" /etc/nsswitch.conf
```

- **✅ Bien:** las dos líneas terminan en `winbind`.
- **❌ Mal:** falta en alguna → vuelve al Paso 1 del procedimiento.

> [!info] 🎓 Winbind puede estar perfecto y no servir de nada
> El punto 2 comprueba que **el traductor existe**; el 3, que **alguien le pregunta**. Un traductor al que nadie consulta es un traductor inútil.

### **4 · 🔴 LOS DOCE TRABAJADORES, CON SUS NÚMEROS EXACTOS**

```bash
for u in hiroshi.nohara nene.sakurada misae.nohara toru.kazama \
         masao.sato ai.suotome bo.suzuki midori.yoshinaga \
         ume.matsuzaka bunta.takakura shinnosuke.nohara himawari.nohara; do
    printf '%-20s ' "$u"; id "$u" 2>/dev/null || echo "NO SE ENCUENTRA"
done
```

- **✅ Bien:** los doce, con UID **`10001`** a **`10012`**, y cada uno con **su departamento en `groups=`**.

> [!warning] ⚠️ El `gid=` que verás es `100(users)`, y está bien
> ```
> uid=10001(...hiroshi.nohara) gid=100(users) groups=100(users),3001(...facturacion)
> ```
> **En Active Directory el grupo primario de todo el mundo es `Domain Users`.** Lo que importa es lo que hay en **`groups=`**: ahí sí está su departamento.
>
> Las ACL de la Fase 7 miran la **pertenencia**, y los ficheros que cree heredarán el grupo de la carpeta por el **setgid** de la Fase 6. **El grupo primario no interviene en ninguna de las dos cosas.**
- **❌ Mal:**
  - `NO SE ENCUENTRA` → [[Fase_5.7_Resolucion_Problemas#E1 · Un usuario no aparece con id|caso E1]]
  - **Otros números** → [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los del escenario|caso E7]]

> [!danger] 🛑 ESTA ES LA COMPROBACIÓN MÁS IMPORTANTE DE LA FASE
> Que `id` responda **no basta**. Tiene que responder **con los números del escenario**.
>
> Si winbind asignó IDs automáticos, todo funciona hoy. Pero en la **Fase 7** vas a dar permisos sobre carpetas usando `3001` a `3006` — y si tus trabajadores no llevan esos números, **esos permisos no se aplicarán a nadie**.
>
> Peor aún: si algún día rehaces el dominio, los números automáticos pueden salir distintos, y **los ficheros de `misae.nohara` quedarán a nombre de un número sin dueño**.
>
> **En Unix, una persona no es su nombre: es su número.** Treinta segundos ahora te ahorran la Fase 7 entera.

### **5 · CADA DEPARTAMENTO CON SU GENTE, EN LOS DOS MUNDOS**

```bash
for g in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "--- $g  (GID $(getent group $g | cut -d: -f3))"
    sudo samba-tool group listmembers "$g"
done
```

- **✅ Bien:** los seis con su GID de `3001` a `3006`, y **dos personas en cada uno**.
- **❌ Mal:**
  - Un GID vacío → falta el `addunixattrs` → [[Fase_5.7_Resolucion_Problemas#E5 · addunixattrs da error de esquema LDAP|caso E5]]
  - Alguien no aparece → [[Fase_5.7_Resolucion_Problemas#E6 · El usuario no está en su grupo|caso E6]]

> [!info] 🎓 Dos comandos porque son dos mundos
> `getent` pregunta al **Linux**. `samba-tool` pregunta al **dominio**. La misma pertenencia vive en los dos sitios y puede estar bien en uno y mal en el otro.
>
> Ese desajuste es la fuente número uno de problemas en entornos mixtos.

### **6 · DOCE PERSONAS, DOCE IDENTIDADES DISTINTAS**

```bash
for u in hiroshi.nohara nene.sakurada misae.nohara toru.kazama \
         masao.sato ai.suotome bo.suzuki midori.yoshinaga \
         ume.matsuzaka bunta.takakura shinnosuke.nohara himawari.nohara; do
    id -u "$u" 2>/dev/null
done | sort | uniq -d
```

- **✅ Bien:** **no devuelve nada.** Ningún número repetido.
- **❌ Mal:** si devuelve algún número, **dos personas lo comparten** — y para el sistema de ficheros **son la misma persona**.

> [!info] 🎓 Esto ya lo viviste
> Es la misma lección del choque de máquinas de la [[Fase_1.6.f_Procedimiento_Exportar_e_Intercambiar|Fase 1]]: **dos cosas con la misma identidad no son dos cosas.** Allí eran dos servidores con la misma clave de host; aquí, dos trabajadores con el mismo número.
>
> Y tiene una consecuencia que en una empresa importa: **ninguna auditoría podría distinguir quién hizo qué.** Los registros guardan el número, no el nombre.

### **7 · LOS BECARIOS SON BECARIOS Y NADA MÁS**

```bash
id -nG shinnosuke.nohara
id -nG himawari.nohara
```

- **✅ Bien:** aparecen en `becarios` **y en ningún departamento operativo**.
- **❌ Mal:** si alguno está en `contabilidad` o similar, se te ha colado en el bucle.

> [!warning] ⚠️ Esto se comprueba aparte a propósito
> En la Fase 7, los becarios van a ser el caso de prueba de *"sin acceso a nada"*. **Un becario que pertenezca a un departamento por error rompe esa prueba** — y no lo notarías hasta la Fase 8, con el cliente Windows delante.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los siete puntos de arriba tú, comando a comando. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase5.sh
> chmod +x verificar_fase5.sh
> less verificar_fase5.sh
> sudo ./verificar_fase5.sh
> ```

> [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
>
> **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
>
> **La comprobación cuesta dos segundos:**
> ```bash
> ls -l verificar_fase5.sh
> ```
> **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
>
> **Y si sospechas que estás con una versión vieja:**
> ```bash
> rm -f verificar_fase5.sh          # bórralo primero: así, si falla el curl, lo ves
> curl -H 'Cache-Control: no-cache' -O <la URL>
> ```
>
> > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> >
> > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**
> *(El `less` se sale con `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído.**
>
> **Sube el informe** `verificacion-fase-5.txt` a tu repositorio.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. **¿Por qué el script comprueba cosas de la Fase 4 antes de mirar nada de la 5?**
> 3. El script lleva el escenario escrito en dos listas al principio. **¿Qué ventaja tiene eso frente a repetir los nombres por todo el código?**

---

### ✅ Checklist de este apartado

- [ ] `samba-ad-dc` → `active` y el dominio responde.
- [ ] `wbinfo -p` responde y `getent passwd` resuelve *(el servicio, `inactive`: correcto)*.
- [ ] `nsswitch.conf` → `winbind` en `passwd` **y** `group`.
- [ ] 🔴 Los **doce** trabajadores con UID **`10001`-`10012`** y sus GID exactos.
- [ ] Los **seis** departamentos con GID **`3001`-`3006`**.
- [ ] **Dos miembros** en cada departamento.
- [ ] **Ningún UID repetido**.
- [ ] Los dos becarios **solo** en `becarios`.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_5.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.7_Resolucion_Problemas]] | [[Fase_5_Gestion_de_Identidades]] | [[Fase_5.8.b_Punto_de_Control]] |
