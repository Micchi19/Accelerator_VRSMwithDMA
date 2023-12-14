module ring_buffer#(
    parameter DATA_WIDTH = 32,
    parameter BURST_LENGTH = 128,
    parameter NUM_LANE = 4
)(
    input  logic                                                    clk,
    input  logic                                                    rst,
    input  logic                                                    wen,
    input  logic                                                    ren,
    input  logic [DATA_WIDTH - 1:0]                                 din,
    output logic                                                    full_flag,
    output logic                                                    empty_flag,
    output logic [(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]                                 fifo_checker, // test
    output logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                               wptr_checker, 
    output logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                       rptr_checker,
    output logic [DATA_WIDTH - 1:0]                                 dout
);

    logic [(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]        buffer;
    logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                    wptr, rptr;
    logic                                                            reg_full_flag;


    // for test
    assign fifo_checker = buffer;
    assign wptr_checker = wptr;
    assign rptr_checker = rptr;

    // Output Assignment
    assign dout = buffer[rptr];

    // Full Flag & Empty Flag
    assign full_flag = (rptr == wptr);
    assign empty_flag = (rptr == (wptr - 1'b1));

    // Input
    always_ff @(posedge clk) begin
        if(wen && !reg_full_flag)
            buffer[wptr] <= din;
    end

    // Write Pointer & Read Pointer
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            wptr <= 0;
            rptr <= ~0;
        end else begin
            // Write Pointer
            if(wen && !full_flag) begin
                if(wptr == ~0)
                    wptr <= 0;
                else 
                    wptr <= wptr + 1;
            end
            // Read Pointer
            if(ren && !empty_flag) begin
                if(rptr == ~0)
                    rptr <= 0;
                else
                    rptr <= rptr + 1;
            end
        end
    end

    always_ff @(posedge clk) begin
        reg_full_flag <= full_flag;
    end

endmodule