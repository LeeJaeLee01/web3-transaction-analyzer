# Track Wallet Nhiều Chain (Multi-Chain Wallet Tracking)

Thư mục này chứa các folder và file liên quan đến **track wallet nhiều chain**.

## Cấu trúc

```
track-wallets/
├── chain/           # Toàn bộ logic chain: aggregator, accounts, balances, các chain managers
├── db/              # addressbook (multichain label)
├── externalapis/    # etherscan_like (HasChainActivity cho kiểm tra hoạt động theo chain)
└── README.md
```

## File / module chính cho Track Wallet Nhiều Chain

### 1. `chain/aggregator.py` – Logic chính

- **`ChainsAggregator`**: Tổng hợp tài khoản và balance nhiều chain.
- **`check_single_address_activity(address, chains)`**: Kiểm tra địa chỉ có hoạt động trên từng chain hay không.
- **`track_evm_address(address, chains)`**: Thêm địa chỉ EVM vào danh sách track cho các chain chỉ định.
- **`check_chains_and_add_accounts(account, chains)`**: Kiểm tra hoạt động rồi bắt đầu track account trên các chain tương ứng.
- **`add_accounts_to_all_evm(accounts)`**: Thêm từng account vào tất cả chain EVM (Ethereum, Optimism, Polygon, Arbitrum, Base, Gnosis, Scroll, BSC, Avalanche, zkSync Lite).
- **`detect_evm_accounts()`**: Tự phát hiện EVM accounts trên nhiều chain và thêm vào tracked accounts.

### 2. `chain/accounts.py`

- **`BlockchainAccounts`**: Dataclass lưu danh sách địa chỉ theo từng chain (eth, optimism, polygon_pos, arbitrum_one, base, gnosis, scroll, binance_sc, btc, bch, ksm, dot, avax, zksync_lite, solana).
- **`BlockchainAccountData`**: (chain, address, label, tags).
- **`SingleBlockchainAccountData`**: Dữ liệu account đơn với label/tags.

### 3. `chain/balances.py`

- **`BlockchainBalances`**: Cấu trúc balance theo từng chain (EVM, BTC, Substrate, Solana, Eth2).

### 4. `db/addressbook.py`

- **`DBAddressbook.maybe_make_entry_name_multichain(address)`**: Gán tên (label) hiện có của địa chỉ cho “multichain” (áp dụng chung nhiều chain).

### 5. `externalapis/etherscan_like.py`

- **`HasChainActivity`**: Interface/API để kiểm tra địa chỉ có hoạt động trên chain (dùng trong `check_single_address_activity`).

## Cách dùng

- Backend gọi `chains_aggregator.add_accounts_to_all_evm(accounts)` khi thêm nhiều địa chỉ và muốn track trên mọi chain EVM.
- Frontend có thể dùng “add account” / “track across chains” và gọi API tương ứng, backend sẽ dùng `check_chains_and_add_accounts` / `track_evm_address` / `add_accounts_to_all_evm`.

## Lưu ý

- Code trong `track-wallets/` có thể phụ thuộc vào types, db, utils. Để chạy độc lập cần điều chỉnh import hoặc copy thêm các module phụ thuộc.
- Các chain được hỗ trợ: ví dụ `SUPPORTED_EVM_EVMLIKE_CHAINS`, `SupportedBlockchain`.
