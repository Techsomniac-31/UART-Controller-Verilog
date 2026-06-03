# Synthesizable UART Core with 16x Oversampling
This repository contains a complete, modular hardware implementation of the Universal Asynchronous Receiver-Transmitter (UART) protocol designed in Verilog-HDL. The architecture features an integrated Baud Rate Generator, a Finite State Machine (FSM) based Transmitter, and a Receiver utilizing a 16x oversampling algorithm for robust asynchronous data recovery.

Verification was performed using a loopback testbench architecture simulated inside Xilinx Vivado.

## System Architecture
The design is modularized under a top-level controller (uart_top.v) that handles clock routing, control paths, and internal serial loopback wiring via explicit named port mapping.

1. Baud Rate Generator (baude_rate_generator.v)
Divides the master system clock down to precise execution enable ticks. To guarantee zero timing drift between transmission and reception windows, the transmission clock enable is tuned as an exact integer multiple of the 16x oversampling reception clock enable.

TX Enable Counter: Resets at 5199 cycles (5200 clock periods).

RX Enable Counter: Resets at 324 cycles (325 clock periods).

Clocking Ratio: 5200 / 325 = 16 (Perfect 16x oversampling alignment).

2. Transmitter FSM (transmitter.v)
Driven by a 4-state sequential Finite State Machine consisting of IDLE, START, DATA, and STOP states.

Instantly latches parallel 8-bit input data (data_in) when the write enable (wr_en) signal pulses high.

Asserts a hardware busy flag to prevent upstream data overwrite during active transmission serialization.

3. Receiver Center-Sampling Engine (receiver.v)
An asynchronous data-recovery system designed to eliminate phase errors and transmission jitter. Instead of tracking data on bit transitions, it targets the static stability region of each serial frame:

Start-Bit Validation: Upon detecting a falling edge on the RX line, it counts 8 receiver enable ticks (sample == 4'd7) to verify the signal is a valid start bit and not a transient glitch.

Mid-Bit Data Capture: Shifts into the data tracking loop and samples subsequent bits exactly every 16 clock ticks (sample == 4'd15), locking data capture straight into the physical geometric center of each bit period.

## Verification and Simulation Event Timeline
The testbench verifies the hardware by streaming sequential data packets (8'h41 followed by 8'h55) through an internal serial loopback connection.

Reset Sequence: Global hardware reset (rst) is asserted and safely de-asserted.

Packet 1 Initialization: Testbench passes character 8'h41 ('A') and pulses wr_en. The top-level core asserts busy, pulling the serial line low to construct the frame.

Data Recovery: The receiver processes the serialized bits over time. Exactly 16 sample pulses into the stop bit state, the character data is reconstructed, outputting 8'h41 on dout and asserting the rdy strobe.

Packet 2 Iteration: The receiver ready line is cleared via rdy_clr, freeing the pipeline to cleanly accept and process the subsequent packet data 8'h55.

## Repository File Structure
src/uart_top.v - Top-level module interconnecting the subsystem

src/baude_rate_generator.v - Dual clock-divider/baud enable tick generator

src/transmitter.v - TX Parallel-to-Serial FSM module

src/receiver.v - RX Serial-to-Parallel center-sampling module

sim/uart_top_tb.v - Self-testing loopback Testbench

## How to Run the Project (Xilinx Vivado)
Create a new project in Xilinx Vivado.

Add the files inside the src/ directory as Design Sources.

Add sim/uart_top_tb.v as a Simulation Source.

Click "Run Simulation" then select "Run Behavioral Simulation".

Set the simulation duration runtime constraint to 600 us inside the Tcl Console interface tool and execute: run 600 us

Press the 'F' key inside the waveform viewport panel to auto-fit the full transmission trace stream into frame view.
