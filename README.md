# APB Protocol

Implementation of the AMBA Advanced Peripheral Bus (APB) protocol using SystemVerilog.

## Running the Program

**TODO: Is this the preferred workflow?**
**TODO: Run verible-verilog-lint and verible-verilog-format on the included files**

1. **Run Simulation**

Option using `make`:
```sh
make
```
Using the provided `Makefile`, should compile all necessary files and run the default testbench.

Option using `vsim` directly:
```sh
vsim -do sim/run_questa.tcl
```

2. **View Waveform in QuestaSim**

Open QuestaSim GUI:
```sh
vsim work.apb_tb
```

Type `do wave.do` in the command window.

3. **Clean Up**
```sh
make clean
```

## Development

See [CONTRIBUTING.md](docs/CONTRIBUTING.md)
