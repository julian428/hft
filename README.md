# Projekt hft

[FPGA](https://pl.aliexpress.com/item/1005012006635603.html?spm=a2g0o.cart.0.0.6f8e452chi04Dj&mp=1&pdp_npi=6%40dis%21PLN%21PLN+772.39%21PLN+772.39%21%21PLN+768.45%21%21%21%402103909217906651008194311e0d68%2112000057260611899%21ct%21PL%212794939618%21%211%210%21&gatewayAdapt=glo2pol)

## Co robimy:
1. Dekodowanie informacji z giełdy na FPGA (fast path)
2. Decyzja co do danych z giełdy (fast path)
3. Utrzymywanie sesji z serwerem giełdy przez soft core risc-v (slow path)
4. Wysyłanie decyzji do giełdy przez soft core (slow path)
5. Odczytywanie i parsowanie historycznych danych giełdy (serwer giełdy)
6. komunikacja z soft core-em (serwer giełdy)
7. zapisywanie decyzji zamówionych przez soft core (serwer giełdy)
