// tokens on ethereum network have token creator address, token contract address and token address
// - when token is created, it involves deployment of smart contract that governs behavior and rules of token
/*

Token Creator Address: 
- this is Ethereum address of account or entity that initiated creation of token smart contract
- it is address from which deployment transaction of token contract was sent

Token Contract Address: 
- when smart contract, which represents token, is deployed on Ethereum blockchain, it is assigned unique address
- this address becomes identifier and entry point for interactions with that specific token
- any transactions or operations involving this token, such as transfers or approvals, are performed through this contract address

Token Address: 
- refer to address of particular token instance or account
- when tokens are transferred or allocated to various Ethereum addresses (wallets), each address holds balance of that specific token
- each of these addresses is unique and holds its own balance of token

- token creator initiates deployment of token contract, which gets unique contract address
- this contract manages behavior of token, and individual Ethereum addresses interact with this contract to hold and transact tokens