# Detect Protocol

Thư mục này chứa các folder và file liên quan đến **phát hiện protocol / decode giao dịch**: decoder base, EVM transaction decoder, và các decoder theo từng protocol (Uniswap, Curve, Aave, 1inch, …).

## Cấu trúc

```
detect-protocol/
├── chain_decoding/       # Base: TransactionDecoder, DecoderInterface, DecodingRules
├── evm_decoding/         # EVM decoder + toàn bộ protocol decoders (Uniswap, Curve, Aave, …)
├── api/services/         # TransactionsService (decode_given_transactions, decode_transactions)
└── README.md
```

## File / module chính

### 1. `chain_decoding/decoder.py` – Base decoder

- **`TransactionDecoder`**: Lớp trừu tượng decode giao dịch theo chain.
  - Khởi tạo với database, dbtx, rules, base_tools, misc_counterparties.
  - `_add_builtin_decoders()`, `_recursively_initialize_decoders()`: Load decoder theo module.
  - Decode logs/events và ghi kết quả vào DB.

### 2. `chain_decoding/interfaces.py` – Interface decoder

- **`DecoderInterface`**: Interface chung cho mọi decoder.
  - `addresses_to_decoders()`: Ánh xạ địa chỉ contract → hàm decode.
  - `counterparties()`: Danh sách counterparty (protocol) mà decoder tạo ra.

### 3. `chain_decoding/types.py`, `tools.py`, `structures.py`, `constants.py`

- Types (CounterpartyDetails, DecodingRulesBase), BaseDecoderTools, hằng số (CPT_GAS, …).

### 4. `evm_decoding/decoder.py` – EVM transaction decoder

- **`EVMTransactionDecoder`**: Decode giao dịch EVM (logs, 4bytes selector, internal tx).
  - `_decode_transaction(transaction, tx_receipt)` → danh sách EvmEvent.
  - Dùng rules (input_data_rules, decoding_rules) và addresses_to_decoders từ từng protocol.

### 5. `evm_decoding/interfaces.py` – EVM decoder interface

- **`EvmDecoderInterface`**: Interface decoder EVM.
  - `addresses_to_decoders()`, `decoding_rules()`, `enricher_rules()`.
  - `counterparties()`: Protocol tương ứng (uniswap-v2, curve, aave, …).

### 6. `evm_decoding/base.py` – Công cụ decode EVM

- **`BaseEvmDecoderTools`**: Tools dùng trong decoder (decode event, resolve asset, kiểm tra contract, …).

### 7. `evm_decoding/` – Các protocol decoder

Mỗi protocol có thư mục riêng (vd. `uniswap/v2/decoder.py`, `curve/decoder.py`) với:

- Decoder kế thừa `EvmDecoderInterface`.
- `addresses_to_decoders()`: contract address → handler.
- `decoding_rules()` / `enricher_rules()` (tùy protocol).
- `counterparties()`: tên protocol.

Ví dụ: aave, balancer, compound, cowswap, curve, hop, oneinch, paraswap, uniswap (v2, v3, v4), velodrome, yearn, woo_fi, …

### 8. `api/services/transactions.py` – API decode

- **`TransactionsService.decode_given_transactions(chain, tx_refs, delete_custom)`**: Decode danh sách tx theo chain (EVM / Evmlike / Solana).
- **`TransactionsService.decode_transactions(chain, force_redecode)`**: Decode lại toàn bộ tx đã có theo chain.
- **`refresh_transactions()`**: Đồng bộ và decode lại theo khoảng thời gian.

## Cách dùng

- **Decode một giao dịch**: Gọi service `decode_given_transactions(chain, [tx_hash], delete_custom=False)`.
- **Decode lại theo chain**: Gọi `decode_transactions(chain, force_redecode=True)`.
- **Thêm protocol mới**: Tạo decoder kế thừa `EvmDecoderInterface`, implement `addresses_to_decoders()` và `counterparties()`, đặt trong `evm_decoding/<protocol>/` và đảm bảo được load bởi `_recursively_initialize_decoders()`.

## Lưu ý

- Code phụ thuộc vào chain (ethereum, evm), history/events, db, types, assets. Để chạy độc lập cần điều chỉnh import hoặc copy thêm các module tương ứng.
- Thư mục đặt tên `chain_decoding` và `evm_decoding` để tránh trùng với cấu trúc `chain/` trong các module khác; khi tích hợp lại có thể map về `chain/decoding` và `chain/evm/decoding`.
