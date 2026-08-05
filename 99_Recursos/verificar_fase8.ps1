# =============================================================================
# BOOCHAN V1 - Verificacion de la Fase 8 (Integracion del Cliente Windows 11)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red - 2.o SMR - IES Jorge Juan (Alicante)
#
# QUE HACE: comprueba desde el CLIENTE WINDOWS que la union al dominio funciona
#           y que CADA TRABAJADOR ve exactamente las carpetas que le tocan
#           segun la matriz de Boochan S.L. No modifica NADA. Solo lee.
#
# USO (PowerShell como Administrador):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\verificar_fase8.ps1
#
# IMPORTANTE: hay que ejecutarlo con VARIOS usuarios distintos. El script sabe
#             que debe ver cada uno y juzga en consecuencia.
#
# Matriz completa: 99_Recursos/Escenario_Boochan_SL.md
# =============================================================================

$Informe = "verificacion-fase-8-$env:USERNAME.txt"
$Global:Fallos = 0
$Global:Avisos = 0

$Dominio    = "BOOCHANLAB.LOCAL"
$DominioNB  = "BOOCHANLAB"
$IPServidor = "10.10.10.10"
$IPCliente  = "10.10.10.20"
$Servidor   = "UbuntuServer.BOOCHANLAB.LOCAL"

# --- LA MATRIZ, vista desde el cliente ---------------------------------------
# Para cada trabajador: que recursos DEBE ver en el listado de red.
# Todo lo que no este en su lista NO debe aparecer siquiera (eso es el ABE).
$Matriz = @{
  "hiroshi.nohara"    = @("facturacion","comercial","comun")
  "nene.sakurada"     = @("facturacion","comercial","comun")
  "misae.nohara"      = @("facturacion","contabilidad","comercial","logistica","comun")
  "toru.kazama"       = @("facturacion","contabilidad","comercial","logistica","comun")
  "masao.sato"        = @("facturacion","comercial","logistica","comun")
  "ai.suotome"        = @("facturacion","comercial","logistica","comun")
  "bo.suzuki"         = @("comercial","logistica","comun")
  "midori.yoshinaga"  = @("comercial","logistica","comun")
  "ume.matsuzaka"     = @("rrhh","becarios","comun")
  "bunta.takakura"    = @("rrhh","becarios","comun")
  "shinnosuke.nohara" = @("becarios")
  "himawari.nohara"   = @("becarios")
}
$TodosLosRecursos = @("facturacion","contabilidad","comercial","logistica","rrhh","becarios","comun")

function Escribe($Texto) { $Texto | Out-File -FilePath $Informe -Append -Encoding utf8 }
function OK($m)    { Write-Host "[OK]    $m" -ForegroundColor Green;  Escribe "[OK]    $m" }
function Fallo($m) { Write-Host "[FALLO] $m" -ForegroundColor Red;    Escribe "[FALLO] $m"; $Global:Fallos++ }
function Aviso($m) { Write-Host "[AVISO] $m" -ForegroundColor Yellow; Escribe "[AVISO] $m"; $Global:Avisos++ }
function Info($m)  { Write-Host "        $m";                          Escribe "        $m" }

