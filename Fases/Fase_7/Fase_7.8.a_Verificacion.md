## Fase 7 · Apartado 8.a — 🔍 Verificación del trabajo

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Seguridad Avanzada (ACLs y ABE)**
> 🧭 Índice de la fase: [[Fase_7]]
>
> **📍 Cuándo se lee:** **Al terminar el procedimiento**, con la grabación aún en marcha. **Antes** de tomar la instantánea.

---

> [!danger] 🛑 PRIMERO SE VERIFICA. DESPUÉS SE GUARDA
> Una instantánea es tu **punto de retorno**. Si guardas un trabajo mal hecho, cada vez que restaures volverás **al mismo problema** — y encima con la tranquilidad de creer que estabas en un sitio bueno.
>
> Aquí compruebas. En el [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] guardas.

> [!danger] ⚠️ Esta fase tiene una peculiaridad: NO se puede verificar entera desde aquí
> La mitad del trabajo es **hacer invisible** una carpeta para quien no tiene permiso. Y la invisibilidad **solo se ve desde el cliente Windows**, que es la Fase 8.
>
> Lo que sí puedes comprobar aquí es que el servidor está **correctamente configurado para ello**. Es lo que hace esta lista, y el punto 6 te dice explícitamente qué queda pendiente.
>
> **No confundas "el servidor está bien configurado" con "la protección funciona".** Lo segundo se demuestra en la Fase 8.

