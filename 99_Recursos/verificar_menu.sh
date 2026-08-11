#!/bin/bash
# =============================================================================
# BOOCHAN V1 - MENU DE VERIFICACION (verificador de verificadores)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
#
# QUE HACE: no comprueba NADA por si mismo. Localiza los verificadores de las
#           fases 1-7, te deja elegir UNO o TODOS, y los ejecuta en orden.
#           Cada verificador escribe su propio informe (verificacion-fase-N.txt)
#           y este menu anade un resumen conjunto: verificacion-menu.txt
#
# USO:
#   chmod +x verificar_menu.sh
#   sudo ./verificar_menu.sh
#
# DONDE BUSCA LOS VERIFICADORES (en este orden):
#   1. La misma carpeta que este menu
#   2. /home/boochan
#   3. $HOME
#
# Cada verificador se descarga solo (apartado 8.a de su fase):
#   curl -O https://raw.githubusercontent.com/sor-iesjj/bloque-2-ubuntu-local/main/99_Recursos/verificar_faseN.sh
#
# 🛑 EL MENU NO SUSTITUYE A LAS COMPROBACIONES.
# Haz primero los puntos de cada 8.a comando a comando, entendiendo que dice
# cada uno. El menu es la red de seguridad de quien ya ha hecho el trabajo,
# y la herramienta de la prueba de campo. No un atajo para saltarse nada.
#
# FASE 8: esta NO entra en este menu. Corre en el cliente Windows:
#   .\verificar_menu.ps1   (lanza verificar_fase8.ps1)
# =============================================================================

# Sin 'set -e' A PROPOSITO: si una fase falla, queremos seguir con el resto.
# Un lanzador que aborta al primer fallo solo cuenta el primero.

INFORME="verificacion-menu.txt"
: > "$INFORME"   # resumen fresco por sesion

V='\033[0;32m'; R='\033[0;31m'; A='\033[0;33m'; N='\033[0m'

# --- Los nombres de las fases (solo para el menu) ----------------------------
declare -A NOMBRE
NOMBRE[1]="Infraestructura Virtual Local"
NOMBRE[2]="Purga y preparacion del entorno"
NOMBRE[3]="Conectividad VPN WireGuard"
NOMBRE[4]="Aprovisionamiento del dominio"
NOMBRE[5]="Gestion de identidades"
NOMBRE[6]="Almacenamiento virtual y cuotas"
NOMBRE[7]="Seguridad avanzada (ACL y ABE)"

# --- ¿Donde estan los verificadores? ------------------------------------------
DIR_MENU=$(cd "$(dirname "$0")" && pwd)
LOC=""
for d in "$DIR_MENU" /home/boochan "$HOME"; do
  if [ -f "$d/verificar_fase2.sh" ]; then LOC="$d"; break; fi
done

if [ -z "$LOC" ]; then
  echo -e "${R}[FALLO]${N} No encuentro los verificadores (verificar_fase1.sh ... verificar_fase7.sh)."
  echo "        Busco en: $DIR_MENU · /home/boochan · $HOME"
  echo "        Descargalos con el 8.a de cada fase y vuelve a intentarlo."
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo -e "${R}[FALLO]${N} Este menu necesita sudo (los verificadores leen archivos de solo root)."
  echo "        Ejecuta:  sudo ./verificar_menu.sh"
  exit 1
fi

# --- Una fase ----------------------------------------------------------------
ejecuta_fase() {
  local n="$1"
  local script="$LOC/verificar_fase$n.sh"
  if [ ! -f "$script" ]; then
    echo -e "${R}[FALLO]${N} No se encuentra $script"
    echo "[FALLO] Fase $n: no se encuentra el verificador" >> "$INFORME"
    return 1
  fi

  echo ""
  echo "============================================================"
  echo " FASE $n · ${NOMBRE[$n]}"
  echo " Verificador: $script"
  echo "============================================================"
  sudo bash "$script"
  local rc=$?

  echo ""
  if [ "$rc" -eq 0 ]; then
    echo -e "${V}[OK]    ${N} Fase $n SUPERADA"
    echo "[OK]    Fase $n SUPERADA" >> "$INFORME"
  else
    echo -e "${R}[FALLO]${N} Fase $n NO SUPERADA (salida $rc)"
    echo "[FALLO] Fase $n NO SUPERADA (salida $rc)" >> "$INFORME"
  fi
  echo ""
  return "$rc"
}

mostrar_menu() {
  echo "============================================================"
  echo " BOOCHAN V1 - MENU DE VERIFICACION"
  echo " Verificadores encontrados en: $LOC"
  echo "============================================================"
  for n in 1 2 3 4 5 6 7; do
    printf "  %s) Fase %s - %s\n" "$n" "$n" "${NOMBRE[$n]}"
  done
  echo "  8) TODAS (1-7) en secuencia"
  echo "  0) Salir"
  echo "============================================================"
}

espera() {
  echo ""
  read -rp "Pulsa ENTER para volver al menu... " _
}
while true; do
  clear 2>/dev/null || true
  mostrar_menu
  read -rp "Elige una opcion: " opcion
  case "$opcion" in
    1|2|3|4|5|6|7) ejecuta_fase "$opcion"; espera ;;
    8)
      echo "" | tee -a "$INFORME"
      echo "=== RESULTADO GLOBAL (fases 1-7) ===" | tee -a "$INFORME"
      for n in 1 2 3 4 5 6 7; do ejecuta_fase "$n"; done
      echo ""
      echo "=== RESUMEN ==="
      cat "$INFORME"
      echo ""
      echo "Resumen guardado en: $(pwd)/$INFORME"
      espera
      ;;
    0|q|Q)
      echo "Hasta luego. Resumen en $(pwd)/$INFORME"
      break
      ;;
    *)
      echo -e "${A}[AVISO]${N} Opcion no valida: '$opcion'"
      espera
      ;;
  esac
done
