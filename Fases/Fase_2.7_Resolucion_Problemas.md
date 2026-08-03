## Fase 2 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Fase 2: Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿Algo no va bien?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `apt purge` no encuentra Samba. | Samba no estaba instalado o ya lo borraste. | No te preocupes, verifica con `dpkg -l \| grep samba`. Si está vacío, perfecto. |
> | En el **Paso 1B** (antes del Paso 2), `systemctl status smbd` sigue diciendo `active (running)`. | El servicio seguía arrancado, o la purga no incluyó todos los paquetes. | Ejecuta el Paso 1A **entero y en orden**: primero el `systemctl stop`, después el `purge` con la lista completa. |
> | **Al ACABAR la fase**, `systemctl status smbd` dice `active (running)`. | **Ninguna: es lo correcto.** El Paso 2 reinstaló Samba a propósito. | No toques nada. La Fase 4 lo desactiva ella sola antes de levantar el dominio. |
> | Purgué con `samba*` y `winbind` sigue instalado. | El comodín solo caza lo que empieza por "samba". | Usa la lista explícita del Paso 1A, que incluye `winbind`, `libnss-winbind` y `libpam-winbind`. |
> | `ss` sigue mostrando algo en el 445 después de purgar. | Un proceso quedó vivo aunque el paquete se borrara. | `sudo ss -tlnp \| grep :445` te dice **qué proceso** lo ocupa. Páralo con `sudo systemctl stop <servicio>` y vuelve a comprobar. |
> | El nombre del servidor es incorrecto. | Error de escritura en `/etc/hostname` o `/etc/hosts`. | Ejecuta `hostname -f`. Debe devolver `UbuntuServer.BOOCHANLAB.LOCAL`. |
> | La pantalla azul de Kerberos no aparece. | Ya está configurado de una instalación anterior. | Ejecuta `sudo dpkg-reconfigure krb5-config` para reconfigurarlo. |
> | `apt update` no descarga nada / sin internet. | El adaptador NAT no está conectado o mal configurado. | En VirtualBox: `Configuración de la VM → Red → Adaptador 1` debe estar habilitado y en modo `NAT`. Reinicia la VM tras el cambio. |
> | `hostname -I` no muestra `10.10.10.10`. | La configuración estática de netplan de la Fase 1 no se aplicó o se perdió. | Revisa el archivo `.yaml` en `/etc/netplan/` y ejecuta `sudo netplan apply`. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.6_Procedimiento]] | [[Fase_2]] | [[Fase_2.8_Punto_de_Control]] |
