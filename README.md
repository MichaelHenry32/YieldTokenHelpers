## Foundry

This smart contract aims to wrap Fraxlend and allow for the easy usage of sfrxUSD Fraxlend asset pairs.

TODO:
    * Wrap borrowAsset
    * Wrap repayAsset
    * Add additional max helper methods

To deploy all contracts to your local anvil node:

Start Anvil: `anvil --fork-url https://rpc.frax.com --auto-impersonate`

Run Forge Test Script: `forge script script/DeployFraxlendPair.s.sol --rpc-url http://localhost:8545 -vvv --broadcast --unlocked`

`cast send 0xfc00000000000000000000000000000000000001 --from 0x230963164d9637a4c536270A06B4e3636d44a2D9 "transfer(address, uint256)(bool)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 1000 ether --unlocked`

forge script script/DeployFraxlendPair.s.sol --rpc-url http://localhost:8545 -vvv --broadcast --unlocked && cast send 0xfc00000000000000000000000000000000000001 --from 0x230963164d9637a4c536270A06B4e3636d44a2D9 "transfer(address, uint256)(bool)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 4000000000000000000000 --unlocked