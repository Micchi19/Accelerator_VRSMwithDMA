module tb_ring_buffer();
localparam DATA_WIDTH = 32;
localparam BUFFER_SIZE = 128;

logic                                                   clk;
logic                                                   rst;
logic                                                   wen;
logic                                                   ren;
logic [DATA_WIDTH - 1:0]                                din;
logic                                                   full_flag;
logic                                                   empty_flag;
logic [DATA_WIDTH - 1:0]                                dout;
//logic [$clog2(BUFFER_SIZE) - 1:0]                       wptr_check, rptr_check;
//logic [DATA_WIDTH - 1:0]                                fifo_check0;

ring_buffer dut(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen),
                    .ren(ren),
                    .din(din),
                    .full_flag(full_flag),
                    .empty_flag(empty_flag),
                    // .wptr_check(wptr_check),
                    // .rptr_check(rptr_check),
                    // .fifo_check0(fifo_check0)
                    .dout(dout)
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD / 2) clk=~clk;
end

initial begin
    $dumpfile("tb_ring_buffer.vcd");
    $dumpvars(0, tb_ring_buffer);
end

task test(logic wen_i, logic ren_i, logic [DATA_WIDTH - 1:0] din_i);
    begin
        wen = wen_i;
        ren = ren_i;
        din = din_i;
    end
endtask

task sample1();
    begin
        #(CLK_PERIOD)       test(1, 0, 1);
        #(CLK_PERIOD)       test(1, 0, 2);
        #(CLK_PERIOD)       test(1, 0, 3);
        #(CLK_PERIOD)       test(1, 0, 4);
        #(CLK_PERIOD)       test(1, 0, 5);
        #(CLK_PERIOD)       test(0, 0, 0);
        
        #(CLK_PERIOD)       test(0, 1, 6);
        #(CLK_PERIOD)       test(0, 1, 7);
        #(CLK_PERIOD)       test(0, 1, 8);
        #(CLK_PERIOD)       test(0, 1, 9);
        #(CLK_PERIOD)       test(0, 1, 10); // empty
        #(CLK_PERIOD)       test(0, 1, 11); 
        #(CLK_PERIOD)       test(1, 0, 12);
        #(CLK_PERIOD)       test(1, 0, 13);
        #(CLK_PERIOD)       test(0, 1, 16);
        #(CLK_PERIOD)       test(0, 1, 17);
    end
endtask

task sample2();
    begin
        #(CLK_PERIOD)       test(1, 0, 1);
        #(CLK_PERIOD)       test(1, 1, 2);
        #(CLK_PERIOD)       test(1, 1, 3);
        #(CLK_PERIOD)       test(1, 1, 4);
        #(CLK_PERIOD)       test(1, 1, 5);
        #(CLK_PERIOD)       test(0, 1, 6);
        #(CLK_PERIOD)       test(0, 0, 0);
    end
endtask

initial begin
    rst = 0; wen = 0; ren = 0; din = 0; 
    #(CLK_PERIOD * 2)   rst = 1;
    #(CLK_PERIOD)       rst = 0;
    #(CLK_PERIOD * 2)   test(0, 0, 0);
    sample2();
    #(CLK_PERIOD)       test(0, 0, 0);
    #(CLK_PERIOD * 20);
    $finish();
end

endmodule
`default_nettype wire