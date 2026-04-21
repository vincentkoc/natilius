#!/bin/bash
# Simulated setup output for VHS demo

CYAN='\033[1;36m'
GREEN='\033[1;32m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "  ${CYAN}┃${RESET} ${BOLD}🐚 natilius${RESET}"
echo -e "  ${CYAN}┃${RESET} ${DIM}Mac Developer Environment Setup${RESET}"
echo -e "  ${CYAN}┃${RESET} ${DIM}v1.4.0${RESET}"
echo ""
echo -e "  ${BOLD}Profile:${RESET} devops"
echo ""
echo -e "  ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
sleep 0.3
echo -e "  ${CYAN}→${RESET} Setting up system updates..."
sleep 0.2
echo -e "  ${GREEN}✓${RESET} System updates complete"
sleep 0.2
echo -e "  ${CYAN}→${RESET} Installing Homebrew packages..."
sleep 0.3
echo -e "  ${GREEN}✓${RESET} 45 packages installed"
sleep 0.2
echo -e "  ${CYAN}→${RESET} Installing Go..."
sleep 0.2
echo -e "  ${GREEN}✓${RESET} Go 1.21 installed"
sleep 0.2
echo -e "  ${CYAN}→${RESET} Installing Kubernetes tools..."
sleep 0.3
echo -e "  ${GREEN}✓${RESET} kubectl, helm, k9s installed"
sleep 0.2
echo -e "  ${CYAN}→${RESET} Installing Terraform..."
sleep 0.2
echo -e "  ${GREEN}✓${RESET} Terraform, tflint installed"
sleep 0.2
echo -e "  ${CYAN}→${RESET} Configuring IDE..."
sleep 0.2
echo -e "  ${GREEN}✓${RESET} VS Code configured"
echo ""
echo -e "  ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}✓ Setup complete!${RESET} Your Mac is ready."
echo ""