"============================================================" | Out-File $Informe -Encoding utf8
Escribe " VERIFICACION DE LA FASE 8 - BoochanV1"
Escribe " Escenario: Boochan S.L. - vista desde el cliente Windows"
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
if ($ips -contains $IPCliente) { OK "A1. El cliente tiene la IP $IPCliente" }
else {
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
if ($dns -contains $IPServidor) { OK "A3. El DNS del cliente apunta al servidor" }
else {
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
    if ($ipDom -eq $IPServidor) { OK "B1. $Dominio resuelve a $IPServidor" }
    else {
        Fallo "B1. $Dominio resuelve a $ipDom, deberia ser $IPServidor"
        Info "     El dominio se anuncio en la tarjeta equivocada: esto viene de la FASE 4."
    }
} catch {
    Fallo "B1. No se puede resolver $Dominio"
    Info "     Revisa el DNS del cliente (A3) y que el servidor este encendido."
}

try {
    $srv = Resolve-DnsName -Name "_ldap._tcp.$Dominio" -Type SRV -ErrorAction Stop
    if ($srv) { OK "B2. Registros SRV del dominio publicados" }
} catch {
    Fallo "B2. No hay registros SRV - Windows no sabra donde esta el controlador"
    Info "     Esto viene de la Fase 4."
}

# =============================================================================
# BLOQUE C - LA UNION AL DOMINIO Y QUIEN ERES
# =============================================================================
Escribe ""; Escribe "--- C. Union al dominio ---"
Write-Host "`n--- C. Union al dominio ---"

$cs = Get-CimInstance Win32_ComputerSystem
if ($cs.PartOfDomain) { OK "C1. El equipo esta unido al dominio: $($cs.Domain)" }
else {
    Fallo "C1. El equipo NO esta unido a ningun dominio (grupo de trabajo: $($cs.Workgroup))"
    Info "     Repite el Paso 3 del procedimiento."
}

# C2. La sesion tiene que ser de un TRABAJADOR del escenario. Si es local o de
#     otro usuario, el bloque E no puede juzgar nada.
$Usuario = $env:USERNAME
if ($env:USERDOMAIN -eq $DominioNB) {
    OK "C2. Sesion de dominio: $env:USERDOMAIN\$Usuario"
    if (-not $Matriz.ContainsKey($Usuario)) {
        Aviso "C2-bis. '$Usuario' no es uno de los 12 trabajadores del escenario"
        Info "     El bloque E no podra juzgar que deberias ver."
    }
} else {
    Fallo "C2. Has iniciado sesion como usuario LOCAL ($env:USERDOMAIN\$Usuario)"
    Info "     Cierra sesion y entra como $DominioNB\<trabajador> antes de seguir."
}

# =============================================================================
# BLOQUE D - KERBEROS Y EL RELOJ
# =============================================================================
# Kerberos rechaza cualquier autenticacion con mas de 5 minutos de desfase, y
# el error que da NO menciona la hora por ningun sitio.
Escribe ""; Escribe "--- D. Kerberos y sincronizacion horaria ---"
Write-Host "`n--- D. Kerberos y sincronizacion horaria ---"

$tickets = (klist 2>&1 | Out-String)
if ($tickets -match "krbtgt/") { OK "D1. Hay tickets de Kerberos: autenticacion Kerberos, no NTLM" }
else {
    Aviso "D1. No se ven tickets krbtgt - puede que estes autenticando por NTLM"
    Info "     Conectate al servidor por NOMBRE, no por IP, para que use Kerberos."
}

try {
    $strip = (w32tm /stripchart /computer:$IPServidor /samples:1 /dataonly 2>&1 | Out-String)
    if ($strip -match "([+-]?\d+[\.,]\d+)s") {
        $desfase = [math]::Abs([double]($Matches[1] -replace ',', '.'))
        if ($desfase -lt 120) {
            OK ("D2. Desfase horario: {0:N1} s (dentro del margen)" -f $desfase)
        } elseif ($desfase -lt 300) {
            Aviso ("D2. Desfase de {0:N0} s - cerca del limite de Kerberos (300 s)" -f $desfase)
            Info "     Ejecuta: w32tm /resync /force"
        } else {
            Fallo ("D2. Desfase de {0:N0} s - Kerberos RECHAZARA la autenticacion" -f $desfase)
            Info "     Arreglo: w32tm /resync /force. Caso E3 del apartado 7."
        }
    } else { Aviso "D2. No se ha podido medir el desfase horario" }
} catch { Aviso "D2. No se ha podido consultar la hora del servidor" }

# =============================================================================
# BLOQUE E - LA MATRIZ, VISTA DESDE EL CLIENTE
# =============================================================================
# ESTE ES EL BLOQUE QUE NO SE PODIA COMPROBAR EN LA FASE 7.
# Comprueba DOS cosas por cada trabajador:
#   1) Que ve TODO lo que le toca            (permisos correctos)
#   2) Que NO ve NADA de lo que no le toca   (ABE funcionando)
Escribe ""; Escribe "--- E. Lo que ve este trabajador (prueba de la Fase 7) ---"
Write-Host "`n--- E. Lo que ve este trabajador (prueba de la Fase 7) ---"

$vista = (net view "\\$Servidor" 2>&1 | Out-String)

if ($Matriz.ContainsKey($Usuario)) {
    $Debe   = $Matriz[$Usuario]
    $NoDebe = $TodosLosRecursos | Where-Object { $Debe -notcontains $_ }

    Info ""
    Info "     Segun la matriz, $Usuario DEBE ver:  $($Debe -join ', ')"
    Info "     Y NO debe ver siquiera:              $($NoDebe -join ', ')"
    Info ""

    # E1 - Lo que tiene que ver, lo ve
    $FaltanRec = @()
    foreach ($rec in $Debe) {
        if ($vista -notmatch "\b$rec\b") { $FaltanRec += $rec }
    }
    if ($FaltanRec.Count -eq 0) {
        OK "E1. Ve los $($Debe.Count) recursos que le corresponden"
    } else {
        Fallo "E1. NO ve estos recursos que deberia ver: $($FaltanRec -join ', ')"
        Info "     Comprueba que sigue en su grupo (Fase 5) y las ACL (Fase 7)."
    }

    # E2 - Lo que NO tiene que ver, NO lo ve. ESTA ES LA PRUEBA DEL ABE.
    $SobranRec = @()
    foreach ($rec in $NoDebe) {
        if ($vista -match "\b$rec\b") { $SobranRec += $rec }
    }
    if ($SobranRec.Count -eq 0) {
        OK "E2. NO ve ninguno de los recursos ajenos - LA INVISIBILIDAD FUNCIONA"
        Info "     Esta es la prueba que quedo pendiente en la Fase 7. Tachala."
    } else {
        Fallo "E2. VE recursos que NO deberia: $($SobranRec -join ', ')"
        Info "     Puede entrar? No. Pero sabe que existen, y eso ya es informacion."
        Info "     El fallo esta en la FASE 7: falta 'access based share enum'."
        Info "     Mira el caso E6 del apartado 7 de esta fase."
    }

    # E3 - Los becarios ademas NO pueden escribir en lo suyo.
    if ($Debe -contains "becarios" -and $Debe.Count -eq 1) {
        $ruta = "\\$Servidor\becarios"
        $tmp  = Join-Path $ruta "prueba_becario_$(Get-Random).txt"
        try {
            New-Item -Path $tmp -ItemType File -ErrorAction Stop | Out-Null
            Fallo "E3. Este becario HA PODIDO CREAR un fichero en 'becarios'"
            Info "     Segun la matriz solo tiene LECTURA. Revisa el Paso 3.b de la Fase 7:"
            Info "     sudo chmod 2750 /srv/samba/departamentos/becarios"
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        } catch {
            OK "E3. El becario NO puede escribir en su carpeta (solo lectura, correcto)"
        }
    }
} else {
    Aviso "E. Sesion con '$Usuario': no esta en la matriz, no se puede juzgar"
    Info "     Entra con uno de los 12 trabajadores del escenario."
}

# =============================================================================
# VEREDICTO
# =============================================================================
Escribe ""; Escribe "============================================================"
Write-Host "`n============================================================"
if ($Global:Fallos -eq 0 -and $Global:Avisos -eq 0) {
    Write-Host " VEREDICTO: FASE 8 SUPERADA (para $Usuario)" -ForegroundColor Green
    Escribe " VEREDICTO: FASE 8 SUPERADA (para $Usuario)"
} elseif ($Global:Fallos -eq 0) {
    Write-Host " VEREDICTO: SUPERADA CON $($Global:Avisos) AVISO(S)" -ForegroundColor Yellow
    Escribe " VEREDICTO: SUPERADA CON $($Global:Avisos) AVISO(S)"
} else {
    Write-Host " VEREDICTO: NO SUPERADA - $($Global:Fallos) FALLO(S)" -ForegroundColor Red
    Escribe " VEREDICTO: NO SUPERADA - $($Global:Fallos) FALLO(S)"
    Escribe " Busca cada caso en Fase_8.7_Resolucion_Problemas."
}
Escribe "============================================================"
Write-Host "============================================================"

Escribe ""
Escribe "ESTE SCRIPT NO HA COMPROBADO:"
Escribe "  - Que un usuario con solo LECTURA no pueda borrar (pruebalo a mano)"
Escribe "  - Que el sticky bit de 'comun' impida borrar lo ajeno"
Escribe "  - Que existan las instantaneas 'Fase 8 terminada' de las dos maquinas"
Escribe ""
Escribe "IMPORTANTE: ejecutalo con VARIOS trabajadores. Como minimo:"
Escribe "  1) shinnosuke.nohara (becario)  -> solo debe ver 'becarios'"
Escribe "  2) masao.sato (comercial)       -> ve facturacion, no contabilidad"
Escribe "  3) misae.nohara (contabilidad)  -> ve casi todo, pero NO rrhh"
Escribe "Guarda los informes: se llaman verificacion-fase-8-<usuario>.txt"
Escribe "Esa coleccion de informes es la prueba de la Fase 7."

Write-Host "`nInforme guardado en: $(Join-Path (Get-Location) $Informe)"
Write-Host "RECUERDA: hay que ejecutarlo con VARIOS usuarios distintos." -ForegroundColor Cyan

if ($Global:Fallos -eq 0) { exit 0 } else { exit 1 }
