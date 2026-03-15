# Integrate Exchange API

Thư mục này chứa các folder và file liên quan đến **tích hợp Exchange API**: interface sàn, manager, các connector sàn và lớp API REST/WebSocket phục vụ exchange.

## Cấu trúc

```
integrate-exchange-API/
├── exchanges/       # Interface, manager, và các exchange connector
├── api/             # REST API, services, schemas (expose exchange qua API)
└── README.md
```

## File / module chính

### 1. `exchanges/exchange.py` – Interface sàn

- **`ExchangeInterface`**: Interface chung cho mọi sàn. Subclass cần implement:
  - `query_balances()` – balance trên sàn
  - `validate_api_key()` – kiểm tra API key
  - `first_connection()` – lần kết nối đầu
  - `query_online_history_events(start_ts, end_ts)` – lịch sử trade/deposit/withdraw
- **`ExchangeWithExtras`**: Sàn có thêm cấu hình (vd. Kraken account type), `edit_exchange_extras()`.
- **`ExchangeWithoutApiSecret`**: Base cho sàn không bắt buộc secret (vd. chỉ API key).

### 2. `exchanges/manager.py` – Quản lý sàn

- **`ExchangeManager`**: Quản lý danh sách sàn đã kết nối.
  - `connected_exchanges`: dict Location → list ExchangeInterface
  - `get_exchange(name, location)`, `iterate_exchanges()`
  - `edit_exchange()`, `delete_exchange()`
  - `query_exchange_history_events()`, `requery_exchange_history_events()`
  - `get_connected_exchanges_info()`

### 3. `exchanges/` – Các connector sàn

| File | Sàn |
|------|-----|
| `binance.py` | Binance (và Binance US qua Location) |
| `bitfinex.py` | Bitfinex |
| `bitmex.py` | BitMEX |
| `bitstamp.py` | Bitstamp |
| `bybit.py` | Bybit |
| `coinbase.py` | Coinbase |
| `coinbaseprime.py` | Coinbase Prime |
| `cryptocom.py` | Crypto.com |
| `gemini.py` | Gemini |
| `htx.py` | HTX (Huobi) |
| `independentreserve.py` | Independent Reserve |
| `kraken.py` | Kraken |
| `kucoin.py` | KuCoin |
| `okx.py` | OKX |
| `poloniex.py` | Poloniex |
| `woo.py` | Woo |
| `bitpanda.py` | Bitpanda |
| `bitcoinde.py` | Bitcoin.de |
| `iconomi.py` | Iconomi |

Cùng với: `constants.py`, `data_structures.py`, `utils.py`.

### 4. `api/services/exchanges.py` – Service API cho sàn

- **`ExchangesService`**:
  - `get_exchanges()` – danh sách sàn đang kết nối
  - `setup_exchange()` – thêm / cấu hình sàn (API key, secret, options từng sàn)
  - `edit_exchange()` – sửa cấu hình sàn
  - `remove_exchange()` – xóa sàn
  - `query_exchange_history_events()` – gọi sync lịch sử sàn
  - `requery_exchange_history_events()` – sync lại lịch sử

### 5. `api/` – REST và WebSocket

- **`rest.py`**: Định nghĩa route REST, dùng `exchange_manager` cho endpoints sàn (connected exchanges, setup, edit, delete, history).
- **`v1/resources.py`**, **`v1/schemas.py`**: Resource và schema cho API v1 (exchanges, balances, history).
- **`server.py`**: Khởi tạo server API.
- **`websockets/`**: Typedefs và notifier cho WebSocket (có thể dùng để push trạng thái sàn).

## Cách dùng

- **Backend**: Khởi tạo `ExchangeManager`, thêm/sửa/xóa sàn qua `setup_exchange` / `edit_exchange` / `delete_exchange`. Gọi `query_exchange_history_events` để đồng bộ lịch sử.
- **API**: Các endpoint trong `rest.py` và service trong `api/services/exchanges.py` expose thao tác sàn ra REST; frontend hoặc client gọi các endpoint này để quản lý và đồng bộ sàn.

## Thêm sàn mới

- Tạo file mới trong `exchanges/` (vd. `newsite.py`).
- Kế thừa `ExchangeInterface` (hoặc `ExchangeWithoutApiSecret` nếu phù hợp), implement `query_balances`, `validate_api_key`, `first_connection`, `query_online_history_events`.
- Thêm sàn vào `exchanges/constants.py` (SUPPORTED_EXCHANGES, Location nếu cần).
- Trong `manager.py` đảm bảo module được load (theo pattern import theo Location hiện có).

## Lưu ý

- Code phụ thuộc vào types, db, accounting, history events, assets. Để chạy độc lập cần điều chỉnh import hoặc copy thêm các module tương ứng.
