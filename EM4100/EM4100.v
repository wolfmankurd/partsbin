module EM4100(
	      input clk,
	      input tx,
	      input [39:0] data,
	      output q
	      );
   
   reg [53:0] 	     txdata;
   localparam STATE_HEAD = 1;
   localparam STATE_DATA = 2;
   localparam STATE_STOP = 4;
   localparam STATE_PAUSE = 8;
   reg [8 - 1:0] STATE;

   reg [$clog2(54 + 1) - 1: 0] counter;
   
   wire 	  CP0, CP1, CP2, CP3;
   reg 			     out;
   reg 			     sending;
   
   always @ (posedge clk) begin
      if (!tx) begin
	 counter <= 0;
	 STATE <= STATE_HEAD;
	 out <= 0;
	 sending <= 0;
	 txdata[3:0] <= data[3:0];
	 txdata[4] <= ^data[3:0];
	 txdata[8:5] <= data[7:4];
	 txdata[9] <= ^data[7:4];
	 txdata[13:10] <= data[11:8];
	 txdata[14] <= ^data[11:8];
	 txdata[18:15] <= data[14:11];
	 txdata[19] <= ^data[14:11];
	 txdata[23:20] <= data[18:15];
	 txdata[24] <= ^data[18:15];
	 txdata[28:25] <= data[21:18];
	 txdata[29] <= ^data[21:18];
	 txdata[33:30] <= data[24:21];
	 txdata[34] <= ^data[24:21];
	 txdata[38:35] <= data[27:24];
	 txdata[39] <= ^data[27:24];
	 txdata[43:40] <= data[31:28];
	 txdata[44] <= ^data[31:28];
	 txdata[48:45] <= data[35:32];
	 txdata[49] <= ^data[35:32];
	 txdata[50] <= CP0;
	 txdata[51] <= CP1;
	 txdata[52] <= CP2;
	 txdata[53] <= CP3;
      end
      else begin
	 counter <= counter + 1;
	 case (STATE)
	    STATE_HEAD: begin
	       sending <= 1;
	       out <= 1;
	       if (counter == 9) begin
		  counter <= 0;
		  STATE <= STATE_DATA;
	       end
	    end
	   STATE_DATA: begin
	      if (counter == 40) begin
		 counter <= 0;
		 STATE <= STATE_STOP;
	      end
	      out <= txdata[counter];
	   end
	   STATE_STOP: begin
	      out <= 0;
	      if (counter == 2) begin
		 counter <= 0;
		 STATE <= STATE_PAUSE;
	      end
	   end
	   STATE_PAUSE: begin
	      sending <= 0;
	      if (counter == 8) begin
		 counter <= 0;
		 STATE <= STATE_HEAD;
	      end
	   end
	 endcase // case (STATE)
      end // else: !if(!tx)
   end // always @ (posedge clk)

   assign CP0 = data[0] ^ data[4] ^ data[8] ^ data[12] ^ data[16] ^ data[20] ^ data[24] ^ data[28] ^ data[32] ^ data[36];
   assign CP1 = data[1] ^ data[5] ^ data[9] ^ data[13] ^ data[17] ^ data[21] ^ data[25] ^ data[29] ^ data[33] ^ data[37];
   assign CP2 = data[2] ^ data[6] ^ data[10] ^ data[14] ^ data[18] ^ data[22] ^ data[26] ^ data[30] ^ data[34] ^ data[38];
   assign CP3 = data[3] ^ data[7] ^ data[11] ^ data[15] ^ data[19] ^ data[23] ^ data[27] ^ data[31] ^ data[35] ^ data[39];
   assign q = (tx & sending) ? out ^ clk : 1'bZ;
endmodule // em4100
