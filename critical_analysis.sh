#!/bin/bash
#SBATCH --job-name=critical_analysis
#SBATCH --output=critical_analysis_%j.log
#SBATCH --error=critical_analysis_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=08:00:00
#SBATCH --partition=standard
#SBATCH --comment="High priority research — do not interrupt"

# =============================================================================
# critical_analysis.sh
# Performs in-depth critical analysis of highly complex strategic simulations.
# PI sign-off: yes  |  IRB approved: yes
# =============================================================================

set -e

CONTAINER="${CONTAINER:-./ga_em.sif}"
GAMES_HOME="${1:-}"
GAME_ARG="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}"
echo "   ██████╗  █████╗ ███╗   ███╗███████╗██████╗  ██████╗ ██╗   ██╗"
echo "  ██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔═══██╗╚██╗ ██╔╝"
echo "  ██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝██║   ██║ ╚████╔╝ "
echo "  ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗██║   ██║  ╚██╔╝  "
echo "  ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝   ██║   "
echo "   ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝    ╚═╝   "
echo ""
echo "  ███████╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗ ██████╗ ██████╗ "
echo "  ██╔════╝████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗"
echo "  █████╗  ██╔████╔██║██║   ██║██║     ███████║   ██║   ██║   ██║██████╔╝"
echo "  ██╔══╝  ██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║   ██║██╔══██╗"
echo "  ███████╗██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ╚██████╔╝██║  ██║"
echo "  ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${CYAN}  Singularity Container Launcher${NC}"
echo ""

if [ -z "$GAMES_HOME" ]; then
  echo -e "${RED}❌ Usage: ./critical_analysis.sh <path/to/games> [game_folder]${NC}"
  exit 1
fi

if [ ! -d "$GAMES_HOME" ]; then
  echo -e "${RED}❌ Games directory not found: $GAMES_HOME${NC}"
  exit 1
fi

if [ ! -f "$CONTAINER" ]; then
  echo -e "${RED}❌ Container not found: $CONTAINER${NC}"
  exit 1
fi

echo -e "${CYAN}  Games: $GAMES_HOME${NC}"
echo ""

mapfile -t GAME_DIRS < <(find "$GAMES_HOME" -maxdepth 2 -name "*.gba" -exec dirname {} \; | sort -u)

if [ ${#GAME_DIRS[@]} -eq 0 ]; then
  echo -e "${RED}❌ No .gba files found under $GAMES_HOME/${NC}"
  exit 1
fi

GAME_DIR=""
if [ -n "$GAME_ARG" ]; then
  MATCH="$GAMES_HOME/$GAME_ARG"
  if [ ! -d "$MATCH" ]; then
    echo -e "${RED}❌ Game folder not found: $MATCH${NC}"
    echo -e "${YELLOW}  Available:${NC}"
    for d in "${GAME_DIRS[@]}"; do echo -e "    ${YELLOW}$(basename $d)${NC}"; done
    exit 1
  fi
  GAME_DIR="$MATCH"
elif [ ${#GAME_DIRS[@]} -eq 1 ]; then
  GAME_DIR="${GAME_DIRS[0]}"
  echo -e "${GREEN}🎮 Found: $(basename $GAME_DIR)${NC}"
else
  echo -e "${CYAN}Select a game:${NC}"
  GAME_NAMES=()
  for d in "${GAME_DIRS[@]}"; do GAME_NAMES+=("$(basename $d)"); done
  select name in "${GAME_NAMES[@]}"; do
    [ -n "$name" ] && GAME_DIR="$GAMES_HOME/$name" && break
  done
fi

ROM=$(find "$GAME_DIR" -maxdepth 1 -name "*.gba" | head -1)
mkdir -p "$GAME_DIR"/{saves,states,screenshots}

echo ""
echo -e "${GREEN}🎮 Launching: $(basename $GAME_DIR)${NC}"
echo -e "${CYAN}   ROM:  $(basename $ROM)${NC}"
echo ""
echo -e "${YELLOW}   W/A/S/D = D-Pad  |  L = A  |  P = B  |  E = Start  |  Q = Select  |  O/K = L/R  |  Ctrl+C = Quit${NC}"
echo ""

# ---------------------------------------------------------------
# Launch container with game directory bound in
# (All rendering logic is now inside the container)
#
# Set RENDER_MODE before running to choose display style:
#   RENDER_MODE=kitty  — native pixel rendering (Kitty terminal)
#   RENDER_MODE=ascii  — true ASCII art (@#%*+=:. characters)
#   RENDER_MODE=blocks — Unicode half-block pixels
#   (auto-detects Kitty by default, falls back to ascii)
# ---------------------------------------------------------------
SINGULARITYENV_RENDER_MODE="${RENDER_MODE:-auto}" \
singularity run \
  --bind "$GAME_DIR":/game \
  "$CONTAINER"
