# Hybrydowy system HFT (Tick-to-Trade) na układzie [FPGA](https://pl.aliexpress.com/item/1005012006635603.html?spm=a2g0o.cart.0.0.6f8e452chi04Dj&mp=1&pdp_npi=6%40dis%21PLN%21PLN+772.39%21PLN+772.39%21%21PLN+768.45%21%21%21%402103909217906651008194311e0d68%2112000057260611899%21ct%21PL%212794939618%21%211%210%21&gatewayAdapt=glo2pol) Artix-7

Projekt zespołowy realizujący sprzętowo-programowy system handlu algorytmicznego o ultraniskich opóźnieniach (*Fast Path / Slow Path*) na układzie **Xilinx Artix-7 (XC7A100T)** z interfejsem Gigabit Ethernet (1GbE).

### Członkowie Zespołu:
- Julian Metzger
- Michał Muszyński
- Jan Szulc

---

## 1. Architektura Systemu

System dzieli się na dwie współpracujące domeny wewnątrz układu FPGA:

* **Fast Path (Ścieżka Krytyczna – SystemVerilog / RTL):**
  * **Odbiornik Cut-Through Ethernet/IP/UDP:** Dekoduje ramki sieciowe w locie bez buforowania całych pakietów (*store-and-forward*).
  * **Dekoder NASDAQ ITCH 5.0:** Rozpoznaje komunikaty rynkowe i filtruje wybrany instrument finansowy.
  * **Dwustopniowa Książka Zleceń (Order Book):** Tablica haszująca (*Order ID Map*) w pamięci wewnętrznej **BRAM** mapująca `Order_ID` na cenę, wolumen i stronę zlecenia oraz tabela **10 najlepszych poziomów cenowych (Bid/Ask)** na rejestrach przesuwnych.
  * **Silnik Decyzyjny i Generator Segmentów TCP (OUCH):** Po wykryciu okazji rynkowej uzupełnia w locie przygotowany szablon nagłówka TCP o parametry zlecenia w uproszczonym protokole **NASDAQ OUCH** oraz numer sekwencyjny, aktualizuje sumę kontrolną i wysyła ramkę na port TX.
* **Slow Path (Koprocesor RISC-V – Firmware w C):**
  * Odpowiada za nawiązanie połączenia TCP (*3-way handshake*), utrzymanie sesji, kontrolę przepływu, obsługę retransmisji oraz przygotowanie w rejestrach FPGA szablonu nagłówka TCP wraz z częściową sumą kontrolną (*Partial Checksum*).
  * Zarządza parametrami ryzyka, konfiguracją progów decyzyjnych oraz telemetrią.

### Etapy realizacji projektu
* **Etap I:** Ethernet, UDP, dekoder ITCH, książka zleceń (odtwarzanie stanu rynku dla wybranego instrumentu).
* **Etap II:** Logika decyzyjna, generator zleceń OUCH/TCP, pomiar opóźnień *data-to-decision* oraz *wire-to-wire* (kompletny tor *Tick-to-Trade*).
* **Etap III:** Integracja rdzenia RISC-V, konfiguracja, telemetria, kontrola ryzyka (zintegrowany system hybrydowy) oraz opcjonalne rozszerzenie instrukcji ALU (ASIP).

---

## 2. Struktura Projektu

Repozytorium zostało zaprojektowane tak, aby działać wieloplatformowo (Windows oraz Linux) bez konfliktów ścieżek w plikach projektu Vivado:

```text
hft/
├── hw/                          # CZĘŚĆ SPRZĘTOWA (SystemVerilog / Vivado)
│   ├── rtl/                     # Syntezowalny kod sprzętowy RTL (.sv) - Fast Path oraz rdzeń RISC-V
│   ├── tb/                      # Testbenche symulacyjne (.sv) dla symulatora Vivado XSim
│   └── constraints/             # Pliki przypisania pinów i ograniczeń czasowych (.xdc) dla płytki BX72
│
├── ref_model/                   # MODEL REFERENCYJNY (C++)
│                                # Weryfikacja Poziomu 2: wzorcowa książka zleceń i logika decyzyjna
│                                # do porównywania stanów pośrednich i decyzji końcowych z układem FPGA
│
├── exchange_server/             # SYMULATOR SERWERA GIEŁDY (C++)
│                                # Odtwarzanie plików .pcap z kontrolą tempa oraz odbiór zleceń OUCH
│
├── sw/                          # OPROGRAMOWANIE UKŁADOWE RISC-V (C / Asembler)
│                                # Firmware dla Slow Path (obsługa sesji TCP, ryzyka i telemetrii)
│
├── bitstreams/                  # GOTOWE PLIKI KONFIGURACYJNE FPGA (.bit)
│                                # Skompresowane pliki .bit gotowe do wgrania na płytkę Artix-7
│
├── scripts/                     # SKRYPTY AUTOMATYZUJĄCE (Tcl / Batch)
│   ├── create_project.tcl       # Generuje lokalny projekt Vivado w folderze ./vivado_work/
│   ├── build_bitstream.tcl      # Kompiluje projekt bez otwierania GUI prosto do ./bitstreams/
│   ├── win_create_gui.bat       # Skrypt dla Windows: tworzy i uruchamia projekt w Vivado GUI
│   └── win_build_bit.bat        # Skrypt dla Windows: kompiluje plik .bit w trybie bezokienkowym
│
├── vivado_work/                 # LOKALNY FOLDER ROBOCZY VIVADO (Ignorowany przez Git!)
│                                # Tu powstaje plik .xpr oraz pliki tymczasowe kompilacji i symulacji
│
├── docs/                        # Dokumentacja
│
├── flake.nix                    # Deklaracja środowiska
└── Makefile                     # Zestaw komend automatyzujących dla systemu Linux
```

