module traffic_light_fsm (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [2:0] LA, 
    output logic [2:0] LB
);

    localparam [2:0] GREEN  = 3'b001;
    localparam [2:0] YELLOW = 3'b010;
    localparam [2:0] RED    = 3'b100;

    typedef enum logic [1:0] {
        S0, S1, S2, S3
    } state_t;

    state_t current_state, next_state;
    logic [2:0] timer;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
            timer <= 3'b000;
        end else begin
            if (current_state != next_state)
                timer <= 3'b000;
            else if (timer < 3'd5)
                timer <= timer + 1'b1;
            
            current_state <= next_state;
        end
    end

    always_comb begin
        case (current_state)
            S0: next_state = (TAORB) ? S0 : S1;
            S1: next_state = (timer >= 3'd4) ? S2 : S1;
            S2: next_state = (~TAORB) ? S2 : S3;
            S3: next_state = (timer >= 3'd4) ? S0 : S3;
            default: next_state = S0;
        endcase
    end

    always_comb begin
        case (current_state)
            S0: begin LA = GREEN;  LB = RED;    end
            S1: begin LA = YELLOW; LB = RED;    end
            S2: begin LA = RED;    LB = GREEN;  end
            S3: begin LA = RED;    LB = YELLOW; end
            default: begin LA = RED; LB = RED;  end
        endcase
    end

endmodule