#!/usr/bin/env bash

# Colors and styling
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print banner
print_banner() {
    echo -e "${BLUE}${BOLD}"
    echo '██╗    ██╗ █████╗ ██╗  ██╗██╗   ██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗     █████╗ ██████╗ ███████╗██████╗  █████╗ ████████╗ █████╗ ██████╗'
    echo '██║    ██║██╔══██╗██║ ██╔╝██║   ██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝    ██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗'
    echo '██║ █╗ ██║███████║█████╔╝ ██║   ██║    ██╔██╗ ██║██║   ██║██║  ██║█████╗      ██║  ██║██████╔╝█████╗  ██████╔╝███████║   ██║   ██║  ██║██████╔╝'
    echo '██║███╗██║██╔══██║██╔═██╗ ██║   ██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝      ██║  ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║   ██║   ██║  ██║██╔══██╗' 
    echo '╚███╔███╔╝██║  ██║██║  ██╗╚██████╔╝    ██║ ╚████║╚██████╔╝██████╔╝███████╗    ╚█████╔╝██║     ███████╗██║  ██║██║  ██║   ██║   ╚█████╔╝██║  ██║'
    echo ' ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚════╝ ╚═╝  ╚═╝'
    echo -e "${NC}"
    echo -e "${YELLOW}Your professional toolkit for operating Waku nodes${NC}"
    echo
}

