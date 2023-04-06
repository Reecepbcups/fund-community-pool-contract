use cw_storage_plus::Item;

use crate::msg::ContractInformationResponse;

// Config configuration Information
pub const INFORMATION: Item<ContractInformationResponse> = Item::new("info");
