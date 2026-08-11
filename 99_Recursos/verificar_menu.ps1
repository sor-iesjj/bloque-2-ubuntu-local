# =============================================================================
# BOOCHAN V1 - MENU DE VERIFICACION DEL CLIENTE WINDOWS (fase 8)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: no comprueba NADA por si mismo. Ejecuta verificar_fase8.ps1, que
#           es el que comprueba la union al dominio y la matriz de carpetas.
#           Se usa para repetirlo con VARIOS usuarios (becario, comercial,
#           contabilidad...) sin tener que teclear la llamada a cada vez.
#
# USO (PowerShell como Administrador):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\verificar_menu.ps1
#
# 🛑 IMPORTANTE: la fase 8 NO se verifica entera desde el servidor ni con un
#    solo usuario. Hay que entrar como VARIOS trabajadores, porque cada uno
#    debe ver sus carpetas y NO ver las de otros (eso es el ABE, la prueba
#    que quedo pendiente en la Fase 7). Este menu lo recuerda.
#
# El hermano Ubuntu de este menu es 99_Recursos/verificar_menu.sh (fases 1-7).
# =============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Verif8 = Join-Path $ScriptDir "verificar_fase8.ps1"

# --- El listado de usuarios con los que conviene probar ---------------------
# (el mismo "ejecutalo como minimo con estos tres" del final del fase8.ps1)
$Sugeridos = @(
    "shinnosuke.nohara",  # becario      -> solo debe ver 'becarios'
    "masao.sato",         # comercial    -> ve facturacion, NO contabilidad
    "misae.nohara"        # contabilidad -> ve casi todo, pero NO rrhh
)

function Mostrar-Menu {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " BOOCHAN V1 - MENU DE VERIFICACION DEL CLIENTE WINDOWS" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " 1) Ejecutar la verificacion AHORA (con el usuario actual)"
    Write-Host " 2) Ver los informes generados"
    Write-Host " 3) Ver que usuarios conviene probar"
    Write-Host " 0) Salir"
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Esperar {
    Write-Host ""
    Read-Host "Pulsa ENTER para volver al menu"
}

while ($true) {
    Mostrar-Menu
    $opcion = Read-Host "Elige una opcion"

    switch ($opcion) {
        "1" {
            if (-not (Test-Path $Verif8)) {
                Write-Host "NO se encuentra verificar_fase8.ps1 en: $ScriptDir" -ForegroundColor Red
                Write-Host "Descargalo con el apartado 8.a:"
                Write-Host "  curl.exe -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_fase8.ps1"
                Esperar
                continue
            }

            $usuario = "$env:USERDOMAIN\$env:USERNAME"
            Write-Host ""
            Write-Host "Sesion actual: $usuario" -ForegroundColor Yellow
            if ($env:USERDOMAIN -ne "BOOCHANLAB") {
                Write-Host ">>> OJO: estas como usuario LOCAL. La verificacion con local no vale." -ForegroundColor Red
                Write-Host ">>> Cierra sesion y entra como BOOCHANLAB\<trabajador>." -ForegroundColor Red
            }
            Write-Host ""
            Read-Host "Pulsa ENTER para lanzar verificar_fase8.ps1 con esta sesion"

            & $Verif8
            Esperar
        }
        "2" {
            Clear-Host
            Write-Host "Informes encontrados:" -ForegroundColor Cyan
            Get-ChildItem -Path $ScriptDir -Filter "verificacion-fase-8-*.txt" -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending |
                Select-Object Name, LastWriteTime |
                Format-Table -AutoSize | Out-Host
            if (-not (Get-ChildItem -Path $ScriptDir -Filter "verificacion-fase-8-*.txt" -ErrorAction SilentlyContinue)) {
                Write-Host "(ninguno todavia)" -ForegroundColor Yellow
            }
            Write-Host ""
            Read-Host "Pulsa ENTER para ver un informe (o 0 para no ver)"
            $cual = Read-Host "Nombre del informe"
            if ($cual -ne "0" -and $cual -ne "") {
                $ruta = Join-Path $ScriptDir $cual
                if (Test-Path $ruta) { Get-Content $ruta | Out-Host } else { Write-Host "No existe: $cual" -ForegroundColor Red }
            }
            Esperar
        }
        "3" {
            Clear-Host
            Write-Host "Ejecuta la verificacion al menos con estos trabajadores:" -ForegroundColor Cyan
            foreach ($u in $Sugeridos) {
                $ficha = switch ($u) {
                    "shinnosuke.nohara" { "becario      -> solo debe ver 'becarios'" }
                    "masao.sato"        { "comercial    -> ve facturacion, NO contabilidad" }
                    "misae.nohara"      { "contabilidad -> ve casi todo, pero NO rrhh" }
                    default             { "" }
                }
                Write-Host ("  - {0,-20} {1}" -f $u, $ficha)
            }
            Write-Host ""
            Write-Host "Cada ejecucion guarda verificacion-fase-8-<usuario>.txt." -ForegroundColor Yellow
            Write-Host "Esa coleccion de informes es la prueba de la Fase 7." -ForegroundColor Yellow
            Esperar
        }
        "0" { Write-Host "Hasta luego."; break }
        default {
            Write-Host "Opcion no valida: $opcion" -ForegroundColor Yellow
            Esperar
        }
    }
}
