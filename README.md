# APB Protocol

Implementation of the AMBA Advanced Peripheral Bus (APB) protocol using SystemVerilog.

## Running the Program

1. **Run Simulation**

The `Makefile` is set up to compile the project files and run simulation without a GUI as the default command.

Option using `make`:
```sh
make
```
Using the provided `Makefile`, should compile all necessary files and run the default testbench.

Option using `vsim` directly, if files are already compiled:
```sh
vsim -do sim/run_questa.tcl
```

2. **View Waveform in QuestaSim**

**Note:** This requires enabling X forwarding if using SSH, or otherwise using a session with GUI support.

Open QuestaSim GUI:
```sh
vsim work.apb_tb
```

Type `do sim/wave.do` followed by `run -all` in the QuestaSim command window.

3. **Clean Up**
```sh
make clean
```

## Development

See [CONTRIBUTING.md](docs/CONTRIBUTING.md)
