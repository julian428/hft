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

hft/
├── .gitignore                   # Ignoruje vivado_work/, obj_dir/ i pliki tymczasowe
├── .gitattributes               # Wymusza końce linii LF na Windowsie i Linuksie
├── shell.nix                    # Środowisko dla NixOS (Verilator, GCC, GTKWave, openFPGALoader)
├── Makefile                     # Szybkie komendy dla Verilatora i Vivado (Linux/NixOS)
│
├── hw/                          # KOD SPRZĘTOWY (SystemVerilog)
│   ├── rtl/
│   │   ├── core/                # CZYSTY, PRZENOŚNY RTL (Działa w Vivado ORAZ w Verilatorze!)
│   │   │   ├── async_byte_fifo.sv
│   │   │   ├── itch_fast_decoder.sv
│   │   │   └── order_book.sv
│   │   └── xilinx/              # WARSTWA FIZYCZNA TYLKO DLA VIVADO (IDDR, PLL, BUFG, Piny)
│   │       ├── rgmii_rx_phy.sv
│   │       └── top_artix7.sv    # Główny moduł łączący piny płytki BX72 z logiką z core/
│   ├── tb/                      # Testbenche SystemVerilog (dla symulatora Vivado XSim)
│   │   └── tb_eth_led_control.sv
│   └── constraints/             # Pliki przypisania pinów (.xdc)
│       └── qmtech_bx72.xdc
│
├── sim/                         # SYMULACJA VERILATOR + MODEL REFERENCYJNY C++
│   ├── sim_main.cpp             # Główny plik C++ spinający Verilatora z testami
│   └── ref_model/               # Referencyjna książka zleceń w C++ (Poziom 2 weryfikacji)
│
├── sw/                          # FIRMWARE RISC-V (Slow Path - Etap III)
├── exchange_server/             # SYMULATOR GIEŁDY NA DELL WYSE (Odtwarzacz PCAP + OUCH)
├── bitstreams/                  # Gotowe, skompresowane pliki .bit do pobrania na Dell Wyse
│
└── scripts/                     # SKRYPTY AUTOMATYZUJĄCE (Windows + Linux)
    ├── create_project.tcl       # Tworzy lokalny projekt Vivado GUI w folderze vivado_work/
    ├── build_bitstream.tcl      # Bezokienkowa kompilacja pliku .bit prosto do bitstreams/
    ├── win_create_gui.bat       # Dwuklik na Windowsie -> tworzy i otwiera projekt w Vivado
    ├── win_build_bit.bat        # Dwuklik na Windowsie -> kompiluje .bit bez otwierania GUI
    └── flash_wyse.sh            # Skrypt na serwerze Dell Wyse: git pull + openFPGALoader
