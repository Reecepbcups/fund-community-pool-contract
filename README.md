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
