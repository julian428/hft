Architektura systemu i główne założenia

Projekt zostanie zrealizowany z wykorzystaniem układu FPGA Xilinx Artix-7 XC7A100T. System będzie odbierał odtwarzany strumień danych giełdowych w formacie NASDAQ ITCH bezpośrednio przez interfejs Gigabit Ethernet, z pominięciem stosu sieciowego systemu operacyjnego. Ze względu na dostępny sprzęt i ograniczenia budżetowe zastosowany zostanie interfejs 1GbE. Modułowa architektura systemu ma umożliwić jego późniejsze dostosowanie do interfejsu 10GbE przy ograniczonym zakresie zmian.

W układzie FPGA zostaną wydzielone dwie części funkcjonalne:

A. Ścieżka krytyczna — logika sprzętowa opisana w SystemVerilogu

Ścieżka krytyczna będzie realizować potokowe przetwarzanie strumienia danych w locie, bez oczekiwania na odebranie całego pakietu i z ograniczeniem buforowania do niezbędnego minimum. Jej zadaniem będzie minimalizacja opóźnienia pomiędzy odbiorem danych rynkowych a wysłaniem zlecenia. Obejmie ona:

- odbiór i sprzętowe dekodowanie datagramów UDP;
- analizę komunikatów giełdowych oraz aktualizację książki zleceń przechowywanej w FPGA;
- ocenę reguł decyzyjnych i generowanie komunikatu zlecenia rynkowego, przesyłanego w segmencie TCP w ramach wcześniej zestawionej sesji.

B. Koprocesor RISC-V — część analityczna i sterująca

Funkcje analityczne i sterujące zostaną zaimplementowane w języku C i będą wykonywane przez 32-bitowy rdzeń RISC-V. Rdzeń będzie odpowiadał za nawiązywanie sesji komunikacyjnych, kontrolę ryzyka oraz telemetrię.

Przewiduje się dostosowanie procesora do specyfiki aplikacji zgodnie z koncepcją ASIP (*Application-Specific Instruction-set Processor*). W tym celu planowane jest rozszerzenie jednostki arytmetyczno-logicznej o obsługę własnych instrukcji przyspieszających wybrane obliczenia finansowe.

Metodyka weryfikacji

Etap symulacyjny

Przed uruchomieniem systemu na układzie FPGA zostanie opracowany referencyjny model algorytmu w języku C++. Wyniki symulacji logiki sprzętowej, w szczególności generowane decyzje transakcyjne, będą porównywane z wynikami modelu referencyjnego. Pozwoli to zweryfikować poprawność implementacji dla przygotowanego zestawu przypadków testowych.

Etap sprzętowy

Podczas końcowych testów układ FPGA zostanie połączony bezpośrednio z komputerem PC. Przygotowana aplikacja w języku C++ będzie pełnić funkcję symulatora giełdy: odtwarzać ruch sieciowy zapisany w plikach `.pcap`, odbierać odpowiedzi układu FPGA i weryfikować ich poprawność.

Kryteria sukcesu

Przyjęto następujące wstępne, mierzalne kryteria sukcesu:

-Zgodność logiczna- pełna zgodność decyzji transakcyjnych generowanych przez FPGA z wynikami modelu referencyjnego w C++ dla przyjętego zestawu danych historycznych.
-Opóźnienie wire-to-wire- uzyskanie opóźnienia poniżej 2 µs, mierzonego od odbioru pierwszego bitu pakietu zawierającego dane rynkowe do wysłania pierwszego bitu odpowiadającego mu komunikatu zlecenia.
-Integracja rdzenia RISC-V z logiką sprzętową- możliwość aktualizacji rejestrów konfiguracyjnych przez procesor podczas działania systemu, bez zakłócania pracy ścieżki krytycznej.
