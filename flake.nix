{
  description = "Środowisko projektowe HFT FPGA (Artix-7 XC7A100T)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Kompilacja modelu referencyjnego C++ i serwera giełdy (PCAP)
          gcc
          cmake
          gnumake
          libpcap

          # Narzędzia sieciowe i programator FPGA (dla serwera Dell Wyse)
          openfpgaloader
          tcpreplay
          wireshark-cli

          # Toolchain C dla koprocesora RISC-V (Etap III)
          pkgsCross.riscv32-embedded.buildPackages.gcc
        ];

        shellHook = ''
          echo "========================================================="
          echo "Środowisko HFT FPGA gotowe (C++ / PCAP / RISC-V / JTAG)"
          echo "========================================================="
        '';
      };
    };
}
