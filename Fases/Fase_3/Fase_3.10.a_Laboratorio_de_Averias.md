## Fase 3 · Apartado 10.a — 🔨 Laboratorio de averías

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Después de la instantánea** del apartado 8.b. Aquí vas a **romper cosas a propósito**.

---

> [!danger] 🛑 REQUISITO: la instantánea `Fase 3 terminada` debe estar hecha
> Sin punto de retorno, no se rompe nada. Compruébalo antes de empezar:
> ```
> VBoxManage snapshot "UbuntuServer" list
> ```
> Si no aparece, vuelve a [[Fase_3.8.b_Punto_de_Control]].

> [!info] 🤖 Vas a usar el verificador en cada avería
> Es el script que descargaste en [[Fase_3.8.a_Verificacion]]. Si no lo tienes a mano:
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase3.sh
> chmod +x verificar_fase3.sh
> ```
> Allí está explicado qué es `curl` y por qué se descarga así.

---

> [!info] 🎓 Por qué se rompe algo que funciona
> Hasta ahora has comprobado que **todo va bien**. Y eso enseña la mitad.
>
> La otra mitad es saber **qué se ve cuando va mal**. Un técnico no se distingue por montar sistemas: se distingue por **reconocer un síntoma** y saber de dónde viene.
>
> Cada avería de aquí es un **ciclo de tres pasos**:
>
> **Romper** → **Comprobar que se detecta** → **Arreglar y confirmar**
>
> No estás perdiendo el tiempo: estás aprendiendo a leer un sistema roto **en condiciones controladas**, en vez de la primera vez que te pase de verdad y con prisa.

> [!tip] 💡 Cómo trabajarlo
> - **Predice antes de ejecutar.** Escribe en tu entrada qué crees que va a pasar. Acertar no puntúa; **haber pensado, sí**.
> - Después de cada rotura, pasa el verificador y mira **qué línea cambia de color**.
> - Arregla y confirma antes de pasar a la siguiente.
> - **Grábalo.** Este apartado es de lo mejor que puedes enseñar en el vídeo.

---

### **AVERÍA 1 · BAJAR EL TÚNEL**

**Romper:**
```bash
sudo wg-quick down wg0
```

**Comprobar:**
```bash
sudo wg show
sudo ss -ulnp | grep 51820
```

- **🤔 Predice:** ¿el fichero de configuración sigue existiendo? ¿Y el túnel?
- **Qué verás:** `wg show` no devuelve nada. El puerto `51820` desaparece.
- **La lección:** **configurado no es lo mismo que funcionando.** El `wg0.conf` sigue ahí, intacto y perfecto. Pero nadie lo está ejecutando. Es la misma diferencia que entre tener un contrato de luz y tener la luz encendida.

**Arreglar:**
```bash
sudo wg-quick up wg0
```

> [!warning] ⏱️ Espera medio minuto antes de dar por bueno el arreglo
> Al levantar el túnel, los contadores se ponen a cero y **el cliente tarda unos segundos en volver a saludar** — hasta 25, por el `PersistentKeepalive`.
>
> Si verificas de inmediato verás *"nunca hubo handshake"* y creerás que lo has roto del todo. **No es un fallo: es que aún no ha llegado el saludo.**

---

### **AVERÍA 2 · QUITAR LA PERSISTENCIA**

**Romper:**
```bash
sudo systemctl disable wg-quick@wg0
```

**Comprobar:**
```bash
systemctl is-enabled wg-quick@wg0
sudo wg show
```

- **🤔 Predice:** ¿deja de funcionar el túnel ahora mismo?
- **Qué verás:** `is-enabled` dice `disabled`… **pero `wg show` sigue funcionando perfectamente.**
- **La lección:** esta es **la avería más peligrosa de todo el itinerario**, porque **no se nota**. El túnel funciona hoy, funciona esta tarde, funciona toda la semana. Y el día que reinicies, no arranca.

  Y para entonces —si ya has hecho la Auditoría Final— SSH solo escuchará por el túnel: **te quedas fuera de tu propio servidor**.

> [!danger] 💣 Consecuencias, por plazos
> | Cuándo | Qué pasa |
> | :--- | :--- |
> | **Hoy** | **Nada.** Cero síntomas. El túnel va perfecto |
> | **Al primer reinicio** | El túnel no levanta. Si ya hiciste la Auditoría Final y SSH solo escucha por la VPN, **pierdes el acceso remoto**: solo entras por la ventana de VirtualBox |
> | **En una empresa** | Un corte de luz de 30 segundos se convierte en horas de incidencia. Los servicios que "estaban funcionando" no vuelven — y quien lo montó ya no trabaja allí |
>
> **Lo que dice el verificador:** `[FALLO] D1` en rojo. **Él sí lo ve, aunque tú no lo notes.**

**Arreglar:**
```bash
sudo systemctl enable wg-quick@wg0
```

> [!question] 🤔 Para tu entrada
> ¿Qué otras averías se te ocurren que **funcionen hoy y fallen al reiniciar**? Piensa en cosas que hayas hecho a mano en las Fases 1 y 2.

---

### **AVERÍA 3 · ROMPER LA MÁSCARA DEL CLIENTE**

> Antes de tocar nada, **copia de seguridad**. Es lo que hace un administrador antes de editar un fichero de configuración:
> ```bash
> sudo cp /etc/wireguard/wg0.conf /tmp/wg0.conf.bak
> ```

**Romper** — cambia el `/32` del peer por `/24`:
```bash
sudo nano /etc/wireguard/wg0.conf
```
```ini
AllowedIPs = 10.20.20.0/24
```
Y recarga el túnel:
```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

