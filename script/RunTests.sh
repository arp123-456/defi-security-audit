#!/bin/bash

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║   DeFi SECURITY AUDIT - FOUNDRY TEST SUITE            ║"
echo "║   Comprehensive Vulnerability Analysis                ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
export MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/demo"

echo "📋 Test Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "RPC URL: $MAINNET_RPC_URL"
echo "Solidity Version: 0.8.19"
echo "Optimizer: Enabled (200 runs)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Foundry is installed
if ! command -v forge &> /dev/null; then
    echo "${RED}❌ Foundry not found. Please install:${NC}"
    echo "   curl -L https://foundry.paradigm.xyz | bash"
    echo "   foundryup"
    exit 1
fi

echo "${GREEN}✅ Foundry detected${NC}"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
forge install foundry-rs/forge-std --no-commit 2>/dev/null || echo "Dependencies already installed"
echo ""

# Build contracts
echo "🔨 Building contracts..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
forge build
if [ $? -ne 0 ]; then
    echo "${RED}❌ Build failed${NC}"
    exit 1
fi
echo "${GREEN}✅ Build successful${NC}"
echo ""

# Run tests
echo "🧪 Running Security Tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: AAVE V3 Security
echo "${YELLOW}[1/2] AAVE V3 Security Tests${NC}"
echo "────────────────────────────────────────────────────────"
forge test --match-path test/AAVE_V3_Security.t.sol -vv --fork-url $MAINNET_RPC_URL
AAVE_RESULT=$?
echo ""

# Test 2: Uniswap V4 Security
echo "${YELLOW}[2/2] Uniswap V4 Security Tests${NC}"
echo "────────────────────────────────────────────────────────"
forge test --match-path test/Uniswap_V4_Security.t.sol -vv --fork-url $MAINNET_RPC_URL
UNISWAP_RESULT=$?
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║                  TEST RESULTS SUMMARY                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

if [ $AAVE_RESULT -eq 0 ]; then
    echo "${GREEN}✅ AAVE V3 Tests: PASSED${NC}"
else
    echo "${RED}❌ AAVE V3 Tests: FAILED${NC}"
fi

if [ $UNISWAP_RESULT -eq 0 ]; then
    echo "${GREEN}✅ Uniswap V4 Tests: PASSED${NC}"
else
    echo "${RED}❌ Uniswap V4 Tests: FAILED${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Detailed Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run with -vvvv for detailed traces:"
echo "  forge test -vvvv --fork-url \$MAINNET_RPC_URL"
echo ""
echo "Generate gas report:"
echo "  forge test --gas-report --fork-url \$MAINNET_RPC_URL"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Exit with error if any test failed
if [ $AAVE_RESULT -ne 0 ] || [ $UNISWAP_RESULT -ne 0 ]; then
    exit 1
fi

echo "${GREEN}✅ All tests completed successfully!${NC}"
echo ""
