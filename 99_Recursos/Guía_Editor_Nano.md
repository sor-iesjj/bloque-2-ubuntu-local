# Guía de Supervivencia: Editor 'nano'

> **El "Bloc de Notas" de Linux**

En un entorno de servidor sin interfaz gráfica (Headless), no podemos usar ratón. Todo se hace mediante comandos. Para editar archivos de configuración cruciales, utilizamos `nano`, el editor de texto más amigable de la terminal.

---

## 🚀 1. Cómo acceder a Nano

Para abrir o crear un archivo, simplemente escribes el comando `nano` seguido de la ruta del archivo.
Si es un archivo del sistema operativo, necesitarás **permisos de administrador**, por lo que siempre antepondremos `sudo`.

> [!example] Ejemplo: Abrir el archivo de red
> ```bash
> sudo nano /etc/hosts
> ```
> *Si el archivo no existe, `nano` te lo creará e indicará en la parte inferior "Nuevo archivo". Si existe, verás su contenido.*

---

## ⌨️ 2. Mandos de Control (Atajos)

En `nano`, el ratón no existe. Giras las páginas con las **flechas del teclado** (`Arriba`, `Abajo`, `Izquierda`, `Derecha`).

Para realizar acciones, fíjate en la barra inferior de tu pantalla; allí están las chuletas.
> [!important] El símbolo `^`
> En la parte inferior de la pantalla de `nano` verás cosas como `^O` o `^X`.
> El símbolo `^` **significa la tecla Control (`Ctrl`)** en tu teclado. (En Mac es `control ⌃` o `command ⌘` dependiendo de tu terminal).

| Acción Vital | Combinación de Teclas | Notas |
| :--- | :--- | :--- |
| **Guardar (Write Out)** | `Ctrl + O` | Pulsa 'Enter' inmediatamente después para confirmar el nombre. |
| **Salir** | `Ctrl + X` | Si hay cambios sin guardar, te preguntará ('Y' para sí, 'N' para no). |
| **Buscar texto** | `Ctrl + W` | Muy útil en archivos largos (W = "Where is"). Escribe y pulsa 'Enter'. |
| **Cortar línea** | `Ctrl + K` | Borra (corta) la línea entera donde esté el cursor. |
| **Pegar línea** | `Ctrl + U` | Pega la línea que acabas de cortar con `Ctrl + K`. |

---

## 📝 3. Ejercicio Práctico: El Flujo Perfecto

Aprende este ciclo de 4 pasos de memoria; lo harás cientos de veces como Administrador de Sistemas.

> [!tip] 💡 Ciclo Profesional de Edición
> 1. **ABRIR:** `sudo nano /ruta/al/archivo`
> 2. **ESCRIBIR:** Te mueves con flechas, borras con Retroceso (Backspace), escribes tu código nuevo.
> 3. **GUARDAR:** Pulsas `Ctrl + O` y a continuación `Enter` para confirmar. ¡Fíjate que abajo pondrá *"[ Se han escrito X líneas ]"*! Si no lo pone, no se ha guardado.
> 4. **SALIR:** Pulsas `Ctrl + X` para volver a la terminal negra.

> [!caution] ¡Cuidado con el teclado Numérico!
> A veces, el teclado numérico de la derecha de tu teclado físico puede escribir símbolos raros en vez de números dentro de `nano`. Usa siempre los números de la fila superior (encima de QWERTY) para evitar errores fatales en IPs y configuraciones.

> [!tip] 💡 Trabajando desde la ventana de VirtualBox en vez de SSH
> Si estás editando archivos directamente desde la ventana de consola de la VM en VirtualBox (en lugar de por SSH), ten en cuenta que **copiar y pegar texto largo puede fallar o introducir caracteres invisibles** según la versión de VirtualBox y si tienes instalado el "Guest Additions". Si vas a pegar contenido largo (como una clave de WireGuard), prefiere hacerlo por SSH cuando sea posible — es más fiable que la consola gráfica de la VM.
