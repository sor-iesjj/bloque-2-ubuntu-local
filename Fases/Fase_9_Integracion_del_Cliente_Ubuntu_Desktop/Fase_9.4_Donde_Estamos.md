## Fase 9 · Apartado 4 — 📍 Dónde estamos

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Ubuntu Desktop)**
> 🧭 Índice de la fase: [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] 🧭 Punto de partida — todo esto está montado y verificado
> Cuando llegas a esta fase, el laboratorio está así:
>
> | Máquina | SO | IP | Estado |
> | :--- | :--- | :--- | :--- |
> | **Servidor** `UbuntuServer` | Ubuntu Server 26.04 LTS | `10.10.10.10` | Dominio `BOOCHANLAB.LOCAL` + Samba AD DC + carpetas + ACL + ABE (Fases 1-7) |
> | **Cliente** `Windows11` | Windows 11 | `10.10.10.20` | Unido al dominio, RSAT instalado (Fase 8) |
> | **Host** | Tu equipo | — | VirtualBox + Red Solo Anfitrión `10.10.10.0/24` |
>
> **El dominio está completo y la matriz de permisos está probada desde Windows.** Nada de esto se va a tocar en esta fase: el servidor se queda como está.

> [!success] 🎯 Lo que vas a conseguir
> Una **segunda máquina cliente** —`UbuntuDesktop`, con **Ubuntu Desktop 26.04 LTS**— que:
>
> 1. Se **une al dominio** `BOOCHANLAB.LOCAL` (creando su cuenta de equipo, como el Windows).
> 2. **Accede por la red** a las carpetas compartidas del servidor (SMB).
> 3. Ve **exactamente lo que le toca** según la matriz — ni más, ni menos (prueba el ABE desde el lado libre).

> [!warning] ⚠️ La diferencia clave con la Fase 8: el SO cliente ahora es **libre**
> En la Fase 8, Windows era el cliente. Ahora es un Ubuntu Desktop, y la unión al dominio **no se hace con un asistente gráfico de Windows**, sino con herramientas de **Linux**: `realm join` y SSSD. Son dos mundos distintos resolviendo lo mismo — y esa comparación **es la lección de la fase**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_9.3_Obligaciones_Grabacion]] | [[Fase_9_Integracion_del_Cliente_Ubuntu_Desktop]] | [[Fase_9.5_Fundamento_Teorico]] |
