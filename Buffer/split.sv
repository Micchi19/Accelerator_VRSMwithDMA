module split#(
    parameter DATA_WIDTH = 32,
    parameter BURST_LENGTH = 32,
    parameter NUM_LANE = 2,
    parameter KERNEL_LENGTH = 3     // KERNEL_SIZE = KERNEL_LENGTH * KERNEL_LENGTH
)(
    input  logic                                            clk,
    input  logic                                            rst,
    input  logic                                            wen,
    input  logic                                            ren, // connect to !(for_output's full_flag)
    input  logic [NUM_LANE - 1:0][DATA_WIDTH - 1:0]         din,
    output logic                                            valid,
    output logic                                            full_flag,
    output logic                                            empty_flag,
    output logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             wen_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             ren_i_checker,
    output logic [KERNEL_LENGTH - 1:0][(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]               fifo_checker,
    output logic [KERNEL_LENGTH - 1:0]                             full_flag_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             empty_flag_i_checker,
    output logic [KERNEL_LENGTH - 1:0][$clog2(NUM_LANE * BURST_LENGTH) - 1:0] wptr_checker, 
    output logic [KERNEL_LENGTH - 1:0][$clog2(NUM_LANE * BURST_LENGTH) - 1:0] rptr_checker,
    output logic [KERNEL_LENGTH - 1:0][DATA_WIDTH - 1:0]    dout
);

    logic [KERNEL_LENGTH - 1:0]                             wen_i;
    logic [KERNEL_LENGTH - 1:0]                             ren_i;
    logic [KERNEL_LENGTH - 1:0]                             full_flag_i;
    logic [KERNEL_LENGTH - 1:0]                             empty_flag_i;
    logic [KERNEL_LENGTH - 1:0]                             reg_empty_flag_i;
    logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i; // NUM: KERNEL_LENGTH + 1


    first_ring_buffer #(
                                            .DATA_WIDTH(DATA_WIDTH),
                                            .NUM_LANE(NUM_LANE),
                                            .BURST_LENGTH(BURST_LENGTH)
    ) first_fifo (
                                            .clk(clk),
                                            .rst(rst),
                                            .wen(wen),
                                            .ren(!full_flag_i[0]),
                                            .din(din),
                                            .valid(wen_i[0]),
                                            .dout(data_i[0])
    );

    //for test
    assign data_i_checker = data_i;
    assign wen_i_checker = wen_i;
    assign ren_i_checker = ren_i;
    assign full_flag_i_checker = full_flag_i;
    assign empty_flag_i_checker = empty_flag_i;

    // Output Assignment
    assign full_flag = full_flag_i[0]; // no need?
    assign empty_flag = empty_flag_i[2];
    assign dout = data_i[KERNEL_LENGTH:1];

    assign valid = ren && !empty_flag_i[0] && full_flag_i[1] && full_flag_i[2];

    genvar i;
    generate
        for(i = 0;i < KERNEL_LENGTH;i++) begin
            // FIFO
            ring_buffer#(
                                            .DATA_WIDTH(DATA_WIDTH),
                                            .BURST_LENGTH(BURST_LENGTH),
                                            .NUM_LANE(NUM_LANE)
            )  ring_buffer_i(
                                            .clk(clk),
                                            .rst(rst),
                                            .wen(wen_i[i]),
                                            .ren(ren_i[i]),
                                            .din(data_i[i]),
                                            .full_flag(full_flag_i[i]),
                                            .empty_flag(empty_flag_i[i]),
                                            .fifo_checker(fifo_checker[i]),
                                            .wptr_checker(wptr_checker[i]),
                                            .rptr_checker(rptr_checker[i]),
                                            .dout(data_i[i + 1])
            );
            // ring_buffer#(
            //                                 .DATA_WIDTH(DATA_WIDTH),
            //                                 .BURST_LENGTH(BURST_LENGTH)
            // )  ring_buffer_i(
            //                                 .clk(clk),
            //                                 .rst(rst),
            //                                 .wen(wen_i[i]),
            //                                 .ren(ren_i[i]),
            //                                 .din(data_i[i]),
            //                                 .full_flag(full_flag_i[i]),
            //                                 .empty_flag(empty_flag_i[i]),
            //                                 .fifo_checker(fifo_checker[i]),
            //                                 .wptr_checker(wptr_checker[i]),
            //                                 .rptr_checker(rptr_checker[i]),
            //                                 .dout(data_i[i + 1])
            // );
        end
            
        for(i = 1;i < KERNEL_LENGTH;i++) begin
            // Each wen & ren
            assign wen_i[i] = !reg_empty_flag_i[i - 1];
            assign ren_i[i - 1] = !full_flag_i[i] && !empty_flag_i[i - 1];
        end
    endgenerate

    always_ff @(posedge clk or posedge rst) begin
        reg_empty_flag_i <= empty_flag_i;
    end

    // always_ff @(posedge clk or posedge rst) begin
    //     for(integer j = 1;j < KERNEL_LENGTH;j++) begin
    //         if(rst) begin
    //             wen_i[j] <= 1'b0;
    //             ren_i[j] <= 1'b0;
    //         end else begin
    //             wen_i[j] <= !empty_flag_i[j - 1];
    //             ren_i[j - 1] <= !full_flag_i[j] && !empty_flag_i[j - 1];
    //         end
    //     end
    // end

    // always_ff @(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         wen_i[0] <= 1'b0;
    //         ren_i[0] <= 1'b0;
    //     end else begin
    //         wen_i[0] <= wen;
    //         ren_i[2] <= ren && !empty_flag_i[0] && full_flag_i[1];
    //     end
    // end

    // Assignment Exception for Loop
    assign ren_i[2] = ren && !empty_flag_i[0] && full_flag_i[1];

    always_ff @(posedge clk or posedge rst) begin
        $display("%d, %d, %d, | %d, %d, %d", fifo_checker[0][0], fifo_checker[1][0], fifo_checker[2][0], fifo_checker[0][31], fifo_checker[1][31], fifo_checker[2][31]);
    end


endmodule