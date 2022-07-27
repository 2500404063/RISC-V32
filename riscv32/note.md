# Notes for Dev

## readmemh
```verilog
module rv32_tb (
);

reg[31:0] rom[99:0];

initial begin
    $readmemh("./program.bin",rom,0,3);
    $display("rom: %h",rom[0]);
    $display("rom: %h",rom[1]);
    $display("rom: %h",rom[1][7:0]);
end

endmodule
```

And the program.bin is
```text
00FFAABB
//I am Ignored
/*I am Ignored as well*/
/*********************************
I am Ignored as well
*********************************/
AABBCCDD
```
This is valid.