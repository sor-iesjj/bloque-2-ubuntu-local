## Fase 8 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Aquí compruebas. En el [[Fase_8.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!success] 🎯 Esta verificación es distinta a todas las anteriores
> Las siete fases anteriores comprobaban **lo que acababas de hacer**. Esta comprueba **todo lo que llevas construido desde la Fase 1**, y lo hace desde donde de verdad importa: **el lado del usuario**.
>
> Un cliente Windows que se une al dominio, autentica con Kerberos y ve exactamente las carpetas que le corresponden es la prueba de que las ocho fases están bien. **Y si algo falla aquí, casi nunca es culpa de esta fase.**

> [!warning] 🖥️ Estos comandos van en el CLIENTE WINDOWS
> Salvo los que digan expresamente *"en el servidor"*. Abre el **Símbolo del sistema** o **PowerShell**, y para algunos hace falta **como Administrador**.

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
  - No resuelve → el DNS del cliente no apunta al servidor → [[Fase_8.7_Resolucion_Problemas#E2 · No se encuentra el dominio aunque hay red|caso E2]]
  - Devuelve una **`10.0.2.x`** → **el fallo de la Fase 4**, aquí y ahora

> [!danger] 🛑 Si la segunda devuelve una `10.0.2.x`, esto es la Fase 4 volviendo
> Es el fallo del que te avisaba el [[Fase_4.7_Resolucion_Problemas#E5 · El dominio se anuncia en una IP que no es la 10.10.10.10|caso E5 de la Fase 4]]: el dominio anunciado en la tarjeta NAT.
>
> Aquel día no dio ningún error. **Han pasado tres semanas y aparece ahora**, con un mensaje que no menciona ni las tarjetas ni el DNS. Se arregla **en el servidor**, no aquí.

### **3 · EL EQUIPO ESTÁ UNIDO AL DOMINIO**

```cmd
systeminfo | findstr /i "Dominio Domain"
whoami
```

- **✅ Bien:** el dominio es `BOOCHANLAB.LOCAL`, y `whoami` devuelve **`boochanlab\user1`**.
- **❌ Mal:**
  - Sale un grupo de trabajo → la unión no se completó
  - `whoami` devuelve un usuario **local** → has iniciado sesión con la cuenta equivocada

> [!warning] ⚠️ Si has entrado con el usuario local, lo demás no vale nada
> Todas las comprobaciones de permisos que vienen ahora dependen de **quién eres**. Cierra sesión y entra como `BOOCHANLAB\user1` antes de seguir.

### **4 · LA AUTENTICACIÓN ES KERBEROS, Y EL RELOJ ESTÁ EN HORA**

```cmd
klist
w32tm /stripchart /computer:10.10.10.10 /samples:3 /dataonly
```

- **✅ Bien:** `klist` muestra tickets, incluido uno de `krbtgt/BOOCHANLAB.LOCAL`, y el desfase horario es de **pocos segundos**.
- **❌ Mal:** desfase de más de **300 segundos** → Kerberos rechazará la autenticación → [[Fase_8.7_Resolucion_Problemas#E3 · Relacion de confianza o credenciales incorrectas|caso E3]].

> [!info] 🎓 `klist` te enseña la Fase 4 funcionando
> Esos tickets son el **reino Kerberos** que aprovisionaste hace semanas, emitiendo credenciales de verdad para un cliente de verdad. Míralos con calma: es la parte más abstracta del proyecto hecha visible.
>
> Y fíjate en que solo aparecen si te conectas **por nombre**, no por IP. Por IP, Windows usa NTLM —más antiguo y sin tickets—, que es justo lo que el dominio venía a sustituir.

### **5 · 🔴 LA PRUEBA QUE QUEDÓ PENDIENTE EN LA FASE 7**

**Esta es la comprobación más importante de la fase, y hay que hacerla DOS VECES, con dos usuarios distintos.**

**5A — Con `BOOCHANLAB\user1`** *(pertenece al grupo `policia`)*:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Bien:** aparecen **`prueba1` y `prueba3`**, y puedes entrar en las dos.

**5B — Cierra sesión, entra con `BOOCHANLAB\user2`** *(NO pertenece al grupo)* y repite:
```cmd
net view \\UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Bien:** aparece **`prueba1`** y **`prueba3` NO aparece siquiera en la lista**.
- **❌ Mal:** si `user2` **ve** `prueba3` → [[Fase_8.7_Resolucion_Problemas#E6 · user2 ve la carpeta que no deberia ver|caso E6]], y el fallo está en la **Fase 7**.

> [!success] 🎯 Estas son las dos casillas que anotaste en la Fase 7
> El apartado 8.a de aquella fase te pidió apuntarlas como pendientes, porque **desde el servidor no había forma de comprobarlas**. Hoy las tachas.
>
> Y fíjate en la diferencia entre las dos cosas que estás probando:
> - Que `user2` **no pueda entrar** → eso son los permisos. Se veía desde Ubuntu.
> - Que `user2` **no sepa que existe** → eso es el ABE. **Solo se ve desde aquí.**
>
> **Denegar el acceso y ocultar la existencia son dos capas distintas de seguridad.** Acabas de comprobar las dos, cada una desde donde se puede.

### **6 · LAS CUOTAS DE LA FASE 6, DESDE EL LADO DEL USUARIO**

Con `user1`, abre la unidad mapeada y mira sus propiedades en el Explorador, o:
```cmd
net use
dir Z:
```

- **✅ Bien:** `Z:` está conectada y Windows muestra la carpeta con **5 GB de capacidad**, no con el tamaño del disco del servidor.

> [!info] 🎓 La cuota de la Fase 6, vista por quien la sufre
> Windows enseña esos 5 GB como si fuera un disco. El usuario no sabe —ni le importa— que por debajo hay un fichero `.img` montado en un servidor Linux. **Ve un disco de 5 GB y punto.**
>
> Eso es exactamente lo que buscabas: una abstracción que funciona.

### **7 · ESCRIBIR DE VERDAD**

```cmd
echo prueba > Z:\prueba_user1.txt
dir Z:
```

- **✅ Bien:** el fichero se crea.
- **❌ Mal:** acceso denegado → [[Fase_8.7_Resolucion_Problemas#E7 · El usuario entra pero no puede escribir|caso E7]], y el fallo está en la Fase 5 o en la 7.

**Y compruébalo desde el servidor**, que es donde se ve lo interesante:
```bash
ls -l /srv/samba/prueba1/prueba_user1.txt
getfacl -p /srv/samba/prueba1/prueba_user1.txt
```

> [!success] 🎯 Mira de quién es ese fichero
> Lo ha creado un usuario desde **Windows**, y en el servidor **Linux** aparece a nombre de `user1`, con `uid=10001`. El mismo número que pusiste a mano en la Fase 5.
>
> **Eso es todo el proyecto funcionando a la vez:** el dominio autenticando (Fase 4), winbind traduciendo la identidad (Fase 5), el disco con cuota recibiendo el fichero (Fase 6), las ACL aplicándose (Fase 7) y el cliente escribiendo (Fase 8).
>
> **Bórralo después:**
> ```cmd
> del Z:\prueba_user1.txt
> ```

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 Este verificador es de PowerShell, no de bash
> Es el único del proyecto que se ejecuta **en Windows**, porque es la única fase cuyo trabajo ocurre en el cliente.

> [!example] Cómo se descarga y se ejecuta
> En el cliente, **PowerShell como Administrador**:
> ```powershell
> cd $env:USERPROFILE
> curl.exe -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase8.ps1
> notepad verificar_fase8.ps1
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> .\verificar_fase8.ps1
> ```
>
> **Léelo antes de ejecutarlo**, igual que has hecho con todos los demás.

> [!danger] 🔴 Hay que ejecutarlo DOS VECES, una con cada usuario
> El script **no puede juzgar el ABE por su cuenta**: el resultado correcto depende de con quién hayas iniciado sesión.
>
> | Sesión | Qué tiene que decir |
> | :--- | :--- |
> | `BOOCHANLAB\user1` | `E2` en verde: **SE VE** `prueba3` |
> | `BOOCHANLAB\user2` | `E2` en verde: **NO se ve** `prueba3` |
>
> **Guarda los dos informes** y súbelos al repositorio. Esa pareja de ficheros **es la prueba de la Fase 7**.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Pega **las dos salidas del `net view`**, la de `user1` y la de `user2`, una debajo de otra.
> 2. Explica **por qué el script no puede decidir solo** si el ABE funciona.
> 3. Y la difícil: **¿por qué esta comprobación no se pudo hacer en la Fase 7?**

---

### ✅ Checklist de este apartado

- [ ] Cliente con IP `10.10.10.20` y `ping 10.10.10.10` respondiendo.
- [ ] `nslookup ubuntuserver.boochanlab.local` → **`10.10.10.10`**, y NO una `10.0.2.x`.
- [ ] Equipo unido a `BOOCHANLAB.LOCAL` y `whoami` → **`boochanlab\user1`**.
- [ ] `klist` muestra tickets de Kerberos.
- [ ] Desfase horario con el servidor **por debajo de 5 minutos**.
- [ ] 🔴 Con **`user1`**: `net view` muestra **`prueba1` y `prueba3`**.
- [ ] 🔴 Con **`user2`**: `net view` muestra `prueba1` y **NO `prueba3`**.
- [ ] Unidad `Z:` mapeada, mostrando **5 GB**.
- [ ] Fichero creado desde Windows y **comprobado en el servidor con `uid=10001`**.
- [ ] Fichero de prueba **borrado**.
- [ ] *(Opcional)* Verificador ejecutado **dos veces**, con los dos informes guardados.

> [!success] ✅ Con todo en verde, pasa al [[Fase_8.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.7_Resolucion_Problemas]] | [[Fase_8]] | [[Fase_8.8.b_Punto_de_Control]] |
