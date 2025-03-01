# Testing

## Case Analysis

### Read transfer

1. **Valid transaction**

    Within first clock cycle (**setup phase**):
    1. Assert `PSEL` signal
    1. Ensure `PWRITE` signal is low
    1. Set a valid address on `PADDR`
    1. Ensure `PENABLE` signal is low
    1. Ensure `PSLVERR` is not asserted

    In the next clock cycle (**access phase**):
    1. Maintain `PSELF`, `PWRITE`, and `PADDR`
    1. Assert `PENABLE` signal
    1. Wait until `PREADY` is asserted by the peripheral
      a. Number of cycles in wait state should not exceed number of cycles `PREADY` is deasserted
    1. Check that `PSLVERR` is still not asserted
    1. Read data on `PRDATA`
    1. Deassert `PSEL` and `PENABLE`

1. **Invalid transactions**

    These cases represent a modification of the above general transaction procedure.

    1. `PSEL` signal deasserted before completion of transaction  
      a. Transaction should be aborted  
      b. Reset to pre-transaction state
    2. `PSLVERR` is asserted before completion of transaction  
      a. Transaction should be aborted
      b. Reset to pre-transaction state
    3. Invalid `PADDR`  
      a. From the specification document: "`PADDR` indicates a byte address. `PADDR` is permitted to be unaligned with respect to the data width, but the result is UNPREDICTABLE. For example, a Completer might use the unaligned address, aligned address, or signal an error response"  
      b. TODO: We should decide what action our completer will take. Maybe the simplest would be for `PSLVERR` to be asserted, and reset to pre-transaction state

1. **Consecutive or concurrent transactions**

    1. Consecutive reads
    1. Read then write
    1. Write then read
    1. Consecutive reads
    1. Consecutive reads to different devices  
      a. We may or may not extend our test suite to cover multiple devices, but if we do, this test would entail changing which `PSEL` is asserted
    1. Concurrent read and write  
      a. Drive `PWDATA` while ensuring `PWRITE` signal is low  
      b. Should result in a successful read
