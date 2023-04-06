# Test script for Juno Smart Contracts (By @Reecepbcups)
#
# sh ./e2e/test_e2e.sh
#
# NOTES: anytime you use jq, use `jq -rc` for ASSERT_* functions (-c removes format, -r is raw to remove \" quotes)

# get functions from helpers file 
# -> query_contract, wasm_cmd, mint_cw721, send_nft_to_listing, send_cw20_to_listing
source ./e2e/helpers.sh

# NOTE: Its probably better to e2e test with JS/TS, but this gives you some info for runing in CLI 
# (I'm on linux 86_64. If you are on a M1/M2 mac, compile_and_copy & start_docker will not work)
# We do have a arm based juno on v13 here:
# docker pull ghcr.io/cosmoscontracts/juno:v13.0.1@sha256:7fd1f38098342355b28ba01d31ae2e32924ea18e739bcd0e550cdf13bc8a5683
# (https://github.com/CosmosContracts/juno/pkgs/container/juno)

# Run:
# CHAIN_ID="local-1" HOME_DIR="~/.juno1/" TIMEOUT_COMMIT="1500ms" CLEAN=true sh scripts/test_node.sh
# Since we need to alter voting time & docker does not allow us to do that yet

BINARY="junod"
DENOM='ujuno'
JUNOD_CHAIN_ID='local-1'
JUNOD_NODE='http://localhost:26657/'
TX_FLAGS="--fees=5000$DENOM --gas 5000000 -y -b block --chain-id $JUNOD_CHAIN_ID --node $JUNOD_NODE --output json"

export JUNOD_COMMAND_ARGS="$TX_FLAGS --from juno1"
export KEY_ADDR="juno1hj5fveer5cjtn4wd6wstzugjfdxzl0xps73ftl"
export COMMUNITY_POOL="juno1jv65s3grqf6v6jl3dp4t6c9t9rk99cd83d88wr"



function compile_and_copy {    
    # compile vaults contract here
    docker run --rm -v "$(pwd)":/code \
      --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
      --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
      cosmwasm/rust-optimizer:0.12.11

    # copy wasm to docker container
    # docker cp ./artifacts/. $CONTAINER_NAME:/
}

# ========================
# === Contract Uploads ===
# ========================
function upload_contract {
    echo "Storing contract..."
    UPLOAD=$($BINARY tx wasm store ./artifacts/fund_community_pool.wasm $JUNOD_COMMAND_ARGS | jq -r '.txhash') && echo $UPLOAD
    BASE_CODE_ID=$($BINARY q tx $UPLOAD --output json | jq -r '.logs[0].events[] | select(.type == "store_code").attributes[] | select(.key == "code_id").value') && echo "Code Id: $BASE_CODE_ID"

    # == INSTANTIATE ==
    # ADMIN="$KEY_ADDR"
    
    TX_HASH=$($BINARY tx wasm instantiate "$BASE_CODE_ID" "{}" --label "community_pool_fund" $JUNOD_COMMAND_ARGS --no-admin | jq -r '.txhash') && echo $VAULT_TX


    export COMMUNITY_CONTRACT=$($BINARY query tx $TX_HASH --output json | jq -r '.logs[0].events[0].attributes[0].value') && echo "COMMUNITY_CONTRACT: $COMMUNITY_CONTRACT"
}

# ===============
# === ASSERTS ===
# ===============
FINAL_STATUS_CODE=0

function ASSERT_EQUAL {
    # For logs, put in quotes. 
    # If $1 is from JQ, ensure its -r and don't put in quotes
    if [ "$1" != "$2" ]; then        
        echo "ERROR: $1 != $2" 1>&2
        FINAL_STATUS_CODE=1 
    else
        echo "SUCCESS"
    fi
}

function ASSERT_CONTAINS {
    if [[ "$1" != *"$2"* ]]; then
        echo "ERROR: $1 does not contain $2" 1>&2        
        FINAL_STATUS_CODE=1 
    else
        echo "SUCCESS"
    fi
}

function add_accounts {
    # provision juno default user i.e. juno1hj5fveer5cjtn4wd6wstzugjfdxzl0xps73ftl
    echo "decorate bright ozone fork gallery riot bus exhaust worth way bone indoor calm squirrel merry zero scheme cotton until shop any excess stage laundry" | $BINARY keys add test-user --recover --keyring-backend test
    # juno1efd63aw40lxf3n4mhf7dzhjkr453axurv2zdzk
    echo "wealth flavor believe regret funny network recall kiss grape useless pepper cram hint member few certain unveil rather brick bargain curious require crowd raise" | $BINARY keys add other-user --recover --keyring-backend test
    # juno16g2rahf5846rxzp3fwlswy08fz8ccuwk03k57y
    echo "clip hire initial neck maid actor venue client foam budget lock catalog sweet steak waste crater broccoli pipe steak sister coyote moment obvious choose" | $BINARY keys add user3 --recover --keyring-backend test

    # send some 10 junox funds to the users
    $BINARY tx bank send juno1 juno1efd63aw40lxf3n4mhf7dzhjkr453axurv2zdzk 10000000$DENOM $JUNOD_COMMAND_ARGS
    $BINARY tx bank send juno1 juno16g2rahf5846rxzp3fwlswy08fz8ccuwk03k57y 10000000#DENOM $JUNOD_COMMAND_ARGS
}

# === COPY ALL ABOVE TO SET ENVIROMENT UP LOCALLY ====



# =============
# === LOGIC ===
# =============

compile_and_copy # the compile takes time for the docker container to start up
sleep 1
add_accounts

upload_contract

# == INITIAL TEST ==
info=$(query_contract $COMMUNITY_CONTRACT '{"contract_info":{}}' | jq -r '.data') && echo $info

$BINARY q bank balances $COMMUNITY_POOL
$BINARY q bank balances $KEY_ADDR

# Send funds to the pool correctly
$BINARY tx wasm execute $COMMUNITY_CONTRACT '{"fund_community_pool":{}}' --amount="1000000$DENOM" $JUNOD_COMMAND_ARGS

# run it as the KEY_ADDR account and send 123ucosm
$BINARY tx gov submit-proposal execute-contract $COMMUNITY_CONTRACT '{"fund_community_pool":{}}' --amount 5000000ujuno --run-as $KEY_ADDR --title "Community Pool Funding from another account" --description="yuh" $TX_FLAGS --from feeacc --deposit 10000000$DENOM
$BINARY tx gov vote 1 yes $JUNOD_COMMAND_ARGS

$BINARY q gov proposal 1

$BINARY q bank balances $COMMUNITY_POOL
