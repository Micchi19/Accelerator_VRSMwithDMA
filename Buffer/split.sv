module split#(
    parameter DATA_WIDTH = 32,
    parameter BURST_LENGTH = 128,
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
    output logic [KERNEL_LENGTH - 1:0][DATA_WIDTH - 1:0]    dout
);

    logic [KERNEL_LENGTH - 1:0]                             wen_i;
    logic [KERNEL_LENGTH - 1:0]                             ren_i;
    logic [KERNEL_LENGTH - 1:0]                             full_flag_i;
    logic [KERNEL_LENGTH - 1:0]                             empty_flag_i;
    logic [KERNEL_LENGTH:0][DATA_WIDTH - 1:0]               data_i; // NUM: KERNEL_LENGTH + 1

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
                                            .dout(data_i[i + 1])
            );
        end
            
        for(i = 1;i < KERNEL_LENGTH;i++) begin
            // Each wen & ren
            assign wen_i[i] = !empty_flag_i[i - 1];
            assign ren_i[i - 1] = !full_flag_i[i];
        end
    endgenerate

    // Assignment Exception for Loop
    assign data_i[0] = din;
    assign wen_i[0] = wen;
    assign ren_i[2] = ren && !empty_flag_i[0] && full_flag_i[1];

endmodule