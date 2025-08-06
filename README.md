# 🧠 Static RAM (SRAM) Collection – Parameterized Verilog Modules

This project contains a suite of **SRAM implementations in Verilog**, covering four types of designs commonly encountered in hardware memory systems:

1. 🟢 **Single Port SRAM – Synchronous Read**
2. 🟡 **Single Port SRAM – Asynchronous Read**
3. 🔵 **Pseudo Dual Port SRAM – Synchronous Read**
4. 🔴 **True Dual Port SRAM – Synchronous Read**

All four implementations are **parameterized by depth and width**, feature **independent read and write enable signals**, and include detailed **testbenches** to demonstrate functionality.

---

## 🔍 Memory Overview

Before diving into SRAM specifics, here's a quick context on memory technologies.

### Volatile vs Non-Volatile

| Type | Retains Data on Power-Off? | Examples |
|------|-----------------------------|----------|
| Volatile | ❌ No | SRAM, DRAM, Cache |
| Non-Volatile | ✅ Yes | ROM, Flash, HDD, SSD |

### Cache and Memory Hierarchy
SRAM is widely used in **CPU caches** (L1/L2/L3) due to its **high speed and random-access capability**. While expensive and area-consuming, SRAM avoids refresh logic (unlike DRAM) and is favored in critical, fast-access paths.

---

## 📦 Project Highlights

- ✅ **Parametrized Design** – Easily customize `depth` and `width`
- ✅ **Separated `we` and `re` signals** – Provides more flexibility than traditional SRAM with a single `we`
- ✅ **Modular Testbenches** – Waveform and terminal-based testing
- ✅ **Explores Sync vs Async Read tradeoffs**
- 🛠️ **Hardware-Friendly RTL** (except async reads which may require caution in large designs)

---

## 🔧 SRAM Implementations

### 🟢 1. Single Port SRAM – Synchronous Read

- Read occurs on **clock edge**
- Cleanest and most stable type of read
- `data_out` is a `reg` assigned inside `always @(posedge clk)`

**Module**: `sram_sp.v`  
**Testbench**: `sram_sp_tb.v`