# Show spinner while running command
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to handle Sepolia RPC setup
setup_sepolia_rpc() {
    echo -e "\n${BOLD}⚡ Sepolia RPC Setup${NC}"
    read -p "Do you already have an Infura account? (y/N): " has_infura

    if [[ $has_infura != [yY] ]]; then
        echo -e "\n${YELLOW}Let's create your Infura account:${NC}"
        echo -e "1. Opening Infura registration page in your browser...\n"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "https://app.infura.io/register"
        else
            xdg-open "https://app.infura.io/register" 2>/dev/null || echo "Please visit: https://app.infura.io/register"
        fi
        
        echo -e "\n${YELLOW}Please complete these steps:${NC}"
        echo "1. Register and verify your email"
        echo "2. Create a new project (Web3 API)"
        echo "3. Select Sepolia network"
        echo -e "4. Copy your endpoint URL\n"
        
        echo -e "${BOLD}${BLUE}Press Enter once you've completed these steps...${NC}"
        read
    else
        echo -e "\n${YELLOW}Please get your Sepolia endpoint URL from Infura dashboard${NC}"
    fi

    # Get and validate Sepolia RPC URL
    while true; do
        echo -e "\n🔗 Enter your Sepolia endpoint URL:"
        echo -e "${YELLOW}Format: https://sepolia.infura.io/v3/YOUR-PROJECT-ID${NC}\n"
        read -p "URL: " rpc_url
        
        if [[ $rpc_url =~ ^https://sepolia\.infura\.io/v3/[0-9a-fA-F]{32}$ ]]; then
            echo -e "\n${GREEN}✅ Sepolia RPC URL configured successfully!${NC}"
            sed -i.bak "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$rpc_url|" .env
            return 0
        else
            echo -e "\n${RED}Invalid Infura URL format. Please check and try again.${NC}"
        fi
    done
}

# Interactive setup function
setup() {
    clear
    echo -e "${BOLD}🚀 Starting Waku Node Setup${NC}\n"

    # Check if .env already exists
    if [ -f .env ]; then
        read -p "💡 .env file already exists. Do you want to reconfigure? (y/N): " confirm
        if [[ $confirm != [yY] ]]; then
            echo -e "${YELLOW}Setup cancelled${NC}"
            return
        fi
    fi

    # Copy .env.example to .env if it doesn't exist
    if [ ! -f .env ]; then
        cp .env.example .env
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Could not find .env.example file${NC}"
            exit 1
        fi
    fi
    
    setup_sepolia_rpc

    # Get Sepolia RPC URL
    while true; do
        read -p "🌐 Enter your Sepolia RPC URL (e.g., https://sepolia.infura.io/v3/YOUR-KEY): " rpc_url
        if [[ $rpc_url == http* ]]; then
            sed -i.bak "s|RLN_RELAY_ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$rpc_url|" .env
            break
        else
            echo -e "${RED}Please enter a valid HTTP(S) URL${NC}"
        fi
    done

    # Get Ethereum private key
    while true; do
        echo -e "\n🔑 Enter your Sepolia ETH private key:"
        echo -e "${YELLOW}Note: Input will be hidden for security${NC}"
        IFS= read -r eth_key
        
        # Remove any 0x prefix if present
        eth_key="${eth_key#0x}"
        
        # Validate the key
        if [[ ${#eth_key} == 64 && "$eth_key" =~ ^[0-9a-fA-F]+$ ]]; then
            sed -i.bak "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$eth_key|" .env
            break
        else
            echo -e "${RED}Error: Private key should be 64 hexadecimal characters (excluding any '0x' prefix)${NC}"
            echo -e "${YELLOW}Please try again...${NC}"
        fi
    done

    # Get RLN password
    read -s -p "🔒 Create a password for your RLN membership: " rln_password
    echo
    sed -i.bak "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=\"$rln_password\"|" .env

    # Clean up backup file
    rm -f .env.bak

    echo -e "\n${GREEN}✅ Configuration saved${NC}"

    # Show configuration summary
    echo -e "\n${BOLD}Configuration Summary:${NC}"
    echo -e "RPC URL: $rpc_url"
    echo -e "Private Key: ****${eth_key: -4}"
    echo -e "RLN Password: ********"

    # Confirm before proceeding
    read -p $'\n'"Ready to start the node? (Y/n): " start_confirm
    if [[ $start_confirm == [nN] ]]; then
        echo -e "${YELLOW}Setup completed. Run './waku-cli.sh start' when you're ready to start the node.${NC}"
        return
    fi

    # Register RLN membership
    echo -e "\n📝 Registering RLN membership..."
    ./register_rln.sh &
    spinner $!

    # Start the node
    echo -e "\n🚀 Starting Waku node..."
    docker-compose up -d &
    spinner $!

    echo -e "\n${GREEN}${BOLD}✨ Your Waku node is ready!${NC}"
    echo -e "📊 View metrics: http://localhost:3000"
    echo -e "💬 Chat interface: http://localhost:4000"
    echo -e "🔍 Check node health: ./waku-cli.sh status"
}

# Interactive menu function
show_interactive_menu() {
    while true; do
        clear
        print_banner
        
        echo -e "${BOLD}📋 Main Menu${NC}\n"
        echo -e "1) 🚀  Quick Start (Setup & Run Node)"
        echo -e "2) 🔧  Node Management"
        echo -e "3) 📊  Monitoring & Logs"
        echo -e "4) 🛠️  Maintenance"
        echo -e "5) 📚  Help & Documentation"
        echo -e "6) 🔚  Exit"
        echo
        read -p "Please select an option [1-6]: " main_choice
        
        case $main_choice in
            1) quick_start_menu ;;
            2) node_management_menu ;;
            3) monitoring_menu ;;
            4) maintenance_menu ;;
            5) help_menu ;;
            6) 
                clear
                print_banner
                echo -e "${GREEN}✨ Thanks for using Waku Node Manager! Goodbye! ✨${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Quick Start Menu
quick_start_menu() {
    while true; do
        clear
        echo -e "${BOLD}🚀 Quick Start Guide${NC}\n"
        echo -e "1) 📝  First Time Setup (Configure & Register)"
        echo -e "2) 🚀  Start Node"
        echo -e "3) 🔙  Back to Main Menu"
        echo
        read -p "Please select an option [1-4]: " choice
        
        case $choice in
            1)
                setup
                press_enter
                ;;
            2)
                echo -e "\n${BOLD}Starting Waku node...${NC}"
                docker-compose up -d
                echo -e "\n${GREEN}✅ Node started successfully!${NC}"
                press_enter
                ;;
            3) return ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Node Management Menu
