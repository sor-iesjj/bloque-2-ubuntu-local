## Fase 3 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 4 sin esto.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el túnel **existe, funciona y sobrevive a un reinicio**. Las llaves privadas son la **identidad** de tu servidor: quien las copie podrá entrar como si fuera él.
>
> Y algo que se te olvidará si no lo miras ahora: un túnel que funciona hoy pero **no arranca solo** deja tu servidor inaccesible más adelante, cuando SSH solo escuche por la VPN.

---

## 🤖 La forma rápida: el verificador automático

> [!success] ✅ Un comando lo comprueba todo
> En el repositorio del curso tienes un script que revisa los diez puntos de control de golpe y escribe un informe.
>
> **1. Ve a la carpeta de recursos** *(la que clonaste en la Fase 0.4)*:
> ```bash
> cd ~/boochan-v1/99_Recursos
> ```
>
> **2. Dale permiso de ejecución** *(solo la primera vez)*:
> ```bash
> chmod +x verificar_fase3.sh
> ```
>
> **3. Ejecútalo:**
> ```bash
> sudo ./verificar_fase3.sh
> ```
> Pedirá tu contraseña una vez. **No modifica nada: solo lee.**
>
> **4. Sube el informe** `verificacion-fase-3.txt` a tu repositorio, junto con la entrada de apuntes.

> [!info] 📄 Qué verás
> ```
> [OK]    A1. IP 10.10.10.10 presente (Fase 1)
> [OK]    B2. Handshake correcto (hace 42s)
> [FALLO] D1. wg-quick@wg0 NO habilitado - al reiniciar NO habra tunel
> ============================================================
>  VEREDICTO: FASE 3 NO SUPERADA - 1 FALLO(S)
> ```
> Cada fallo te dice **qué caso** mirar en [[Fase_3.7_Resolucion_Problemas]].

> [!warning] ⚠️ El script no lo comprueba todo
> Corre **dentro del servidor**, así que hay dos cosas que solo puedes verificar tú, en tu equipo Windows. Están en el apartado 3 de más abajo. **No las saltes.**

---

## 🔍 Los puntos de control, uno a uno

> Esto es lo que comprueba el script. Léelo aunque te haya salido todo `OK`: **en el vídeo tienes que explicar qué significa cada uno**, no solo enseñar que pone OK.

### **1 · LA BASE DE LAS FASES ANTERIORES**

> [!question] ¿Por qué se comprueba esto en la Fase 3?
> Porque el túnel **viaja por dentro** de la red que montaste en la Fase 1. Si esa red se rompió, el túnel puede parecer correcto y aun así fallar todo lo que venga después.
>
> Se diagnostica **siempre de abajo hacia arriba**.

