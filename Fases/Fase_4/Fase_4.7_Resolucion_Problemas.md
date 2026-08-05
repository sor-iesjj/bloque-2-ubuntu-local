## Fase 4 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!info] 🔍 Cómo se lee cada caso
> **Síntoma** *(qué ves)* → **Hipótesis** *(qué puede ser)* → **Comprobación** *(el comando que lo confirma)* → **Arreglo** → **Qué aprendes**
>
> No saltes a la solución. **La comprobación es la parte que te enseña a diagnosticar**, y es la que vas a necesitar el día que el fallo no esté en ninguna lista.

> [!danger] 🛑 Esta fase tiene un fallo que NO da ningún error
> Es el **[[#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5]]**. Todo funciona, todas las comprobaciones salen bien, y **la Fase 8 revienta tres semanas después**.
>
> Si solo vas a leer un caso de esta página, lee ese.

---

## 🗺️ Índice rápido por síntoma

| Lo que ves | Caso |
| :--- | :--- |
| El script para diciendo que falta un paquete | [[#E1 · El script para diciendo que falta un paquete\|E1]] |
| `git clone` falla, no hay red | [[#E2 · git clone falla porque no hay red\|E2]] |
| El aprovisionamiento falló a medias y quiero repetirlo | [[#E3 · El aprovisionamiento falló a medias y quiero repetirlo\|E3]] |
| `Realm not found` o Kerberos no autentica | [[#E4 · Realm not found o Kerberos no autentica\|E4]] |
| **Todo va bien pero el dominio se anuncia en `10.0.2.x`** | [[#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10\|E5]] ⚠️ |
| Tras reiniciar, el DNS ha vuelto a otro sitio | [[#E6 · Tras reiniciar el DNS ha vuelto a otro sitio\|E6]] |
| `Operation not permitted` al tocar `/etc/resolv.conf` | [[#E7 · Operation not permitted al tocar resolv.conf\|E7]] |
| Me he quedado sin internet: `apt` no funciona | [[#E8 · Me he quedado sin internet y apt no funciona\|E8]] |
| `samba-ad-dc` no arranca | [[#E9 · samba-ad-dc no arranca\|E9]] |
| Funciona hoy, pero tras reiniciar no hay dominio | [[#E10 · Funciona hoy pero tras reiniciar no hay dominio\|E10]] |

---

### E1 · El script para diciendo que falta un paquete

> [!bug] Síntoma
> El script se detiene nada más empezar:
> ```
> ERROR: falta el paquete 'samba-ad-dc'
> ```
> o lo mismo con `samba-ad-provision`.

**Hipótesis.** La Fase 2 se hizo con una versión antigua del material, o restauraste una instantánea anterior a la instalación de esos paquetes.

**Comprobación.**
```bash
dpkg -s samba-ad-dc samba-ad-provision 2>&1 | grep -Ei "status|not installed|no está instalado"
```

**Arreglo.** Instálalos y relanza:
```bash
sudo apt install -y samba-ad-dc samba-ad-provision
sudo ./provision_boochan.sh
```

> [!summary] Qué aprendes
> **El script se ha parado a propósito, y eso es una virtud.** Su primera línea es `set -euo pipefail`: aborta al primer error en vez de seguir adelante dejándote un dominio a medias.
>
> Un script de administración que **no** para cuando algo falla es un script que miente. Aquí lo has visto protegiéndote.

---

### E2 · git clone falla porque no hay red

> [!bug] Síntoma
> ```
> fatal: unable to access 'https://github.com/...': Could not resolve host
> ```

**Hipótesis.** El adaptador NAT no está activo, o el servidor intenta salir por la Red Solo Anfitrión, que **no da internet**.

**Comprobación.** Separa *"no hay red"* de *"no hay DNS"*:
```bash
ping -c2 8.8.8.8                    # ¿llego? (esto NO usa DNS)
getent hosts github.com             # ¿resuelvo nombres?
ip -brief -4 addr                   # ¿tengo las dos tarjetas?
```

**Arreglo.** Si falla el `ping`, revisa en VirtualBox que el **Adaptador 1 esté en NAT**. Si va el `ping` y falla el `getent`, tienes red y no DNS.

> [!summary] Qué aprendes
> Que **tu servidor tiene dos tarjetas con dos trabajos distintos**, y confundirlas es de lo más habitual: la `10.10.10.10` es para el laboratorio y **no sale a internet**. Lo viste en la Fase 1 y aquí lo pagas.

---

### E3 · El aprovisionamiento falló a medias y quiero repetirlo

> [!bug] Síntoma
> El script se cortó por cualquier motivo y ahora, al relanzarlo, se queja de que el dominio ya existe o de ficheros que ya están.

**Hipótesis.** Hay un aprovisionamiento **a medio hacer**. No está ni bien ni sin empezar.

> [!danger] ⚠️ Lo mejor que puedes hacer es NO arreglarlo a mano
> Un dominio a medias tiene ficheros en `/var/lib/samba/`, una base de datos LDAP incompleta y un `krb5.conf` que puede estar o no. Ir quitando piezas a mano es cómo se acaba con un servidor en un estado que nadie sabe describir.
>
> **Restaura la instantánea `Fase 3 terminada` y empieza de cero.** Tardas dos minutos y sabes exactamente de dónde partes.

**Comprobación.** Antes de decidir:
```bash
systemctl is-active samba-ad-dc
ls /var/lib/samba/private/ 2>/dev/null | head
```

**Arreglo.** Restaurar la instantánea de la Fase 3 y relanzar el procedimiento entero.

> [!summary] Qué aprendes
> **Volver a un punto conocido es más rápido y más seguro que reparar un estado desconocido.** Es la razón por la que llevas tomando instantáneas desde la Fase 1.
>
> Un administrador con prisa repara a mano. Uno con oficio restaura.

---

### E4 · Realm not found o Kerberos no autentica

> [!bug] Síntoma
> ```
> kinit: Cannot find KDC for realm "BOOCHANLAB.LOCAL"
> ```
> o cualquier orden con `-U Administrator` que no consigue autenticar.

**Hipótesis.** El `/etc/krb5.conf` del sistema no es el que generó el dominio, o **el reino está en minúsculas**.

**Comprobación.**
```bash
grep -i default_realm /etc/krb5.conf
```
- **✅ Bien:** `default_realm = BOOCHANLAB.LOCAL`
- **❌ Mal:** en minúsculas, o el fichero no existe.

**Arreglo.** Instala el que generó Samba:
```bash
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
grep -i default_realm /etc/krb5.conf
```

> [!summary] Qué aprendes
> **En Kerberos el reino va SIEMPRE en mayúsculas**, y no es una manía: el protocolo distingue mayúsculas de minúsculas en ese campo. `boochanlab.local` y `BOOCHANLAB.LOCAL` son dos reinos distintos para él.
>
> Y fíjate en el mensaje: dice *"no encuentro el KDC"*, no *"has escrito el reino en minúsculas"*. **El error casi nunca te dice la causa: te dice la consecuencia.**

---

### E5 · El dominio se anuncia en una IP que no es la 10.10.10.10

> [!bug] Síntoma
> **Ninguno.** Y ese es el problema.
>
> El script terminó con su recuadro de éxito, `samba-ad-dc` está activo, el DNS responde, todo parece perfecto. Pero:
> ```bash
> host -t A ubuntuserver.boochanlab.local 127.0.0.1
> ```
> devuelve una dirección **`10.0.2.x`** en lugar de `10.10.10.10`.

**Hipótesis.** El dominio se aprovisionó **sin `--host-ip`**, y Samba eligió por su cuenta una de las dos tarjetas: la de NAT.

> [!danger] 🛑 El fallo más caro de todo el bloque
> Tu servidor tiene **dos tarjetas**. La `10.0.2.15` es la de NAT: existe solo dentro de VirtualBox, para dar internet a la VM, y **ningún otro equipo de tu laboratorio puede alcanzarla**.
>
> Si el dominio se anuncia ahí, está diciéndole al mundo *"búscame en una dirección a la que no llega nadie"*.
>
> **Qué pasa entonces:** hoy nada. Mañana tampoco. Y en la **Fase 8**, cuando el cliente Windows intente unirse, dirá **"No se encuentra el dominio"** — un mensaje que no menciona ni las tarjetas, ni el DNS, ni esta fase que hiciste hace tres semanas.

**Comprobación.**
```bash
host -t A ubuntuserver.boochanlab.local 127.0.0.1
```

**Arreglo.** Borra el registro malo **usando la IP exacta que te haya devuelto el comando** —no la copies de aquí, mira la tuya— y añade el bueno:
```bash
sudo samba-tool dns delete 127.0.0.1 boochanlab.local ubuntuserver A LA_IP_QUE_TE_SALIO -U Administrator
sudo samba-tool dns add    127.0.0.1 boochanlab.local ubuntuserver A 10.10.10.10 -U Administrator
```
Y vuelve a comprobar con el mismo `host`.

> [!summary] Qué aprendes
> Que **un servidor con dos tarjetas tiene que decir explícitamente por cuál se anuncia.** Si no lo dices tú, lo decide el programa — y acertará la mitad de las veces.
>
> Y sobre todo: **el fallo que no da error es el caro.** Este no rompe nada hoy; rompe la Fase 8 dentro de tres semanas, cuando ya no te acuerdes de qué hiciste aquí. Por eso la verificación del apartado 8.a lo comprueba **explícitamente**, y por eso el `--host-ip` está en el script.

---

### E6 · Tras reiniciar el DNS ha vuelto a otro sitio

> [!bug] Síntoma
> Después de reiniciar el servidor, el dominio deja de resolverse. Y:
> ```bash
> cat /etc/resolv.conf
> ```
> ya **no** dice `nameserver 127.0.0.1`.

**Hipótesis.** `systemd-resolved` ha vuelto a escribir el fichero, porque no estaba protegido.

**Comprobación.**
```bash
lsattr /etc/resolv.conf
```
- **✅ Bien:** aparece una `i` entre los atributos.
- **❌ Mal:** no aparece → el fichero se puede sobrescribir.

**Arreglo.**
```bash
sudo chattr -i /etc/resolv.conf
sudo rm -f /etc/resolv.conf
printf "nameserver 127.0.0.1\nsearch BOOCHANLAB.LOCAL\n" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
lsattr /etc/resolv.conf
```

> [!summary] Qué aprendes
> Que **hay ficheros que el sistema regenera solo**, y escribir en ellos no basta: hay que **impedir** que los toquen. Eso hace `chattr +i` *(immutable)*: ni siquiera `root` puede modificarlos hasta quitarlo.
>
> Y la lección general: **"lo he cambiado" no es lo mismo que "se quedará cambiado".** La prueba de una configuración es que sobreviva a un reinicio.

---

### E7 · Operation not permitted al tocar resolv.conf

> [!bug] Síntoma
> ```
> rm: no se puede borrar '/etc/resolv.conf': Operation not permitted
> ```
> Y lo estás haciendo con `sudo`.

**Hipótesis.** El fichero es **inmutable**. Es el `chattr +i` del caso anterior, funcionando exactamente como debe.

**Comprobación.**
```bash
lsattr /etc/resolv.conf
```
Si ves la `i`, está protegido.

**Arreglo.** Quita la protección, haz el cambio, y **vuelve a ponerla**:
```bash
sudo chattr -i /etc/resolv.conf
# ... tu cambio ...
sudo chattr +i /etc/resolv.conf
```

> [!summary] Qué aprendes
> Que **`sudo` no es omnipotente.** Es la primera vez en el curso que te encuentras algo que `root` no puede hacer, y conviene que te choque: los permisos de Unix no son la única capa de protección que existe.
>
> Y que **si lo dejas desprotegido "por comodidad", el problema del [[#E6 · Tras reiniciar el DNS ha vuelto a otro sitio|caso E6]] vuelve.** Protección que se quita y no se repone es protección que no existe.

---

### E8 · Me he quedado sin internet y apt no funciona

> [!bug] Síntoma
> Tras aprovisionar el dominio, `sudo apt update` falla con errores de resolución de nombres.

**Hipótesis.** El servidor ahora se pregunta a sí mismo (`127.0.0.1`), y el reenvío hacia el exterior no está funcionando.

**Comprobación.** Separa las tres cosas:
```bash
ping -c2 8.8.8.8                                     # ¿hay red? (no usa DNS)
host -t A ubuntuserver.boochanlab.local 127.0.0.1    # ¿resuelvo lo de DENTRO?
getent hosts archive.ubuntu.com                      # ¿resuelvo lo de FUERA?
```

**Arreglo.** Si resuelves lo de dentro pero no lo de fuera, falta el **reenviador**. El script lo configura con `dns forwarder = 8.8.8.8`. Compruébalo:
```bash
grep -i "dns forwarder" /etc/samba/smb.conf
sudo systemctl restart samba-ad-dc
```

> [!summary] Qué aprendes
> Cómo funciona un **DNS con reenvío**: tu servidor contesta él mismo lo que es de su dominio, y **lo que no conoce se lo pregunta a otro** (aquí, a Google). Es exactamente lo que hace el router de tu casa.
>
> Y la técnica de diagnóstico, que vale para siempre: **`ping` a una IP no usa DNS.** Si el `ping` a `8.8.8.8` va y el `getent` no, el problema es de nombres, no de red.

---

### E9 · samba-ad-dc no arranca

> [!bug] Síntoma
> ```bash
> systemctl is-active samba-ad-dc
> ```
> devuelve `failed` o `inactive`. En el registro puede aparecer algo de un puerto ocupado.

**Hipótesis.** El **Samba clásico** (`smbd`, `nmbd`, `winbind`) sigue corriendo y se pelea por los mismos puertos.

**Comprobación.**
```bash
systemctl is-active smbd nmbd winbind
sudo systemctl status samba-ad-dc --no-pager | head -20
sudo journalctl -u samba-ad-dc -n 30 --no-pager
```

**Arreglo.** Apaga el clásico y levanta el controlador:
```bash
sudo systemctl disable --now smbd nmbd winbind
sudo systemctl unmask samba-ad-dc
sudo systemctl enable --now samba-ad-dc
systemctl is-active samba-ad-dc
```

> [!summary] Qué aprendes
> Que **`samba` y `samba-ad-dc` son dos formas incompatibles de usar el mismo programa.** El clásico comparte carpetas; el AD DC es un controlador de dominio completo. **No pueden convivir**, y el script los apaga a propósito.
>
> Fíjate en algo que ya te pasó en la Fase 2: los servicios que estorban rara vez dicen *"estorbo"*. Dicen *"puerto ocupado"*, o directamente no arrancan.

---

### E10 · Funciona hoy pero tras reiniciar no hay dominio

> [!bug] Síntoma
> Todo iba bien. Reinicias, y `samba-ad-dc` está parado.

**Hipótesis.** El servicio se levantó **a mano** y nunca se habilitó para el arranque.

**Comprobación.**
```bash
systemctl is-enabled samba-ad-dc
```
- **✅ Bien:** `enabled`.
- **❌ Mal:** `disabled` o `masked`.

**Arreglo.**
```bash
sudo systemctl unmask samba-ad-dc
sudo systemctl enable --now samba-ad-dc
systemctl is-enabled samba-ad-dc
```

> [!summary] Qué aprendes
> La distinción que llevas arrastrando desde la Fase 3: **`active` es "está corriendo ahora"; `enabled` es "arrancará solo la próxima vez".** Son dos cosas distintas y hacen falta las dos.
>
> Un servicio `active` pero no `enabled` es una bomba de relojería: funciona hasta el primer reinicio, que siempre llega en el peor momento.

---

> [!question] 🤔 Si tu fallo no está aquí
> **Antes de buscar en internet**, haz esto:
> 1. **Pasa el verificador:** `sudo ./verificar_fase4.sh`. Te dice qué comprobación falla, y eso ya acota el problema a un bloque.
> 2. **Lee el registro del servicio:** `sudo journalctl -u samba-ad-dc -n 40 --no-pager`.
> 3. **Anota el mensaje literal** en tu entrada de apuntes, aunque lo resuelvas. Los mensajes de error se repiten, y el tuyo de hoy es el de un compañero de la semana que viene.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.6_Procedimiento]] | [[Fase_4]] | [[Fase_4.8.a_Verificacion]] |