**Comprobar:**
```bash
sudo wg show
```

- **🤔 Predice:** ¿se cae el túnel?
- **Qué verás:** **el túnel sigue funcionando.** Handshake, tráfico, todo normal.
- **La lección:** **hay errores que no dan error.** Con un solo cliente el fallo no se nota; con dos, el servidor no sabría a cuál enviar cada paquete y aparecerían cortes intermitentes que nadie relacionaría con este fichero.

  Son los peores: los que se manifiestan **más tarde, en otro sitio y de forma aleatoria**.

> [!danger] 💣 Consecuencias, por plazos
> | Cuándo | Qué pasa |
> | :--- | :--- |
> | **Hoy, con un cliente** | **Nada** |
> | **En la Fase 8, con el cliente Windows 11** | Los **dos** peers reclaman el mismo rango. WireGuard enruta hacia el último que coincida: el tráfico de un cliente **puede irse al otro**. Uno de los dos deja de responder, y cambia según quién haya saludado el último |
> | **En una VPN de empresa** | Es el clásico *"a veces no me va la VPN"* **sin patrón reproducible**. Y no hay ningún error en ningún registro que lo delate |
>
> **Lo que dice el verificador:** `[FALLO] C2` en rojo.
>
> ⚠️ **Esta es la más traicionera de todas:** el síntoma aparece **dos fases más tarde**, cuando ya nadie recuerda haber tocado esta línea.

