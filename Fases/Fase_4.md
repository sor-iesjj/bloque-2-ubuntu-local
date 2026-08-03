	## 👑 Fase 4: Aprovisionamiento del Dominio (Samba AD DC)

### Infraestructura de Servidor Local (VirtualBox)

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Integración de Sistemas Operativos - Servidor de Dominio]**
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** VM con 3072-4096 MB RAM asignados en VirtualBox (según la nota de dimensionado de la Fase 1) | Git | Samba disponible

---

> [!abstract] 📋 Qué se te evalúa en esta fase
> **Resultado de Aprendizaje — `RA.03`** *(pesa un **18 %** del módulo, el segundo más alto · UD6)*
> *Realiza tareas de gestión sobre dominios identificando necesidades y aplicando herramientas de administración.*
>
> Esta es **la fase central del RA.03**: toca **6 de sus 8 criterios**.
>
> | Código | Criterio de evaluación | Dónde lo demuestras aquí |
> | :--- | :--- | :--- |
> | `CE.03.a` | Se ha identificado la función del servicio de directorio, sus elementos y nomenclatura. | El fundamento teórico: qué es un directorio, y el porqué de `BOOCHANLAB` / `BOOCHANLAB.LOCAL` (NetBIOS y Realm) |
> | `CE.03.b` | Se ha reconocido el concepto de dominio y sus funciones. | Explicar en el vídeo qué gana el laboratorio al tener dominio frente a máquinas sueltas |
> | `CE.03.d` | Se ha realizado la instalación del servicio de directorio. | El aprovisionamiento de Samba AD DC |
> | `CE.03.e` | Se ha realizado la configuración básica del servicio de directorio. | `smb.conf`, el DNS interno y `resolv.conf` inmutable |
> | `CE.03.g` | Se ha analizado la estructura del servicio de directorio. | Recorrer el árbol del dominio recién creado y reconocer sus contenedores |
> | `CE.03.h` | Se han utilizado herramientas de administración de dominios. | `samba-tool` de principio a fin |
>
> **Los 2 que NO se evalúan aquí:** `CE.03.f` (agrupaciones para modelos administrativos) se trabaja en la **Fase 5** al crear las unidades organizativas; `CE.03.c` (relaciones de confianza entre dominios) **requiere dos dominios** y queda fuera del alcance de este laboratorio de un solo servidor.

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v1-fase-4-aprovisionamiento-del-dominio-samba-ad-d.md` dentro de `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 4 de Boochan V1 — Aprovisionamiento del Dominio (Samba AD DC)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V1 · Fase 4 — Aprovisionamiento del Dominio (Samba AD DC)`, súbelo a tu playlist de YouTube **`B2_Ubuntu_Local`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---


### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 3
> Tienes un servidor con identidad de dominio (`UbuntuServer.BOOCHANLAB.LOCAL`), accesible de forma cifrada a través de un túnel WireGuard (`10.20.20.1`). Ahora necesitas darle la funcionalidad de un verdadero **Controlador de Dominio** — el "cerebro" que gestiona usuarios, grupos, autenticación y autorización.

> [!warning] El Problema
> Sin un dominio, Windows 11 en tu laboratorio es un equipo aislado. Los usuarios se loguean localmente (usuario/contraseña guardados en el PC). No hay forma centralizada de gestionar identidades, no hay Single Sign-On, no hay políticas de grupo. Si necesitas cambiar la contraseña de un usuario, debes hacerlo en cada PC manualmente. Además, Kerberos (el protocolo de seguridad profesional) requiere un dominio para funcionar.

> [!success] Objetivo de esta Fase
> Provisionar **Samba AD DC** (Active Directory Domain Controller) en el servidor. Esto creará el dominio **`BOOCHANLAB`** (NetBIOS) / **`BOOCHANLAB.LOCAL`** (Realm) como un "reino" Kerberos con servicios interdependientes: LDAP (directorio), DNS interno (registros SRV), Kerberos (autenticación), y replicación. Desde ahora, los usuarios se autenticarán contra el dominio, no contra máquinas individuales.

> [!tip] Hoja de Ruta
> 1. Comprobar que no hace falta abrir ningún puerto en un firewall cloud (aquí no existe)
> 2. Ejecutar el script `provision_boochan.sh` adaptado a `BOOCHANLAB.LOCAL`, que automatiza la creación del dominio (tarda 2-3 minutos)
> 3. Verificar que el servicio `samba-ad-dc` está activo: `sudo systemctl status samba-ad-dc`
> 4. Comprobar que el DNS interno apunta a `127.0.0.1`: `cat /etc/resolv.conf`
> 5. Hacer inmutable `/etc/resolv.conf` con `chattr +i` para que `systemd-resolved` no lo rompa en reinicios
> 6. Validar que Kerberos funciona: `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL 127.0.0.1`
> 7. Listar usuarios creados automáticamente: `samba-tool user list` (verás Administrator, krbtgt, etc.)
>
> **Resultado Final:** Dominio `BOOCHANLAB.LOCAL` completamente provisionado y operativo. El servidor es ahora un verdadero Controlador de Dominio profesional, listo para que la futura VM Windows 11 se una a él.
> **Siguiente:** Fase 5 (Usuarios) — crearás usuarios del dominio (user1, user2) con mapeados correctos a Linux (UIDs/GIDs).

---

### 📚 Fundamento Teórico

> [!abstract] 1. El "Cerebro" de la Red: Active Directory (AD)
> Estamos creando el **Active Directory**. Este es el "Cerebro" que gestiona la base de datos de todos los objetos de la red: usuarios, grupos y ordenadores. Samba AD DC emula tres servicios vitales para que esto funcione:
> *   **LDAP:** El protocolo para consultar la base de datos de usuarios.
> *   **Kerberos:** El sistema de "tickets" de seguridad (como un pase VIP de un festival).
> *   **DNS Interno:** Samba gestiona sus propios registros SRV que indican dónde están los servicios de red.

> [!important] 2. Inmutabilidad y Persistencia (aquí también hace falta, aunque no haya "nube" de por medio)
> Podrías pensar que el problema de `resolv.conf` sobrescrito es exclusivo de la nube (Azure/AWS inyectando su propio DNS). **No es así.** Ubuntu Server 26.04 gestiona el DNS mediante `systemd-resolved` de forma nativa, tanto si la VM corre en AWS como si corre en tu VirtualBox local. Cada vez que la interfaz de red se reconfigura (por ejemplo, en cada arranque, al renovar la IP del adaptador NAT), `systemd-resolved` puede reescribir `/etc/resolv.conf` y borrar nuestra configuración manual. El comando `chattr +i` lo hace **inmutable** (imposible de borrar o cambiar ni por el propio root), garantizando que el servidor siempre se consulte a sí mismo (`127.0.0.1`) para resolver nombres del dominio.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Dominio
> - **Reino (Realm):** El nombre de dominio completo (ej. `BOOCHANLAB.LOCAL`). Siempre se escribe en **MAYÚSCULAS** para que Kerberos lo entienda.
> - **NetBIOS Domain:** El nombre corto del dominio (ej. `BOOCHANLAB`), usado por protocolos Windows heredados y como prefijo de inicio de sesión (`BOOCHANLAB\usuario`).
> - **Provisionamiento:** El acto de generar la base de datos del dominio desde cero.
> - **SRV Record:** Un registro DNS especial que indica qué servidor ofrece un servicio específico (ej. "el servidor de tickets está en esta IP").
> - **chattr +i:** El "cemento armado" de Linux. Hace que un archivo no se pueda modificar ni por el administrador.

---

### 🔓 Firewall Local: por qué esta fase no tiene sección de puertos cloud

> [!info] En BoochanV2/V3 aquí había 13 reglas que abrir en Azure/AWS — en local, cero
> Active Directory es un ecosistema de servicios que se hablan entre sí: Kerberos (88), DNS (53), LDAP (389/636), RPC (135 y el rango dinámico 49152-65535), SMB (445), cambio de contraseñas (464) y NTP (123). En las versiones cloud del proyecto, cada uno de esos puertos debía abrirse manualmente en el Security Group/NSG del proveedor, porque el tráfico entrante estaba bloqueado por defecto.
>
> **En tu Red Solo Anfitrión de VirtualBox no hay ningún firewall perimetral que bloquee ese tráfico entre VMs.** Todo el ecosistema de puertos de Active Directory funcionará entre el servidor (`10.10.10.10`) y la futura VM cliente Windows 11 sin que tengas que configurar nada adicional — el propio hecho de compartir el mismo segmento de Red Solo Anfitrión ya permite esa comunicación.
>
> > [!tip] 💡 ¿Merece la pena entender esos 13 puertos igualmente?
> > Sí, y mucho. Aunque aquí no los "abras" en ningún portal, siguen siendo los mismos puertos que un Controlador de Dominio real usa en producción. Cuando en el futuro despliegues un dominio en una red corporativa con firewall perimetral, necesitarás saber exactamente qué puertos pedir que se abran. Consulta la tabla de referencia de BoochanV3 (`SOR/BoochanV3/Fases/Fase_4.md`) si quieres repasar el propósito de cada uno — Kerberos (88), DNS (53), RPC (135), LDAP (389/636), SMB (445), RPC dinámico (49152-65535), cambio de contraseñas (464) y NTP (123).

---

### 🛠️ Procedimiento Práctico (BoochanV1)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v1-fase-4-aprovisionamiento-del-dominio-samba-ad-d.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Descarga del Proyecto y Ejecución del Script
> Para evitar errores humanos, usaremos el script `provision_boochan.sh`, adaptado para este laboratorio local con las variables `BOOCHANLAB` / `BOOCHANLAB.LOCAL`. Primero, descargamos el proyecto completo desde el repositorio usando `git`:
>
> > [!info] 📚 Diccionario de Comandos: Consulta el [[Diccionario_Comandos_Sistema]] para entender al detalle cómo funcionan los comandos administrativos que usaremos aquí.
>
> **1.** Instala `git` y clona el repositorio de la práctica dentro del servidor:
> ```bash
> sudo apt install git -y
> sudo git clone https://github.com/sor-iesjj/bloque-2-ubuntu-local /opt/boochan
> ```
>
> > [!warning] ⚠️ Que sea el de **V1 (Local)**
> > Los scripts `provision_boochan.sh` de V1, V2 y V3 se parecen muchísimo, pero los de la nube usan el realm **`BOOCHAN.SPACE`**. Si clonas el equivocado, el dominio no coincidirá con el `/etc/hosts` que configuraste en la Fase 2 y **nada encajará**.
> > El repositorio correcto es el que termina en **`bloque-2-ubuntu-local`**.
>
> **2.** Entra y **LEE EL SCRIPT ANTES DE EJECUTARLO**:
> ```bash
> cd /opt/boochan
> cat provision_boochan.sh
> ```
>
> > [!danger] 🛑 Esto no es una formalidad
> > Vas a ejecutar como **root** un fichero descargado de internet. Ahí dentro hay comandos que **borran ficheros del sistema** (`rm -f /etc/resolv.conf`) y que dejan otros **imposibles de modificar** (`chattr +i`).
> >
> > **Nunca ejecutes como root un script que no has leído.** Si un día alguien te pasa un `curl ... | sudo bash`, esa es exactamente la costumbre que te salva.
> >
> > Localiza en el `cat` estas cinco cosas y explícalas en el vídeo:
> > 1. Las variables del principio: `DOMAIN_NAME`, `REALM_NAME`, `ADMIN_PASS`.
> > 2. Qué le hace a `/etc/resolv.conf` y por qué.
> > 3. Qué significa `--use-rfc2307` *(pista: sin eso, la Fase 5 no funciona)*.
> > 4. Para qué está `--host-ip=10.10.10.10` *(pista: tu servidor tiene DOS tarjetas — ¿qué pasaría si Samba eligiera la otra?)*.
> > 5. Qué tres servicios apaga al final, y por qué estorban.
>
> **3.** Ahora sí, dale permiso de ejecución y lánzalo:
> ```bash
> sudo chmod +x provision_boochan.sh
> sudo ./provision_boochan.sh
> ```
>
> El script tardará **2-3 minutos**. Verás mensajes de progreso en pantalla.
>
> > [!tip] 💡 El script escribe mucho en pantalla — ¿cómo sé si va bien?
> > Es normal ver líneas amarillas e incluso algún aviso en rojo durante el proceso: son mensajes informativos de Samba, no errores reales. El script está preparado para **pararse él solo en cuanto algo falle de verdad**, diciéndote qué falta y cómo arreglarlo. La confirmación de éxito es este recuadro:
> > ```
> > ==========================================================
> >  Despliegue de BOOCHANLAB finalizado CORRECTAMENTE.
> > ==========================================================
> > ```
> > Si en su lugar ves una línea que empieza por `ERROR:` o por `!!!`, **lee lo que dice**: te indica exactamente qué instalar o qué revisar. No sigas al Paso 2 sin el recuadro de éxito.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`git clone`:** Descarga una copia completa del proyecto desde internet a tu servidor (usando el adaptador NAT para salir), igual que descargar un ZIP pero de forma más profesional. Necesita el adaptador **NAT** funcionando: la Red Solo Anfitrión no da salida a internet.
> > - **`chmod +x`:** En Linux, los archivos descargados no "tienen permiso" para ejecutarse por seguridad. Este comando le pone la etiqueta de **ejecutable**.
> > - **El punto y la barra (`./`):** Le dice a Linux: "Busca este archivo **aquí mismo**, en esta carpeta". Sin el `./`, Linux buscaría el comando en las carpetas del sistema y no lo encontraría.
> > - **Los valores por defecto del script:** El script ya viene configurado con los valores correctos de este proyecto (`BOOCHANLAB`, Realm `BOOCHANLAB.LOCAL`, contraseña `P@ssw0rd`). No necesitas modificar nada salvo que tu profesor indique lo contrario.
>
> > [!note] 📄 Mapa del script: las cinco secciones que verás en el `cat`
> > **La fuente de verdad es el script que acabas de clonar**, no este resumen — si difieren, manda el del repositorio. Esto es el mapa para no perderte al leerlo:
> >
> > | Sección | Qué hace | La línea clave |
> > | :--- | :--- | :--- |
> > | **0. Comprobaciones previas** | Verifica que estás como root y que los paquetes de la Fase 2 están instalados. **Si falta algo, para aquí** y te dice qué instalar | `dpkg -s samba-ad-dc samba-ad-provision` |
> > | **1. Aprovisionamiento** | Crea el dominio entero: directorio LDAP, Kerberos, DNS interno | `samba-tool domain provision ... --host-ip=10.10.10.10` |
> > | **2. Kerberos** | Instala el `krb5.conf` que acaba de generar el dominio | `cp /var/lib/samba/private/krb5.conf` |
> > | **3. Arranque del AD DC** | Apaga el Samba clásico y levanta el controlador de dominio | `systemctl enable --now samba-ad-dc` |
> > | **4. DNS persistente** | Apunta el servidor a sí mismo y bloquea el fichero para que nada lo sobrescriba | `chattr +i /etc/resolv.conf` |
> >
> > > [!question] 🤔 ¿Por qué el DNS se toca al FINAL y no al principio?
> > > Porque apuntar el servidor a `127.0.0.1` **solo tiene sentido cuando ya hay un DNS escuchando ahí** — y ese DNS es el de Samba, que no existe hasta la sección 3.
> > > Y hay un motivo más importante: si el aprovisionamiento falla, el servidor **conserva su resolución de nombres** y puedes seguir instalando paquetes para arreglarlo. Al revés, un fallo te dejaría sin DNS y sin poder instalar nada: encerrado fuera de tu propia máquina.
> > > **Regla general: lo que te puede dejar aislado, se hace al final y solo si todo lo demás ha ido bien.**
> >
> > Y una línea más, arriba del todo, que es la que hace al script digno de confianza: **`set -euo pipefail`** — aborta al primer error en vez de seguir adelante con todo roto. Un script de administración que no para cuando algo falla es un script que miente.
> >
> > El `DNS_FORWARDER=8.8.8.8` funciona así: cuando Samba no sabe resolver un nombre (porque no es del dominio), reenvía la consulta a Google DNS a través del adaptador NAT.

> [!example] Paso 2: Verificación de Servicios
> Una vez finalizado el script, debemos comprobar que el "corazón" del dominio está latiendo:
> ```bash
> # Comprobar que el servicio está activo y corriendo
> sudo systemctl status samba-ad-dc
> ```

> [!example] Paso 3: Verificación del DNS
> Es vital confirmar que el servidor se mira a sí mismo para resolver nombres de red:
> ```bash
> # Debe devolver: nameserver 127.0.0.1
> cat /etc/resolv.conf
> ```

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿El dominio no nace?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Error `Realm not found`. | El archivo `/etc/krb5.conf` no está bien configurado. | Copia el generado por Samba: `sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf`. |
> | No resuelve al `127.0.0.1`. | `systemd-resolved` está secuestrando el DNS. | Primero desbloquea el fichero: `sudo chattr -i /etc/resolv.conf` (sin esto, el siguiente `rm` falla con `Operation not permitted`). Luego `sudo rm /etc/resolv.conf`, reescribe: `echo "nameserver 127.0.0.1" \| sudo tee /etc/resolv.conf`, y vuelve a bloquear: `sudo chattr +i /etc/resolv.conf`. |
> | El script para con `ERROR: falta el paquete 'samba-ad-dc'` (o `samba-ad-provision`). | La Fase 2 se hizo con una versión antigua del material, o restauraste una instantánea anterior a su instalación. | Es el script **protegiéndote**: instala lo que pide — `sudo apt install -y samba-ad-dc samba-ad-provision` — y relánzalo. Recuerda restaurar el DNS primero si no tienes internet: `sudo chattr -i /etc/resolv.conf && echo "nameserver 8.8.8.8" \| sudo tee /etc/resolv.conf`. |
> | `host -t A ubuntuserver.boochanlab.local` devuelve una `10.0.2.x` en vez de `10.10.10.10`. | El dominio se aprovisionó sin `--host-ip` y Samba eligió la tarjeta NAT. El dominio "funciona"… pero nadie podrá encontrarlo, y la Fase 8 fallará con "No se encuentra el dominio". | **Borra el registro malo usando la IP exacta que te haya devuelto el `host`** (no la copies de aquí, mira la tuya) y añade el bueno:<br>`sudo samba-tool dns delete 127.0.0.1 boochanlab.local ubuntuserver A LA_IP_QUE_TE_SALIO -U Administrator`<br>`sudo samba-tool dns add 127.0.0.1 boochanlab.local ubuntuserver A 10.10.10.10 -U Administrator`<br>Vuelve a comprobar con `host`. |
> | El script falla en `git clone` por falta de red. | El adaptador NAT no está activo o `git` intenta usar la Red Solo Anfitrión (sin salida a internet). | Comprueba `ping 8.8.8.8` antes de clonar; revisa el adaptador NAT en `Configuración de la VM → Red`. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué es fundamental que el servidor DNS del dominio sea el propio servidor (`127.0.0.1`)?
> 2. ¿Qué es un "ticket" de Kerberos y por qué evita enviar contraseñas por la red constantemente?
> 3. ¿Qué pasaría si el atributo de inmutabilidad (`+i`) no estuviera activo en el `resolv.conf` tras reiniciar la VM, aunque no haya ningún proveedor cloud de por medio?
> 4. ¿Cuál es la diferencia entre el Realm (`BOOCHANLAB.LOCAL`) y el nombre NetBIOS (`BOOCHANLAB`) del dominio? ¿Cuándo se usa cada uno?
> 5. 🔬 **Reto práctico:** Ejecuta `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL 127.0.0.1` en el servidor. Si el dominio está bien provisionado, ¿qué IP debería devolver? Si no devuelve nada, ¿qué componente del sistema está fallando?
> 6. 🔬 **Reto práctico:** Ejecuta `samba-tool user list` en el servidor. ¿Qué usuarios ves, siendo que tú no has creado ninguno todavía? Localiza el usuario que empieza por `krbtgt` — busca en internet para qué sirve ese usuario en Kerberos y explícalo con tus palabras. Compara además la RAM libre actual con la que anotaste al final de la Fase 1.

---

> [!caution] 🛑 Auditoría y Evaluación (RA.03)
> **Peligro Crítico:** Si el DNS vuelve a apuntar a otro sitio en lugar de a `127.0.0.1`, los ordenadores dirán "No se encuentra el dominio" y nadie podrá iniciar sesión.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de ejecutar las verificaciones, instala las herramientas de diagnóstico DNS (no vienen preinstaladas en Ubuntu Server):
> ```bash
> sudo apt install dnsutils -y
> ```
> - [ ] ¿Responde `samba-tool domain level show` sin errores?
> - [ ] ¿El comando `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL` devuelve la IP correcta?
> - [ ] ¿`host -t A ubuntuserver.boochanlab.local` devuelve **`10.10.10.10`** — y NO una `10.0.2.x`? *(Si sale la de la NAT, ve a la tabla de troubleshooting: es un fallo silencioso que reventaría la Fase 8.)*
> - [ ] 💾 **Instantánea `Fase 4 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B2_Ubuntu_Local/v1-fase-4-aprovisionamiento-del-dominio-samba-ad-d.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B2_Ubuntu_Local` (No listado) | Nombrado `V1 · Fase 4 — Aprovisionamiento del Dominio (Samba AD DC)`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes en GitHub | La entrada, subida con `git add` → `commit` → `push` |
> | **💾 Punto de control** | Instantánea en VirtualBox | Nombrada **`Fase 4 terminada`**, y **tomada durante la grabación** para que se vea que la has hecho |
>
> > [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> > Las **Preguntas Críticas** y el **🔬 Reto** de más arriba no son decorativos: son la parte de la fase que demuestra que has entendido lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
> > Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.
>
> > [!info] 🏷️ Por qué el nombre lleva `V1` delante
> > Porque el proyecto Boochan existe en **varias versiones** (VirtualBox, Hyper-V, Azure, AWS…) y algunas comparten bloque y playlist. Sin la etiqueta, la Fase 4 de Azure y la de AWS se llamarían **exactamente igual** y no habría forma de distinguirlas. Con ella, tu carpeta y tu playlist dicen siempre **qué versión hiciste**.
>
> > [!success] 🎯 Criterio de éxito
> > Abro tu repositorio, encuentro la entrada de esta fase, y dentro está: qué has hecho, qué has entendido, qué dudas te han quedado y el enlace al vídeo donde se te ve haciéndolo. Si falta el enlace o faltan las respuestas, la fase **no cuenta como entregada**.
>
> > [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> > **Una fase, una entrada.** No creas un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**, para no perder nunca más de un día de trabajo.

---

> [!important] 💾 ÚLTIMO PASO: toma tu punto de control
> Antes de cerrar la grabación, **apaga la VM y toma una instantánea**:
>
> ```bash
> sudo poweroff
> ```
>
> En VirtualBox: selecciona la VM → **`Instantáneas`** → **`Tomar`** → nómbrala **`Fase 4 terminada`**, con la descripción *"dominio `BOOCHANLAB.LOCAL` provisionado"*.
>
> **Por qué:** si algo se rompe en la fase siguiente, vuelves aquí en treinta segundos en vez de reinstalar desde cero. Y te permite **probar cosas a propósito** para ver qué pasa, sabiendo que puedes deshacerlo.
>
> Cómo se hace paso a paso, y qué NO conserva una instantánea: [[Fase_0.S_Instantaneas_Puntos_de_Control]]
>
> ⚠️ **Antes de la Fase 4 esto no es opcional.** Es la fase que más piezas mueve y la que más se rompe.
