## Fase 7 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Aquí compruebas. En el [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ Esta fase NO se puede verificar entera desde aquí
> La mitad del trabajo es **hacer invisible** una carpeta para quien no tiene permiso. Y la invisibilidad **solo se ve desde el cliente Windows**, que es la Fase 8.
>
> Lo que sí puedes comprobar aquí es que el servidor está **correctamente configurado para ello**. El punto 7 te dice qué queda pendiente, para que lo **anotes** en vez de darlo por hecho.
>
> **No confundas "el servidor está bien configurado" con "la protección funciona".**

> [!info] 📋 Ten delante la matriz
> Todo lo de esta lista sale de [[Escenario_Boochan_SL]]. **No la verifiques de memoria:** son ocho permisos cruzados y es muy fácil dar uno de más.

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`ubuntuserver`** → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

### **1 · LA BASE DE LAS FASES 5 Y 6 SIGUE EN PIE**

```bash
for d in facturacion contabilidad comercial logistica rrhh becarios; do
    printf '%-16s %s\n' "$d" "$(getent group $d | cut -d: -f3)"
done
mountpoint /srv/samba/departamentos && mountpoint /srv/samba/comun
stat -c '%n %U:%G' /srv/samba/departamentos/*
```

- **Por qué:** una ACL se le da **a un grupo**, sobre **una carpeta montada**. Si el grupo no se ve o la carpeta no está montada, estás poniendo permisos en la nada.
- **✅ Bien:** los seis grupos con `3001`-`3006`, los dos volúmenes montados, y cada carpeta a nombre de **su** departamento.
- **❌ Mal:** vuelve a la fase de la que venga — [[Fase_5.7_Resolucion_Problemas|Fase 5]] o [[Fase_6.7_Resolucion_Problemas|Fase 6]].

### **2 · 🔴 LOS OCHO PERMISOS CRUZADOS ESTÁN PUESTOS**

```bash
for d in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "=== $d"
    getfacl -p "/srv/samba/departamentos/$d" 2>/dev/null | grep -E "^(group|default:group):" 
done
```

Compara **casilla por casilla** con la matriz. Esto es lo que tiene que salir:

| Carpeta | Grupos que deben aparecer, además del suyo |
| :--- | :--- |
| `facturacion` | `comercial:r-x` · `contabilidad:rwx` |
| `contabilidad` | **ninguno** |
| `comercial` | `facturacion:r-x` · `contabilidad:r-x` · `logistica:r-x` |
| `logistica` | `contabilidad:r-x` · `comercial:r-x` |
| `rrhh` | **ninguno** |
| `becarios` | `rrhh:r-x` |

- **❌ Falta alguno** → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]] si es la línea `default:`, o repite el Paso 2 si falta entero.

> [!danger] 🛑 Y ahora mira lo contrario: que no SOBRE ninguno
> Un permiso de más es peor que uno de menos. **El de menos se nota enseguida** —alguien no puede trabajar y te llama—. **El de más no lo nota nadie** hasta que alguien ve lo que no debía.
>
> Las dos casillas que tienen que estar **vacías** son las importantes:
> - **`rrhh`** → no debe aparecer **ningún** grupo ajeno. Ni contabilidad.
> - **`contabilidad`** → tampoco.
>
> Si en `rrhh` aparece cualquier cosa, has roto el principio de mínimo privilegio de la empresa.

### **3 · 🔴 LA MÁSCARA NO ESTÁ RECORTANDO NADA**

```bash
getfacl -p /srv/samba/departamentos/* 2>/dev/null | grep "#effective"
```

- **✅ Bien:** **no devuelve nada.**
- **❌ Mal:** cualquier línea → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]]:
  ```bash
  sudo setfacl -m m::rwx /srv/samba/departamentos/<la_carpeta>
  ```

> [!danger] 🛑 Esta es la trampa más fina de toda la fase
> ```
> group:comercial:r-x		#effective:r--
> ```
> **Pone `r-x` y significa `r--`.** El permiso está escrito, es correcto, y no se aplica.
>
> La máscara es un techo general que recorta a todos los grupos de la lista **sin borrarlos**. Si lees la ACL con prisa —y todo el mundo la lee con prisa— ves lo que esperabas ver.
>
> **Lo que está escrito y lo que se aplica pueden ser cosas distintas.** El sistema te lo está diciendo, en una columna que casi nadie mira.

### **4 · LOS DOS CASOS ESPECIALES**

```bash
stat -c '%n  %U:%G  %a' /srv/samba/departamentos/becarios /srv/samba/comun
ls -ld /srv/samba/departamentos/becarios /srv/samba/comun
```

- **✅ Bien:**
  - `becarios` → **`2750`**, y en `ls -ld` se lee `drwxr-s---` *(el grupo con `r-x`, **sin `w`**)*
  - `comun` → **`1777`**, con la **`t`** al final
- **❌ Mal:**
  - `becarios` en `2770` → **pueden escribir y borrar**, y la prueba de la Fase 8 fallará. Vuelve al Paso 3.b
  - `comun` sin la `t` → se perdió el sticky bit de la Fase 6

> [!info] 🎓 Los becarios son la única excepción de la matriz
> Todos los departamentos tienen `RW` sobre lo suyo. **Ellos solo `R`.** Y la Fase 6 creó las siete carpetas iguales, porque allí todavía no había política.
>
> Es el tipo de detalle que se salta con facilidad y que **solo se nota dos fases después**.

### **5 · 🔴 LA CONFIGURACIÓN DE SAMBA ES VÁLIDA**

```bash
sudo testparm
grep -c "^\[" /etc/samba/smb.conf
grep -n "^\[" /etc/samba/smb.conf
```

