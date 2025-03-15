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
    1. Maintain `PSEL`, `PWRITE`, and `PADDR`
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
      b. Our completer will be designed to require alignment. For invalid addresses, `PSLVERR` will be asserted, and the perhipheral will be reset to pre-transaction state

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

### Write Transfer

1. **Setup Phase(First Clock Cycle)**

   1. The bridge asserts `PSEL` to indicate a valid transaction.
   1. The `PWRITE` signal is set **high** to indicate a write transfer.
   1. A valid address is placed on `PADDR`.
   1. `PWDATA` is set to the data to be written.
   1. `PENABLE` remains **low**.
   1. `PSLVERR` is not asserted.

2. **Access Phase (Second Clock Cycle)**

   1. The bridge maintains `PSEL`, `PWRITE`, and `PADDR` values.
   1. `PENABLE` is asserted **high**.
   1. The peripheral sets `PREADY` **high** once it is ready to accept data.
   1. If `PREADY` is **low**, the bridge remains in the access phase until `PREADY` is **high**.
   1. The data on `PWDATA` is written to the corresponding memory location.
   1. If an invalid address is detected, `PSLVERR` is asserted.

3. **Transfer Completion**

   1. The bridge deasserts `PSEL` and `PENABLE` after receiving acknowledgment (`PREADY` high).
   2. If `PSLVERR` is asserted, the bridge may trigger an error handling routine.

4. **Error Handling Cases** 

   1. **Invalid Address:** If `PADDR` is out of the valid range, `PSLVERR` is set **high**, and the transfer is not completed.
   2. **Write Failure:** If the peripheral does not acknowledge the write request, `PREADY` remains **low**, leading to a stalled transaction.

5. **Timing Considerations** 

   1. The number of wait states should not exceed the number of cycles PREADY is deasserted.
   2. The bridge must not change address or control signals during the access phase.
   3. Once `PREADY` is asserted, the write transfer must be completed within the same cycle.

6. **Edge Cases** 

   1. Repeated Write Requests: If the same address is written multiple times, the latest value should overwrite the previous one.
   2. Back-to-Back Transfers: If a new write request follows immediately, `PSEL` can be reasserted without deasserting it between cycles.
   3. Peripheral Delays: If a slow peripheral takes multiple cycles to assert `PREADY`, the bridge must wait appropriately.

### Protection unit support

Testing the `PPROT` signals will entail a shared memory map between the design under test and the testbench. The memory map will designate specific memory blocks as having certain characteristics. For example, a boot ROM section may be designated as secure. A system configuration section may be privileged access only. There may also be different sections designated as data versus instructions.

Our testing strategy will focus on checking each protection bit with read and write transactions. We will hold on testing combinations of protection bits for now. We will also assume prior tests cover the case of reading / writing to regions *not* designated as privileged or secure.

1. **Privileged access** (`PPROT[0]`)

    (1) Attempt *invalid read* to privileged region  
    1. Ensure `PPROT[0]` is low
    1. Attempt a typical read transaction to an address in a privileged region
    1. Confirm that `SLVERR` is asserted
    1. Confirm data on `PRDATA` is masked by setting it equal to `z`

    (2) Attempt *valid read* to privileged region  
    1. Ensure `PPROT[0]` is high
    1. Attempt a typical read transaction to an address in a privileged region
    1. Confirm that `SLVERR` is **not** asserted
    1. Confirm data on `PRDATA` is valid

    (3) Attempt *invalid write* to privileged region  
    1. Perform a *valid read* to an address in a privileged region and save retrieved value
    1. Ensure `PPROT[0]` is low
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is the same as the original retrieved value.

    (4) Attempt *valid write* to privileged region  
    1. Perform a *valid read* to an address in a privileged region and save retrieved value
    1. Ensure `PPROT[0]` is high
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is **not** asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is different from the original retrieved value.

2. **Secure access** (`PPROT[1]`)

    (1) Attempt *invalid read* to secure region  
    1. Ensure `PPROT[1]` is high (non-secure)
    1. Attempt a typical read transaction to an address in a secure region
    1. Confirm that `SLVERR` is asserted
    1. Confirm data on `PRDATA` is masked by setting it equal to `z`

    (2) Attempt *valid read* to secure region  
    1. Ensure `PPROT[1]` is low (secure)
    1. Attempt a typical read transaction to an address in a secure region
    1. Confirm that `SLVERR` is **not** asserted
    1. Confirm data on `PRDATA` is valid

    (3) Attempt *invalid write* to secure region  
    1. Perform a *valid read* to an address in a secure region and save retrieved value
    1. Ensure `PPROT[1]` is high (non-secure)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is the same as the original retrieved value.

    (4) Attempt *valid write* to secure region  
    1. Perform a *valid read* to an address in a secure region and save retrieved value
    1. Ensure `PPROT[1]` is low (secure)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is **not** asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is different from the original retrieved value.

3. **Data or Instruction access** (`PPROT[2]`)

    (1) Attempt *invalid read* to data region  
    1. Ensure `PPROT[2]` is high (instruction access)
    1. Attempt a typical read transaction to an address in a data region
    1. Confirm that `SLVERR` is asserted
    1. Confirm data on `PRDATA` is masked by setting it equal to `z`

    (2) Attempt *valid read* to data region  
    1. Ensure `PPROT[2]` is low (data access)
    1. Attempt a typical read transaction to an address in a data region
    1. Confirm that `SLVERR` is **not** asserted
    1. Confirm data on `PRDATA` is valid

    (3) Attempt *invalid write* to data region  
    1. Perform a *valid read* to an address in a data region and save retrieved value
    1. Ensure `PPROT[2]` is high (instruction region)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is the same as the original retrieved value.

    (4) Attempt *valid write* to data region  
    1. Perform a *valid read* to an address in a data region and save retrieved value
    1. Ensure `PPROT[2]` is low (data region)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is **not** asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is different from the original retrieved value.

    (5) Attempt *invalid read* to instruction region  
    1. Ensure `PPROT[2]` is low (data access)
    1. Attempt a typical read transaction to an address in an instruction region
    1. Confirm that `SLVERR` is asserted
    1. Confirm data on `PRDATA` is masked by setting it equal to `z`

    (6) Attempt *valid read* to instruction region  
    1. Ensure `PPROT[2]` is high (instruction access)
    1. Attempt a typical read transaction to an address in an instruction region
    1. Confirm that `SLVERR` is **not** asserted
    1. Confirm data on `PRDATA` is valid

    (7) Attempt *invalid write* to instruction region  
    1. Perform a *valid read* to an address in an instruction region and save retrieved value
    1. Ensure `PPROT[2]` is low (data region)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is the same as the original retrieved value.

    (8) Attempt *valid write* to instruction region  
    1. Perform a *valid read* to an address in an instruction region and save retrieved value
    1. Ensure `PPROT[2]` is high (instruction region)
    1. Attempt a typical write transaction to the address used above, using a different value than the one retrieved (maybe simply modify the retrieved value).
    1. Confirm that `SLVERR` is **not** asserted
    1. Perform a *valid read* to the same address and save retrieved value. Confirm the newly retrieved value is different from the original retrieved value.
