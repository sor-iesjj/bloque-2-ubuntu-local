## Fase 8 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8_Integracion_del_Cliente_Windows_11]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!success] 🎯 Esta verificación es distinta a todas las anteriores
> Las siete fases anteriores comprobaban **lo que acababas de hacer**. Esta comprueba **todo lo que llevas construido desde la Fase 1**, y lo hace desde donde de verdad importa: **el lado del trabajador**.
>
> **Y si algo falla aquí, casi nunca es culpa de esta fase.**

> [!warning] 🖥️ Estos comandos van en el CLIENTE WINDOWS
> Salvo los que digan expresamente *"en el servidor"*. Abre el **Símbolo del sistema** o **PowerShell**, y para algunos hace falta **como Administrador**.

> [!info] 📋 Ten delante la matriz
> Los puntos 5, 6 y 7 se juzgan contra [[Escenario_Boochan_SL]]. **Sin la tabla delante no puedes saber si el resultado es correcto.**

### **1 · EL CLIENTE ESTÁ EN LA RED DEL LABORATORIO**

```cmd
ipconfig /all
ping 10.10.10.10
```

- **✅ Bien:** el cliente tiene `10.10.10.20`, máscara `255.255.255.0`, y el servidor responde.
- **❌ Mal:** → [[Fase_8.7_Resolucion_Problemas#E1 · No se encuentra el dominio y no hay red|caso E1]].

### **2 · EL CLIENTE SABE A QUIÉN PREGUNTAR**

```cmd
nslookup BOOCHANLAB.LOCAL
nslookup ubuntuserver.boochanlab.local 10.10.10.10
```

- **✅ Bien:** las dos devuelven **`10.10.10.10`**.
- **❌ Mal:**
  - No resuelve → [[Fase_8.7_Resolucion_Problemas#E2 · No se encuentra el dominio aunque hay red|caso E2]]
  - Devuelve una **`10.0.2.x`** → **el fallo de la Fase 4**, aquí y ahora

> [!danger] 🛑 Si la segunda devuelve una `10.0.2.x`, esto es la Fase 4 volviendo
> Es el fallo del que te avisaba el [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5 de la Fase 4]]: el dominio anunciado en la tarjeta NAT.
>
> Aquel día no dio ningún error. **Han pasado semanas y aparece ahora**, con un mensaje que no menciona ni las tarjetas ni el DNS. Se arregla **en el servidor**.

### **3 · EL EQUIPO ESTÁ UNIDO Y SABES QUIÉN ERES**

```cmd
systeminfo | findstr /i "Dominio Domain"
whoami
whoami /groups | findstr /i "boochanlab"
```

- **✅ Bien:** dominio `BOOCHANLAB.LOCAL`, `whoami` devuelve **`boochanlab\<trabajador>`**, y en los grupos aparece **su departamento**.
- **❌ Mal:** un usuario **local** → cierra sesión y entra con una cuenta del dominio.

> [!warning] ⚠️ Si has entrado con el usuario local, lo demás no vale nada
> Todo lo que viene depende de **quién eres**. Y el `whoami /groups` es la forma de confirmar en qué departamento estás **antes** de juzgar lo que ves.

### **4 · LA AUTENTICACIÓN ES KERBEROS, Y EL RELOJ ESTÁ EN HORA**

```cmd
klist
w32tm /stripchart /computer:10.10.10.10 /samples:3 /dataonly
```

- **✅ Bien:** `klist` muestra tickets, incluido `krbtgt/BOOCHANLAB.LOCAL`, y el desfase es de **pocos segundos**.
- **❌ Mal:** más de **300 segundos** → Kerberos rechazará la autenticación → [[Fase_8.7_Resolucion_Problemas#E3 · Relación de confianza o credenciales incorrectas|caso E3]].

> [!info] 🎓 `klist` te enseña la Fase 4 funcionando
> Esos tickets son el **reino Kerberos** que aprovisionaste hace semanas, emitiendo credenciales de verdad. Y solo aparecen si te conectas **por nombre**, no por IP: por IP, Windows cae a NTLM.

---

## **5 · 🔴 LAS SIETE PRUEBAS DE LA MATRIZ**

**Aquí se comprueba, por fin, todo el proyecto.** Cada prueba se hace **iniciando sesión con el trabajador que toca**, y hay que cerrar sesión entre una y otra.

> [!important] 🔁 La pertenencia a grupos se lee AL INICIAR SESIÓN
> No basta con cambiar de usuario en un `net use`. **Cierra sesión de verdad** entre cada prueba, o arrastrarás los permisos del anterior.

### **5.1 — shinnosuke.nohara (becario) NO ve contabilidad**

Inicia sesión como `BOOCHANLAB\shinnosuke.nohara`:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Bien:** aparece **`becarios` y nada más**. Ni `contabilidad`, ni `comun`, ni ninguna otra.
- **❌ Mal:** si ve cualquier otra → [[Fase_8.7_Resolucion_Problemas#E6 · shinnosuke.nohara ve la carpeta que no debería ver|caso E6]], y el fallo está en la **Fase 7**.

### **5.2 — El becario NO puede borrar nada de lo suyo**

Con la misma sesión:
```cmd
dir \\UbuntuServer.BOOCHANLAB.LOCAL\becarios
echo prueba > \\UbuntuServer.BOOCHANLAB.LOCAL\becarios\intento.txt
```
- **✅ Bien:** el `dir` **funciona** *(puede leer)* y el `echo` **falla con acceso denegado** *(no puede escribir)*.
- **❌ Mal:** si el fichero se crea → falta el `chmod 2750` del Paso 3.b de la Fase 7.

> [!info] 🎓 Leer sí, tocar no
> Un becario llega la semana que viene y se va en tres meses. **Puede consultar y aprender; no puede destruir el material del que aprende.** Eso es mínimo privilegio, no desconfianza.

### **5.3 — masao.sato (comercial) SÍ abre una factura**

> [!warning] ⚠️ Antes de esta prueba: asegúrate de que hay una factura que abrir
> El fichero `factura-001.txt` puede que lo crearas en el laboratorio de la Fase 6, pero **era opcional**. Si no está, estas dos pruebas fallan por un fichero que no existe, no por un permiso.
>
> **Compruébalo y créalo si hace falta**, desde el servidor y como alguien de facturación:
> ```bash
> ls /srv/samba/departamentos/facturacion/factura-001.txt \
>   || sudo -u '#10001' sh -c 'echo "Factura de prueba" > /srv/samba/departamentos/facturacion/factura-001.txt'
> ```
> *(`10001` es `hiroshi.nohara`, de facturación. Se crea con su identidad **a propósito**: un fichero creado por `root` no demuestra nada sobre los permisos del grupo.)*

Cierra sesión y entra como `BOOCHANLAB\masao.sato`:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
type \\UbuntuServer.BOOCHANLAB.LOCAL\facturacion\factura-001.txt
```
- **✅ Bien:** ve `facturacion`, `comercial`, `logistica` y `comun`; y **lee** el contenido de la factura.

### **5.4 — 🔴 Pero NO puede borrarla**

Con la misma sesión:
```cmd
del \\UbuntuServer.BOOCHANLAB.LOCAL\facturacion\factura-001.txt
```
- **✅ Bien:** **acceso denegado.**
- **❌ Mal:** si la borra, comercial tiene `w` sobre facturación y **no debería** → revisa el `getfacl` en el servidor: tiene que poner `group:BOOCHANLAB\comercial:r-x`, sin la `w`.

> [!success] 🎯 Esta es la prueba más importante del proyecto entero
> **Ver y modificar son cosas distintas.** Un comercial necesita saber si su cliente ha pagado; **no puede tocar la factura**.
>
> Si pudiera, **el mismo que cobra la comisión podría cambiar el importe facturado**. No es un detalle técnico: es control interno, y acabas de demostrarlo funcionando.

### **5.5 — misae.nohara (contabilidad) SÍ escribe en facturación**

Cierra sesión y entra como `BOOCHANLAB\misae.nohara`:
```cmd
echo Ajuste contable Q1 > \\UbuntuServer.BOOCHANLAB.LOCAL\facturacion\ajuste-Q1.txt
dir \\UbuntuServer.BOOCHANLAB.LOCAL\facturacion
```
- **✅ Bien:** el fichero **se crea**. Contabilidad y facturación son el mismo circuito de dinero.

### **5.6 — 🔴 Pero contabilidad NO ve RRHH**

Con la misma sesión:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Bien:** ve `facturacion`, `contabilidad`, `comercial`, `logistica` y `comun`. **`rrhh` no aparece.**
- **❌ Mal:** si aparece → alguien le dio un permiso que no está en la matriz.

> [!success] 🎯 La regla que parece una contradicción y no lo es
> El departamento que ve **todo el dinero de la empresa** no puede ver **los sueldos de sus compañeros**.
>
> Contabilidad necesita el **importe total** a pagar, no el expediente de cada persona. **Acceso a lo que necesitas para tu trabajo, y nada más.** Eso es el principio de mínimo privilegio, y es la regla más importante de toda la matriz.

### **5.7 — El sticky bit de la carpeta común**

Con `misae.nohara`, deja un fichero en la común:
```cmd
echo De Misae > \\UbuntuServer.BOOCHANLAB.LOCAL\comun\de-misae.txt
```
Cierra sesión, entra como `BOOCHANLAB\nene.sakurada` e intenta borrarlo:
```cmd
type \\UbuntuServer.BOOCHANLAB.LOCAL\comun\de-misae.txt
del  \\UbuntuServer.BOOCHANLAB.LOCAL\comun\de-misae.txt
```
- **✅ Bien:** **lo lee** pero **no lo borra**.
- **❌ Mal:** si lo borra → falta el sticky bit → revisa que `comun` esté en `1777`.

> [!info] 🎓 Puedes crear, puedes leer, no puedes destruir lo ajeno
> Es el mecanismo de `/tmp`, aplicado a la carpeta donde escriben seis departamentos. **Evita el problema clásico de las carpetas compartidas:** que alguien borre por prisa el trabajo de otro.

---

### **6 · LO QUE HAS CREADO, VISTO DESDE EL SERVIDOR**

Vuelve al **servidor Ubuntu** y mira el fichero que creó `misae.nohara` desde Windows:
```bash
ls -l  /srv/samba/departamentos/facturacion/ajuste-Q1.txt
ls -ln /srv/samba/departamentos/facturacion/ajuste-Q1.txt
getfacl -p /srv/samba/departamentos/facturacion/ajuste-Q1.txt
```

- **✅ Bien:** aparece a nombre de **`misae.nohara`** con **`uid=10003`**, el grupo heredado por el setgid, y **la ACL heredada** con `comercial` y `contabilidad`.

> [!success] 🎯 Todo el proyecto, en una sola salida de `ls`
> Un fichero creado desde **Windows**, guardado en un disco **Linux**, a nombre de una identidad del **dominio**, con el número que pusiste **a mano en la Fase 5**, sobre un volumen con **cuota de la Fase 6**, y con los permisos **heredados de la Fase 7**.
>
> Cinco fases funcionando a la vez en un fichero de texto de 20 bytes. Míralo con calma.

### **7 · LIMPIA LO QUE HAS CREADO**

```cmd
del \\UbuntuServer.BOOCHANLAB.LOCAL\facturacion\ajuste-Q1.txt
del \\UbuntuServer.BOOCHANLAB.LOCAL\comun\de-misae.txt
```
*(Con un usuario que tenga permiso para borrarlos: `misae.nohara`.)*

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 Este verificador es de PowerShell, no de bash
> Es el único del proyecto que se ejecuta **en Windows**.

> [!example] Cómo se descarga y se ejecuta
> En el cliente, **PowerShell**:
> ```powershell
> cd $env:USERPROFILE
> curl.exe -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase8.ps1
> notepad verificar_fase8.ps1
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> .\verificar_fase8.ps1
> ```

> [!danger] 🔴 Hay que ejecutarlo con VARIOS trabajadores
> El script **lleva la matriz dentro** y sabe qué debe ver cada uno. Ejecútalo **como mínimo** con estos tres:
>
> | Sesión | Qué tiene que decir |
> | :--- | :--- |
> | `shinnosuke.nohara` | Ve **solo** `becarios`, y **no puede escribir** en él |
> | `masao.sato` | Ve `facturacion` pero **no** `contabilidad` ni `rrhh` |
> | `misae.nohara` | Ve casi todo, pero **no** `rrhh` ni `becarios` |
>
> Cada ejecución guarda su propio informe: `verificacion-fase-8-<usuario>.txt`. **Sube los tres al repositorio.** Esa colección **es la prueba de la Fase 7**.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Pega **las tres salidas de `net view`**, una por trabajador, una debajo de otra.
> 2. El script comprueba dos cosas por usuario: **lo que ve y lo que NO ve**. ¿Por qué la segunda es la importante?
> 3. La difícil: **¿por qué esta comprobación no se pudo hacer en la Fase 7?**

---

### ✅ Checklist de este apartado

- [ ] Cliente con IP `10.10.10.20` y `ping` al servidor.
- [ ] `nslookup ubuntuserver.boochanlab.local` → **`10.10.10.10`**, NO una `10.0.2.x`.
- [ ] Equipo unido a `BOOCHANLAB.LOCAL`, y `whoami /groups` muestra el departamento.
- [ ] `klist` con tickets de Kerberos y desfase horario **por debajo de 5 minutos**.
- [ ] 🔴 **5.1** `shinnosuke.nohara` ve **solo** `becarios`.
- [ ] 🔴 **5.2** El becario **lee** pero **no escribe** en su carpeta.
- [ ] 🔴 **5.3** `masao.sato` **abre** una factura.
- [ ] 🔴 **5.4** `masao.sato` **NO puede borrarla**.
- [ ] 🔴 **5.5** `misae.nohara` **sí escribe** en facturación.
- [ ] 🔴 **5.6** `misae.nohara` **NO ve** `rrhh`.
- [ ] 🔴 **5.7** Un usuario **no puede borrar** en `comun` el fichero de otro.
- [ ] Comprobado en el servidor que el fichero creado desde Windows lleva **`uid=10003`** y la ACL heredada.
- [ ] Ficheros de prueba **borrados**.
- [ ] *(Opcional)* Verificador ejecutado con **tres trabajadores**, con sus tres informes.

> [!success] ✅ Con todo en verde, pasa al [[Fase_8.8.b_Punto_de_Control|apartado 8.b]] y guarda las instantáneas.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.7_Resolucion_Problemas]] | [[Fase_8_Integracion_del_Cliente_Windows_11]] | [[Fase_8.8.b_Punto_de_Control]] |
