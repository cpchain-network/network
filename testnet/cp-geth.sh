#!/bin/sh
export VERBOSITY="3"
export GETH_DATA_DIR="/db"
export GETH_CHAINDATA_DIR="/db/geth/chaindata"
export GENESIS_FILE_PATH="/db/genesis.json"

# start the geth node
echo "Starting CP Geth"

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
    echo "$GETH_CHAINDATA_DIR missing, running init"
    echo "Initializing genesis."
    geth --verbosity="$VERBOSITY" init \
        --datadir="$GETH_DATA_DIR" \
        --state.scheme=hash \
        "$GENESIS_FILE_PATH"
else
    echo "$GETH_CHAINDATA_DIR exists."
fi

exec geth \
        --datadir="$GETH_DATA_DIR" \
        --verbosity="$VERBOSITY" \
        --http \
        --http.corsdomain="*" \
        --http.vhosts="*" \
        --http.addr=0.0.0.0 \
        --http.port="8545" \
        --http.api=web3,debug,eth,txpool,net,engine,trace \
        --ws \
        --ws.addr=0.0.0.0 \
        --ws.port=8546 \
        --ws.origins="*" \
        --ws.api=debug,eth,txpool,net,engine \
        --syncmode=full \
        --nodiscover \
        --maxpeers=0 \
        --networkid=86606 \
        --txpool.nolocals \
        --txpool.lifetime=1m \
        --txpool.pricelimit=8000000000 \
        --txpool.accountslots=12 \
        --txpool.accountqueue=24 \
        --txpool.globalslots=4096 \
        --txpool.globalqueue=1024 \
        --txpool.pricebump=15 \
        --rpc.allow-unprotected-txs \
        --authrpc.addr="0.0.0.0" \
        --authrpc.port=8551 \
        --authrpc.vhosts="*" \
        --authrpc.jwtsecret=./jwt_secret_txt \
        --gcmode=archive \
        --metrics \
        --metrics.addr=0.0.0.0 \
        --metrics.port=6060 \
        --rollup.sequencerhttp=https://rpc-testnet.cpchain.com \
        "$@"
    