node_management_menu() {
    while true; do
        clear
        echo -e "${BOLD}🔧 Node Management${NC}\n"
        echo -e "1) ▶️  Start Node"
        echo -e "2) ⏹️  Stop Node"
        echo -e "3) 🔄  Restart Node"
        echo -e "4) 🔍  Check Node Status"
        echo -e "5) 🆙  Update Node"
        echo -e "6) 🔙  Back to Main Menu"
        echo
        read -p "Please select an option [1-6]: " choice
        
        case $choice in
            1) 
                echo -e "\n${BOLD}Starting node...${NC}"
                docker-compose up -d
                press_enter
                ;;
            2)
                echo -e "\n${BOLD}Stopping node...${NC}"
                docker-compose down
                press_enter
                ;;
            3)
                echo -e "\n${BOLD}Restarting node...${NC}"
                docker-compose restart
                press_enter
                ;;
            4) 
                status
                press_enter
                ;;
            5)
                update
                press_enter
                ;;
            6) return ;;
        esac
    done
}

# Monitoring Menu
monitoring_menu() {
    while true; do
        clear
        echo -e "${BOLD}📊 Monitoring & Logs${NC}\n"
        echo -e "1) 📜  View Node Logs"
        echo -e "2) 📈  Open Metrics Dashboard"
        echo -e "3) 💬  Open Chat Interface"
        echo -e "4) 📉  Show Node Statistics"
        echo -e "5) 🔙  Back to Main Menu"
        echo
        read -p "Please select an option [1-5]: " choice
        
        case $choice in
            1) 
                docker-compose logs --tail=100 -f
                ;;
            2)
                echo -e "\n${BOLD}Opening metrics dashboard...${NC}"
                xdg-open http://localhost:3000 2>/dev/null || open http://localhost:3000 2>/dev/null || echo "Please open http://localhost:3000 in your browser"
                press_enter
                ;;
            3)
                echo -e "\n${BOLD}Opening chat interface...${NC}"
                xdg-open http://localhost:4000 2>/dev/null || open http://localhost:4000 2>/dev/null || echo "Please open http://localhost:4000 in your browser"
                press_enter
                ;;
            4)
                show_node_stats
                press_enter
                ;;
            5) return ;;
        esac
    done
}

# Maintenance Menu
maintenance_menu() {
    while true; do
        clear
        echo -e "${BOLD}🛠️  Maintenance${NC}\n"
        echo -e "1) 🧹  Clean Docker Artifacts"
        echo -e "2) 💾  Backup Configuration"
        echo -e "3) 📥  Restore Configuration"
        echo -e "4) 🔄  Reset Node"
        echo -e "5) 🔙  Back to Main Menu"
        echo
        read -p "Please select an option [1-5]: " choice
        
        case $choice in
            1) 
                cleanup
                press_enter
                ;;
            2)
                backup_config
                press_enter
                ;;
            3)
                restore_config
                press_enter
                ;;
            4)
                reset_node
                press_enter
                ;;
            5) return ;;
        esac
    done
}

# Help Menu
help_menu() {
    while true; do
        clear
        echo -e "${BOLD}📚 Help & Documentation${NC}\n"
        echo -e "1) 🚀 Show Quick Start Guide"
        echo -e "2) 🔧 Troubleshooting Guide"
        echo -e "3) 📖 View Documentation"
        echo -e "4) ℹ️   About"
        echo -e "5) 🔙 Back to Main Menu"
        echo
        read -p "Please select an option [1-5]: " choice
        
        case $choice in
            1) 
                show_quick_start_guide
                press_enter
                ;;
            2)
                show_troubleshooting
                press_enter
                ;;
            3)
                xdg-open "https://docs.waku.org" 2>/dev/null || open "https://docs.waku.org" 2>/dev/null || echo "Please visit https://docs.waku.org"
                press_enter
                ;;
            4)
                show_about
                press_enter
                ;;
            5) return ;;
        esac
    done
}

