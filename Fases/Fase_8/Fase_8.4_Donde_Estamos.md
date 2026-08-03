## Fase 8 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 7
> El servidor Linux es ahora un "reino" completo: dominio `BOOCHANLAB.LOCAL`, usuarios, grupos, discos protegidos, y permisos granulares. Todo está funcionando perfectamente desde la terminal. Sin embargo, todavía no existe ningún cliente que se beneficie de ese dominio — solo hay una VM en VirtualBox: el servidor. Ahora toca crear una **segunda VM**, esta vez con Windows 11, para que los usuarios del aula tengan un puesto de trabajo real.

> [!warning] El Problema
> Windows y Linux hablan idiomas diferentes de seguridad. Windows necesita: (1) encontrar el servidor por DNS, (2) sincronizar el reloj exactamente (Kerberos rechaza diferencias > 5 minutos), (3) establecer una "relación de confianza" registrándose en Active Directory, (4) permitir que los usuarios inicien sesión con sus credenciales de dominio. Si algo falla, el usuario ve "No se encuentra el dominio" o "Error de relación de confianza".

> [!success] Objetivo de esta Fase
> **Crear una VM de Windows 11 en VirtualBox y unirla al dominio BOOCHANLAB.LOCAL**, de forma que los usuarios puedan iniciar sesión con sus credenciales de dominio (ej. `BOOCHANLAB\user1`) y acceder a las carpetas compartidas del servidor con los permisos que se les asignaron en Linux. Es el momento de la verdad: la infraestructura híbrida (Linux servidor + Windows cliente), ambas viviendo como VMs dentro del mismo VirtualBox, funcionando en sinergia.

> [!tip] Hoja de Ruta
> 1. **Crear la VM cliente:** Windows 11, 4 GB RAM, 40 GB de disco, dos adaptadores de red (Red Solo Anfitrión + NAT)
> 2. **Instalar Windows 11** en la nueva VM (si no la tenías ya preparada)
> 3. **Configurar IP y DNS:** IP fija `10.10.10.20` en el adaptador de Red Solo Anfitrión, DNS apuntando a `10.10.10.10` (el servidor)
> 4. **Sincronizar reloj:** Ejecutar `w32tm /resync /force` para emparejar la hora exactamente con el servidor
> 5. **Unir al dominio:** A través de Configuración → Sistema → Acerca de, introducir `BOOCHANLAB.LOCAL` y credenciales de Administrator
> 6. **Reiniciar Windows:** Obligatorio para aplicar los cambios de dominio
> 7. **Primer login:** Iniciar sesión con `BOOCHANLAB\user1` y su contraseña desde la pantalla de inicio
> 8. **Instalar RSAT:** Herramientas administrativas para gestionar usuarios/grupos desde Windows gráficamente
> 9. **Mapear carpetas de red:** Conectar `\\UbuntuServer.BOOCHANLAB.LOCAL\prueba1` y `prueba3` como unidades de red (Z:, por ejemplo)
>
> **Resultado Final:** Windows 11 es ahora un cliente legítimo del dominio, viviendo como una VM más dentro de tu VirtualBox local. Los usuarios pueden iniciar sesión, acceder a carpetas según sus permisos de grupo, y crear archivos que el servidor Linux reconoce automáticamente.
> **Siguiente:** Fase completada — el proyecto es funcional de extremo a extremo. Servidor Linux como DC, usuarios en AD, almacenamiento seguro, y clientes Windows integrados. Solo queda la Auditoría Final de seguridad.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.3_Obligaciones_Grabacion]] | [[Fase_8]] | [[Fase_8.5_Fundamento_Teorico]] |