**Arreglar:**
```bash
sudo cp /tmp/wg0.conf.bak /etc/wireguard/wg0.conf
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

---

### **AVERÍA 4 · METER UN `Endpoint` EN EL SERVIDOR**

**Romper** — añade esta línea dentro del bloque `[Peer]` del **servidor**:
```ini
Endpoint = 10.10.10.1:51820
```

**Comprobar:**
```bash
sudo cat /etc/wireguard/wg0.conf
```

- **🤔 Predice:** parece razonable, ¿no? Si el cliente lleva `Endpoint`, ¿por qué no el servidor?
- **La lección:** **la regla de oro de WireGuard** — en cada fichero, `[Interface]` habla **de ti** y `[Peer]` habla **del otro**.

  El servidor no necesita `Endpoint` porque **lo aprende solo**: en cuanto recibe un saludo válido, anota de dónde vino y responde ahí. Eso permite que el cliente cambie de red o de Wi-Fi sin tocar nada en el servidor.

  El cliente sí lo necesita, porque **alguien tiene que dar el primer paso** y saber a qué puerta llamar.

**Arreglar:** borra la línea y recarga el túnel.

---

### **AVERÍA 5 · ABRIR LOS PERMISOS DEL FICHERO**

**Romper:**
```bash
sudo chmod 644 /etc/wireguard/wg0.conf
```

**Comprobar:**
```bash
ls -l /etc/wireguard/wg0.conf
sudo wg show
```

- **🤔 Predice:** ¿afecta al funcionamiento?
- **Qué verás:** **absolutamente nada.** El túnel va igual de bien.
- **La lección:** ese fichero contiene **la clave privada de tu servidor**. Con `644`, **cualquier usuario de la máquina puede leerla** — y con esa clave se puede suplantar a tu servidor en la red.

  Un fallo de seguridad **no se manifiesta como un fallo de funcionamiento**. Por eso existen las auditorías: si esperas a que algo deje de ir, nunca lo encontrarás.

> [!danger] 💣 Consecuencias, por plazos
> | Cuándo | Qué pasa |
> | :--- | :--- |
> | **Hoy, en tu laboratorio** | **Nada**, y con un solo usuario el riesgo es casi teórico |
> | **En un servidor con varios usuarios** | Cualquiera lee la **clave privada del servidor**. Con ella puede **hacerse pasar por tu servidor** desde otra máquina: tus clientes conectarían al impostor creyendo que es el legítimo |
> | **Al clonar o entregar la máquina** | 🔴 **Aquí deja de ser teórico.** En el ejercicio [[Fase_1.6.f_Procedimiento_Clonar_e_Intercambiar]] entregas tu VM a un compañero. Con los permisos abiertos, **le entregas la clave privada dentro** |
>
> **Lo que dice el verificador:** `[AVISO] C3` en amarillo.
>
> > [!info] 🔐 Un matiz que conviene saber
> > WireGuard tiene *forward secrecy*: usa claves temporales distintas en cada sesión. Así que **el tráfico ya capturado NO se puede descifrar** aunque roben esa clave.
> >
> > Lo que sí permite es **suplantar de ahí en adelante**. Es robo de identidad, no de historial. Grave igual, pero conviene saber exactamente qué se pierde.

**Arreglar:**
```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

---

### **AVERÍA 6 · DESCONECTAR EL CLIENTE**

> Esta se hace **en Windows**, no en el servidor.

**Romper:** en la aplicación de WireGuard, pulsa **`Desactivar`**.

**Comprobar** — en el servidor:
```bash
sudo wg show
```

- **🤔 Predice:** ¿desaparece el peer de la lista?
- **Qué verás:** el peer **sigue apareciendo**, con su clave y sus `AllowedIPs`. Lo que envejece es el `latest handshake`.
- **La lección:** el servidor **no sabe** que el cliente se ha ido. Nadie le avisa. Solo sabe **cuánto hace que no le habla**.

  Así funcionan casi todos los sistemas en red: no hay una desconexión limpia, hay **silencio** — y alguien decidiendo cuánto silencio es demasiado.

**Arreglar:** pulsa **`Activar`** y espera unos segundos.

---

> [!success] ✅ Deja el sistema como estaba
> Al terminar las seis, pasa el verificador y comprueba que **todo vuelve a estar en verde**:
> ```bash
> sudo ./verificar_fase3.sh
> ```
>
> Si algo no vuelve a su sitio, **restaura la instantánea `Fase 3 terminada`** y listo. Para eso está.

> [!important] 🎯 La lección que une las averías 2, 3 y 5
> En las tres, **el sistema sigue funcionando perfectamente**. No hay error, no hay log, no hay síntoma.
>
> Y en las tres, **el verificador las detecta**.
>
> Ese es exactamente el motivo de que exista una herramienta de comprobación de estado: **"funciona" no es lo mismo que "está bien"**. Si esperas a que algo deje de ir para revisarlo, estos tres fallos no los encuentras nunca — los encuentras el día que explotan, que siempre es el peor.

> [!question] 📝 Lo que va a tu entrada de apuntes
> 1. De las seis averías, **¿cuáles NO se notaban?** ¿Por qué son las más peligrosas?
> 2. La avería 2 y la 5 tienen algo en común. ¿Qué es?
> 3. En la avería 3, el túnel siguió funcionando con la configuración mal. **¿Cómo detectarías tú un fallo así en un sistema que no has montado tú?**
> 4. ¿Qué avería te ha sorprendido más y por qué?

---
---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.9_Preguntas]] | [[Fase_3]] | [[Fase_3.10.b_Auditoria_y_Cierre]] |