# Utility Functions
press_enter() {
    echo
    read -p "Press Enter to continue..."
}

status() {
    echo -e "${BOLD}🔍 Checking node status...${NC}\n"
    ./chkhealth.sh
}

update() {
    echo -e "${BOLD}🆙 Updating Waku node...${NC}\n"
    
    echo "Stopping node..."
    docker-compose down

    echo "Getting latest version..."
    git pull origin master

    echo "Starting updated node..."
    docker-compose up -d

    echo -e "\n${GREEN}✅ Node updated successfully!${NC}"
}

cleanup() {
    echo -e "${YELLOW}⚠️  Warning: This will clean up all Docker artifacts not used by Waku${NC}"
    read -p "Are you sure you want to continue? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        echo "Cleaning Docker system..."
        docker system prune -a
        docker image prune -a
        docker container prune
        docker volume prune
        echo -e "${GREEN}✅ Cleanup completed${NC}"
    fi
}

show_node_stats() {
    echo -e "${BOLD}📊 Node Statistics${NC}\n"
    echo "Memory Usage:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    echo -e "\nDisk Usage:"
    df -h | grep -E '^/dev/'
}

backup_config() {
    backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp .env "$backup_dir/"
    echo -e "${GREEN}✅ Configuration backed up to $backup_dir${NC}"
}

restore_config() {
    if [ ! -d "backups" ]; then
        echo -e "${RED}No backups found${NC}"
        return
    fi
    
    echo "Available backups:"
    select backup in $(ls backups); do
        if [ -n "$backup" ]; then
            cp "backups/$backup/.env" .env
            echo -e "${GREEN}✅ Configuration restored from $backup${NC}"
            break
        fi
    done
}

reset_node() {
    echo -e "${RED}⚠️  Warning: This will reset your node to default settings${NC}"
    read -p "Are you sure? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        docker-compose down -v
        rm -f .env
        echo -e "${GREEN}✅ Node reset complete${NC}"
    fi
}

show_quick_start_guide() {
    echo -e "${BOLD}🚀 Quick Start Guide${NC}\n"
    echo "1. Ensure you have:"
    echo "   - Docker and Docker Compose installed"
    echo "   - A Sepolia RPC URL"
    echo "   - Some Sepolia ETH for RLN registration"
    echo
    echo "2. Run the setup wizard from the main menu"
    echo "3. Follow the prompts to configure your node"
    echo "4. Monitor your node using the dashboard"
}

show_troubleshooting() {
    echo -e "${BOLD}🔧 Troubleshooting Guide${NC}\n"
    echo "Common Issues:"
    echo
    echo "1. Node won't start:"
    echo "   - Check Docker status"
    echo "   - Verify .env configuration"
    echo "   - Ensure ports aren't in use"
    echo
    echo "2. RLN registration fails:"
    echo "   - Verify Sepolia RPC URL"
    echo "   - Ensure sufficient Sepolia ETH"
    echo
    echo "3. Performance issues:"
    echo "   - Check system resources"
    echo "   - Monitor disk space"
    echo "   - Review log files"
}

show_about() {
    echo -e "${BOLD}ℹ️  About Waku Node Manager${NC}\n"
    echo "Version: 1.0.0"
    echo "A user-friendly interface for managing Waku nodes"
    echo
    echo "Resources:"
    echo "- 📚  Documentation: https://docs.waku.org"
    echo "- 🐙  GitHub: https://github.com/waku-org/nwaku"
    echo "- 💬  Community: https://discord.gg/waku"
}

# Main command handler
case "$1" in
    setup|status|update|cleanup|help)
        "$1"
        ;;
    *)
        show_interactive_menu
        ;;
esac
