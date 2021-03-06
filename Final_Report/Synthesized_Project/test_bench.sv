`timescale 1ns/100ps
//NOTE: you need to compile SystemVerilogCSP.sv as well
`define send_count 50
module data_generator (interface data_out);
  parameter FL = 0; //ideal environment
  parameter MYID = 0;
  logic [3:0] addr;
  //logic [3:0] starting_addr;
  logic [3:0] data;
  logic [16:0] counter;
  logic [7:0] SendValue=0;

  initial
  begin 
    counter = 0;
    #500;
    forever begin
        if (counter < `send_count) begin
        addr = $random() % (2**4);
        data = $random() % (2**4);
        while(MYID == addr)
        begin
          addr = $random() % (2**4);
        end
        #FL;

        SendValue = {data,addr};
         
        //Communication action Send is about to start
        data_out.Send(SendValue);

        // Push back data for verification
        tb_module.time_queue[int'(addr)].push_back($time);
        tb_module.data_queue[int'(addr)].push_back(SendValue);
        //$display("Starting to send to %d with %b", addr , SendValue);

        // Increment global counter
        tb_module.total_send += 1;
        $display("Start module data_gen and time is %d, Send count: %d", $time, tb_module.total_send); 
        counter += 1; // local counter
        end
      #3;
    end
  end
endmodule

//Sample data_bucket module
module data_bucket_top_tb (interface r);
  parameter WIDTH = 8;
  parameter BL = 0; //ideal environment
  parameter MYID = 0;
  logic [WIDTH-1:0] ReceiveValue = 0;
  //Variables added for performance measurements
  real time_started, time_spent_during_travel;
  int queue_check;

  initial
  begin
    #500;
    forever begin
      //Save the simulation time when Receive starts
      r.Receive(ReceiveValue);
      // Global Receive Count
      tb_module.receive_count = tb_module.receive_count + 1;
      // Global Cycle Count
      tb_module.cycle_queue[MYID] += 1;
      tb_module.throughput[MYID] = real'(tb_module.cycle_queue[MYID]) / real'($time);

      // Check the receive data if it matched
      for (int i=0; i < tb_module.data_queue[MYID].size(); i++) begin
        if (tb_module.data_queue[MYID][i] == ReceiveValue) begin
          queue_check = i;
        end
      end
      if (tb_module.data_queue[MYID][queue_check] == ReceiveValue) begin
        //$display("\tData matched");
        time_started = tb_module.time_queue[MYID][queue_check];
        time_spent_during_travel = $time - time_started ;
        tb_module.sum_travel_time[MYID] += time_spent_during_travel;
        tb_module.time_queue[MYID].delete(queue_check);

        tb_module.data_queue[MYID].delete(queue_check);
      end
        $display("Data bucket [%d] is receiving %b | Receive count: %d 
      Bucket Avg Cycle Time: %f, Sum Cycles: %f ", MYID, 
      ReceiveValue, tb_module.receive_count,
       (tb_module.sum_travel_time[MYID]/tb_module.cycle_queue[MYID]), tb_module.sum_travel_time[MYID]);


      #BL;
      end
  end
endmodule

module tb_module; 

  logic error_flag;
  reg [15:0] time_queue [16] [$];
  reg [7:0] data_queue [16] [$];
  integer cycle_queue [16];
  real sum_travel_time [16];
  real throughput [16];
  real total_throughput;
  real total_travel_time;
  integer receive_count;
  integer total_send;
  //integer fp_result;
  //integer fp_original;


  e1ofN_M #(.N(2), .M(8)) intf2core  [15:0] (); 
  e1ofN_M #(.N(2), .M(8)) db_intf[15:0]  (); 



  data_generator #(.MYID(0)) dg0(intf2core[0]);
  data_generator #(.MYID(1)) dg1(intf2core[1]);
  data_generator #(.MYID(2)) dg2(intf2core[2]);
  data_generator #(.MYID(3)) dg3(intf2core[3]);
  data_generator #(.MYID(4)) dg4(intf2core[4]);
  data_generator #(.MYID(5)) dg5(intf2core[5]);
  data_generator #(.MYID(6)) dg6(intf2core[6]);
  data_generator #(.MYID(7)) dg7(intf2core[7]);
  data_generator #(.MYID(8)) dg8(intf2core[8]);
  data_generator #(.MYID(9)) dg9(intf2core[9]);
  data_generator #(.MYID(10)) dg10(intf2core[10]);
  data_generator #(.MYID(11)) dg11(intf2core[11]);
  data_generator #(.MYID(12)) dg12(intf2core[12]);
  data_generator #(.MYID(13)) dg13(intf2core[13]);
  data_generator #(.MYID(14)) dg14(intf2core[14]);
  data_generator #(.MYID(15)) dg15(intf2core[15]);


  top top1 (.dg_in(intf2core[15:0]), .db_out(db_intf[15:0]));
  data_bucket_top_tb #(.MYID(0)) db0000(db_intf[0]);
  data_bucket_top_tb #(.MYID(1)) db0001(db_intf[1]);
  data_bucket_top_tb #(.MYID(2)) db0010(db_intf[2]);
  data_bucket_top_tb #(.MYID(3)) db0011(db_intf[3]);
  data_bucket_top_tb #(.MYID(4)) db0100(db_intf[4]);
  data_bucket_top_tb #(.MYID(5)) db0101(db_intf[5]);
  data_bucket_top_tb #(.MYID(6)) db0110(db_intf[6]);
  data_bucket_top_tb #(.MYID(7)) db0111(db_intf[7]);

  data_bucket_top_tb #(.MYID(8)) db1000(db_intf[8]);
  data_bucket_top_tb #(.MYID(9)) db1001(db_intf[9]);
  data_bucket_top_tb #(.MYID(10)) db1010(db_intf[10]);
  data_bucket_top_tb #(.MYID(11)) db1011(db_intf[11]);
  data_bucket_top_tb #(.MYID(12)) db1100(db_intf[12]);
  data_bucket_top_tb #(.MYID(13)) db1101(db_intf[13]);
  data_bucket_top_tb #(.MYID(14)) db1110(db_intf[14]);
  data_bucket_top_tb #(.MYID(15)) db1111(db_intf[15]);


initial 
  begin 
    // initialize 
    receive_count = 0;
    error_flag = 0;
    total_send = 0;
    total_travel_time = 0;
    for (int i=0; i < 16; i++)begin
      cycle_queue[i] = 0;
      sum_travel_time[i] = 0;
      throughput[i] = 0;
    end
    #400;
    $display("Waiting for receivers");
    wait ((receive_count > 0) && (receive_count == total_send));
    $display("Received: %d",receive_count);
    // fp_result = $fopen("result_output.txt","w");
    $display("Received all data, perform final check up");
    for (int i =0; i < 16; i++)begin
      // Loop through data queue, should have 0 element left
      $display("Checking data_queue[%d].size: %d", i, data_queue[i].size());
      // If any of the queue has non-zero, set error flag
      if (data_queue[i].size() != 0) begin
        error_flag = 1;
      end
    end
    for (int i =0; i < 16; i++)begin
      // Print Cycle Time
      total_travel_time += (sum_travel_time[i]/cycle_queue[i]) ;
      $display("\tNode[%d]: Average Cycle Time: %f", i, (sum_travel_time[i]/cycle_queue[i]));
    end
    for (int i =0; i < 16; i++)begin
      // Print Throughput
      total_throughput += throughput[i];
      $display("\tNode[%d]: Average Throughput: %f", i, throughput[i]);
    end
    $display("\nOverall Average Cycle Time:%f\nAverage Throughput\n", total_travel_time/16, total_throughput/16);


    if (error_flag == 1) 
      $display(" =====   Error ===== ");
    else
      $display(" ===== Test Successful ======\n Total Sent: %d Total Received: %d", total_send, receive_count);

  end 

endmodule 