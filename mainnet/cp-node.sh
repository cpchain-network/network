#!/bin/sh

#set up env
export OP_NODE_L2_ENGINE_RPC='http://localhost::8551'
export OP_NODE_L2_ENGINE_AUTH=./jwt_secret_txt
export OP_NODE_LOG_LEVEL='info'
export OP_NODE_P2P_SEQUENCER_ADDRESS='0xDcdac98A82b8E586900Da6a87CeD838FB09c49e6'
export OP_NODE_ROLLUP_CONFIG='/config/rollup.json'
export OP_NODE_RPC_ADDR='0.0.0.0'
export OP_NODE_RPC_PORT=8545
export OP_NODE_P2P_LISTEN_IP='0.0.0.0'
export OP_NODE_P2P_LISTEN_TCP_PORT=9003
export OP_NODE_P2P_LISTEN_UDP_PORT=9003
export OP_NODE_P2P_PEER_SCORING='light'
export OP_NODE_P2P_NO_DISCOVERY='true'
export OP_NODE_P2P_PEER_BANNING='true'
export OP_NODE_P2P_PRIV_PATH=./p2p_node_key_txt
export OP_NODE_P2P_DISCOVERY_PATH='/cp-node/opnode_discovery_db'
export OP_NODE_P2P_PEERSTORE_PATH='/cp-node/opnode_peerstore_db'
export OP_NODE_P2P_STATIC=''
export OP_NODE_METRICS_ENABLED='true'    
export OP_NODE_METRICS_ADDR='0.0.0.0'
export OP_NODE_METRICS_PORT='7300'
export OP_NODE_P2P_SYNC_ONLYREQTOSTATIC='true'
export OP_NODE_EL_RPC_MAX_BATCH_SIZE=500
export OP_NODE_EL_RPC_URL='https://rpc.cpchain.com'
export OP_NODE_SYNCMODE='execution-layer'

# start the geth node
echo "Starting CP Node"

exec cp-node