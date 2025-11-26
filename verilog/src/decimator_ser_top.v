/*
 * Copyright (c) 2025 Michael Koefinger
 * SPDX-License-Identifier: Apache-2.0
 */
// 8-Stage Half-Band Filter Decimator using Saramaki HBFs' with a serial output (shift register)

`include "./dec_top.v"

module decimator_ser_top(
    input wire      clk,
    input wire      rst_b,
    input wire      data_i,
    output wire     data_o,         // Serial Data Stream
    output wire      frame_sync     // High while data is being transmitted
);
    wire data_i_sync_1, data_i_sync_2;
    wire busy;
    wire [21:0] filter_o;
    wire valid_strobe;

    synchronizer #(.N_STAGES(3), .DATA_W(1)) u_sync_2 (
        .clk        (clk),
        .rst_b      (rst_b),
        .sync_i     (data_i),
        .sync_o_1   (data_i_sync_1),
        .sync_o_2   (data_i_sync_2)
    );

    decimator_top u_dec_256_22b (
        .clk_fs         (clk),
        .rst_b          (rst_b),
        .data_in        (data_i_sync_2),  
        .data_out       (filter_o),
        .valid_strobe   (valid_strobe)
    );

    dec_serializer_22b u_ser_22b (
        .clk            (clk),
        .rst_b          (rst_b),
        .valid_strobe   (valid_strobe),
        .data_i         (filter_o),  
        .data_o         (data_o),
        .frame_sync     (frame_sync),
        .busy           (busy)
    );
    
endmodule
