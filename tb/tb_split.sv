module tb_split();
localparam DATA_WIDTH = 32;
localparam BURST_LENGTH = 32;
localparam KERNEL_LENGTH = 3;           // KERNEL_SIZE = KERNEL_LENGTH * KERNEL_LENGTH

logic                                                   clk;
logic                                                   rst;
logic                                                   wen;
logic                                                   ren;
logic [DATA_WIDTH - 1:0]                                din;
logic                                                   valid;
logic                                                   full_flag;
logic                                                   empty_flag;
logic [KERNEL_LENGTH - 1:0][DATA_WIDTH - 1:0]           dout;
logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i_checker; // for test
logic [KERNEL_LENGTH - 1:0]                             wen_i_checker;
logic [KERNEL_LENGTH - 1:0]                             ren_i_checker;
logic [KERNEL_LENGTH - 1:0][BURST_LENGTH - 1:0][DATA_WIDTH - 1:0]               fifo0_checker;
logic [KERNEL_LENGTH - 1:0]                             full_flag_i_checker;
logic [KERNEL_LENGTH - 1:0]                             empty_flag_i_checker;


split dut(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen),
                    .ren(ren),
                    .din(din),
                    .valid(valid),
                    .full_flag(full_flag),
                    .empty_flag(empty_flag),
                    .data_i_checker(data_i_checker),
                    .wen_i_checker(wen_i_checker),
                    .ren_i_checker(ren_i_checker),
                    .fifo0_checker(fifo0_checker),
                    .full_flag_i_checker(full_flag_i_checker),
                    .empty_flag_i_checker(empty_flag_i_checker),
                    // .wptr_check(wptr_check),
                    // .rptr_check(rptr_check),
                    .dout(dout)
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD / 2) clk=~clk;
end

initial begin
    $dumpfile("tb_split.vcd");
    $dumpvars(0, tb_split);
end

task test(logic wen_i, logic ren_i, logic [DATA_WIDTH - 1:0] din_i);
    begin
        wen = wen_i;
        ren = ren_i;
        din = din_i;
    end
endtask

task full_buffer(logic [DATA_WIDTH - 1:0] din_i);
    begin
        for(integer i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)   test(1, 0, i+1);
        end
    end
endtask

task last_buffer(logic [DATA_WIDTH - 1:0] din_i);
    begin
        for(integer i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)   test(1, 1, i+1);
        end
    end
endtask

initial begin
    rst = 0; wen = 0; ren = 0; din = 0; 
    #(CLK_PERIOD * 2)   rst = 1;
    #(CLK_PERIOD)       rst = 0;
    #(CLK_PERIOD * 2)   test(0, 0, 0);
    full_buffer(1);
    #(CLK_PERIOD)       test(0, 0, 0);
    full_buffer(2);
    #(CLK_PERIOD)       test(0, 0, 0);
    last_buffer(3);
    #(CLK_PERIOD)       test(0, 0, 0);
    #(CLK_PERIOD * 20);
    $finish();
end

endmodule
`default_nettype wire