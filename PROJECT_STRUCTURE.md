# 📁 Cấu trúc dự án — web3-transaction-analyzer

> Tài liệu phân tích và mô tả các folder trong repo, giúp theo dõi và đọc code dễ dàng.

---

## 🗂 Tổng quan cây thư mục

```
web3-transaction-analyzer/
│
├── 📂 track-wallets/           → Track wallet nhiều chain
├── 📂 integrate-exchange-API/  → Tích hợp API sàn giao dịch
├── 📂 get-price-token/         → Lấy giá token / asset
├── 📂 detect-protocol/         → Phát hiện protocol & decode giao dịch
│
├── 📄 requirements.txt         → Danh sách thư viện Python
├── 📄 install_dependencies.sh  → Script cài đặt dependencies
├── 📄 push_in_stages.sh        → Script commit + push từng module (tránh push quá nặng)
├── 📄 README.md                → Hướng dẫn nhanh
└── 📄 PROJECT_STRUCTURE.md     → File này — phân tích cấu trúc
```

---

## 📂 1. track-wallets

**Mục đích:** Theo dõi ví trên nhiều chain (EVM, Bitcoin, Solana, …), thêm/xóa account theo chain, gán label multichain.

| Thành phần | Mô tả |
|------------|--------|
| **chain/** | Aggregator, accounts, balances, managers từng chain |
| **db/** | Address book (label multichain cho địa chỉ) |
| **externalapis/** | Etherscan-like API (kiểm tra hoạt động địa chỉ theo chain) |

### Cấu trúc chi tiết

```
track-wallets/
├── chain/
│   ├── aggregator.py      ← ChainsAggregator, track_evm_address, add_accounts_to_all_evm
│   ├── accounts.py        ← BlockchainAccounts, BlockchainAccountData
│   ├── balances.py        ← BlockchainBalances
│   ├── manager.py
│   ├── structures.py
│   └── [ethereum, optimism, polygon_pos, arbitrum_one, base, ...]  (các chain con)
├── db/
│   └── addressbook.py     ← maybe_make_entry_name_multichain()
├── externalapis/
│   └── etherscan_like.py  ← HasChainActivity
└── README.md
```

### API chính cần nhớ

| API | Chức năng |
|-----|-----------|
| `check_single_address_activity(address, chains)` | Kiểm tra địa chỉ có hoạt động trên từng chain |
| `track_evm_address(address, chains)` | Thêm địa chỉ vào danh sách track theo chain |
| `check_chains_and_add_accounts(account, chains)` | Kiểm tra hoạt động rồi bắt đầu track |
| `add_accounts_to_all_evm(accounts)` | Thêm account vào tất cả chain EVM |

---

## 📂 2. integrate-exchange-API

**Mục đích:** Kết nối sàn giao dịch (Binance, Kraken, Coinbase, …), lấy balance và lịch sử trade, expose qua REST API.

| Thành phần | Mô tả |
|------------|--------|
| **exchanges/** | Interface, manager, connector từng sàn |
| **api/** | REST, services, schemas (expose exchange qua HTTP) |

### Cấu trúc chi tiết

```
integrate-exchange-API/
├── exchanges/
│   ├── exchange.py        ← ExchangeInterface, ExchangeWithExtras
│   ├── manager.py         ← ExchangeManager
│   ├── constants.py
│   ├── data_structures.py
│   ├── utils.py
│   └── [binance, kraken, bybit, coinbase, okx, ...].py   (connector từng sàn)
├── api/
│   ├── rest.py            ← Route REST, get_connected_exchanges_info, ...
│   ├── server.py
│   ├── services/
│   │   └── exchanges.py   ← ExchangesService (setup, edit, remove, query history)
│   └── v1/                ← resources, schemas
└── README.md
```

### API chính cần nhớ

| API | Chức năng |
|-----|-----------|
| `get_exchanges()` | Danh sách sàn đang kết nối |
| `setup_exchange(...)` | Thêm / cấu hình sàn (API key, secret, options) |
| `edit_exchange(...)` | Sửa cấu hình sàn |
| `remove_exchange(name, location)` | Xóa sàn |
| `query_exchange_history_events(...)` | Đồng bộ lịch sử giao dịch sàn |

---

## 📂 3. get-price-token

**Mục đích:** Lấy giá token/asset (hiện tại và lịch sử), qua oracles (Cryptocompare, Coingecko, Defillama, …) và logic đặc biệt (LP, vault).

| Thành phần | Mô tả |
|------------|--------|
| **inquirer.py** | Tra cứu giá hiện tại (find_price, find_prices_and_oracles) |
| **history/** | PriceHistorian, HistoricalPrice, types |
| **oracles/** | Cấu trúc oracles |
| **externalapis/** | Cryptocompare, Coingecko, Defillama, Alchemy |
| **chain/ethereum/oracles/** | Uniswap V2/V3 (giá lịch sử on-chain) |
| **api/** | REST: get_current_assets_price, get_historical_assets_price |

### Cấu trúc chi tiết

```
get-price-token/
├── inquirer.py            ← Inquirer.find_price, find_prices_and_oracles, get_underlying_asset_price
├── interfaces.py          ← CurrentPriceOracleInterface, HistoricalPriceOracleInterface
├── history/
│   ├── price.py           ← PriceHistorian (query_historical_price, query_multiple_prices)
│   ├── types.py           ← HistoricalPrice, HistoricalPriceOracle
│   └── ...
├── oracles/
│   └── structures.py
├── globaldb/
│   └── manual_price_oracles.py   ← ManualCurrentOracle
├── externalapis/
│   ├── cryptocompare.py
│   ├── coingecko.py
│   ├── defillama.py
│   └── alchemy.py
├── chain/ethereum/oracles/
│   ├── uniswap.py         ← UniswapV2Oracle, UniswapV3Oracle
│   └── constants.py
├── utils/mixins/
│   └── penalizable_oracle.py
├── api/
│   └── ...                ← get_current_assets_price, get_historical_assets_price
└── README.md
```

### API chính cần nhớ

| API | Chức năng |
|-----|-----------|
| `Inquirer.find_price(from_asset, to_asset)` | Giá hiện tại 1 asset → 1 asset đích |
| `Inquirer.find_prices_and_oracles(...)` | Giá nhiều asset + oracle dùng |
| `PriceHistorian().query_historical_price(...)` | Giá tại một timestamp |
| `PriceHistorian().query_multiple_prices(...)` | Giá nhiều asset tại một thời điểm |
| `get_underlying_asset_price(token)` | Giá token đặc biệt (LP, Curve, Yearn, …) |

---

## 📂 4. detect-protocol

**Mục đích:** Phát hiện protocol và decode giao dịch EVM (Uniswap, Curve, Aave, 1inch, …), tạo event/trade từ log.

| Thành phần | Mô tả |
|------------|--------|
| **chain_decoding/** | Base: TransactionDecoder, DecoderInterface, rules |
| **evm_decoding/** | EVM decoder + toàn bộ protocol decoders |
| **api/services/** | TransactionsService (decode_given_transactions, decode_transactions) |

### Cấu trúc chi tiết

```
detect-protocol/
├── chain_decoding/
│   ├── decoder.py         ← TransactionDecoder (base)
│   ├── interfaces.py      ← DecoderInterface
│   ├── types.py           ← CounterpartyDetails, DecodingRulesBase
│   ├── tools.py           ← BaseDecoderTools
│   ├── structures.py
│   └── constants.py
├── evm_decoding/
│   ├── decoder.py         ← EVMTransactionDecoder
│   ├── interfaces.py     ← EvmDecoderInterface
│   ├── base.py            ← BaseEvmDecoderTools
│   ├── structures.py
│   ├── constants.py
│   └── [uniswap/, curve/, aave/, oneinch/, paraswap/, balancer/, ...]  (từng protocol)
├── api/services/
│   └── transactions.py   ← decode_given_transactions, decode_transactions
└── README.md
```

### API chính cần nhớ

| API | Chức năng |
|-----|-----------|
| `decode_given_transactions(chain, tx_refs, ...)` | Decode danh sách tx theo chain |
| `decode_transactions(chain, force_redecode)` | Decode lại toàn bộ tx đã có theo chain |
| `addresses_to_decoders()` | Ánh xạ contract → hàm decode (trong từng decoder) |
| `counterparties()` | Tên protocol (uniswap-v2, curve, aave, …) |

---

## 🔗 Quan hệ giữa các module

```
                    ┌─────────────────────┐
                    │   REST API / App    │
                    └──────────┬──────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ track-wallets   │  │ integrate-      │  │ get-price-token │
│ (aggregator,    │  │ exchange-API    │  │ (Inquirer,      │
│  accounts,      │  │ (exchanges,     │  │  PriceHistorian,│
│  addressbook)   │  │  manager, API)  │  │  oracles, API)  │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  detect-protocol    │
                    │  (decoders, decode  │
                    │   transactions)     │
                    └─────────────────────┘
```

- **track-wallets:** Quản lý “track cái gì, ở chain nào”.
- **integrate-exchange-API:** Kết nối sàn, balance & history.
- **get-price-token:** Giá hiện tại & lịch sử cho token/asset.
- **detect-protocol:** Hiểu giao dịch thuộc protocol nào (Uniswap, Curve, …).

---

## 📦 Cài đặt thư viện (chung cho cả repo)

| File | Mô tả |
|------|--------|
| **requirements.txt** | Danh sách package Python (gevent, web3, flask, …). |
| **install_dependencies.sh** | Script: tạo `.venv` (nếu chưa có), `pip install -r requirements.txt`. |

```bash
# Cài thư viện (một lần)
./install_dependencies.sh
```

**Push từng phần (tránh push một lần quá nặng):**

```bash
# Commit + push lần lượt: root → track-wallets → integrate-exchange-API → get-price-token → detect-protocol
./push_in_stages.sh

# Hoặc chỉ định remote/branch: ./push_in_stages.sh origin main
```

Chi tiết thêm xem **README.md** ở root.

---

## 📋 Bảng tra cứu nhanh

| Bạn muốn… | Xem folder | File/API then chốt |
|-----------|------------|---------------------|
| Track ví nhiều chain | track-wallets | `chain/aggregator.py` → `add_accounts_to_all_evm`, `track_evm_address` |
| Kết nối sàn, balance, history | integrate-exchange-API | `exchanges/manager.py`, `api/services/exchanges.py` |
| Lấy giá token (hiện tại / lịch sử) | get-price-token | `inquirer.py`, `history/price.py`, oracles trong `externalapis/` |
| Decode giao dịch theo protocol | detect-protocol | `evm_decoding/decoder.py`, `evm_decoding/<protocol>/`, `api/services/transactions.py` |

---

*Cập nhật lần cuối: theo cấu trúc hiện tại của repo.*