> [!bug] 🛑 Si administras por SSH: confirma primero DÓNDE estás
> ```bash
> hostname
> ```
> Tiene que responder **`ubuntuserver`** → si no, [[Fase_4.7_Resolucion_Problemas#E11 · Los comandos me responden pero contestan mal|caso E11 de la Fase 4]].

> Todos los comandos de aquí **solo leen**. Ninguno modifica nada.

### **1 · LA BASE DE LAS FASES 5 Y 6 SIGUE EN PIE**

```bash
getent group policia
mountpoint /srv/samba/prueba3
ls -ld /srv/samba/prueba3
```

- **Por qué:** una ACL se le da **a un grupo**, sobre **una carpeta montada**. Si el grupo no se ve o la carpeta no está montada, estás poniendo permisos en la nada.
- **✅ Bien:** el grupo con GID `3001`, la carpeta es punto de montaje, y pertenece a `root policia`.
- **❌ Mal:** vuelve a la fase de la que venga el fallo — [[Fase_5.7_Resolucion_Problemas|Fase 5]] o [[Fase_6.7_Resolucion_Problemas|Fase 6]].

> [!info] 🎓 Aquí se nota que las fases se sostienen unas a otras
> Estás poniendo seguridad avanzada sobre una carpeta que existe gracias a la Fase 6, para un grupo que existe gracias a la Fase 5, en un dominio que existe gracias a la Fase 4. **Verificar hacia atrás antes de verificar lo tuyo** te ahorra buscar en el sitio equivocado.

### **2 · 🔴 LA ACL DICE LO QUE CREES, Y ADEMÁS SE APLICA**

```bash
getfacl -p /srv/samba/prueba3
```

- **✅ Bien:** aparecen estas dos líneas, **sin ninguna coletilla al final**:
  ```
  group:policia:rwx
  default:group:policia:rwx
  ```
- **❌ Mal:**
  - No hay línea `default:` → los ficheros nuevos no heredarán → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]]
  - Pone `#effective:r--` al final → **la máscara lo está recortando** → [[Fase_7.7_Resolucion_Problemas#E6 · getfacl dice effective y el permiso no se aplica|caso E6]]

> [!danger] 🛑 Mira la columna de la derecha, no solo la de la izquierda
> Esta es la trampa más fina de toda la fase:
> ```
> group:policia:rwx		#effective:r--
> ```
> **Pone `rwx` y significa `r--`.** El permiso está escrito en la lista y la máscara lo recorta. Si lees la ACL por encima, ves lo que esperabas ver y sigues adelante.
>
> **Lo que está escrito y lo que se aplica pueden ser cosas distintas** — y el sistema te lo está diciendo, en una columna que hay que saber mirar.

### **3 · 🔴 LA CONFIGURACIÓN DE SAMBA ES VÁLIDA**

```bash
sudo testparm
```

- **Qué hace:** valida `/etc/samba/smb.conf` **sin reiniciar nada**. Pulsa `Enter` cuando pregunte.
- **✅ Bien:** `Loaded services file OK` y te muestra la configuración.
- **❌ Mal:** te dice **la línea exacta** del error → [[Fase_7.7_Resolucion_Problemas#E1 · samba-ad-dc no arranca tras editar el smb.conf|caso E1]].

> [!danger] 🛑 En esta fase, reiniciar Samba a ciegas tumba el DOMINIO
> `samba-ad-dc` no es solo el servidor de ficheros: **es el controlador de dominio**. Si no arranca por una errata en `smb.conf`, se lleva por delante el DNS, Kerberos y LDAP.
>
> **`testparm` es a `smb.conf` lo que `mount -a` era a `fstab`.** El mismo reflejo, otro servicio: se valida antes de reiniciar, no después de romper.

Y comprueba que no has duplicado nada:
```bash
grep -n "^\[prueba" /etc/samba/smb.conf
```
- **✅ Bien:** una sola línea por recurso. Si sale dos veces → [[Fase_7.7_Resolucion_Problemas#E7 · Secciones duplicadas en smb.conf|caso E7]].

### **4 · LOS RECURSOS ESTÁN PUBLICADOS CON SUS OPCIONES**

```bash
testparm -s --section-name=prueba3
```

- **✅ Bien:** aparecen las tres:
  - `access based share enum = Yes` *(oculta el recurso a quien no tiene acceso)*
  - `hide unreadable = Yes` *(oculta el contenido que no se puede abrir)*
  - `vfs objects = acl_xattr` *(guarda los permisos de Windows en Linux)*
- **❌ Mal:** falta alguna → [[Fase_7.7_Resolucion_Problemas#E5 · La carpeta protegida se ve desde Windows|caso E5]] o [[Fase_7.7_Resolucion_Problemas#E8 · Las ACL desaparecen al copiar ficheros desde Windows|caso E8]].

> [!info] 🎓 `testparm -s` te enseña lo que Samba ENTIENDE
> No lo que tú escribiste. Si has duplicado una sección o te has equivocado de sitio, aquí se ve — porque muestra la configuración **efectiva**, ya interpretada.

### **5 · EL DOMINIO SIGUE VIVO DESPUÉS DEL CAMBIO**

```bash
systemctl is-active samba-ad-dc
host -t A ubuntuserver.boochanlab.local 127.0.0.1
id user1
```

- **Por qué:** acabas de reiniciar el servicio que sostiene el dominio. Comprueba que volvió entero, no solo que arrancó.
- **✅ Bien:** `active`, el `host` devuelve `10.10.10.10`, e `id user1` sigue dando `uid=10001`.

### **6 · LA HERENCIA FUNCIONA DE VERDAD** *(la prueba que importa)*

Los puntos anteriores dicen que la ACL **está escrita**. Este dice que **hace algo**:

```bash
sudo touch /srv/samba/prueba3/prueba_herencia.txt
getfacl -p /srv/samba/prueba3/prueba_herencia.txt
```

- **✅ Bien:** el fichero recién creado **ya lleva** `group:policia:rwx`, sin que tú se lo hayas puesto.
- **❌ Mal:** no lo lleva → falta la ACL por defecto → [[Fase_7.7_Resolucion_Problemas#E4 · Los ficheros nuevos no heredan los permisos|caso E4]].

**Y bórralo, que no se quede ahí:**
```bash
sudo rm -f /srv/samba/prueba3/prueba_herencia.txt
```

> [!warning] 🛑 LO QUE ESTA LISTA NO PUEDE COMPROBAR
> Todo lo de arriba dice que **el servidor está bien configurado**. Ninguno de esos comandos demuestra que la carpeta sea **invisible** para quien no tiene permiso, porque la invisibilidad ocurre en el listado de red que ve un cliente Windows.
>
> **Queda pendiente para la Fase 8, y son dos pruebas concretas:**
> 1. Entrar con `user1` *(del grupo `policia`)* → **ve `prueba3` y puede entrar**.
> 2. Entrar con `user2` *(que no es del grupo)* → **`prueba3` no aparece siquiera en la lista**.
>
> **Anota estas dos pruebas en tu entrada de apuntes ahora**, como pendientes. En la Fase 8 las tacharás.

---

## 🤖 Confirmación automática *(opcional, y después de hacerlo a mano)*

> [!warning] 🛑 El script NO sustituye a las comprobaciones
> Haz los seis puntos de arriba tú, comando a comando. **En el vídeo tienes que explicarlos** — no enseñar que un script pone OK.

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
> **Sube el informe** `verificacion-fase-7.txt` a tu repositorio, junto con la entrada de apuntes.

> [!question] 🤔 Para tu entrada de apuntes
> 1. Anota **dos comprobaciones que hace el script y que tú no habías hecho a mano**.
> 2. Y una más difícil: **el script dice explícitamente que hay algo que NO puede comprobar. ¿Qué es, y por qué no puede?**

---

### ✅ Checklist de este apartado

- [ ] `getent group policia` y `mountpoint /srv/samba/prueba3` responden bien.
- [ ] 🔴 `getfacl` muestra `group:policia:rwx` **sin `#effective`**.
- [ ] 🔴 `getfacl` muestra `default:group:policia:rwx`.
- [ ] 🔴 `sudo testparm` → **`Loaded services file OK`**.
- [ ] `grep "^\[prueba"` → **una sola línea por recurso**.
- [ ] `[prueba3]` con `access based share enum`, `hide unreadable` y `acl_xattr`.
- [ ] `samba-ad-dc` sigue `active` y el dominio responde.
- [ ] Prueba de herencia hecha: el fichero nuevo lleva la ACL, **y borrado después**.
- [ ] Las **dos pruebas pendientes de la Fase 8** anotadas en la entrada.
- [ ] *(Opcional)* Script descargado, leído, ejecutado e informe subido al repositorio.

> [!success] ✅ Con todo en verde, pasa al [[Fase_7.8.b_Punto_de_Control|apartado 8.b]] y guarda la instantánea.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_7.7_Resolucion_Problemas]] | [[Fase_7]] | [[Fase_7.8.b_Punto_de_Control]] |
