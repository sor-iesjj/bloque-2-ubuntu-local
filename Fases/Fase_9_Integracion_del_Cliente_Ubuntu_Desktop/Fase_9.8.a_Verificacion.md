## Fase 9 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> No tomes la instantánea `Fase 9 terminada` hasta que todo lo de abajo esté en verde. Si guardas sin verificar, guardas los fallos.

> [!success] 🎯 Qué comprueba esta verificación
> Que el Ubuntu Desktop **está unido al dominio** y que la **matriz de permisos se respeta desde el lado libre**. Es la prueba de que el modelo no depende del sistema del cliente.

---

**Comandos en el CLIENTE Ubuntu Desktop, salvo que se diga "en el servidor".**

### 1 · El cliente está en la red y llega al servidor

```bash
ip addr show
ping -c 2 10.10.10.10
```
- **✅ Bien:** IP de `10.10.10.0/24` y el servidor responde.
- **❌ Mal:** → caso C5.

### 2 · El DNS apunta al servidor

```bash
nslookup BOOCHANLAB.LOCAL
```
- **✅ Bien:** responde `10.10.10.10`.
- **❌ Mal:** → caso C3.

### 3 · El equipo está unido al dominio

```bash
realm list
```
- **✅ Bien:** `configured`, dominio `BOOCHANLAB.LOCAL`, modo `sssd`.
- **❌ Mal:** el equipo no está unido → repite el Paso 7.

### 4 · La hora está en hora

```bash
timedatectl
```
- **✅ Bien:** `Europe/Madrid`, hora correcta.
- **❌ Mal:** → caso C1.

### 5 · Un usuario del dominio resuelve (se ve su identidad)

```bash
getent passwd masao.sato
```
- **✅ Bien:** devuelve una línea con `uid=10005` (el UID del escenario).
- **❌ Mal:** SSSD no traduce → comprueba la unión (Paso 3).

### 6 · Acceso a las carpetas desde el cliente libre

Desde el gestor de archivos, `smb://UbuntuServer.BOOCHANLAB.LOCAL` con `masao.sato`.
- **✅ Bien:** ve `comercial`, `facturacion`, `logistica`, `comun` — **y NO** `contabilidad` ni `rrhh`.
- **❌ Mal:** si ve lo ajeno, hay un permiso de más → revisa en el servidor el `getfacl` (Fase 7).

### 7 · La matriz, desde el otro lado — las mismas 7 pruebas que en la Fase 8

Igual que en la Fase 8, **cerrando sesión entre cada una**:

| Prueba | Usuario | Qué hace | ✅ Bien |
| :--- | :--- | :--- | :--- |
| **7.1** | `shinnosuke.nohara` (becario) | Entra y ve `smb://` | Ve **solo `becarios`** |
| **7.2** | *(el mismo)* | Intenta escribir en `becarios` | **Denegado** (solo lectura) |
| **7.3** | `masao.sato` (comercial) | Abre una factura | Ve sus 4 carpetas y **lee** la factura |

> [!warning] ⚠️ Antes de esta prueba: asegúrate de que hay una factura que abrir
> El fichero `factura-001.txt` puede que lo crearas en el laboratorio de la Fase 6, pero **era opcional**. Si no está, la prueba falla por un fichero que no existe, no por un permiso. **Compruébalo y créalo si hace falta**, desde el servidor:
> ```bash
> ls /srv/samba/departamentos/facturacion/factura-001.txt \
>   || sudo -u '#10001' sh -c 'echo "Factura de prueba" > /srv/samba/departamentos/facturacion/factura-001.txt'
> ```
> *(`10001` es `hiroshi.nohara`, de facturación. Se crea con su identidad a propósito.)*
| **7.4** | *(el mismo)* | Intenta borrar esa factura | **Denegado** (ver ≠ modificar) |
| **7.5** | `misae.nohara` (contabilidad) | Escribe en `facturacion` | El fichero **se crea** |
| **7.6** | *(el mismo)* | Ve `smb://` | Ve todo **menos `rrhh`** |
| **7.7** | `nene.sakurada` | Intenta borrar en `comun` lo de otro | **Denegado** (sticky bit) |

> [!important] 🔁 Cierra sesión entre cada prueba — la pertenencia a grupos se lee al iniciar sesión
> Es la misma regla que la Fase 8: no vale cambiar de usuario en caliente. **Salir y entrar.**

---

## 🤖 Confirmación automática *(opcional, después de hacerlo a mano)*

> [!warning] 🛑 El verificador de esta fase es un script `.sh`, igual que en el servidor
> No hay script `.ps1` aquí: el cliente es Linux. Se ejecuta **en el cliente Ubuntu Desktop** con `sudo`.

```bash
curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase9.sh
chmod +x verificar_fase9.sh
sudo ./verificar_fase9.sh
```

Comprueba: pertenencia al dominio, resolución del usuario, hora, y que el cliente llega al servidor. Guarda el informe y súbelo a tu repositorio.

> [!info] 📋 El script NO sustituye a las comprobaciones
> Haz los puntos de arriba tú, comando a comando. El script sirve **después**, para confirmar que no se te ha escapado nada.

---

### ✅ Checklist de este apartado

- [ ] Cliente en `10.10.10.0/24` y `ping` al servidor.
- [ ] `nslookup BOOCHANLAB.LOCAL` → `10.10.10.10`.
- [ ] `realm list` → `configured`.
- [ ] `timedatectl` → `Europe/Madrid`.
- [ ] `getent passwd masao.sato` → `uid=10005`.
- [ ] 🔴 **7.1** `shinnosuke.nohara` ve **solo** `becarios`.
- [ ] 🔴 **7.2** El becario **lee** pero **no escribe**.
- [ ] 🔴 **7.3** `masao.sato` **abre** una factura.
- [ ] 🔴 **7.4** `masao.sato` **NO puede borrarla**.
- [ ] 🔴 **7.5** `misae.nohara` **sí escribe** en facturación.
- [ ] 🔴 **7.6** `misae.nohara` **NO ve** `rrhh`.
- [ ] 🔴 **7.7** Un usuario **no puede borrar** en `comun` lo de otro.
- [ ] *(Opcional)* Verificador con su informe.

> [!success] ✅ Con todo en verde, pasa al [[Fase_9.8.b_Punto_de_Control|apartado 8.b]] y guarda las instantáneas.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.7_Resolucion_Problemas]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.8.b_Punto_de_Control]] |
