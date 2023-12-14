module first_ring_buffer #(
    parameter DATA_WIDTH = 32,
    parameter NUM_LANE = 4,
    parameter BURST_LENGTH = 128
)(
    input  logic                                                    clk,
    input  logic                                                    rst,
    input  logic                                                    wen,
    input  logic                                                    ren,  // connect to !(buffer[0]'s full_flag)
    input  logic [NUM_LANE - 1:0][DATA_WIDTH - 1:0]                 din,
    output logic                                                    valid,
    // output logic [(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]                                 fifo_checker, // for test
    // output logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                               wptr_checker,  // for test
    // output logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                       rptr_checker, // for test
    // output logic                                                    empty_flag_checker, // for test
    output logic [DATA_WIDTH - 1:0]                                 dout
);

    logic [(NUM_LANE * BURST_LENGTH) - 1:0][DATA_WIDTH - 1:0]       buffer;
    logic [$clog2(NUM_LANE * BURST_LENGTH) - 1:0]                   wptr, rptr;
    logic                                                           empty_flag;
    logic                                                           reg_empty_flag;


    // for test
    // assign fifo_checker = buffer;
    // assign wptr_checker = wptr;
    // assign rptr_checker = rptr;
    // assign empty_flag_checker = empty_flag;

    // Output Assignment
    assign dout = buffer[rptr];
    assign valid = !reg_empty_flag;

    // Empty Flag
    assign empty_flag = (rptr == (wptr - 1'b1));

    // Input
    always_ff @(posedge clk) begin
        if(wen)
            for(int i = 0;i < NUM_LANE;i++) begin
                buffer[wptr + i] <= din[i];
            end
    end

    // Write Pointer & Read Pointer
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            wptr <= 0;
            rptr <= ~0;
        end else begin
            // Write Pointer
            if(wen) begin
                if(wptr == ~0)
                    wptr <= 0;
                else 
                    wptr <= wptr + NUM_LANE;
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

    always_ff @(posedge clk or posedge rst) begin
        reg_empty_flag <= empty_flag;
    end

endmodule