// Copyright (c) 2012 Ben Reynwar
// Released under MIT License (see LICENSE.txt)

module twiddlefactors_256 (
    input  wire                            clk,
    input  wire [6:0]          addr,
    input  wire                            addr_nd,
    output reg signed [19:0] tf_out
  );

  always @ (posedge clk)
    begin
      if (addr_nd)
        begin
          case (addr)
			
            7'd0: tf_out <= { 10'sd256,  -10'sd0 };
			
            7'd1: tf_out <= { 10'sd256,  -10'sd6 };
			
            7'd2: tf_out <= { 10'sd256,  -10'sd13 };
			
            7'd3: tf_out <= { 10'sd255,  -10'sd19 };
			
            7'd4: tf_out <= { 10'sd255,  -10'sd25 };
			
            7'd5: tf_out <= { 10'sd254,  -10'sd31 };
			
            7'd6: tf_out <= { 10'sd253,  -10'sd38 };
			
            7'd7: tf_out <= { 10'sd252,  -10'sd44 };
			
            7'd8: tf_out <= { 10'sd251,  -10'sd50 };
			
            7'd9: tf_out <= { 10'sd250,  -10'sd56 };
			
            7'd10: tf_out <= { 10'sd248,  -10'sd62 };
			
            7'd11: tf_out <= { 10'sd247,  -10'sd68 };
			
            7'd12: tf_out <= { 10'sd245,  -10'sd74 };
			
            7'd13: tf_out <= { 10'sd243,  -10'sd80 };
			
            7'd14: tf_out <= { 10'sd241,  -10'sd86 };
			
            7'd15: tf_out <= { 10'sd239,  -10'sd92 };
			
            7'd16: tf_out <= { 10'sd237,  -10'sd98 };
			
            7'd17: tf_out <= { 10'sd234,  -10'sd104 };
			
            7'd18: tf_out <= { 10'sd231,  -10'sd109 };
			
            7'd19: tf_out <= { 10'sd229,  -10'sd115 };
			
            7'd20: tf_out <= { 10'sd226,  -10'sd121 };
			
            7'd21: tf_out <= { 10'sd223,  -10'sd126 };
			
            7'd22: tf_out <= { 10'sd220,  -10'sd132 };
			
            7'd23: tf_out <= { 10'sd216,  -10'sd137 };
			
            7'd24: tf_out <= { 10'sd213,  -10'sd142 };
			
            7'd25: tf_out <= { 10'sd209,  -10'sd147 };
			
            7'd26: tf_out <= { 10'sd206,  -10'sd152 };
			
            7'd27: tf_out <= { 10'sd202,  -10'sd157 };
			
            7'd28: tf_out <= { 10'sd198,  -10'sd162 };
			
            7'd29: tf_out <= { 10'sd194,  -10'sd167 };
			
            7'd30: tf_out <= { 10'sd190,  -10'sd172 };
			
            7'd31: tf_out <= { 10'sd185,  -10'sd177 };
			
            7'd32: tf_out <= { 10'sd181,  -10'sd181 };
			
            7'd33: tf_out <= { 10'sd177,  -10'sd185 };
			
            7'd34: tf_out <= { 10'sd172,  -10'sd190 };
			
            7'd35: tf_out <= { 10'sd167,  -10'sd194 };
			
            7'd36: tf_out <= { 10'sd162,  -10'sd198 };
			
            7'd37: tf_out <= { 10'sd157,  -10'sd202 };
			
            7'd38: tf_out <= { 10'sd152,  -10'sd206 };
			
            7'd39: tf_out <= { 10'sd147,  -10'sd209 };
			
            7'd40: tf_out <= { 10'sd142,  -10'sd213 };
			
            7'd41: tf_out <= { 10'sd137,  -10'sd216 };
			
            7'd42: tf_out <= { 10'sd132,  -10'sd220 };
			
            7'd43: tf_out <= { 10'sd126,  -10'sd223 };
			
            7'd44: tf_out <= { 10'sd121,  -10'sd226 };
			
            7'd45: tf_out <= { 10'sd115,  -10'sd229 };
			
            7'd46: tf_out <= { 10'sd109,  -10'sd231 };
			
            7'd47: tf_out <= { 10'sd104,  -10'sd234 };
			
            7'd48: tf_out <= { 10'sd98,  -10'sd237 };
			
            7'd49: tf_out <= { 10'sd92,  -10'sd239 };
			
            7'd50: tf_out <= { 10'sd86,  -10'sd241 };
			
            7'd51: tf_out <= { 10'sd80,  -10'sd243 };
			
            7'd52: tf_out <= { 10'sd74,  -10'sd245 };
			
            7'd53: tf_out <= { 10'sd68,  -10'sd247 };
			
            7'd54: tf_out <= { 10'sd62,  -10'sd248 };
			
            7'd55: tf_out <= { 10'sd56,  -10'sd250 };
			
            7'd56: tf_out <= { 10'sd50,  -10'sd251 };
			
            7'd57: tf_out <= { 10'sd44,  -10'sd252 };
			
            7'd58: tf_out <= { 10'sd38,  -10'sd253 };
			
            7'd59: tf_out <= { 10'sd31,  -10'sd254 };
			
            7'd60: tf_out <= { 10'sd25,  -10'sd255 };
			
            7'd61: tf_out <= { 10'sd19,  -10'sd255 };
			
            7'd62: tf_out <= { 10'sd13,  -10'sd256 };
			
            7'd63: tf_out <= { 10'sd6,  -10'sd256 };
			
            7'd64: tf_out <= { 10'sd0,  -10'sd256 };
			
            7'd65: tf_out <= { -10'sd6,  -10'sd256 };
			
            7'd66: tf_out <= { -10'sd13,  -10'sd256 };
			
            7'd67: tf_out <= { -10'sd19,  -10'sd255 };
			
            7'd68: tf_out <= { -10'sd25,  -10'sd255 };
			
            7'd69: tf_out <= { -10'sd31,  -10'sd254 };
			
            7'd70: tf_out <= { -10'sd38,  -10'sd253 };
			
            7'd71: tf_out <= { -10'sd44,  -10'sd252 };
			
            7'd72: tf_out <= { -10'sd50,  -10'sd251 };
			
            7'd73: tf_out <= { -10'sd56,  -10'sd250 };
			
            7'd74: tf_out <= { -10'sd62,  -10'sd248 };
			
            7'd75: tf_out <= { -10'sd68,  -10'sd247 };
			
            7'd76: tf_out <= { -10'sd74,  -10'sd245 };
			
            7'd77: tf_out <= { -10'sd80,  -10'sd243 };
			
            7'd78: tf_out <= { -10'sd86,  -10'sd241 };
			
            7'd79: tf_out <= { -10'sd92,  -10'sd239 };
			
            7'd80: tf_out <= { -10'sd98,  -10'sd237 };
			
            7'd81: tf_out <= { -10'sd104,  -10'sd234 };
			
            7'd82: tf_out <= { -10'sd109,  -10'sd231 };
			
            7'd83: tf_out <= { -10'sd115,  -10'sd229 };
			
            7'd84: tf_out <= { -10'sd121,  -10'sd226 };
			
            7'd85: tf_out <= { -10'sd126,  -10'sd223 };
			
            7'd86: tf_out <= { -10'sd132,  -10'sd220 };
			
            7'd87: tf_out <= { -10'sd137,  -10'sd216 };
			
            7'd88: tf_out <= { -10'sd142,  -10'sd213 };
			
            7'd89: tf_out <= { -10'sd147,  -10'sd209 };
			
            7'd90: tf_out <= { -10'sd152,  -10'sd206 };
			
            7'd91: tf_out <= { -10'sd157,  -10'sd202 };
			
            7'd92: tf_out <= { -10'sd162,  -10'sd198 };
			
            7'd93: tf_out <= { -10'sd167,  -10'sd194 };
			
            7'd94: tf_out <= { -10'sd172,  -10'sd190 };
			
            7'd95: tf_out <= { -10'sd177,  -10'sd185 };
			
            7'd96: tf_out <= { -10'sd181,  -10'sd181 };
			
            7'd97: tf_out <= { -10'sd185,  -10'sd177 };
			
            7'd98: tf_out <= { -10'sd190,  -10'sd172 };
			
            7'd99: tf_out <= { -10'sd194,  -10'sd167 };
			
            7'd100: tf_out <= { -10'sd198,  -10'sd162 };
			
            7'd101: tf_out <= { -10'sd202,  -10'sd157 };
			
            7'd102: tf_out <= { -10'sd206,  -10'sd152 };
			
            7'd103: tf_out <= { -10'sd209,  -10'sd147 };
			
            7'd104: tf_out <= { -10'sd213,  -10'sd142 };
			
            7'd105: tf_out <= { -10'sd216,  -10'sd137 };
			
            7'd106: tf_out <= { -10'sd220,  -10'sd132 };
			
            7'd107: tf_out <= { -10'sd223,  -10'sd126 };
			
            7'd108: tf_out <= { -10'sd226,  -10'sd121 };
			
            7'd109: tf_out <= { -10'sd229,  -10'sd115 };
			
            7'd110: tf_out <= { -10'sd231,  -10'sd109 };
			
            7'd111: tf_out <= { -10'sd234,  -10'sd104 };
			
            7'd112: tf_out <= { -10'sd237,  -10'sd98 };
			
            7'd113: tf_out <= { -10'sd239,  -10'sd92 };
			
            7'd114: tf_out <= { -10'sd241,  -10'sd86 };
			
            7'd115: tf_out <= { -10'sd243,  -10'sd80 };
			
            7'd116: tf_out <= { -10'sd245,  -10'sd74 };
			
            7'd117: tf_out <= { -10'sd247,  -10'sd68 };
			
            7'd118: tf_out <= { -10'sd248,  -10'sd62 };
			
            7'd119: tf_out <= { -10'sd250,  -10'sd56 };
			
            7'd120: tf_out <= { -10'sd251,  -10'sd50 };
			
            7'd121: tf_out <= { -10'sd252,  -10'sd44 };
			
            7'd122: tf_out <= { -10'sd253,  -10'sd38 };
			
            7'd123: tf_out <= { -10'sd254,  -10'sd31 };
			
            7'd124: tf_out <= { -10'sd255,  -10'sd25 };
			
            7'd125: tf_out <= { -10'sd255,  -10'sd19 };
			
            7'd126: tf_out <= { -10'sd256,  -10'sd13 };
			
            7'd127: tf_out <= { -10'sd256,  -10'sd6 };
			
            default:
              begin
                tf_out <= 20'd0;
              end
         endcase
      end
  end
endmodule