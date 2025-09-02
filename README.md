# CPChain RPC Node Deployment Guide

This guide provides comprehensive instructions for deploying CPChain RPC nodes:

- **cp-geth**: Execution layer client
- **cp-node**: Consensus layer client

## Table of Contents

- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Deployment Methods](#deployment-methods)
  - [Method 1: Docker Deployment](#method-1-docker-deployment)
  - [Method 2: Shell Script Deployment](#method-2-shell-script-deployment)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

## System Requirements

### Hardware Requirements
- **CPU**: 4+ cores (8+ cores recommended)
- **Memory**: 8GB+ (16GB recommended for optimal performance)
- **Storage**: 500GB+ SSD (more space required for archive mode)
- **Network**: Stable internet connection with good bandwidth

### Software Requirements
- Docker 20.10+ (for Docker deployment)
- Go 1.22+ (for shell script deployment)
- OpenSSL (for key generation)
- At least 50GB available disk space

## Prerequisites

### 1. Clone the Repository
```bash
git clone https://github.com/cpchain-network/network.git
cd network
```

### 2. Generate Required Keys

#### JWT Secret
```bash
# Generate JWT secret for authentication between cp-geth and cp-node
openssl rand -hex 32 > jwt_secret_txt
```

#### P2P Private Key
```bash
# Generate P2P private key for node identification
cast w n |grep -i "Private Key" |awk -F ": " '{print $2}' |sed 's/0x//' > p2p_node_key_txt
```

### 3. Prepare Configuration Files
Ensure you have the necessary configuration files in the appropriate network directory:
- `mainnet/genesis.json` - Genesis block configuration
- `mainnet/rollup.json` - Rollup configuration
- `testnet/genesis.json` - Testnet genesis configuration
- `testnet/rollup.json` - Testnet rollup configuration

## Deployment Methods

### Method 1: Docker Deployment

This method uses Docker containers to run the CPChain RPC node components.

#### Step 1: Build Docker Images

##### Build cp-geth Image
```bash
cd cp-geth
docker build -t cpchain-network/cp-geth:latest .
```

##### Build cp-node Image
```bash
cd cp-node
docker build -t cpchain-network/cp-node:latest .
```

#### Step 2: Start cp-geth Container
```bash
# Create data volume
docker volume create geth_data

# Start cp-geth container
docker run -d \
  --name cp-geth-rpc \
  -p 8545:8545 \
  -p 8546:8546 \
  -p 6060:6060 \
  -v $(pwd)/mainnet/genesis.json:/db/genesis.json:ro \
  -v $(pwd)/jwt_secret_txt:/config/jwt_secret_txt:ro \
  -v geth_data:/db \
  -e VERBOSITY=3 \
  -e GETH_DATA_DIR=/db \
  -e GETH_CHAINDATA_DIR=/db/geth/chaindata \
  -e GENESIS_FILE_PATH=/db/genesis.json \
  -e CHAIN_ID=86608 \
  -e RPC_PORT=8545 \
  -e WS_PORT=8546 \
  -e AUTHRPC_PORT=8551 \
  -e METRICS_PORT=6060 \
  cpchain-network/cp-geth:latest
```

#### Step 3: Start cp-node Container
```bash
# Create data volume
docker volume create node_data

# Start cp-node container
docker run -d \
  --name cp-node-rpc \
  -p 8547:8545 \
  -p 9004:9003 \
  -p 7301:7300 \
  -v $(pwd)/mainnet/rollup.json:/config/rollup.json:ro \
  -v $(pwd)/jwt_secret_txt:/config/jwt_secret_txt:ro \
  -v $(pwd)/p2p_node_key_txt:/config/p2p_node_key_txt:ro \
  -v node_data:/cp-node \
  --link cp-geth-rpc:cp-geth-rpc \
  -e OP_NODE_L2_ENGINE_RPC=http://cp-geth-rpc:8551 \
  -e OP_NODE_L2_ENGINE_AUTH=/config/jwt_secret_txt \
  -e OP_NODE_LOG_LEVEL=info \
  -e OP_NODE_P2P_SEQUENCER_ADDRESS=0xDcdac98A82b8E586900Da6a87CeD838FB09c49e6 \
  -e OP_NODE_ROLLUP_CONFIG=/config/rollup.json \
  -e OP_NODE_RPC_ADDR=0.0.0.0 \
  -e OP_NODE_RPC_PORT=8545 \
  -e OP_NODE_P2P_LISTEN_IP=0.0.0.0 \
  -e OP_NODE_P2P_LISTEN_TCP_PORT=9003 \
  -e OP_NODE_P2P_LISTEN_UDP_PORT=9003 \
  -e OP_NODE_P2P_PEER_SCORING=light \
  -e OP_NODE_P2P_NO_DISCOVERY=true \
  -e OP_NODE_P2P_PEER_BANNING=true \
  -e OP_NODE_P2P_PRIV_PATH=/config/p2p_node_key_txt \
  -e OP_NODE_P2P_DISCOVERY_PATH=/cp-node/opnode_discovery_db \
  -e OP_NODE_P2P_PEERSTORE_PATH=/cp-node/opnode_peerstore_db \
  -e OP_NODE_P2P_STATIC= \
  -e OP_NODE_METRICS_ENABLED=true \
  -e OP_NODE_METRICS_ADDR=0.0.0.0 \
  -e OP_NODE_METRICS_PORT=7300 \
  -e OP_NODE_P2P_SYNC_ONLYREQTOSTATIC=true \
  -e OP_NODE_EL_RPC_MAX_BATCH_SIZE=500 \
  -e OP_NODE_EL_RPC_URL=https://rpc.cpchain.com \
  -e OP_NODE_SYNCMODE=execution-layer \
  cpchain-network/cp-node:latest
```

#### Docker Management Commands
```bash
# View logs
docker logs -f cp-geth-rpc
docker logs -f cp-node-rpc

# Stop containers
docker stop cp-geth-rpc cp-node-rpc

# Remove containers
docker rm cp-geth-rpc cp-node-rpc

# Remove volumes (WARNING: This will delete all data)
docker volume rm geth_data node_data
```

### Method 2: Shell Script Deployment

This method uses shell scripts to run the CPChain components directly on the host system.

#### Prerequisites for Shell Script Deployment
- Go 1.22+ installed
- cp-geth and cp-node binaries built and available in PATH
- Required configuration files in the network directory

#### Step 1: Build Binaries

#### Step 2: Prepare Environment
```bash
# Create necessary directories
mkdir -p /db/geth/chaindata
mkdir -p /cp-node/opnode_discovery_db
mkdir -p /cp-node/opnode_peerstore_db

# Copy configuration files
cp mainnet/genesis.json /db/genesis.json
cp mainnet/rollup.json /config/rollup.json
```

#### Step 3: Start cp-geth
```bash
cd mainnet
chmod +x cp-geth.sh
./cp-geth.sh
```

#### Step 4: Start cp-node (in another terminal)
```bash
cd mainnet
chmod +x cp-node.sh
./cp-node.sh
```

### Health Checks
```bash
# Check cp-geth RPC
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```