- **✅ Bien:** `Loaded services file OK`, y **cada sección aparece una sola vez**.
- **❌ Mal:**
  - Error de sintaxis → [[Fase_7.7_Resolucion_Problemas#E1 · samba-ad-dc no arranca tras editar el smb.conf|caso E1]]
  - Una sección repetida → [[Fase_7.7_Resolucion_Problemas#E7 · Secciones duplicadas en smb.conf|caso E7]]

> [!danger] 🛑 En esta fase, reiniciar Samba a ciegas tumba el DOMINIO
> `samba-ad-dc` **es el controlador de dominio**. Si no arranca por una errata en `smb.conf`, se lleva por delante el DNS, Kerberos y LDAP.
>
> **`testparm` es a `smb.conf` lo que `mount -a` era a `fstab`.** Mismo reflejo, otro servicio.

### **6 · LAS SIETE CARPETAS PUBLICADAS, CON SUS OPCIONES**

```bash
for s in facturacion contabilidad comercial logistica rrhh becarios; do
    echo "=== $s"
    testparm -s --section-name="$s" 2>/dev/null | grep -Ei "path|acl_xattr|access based|hide unreadable"
done
testparm -s --section-name=comun 2>/dev/null | grep -Ei "path|acl_xattr"
```

- **✅ Bien:** las **seis** de departamento con las tres opciones —`acl_xattr`, `access based share enum = Yes` y `hide unreadable = Yes`— y `comun` con `acl_xattr`.
- **❌ Mal:** falta alguna → [[Fase_7.7_Resolucion_Problemas#E5 · Una carpeta protegida se ve desde Windows|caso E5]] o [[Fase_7.7_Resolucion_Problemas#E8 · Las ACL desaparecen al copiar ficheros desde Windows|caso E8]].

> [!info] 🎓 `testparm -s` te enseña lo que Samba ENTIENDE
> No lo que tú escribiste. Si has duplicado una sección o te has equivocado de sitio, **aquí se ve** — porque muestra la configuración **efectiva**, ya interpretada.

### **7 · LA HERENCIA FUNCIONA DE VERDAD** *(la prueba que importa)*

Los puntos anteriores dicen que las ACL **están escritas**. Este dice que **hacen algo**:

```bash
sudo touch /srv/samba/departamentos/facturacion/prueba_herencia.txt
getfacl -p /srv/samba/departamentos/facturacion/prueba_herencia.txt
```

- **✅ Bien:** el fichero recién creado **ya lleva** `group:comercial` y `group:contabilidad`, sin que tú se los hayas puesto.
- **❌ Mal:** no los lleva → falta la ACL por defecto → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]].

**Y bórralo:**
```bash
sudo rm -f /srv/samba/departamentos/facturacion/prueba_herencia.txt
```

---

> [!warning] 🛑 LO QUE ESTA LISTA NO PUEDE COMPROBAR
> Todo lo de arriba dice que **el servidor está bien configurado**. Ninguno de esos comandos demuestra que una carpeta sea **invisible** para quien no tiene permiso: eso ocurre en el listado de red que ve un cliente Windows.
>
> **Anota estas cuatro pruebas en tu entrada de apuntes como pendientes.** Las tacharás en la Fase 8:
>
> - [ ] `shinnosuke.nohara` *(becario)* → **no ve** `contabilidad` en el listado de red.
> - [ ] `shinnosuke.nohara` → **no puede borrar** nada en su propia carpeta.
> - [ ] `masao.sato` *(comercial)* → **abre** una factura pero **no puede borrarla**.
> - [ ] `misae.nohara` *(contabilidad)* → **no ve** `rrhh`.
>
> **Una fase que se da por verificada sin haber probado esto está afirmando algo que no ha comprobado.**

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los siete puntos de arriba tú. **En el vídeo tienes que explicarlos.**

> [!example] Cómo se descarga y se ejecuta
> ```bash
> cd ~
> curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase7.sh
> chmod +x verificar_fase7.sh
> less verificar_fase7.sh
> sudo ./verificar_fase7.sh
> ```
> *(El `less` se sale con `q`.)*
>
> **Sube el informe** `verificacion-fase-7.txt` a tu repositorio.

> [!question] 🤔 Para tu entrada de apuntes
> 1. El script tiene una lista `CRUCES` y otra `PROHIBIDOS`. **¿Por qué comprueba también lo que NO debe existir?**
> 2. Anota **dos comprobaciones que hace y que tú no habías hecho a mano**.
> 3. La difícil: **el script dice explícitamente que hay algo que no puede comprobar. ¿Qué es, y por qué no puede?**

---

### ✅ Checklist de este apartado

- [ ] Los seis grupos visibles, los dos volúmenes montados, cada carpeta con su dueño.
- [ ] 🔴 Los **ocho permisos cruzados** puestos, **con su línea `default:`**.
- [ ] 🔴 **`rrhh` y `contabilidad` sin ningún grupo ajeno** en su ACL.
- [ ] 🔴 `getfacl … | grep "#effective"` **no devuelve nada**.
- [ ] `becarios` en **`2750`** *(sin `w` para su grupo)*.
- [ ] `comun` en **`1777`**, con la **`t`**.
- [ ] 🔴 `sudo testparm` → **`Loaded services file OK`**, y ninguna sección duplicada.
- [ ] Las **seis** de departamento con `acl_xattr`, `access based share enum` y `hide unreadable`.
- [ ] Prueba de herencia hecha, y el fichero **borrado** después.
- [ ] Las **cuatro pruebas pendientes de la Fase 8** anotadas en la entrada.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.7_Resolucion_Problemas]] | [[Fase_7]] | [[Fase_7.8.b_Punto_de_Control]] |
