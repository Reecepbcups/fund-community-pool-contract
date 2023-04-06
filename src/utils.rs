use crate::ContractError;

use cosmos_sdk_proto::cosmos::base::v1beta1::Coin as SdkCoin;
use cosmos_sdk_proto::cosmos::distribution::v1beta1::MsgFundCommunityPool;
use cosmwasm_std::{Addr, Coin, CosmosMsg, StdError, StdResult};

pub fn get_community_pool_msg(
    depositor: &Addr,
    funds: Vec<Coin>,
) -> Result<CosmosMsg, ContractError> {
    let coins = funds
        .iter()
        .map(|coin| SdkCoin {
            denom: coin.denom.to_string(),
            amount: coin.amount.to_string(),
        })
        .collect();

    Ok(proto_encode(
        MsgFundCommunityPool {
            amount: coins,
            depositor: depositor.to_string(),
        },
        "/cosmos.distribution.v1beta1.MsgFundCommunityPool".to_string(),
    )?)
}

// encode a protobuf into a cosmos message
// Inspired by https://github.com/alice-ltd/smart-contracts/blob/master/contracts/alice_terra_token/src/execute.rs#L73-L76
pub fn proto_encode<M: prost::Message>(msg: M, type_url: String) -> StdResult<CosmosMsg> {
    let mut bytes = Vec::new();
    prost::Message::encode(&msg, &mut bytes)
        .map_err(|_e| StdError::generic_err("Message encoding must be infallible"))?;
    Ok(cosmwasm_std::CosmosMsg::<cosmwasm_std::Empty>::Stargate {
        type_url,
        value: cosmwasm_std::Binary(bytes),
    })
}

pub fn throw_err(msg: &str) -> ContractError {
    ContractError::Std(cosmwasm_std::StdError::generic_err(msg))
}
