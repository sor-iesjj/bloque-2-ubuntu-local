# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 8 (Integracion del Cliente Windows 11)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red - 2.o SMR - IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba desde el CLIENTE WINDOWS que la union al dominio funciona
#           y que la proteccion de la Fase 7 se comporta como debe.
#           No modifica NADA. Solo lee.
#
# USO (PowerShell como Administrador):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\verificar_fase8.ps1
#
# El informe se guarda en verificacion-fase-8.txt, en la carpeta actual.
#
# OJO: este script se ejecuta en WINDOWS, no en el servidor Ubuntu. Es el unico
#      verificador del proyecto que va en PowerShell, porque es la unica fase
#      cuyo trabajo ocurre en el cliente.
# =============================================================================

$Informe = "verificacion-fase-8.txt"
$Global:Fallos = 0
$Global:Avisos = 0

$Dominio     = "BOOCHANLAB.LOCAL"
$DominioNB   = "BOOCHANLAB"
$IPServidor  = "10.10.10.10"
$IPCliente   = "10.10.10.20"
$Servidor    = "UbuntuServer.BOOCHANLAB.LOCAL"

function Escribe($Texto) { $Texto | Out-File -FilePath $Informe -Append -Encoding utf8 }
function OK($m)    { Write-Host "[OK]    $m" -ForegroundColor Green;  Escribe "[OK]    $m" }
function Fallo($m) { Write-Host "[FALLO] $m" -ForegroundColor Red;    Escribe "[FALLO] $m"; $Global:Fallos++ }
function Aviso($m) { Write-Host "[AVISO] $m" -ForegroundColor Yellow; Escribe "[AVISO] $m"; $Global:Avisos++ }
function Info($m)  { Write-Host "        $m";                          Escribe "        $m" }

"============================================================" | Out-File $Informe -Encoding utf8
Escribe " VERIFICACION DE LA FASE 8 - BoochanV1"
Escribe " Fecha:   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Escribe " Equipo:  $env:COMPUTERNAME"
Escribe " Usuario: $env:USERDOMAIN\$env:USERNAME"
Escribe "============================================================"
Get-Content $Informe | Write-Host

# =============================================================================
# BLOQUE A - RED: EL CLIENTE LLEGA AL SERVIDOR
# =============================================================================
Escribe ""; Escribe "--- A. Red del laboratorio ---"
Write-Host "`n--- A. Red del laboratorio ---"

$ips = (Get-NetIPAddress -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress)
if ($ips -contains $IPCliente) {
    OK "A1. El cliente tiene la IP $IPCliente"
} else {
    Fallo "A1. El cliente NO tiene la IP $IPCliente"
    Info "     IPs encontradas: $($ips -join ', ')"
}

if (Test-Connection -ComputerName $IPServidor -Count 2 -Quiet -ErrorAction SilentlyContinue) {
    OK "A2. El servidor $IPServidor responde al ping"
} else {
    Fallo "A2. El servidor $IPServidor NO responde"
    Info "     Sin red no hay dominio. Mira el caso E1 del apartado 7."
}

# A3. El DNS del cliente TIENE que ser el servidor. Si apunta al router o a
#     Google, la red va y el dominio no aparece: es el fallo mas frecuente.
$dns = (Get-DnsClientServerAddress -AddressFamily IPv4 |
        Select-Object -ExpandProperty ServerAddresses) | Sort-Object -Unique
if ($dns -contains $IPServidor) {
    OK "A3. El DNS del cliente apunta al servidor ($IPServidor)"
} else {
    Fallo "A3. El DNS del cliente NO apunta a $IPServidor"
    Info "     DNS configurados: $($dns -join ', ')"
    Info "     La red funciona y el dominio no se encuentra. Caso E2 del apartado 7."
}

# =============================================================================
# BLOQUE B - EL CLIENTE ENCUENTRA EL DOMINIO
# =============================================================================
Escribe ""; Escribe "--- B. Localizacion del dominio ---"
Write-Host "`n--- B. Localizacion del dominio ---"

try {
    $r = Resolve-DnsName -Name $Dominio -ErrorAction Stop
    $ipDom = ($r | Where-Object { $_.IPAddress } | Select-Object -First 1).IPAddress
    if ($ipDom -eq $IPServidor) {
        OK "B1. $Dominio resuelve a $IPServidor"
    } else {
        Fallo "B1. $Dominio resuelve a $ipDom, deberia ser $IPServidor"
        Info "     El dominio se anuncio en la tarjeta equivocada: esto viene de la FASE 4."
    }
} catch {
    Fallo "B1. No se puede resolver $Dominio"
    Info "     Revisa el DNS del cliente (A3) y que el servidor este encendido."
}