⏱️ **Waveform**:  
![Sync Read](https://github.com/VLSI-Shubh/SRAM/blob/231c723985ababd903c7d7f75f41a97d57863f00/images/Output%20-%20SIngle%20port%20Sync.%20read.png)
### 🧪 Waveform Analysis: Single Port SRAM (Sync Read)

This table captures the **significant changes** in signal behavior from the VCD dump of `sram_sp_tb.v` and explains what is happening in the design at each stage:

| Time (ns) | `we` | `re` | `addr` | `data_in` | `data_out` | Explanation |
|-----------|------|------|--------|-----------|------------|-------------|
| 0         | 0    | 0    | 0      | 0         | `x`        | Initial values; `data_out` is undefined (`x`) as simulation just started |
| 5         | 0    | 0    | 0      | 0         | `z`        | Output is high impedance (`z`) since neither read nor write is enabled |
| 10        | 1    | 0    | 0      | 25        | `z`        | Write enabled; 25 is written to address 0 (write happens on rising edge) |
| 20        | 0    | 0    | 0      | 25        | `z`        | Write disabled; no read either, output remains `z` |
| 30        | 0    | 1    | 0      | 25        | `z`        | Read enabled; read happens on next rising edge |
| 35        | 0    | 1    | 0      | 25        | 25         | On clock edge, value 25 is read from address 0 and appears at output |
| 40        | 0    | 0    | 0      | 25        | 25         | Read disabled; output retains last valid data temporarily |
| 45        | 0    | 0    | 0      | 25        | `z`        | With both `we` and `re` low, `data_out` goes to high impedance |

---

#### 📌 Key Takeaways:
- This is a **synchronous read** implementation — the read data (`data_out`) becomes valid **only after a rising clock edge** when `re` is high.
- Output goes to **high impedance (`z`)** when neither read nor write is active.
- Separate `we` and `re` signals provide **explicit control**, unlike traditional designs that infer read from `we = 0`.
---

### 🟡 2. Single Port SRAM – Asynchronous Read

- Read is **combinational** (outside clocked block)
- `data_out` is a **continuous assignment**
- Not ideal for all synthesis flows – suitable for small ROMs or LUT-based access

**Module**: `sram_sp_as.v`  
**Testbench**: `sram_sp_as_tb.v`

⚡ **Waveform**:  
![Async Read](https://github.com/VLSI-Shubh/SRAM/blob/231c723985ababd903c7d7f75f41a97d57863f00/images/Output%20-%20SIngle%20port%20Async.%20read.png)

### 🧪 Waveform Analysis: Single Port SRAM (Async Read)

This table summarizes the **signal transitions and their effect** on the output for the asynchronous read implementation (`sram_sp_as_tb.v`):

| Time (ns) | `we` | `re` | `addr` | `data_in` | `data_out` | Explanation |
|-----------|------|------|--------|-----------|------------|-------------|
| 0         | 0    | 0    | 0      | 0         | `z`        | Initial state; no read or write enabled, output is high impedance |
| 10        | 1    | 0    | 0      | 25        | `z`        | Write enabled; 25 is written to address 0 on rising edge of clock |
| 20        | 0    | 0    | 0      | 25        | `z`        | Write disabled; no read; output stays in high impedance |
| 30        | 0    | 1    | 0      | 25        | 25         | Asynchronous read: as soon as `re` is high, data from address 0 (25) appears immediately at output |
| 40        | 0    | 0    | 0      | 25        | `z`        | Read disabled; output goes back to high impedance |

---

#### 📌 Key Takeaways:
- **Asynchronous read**: `data_out` changes **immediately** when `re` is asserted, without waiting for a clock edge.
- Output goes to **high impedance (`z`)** when `re` is deasserted.
- The design is suitable for **fast, clock-independent reads**, but can be unstable for larger designs or high-speed systems.

---

### 🔵 3. Pseudo Dual Port SRAM – Sync Read

- **Write Port (A)** and **Read Port (B)** share memory, but have separate addresses and control signals
- Useful when read/write does **not occur simultaneously on the same address**

**Module**: `sram_pdp.v`  
**Testbench**: `sram_pdp_tb.v`

🔄 **Waveform**:  
![Pseudo Dual Port](https://github.com/VLSI-Shubh/SRAM/blob/231c723985ababd903c7d7f75f41a97d57863f00/images/Output_Pseudo_Dual_port.png)

### 🧪 Waveform Analysis: Pseudo Dual Port SRAM (Sync Read)

This table highlights the **critical changes in signal behavior** and their effect on `data_outB`(ab) during the simulation of the `sram_pdp_tb.v` testbench:

| Time (ns) | `clk` | `cs` | `we_A` | `re_B` | `A`     | `aa` | `ab` | `y`    | Explanation |
|-----------|-------|------|--------|--------|---------|------|------|--------|-------------|
| 0         | 0     | 0    | 0      | 0      | 0000    | 0    | 0    | `xxxx` | Initial state; chip select disabled, all outputs undefined |
| 5         | 1     | 1    | 1      | 0      | `abcd`  | 12   | 0    | `zzzz` | Write to address 12 initiated on Port A |
| 15        | 1     | 1    | 0      | 0      | `0000`  | 12   | 0    | `zzzz` | Write completed, outputs still high impedance |
| 25        | 1     | 1    | 0      | 1      | `0000`  | 12   | 12   | `abcd` | Synchronous read on Port B at address 12 returns `abcd` |
| 45        | 1     | 1    | 1      | 0      | `1234`  | 100  | 12   | `zzzz` | Write new data `1234` to address 100 via Port A |
| 65        | 1     | 1    | 0      | 1      | `1234`  | 100  | 100  | `1234` | Read from address 100 returns `1234` on `y` |
| 85        | 1     | 1    | 0      | 0      | `1234`  | 100  | 100  | `zzzz` | Read disabled; `data_outB` goes to high impedance |

---

#### 📌 Key Takeaways:
- The pseudo dual port design allows **simultaneous access** to memory through different ports for **read** and **write**.
- `data_outB` is updated **on the rising edge of the clock**, confirming **synchronous read behavior**.
- When `re_B` is deasserted, `data_outB` enters a **high impedance state (`zzzz`)**.

> ✅ Note: Although the ports are logically separated, they still **share a common clock** and memory, unlike true dual port SRAMs.

---

### 🔴 4. True Dual Port SRAM – Sync Read

- Two **completely independent ports (A and B)**
- Independent clocks, addresses, inputs, enables
- Allows full **simultaneous access**, true dual-port operation

**Module**: `sram_dp.v`  
**Testbench**: `sram_dp_tb.v`
![True Dual Port](https://github.com/VLSI-Shubh/SRAM/blob/231c723985ababd903c7d7f75f41a97d57863f00/images/Output_True_Dual_port.png)

## 📈 Waveform Analysis: True Dual-Port SRAM (`sram_dp_tb.v`)

This table captures key events from the VCD simulation and explains output transitions with respect to Port A and Port B operations.

| Time (ns) | Action                                                                 | Port A Signals                                  | Port B Signals                                  | Output A | Output B | Explanation |
|-----------|------------------------------------------------------------------------|--------------------------------------------------|--------------------------------------------------|----------|----------|-------------|
| 15000     | Write to addr 5 by Port A                                            | `we_A=1`, `add_A=5`, `data_inA=aaaa`             | —                                                | zzzz     | zzzz     | Port A writes `aaaa` to addr 5 |
| 21000     | Write to addr 10 by Port B                                           | —                                                | `we_B=1`, `add_B=10`, `data_inB=bbbb`            | zzzz     | zzzz     | Port B writes `bbbb` to addr 10 |
| 35000     | Read from addr 5 by Port A                                           | `re_A=1`, `add_A=5`                              | —                                                | `aaaa`   | zzzz     | Port A reads its own earlier write to addr 5 |
| 49000     | Read from addr 10 by Port B                                          | —                                                | `re_B=1`, `add_B=10`                             | aaaa     | `bbbb`   | Port B reads its own earlier write to addr 10 |
| 56000     | Write to addr 15 by Port A                                           | `we_A=1`, `add_A=15`, `data_inA=1234`            | —                                                | aaaa     | bbbb     | Port A writes `1234` to addr 15 |
| 63000     | Read from addr 5 by Port B                                           | —                                                | `re_B=1`, `add_B=5`                              | aaaa     | `aaaa`   | 🧠 **Important:** Even though `data_inB=bbbb`, no write occurred to addr 5. Port B reads `aaaa`, written earlier by Port A. |
| 75000     | Read from addr 15 by Port A                                          | `re_A=1`, `add_A=15`                             | —                                                | `1234`   | aaaa     | Port A verifies its own write to addr 15 |
| 91000     | End of read by Port B                                                | —                                                | `re_B=0`                                         | `1234`   | zzzz     | Output B goes high-Z after read is disabled |

---

### 🔍 Key Insight:

At **time 63000**, even though `data_inB = bbbb` and `add_B = 5`, Port B reads **`aaaa`**.  
Why?

- `bbbb` was never written to **address 5** — it was written to **address 10**.
- `aaaa` was written to **address 5** by Port A at time 15000.
- Port B is **only reading**, so it observes the last data stored at address 5, which is `aaaa`.

✅ This confirms **correct True Dual-Port SRAM behavior** — both ports access the same memory array, and changes made by one port are visible to the other (if not overwritten).


---

#### 📌 Key Takeaways:
- **True dual port SRAM** supports simultaneous independent reads/writes on two ports.
- Each port operates on **its own clock** (`clk_A`, `clk_B`).
- When read enable is low, the corresponding output enters **high-impedance (`zzzz`)** state.
- Demonstrates **non-blocking and parallel memory access**.

> ✅ This simulation validates the ability of the memory to handle concurrent, independent read and write operations.

---

#### 📌 Key Takeaways:
- True dual port SRAM allows **independent, simultaneous** read/write operations through two separate ports (`A` and `B`), each with its own clock.
- Writes and reads occur **only on respective clock edges** (`clk_A` and `clk_B`) due to synchronous design.
- **`data_outA` and `data_outB` reflect changes** when the corresponding port is in **read mode**, and enter **high impedance (`zzzz`)** when not reading.

> ✅ This simulation verifies **concurrent access** to memory and shows the **correct data flow** through both ports with isolated controls.

---



## 📁 Project Structure

| File | Description |
|------|-------------|
| `sram_sp.v` | Single Port SRAM (sync read) |
| `sram_sp_as.v` | Single Port SRAM (async read) |
| `sram_pdp.v` | Pseudo Dual Port SRAM |
| `sram_dp.v` | True Dual Port SRAM |
| `*_tb.v` | Testbenches |
| `*.vcd` | Simulation waveform files |
| `images/` | Waveform images |


---
## 🛠️ Tools Used

| Tool               | Purpose                                           |
|--------------------|---------------------------------------------------|
| **Icarus Verilog** | Compile/simulate Verilog code                    |
| **GTKWave**        | View simulation waveform dumps (`.vcd` files)    |
| **EDA Playground** | Online Verilog editor and schematic viewer       |

---
## 📝 License


Open for educational and personal use under the [MIT License](https://github.com/VLSI-Shubh/SRAM/blob/3f7917260e63eb739c8da0813528dcd941404774/License.txt)
