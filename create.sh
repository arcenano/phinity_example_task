
# Create complete Verilog module
cat > sources/simple_adder.sv << 'EOF'
module simple_adder (
    input wire clk,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [7:0] sum
);
    always @(posedge clk) begin
        sum <= a + b;  // Complete implementation
    end
endmodule
EOF

# Create hidden test (will grade the agent)
cat > tests/test_simple_adder_hidden.py << 'EOF'
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test_addition(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    await RisingEdge(dut.clk)
    dut.a.value = 5
    dut.b.value = 3
    await RisingEdge(dut.clk)
    assert dut.sum.value == 8, f"Expected 8, got {dut.sum.value}"

# ⚠️ CRITICAL: Every test needs this pytest wrapper
def test_simple_adder_hidden_runner():
    import os
    from pathlib import Path
    from cocotb_tools.runner import get_runner
    
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    
    sources = [proj_path / "sources/simple_adder.sv"]  # Note: sources/ not rtl/
    
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="simple_adder",
        always=True,
    )
    runner.test(
        hdl_toplevel="simple_adder",
        test_module="test_simple_adder_hidden"
    )
EOF

git add .
git commit -m "Complete simple_adder solution with tests"
git push origin simple_adder