# B2. Los registros SRV son como Windows localiza al controlador de dominio.
try {
    $srv = Resolve-DnsName -Name "_ldap._tcp.$Dominio" -Type SRV -ErrorAction Stop
    if ($srv) { OK "B2. Registros SRV del dominio publicados" }
} catch {
    Fallo "B2. No hay registros SRV - Windows no sabra donde esta el controlador"
    Info "     Esto viene de la Fase 4."
}

# =============================================================================
# BLOQUE C - LA UNION AL DOMINIO
# =============================================================================
Escribe ""; Escribe "--- C. Union al dominio ---"
Write-Host "`n--- C. Union al dominio ---"

$cs = Get-CimInstance Win32_ComputerSystem
if ($cs.PartOfDomain) {
    OK "C1. El equipo esta unido al dominio: $($cs.Domain)"
    if ($cs.Domain -notlike "*$DominioNB*") {
        Aviso "C1-bis. El dominio no coincide con $Dominio - revisalo"
    }
} else {
    Fallo "C1. El equipo NO esta unido a ningun dominio (grupo de trabajo: $($cs.Workgroup))"
    Info "     Repite el Paso 3 del procedimiento."
}

# C2. La sesion actual tiene que ser de un usuario DEL DOMINIO. Si es local,
#     las comprobaciones de permisos de mas abajo no valen nada.
if ($env:USERDOMAIN -eq $DominioNB) {
    OK "C2. La sesion actual es del usuario de dominio $env:USERDOMAIN\$env:USERNAME"
} else {
    Fallo "C2. Has iniciado sesion como usuario LOCAL ($env:USERDOMAIN\$env:USERNAME)"
    Info "     Cierra sesion y entra como $DominioNB\user1 antes de verificar nada mas."
}

# =============================================================================
# BLOQUE D - KERBEROS Y EL RELOJ
# =============================================================================
# Kerberos rechaza cualquier autenticacion con mas de 5 minutos de desfase, y
# el error que da NO menciona la hora por ningun sitio.
Escribe ""; Escribe "--- D. Kerberos y sincronizacion horaria ---"
Write-Host "`n--- D. Kerberos y sincronizacion horaria ---"

$tickets = (klist 2>&1 | Out-String)
if ($tickets -match "krbtgt/") {
    OK "D1. Hay tickets de Kerberos: la autenticacion es Kerberos, no NTLM"
} else {
    Aviso "D1. No se ven tickets krbtgt - puede que estes autenticando por NTLM"
    Info "     Conectate al servidor por NOMBRE, no por IP, para que use Kerberos."
}

try {
    $strip = (w32tm /stripchart /computer:$IPServidor /samples:1 /dataonly 2>&1 | Out-String)
    if ($strip -match "([+-]?\d+[\.,]\d+)s") {
        $desfase = [math]::Abs([double]($Matches[1] -replace ',', '.'))
        if ($desfase -lt 120) {
            OK ("D2. Desfase horario con el servidor: {0:N1} s (dentro del margen)" -f $desfase)
        } elseif ($desfase -lt 300) {
            Aviso ("D2. Desfase de {0:N0} s - cerca del limite de Kerberos (300 s)" -f $desfase)
            Info "     Ejecuta: w32tm /resync /force"
        } else {
            Fallo ("D2. Desfase de {0:N0} s - Kerberos RECHAZARA la autenticacion" -f $desfase)
            Info "     Arreglo: w32tm /resync /force. Caso E3 del apartado 7."
        }
    } else {
        Aviso "D2. No se ha podido medir el desfase horario"
    }
} catch {
    Aviso "D2. No se ha podido consultar la hora del servidor"
}

# =============================================================================
# BLOQUE E - LO QUE VIENE DE LA FASE 7: LA INVISIBILIDAD (ABE)
# =============================================================================
# ESTE ES EL BLOQUE QUE NO SE PODIA COMPROBAR EN LA FASE 7.
# Depende de QUIEN ha iniciado sesion:
#   - user1 (grupo policia) -> DEBE ver prueba3
#   - user2 (no es del grupo) -> NO DEBE verla siquiera
Escribe ""; Escribe "--- E. Recursos compartidos y ABE (prueba de la Fase 7) ---"
Write-Host "`n--- E. Recursos compartidos y ABE (prueba de la Fase 7) ---"

