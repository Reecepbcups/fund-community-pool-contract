# Fund Community Pool Contract

A contract you can call with some funds to send them to the community pool properly :)

Call the message `{"fund_community_pool":{}}` with some funds to send them to the community pool. (You can send multiple in 1 message)


## Examples

```bash
# sends 1 JUNO and 0.0000123 COSM to the community pool
junod tx wasm execute $COMMUNITY_CONTRACT '{"fund_community_pool":{}}' --amount="1000000ujuno,123ucosm" $JUNOD_COMMAND_ARGS

# Sends funds from another account via governance
$BINARY tx gov submit-proposal execute-contract $COMMUNITY_CONTRACT '{"fund_community_pool":{}}' --amount 5000000ujuno --run-as $KEY_ADDR --title "Community Pool prop" --description="yuh" $TX_FLAGS --from <key> --deposit 10000000ujuno
```

## Store Contract

```bash
# Current Mainnet ID: 2591
junod tx wasm store ./artifacts/fund_community_pool.wasm --node https://rpc.juno.strange.love:443 --keyring-backend=os --gas=2500000 --chain-id=juno-1 --from <key>
```

## Init Contract

```bash
# Really we only need 1 of these since its permission-less
# For other chains, use '{"community_pool_address":"otherchain1xxxxxxx"}'
junod tx wasm instantiate 2591 "{}" --label "community_pool_fund_contract" --no-admin --node https://rpc.juno.strange.love:443 --keyring-backend=os --gas=1000000 --chain-id=juno-1 --from=<key>


# Mainnet: juno10ckf6qlmjlq72juz9ezcu3lqmptq7yzk26tuuxh7y805mherx9ksjunn57
```

## Query Contract

```bash
# Query the contract
junod q wasm contract-state smart juno10ckf6qlmjlq72juz9ezcu3lqmptq7yzk26tuuxh7y805mherx9ksjunn57 '{"contract_info":{}}' --node https://rpc.juno.strange.love:443
```
