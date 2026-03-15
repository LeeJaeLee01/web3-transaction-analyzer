# Get Price Token

Thư mục này chứa các folder và file liên quan đến **lấy giá token/asset**: giá hiện tại (current price), giá lịch sử (historical price), oracles và API phục vụ price.

## Cấu trúc

```
get-price-token/
├── inquirer.py          # Tra cứu giá hiện tại (find_price, find_prices_and_oracles)
├── interfaces.py        # Interface oracles (Current, Historical)
├── history/             # PriceHistorian, HistoricalPrice, types
├── oracles/             # Cấu trúc oracles
├── globaldb/            # Manual current price oracle
├── externalapis/        # Cryptocompare, Coingecko, Defillama, Alchemy
├── chain/ethereum/oracles/  # Uniswap V2/V3 historical oracles
├── utils/mixins/        # penalizable_oracle
└── api/                 # REST API (get_current_assets_price, get_historical_assets_price)
```

## File / module chính

### 1. `inquirer.py` – Giá hiện tại

- **`Inquirer.find_price(from_asset, to_asset)`**: Lấy giá hiện tại từ một asset sang asset đích.
- **`Inquirer.find_prices_and_oracles(from_assets, to_asset)`**: Lấy giá nhiều asset và oracle tương ứng.
- **`Inquirer._find_prices()`**: Logic chính: manual → fiat → special (LP, vault, curve, yearn, …) → oracles.
- **`get_underlying_asset_price(token)`**: Giá token đặc biệt (LP, Curve, Yearn, Balancer, Uniswap V3/V4, Pendle, …).

### 2. `history/price.py` – Giá lịch sử

- **`PriceHistorian`** (singleton): Query giá theo thời điểm.
  - `query_historical_price(from_asset, to_asset, timestamp)`
  - `query_multiple_prices(from_assets, to_asset, timestamp)`
- Dùng oracles: Cryptocompare, Coingecko, Defillama, Alchemy, UniswapV2, UniswapV3.
- **`query_price_or_use_default(asset, time, default_value, location)`**: Lấy giá hoặc dùng giá mặc định.

### 3. `history/types.py`

- **`HistoricalPriceOracle`**: Enum nguồn giá lịch sử (MANUAL, COINGECKO, CRYPTOCOMPARE, DEFILLAMA, UNISWAPV2, UNISWAPV3, ALCHEMY, …).
- **`HistoricalPrice`**: NamedTuple (from_asset, to_asset, source, timestamp, price).

### 4. `interfaces.py` – Interface oracles

- **`CurrentPriceOracleInterface`**: Oracle giá hiện tại.
  - `query_current_price(from_asset, to_asset)` → Price
  - `query_multiple_current_prices(from_assets, to_asset)` → dict
- **`HistoricalPriceOracleInterface`**: Oracle giá lịch sử.
  - `query_historical_price(from_asset, to_asset, timestamp)` → Price

### 5. `oracles/structures.py`

- Cấu trúc dữ liệu dùng chung cho oracles.

### 6. `globaldb/manual_price_oracles.py`

- **`ManualCurrentOracle`**: Giá hiện tại nhập tay; `query_current_price()` đọc từ GlobalDB và quy đổi sang to_asset.

### 7. `externalapis/` – Nguồn giá bên ngoài

| File | Mô tả |
|------|--------|
| `cryptocompare.py` | Cryptocompare – current & historical |
| `coingecko.py` | CoinGecko – current & historical |
| `defillama.py` | DeFiLlama – current & historical |
| `alchemy.py` | Alchemy – current & historical (token price API) |
| `interface.py` | Base cho external service / oracle |
| `utils.py` | Tiện ích chung |

### 8. `chain/ethereum/oracles/`

- **UniswapV2Oracle**, **UniswapV3Oracle**: Giá lịch sử từ pool Uniswap (on-chain).
- `constants.py`: Hằng số dùng cho oracles.

### 9. `utils/mixins/penalizable_oracle.py`

- **PenalizablePriceOracleMixin**: Xử lý rate limit / penalty cho oracle (tránh gọi quá tải).

### 10. `api/` – REST API giá

- **`api/rest.py`**:
  - `get_current_assets_price(assets, target_asset, ignore_cache)` → giá hiện tại nhiều asset.
  - `get_historical_assets_price(assets, target_asset, timestamp)` → giá lịch sử.
  - `get_historical_prices_per_asset` (theo asset / khoảng thời gian).
- **`api/services/assets.py`**:
  - `get_current_assets_price()`: Gọi `Inquirer.find_prices_and_oracles()`.
  - `get_historical_assets_price()`: Gọi `PriceHistorian.query_multiple_prices()` hoặc GlobalDB.
- **`api/v1/resources.py`**: Resource cho endpoint current/historical assets price.

## Cách dùng

- **Giá hiện tại**: Gọi `Inquirer.find_price(asset, target_asset)` hoặc API `get_current_assets_price`.
- **Giá lịch sử**: Gọi `PriceHistorian().query_historical_price(asset, target_asset, timestamp)` hoặc API `get_historical_assets_price`.
- **Token đặc biệt (LP, vault, …)**: `get_underlying_asset_price(token)` trong `inquirer.py` xử lý theo protocol (Curve, Yearn, Uniswap, Balancer, …).

## Thêm oracle giá mới

- **Current**: Implement `CurrentPriceOracleInterface`, thêm instance vào Inquirer và gọi trong `_query_oracle_instances` / danh sách oracles.
- **Historical**: Implement `HistoricalPriceOracleInterface`, thêm vào `HistoricalPriceOracle` enum và vào PriceHistorian.

## Lưu ý

- Code phụ thuộc vào types, assets, db (GlobalDB, settings), constants. Để chạy độc lập cần điều chỉnh import hoặc copy thêm các module tương ứng.
