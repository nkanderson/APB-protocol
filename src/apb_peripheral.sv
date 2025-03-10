/*
    apb_peripheral - Source Code for APB Peripheral

    ECE 571 - Team 6 Winter 2025
*/

module apb_peripheral
(
    apb_if.peripheral apb  // Connect to APB interface (peripheral side)
);
  // Import package
  import apb_pkg::*;

  // FSM Variables
  state currState, nextState;

  // Variables
  logic err;

  // Internal storage
  logic [31:0] reg_mem[REG_ITEMS];

  // FSM
  always_ff @(posedge apb.pclk or negedge apb.presetn) begin
    if (!apb.presetn) begin
      // Reset internal registers
      foreach (reg_mem[i]) begin
        reg_mem[i] <= '0;  // Set each element to 0
      end
      // Reset status registers
      err <= 1'b0;
      currState <= IDLE;
    end else begin
      // Reset any errors present only during ACCESS
      if (err && currState == ACCESS)
        err <= 1'b0;

      // Push next state to current state
      currState <= nextState;
      end
  end

  // Output Logic
  always_comb begin
    unique case (currState)
      // For any other state, don't send data yet
      IDLE: begin
        apb.pready = 1'b0;
        apb.prdata = 'bz;
        apb.pslverr = 1'b0;
      end
      SETUP: begin
        // Note: if we want to simulate waitstates,
        // PREADY needs to be deasserted (maybe use
        // a counter to keep PREADY deasserted for
        // x number of cycles)
        apb.pready = 1'b0;
        apb.pslverr = 1'b0;

        // TODO: Need write logic here
        if (apb.pwrite) begin

          apb.prdata = 'bz;

        // For read transfer, drive PRDATA with the contents
        // of the reg_mem using PADDR excluding the byte align bits
        // If err is asserted, drive prdata with Z
        end else begin
          apb.prdata = (err) ? 'bz : reg_mem[apb.paddr[ADDR_WIDTH-1:ALIGNBITS]];
        end
      end
      ACCESS: begin
        apb.prdata = 'bz;
        apb.pready = 1'b1;
        apb.pslverr = (err) ? 1'b1 : 1'b0;
      end
    endcase
  end

  // Next State Logic
  always_comb begin
    err = 1'b0;
    unique case (currState)
      // IDLE: Default state of APB Protocol (no transfer)
      IDLE: begin
        // Check if device is selected and if the state is
        // not in a secondary or subsequent cycle of the APB transfer
        if (apb.psel) begin
          nextState = SETUP;
          err = apb.penable ? 1'b1 : 1'b0;

        // Else remain in IDLE mode
        end else begin
          nextState = IDLE;
        end
      end
      // SETUP: a transfer has been sent by REQUESTER
      SETUP: begin
        // Checks for the following errors:
        // - If PSEL signal drops during SETUP
        // - If PADDR is not aligned
        // - If PENABLE signal is asserted during SETUP
        if (!apb.psel || !validAlign(apb.paddr) || apb.penable) begin
          nextState = ACCESS;     // Continue to ACCESS state
          err = 1'b1;             // Indicate error has occured

        // If the requester is ready for access,
        // the perhiperal will transition to ACCESS
        end else begin
          nextState = ACCESS;
        end
      end
      // ACCESS: checks for continued chained accesses
      ACCESS: begin
        // Check if any waitstates have been inserted
        if (apb.pready == 0) begin
          nextState = ACCESS;
        // Else transfer is good to continue
        end else begin
          // If PSEL still is high, go back to SETUP
          // for chained reads/writes
          if (apb.psel) begin
            nextState = SETUP;

          // Else return back to IDLE
          end else begin
            nextState = IDLE;
          end
        end
      end
    endcase
  end

endmodule
