## Fase 3 · Apartado 8 — 💾 Verificación y punto de control

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Este apartado tiene dos partes, en este orden:
> 1. **Verificar** — solo lectura, no toca nada
> 2. **Guardar** — la instantánea, ya de un estado comprobado

---

## 🔍 PARTE 1 — Verificación

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · EL TÚNEL FUNCIONA**

```bash
sudo wg show
```

- **Qué hace:** muestra el estado del túnel y de cada cliente conectado.
- **Por qué:** es **la única prueba real**. WireGuard **descarta en silencio** los paquetes de quien no reconoce, así que puedes tener un túnel que dice "activo" y no transmite nada.
- **✅ Bien:** aparece `latest handshake` de hace **menos de 3 minutos**, y `transfer` con cifras **distintas de cero en los dos sentidos**.
- **❌ Mal:**
  - No aparece `latest handshake` → nunca se han saludado → [[Fase_3.7_Resolucion_Problemas#E3 · El túnel dice activo pero no pasa nada|caso E3]]
  - `0 B received` → tú envías, el servidor no responde → mismo caso

### **2 · EL SERVIDOR ESCUCHA**

```bash
sudo ss -ulnp | grep 51820
```

- **Qué hace:** lista los puertos **UDP** abiertos y qué proceso los ocupa.
- **Por qué la `u` y no la `t`:** WireGuard es **UDP**. Buscarlo con `-tlnp` (TCP) y concluir que no está es un error clásico.
- **✅ Bien:** una línea con `51820`.
- **❌ Mal:** vacío → el túnel no está levantado: `sudo wg-quick up wg0`.

### **3 · SOBREVIVE A UN REINICIO**

```bash
systemctl is-enabled wg-quick@wg0
```

- **Qué hace:** consulta si el túnel se levanta solo al encender la máquina.
- **✅ Bien:** `enabled`.
- **❌ Mal:** `disabled` → `sudo systemctl enable wg-quick@wg0`.

> [!danger] ⚠️ Este es el que más caro sale, y el más fácil de pasar por alto
> Hoy funciona porque lo levantaste tú a mano. Pero en la **Auditoría Final** harás que SSH escuche **solo por la VPN**. Si entonces el túnel no arranca solo, al primer reinicio te quedas **sin ninguna forma de entrar** salvo la ventana de VirtualBox.
>
> Un `enabled` no cuesta nada hoy y te ahorra una tarde dentro de tres semanas.

### **4 · LA BASE DE LAS FASES ANTERIORES SIGUE EN PIE**

```bash
ip -4 addr show | grep 10.10.10.10
hostname -f
```

- **Qué hace:** comprueba la IP fija de la Fase 1 y el nombre completo de la Fase 2.
- **Por qué aquí:** el túnel **viaja por dentro** de la red de la Fase 1, y el dominio de la Fase 4 se construirá sobre ese nombre. Si algo se rompió mientras trabajabas, el momento de verlo es **ahora**, no dentro de tres fases.
- **✅ Bien:** aparece `10.10.10.10/24`, y `hostname -f` devuelve `UbuntuServer.BOOCHANLAB.LOCAL`.
- **❌ Mal:** → [[Fase_1.7_Resolucion_Problemas#E5 · Mi servidor no tiene la IP 10.10.10.10|Fase 1, caso E5]] o [[Fase_2.7_Resolucion_Problemas#E7 · hostname -f no devuelve el nombre completo|Fase 2, caso E7]].

### **5 · DESDE TU EQUIPO WINDOWS**

```
ping 10.20.20.1
```

- **Qué hace:** envía paquetes al servidor **por dentro del túnel**.
- **Por qué desde ahí:** es el único sitio donde se prueba la VPN **de extremo a extremo**. Todo lo anterior lo has comprobado desde dentro del servidor, y un servidor siempre te dirá lo que él cree de sí mismo.
- **✅ Bien:** cuatro respuestas.

> [!warning] ⚠️ Este ping funciona en un sentido, pero NO al revés
> Desde el servidor, `ping 10.20.20.2` hacia tu Windows **fallará aunque todo esté perfecto**: Windows descarta el ICMP entrante por defecto. Es un **falso negativo**, no un problema.
> El porqué está en [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]].

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los cinco puntos de arriba tú, comando a comando, entendiendo qué dice cada uno. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.
>
> El script sirve **después**, para confirmar que no se te ha escapado nada. Es la red de seguridad de quien ya ha hecho el trabajo, no un atajo para saltárselo.

> [!example] Cómo se descarga y se ejecuta
> **1. Descárgalo directamente en el servidor:**
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase3.sh
> ```
>
> **2. Dale permiso de ejecución** *(un fichero recién descargado no puede ejecutarse hasta que se lo das)*:
> ```bash
> chmod +x verificar_fase3.sh
> ```
>
> **3. Ejecútalo:**
> ```bash
> sudo ./verificar_fase3.sh
> ```
>
> **4. Sube el informe** `verificacion-fase-3.txt` a tu repositorio, junto con la entrada de apuntes.

> [!info] 🌐 ¿Qué es `curl` y por qué esa dirección tan rara?
> **`curl` es un navegador sin ventana.** Descarga una dirección de internet desde la línea de comandos. Viene instalado en Ubuntu Server; si no lo tuvieras:
> ```bash
> sudo apt install -y curl
> ```
>
> **Lo de `raw.githubusercontent.com`.** Cuando ves un fichero en GitHub, lo ves **envuelto** en su página web: menús, botones, colores. Si descargaras esa dirección, te bajarías la página entera, no el fichero.
>
> GitHub ofrece una segunda dirección que devuelve **el fichero desnudo**. Se construye con dos cambios:
>
> | | Dirección |
> | :--- | :--- |
> | **Página web** | `github.com/sor-iesjj/…/**blob**/main/99_Recursos/verificar_fase3.sh` |
> | **Fichero crudo** | `**raw.githubusercontent.com**/sor-iesjj/…/main/99_Recursos/verificar_fase3.sh` |
>
> 1. `github.com` → `raw.githubusercontent.com`
> 2. Desaparece el `/blob/`
>
> **Funciona sin usuario ni contraseña porque el repositorio del curso es público.** Si fuera privado, `curl` recibiría un error de permisos y habría que autenticarse.
>
> **¿Y por qué no clonar el repositorio en el servidor?** Porque traería **cientos de ficheros** del material para usar **uno solo** de 9 KB. Además, el repositorio lo clonaste en tu **Windows**, para leer los apuntes en Obsidian: en el servidor no está.
>
> **La `-O` mayúscula** significa *"guárdalo con el mismo nombre que tiene en el servidor"*. Con `-o` minúscula podrías darle otro.

> [!question] 🤔 Antes de seguir: léelo
> ```bash
> less verificar_fase3.sh
> ```
> *(Se sale con la tecla `q`.)*
>
> **Un administrador nunca ejecuta con `sudo` un script que no ha leído.** Aquí sabes de dónde viene, pero acostúmbrate igual.
>
> Anota en tu entrada **dos comprobaciones que hace el script y que tú no habías hecho a mano**.

---

## 💾 PARTE 2 — El punto de control

> [!important] 💾 Ahora sí: guarda el estado
> **Solo si las cinco verificaciones han salido bien.** Con la grabación todavía en marcha, apaga la máquina:
>
> ```bash
> sudo poweroff
> ```
>
> En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 3 terminada`**.
>
> Por comando, si el botón no aparece:
> ```
> VBoxManage snapshot "UbuntuServer" take "Fase 3 terminada"
> ```
>
> Y comprueba que se ha creado:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```

> [!tip] 💡 Por qué la instantánea va aquí y no al final de la fase
> Las preguntas del apartado 9 son trabajo de mesa y puedes tardar días. La instantánea cierra el **trabajo de máquina** mientras lo tienes fresco y la VM en la mano.
>
> Y hay una segunda razón: en el apartado 10 vas a **romper cosas a propósito** para entender qué detecta cada comprobación. Esta instantánea es la red de seguridad que te permite hacerlo sin miedo.

> Cómo se hace paso a paso, cómo verificar que existe y qué NO conserva: [[Fase_0.S_Instantaneas_Puntos_de_Control]]

---

### ✅ Checklist de este apartado

- [ ] `sudo wg show` → handshake reciente y tráfico en los dos sentidos.
- [ ] `sudo ss -ulnp` → el `51820` ocupado.
- [ ] `systemctl is-enabled wg-quick@wg0` → `enabled`.
- [ ] `10.10.10.10` presente y `hostname -f` correcto.
- [ ] `ping 10.20.20.1` responde **desde Windows**.
- [ ] *(Opcional)* Script ejecutado, leído, e informe subido al repositorio.
- [ ] 💾 **Instantánea `Fase 3 terminada`** tomada, con la VM apagada y **grabándolo**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.7_Resolucion_Problemas]] | [[Fase_3]] | [[Fase_3.9_Preguntas]] |
