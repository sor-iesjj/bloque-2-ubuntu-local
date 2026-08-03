## Fase 4 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿El dominio no nace?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Error `Realm not found`. | El archivo `/etc/krb5.conf` no está bien configurado. | Copia el generado por Samba: `sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf`. |
> | No resuelve al `127.0.0.1`. | `systemd-resolved` está secuestrando el DNS. | Primero desbloquea el fichero: `sudo chattr -i /etc/resolv.conf` (sin esto, el siguiente `rm` falla con `Operation not permitted`). Luego `sudo rm /etc/resolv.conf`, reescribe: `echo "nameserver 127.0.0.1" \| sudo tee /etc/resolv.conf`, y vuelve a bloquear: `sudo chattr +i /etc/resolv.conf`. |
> | El script para con `ERROR: falta el paquete 'samba-ad-dc'` (o `samba-ad-provision`). | La Fase 2 se hizo con una versión antigua del material, o restauraste una instantánea anterior a su instalación. | Es el script **protegiéndote**: instala lo que pide — `sudo apt install -y samba-ad-dc samba-ad-provision` — y relánzalo. Recuerda restaurar el DNS primero si no tienes internet: `sudo chattr -i /etc/resolv.conf && echo "nameserver 8.8.8.8" \| sudo tee /etc/resolv.conf`. |
> | `host -t A ubuntuserver.boochanlab.local` devuelve una `10.0.2.x` en vez de `10.10.10.10`. | El dominio se aprovisionó sin `--host-ip` y Samba eligió la tarjeta NAT. El dominio "funciona"… pero nadie podrá encontrarlo, y la Fase 8 fallará con "No se encuentra el dominio". | **Borra el registro malo usando la IP exacta que te haya devuelto el `host`** (no la copies de aquí, mira la tuya) y añade el bueno:<br>`sudo samba-tool dns delete 127.0.0.1 boochanlab.local ubuntuserver A LA_IP_QUE_TE_SALIO -U Administrator`<br>`sudo samba-tool dns add 127.0.0.1 boochanlab.local ubuntuserver A 10.10.10.10 -U Administrator`<br>Vuelve a comprobar con `host`. |
> | El script falla en `git clone` por falta de red. | El adaptador NAT no está activo o `git` intenta usar la Red Solo Anfitrión (sin salida a internet). | Comprueba `ping 8.8.8.8` antes de clonar; revisa el adaptador NAT en `Configuración de la VM → Red`. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.6_Procedimiento]] | [[Fase_4]] | [[Fase_4.8_Punto_de_Control]] |
