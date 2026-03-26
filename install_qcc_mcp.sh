#!/bin/bash
# vendor-assessment-qcc Installation Script
# 企查查MCP供应商评估Skill安装脚本
#
# 一键安装命令:
#   bash <(curl -sL https://raw.githubusercontent.com/duhu2000/vendor-assessment-qcc/main/install_qcc_mcp.sh)
#
# 本地安装命令:
#   bash install_qcc_mcp.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  vendor-assessment-qcc Installer"
echo "  企查查MCP供应商评估Skill安装程序"
echo "=========================================="
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
    CLAUDE_DIR="$HOME/.claude"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="Linux"
    CLAUDE_DIR="$HOME/.claude"
else
    echo -e "${RED}Unsupported platform: $OSTYPE${NC}"
    echo "This script supports macOS and Linux only."
    exit 1
fi

echo -e "${BLUE}Detected platform: $PLATFORM${NC}"
echo ""

# Check installation mode
# When running via 'bash <(curl ...)', BASH_SOURCE[0] returns something like /dev/fd/63
# In normal execution, it's the actual script path
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
INSTALL_MODE="local"
SOURCE_DIR=""

# Detect curl mode: if BASH_SOURCE contains /dev/fd/ or doesn't exist as a real file
if [[ "$SCRIPT_SOURCE" == /dev/fd/* ]] || [[ "$SCRIPT_SOURCE" == /proc/*/fd/* ]] || [ ! -f "$SCRIPT_SOURCE" ]; then
    INSTALL_MODE="curl"
    echo -e "${BLUE}Installation mode: curl (downloading from GitHub)${NC}"

    # Download from GitHub
    TEMP_DIR=$(mktemp -d)
    echo -e "${BLUE}Downloading from GitHub...${NC}"

    if command -v curl &> /dev/null; then
        curl -sL https://github.com/duhu2000/vendor-assessment-qcc/archive/refs/heads/main.tar.gz | tar -xz -C "$TEMP_DIR" --strip-components=1
    elif command -v wget &> /dev/null; then
        wget -qO- https://github.com/duhu2000/vendor-assessment-qcc/archive/refs/heads/main.tar.gz | tar -xz -C "$TEMP_DIR" --strip-components=1
    else
        echo -e "${RED}Error: curl or wget is required${NC}"
        exit 1
    fi

    SOURCE_DIR="$TEMP_DIR"
else
    echo -e "${BLUE}Installation mode: local${NC}"
    SOURCE_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
fi

# Check for QCC MCP API Key
if [ -z "$QCC_MCP_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  QCC_MCP_API_KEY not found in environment${NC}"
    echo ""
    echo "To use QCC MCP enhanced features, you need an API key."
    echo "Get your key at: https://mcp.qcc.com"
    echo ""
    echo "Options:"
    echo "1. Continue without QCC MCP (baseline mode only)"
    echo "2. Enter API key now"
    echo "3. Exit and configure later"
    echo ""
    read -p "Select option (1/2/3): " choice

    case $choice in
        1)
            echo -e "${YELLOW}Continuing without QCC MCP. Chinese supplier verification will be limited.${NC}"
            ;;
        2)
            read -p "Enter your QCC MCP API Key: " api_key
            export QCC_MCP_API_KEY="$api_key"
            echo -e "${GREEN}✓ API key set for this session${NC}"
            echo ""
            echo "To make this permanent, add to your shell profile:"
            if [[ "$PLATFORM" == "macOS" ]]; then
                echo "  echo 'export QCC_MCP_API_KEY=\"$api_key\"' >> ~/.zshrc"
                echo "  source ~/.zshrc"
            else
                echo "  echo 'export QCC_MCP_API_KEY=\"$api_key\"' >> ~/.bashrc"
                echo "  source ~/.bashrc"
            fi
            ;;
        3)
            echo "Exiting. Please set QCC_MCP_API_KEY and run again."
            exit 0
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
else
    echo -e "${GREEN}✓ QCC_MCP_API_KEY found${NC}"
fi

echo ""
echo "=========================================="
echo "  Step 1: Installing MCP Configuration"
echo "=========================================="

# Install .mcp.json configuration
echo ""
echo -e "${BLUE}Installing MCP server configuration...${NC}"
MCP_CONFIG_DEST="$CLAUDE_DIR/.mcp.json"

if [ -f "$MCP_CONFIG_DEST" ]; then
    echo -e "${YELLOW}  Existing .mcp.json found, backing up...${NC}"
    cp "$MCP_CONFIG_DEST" "${MCP_CONFIG_DEST}.backup.$(date +%Y%m%d%H%M%S)"
fi

# Create MCP config with API key placeholder
cat > "$MCP_CONFIG_DEST" << 'MCPJSONEOF'
{
  "mcpServers": {
    "qcc-company": {
      "url": "https://agent.qcc.com/mcp/company/stream",
      "headers": {
        "Authorization": "Bearer ${QCC_MCP_API_KEY}"
      }
    },
    "qcc-risk": {
      "url": "https://agent.qcc.com/mcp/risk/stream",
      "headers": {
        "Authorization": "Bearer ${QCC_MCP_API_KEY}"
      }
    },
    "qcc-ipr": {
      "url": "https://agent.qcc.com/mcp/ipr/stream",
      "headers": {
        "Authorization": "Bearer ${QCC_MCP_API_KEY}"
      }
    },
    "qcc-operation": {
      "url": "https://agent.qcc.com/mcp/operation/stream",
      "headers": {
        "Authorization": "Bearer ${QCC_MCP_API_KEY}"
      }
    }
  }
}
MCPJSONEOF

echo -e "${GREEN}  ✓ MCP configuration installed to: $MCP_CONFIG_DEST${NC}"

echo ""
echo "=========================================="
echo "  Step 2: Installing Skill"
echo "=========================================="

# Define destination
SKILLS_DIR="$CLAUDE_DIR/skills"

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Install vendor-assessment-qcc skill
echo ""
echo -e "${BLUE}Installing vendor-assessment-qcc skill...${NC}"
VENDOR_DEST="$SKILLS_DIR/vendor-assessment-qcc"

if [ -d "$VENDOR_DEST" ]; then
    echo -e "${YELLOW}  Existing vendor-assessment-qcc found, backing up...${NC}"
    mv "$VENDOR_DEST" "${VENDOR_DEST}.backup.$(date +%Y%m%d%H%M%S)"
fi

# Create skill directory
mkdir -p "$VENDOR_DEST"

# Copy QCC enhanced version as default
cp "$SOURCE_DIR/SKILL.qcc-enhanced.md" "$VENDOR_DEST/SKILL.md"
echo -e "${GREEN}  ✓ vendor-assessment-qcc installed (QCC MCP enhanced)${NC}"

# Copy original version as reference
cp "$SOURCE_DIR/SKILL.original.md" "$VENDOR_DEST/SKILL.original.md" 2>/dev/null || true

echo ""
echo "=========================================="
echo "  Step 2: Installing QCC MCP Connector"
echo "=========================================="

SCRIPTS_DEST="$CLAUDE_DIR/vendor-assessment-qcc-scripts"

if [ -d "$SCRIPTS_DEST" ]; then
    echo -e "${YELLOW}Existing scripts directory found, backing up...${NC}"
    mv "$SCRIPTS_DEST" "${SCRIPTS_DEST}.backup.$(date +%Y%m%d%H%M%S)"
fi

mkdir -p "$SCRIPTS_DEST"

# Check if qcc-mcp-integration directory exists
if [ -d "$SOURCE_DIR/qcc-mcp-integration" ]; then
    cp -r "$SOURCE_DIR/qcc-mcp-integration/"* "$SCRIPTS_DEST/"
    echo -e "${GREEN}✓ QCC MCP connector installed to: $SCRIPTS_DEST${NC}"
else
    echo -e "${YELLOW}⚠️  qcc-mcp-integration directory not found, skipping connector installation${NC}"
fi

echo ""
echo "=========================================="
echo "  Step 3: Verifying Installation"
echo "=========================================="

# Check MCP config
echo ""
echo -e "${BLUE}Checking MCP configuration...${NC}"
if [ -f "$MCP_CONFIG_DEST" ]; then
    echo -e "${GREEN}  ✓ MCP configuration file installed${NC}"
else
    echo -e "${RED}  ✗ MCP configuration file not found${NC}"
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python3 not found. Please install Python 3.9+${NC}"
else
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python found: $PYTHON_VERSION${NC}"
fi

# Check required Python packages
echo ""
echo -e "${BLUE}Checking Python dependencies...${NC}"
python3 -c "import requests" 2>/dev/null && echo -e "${GREEN}  ✓ requests${NC}" || echo -e "${YELLOW}  ⚠️  requests not installed (pip3 install requests)${NC}"

# Verify skill installation
echo ""
echo -e "${BLUE}Verifying skill installation...${NC}"
if [ -f "$VENDOR_DEST/SKILL.md" ]; then
    echo -e "${GREEN}  ✓ SKILL.md installed${NC}"
else
    echo -e "${RED}  ✗ SKILL.md not found${NC}"
fi

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo -e "${GREEN}vendor-assessment-qcc has been installed successfully!${NC}"
echo ""
echo "Installed Skill:"
echo "  • vendor-assessment-qcc  - 供应商评估（企查查MCP增强版）"
echo ""
echo "Location:"
echo "  Skill:   $VENDOR_DEST/SKILL.md"
echo "  Scripts: $SCRIPTS_DEST"
echo ""

if [ -n "$QCC_MCP_API_KEY" ]; then
    echo -e "${GREEN}QCC MCP Status: CONFIGURED${NC}"
    echo "Chinese supplier verification: ENABLED"
else
    echo -e "${YELLOW}QCC MCP Status: NOT CONFIGURED${NC}"
    echo "To enable Chinese supplier verification:"
    echo "  export QCC_MCP_API_KEY='your_key_here'"
fi

echo ""
echo "=========================================="
echo "  ⚠️  IMPORTANT: Post-Installation Steps"
echo "=========================================="
echo ""
echo -e "${YELLOW}You MUST restart Claude Code to load the MCP configuration!${NC}"
echo ""
echo "Step 1: Completely exit Claude Code"
echo "Step 2: Ensure QCC_MCP_API_KEY is set:"
echo "       export QCC_MCP_API_KEY='your_api_key_here'"
echo "Step 3: Restart Claude Code"
echo "Step 4: Verify MCP servers are loaded:"
echo "       You should see 'qcc-company', 'qcc-risk', etc. in available tools"
echo ""
echo "=========================================="
echo "  Quick Start"
echo "=========================================="
echo ""
echo "After restarting Claude Code, use these commands:"
echo ""
echo "1. Verify MCP tools are available:"
echo "   Check if Claude shows available MCP tools from qcc-company, qcc-risk, etc."
echo ""
echo "2. Use the skill:"
echo ""
echo "   # 评估中国供应商（自动启用QCC MCP）"
echo "   /vendor-assessment-qcc 华为技术有限公司"
echo ""
echo "   # 评估其他供应商"
echo "   /vendor-assessment-qcc 供应商名称"
echo ""
echo "3. For programmatic use:"
echo "   python3 $SCRIPTS_DEST/qcc_mcp_connector.py"
echo ""
echo "=========================================="
echo "  Documentation"
echo "=========================================="
echo ""
echo "• README.md              - 详细文档"
echo "• SKILL.md               - Skill使用指南"
echo "• https://mcp.qcc.com    - QCC MCP官网"
echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""

# Cleanup temp directory if curl mode
if [ "$INSTALL_MODE" == "curl" ]; then
    rm -rf "$TEMP_DIR"
fi
