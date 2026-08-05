## Fase 4 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 5 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que el dominio **existe, responde y es localizable**. Las tres cosas, y la tercera es la que se olvida.
>
> Un dominio puede estar impecable por dentro y ser invisible desde fuera. Eso no se nota hasta la Fase 8, y para entonces habrás construido cuatro fases más encima.

---

## **1 · EL CONTROLADOR DE DOMINIO**

- [ ] `systemctl is-active samba-ad-dc` → **`active`**.
- [ ] `systemctl is-enabled samba-ad-dc` → **`enabled`**.
- [ ] `smbd`, `nmbd` y `winbind` → los tres **`inactive`**.

## **2 · EL DOMINIO RESPONDE**

- [ ] `sudo samba-tool domain level show` responde sin errores.
- [ ] El reino es **`BOOCHANLAB.LOCAL`**, y `grep default_realm /etc/krb5.conf` lo confirma **en mayúsculas**.
- [ ] `smb.conf` contiene `rfc2307` *(lo necesita la Fase 5 para dar identidad Unix a los usuarios)*.

## **3 · 🔴 EL DOMINIO ES LOCALIZABLE**

- [ ] `host -t A ubuntuserver.boochanlab.local 127.0.0.1` → **`10.10.10.10`**, y **NO** una `10.0.2.x`.
- [ ] `host -t SRV _kerberos._tcp.boochanlab.local 127.0.0.1` devuelve resultado.
- [ ] `host -t SRV _ldap._tcp.boochanlab.local 127.0.0.1` devuelve resultado.

> [!danger] ⚠️ Si la primera casilla falla, PARA AQUÍ
> No es un detalle: es el fallo que hace fracasar la Fase 8 sin dar ninguna pista. Arréglalo ahora con el [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5]] y vuelve a tomar la instantánea.

## **4 · EL DNS AGUANTA UN REINICIO**

- [ ] `/etc/resolv.conf` dice `nameserver 127.0.0.1`.
- [ ] `lsattr /etc/resolv.conf` muestra el atributo **`i`**.
- [ ] `getent hosts archive.ubuntu.com` responde *(el reenviador funciona)*.

## **5 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **seis averías** provocadas y reparadas, **en dos sesiones** (1-3 servicio y DNS, 4-6 fallos silenciosos).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Verificador pasado al final: **`FASE 4 SUPERADA`**.

## **6 · LAS COPIAS**

- [ ] 💾 Instantánea **`Fase 4 terminada`** tomada y comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F4-aprovisionamiento-del-dominio.ova`** en `SOR/Bloque_2/Fases/Fase_4/` de tu **disco externo**.

## **7 · LA ENTREGA**

- [ ] Las **cuatro entradas** de apuntes, con sus **cuatro enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_4.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 4
> Que un **dominio** no es un programa que se instala: es un servicio de directorio, un reino de autenticación y un servidor DNS **funcionando a la vez**. Parar uno es pararlos todos, como viste en la avería 1.
>
> Que **el DNS es la pieza que sostiene el dominio**, y que un controlador tiene que preguntarse a sí mismo por lo suyo y reenviar lo demás. Un servidor que resuelve el mundo entero menos a sí mismo no le sirve a nadie.
>
> Que hay ficheros que el sistema **reescribe por su cuenta**, y que cambiarlos no basta: hay que impedir que los toquen. `chattr +i` fue la primera vez que te encontraste algo que ni `root` puede hacer.
>
> Que **`samba` y `samba-ad-dc` no conviven**, y que la misma comprobación que en la Fase 2 era "está encendido, bien" aquí es "está encendido, mal". **Se verifica contra el estado que toca, no contra una lista fija.**
>
> Y por encima de todo, lo que enseña la avería 4: **el fallo que no da error es el caro.** Un dominio anunciado en la tarjeta equivocada funciona hoy, funciona mañana, y revienta dentro de tres semanas con un mensaje que no apunta aquí. Por eso se verifica **antes** de guardar, y por eso la verificación mira exactamente eso.
>
> **Siguiente:** Fase 5 — Gestión de Identidades (usuarios y grupos).

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.10.a_Laboratorio_de_Averias]] | [[Fase_4]] | **Fase 5** |
