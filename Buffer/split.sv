module split#(
    parameter DATA_WIDTH = 32,
    parameter BURST_LENGTH = 32,
    parameter KERNEL_LENGTH = 3     // KERNEL_SIZE = KERNEL_LENGTH * KERNEL_LENGTH
)(
    input logic                                             clk,
    input logic                                             rst,
    input logic                                             wen,
    input logic                                             ren,
    input logic [DATA_WIDTH - 1:0]                          din,
    output logic                                            valid,
    output logic                                            full_flag,
    output logic                                            empty_flag,
    output logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             wen_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             ren_i_checker,
    output logic [KERNEL_LENGTH - 1:0][BURST_LENGTH - 1:0][DATA_WIDTH - 1:0]               fifo0_checker,
    output logic [KERNEL_LENGTH - 1:0]                             full_flag_i_checker,
    output logic [KERNEL_LENGTH - 1:0]                             empty_flag_i_checker,
    output logic [KERNEL_LENGTH - 1:0][$clog2(BURST_LENGTH) - 1:0] wptr_checker, 
    output logic [KERNEL_LENGTH - 1:0][$clog2(BURST_LENGTH) - 1:0] rptr_checker,
    output logic [KERNEL_LENGTH - 1:0][DATA_WIDTH - 1:0]    dout
);

    logic [KERNEL_LENGTH - 1:0]                             wen_i;
    logic [KERNEL_LENGTH - 1:0]                             ren_i;
    logic [KERNEL_LENGTH - 1:0]                             full_flag_i;
    logic [KERNEL_LENGTH - 1:0]                             empty_flag_i;
    logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i; // NUM: KERNEL_LENGTH + 1

    //for test
    assign data_i_checker = data_i;
    assign wen_i_checker = wen_i;
    assign ren_i_checker = ren_i;
    assign full_flag_i_checker = full_flag_i;
    assign empty_flag_i_checker = empty_flag_i;

    // Output Assignment
    assign full_flag = full_flag_i[0];
    assign empty_flag = empty_flag_i[2];
    assign valid = ren && !empty_flag_i[0] && full_flag_i[1] && full_flag_i[2];
    assign dout = data_i[KERNEL_LENGTH:1];

    genvar i;
    generate
        for(i = 0;i < KERNEL_LENGTH;i++) begin
            // FIFO
            ring_buffer#(
                                            .DATA_WIDTH(DATA_WIDTH),
                                            .BURST_LENGTH(BURST_LENGTH)
            )  ring_buffer_i(
                                            .clk(clk),
                                            .rst(rst),
                                            .wen(wen_i[i]),
                                            .ren(ren_i[i]),
                                            .din(data_i[i]),
                                            .full_flag(full_flag_i[i]),
                                            .empty_flag(empty_flag_i[i]),
                                            .fifo0_checker(fifo0_checker[i]),
                                            .wptr_checker(wptr_checker[i]),
                                            .rptr_checker(rptr_checker[i]),
                                            .dout(data_i[i + 1])
            );
        end
            
        for(i = 1;i < KERNEL_LENGTH;i++) begin
            // Each wen & ren
            assign wen_i[i] = !empty_flag_i[i - 1];
            assign ren_i[i - 1] = !full_flag_i[i] && !empty_flag_i[i - 1];
        end
    endgenerate

    // always_ff @(posedge clk or posedge rst) begin
    //     for(integer j = 1;j < KERNEL_LENGTH;j++) begin
    //         if(rst) begin
    //             wen_i[j] <= 1'b0;
    //             ren_i[j] <= 1'b0;
    //         end else begin
    //             wen_i[j] <= !empty_flag_i[j - 1];
    //             ren_i[j - 1] <= !full_flag_i[j];
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
    assign data_i[0] = din;
    assign wen_i[0] = wen;
    assign ren_i[2] = ren && !empty_flag_i[0] && full_flag_i[1];


endmodule