## Fase 2 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima creyendo que estabas en un sitio bueno.
>
> **Guardar sin comprobar es peor que no guardar.**
>
> Aquí compruebas. En el [[Fase_2.8.b_Punto_de_Control|apartado 8.b]] guardas.

---

## 🔍 LAS CINCO COMPROBACIONES

> Todas **solo leen**. Ninguna modifica nada.

### **1 · LA IDENTIDAD DEL SERVIDOR**

```bash
hostname
hostname -f
```

- **Qué hace:** el primero da el nombre corto; el segundo, el **nombre completo** (FQDN).
- **Por qué es LA comprobación de esta fase:** en la Fase 4, el dominio de Active Directory se construirá **sobre ese nombre**. Si está mal, el dominio se levanta mal y el error aparece dos fases más tarde, sin mencionar `/etc/hosts` por ninguna parte.
- **✅ Bien:** `UbuntuServer` y `UbuntuServer.BOOCHANLAB.LOCAL`.
- **❌ Mal:** si `hostname -f` devuelve solo `UbuntuServer` → [[Fase_2.7_Resolucion_Problemas#E7 · hostname -f no devuelve el nombre completo|caso E7]].

### **2 · EL FICHERO DE IDENTIDADES**

```bash
cat /etc/hosts
```

- **Qué hace:** muestra el fichero donde vive la identidad de red del servidor.
- **Por qué mirarlo aunque el punto 1 esté bien:** porque hay dos formas de que `hostname -f` acierte por casualidad y falle después.
- **✅ Bien:** tres cosas a la vez —

| Debe haber | Debe NO haber |
| :--- | :--- |
| `127.0.0.1  localhost` | Ninguna línea `127.0.1.1` |
| `10.10.10.10  UbuntuServer.BOOCHANLAB.LOCAL  UbuntuServer` | |

- **❌ Mal:**
  - **Vacío** → [[Fase_2.7_Resolucion_Problemas#E6 · El fichero de identidades de red está vacío|caso E6]]
  - **Con `127.0.1.1`** → esa línea gana porque va antes, y deja tu servidor apuntando a bucle local
  - **Columnas al revés** → `hostname -f` devuelve el **segundo campo**: si pones el corto antes, te da el corto

### **3 · LOS PAQUETES QUE NECESITA LA FASE 4**

```bash
dpkg -s samba-ad-dc samba-ad-provision | grep -E '^Package|^Status'
```

- **Qué hace:** consulta si esos dos paquetes están instalados de verdad.
- **Por qué solo esos dos:** desde Ubuntu 24.04 el controlador de dominio **ya no viene dentro del paquete `samba`**. Sin ellos, la Fase 4 es imposible.
- **✅ Bien:** los dos con `install ok installed`.
- **❌ Mal:** `sudo apt install -y samba-ad-dc samba-ad-provision`.

> [!warning] ⚠️ Comprueba lo que HAY, no lo que pediste
> `apt` puede avisar de que un paquete no existe **y seguir instalando el resto sin abortar**. Terminas creyendo que instalaste todo. → [[Fase_2.7_Resolucion_Problemas#E11 · Instalé los paquetes pero uno no está|caso E11]]

### **4 · KERBEROS, EN MAYÚSCULAS**

```bash
grep default_realm /etc/krb5.conf
```

- **Qué hace:** muestra el reino Kerberos configurado.
- **Por qué las mayúsculas:** en Kerberos el nombre del reino **distingue mayúsculas de minúsculas**. Con `boochanlab.local` en minúsculas, ningún usuario podrá autenticarse en la Fase 5 — y el error no dirá nada de mayúsculas.
- **✅ Bien:** `default_realm = BOOCHANLAB.LOCAL`.
- **❌ Mal:** `sudo dpkg-reconfigure krb5-config`.

### **5 · EL SISTEMA ACTUALIZADO Y SANO**

```bash
sudo dpkg --audit
apt list --upgradable
```

- **Qué hace:** el primero busca paquetes a medio configurar; el segundo, actualizaciones pendientes.
- **Por qué:** aquí demuestras el `CE.01.h` *(se ha actualizado el sistema operativo en red)*.
- **✅ Bien:** el primero **sin salida**; el segundo, pocos o ninguno.
- **❌ Mal:** si `dpkg --audit` devuelve algo → `sudo dpkg --configure -a`.

> [!info] 💡 Que queden dos o tres sin actualizar es normal
> `apt upgrade` **no toca** los paquetes cuya actualización obligaría a instalar o eliminar otros. Es conservador a propósito.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los cinco puntos tú, comando a comando. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.
>
> El script sirve **después**, para confirmar que no se te ha escapado nada.

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase2.sh
> chmod +x verificar_fase2.sh
> sudo ./verificar_fase2.sh
> ```

> > [!danger] 🛑 Comprueba que te has traído la versión BUENA. No es paranoia
> > Un `curl` puede decirte `100%` y traerte **un fichero antiguo**: GitHub sirve estos ficheros a través de una red de caché, y a veces un nodo tarda en actualizarse.
> >
> > **Pasó de verdad**, y costó veinte minutos de diagnóstico: el verificador marcaba fallos que no existían, y el problema era que el fichero descargado era el de antes.
> >
> > **La comprobación cuesta dos segundos:**
> > ```bash
> > ls -l verificar_fase2.sh
> > ```
> > **Apunta el tamaño en bytes.** Si vuelves a descargarlo tras un aviso de que se ha corregido y **el tamaño no ha cambiado**, es que te has traído el mismo de antes.
> >
> > **Y si sospechas que estás con una versión vieja:**
> > ```bash
> > rm -f verificar_fase2.sh          # bórralo primero: así, si falla el curl, lo ves
> > curl -H 'Cache-Control: no-cache' -O <la URL>
> > ```
> >
> > > [!info] 🎓 Otra vez la misma idea, y ya van tres en este bloque
> > > **Que un comando no dé error no significa que haya hecho lo que querías.** El `curl` devolvió `200 OK`, descargó un fichero válido y ejecutable… y era el equivocado.
> > >
> > > Lo has visto ya con `chown` *(pasa y deja la carpeta a nombre de root)*, con `setfacl` *(pasa y la máscara anula el permiso)* y ahora con `curl`. **Siempre la misma lección: comprueba el resultado, no el mensaje.**
> Genera `verificacion-fase-2.txt`. **Súbelo a tu repositorio** con la entrada de apuntes.

> [!info] 🌐 ¿Qué es `curl` y por qué esa dirección?
> **`curl` es un navegador sin ventana:** descarga una dirección desde la línea de comandos. Viene instalado en Ubuntu Server; si no: `sudo apt install -y curl`.
>
> **`raw.githubusercontent.com`** devuelve **el fichero desnudo**, sin la página web de GitHub alrededor. Se construye con dos cambios sobre la dirección normal:
>
> 1. `github.com` → `raw.githubusercontent.com`
> 2. Desaparece el `/blob/`
>
> **Funciona sin usuario ni contraseña porque el repositorio del curso es público.**
>
> **¿Por qué no clonar el repositorio?** Porque traería cientos de ficheros para usar uno de 8 KB. Además, el repositorio lo clonaste en tu **Windows** para leer los apuntes: en el servidor no está.

> [!question] 🤔 Léelo antes de ejecutarlo
> ```bash
> less verificar_fase2.sh
> ```
> *(Se sale con `q`.)* **Un administrador nunca ejecuta con `sudo` un script que no ha leído.**

---

### ✅ Checklist de este apartado

- [ ] `hostname -f` → `UbuntuServer.BOOCHANLAB.LOCAL`.
- [ ] `/etc/hosts` con `localhost`, con la línea del dominio y **sin** `127.0.1.1`.
- [ ] `samba-ad-dc` y `samba-ad-provision` instalados.
- [ ] `default_realm = BOOCHANLAB.LOCAL`, en mayúsculas.
- [ ] `dpkg --audit` sin salida.
- [ ] *(Opcional)* Script ejecutado e informe subido al repositorio.

> [!success] ✅ Con las cinco en verde, pasa al [[Fase_2.8.b_Punto_de_Control|apartado 8.b]].

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.7_Resolucion_Problemas]] | [[Fase_2]] | [[Fase_2.8.b_Punto_de_Control]] |
