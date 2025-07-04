`timescale 1ns/1ps
module lpc_analysis (
    input clk,
    input rst,
    input valid,      // New signal: indicates when a new sample is available
    input signed [15:0] sample_in,
    output reg signed [15:0] residual_out
);

    // Internal registers for past samples
    reg signed [15:0] past_samples [0:9];
    integer i;

    // LPC coefficients
    reg signed [15:0] lpc_coeffs [0:9];

    // Predicted sample value
    reg signed [31:0] predicted;

    // Initialize LPC coefficients
    initial begin
        lpc_coeffs[0] = -46;
        lpc_coeffs[1] = 73;
        lpc_coeffs[2] = -91;
        lpc_coeffs[3] = 90;
        lpc_coeffs[4] = -73;
        lpc_coeffs[5] = 48;
        lpc_coeffs[6] = -27;
        lpc_coeffs[7] = 15;
        lpc_coeffs[8] = -6;
        lpc_coeffs[9] = 1;
    end

    // Prediction and residual calculation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1) begin
                past_samples[i] <= 0;
            end
            residual_out <= 0;
            predicted <= 0;
        end else if (valid) begin
            // Shift in the new sample
            for (i = 9; i > 0; i = i - 1) begin
                past_samples[i] <= past_samples[i-1];
            end
            past_samples[0] <= sample_in;

            // Reset predicted before accumulation
            predicted = 0;
            for (i = 0; i < 10; i = i + 1) begin
                predicted = predicted + (past_samples[i] * lpc_coeffs[i]);
            end
            $display("predicted=%d",predicted);

            // Calculate the residual
            residual_out <= sample_in - (predicted >>> 4); // Scale down to 16 bits
            $display("LPC Computation: sample_in=%d, scaled_predicted=%d, residual_out=%d", sample_in, (predicted >>> 4), residual_out);
        end
    end

endmodule
