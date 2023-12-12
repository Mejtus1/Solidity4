// create token on solidity, test it on testnet and run it
// create simple website and connect it with token and provide uniswap liquidity 

// prejst si z token lounchu ako to vsetko prebieha 
// mozno dobre to spravit ako typ TITAN token a dohladat liquidity, create atc

// take created code and run it in remix to see its methods 
// Can you uniswap on testnet ? 


// 0x335d4267b944a41f46a94422bd164E2579134437 = CONTRACT ADDRESS 
// https://etherscan.io/address/0x335d4267b944a41f46a94422bd164e2579134437
// 0x95a1D7dc291bc77D02891f5DC192ee0d543CF0B8 = TOKEN CREATOR ADDRESS 
// https://etherscan.io/address/0x95a1d7dc291bc77d02891f5dc192ee0d543cf0b8 


// 1. This wallet created token (0x95a1D7dc291bc77D02891f5DC192ee0d543CF0B8)
// 1. send ether, added liquidity and renounced ownership (it would be connected with )
0xf0ca537d4d57f081fd41758a36ebc415b557f07c25321e58dc96f2f56cb57706 Lock LP Token 	   9 hrs 20 mins ago    OUT UNCX Network Security : LP Lockers 0.1 ETH	0.01253352
0x62c8163bacaff405bb4f114a9eaa0fa8026bf9dd317d75693c2b22b34c0bc3ce Renounce Ownership  9 hrs 20 mins ago	OUT	0x335d42...79134437 0 ETH	0.00073885
0xd7ee37f5937d5e9ee2e869d4a524b3ec50a9b4e831d0088cc5644f77d86712d9 Remove Limits 	   9 hrs 20 mins ago	OUT	0x335d42...79134437 0 ETH	0.00115884
0x0166fb1d4fdcd59f9015d8cd07cbc8d1ac815ae1e277b61f79ed2405c7854ca2 Approve 	           9 hrs 21 mins ago    OUT Uniswap V2: TITAN 48 0 ETH	0.00143795
0x55f2b13ee5238a87375f27e36f07a1356bd8d8180d21fa40644bb50efed40be6 Open Trading        9 hrs 22 mins ago	OUT	0 ETH	0.09048483
0x148fb331ec626434c195bf01d8f077e5dccc370bd44d6c575da659d86988ae6d Transfer            9 hrs 24 mins ago	OUT	0 ETH	0.00160727
0x05f3489798fccaf6de96a4de7b9cc940ff7db6c5ca4b6f97e3bf0fe1e5a8ca19 Transfer            9 hrs 24 mins ago	OUT	1 ETH	0.00065386
0x232261c39ae38bd5bbfd612d7306aee82df6ca25348ae3ef3e952cc7a47f394c 0x60806040          9 hrs 25 mins ago	OUT	Create: TokenTitanBot 0 ETH	0.10123243
0xc3ad5e71e0205e17c56eb9632158bbbcb39579ed6ff17c0fad4e64d8aaadc0da Transfer            9 hrs 31 mins ago	IN FixedFloat 	1.5836769 ETH	0.000714
// ^starts with this transaction 

// https://etherscan.io/address/0x95a1d7dc291bc77d02891f5dc192ee0d543cf0b8 = 0x95 ADDRESS (Main wallet, that created contract)

// Internal transactions for this wallet CORRESPONT WITH FEES PAID FROM CONTRACT 
0xf3d49f08f8b4076e75d64a866c215555ec4fd9b5ad7ae8568b3cc491e9b03f76 18680997 9 hrs 41 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.03217377 ETH
0x09ce0d87803dc1ff9c4f6aa232b10c7c665d503fc6c5422e452306476b3815fd 18680997 9 hrs 41 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.03571932 ETH
0x86071056252deac04608b3bde7c288be828d07419588bf01bfedbd506e495334 18680997 9 hrs 41 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.03988534 ETH
0xb9b0fb7ea82a1830c6d5601d2f9632ac56ae48301130ad3ed748d30e0646c316 18680997 9 hrs 41 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.04482559 ETH
0x403f425bc7630161ab965e5b3e26a7735f5b24113e6f76e31497d2dc4b804ca8 18680995 9 hrs 42 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.04712981 ETH
0x3f72653d04a12935b894e8768c8715d5f59023e21ad48e2e05336268e62f4e0a 18680989 9 hrs 43 mins ago 0x335d42...79134437 0x95a1D7...543CF0B8 0.0522327 ETH
// ^ starts with this transaction 

// 2. https://etherscan.io/address/0x335d4267b944a41f46a94422bd164e2579134437
// this is token contract and transactions correspont with upper ones, after open trading the trading starts and people buy in 
0x55f2b13ee5238a87375f27e36f07a1356bd8d8180d21fa40644bb50efed40be6 Open Trading        9 hrs 22 mins ago	IN	0 ETH	0.09048483
0x148fb331ec626434c195bf01d8f077e5dccc370bd44d6c575da659d86988ae6d Transfer 	       9 hrs 24 mins ago	IN	0 ETH	0.00160727
0x05f3489798fccaf6de96a4de7b9cc940ff7db6c5ca4b6f97e3bf0fe1e5a8ca19 Transfer	           9 hrs 24 mins ago	IN	1 ETH	0.00065386
0x232261c39ae38bd5bbfd612d7306aee82df6ca25348ae3ef3e952cc7a47f394c 0x60806040          9 hrs 25 mins ago	IN	Create: TokenTitanBot 0 ETH	0.10123243
// ^ transactions start with this one 