$vista = (net view "\\$Servidor" 2>&1 | Out-String)
$vePrueba1 = $vista -match "prueba1"
$vePrueba3 = $vista -match "prueba3"

if ($vePrueba1) {
    OK "E1. El recurso 'prueba1' es visible (lo es para todos)"
} else {
    Fallo "E1. No se ve 'prueba1' - revisa que el servidor publique el recurso"
}

Info ""
Info "     ATENCION: el resultado correcto de E2 DEPENDE de con quien has entrado."
Info "     Sesion actual: $env:USERDOMAIN\$env:USERNAME"
Info ""

if ($env:USERNAME -eq "user1") {
    if ($vePrueba3) {
        OK "E2. Con user1 (grupo policia) SE VE 'prueba3' - correcto"
    } else {
        Fallo "E2. Con user1 NO se ve 'prueba3' - deberia verlo"
        Info "     Comprueba que user1 sigue en el grupo policia (Fase 5)."
    }
} elseif ($env:USERNAME -eq "user2") {
    if ($vePrueba3) {
        Fallo "E2. Con user2 SE VE 'prueba3' - LA INVISIBILIDAD NO FUNCIONA"
        Info "     Puede entrar? No. Pero sabe que existe, y eso ya es informacion."
        Info "     El fallo esta en la FASE 7: falta 'access based share enum'."
        Info "     Mira el caso E6 del apartado 7 de esta fase."
    } else {
        OK "E2. Con user2 NO se ve 'prueba3' - LA INVISIBILIDAD FUNCIONA"
        Info "     Esta es la prueba que quedo pendiente en la Fase 7. Tachala."
    }
} else {
    Aviso "E2. Sesion iniciada con '$env:USERNAME': no se puede juzgar el ABE"
    Info "     La prueba hay que hacerla DOS VECES: una con user1 y otra con user2."
}

# E3. La unidad de red mapeada.
$z = Get-PSDrive -Name Z -ErrorAction SilentlyContinue
if ($z) {
    OK "E3. La unidad Z: esta mapeada ($($z.DisplayRoot))"
} else {
    Aviso "E3. No hay unidad Z: mapeada en esta sesion"
    Info "     Si la mapeaste sin /persistent:yes, se pierde al cerrar sesion. Caso E4."
}

# =============================================================================
# VEREDICTO
# =============================================================================
Escribe ""; Escribe "============================================================"
Write-Host "`n============================================================"
if ($Global:Fallos -eq 0 -and $Global:Avisos -eq 0) {
    Write-Host " VEREDICTO: FASE 8 SUPERADA" -ForegroundColor Green
    Escribe " VEREDICTO: FASE 8 SUPERADA"
} elseif ($Global:Fallos -eq 0) {
    Write-Host " VEREDICTO: FASE 8 SUPERADA CON $($Global:Avisos) AVISO(S)" -ForegroundColor Yellow
    Escribe " VEREDICTO: FASE 8 SUPERADA CON $($Global:Avisos) AVISO(S)"
    Escribe " Un aviso no impide seguir, pero LEELO: mira arriba cual es."
} else {
    Write-Host " VEREDICTO: FASE 8 NO SUPERADA - $($Global:Fallos) FALLO(S)" -ForegroundColor Red
    Escribe " VEREDICTO: FASE 8 NO SUPERADA - $($Global:Fallos) FALLO(S)"
    Escribe " Busca cada caso en Fase_8.7_Resolucion_Problemas."
}
Escribe "============================================================"
Write-Host "============================================================"

Escribe ""
Escribe "ESTE SCRIPT NO HA COMPROBADO:"
Escribe "  - La prueba de ABE con los DOS usuarios (hay que ejecutarlo dos veces)"
Escribe "  - Que exista la instantanea 'Fase 8 terminada' del cliente"
Escribe "  - Que RSAT este instalado y funcione"
Escribe ""
Escribe "IMPORTANTE: ejecuta este script DOS VECES, una con cada usuario:"
Escribe "  1) Sesion con BOOCHANLAB\user1  -> debe VER prueba3"
Escribe "  2) Sesion con BOOCHANLAB\user2  -> NO debe verla"
Escribe "Guarda los DOS informes. Esa pareja es la prueba de la Fase 7."

Write-Host "`nInforme guardado en: $(Join-Path (Get-Location) $Informe)"
Write-Host "Subelo a tu repositorio junto con la entrada de apuntes."
Write-Host "RECUERDA: hay que ejecutarlo DOS VECES, con user1 y con user2." -ForegroundColor Cyan

if ($Global:Fallos -eq 0) { exit 0 } else { exit 1 }
