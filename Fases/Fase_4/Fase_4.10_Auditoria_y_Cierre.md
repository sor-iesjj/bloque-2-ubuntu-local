## Fase 4 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría y Evaluación (RA.03)
> **Peligro Crítico:** Si el DNS vuelve a apuntar a otro sitio en lugar de a `127.0.0.1`, los ordenadores dirán "No se encuentra el dominio" y nadie podrá iniciar sesión.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de ejecutar las verificaciones, instala las herramientas de diagnóstico DNS (no vienen preinstaladas en Ubuntu Server):
> ```bash
> sudo apt install dnsutils -y
> ```
> - [ ] ¿Responde `samba-tool domain level show` sin errores?
> - [ ] ¿El comando `nslookup _kerberos._tcp.BOOCHANLAB.LOCAL` devuelve la IP correcta?
> - [ ] ¿`host -t A ubuntuserver.boochanlab.local` devuelve **`10.10.10.10`** — y NO una `10.0.2.x`? *(Si sale la de la NAT, ve a la tabla de troubleshooting: es un fallo silencioso que reventaría la Fase 8.)*
> - [ ] 💾 **Instantánea `Fase 4 terminada` tomada** en VirtualBox, con la VM apagada y **grabándolo**.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.9_Preguntas]] | [[Fase_4]] | **Fase 5** |
