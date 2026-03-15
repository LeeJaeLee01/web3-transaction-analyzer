# web3-transaction-analyzer

Các module phân tích giao dịch / portfolio (track wallet, exchange API, giá token, detect protocol).

## Modules

| Thư mục | Mô tả |
|---------|--------|
| [track-wallets/](track-wallets/) | Track wallet nhiều chain (EVM, BTC, Solana, …): aggregator, accounts, addressbook multichain. |
| [integrate-exchange-API/](integrate-exchange-API/) | Tích hợp sàn: interface exchange, manager, connector các sàn + REST API. |
| [get-price-token/](get-price-token/) | Lấy giá token: Inquirer, PriceHistorian, oracles (Cryptocompare, Coingecko, Defillama, …). |
| [detect-protocol/](detect-protocol/) | Detect protocol / decode giao dịch: EVM decoder, protocol decoders (Uniswap, Curve, Aave, …). |

## Cài đặt thư viện (cho cả source)

Dùng một trong hai cách:

```bash
# Cách 1: chạy script (tạo .venv nếu chưa có, rồi pip install)
chmod +x install_dependencies.sh
./install_dependencies.sh

# Cách 2: tự tạo venv và cài
python3.11 -m venv .venv
source .venv/bin/activate   # Linux/macOS
pip install -r requirements.txt
```

File **requirements.txt** liệt kê các thư viện cần cho toàn bộ module (gevent, web3, flask, marshmallow, …). Các dependency tùy chọn (substrate, solana, sqlcipher) có thể bỏ comment trong `requirements.txt` nếu dùng.

**Đẩy code từng phần (push nhẹ, tránh lỗi/timeout):**

```bash
./push_in_stages.sh
# Hoặc: ./push_in_stages.sh origin main
```

Script sẽ commit và push lần lượt: (1) root files, (2) track-wallets, (3) integrate-exchange-API, (4) get-price-token, (5) detect-protocol.

---

Lưu ý: code trong từng module vẫn import từ package gốc (types, db, …). Để chạy độc lập từng module cần chỉnh import hoặc chạy trong môi trường phù hợp.