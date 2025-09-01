`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2025 18:10:00
// Design Name: 
// Module Name: an
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module an(
    input clk,
    input [1:0] RUDI,
    input reset,
    input [16:1] mr_adv_ability,
    input mr_an_enable,
    input [15:0] rx_Config_Reg,
    output reg mr_page_rx,
    output reg mr_an_complete,
    output reg mr_np_loaded,
    output reg [15:0] tx_Config_Reg,
    output reg [1:0] xmit,
    output reg toggle_tx,
    output reg toggle_rx,
    output reg np_rx,
    output reg resolve_priority
    );
    localparam [2:0]
        AN_ENABLE              = 3'd0,
        AN_RESTART             = 3'd1,
        AN_DISABLE_LINK_OK     = 3'd2,
        ABILITY_DETECT         = 3'd3,
        ACKNOWLEDGE_DETECT     = 3'd4,
        COMPLETE_ACKNOWLEDGE   = 3'd5,
        IDLE_DETECT            = 3'd6,
        LINK_OK                = 3'd7;
        
        reg start_link_timer;
        reg link_timer_done;
        reg [2:0] state,next_state;
        reg next_mr_page_rx;
        reg next_mr_an_complete;
        reg [15:0] next_tx_Config_Reg;
        reg [1:0] next_xmit;
        reg [31:0] timer;
        reg next_start_link_timer;
        reg next_toggle_tx;
        reg next_mr_np_loaded;
        reg next_toggle_rx;
        reg next_np_rx;
        reg next_resolve_priority;
        
         //////required functions for ability, consistency, acknowledge and idle match ////////
       reg [15:0] reg_fun [2:0];
       reg [1:0] rudi_reg [2:0];
       
       wire ability_match;
       wire same_hi_abm;
       wire same_low_abm;
       
       wire acknowledge_match;
       wire same_acm;
       
       wire consistency_match;
       
       wire idle_match;
       always @(posedge clk) begin
           if (reset) begin
               reg_fun[0] <= 16'd0;
               reg_fun[1] <= 16'd0;
               reg_fun[2] <= 16'd0;
           end else if (rx_Config_Reg != 16'd0) begin
               reg_fun[0] <= reg_fun[1];
               reg_fun[1] <= reg_fun[2];
               reg_fun[2] <= rx_Config_Reg;
          end
      end
      
      always @(posedge clk) begin
           if (reset) begin
               rudi_reg[2] <= 2'b00;               
               rudi_reg[1] <= 2'b00;
               rudi_reg[0] <= 2'b00;
           end else begin
               rudi_reg[0] <= rudi_reg[1];
               rudi_reg[1] <= rudi_reg[2];
               rudi_reg[2] <= RUDI;
          end
      end

      assign same_hi_abm  = (reg_fun[0][15] == reg_fun[1][15]) && (reg_fun[1][15] == reg_fun[2][15]);
      assign same_low_abm = (reg_fun[0][13:0] == reg_fun[1][13:0]) && (reg_fun[1][13:0] == reg_fun[2][13:0]);
      assign ability_match = same_hi_abm && same_low_abm;
      
      assign same_acm  = (reg_fun[0][14] == reg_fun[1][14]) && (reg_fun[1][14] == reg_fun[2][14]);
      assign acknowledge_match = same_acm;
      
      assign consistency_match = (ability_match && acknowledge_match);

      assign idle_match = ((rudi_reg[0] == 2'b01) && (rudi_reg[1] == 2'b01) && (rudi_reg[2] == 2'b01));
       /////////////////////////////////////////////
        always@(posedge clk) begin
            link_timer_done <= 0;
            if(reset) begin
                timer <= 0;
                link_timer_done <= 0;
            end else begin
                if(start_link_timer) begin
                    if(timer == 32'd1250000) begin
                        timer <= 0;
                        link_timer_done <= 1;
                    end else begin
                        timer <= timer + 1;
                    end
                 end else begin
                    timer <= 0;
                 end   
            end
        end
        
        always@(posedge clk) begin
            if(reset) begin
                state <= AN_ENABLE;
                start_link_timer <= 0;
                mr_page_rx <= 0;
                mr_np_loaded <= 0;
                mr_an_complete <= 0;
                tx_Config_Reg <= 0;
                xmit <= 2'b00;
                np_rx <= 0;
                toggle_tx <= 0;
                toggle_rx <= 0;
                resolve_priority <= 0;
            end else begin
                state <= next_state;
                start_link_timer <= next_start_link_timer;
                mr_page_rx <= next_mr_page_rx;
                mr_an_complete <= next_mr_an_complete;
                tx_Config_Reg <= next_tx_Config_Reg;
                xmit <= next_xmit;
                mr_np_loaded <= next_mr_np_loaded;
                toggle_tx <= next_toggle_tx;
                toggle_rx <= next_toggle_rx;
                np_rx <= next_np_rx;
                resolve_priority <= next_resolve_priority;
            end
        end
        
        always@(*) begin
            next_state = state;
            next_mr_page_rx = mr_page_rx;
            next_mr_an_complete = mr_an_complete;
            next_tx_Config_Reg = tx_Config_Reg;
            next_xmit = xmit;
            next_start_link_timer = 0;
            next_mr_np_loaded = mr_np_loaded;
            next_toggle_tx = toggle_tx;
            next_toggle_rx = toggle_rx;
            next_np_rx = np_rx;
            next_resolve_priority = 0;
            case(state)
                AN_ENABLE: begin
                    next_mr_page_rx = 0;
                    next_mr_an_complete = 0;
                    if(mr_an_enable) begin
                        next_tx_Config_Reg = 0;
                        next_xmit = 0;
                        next_state = AN_RESTART;   
                    end else begin
                        next_xmit = 1;
                        next_state = AN_DISABLE_LINK_OK;   
                    end                       
                end
                
                AN_RESTART: begin
                    next_mr_np_loaded = 0;
                    next_tx_Config_Reg = 0;
                    next_xmit = 0;
                    next_start_link_timer = 1;
                    if(link_timer_done) begin
                        next_state = ABILITY_DETECT;
                    end
                end
                
                AN_DISABLE_LINK_OK: begin
                    next_xmit = 2'b10;
                    if(mr_an_enable) begin
                        next_state = AN_ENABLE;
                    end
                end
                
                ABILITY_DETECT: begin
                    next_toggle_tx = mr_adv_ability[12];
                    next_tx_Config_Reg[15] = mr_adv_ability[16];
                    next_tx_Config_Reg[14] = 0;
                    next_tx_Config_Reg[13:0] = mr_adv_ability[14:1];
                    if(ability_match && rx_Config_Reg != 0) begin
                        next_state = ACKNOWLEDGE_DETECT;
                    end
                end
                
                ACKNOWLEDGE_DETECT: begin
                    next_tx_Config_Reg[14] = 1;
                    if((acknowledge_match && !consistency_match) || (ability_match && rx_Config_Reg == 0)) begin
                        next_state = AN_ENABLE;    
                    end else if(acknowledge_match && consistency_match) begin
                        next_state = COMPLETE_ACKNOWLEDGE; 
                    end
                end
                
                COMPLETE_ACKNOWLEDGE: begin
                    next_start_link_timer = 1;
                    next_toggle_tx = !toggle_tx;
                    next_toggle_rx = rx_Config_Reg[11];
                    next_np_rx = rx_Config_Reg[15];
                    next_mr_page_rx = 1;
                    if(ability_match && rx_Config_Reg == 0) begin
                        next_state = AN_ENABLE;
                    end else if(link_timer_done && (!ability_match || rx_Config_Reg != 0)) begin
                        next_state = IDLE_DETECT;
                    end
                end
                
                IDLE_DETECT: begin
                    next_start_link_timer = 1;
                    next_xmit = 2'b01;
                    next_resolve_priority = 1;
                    if(ability_match && rx_Config_Reg == 0) begin
                        next_state = AN_ENABLE;
                    end else if(idle_match && link_timer_done) begin
                        next_state = LINK_OK;
                    end
                end
                
                LINK_OK: begin
                    next_xmit = 2'b10;
                    next_mr_an_complete = 1;
                    next_resolve_priority = 1;
                    if(ability_match) begin
                        next_state = AN_ENABLE;
                    end
                end
            endcase
        end
       
      
endmodule
