use cosmwasm_schema::{cw_serde, QueryResponses};

#[cw_serde]
pub struct InstantiateMsg {
    pub community_pool_address: Option<String>,
}

#[cw_serde]
pub enum ExecuteMsg {
    FundCommunityPool {},
}

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(ContractInformationResponse)]
    ContractInfo {},
}

// === RESPONSES ===
#[cw_serde]
pub struct ContractInformationResponse {
    pub community_pool_address: String,
}