**1A — La IP del laboratorio**
```bash
ip -4 addr show | grep 10.10.10.10
```
- **Qué hace:** busca la IP fija de la Fase 1 en las tarjetas de red.
- **✅ Bien:** aparece `10.10.10.10/24`.
- **❌ Mal:** no aparece → tu túnel no tiene por dónde viajar. Ve a [[Fase_1.7_Resolucion_Problemas#E5 · Mi servidor no tiene la IP 10.10.10.10|Fase 1, caso E5]].

**1B — El nombre completo del servidor**
```bash
hostname -f
```
- **Qué hace:** pregunta el nombre completo (FQDN).
- **✅ Bien:** `UbuntuServer.BOOCHANLAB.LOCAL`.
- **❌ Mal:** devuelve solo `UbuntuServer` → ve a [[Fase_2.7_Resolucion_Problemas#E7 · hostname -f no devuelve el nombre completo|Fase 2, caso E7]]. **Arréglalo antes de la Fase 4**, que construye el dominio sobre ese nombre.

### **2 · EL TÚNEL**

**2A — El saludo criptográfico *(el punto más importante)***
```bash
sudo wg show
```
- **Qué hace:** muestra el estado del túnel y de cada cliente conectado.
- **Por qué:** es **la única prueba real** de que funciona. WireGuard **descarta en silencio** los paquetes de quien no reconoce: puedes tener un túnel que dice "activo" y no transmite nada.
- **✅ Bien:** `latest handshake` de hace menos de 3 minutos, y `transfer` con cifras **distintas de cero en los dos sentidos**.
- **❌ Mal:**
  - **No aparece `latest handshake`** → nunca se han saludado. Llaves cruzadas → [[Fase_3.7_Resolucion_Problemas#E3 · El túnel dice activo pero no pasa nada|caso E3]].
  - **`0 B received`** → tú envías, el servidor no responde. Mismo caso.

**2B — El puerto**
```bash
sudo ss -ulnp | grep 51820
```
- **Qué hace:** lista los puertos **UDP** abiertos.
- **Por qué la `u`:** WireGuard es **UDP**, no TCP. Buscarlo con `-tlnp` y concluir que no está es un error clásico.
- **✅ Bien:** una línea con `51820`.
- **❌ Mal:** vacío → el túnel no está levantado: `sudo wg-quick up wg0`.

### **3 · LO QUE SOLO PUEDES COMPROBAR TÚ**

> [!danger] 🛑 El script no llega aquí. Hazlo en tu equipo Windows.

**3A — El ping desde el cliente**
```
ping 10.20.20.1
```
- **Qué hace:** envía paquetes al servidor **por dentro del túnel**.
- **✅ Bien:** cuatro respuestas.
- **❌ Mal:** sin respuesta → vuelve al punto 2A.

> [!warning] ⚠️ Este ping funciona en un sentido, pero NO al revés
> Desde el servidor, `ping 10.20.20.2` hacia tu Windows **fallará aunque todo esté bien**: Windows descarta el ICMP entrante por defecto. Es un **falso negativo**, no un problema.
> El porqué está en [[Fase_1.6.e_Procedimiento_Acceso_Desde_Otro_Equipo]].

**3B — La máscara de tu cliente**
- **Dónde:** en la app de WireGuard, campo `Address` del bloque `[Interface]`.
- **✅ Bien:** `10.20.20.2/32`.
- **❌ Mal:** cualquier otra cosa (`/24`, `/25`…).
- **Por qué:** `/32` significa *"soy exactamente esta dirección y ninguna más"*. Con otra máscara le dices al sistema que eres **muchas** direcciones, y el enrutado queda ambiguo. **El túnel puede levantar igual** y darte fallos intermitentes después — de los peores, porque no los relacionas con esto.

### **4 · LA PERSISTENCIA**

**4A — ¿Arranca solo?**
```bash
systemctl is-enabled wg-quick@wg0
```
- **Qué hace:** consulta si el túnel se levanta al encender la máquina.
- **✅ Bien:** `enabled`.
- **❌ Mal:** `disabled` → `sudo systemctl enable wg-quick@wg0`.

> [!danger] ⚠️ Este es el que más caro sale
> Hoy funciona porque lo levantaste a mano. Pero en la **Auditoría Final** harás que SSH escuche **solo por la VPN**. Si entonces el túnel no arranca solo, al primer reinicio te quedas **sin ninguna forma de entrar** salvo la ventana de VirtualBox.
>
> Compruébalo de verdad: reinicia con `sudo reboot` y vuelve a lanzar `sudo wg show`.

---

## ✅ Checklist final: no pases a la Fase 4 sin esto

> [!success] Antes de dar la fase por terminada
> **El túnel**
> - [ ] `sudo wg show` muestra **handshake reciente** y tráfico en los dos sentidos.
> - [ ] `sudo ss -ulnp` muestra el **51820** ocupado.
> - [ ] `ping 10.20.20.1` responde **desde Windows**.
> - [ ] El `Address` del cliente es **`/32`**.
>
> **La persistencia**
> - [ ] `systemctl is-enabled wg-quick@wg0` devuelve **`enabled`**.
> - [ ] Comprobado **reiniciando de verdad**, no solo leyendo el comando.
>
> **La base**
> - [ ] `10.10.10.10` sigue presente · `hostname -f` sigue correcto.
>
> **La entrega**
> - [ ] Informe `verificacion-fase-3.txt` generado y **subido al repositorio**.
> - [ ] 💾 Instantánea **`Fase 3 terminada`** tomada con la VM apagada, y **grabándolo**.
> - [ ] Entrada de apuntes con el enlace del vídeo · preguntas contestadas · `commit` y `push`.

> [!important] 🔓 SSH sigue como estaba. No lo toques todavía
> Sigues entrando con `ssh boochan@10.10.10.10`.
>
> Restringir el acceso al túnel se hace en la **[[Auditoria_Final]]**, cuando ya sepas que el túnel es fiable. Anótalo en tu entrada como **puerta pendiente de cerrar**: un administrador lleva la cuenta de las que deja abiertas.

> [!summary] 🎓 Qué has aprendido en la Fase 3
> Que una VPN es **una red construida encima de otra**, y que si la de abajo falla, la de arriba no puede funcionar.
>
> Que **"activo" no significa "funcionando"**: el handshake es el único dato que no miente.
>
> Que un sistema que **ignora en silencio** a quien no reconoce está haciendo bien su trabajo, aunque te complique el diagnóstico.
>
> Y que un servicio que funciona hoy pero **no arranca solo** es una avería aplazada.
>
> **Siguiente:** Fase 4 — Despliegue del Dominio.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.9_Preguntas]] | [[Fase_3]] | **Fase 4** |
