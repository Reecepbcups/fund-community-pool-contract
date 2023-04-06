use std::env;

#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult};
use cw2::set_contract_version;

use crate::error::ContractError;
use crate::msg::{ContractInformationResponse, ExecuteMsg, InstantiateMsg, QueryMsg};

use crate::state::INFORMATION;
use crate::utils::get_community_pool_msg;

const CONTRACT_NAME: &str = "crates.io:fund-community-pool";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    _info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;

    let community_pool_address = msg
        .community_pool_address
        .unwrap_or_else(|| "juno1jv65s3grqf6v6jl3dp4t6c9t9rk99cd83d88wr".to_string());

    // save the contract information
    let contract_info = ContractInformationResponse {
        community_pool_address: community_pool_address.clone(),
    };

    // save this to the users profile
    INFORMATION.save(deps.storage, &contract_info)?;

    Ok(Response::new()
        .add_attribute("action", "instantiate")
        .add_attribute("address", community_pool_address))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::FundCommunityPool {} => {
            let community_pool_addr = INFORMATION.load(deps.storage)?.community_pool_address;

            let msg = get_community_pool_msg(&env.contract.address, info.funds)?;

            Ok(Response::new()
                .add_attribute("action", "fund_community_pool")
                .add_attribute("address", community_pool_addr)
                .add_message(msg)
            )
        }
    }
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::ContractInfo {} => {
            let info = INFORMATION.load(deps.storage)?;
            let v = to_binary(&info)?;
            Ok(v)
        }
    }
}

#[cfg(test)]
mod tests {}