_Ważna zasada_: Katalog `vivado_work/` oraz pliki `.xpr` są celowo ignorowane przez .gitignore. Nigdy nie dodawaj ich do repozytorium. Projekt Vivado jest generowany lokalnie na każdym komputerze za pomocą skryptu `scripts/create_project.tcl`.

## 3. Setup Projektu

Do pracy z częścią sprzętową wymagany jest pakiet Xilinx Vivado ML Standard (darmowa edycja w pełni obsługuje docelowy układ Artix-7 XC7A100T)

### A. Konfiguracja na systemie Windows
1. Sklonuj repozytorium

```bash
git clone https://github.com/julian428/hft.git
cd hft
```
2. Sprawdź ścieżkę do Vivado w skryptach `.bat`:
Otwórz pliki `scripts\win_create_gui.bat` oraz `scripts\win_build_bit.bat` i upewnij się, że ścieżka wskazuje na Twoją wersję i lokalizację instalacji Vivado (domyślnie `C:\AMDDesignTools\2026.1\Vivado\settings64.bat`).

3. Wygeneruj i otwórz projekt w Vivado GUI:
Uruchom plik `scripts\win_create_gui.bat`. Skrypt automatycznie utworzy folder `vivado_work\`, zaimportuje wszystkie pliki z `hw/rtl/`, `hw/tb/` oraz `hw/constraints/` i otworzy gotowe okno programu Vivado.

### B. Konfiguracja na systemie Linux

1. Sklonuj repozytorium:
```Bash
git clone https://github.com/julian428/hft.git
cd hft
```

2. Uruchom środowisko z narzędziami:
```Bash
nix develop
```

3. Wygeneruj i otwórz projekt w Vivado GUI:
```Bash
make vivado-gui
```

## 4. Jak korzystać z projektu

### 1. Otwieranie projektu

- Pierwsze uruchomienie (lub po pobraniu nowych plików przez git pull): Uruchom `scripts\win_create_gui.bat` (Windows) lub `make vivado-gui` (Linux). Skrypt na czysto odtworzy projekt `vivado_work/hft_fpga.xpr` ze wszystkimi aktualnymi plikami z repozytorium.

- Kolejne uruchomienia: Możesz otwierać utworzony wcześniej plik `vivado_work/hft_fpga.xpr` bezpośrednio w programie Vivado.

### 2. Edycja i dodawanie nowych plików sprzętowych (.sv, .xdc)

Wszystkie pliki źródłowe muszą fizycznie znajdować się w katalogach `hw/rtl/`, `hw/tb/` lub `hw/constraints/`, aby były widoczne dla Gita:

- Sposób zalecany: Utwórz nowy plik `.sv` bezpośrednio w folderze `hw/rtl/` (lub testbench w `hw/tb/`), a następnie odśwież projekt skryptem `create_project.tcl` lub dodaj plik w Vivado przez Add Sources → Add Files.

- Uwaga przy korzystaniu z kreatora w Vivado: Podczas dodawania plików w oknie Add Sources zawsze odznaczaj opcję „Copy sources into project”. Gdyby była zaznaczona, Vivado skopiowałoby plik do ignorowanego folderu `vivado_work/` i zmiany nie zapisałyby się w repozytorium Git.

### 3. Uruchamianie symulacji

    1. W panelu Sources rozwiń sekcję Simulation Sources → sim_1.

    2. Kliknij prawym przyciskiem myszy na testbench, który chcesz przetestować i wybierz Set as Top.

    3. W menu po lewej stronie kliknij Run Simulation → Run Behavioral Simulation.

### 4. Generowanie Bitstreamu

Masz do wyboru dwie metody:

- Bez otwierania interfejsu graficznego:

    - Windows: uruchom scripts\win_build_bit.bat.

    - Linux: Wpisz w terminalu `make bitstream`.
        Skrypt automatycznie przeprowadzi syntezę oraz implementację i zapisze gotowy, skompresowany plik w bitstreams/hft_top.bit.

- Z poziomu GUI Vivado:
    Kliknij Generate Bitstream w lewym dolnym rogu programu, a po zakończeniu skopiuj wygenerowany plik `.bit` z `vivado_work/hft_fpga.runs/impl_1/` do katalogu `bitstreams/`.

### 5. Wgrywanie układu na płytkę FPGA (Serwer laboratoryjny)

Płytka z układem Artix-7 XC7A100T jest podłączona przez USB-JTAG oraz Gigabit Ethernet do serwera laboratoryjnego:
Połącz się przez SSH z serwerem, pobierz zmiany i zaprogramuj układ FPGA:

```Bash

cd ~/hft
git pull
make flash
```

(Polecenie make flash wywołuje openFPGALoader -c digilent_hs3 bitstreams/hft_top.bit i wgrywa konfigurację bezpośrednio do pamięci SRAM układu FPGA).
