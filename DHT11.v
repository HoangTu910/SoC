module DHT11 (
    // Avalon MM Interface
    input clk,           // Clock
    input reset,         // Reset
    input [3:0] address, // Address from Avalon bus
    input write,         // Write enable signal
    input read,          // Read enable signal
    input [31:0] writedata, // Data from master
    output reg [31:0] readdata, // Data to master
    
    // DHT11 Interface
    inout data_pin           // Bidirectional pin connected to DHT11 DATA
);

    // Internal signals
    reg [7:0] temperature;    // Temperature value
    reg valid;                // Valid flag
    reg [31:0] counter;       // Counter for timing
    reg [5:0] bit_index;      // Bit index
    reg [39:0] data_buffer;   // Buffer to store 40-bit data
    reg [3:0] state;          // FSM state
    
    // Pin control
    reg data_dir;             // 0 = input, 1 = output
    reg data_out;             // Output value for the data pin

    assign data_pin = data_dir ? data_out : 1'bz; // Bidirectional pin logic

    // FSM states
    localparam IDLE          = 4'b0000,
               START_SIGNAL  = 4'b0001,
               WAIT_RESPONSE = 4'b0010,
               READ_DATA     = 4'b0011,
               PROCESS_DATA  = 4'b0100;

    // Timing parameters (50 MHz clock assumed)
    localparam START_TIME = 900000;      // 18ms start signal
    localparam RESPONSE_TIME = 4000;    // 80us response window
    localparam BIT_DURATION = 2000;     // ~50us per bit

    // FSM Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            state <= IDLE;
            temperature <= 0;
            valid <= 0;
            data_dir <= 0;
            data_out <= 1;
            bit_index <= 0;
            data_buffer <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 0;
                    counter <= 0;
                    data_dir <= 1;     // Set pin as output
                    data_out <= 1;     // Pin high
                    state <= START_SIGNAL;
                end

                START_SIGNAL: begin
                    if (counter < START_TIME) begin
                        data_out <= 0;  // Pull pin low
                        counter <= counter + 1;
                    end else begin
                        data_out <= 1;  // Release pin
                        data_dir <= 0;  // Switch to input mode
                        counter <= 0;
                        state <= WAIT_RESPONSE;
                    end
                end

                WAIT_RESPONSE: begin
                    if (counter < RESPONSE_TIME) begin
                        counter <= counter + 1;
                        if (!data_pin) begin // Sensor pulls low
                            counter <= 0;
                            state <= READ_DATA;
                        end
                    end else begin
                        state <= IDLE; // Timeout
                    end
                end

                READ_DATA: begin
                    if (counter < BIT_DURATION) begin
                        counter <= counter + 1;
                        if (counter == BIT_DURATION / 2) begin
                            data_buffer[39 - bit_index] <= data_pin; // Read bit
                        end
                    end else begin
                        counter <= 0;
                        bit_index <= bit_index + 1;
                        if (bit_index == 39) begin
                            state <= PROCESS_DATA;
                        end
                    end
                end

                PROCESS_DATA: begin
                    temperature <= data_buffer[31:24]; // Extract temperature
                    valid <= 1;  // Indicate valid data
                    state <= IDLE;
                end
            endcase
        end
    end

    // Avalon MM Read/Write Interface
    always @(*) begin
        if (read) begin
            case (address)
                4'b0000: readdata = {24'b0, temperature}; // Temperature
                4'b0001: readdata = {31'b0, valid};       // Valid flag
                default: readdata = 32'b0;
            endcase
        end else begin
            readdata = 32'b0;
        end
    end

    // Write logic (if needed for configuration)
    always @(posedge clk) begin
        if (write) begin
            case (address)
                // Add any writable registers here if needed
                default: ;
            endcase
        end
    end
endmodule