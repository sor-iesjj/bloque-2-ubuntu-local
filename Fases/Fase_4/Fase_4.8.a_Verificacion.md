## Fase 4 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Aquí compruebas. En el [[Fase_4.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ Y en esta fase es más grave que en ninguna
> El fallo principal de la Fase 4 **no da error**: el dominio se anuncia en la tarjeta equivocada, todo parece funcionar, y **la Fase 8 revienta tres semanas después**.
>
> Si tomas la instantánea sin comprobar el punto 3, estarás guardando ese fallo. Y cada vez que restaures, volverá.

---

> [!important] 🔧 Antes de empezar: instala las herramientas de DNS
> No vienen en Ubuntu Server y las necesitas para tres de las seis comprobaciones:
> ```bash
> sudo apt install -y dnsutils
> ```
> Si `apt` falla aquí, ya tienes tu primer hallazgo → [[Fase_4.7_Resolucion_Problemas#E8 · Me he quedado sin internet y apt no funciona|caso E8]].

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`ubuntuserver`**. Si responde el nombre de tu ordenador, la sesión SSH se cerró y estás comprobando **tu propia máquina**: los siete puntos de abajo te contestarán cosas, pero ninguna valdrá → [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11]].
>
> Una verificación hecha en la máquina equivocada es peor que no hacerla: te deja tranquilo sin motivo.

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · EL CONTROLADOR DE DOMINIO ESTÁ VIVO**

```bash
systemctl is-active samba-ad-dc
systemctl is-enabled samba-ad-dc
```

- **Qué hacen:** el primero dice si está corriendo **ahora**; el segundo, si arrancará **solo** la próxima vez.
- **✅ Bien:** `active` y `enabled`.
- **❌ Mal:**
  - `failed` o `inactive` → [[Fase_4.7_Resolucion_Problemas#E9 · samba-ad-dc no arranca|caso E9]]
  - `disabled` → [[Fase_4.7_Resolucion_Problemas#E10 · Funciona hoy pero tras reiniciar no hay dominio|caso E10]]

> [!warning] ⚠️ `active` y `enabled` no son lo mismo, y hacen falta los dos
> Un dominio `active` pero no `enabled` funciona hasta el primer reinicio. Y el primer reinicio llega siempre en el peor momento — normalmente a mitad de la Fase 8, con el cliente Windows delante.

### **2 · EL SAMBA CLÁSICO ESTÁ APAGADO**

```bash
systemctl is-active smbd nmbd winbind
```

- **Qué hace:** comprueba que los tres servicios del Samba **clásico** están parados.
- **Por qué:** `smbd` y `samba-ad-dc` **se pelean por los mismos puertos**. No pueden convivir, y el script los apaga a propósito.
- **✅ Bien:** los tres devuelven `inactive`.
- **❌ Mal:** alguno `active` → [[Fase_4.7_Resolucion_Problemas#E9 · samba-ad-dc no arranca|caso E9]].

> [!info] 🎓 Ojo, esto cambia respecto a la Fase 2
> En la Fase 2 comprobabas que **`smbd` estuviera activo** — era correcto entonces, porque todavía no había dominio.
>
> **Aquí es al revés.** Al aprovisionar el dominio, el Samba clásico pasa de ser lo que quieres a ser un estorbo. **La misma comprobación cambia de signo según la fase**, y eso es normal: verificas contra el estado que toca, no contra una lista fija.

### **3 · 🔴 EL DOMINIO SE ANUNCIA EN LA IP CORRECTA**

```bash
host -t A ubuntuserver.boochanlab.local 127.0.0.1
```

- **Qué hace:** le pregunta al DNS del dominio **en qué dirección vive el servidor**.
- **✅ Bien:** `has address 10.10.10.10`
- **❌ Mal:** devuelve una **`10.0.2.x`** → [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5]]

> [!danger] 🛑 ESTA ES LA COMPROBACIÓN MÁS IMPORTANTE DE LA FASE
> Tu servidor tiene **dos tarjetas**. La `10.0.2.x` es la de NAT: existe solo dentro de VirtualBox y **ningún otro equipo puede alcanzarla**.
>
> Si el dominio se anuncia ahí, está diciendo *"búscame en una dirección a la que no llega nadie"*. Y **no lo notarás**: `samba-ad-dc` estará activo, el DNS responderá, todo saldrá en verde.
>
> Lo notarás en la **Fase 8**, cuando el cliente Windows diga **"No se encuentra el dominio"** y ese mensaje no mencione ni las tarjetas, ni el DNS, ni esta fase.
>
> **Diez segundos ahora te ahorran una tarde dentro de tres semanas.**

### **4 · UN CLIENTE PODRÍA ENCONTRAR EL DOMINIO**

```bash
host -t SRV _kerberos._tcp.boochanlab.local 127.0.0.1
host -t SRV _ldap._tcp.boochanlab.local 127.0.0.1
```

- **Qué hacen:** consultan los **registros SRV**, que son la guía telefónica del dominio: dicen *"el servicio Kerberos está en tal máquina, en tal puerto"*.
- **Por qué:** un cliente Windows **no sabe dónde está tu servidor**. Lo primero que hace al unirse es preguntar por estos registros. Sin ellos, no hay dominio al que unirse.
- **✅ Bien:** las dos consultas devuelven una línea apuntando a `ubuntuserver.boochanlab.local`.
- **❌ Mal:** vacío o error → el dominio no publicó su guía.

### **5 · EL DNS SOBREVIVE A UN REINICIO**

```bash
cat /etc/resolv.conf
lsattr /etc/resolv.conf
```

| Comando | ✅ Bien | ❌ Mal |
| :--- | :--- | :--- |
| `cat` | `nameserver 127.0.0.1` *(una segunda línea `search BOOCHANLAB.LOCAL` es normal)* | Un `nameserver` distinto → [[Fase_4.7_Resolucion_Problemas#E6 · Tras reiniciar el DNS ha vuelto a otro sitio\|caso E6]] |
| `lsattr` | Aparece una **`i`** entre los atributos | Sin `i` → el fichero se sobrescribirá al reiniciar |

> Ya lo comprobaste en el [[Fase_4.6_Procedimiento|Paso 3 del procedimiento]]. **Se repite aquí a propósito:** esta es la lista con la que decides si guardas la instantánea, y tiene que sostenerse sola.

> [!info] 🎓 Por qué hace falta la `i` (inmutable)
> `systemd-resolved` **reescribe `/etc/resolv.conf` por su cuenta** cada vez que arranca el sistema. Puedes editarlo cien veces: al reiniciar, vuelve a lo suyo.
>
> `chattr +i` lo deja **inmutable**: ni siquiera `root` puede tocarlo hasta quitarlo. Es la única forma de que tu cambio aguante.
>
> **"Lo he cambiado" no es lo mismo que "se quedará cambiado".** La prueba de una configuración es que sobreviva a un reinicio — y aquí la estás comprobando sin tener que reiniciar.

### **6 · SIGUE HABIENDO INTERNET**

```bash
getent hosts archive.ubuntu.com
```

- **Qué hace:** resuelve un nombre **de fuera** del dominio.
- **Por qué:** ahora tu servidor se pregunta a sí mismo. Lo que no es de su dominio tiene que **reenviarlo** hacia fuera. Si el reenviador no funciona, `apt` dejará de funcionar y no te enterarás hasta la Fase 5.
- **✅ Bien:** devuelve una IP.
- **❌ Mal:** nada → [[Fase_4.7_Resolucion_Problemas#E8 · Me he quedado sin internet y apt no funciona|caso E8]].

### **7 · EL DOMINIO RESPONDE COMO DOMINIO**

```bash
sudo samba-tool domain level show
```

- **Qué hace:** consulta el nivel funcional del bosque y del dominio. Es la forma más directa de preguntarle a Samba *"¿existes de verdad?"*.
- **✅ Bien:** devuelve los niveles sin errores.
- **❌ Mal:** error de conexión o de Kerberos → [[Fase_4.7_Resolucion_Problemas#E4 · Realm not found o Kerberos no autentica|caso E4]].

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los siete puntos de arriba tú, comando a comando, entendiendo qué dice cada uno. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.
>
> El script sirve **después**, para confirmar que no se te ha escapado nada.

> [!example] Cómo se descarga y se ejecuta
> **1. Descárgalo en el servidor:**
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase4.sh
> ```

> > [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> > Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
> >
> > **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
> >
> > **La comprobación cuesta dos segundos:**
> > ```bash
> > ls -l verificar_fase4.sh
> > ```
> > **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
> >
> > **Y si sospechas que estás con una versión vieja:**
> > ```bash
> > rm -f verificar_fase4.sh          # bórralo primero: así, si falla el curl, lo ves
> > curl -H 'Cache-Control: no-cache' -O <la URL>
> > ```
> >
> > > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> > >
> > > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**
>
> **2. Dale permiso de ejecución:**
> ```bash
> chmod +x verificar_fase4.sh
> ```
>
> **3. Léelo antes de ejecutarlo:**
> ```bash
> less verificar_fase4.sh
> ```
> *(Se sale con `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído** — y en esta fase acabas de leer otro mucho más peligroso, el de aprovisionamiento.
>
> **4. Ejecútalo:**
> ```bash
> sudo ./verificar_fase4.sh
> ```
>
> **5. Sube el informe** `verificacion-fase-4.txt` a tu repositorio, junto con la entrada de apuntes.

> [!info] 🌐 El `curl` y `raw.githubusercontent.com`
> Ya lo explicamos en [[Fase_3.8.a_Verificacion]]: `curl` descarga una dirección desde la línea de comandos, y `raw.githubusercontent.com` devuelve **el fichero desnudo**, sin la página web de GitHub alrededor.
>
> **Aquí hay un matiz nuevo:** el servidor ya no usa el DNS de antes, sino el suyo propio. Si el `curl` falla resolviendo el nombre, no es cosa de GitHub — es el reenviador → [[Fase_4.7_Resolucion_Problemas#E8 · Me he quedado sin internet y apt no funciona|caso E8]].

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. Y una pregunta más difícil: **¿por qué el script comprueba que `smbd` esté APAGADO, si en la Fase 2 comprobaba que estuviera encendido?**

---

---

### ✅ Checklist de este apartado

- [ ] `dnsutils` instalado.
- [ ] `samba-ad-dc` → `active` **y** `enabled`.
- [ ] `smbd`, `nmbd` y `winbind` → los tres `inactive`.
- [ ] 🔴 `host -t A ubuntuserver.boochanlab.local` → **`10.10.10.10`**, y NO una `10.0.2.x`.
- [ ] Registros **SRV** de `_kerberos` y `_ldap` publicados.
- [ ] `/etc/resolv.conf` con `nameserver 127.0.0.1` **y** con el atributo `i`.
- [ ] `getent hosts archive.ubuntu.com` responde.
- [ ] `samba-tool domain level show` responde sin errores.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_4.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior                        | 🧭 Índice  |                     Siguiente → |
| :-------------------------------- | :--------: | ------------------------------: |
| [[Fase_4.7_Resolucion_Problemas]] | [[Fase_4]] | [[Fase_4.8.b_Punto_de_Control]] |