// 3. internal transactions 
Supply 7,200,000,000 TITAN And 1 ETH Liquidity To Uniswap V2
18680944 9 hrs 37 mins ago 0x55f2b13ee5238a87375f27e36f07a1356bd8d8180d21fa40644bb50efed40be6 call 0x335d42...79134437 Uniswap V2: Router 2 1 ETH
                            OPEN TRADING transaction in 1. 
// rest of the internal transactions is exchange between people and contract with fee distribution address set to 0x95a1D7dc291bc77D02891f5DC192ee0d543CF0B8 = (token creator address)
0xb9b0fb7ea82a1830c6d5601d2f9632ac56ae48301130ad3ed748d30e0646c316 call	0x335d42...79134437 0x95a1D7...543CF0B8 0.044825594563872474 ETH
0xb9b0fb7ea82a1830c6d5601d2f9632ac56ae48301130ad3ed748d30e0646c316 call	Uniswap V2: Router 2 0x335d42...79134437 0.044825594563872474 ETH 18680995	9 hrs 27 mins ago	
0x403f425bc7630161ab965e5b3e26a7735f5b24113e6f76e31497d2dc4b804ca8 call	0x335d42...79134437 0x95a1D7...543CF0B8 0.047129818815157975 ETH
0x403f425bc7630161ab965e5b3e26a7735f5b24113e6f76e31497d2dc4b804ca8 call	Uniswap V2: Router 2 0x335d42...79134437 0.047129818815157975 ETH 18680989	9 hrs 28 mins ago	
0x3f72653d04a12935b894e8768c8715d5f59023e21ad48e2e05336268e62f4e0a call	0x335d42...79134437 0x95a1D7...543CF0B8 0.052232706562200683 ETH
0x3f72653d04a12935b894e8768c8715d5f59023e21ad48e2e05336268e62f4e0a call	Uniswap V2: Router 2 0x335d42...79134437 0.052232706562200683 ETH
// ^ends with this transaction

// USING 0x3f as example internal transaction 
0x3f72653d04a12935b894e8768c8715d5f59023e21ad48e2e05336268e62f4e0a call	0x335d42...79134437 0x95a1D7...543CF0B8 0.052232706562200683 ETH
0x3f72653d04a12935b894e8768c8715d5f59023e21ad48e2e05336268e62f4e0a call	Uniswap V2: Router 2 0x335d42...79134437 0.052232706562200683 ETH

From: ENS Name skeelz.eth Interacted With (To): 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD (Uniswap: Universal Router)
Transfer 0.052232706562200683 ETH From Wrapped Ether To Uniswap V2: Router 2 // wallet skeelz interacts with UNISWAP router
Transfer 0.052232706562200683 ETH From Uniswap V2: Router 2 To 0x335d42...79134437 // Uniswap sends to CONTRACT wallet
Transfer 0.052232706562200683 ETH From 0x335d42...79134437 To 0x95a1D7...543CF0B8 // CONTRACT wallet pays fees to ORIGINAL wallet 1 which created contract (0x95a1D7dc291bc77D02891f5DC192ee0d543CF0B8 token creator address)
Transfer 0.064421533464119422 ETH From Wrapped Ether To Uniswap: Universal Router // rest of the ether goes to Uniswap router
Transfer 0.064421533464119422 ETH From Uniswap: Universal Router To 0xA87b68...1d29Dfb4 // Uniswap router swaps and pays rest amount to skeelz wallet

// 4. after that token creator calls aditional methods that include: 
// these methods are called few minutes after trading is open 
0xf0ca537d4d57f081fd41758a36ebc415b557f07c25321e58dc96f2f56cb57706 Lock LP Token       18680955 9 hrs 52 mins ago 0x95a1D7...543CF0B8 OUT	UNCX Network Security : LP Lockers 0.1 ETH	0.01253352
0x62c8163bacaff405bb4f114a9eaa0fa8026bf9dd317d75693c2b22b34c0bc3ce Renounce Ownersh... 18680954 9 hrs 52 mins ago 0x95a1D7...543CF0B8 OUT 0x335d42...79134437 0 ETH 0.00073885
0xd7ee37f5937d5e9ee2e869d4a524b3ec50a9b4e831d0088cc5644f77d86712d9 Remove Limits       18680954 9 hrs 52 mins ago 0x95a1D7...543CF0B8 OUT 0x335d42...79134437 0 ETH 0.00115884
0x0166fb1d4fdcd59f9015d8cd07cbc8d1ac815ae1e277b61f79ed2405c7854ca2 Approve             18680953 9 hrs 52 mins ago 0x95a1D7...543CF0B8 OUT Uniswap V2: TITAN 48 0 ETH	0.00143795
