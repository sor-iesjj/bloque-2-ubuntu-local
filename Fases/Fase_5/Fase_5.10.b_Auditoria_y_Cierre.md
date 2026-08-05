## Fase 5 · Apartado 10.b — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la Fase 6 sin repasarlo.

---

> [!caution] 🛑 Qué se audita en esta fase
> Que los usuarios **existen, son visibles y tienen los números correctos**. Las tres cosas, y la tercera es la que se olvida.
>
> Un usuario puede estar impecable en el dominio y ser inservible en Linux. Y puede ser visible en Linux con un número que no es el suyo. Eso no se nota hasta la Fase 7, cuando los permisos no alcancen a nadie.

---

## **1 · EL TRADUCTOR**

- [ ] `wbinfo -p` → **responde**.
- [ ] `getent passwd hiroshi.nohara` → **lo resuelve**.
- [ ] `systemctl is-active winbind` → **`inactive`** *(correcto en un AD DC: winbindd va dentro de samba)*.
- [ ] `/etc/nsswitch.conf` con `winbind` en las líneas `passwd` **y** `group`.

## **2 · LOS SEIS DEPARTAMENTOS**

- [ ] `facturacion` → GID **`3001`** · `contabilidad` → **`3002`** · `comercial` → **`3003`**
- [ ] `logistica` → GID **`3004`** · `rrhh` → **`3005`** · `becarios` → **`3006`**
- [ ] Cada uno con **exactamente dos miembros**, los del escenario.

```bash
for g in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "--- $g  (GID $(getent group $g | cut -d: -f3))"
    sudo samba-tool group listmembers "$g"
done
```

## **3 · 🔴 LAS DOCE IDENTIDADES UNIX**

- [ ] Los **doce** trabajadores con UID **`10001`** a **`10012`**, **exactamente** los de [[Escenario_Boochan_SL]].
- [ ] Cada uno con **su departamento en `groups=`** *(el `gid=` primario es `100(users)`: normal en AD)*.
- [ ] **Ningún UID repetido.**
- [ ] Los dos becarios **solo** en `becarios`, en ningún departamento operativo.
- [ ] `sudo samba-tool user list` **no** muestra `prueba.temporal` ni `duplicado.temporal` *(los del laboratorio)*.

```bash
for u in hiroshi.nohara nene.sakurada misae.nohara toru.kazama \
         masao.sato ai.suotome bo.suzuki midori.yoshinaga \
         ume.matsuzaka bunta.takakura shinnosuke.nohara himawari.nohara; do
    printf '%-20s ' "$u"; id "$u" 2>/dev/null || echo "NO SE ENCUENTRA"
done
```

> [!danger] ⚠️ Si algún UID no es el del escenario, PARA AQUÍ
> No es un detalle: es el fallo que hace fracasar la Fase 7 sin dar ninguna pista. Arréglalo ahora con el [[Fase_5.7_Resolucion_Problemas#E7 · Los UID no son los del escenario|caso E7]] y vuelve a tomar la instantánea.

## **4 · LA BASE DE LA FASE 4 SIGUE EN PIE**

- [ ] `systemctl is-active samba-ad-dc` → **`active`**.
- [ ] `sudo samba-tool domain level show` responde sin errores.
- [ ] `host -t A ubuntuserver.boochanlab.local 127.0.0.1` → **`10.10.10.10`**.

## **5 · EL LABORATORIO DE AVERÍAS** *(entrega 3)*

- [ ] Las **seis averías** provocadas y reparadas, **en dos sesiones** (1-3 visibilidad, 4-6 fallos silenciosos).
- [ ] **Predicción escrita antes** de cada una.
- [ ] Verificador pasado al final: **`FASE 5 SUPERADA`**.

## **6 · LAS COPIAS**

- [ ] 💾 Instantánea **`Fase 5 terminada`** tomada **con la VM apagada** y comprobada con `VBoxManage snapshot "UbuntuServer" list`.
- [ ] 💿 **`B2-F5-gestion-de-identidades.ova`** en `SOR/Bloque_2/Fases/Fase_5/` de tu **disco externo**.

## **7 · LA ENTREGA**

- [ ] Las **tres entradas** de apuntes, con sus **tres enlaces de vídeo**.
- [ ] Preguntas críticas contestadas.
- [ ] `commit` y `push` hechos.

> [!danger] 🛑 Si falta una pieza, la fase no se corrige
> No hay entregas parciales. Repásalo con [[Fase_5.2_Entregables]] delante antes de entregar.

---

> [!summary] 🎓 Qué has aprendido en la Fase 5
> Que **un usuario de dominio no es un usuario de Linux** hasta que alguien los traduce, y que ese alguien tiene nombre: `winbind`. Sin él, las cuentas existen y no sirven.
>
> Que **existir y ser visible son cosas distintas**, y que hay dos formas de romper la visibilidad —el traductor parado y el traductor ignorado— que producen **el mismo síntoma**. Aprendiste a separarlas comparando `wbinfo` con `getent`, que es la técnica de diagnóstico de la fase.
>
> Que **en Unix la identidad es un número, no un nombre.** El nombre es una etiqueta que se consulta en una tabla; el número es lo que se guarda en cada fichero y en cada registro. Por eso dos usuarios con el mismo UID son, para el sistema, la misma persona.
>
> Que hay decisiones que **solo se pueden tomar al crear algo**: el `--use-rfc2307` de la Fase 4 era una palabra en una línea, y sin ella esta fase entera es imposible.
>
> Y otra vez, porque es la lección que más caro sale: **el fallo que no da error es el caro.** Un usuario creado sin `--uid-number` funciona hoy, funciona mañana, y deja sus ficheros huérfanos el día que rehagas el dominio. Por eso se verifica **antes** de guardar, y por eso la verificación mira los números y no solo los nombres.
>
> **Siguiente:** Fase 6 — Almacenamiento y cuotas.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.10.a_Laboratorio_de_Averias]] | [[Fase_5]] | **Fase 6** |
