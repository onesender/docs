# Patch tripay

Ubah plugin tripay dengan edit file tripay-payment-gateway/woocommerce-gateway-tripay.php

Cari kode di sekitar baris ke 310
```php
$order->save();
```
Tambahkan 1 baris kode di bawahnya
```php
$order->save();

// Tambahkan 1 baris kode ini
do_action( 'tripay/transaction_created', $order );
```

![Tripay patch ](https://i.postimg.cc/2jFhz54m/tripay.png)

Meta data:
---|---
Jumlah tagihan | {{order_metadata._tripay_payment_amount}}
Kode reference | {{order_metadata._tripay_payment_reference}}
Link pembayaran | {{order_metadata._tripay_payment_pay_url}}
Kode pembayaran | {{order_metadata._tripay_payment_pay_code}}
Expired time | {{order_metadata._tripay_payment_expired_time}}
Expired date | {{order_metadata._tripay_payment_expired_date}}
Merchant | {{order_metadata._tripay_payment_type}}
