## Fase 10 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (macOS)**
> 🧭 Índice de la fase: [[Fase_10_Integracion_del_Cliente_macOS]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> No tomes la instantánea `Fase 10 terminada` del servidor hasta que todo lo de abajo esté en verde.

> [!success] 🎯 Qué comprueba esta verificación
> Que la **VM de macOS arranca**, accede al dominio y que la **matriz se respeta desde el sistema de Apple** — el cierre del RA.06.

---

**Comandos en la VM de macOS, salvo que se diga "en el servidor".**

### 0 · La VM de macOS arranca y llega al escritorio

- **✅ Bien:** la VM arranca sin pantalla negra, sin la tortuga, y llegas al escritorio de macOS.
- **❌ Mal:** pantalla negra / EXITBS → caso C1. Tortuga → caso C2.

### 1 · La VM llega al servidor

```bash
ping -c 2 10.10.10.10
```
- **✅ Bien:** responde.
- **❌ Mal:** → caso C1.

### 2 · Resuelve el nombre

```bash
ping -c 2 UbuntuServer.BOOCHANLAB.LOCAL
```
- **✅ Bien:** responde con la IP del servidor.
- **❌ Mal:** → usa la IP directa o avisa al profesor.

### 3 · La hora del Mac está en hora

Ajustes → Fecha y hora.
- **✅ Bien:** hora correcta, automática.
- **❌ Mal:** → caso C2 (el fallo nº1).

### 4 · Acceso a las carpetas desde el Finder

`Cmd + K` → `smb://UbuntuServer.BOOCHANLAB.LOCAL` → `masao.sato` / `P@ssw0rd`.
- **✅ Bien:** se conecta y ves las carpetas.
- **❌ Mal:** → casos C2 o C3.

### 5 · La matriz, desde el tercer sistema — las mismas pruebas que en las Fases 8 y 9

Con `masao.sato` conectado, y **cerrando la conexión entre cada usuario**:

| Prueba | Usuario | ✅ Bien |
| :--- | :--- | :--- |
| **5.1** | `shinnosuke.nohara` (becario) | Ve **solo `becarios`** |
| **5.2** | *(el mismo)* | No puede escribir en `becarios` |
| **5.3** | `masao.sato` (comercial) | Ve sus 4 carpetas y **lee** la factura |
| **5.4** | *(el mismo)* | No puede **borrar** la factura |
| **5.5** | `misae.nohara` (contabilidad) | Puede **escribir** en `facturacion` |
| **5.6** | *(el mismo)* | No ve `rrhh` |
| **5.7** | `nene.sakurada` | No puede borrar en `comun` lo de otro |

> [!important] 🔁 Cierra la conexión entre cada prueba (Cmd+K → Desconectar)
> La identidad se lee al conectar. Entre un usuario y otro, **desconecta y vuelve a conectar** — igual que cerrabas sesión en las Fases 8 y 9.

---

### 6 · Desde el servidor: comprueba que el acceso quedó registrado (opcional)

En el servidor, puedes ver quién está accediendo a los recursos:
```bash
sudo smbstatus
```
- **✅ Bien:** aparece `masao.sato` conectado desde el Mac.

---

## 🤖 Confirmación automática *(opcional, después de hacerlo a mano)*

> [!warning] 🛑 No hay verificador `.sh` que corra en el Mac para esto
> A diferencia de la Fase 9, aquí **no hay script de verificación dedicado**: el acceso SMB desde un cliente externo no se puede automatizar igual. La prueba real es el punto 5 (las 7 pruebas de la matriz desde el Finder), y **la evidencia es tu vídeo**.
>
> Lo que sí puedes hacer es pasar el verificador del **servidor** para confirmar que el dominio está sano:
> ```bash
> sudo ./verificar_fase7.sh
> ```

---

### ✅ Checklist de este apartado

- [ ] El Mac `ping` al servidor y resuelve `UbuntuServer.BOOCHANLAB.LOCAL`.
- [ ] La hora del Mac es correcta.
- [ ] Acceso por `smb://…` con `masao.sato`.
- [ ] 🔴 **5.1** `shinnosuke.nohara` ve **solo** `becarios`.
- [ ] 🔴 **5.2** El becario no puede escribir.
- [ ] 🔴 **5.3** `masao.sato` abre una factura.
- [ ] 🔴 **5.4** No puede borrarla.
- [ ] 🔴 **5.5** `misae.nohara` escribe en `facturacion`.
- [ ] 🔴 **5.6** No ve `rrhh`.
- [ ] 🔴 **5.7** No borra en `comun` lo ajeno.
- [ ] *(Opcional)* Verificador del servidor en verde.

> [!success] ✅ Con todo en verde, pasa al [[Fase_10.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea del servidor.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_10.7_Resolucion_Problemas]] | [[Fase_10_Integracion_del_Cliente_macOS]] | [[Fase_10.8.b_Punto_de_Control]] |
