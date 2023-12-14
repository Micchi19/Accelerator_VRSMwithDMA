module tb_first_ring_buffer ();
    localparam DATA_WIDTH = 32;
    localparam NUM_LANE = 2;
    localparam BURST_LENGTH = 8;

    logic                                                       clk;
    logic                                                       rst;
    logic                                                       wen;
    logic                                                       ren;
    logic [NUM_LANE - 1:0][DATA_WIDTH - 1:0]                    din;
    logic                                                       valid;
    logic [DATA_WIDTH - 1:0]                                    dout;
    logic [(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]   fifo_checker; // test
    logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]               wptr_checker;
    logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]               rptr_checker;
    logic                                                       empty_flag_checker;


    first_ring_buffer #(
                    .DATA_WIDTH     (DATA_WIDTH),
                    .NUM_LANE       (NUM_LANE),
                    .BURST_LENGTH   (BURST_LENGTH)
    ) dut(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen),
                    .ren(ren),
                    .din(din),
                    .valid(valid),
                    .wptr_checker(wptr_checker),
                    .rptr_checker(rptr_checker),
                    .fifo_checker(fifo_checker),
                    .empty_flag_checker(empty_flag_checker),
                    .dout(dout)
);

localparam CLK_PERIOD = 2;
initial begin
    clk <= 1;
    forever #(CLK_PERIOD / 2) clk=~clk;
end

initial begin
    $dumpfile("tb_first_ring_buffer.vcd");
    $dumpvars(0, tb_first_ring_buffer);
end

task test(logic wen_i, logic ren_i, logic [DATA_WIDTH - 1:0] din_i);
    begin
        wen = wen_i;
        ren = ren_i;
        for(int i = 0;i < NUM_LANE;i++) begin
            din[i] = din_i + i;
        end
    end
endtask

task sample1();
    begin
        for(int i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)       test(1, 1, i);    
        end
        for(int i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)       test(0, 1, i);    
        end
    end
endtask

task edge0();
    begin
        for(int i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)       test(0, 1, i);    
        end
        for(int i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)       test(1, 1, i);    
        end
        for(int i = 0;i < BURST_LENGTH;i++) begin
            #(CLK_PERIOD)       test(0, 1, i);    
        end
    end
endtask


initial begin
    rst = 0; wen = 0; ren = 0; din = 0; 
    #(CLK_PERIOD * 2)   rst = 1;
    #(CLK_PERIOD)       rst = 0;
    #(CLK_PERIOD * 2)   
    edge0();
    #(CLK_PERIOD)       test(0, 0, 0);
    #(CLK_PERIOD * 20);
    $finish();
end

endmodule
`default_nettype wire