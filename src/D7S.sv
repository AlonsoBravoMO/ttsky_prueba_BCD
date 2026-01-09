module BCD(
    input logic [7:0] dec,
    output logic [3:0] d1,
    output logic [3:0] d2,
    output logic [3:0] d3
    );

    logic carry;
    logic [7:0] dato;
    logic [11:0] cadena;

    always_comb begin : dectobcd

    d1 = 4'd0;
    d2 = 4'd0;
    d3 = 4'd0;
    dato = dec;

    for (int i = 0; i < 8; i++ ) begin

        if (d1 >= 4'd5) begin
            d1 = d1 + 4'd3;
        end

        if (d2 >= 4'd5) begin
            d2 = d2+4'd3;
        end

        if (d3 >= 4'd5) begin
            d3 = d3 + 4'd3;
        end
        cadena = {d3, d2, d1}; // 0000 0000 0000 
        carry = dato[7];        // 7654 3210 carry = 7
        dato = dato << 1;        // dato = 6543 2100 
        cadena = cadena << 1;  // 0000 0000 0000
        cadena[0] = carry;     // 0000 0000 0007
        d1 = cadena[3:0];
        d2 = cadena[7:4];
        d3 = cadena[11:8];
    end     
    end
endmodule

module tabla(
    input logic [3:0] d1,
    input logic [3:0] d2,
    input logic [3:0] d3,
    output logic [6:0] d7s1,
    output logic [6:0] d7s2,
    output logic [6:0] d7s3 
    );

    always_comb begin : tabla_de_prioridad_para_d1

    case (d1)
                    //ABCDEFG++
        4'd1: d7s1 =~7'b0110000;
        4'd2: d7s1 =~7'b1101101;
        4'd3: d7s1 =~7'b1111001;
        4'd4: d7s1 =~7'b0110011;
        4'd5: d7s1 =~7'b1011011;
        4'd6: d7s1 =~7'b1011111;
        4'd7: d7s1 =~7'b1110000;
        4'd8: d7s1 =~7'b1111111;
        4'd9: d7s1 =~7'b1111011;
        4'd0: d7s1 =~7'b1111110;
        default: d7s1 = ~7'b1111110;
    endcase

    end


    always_comb begin : tabla_de_prioridad_para_d2

    case (d2)
                    //ABCDEFG++
        4'd1: d7s2 =~7'b0110000;
        4'd2: d7s2 =~7'b1101101;
        4'd3: d7s2 =~7'b1111001;
        4'd4: d7s2 =~7'b0110011;
        4'd5: d7s2 =~7'b1011011;
        4'd6: d7s2 =~7'b1011111;
        4'd7: d7s2 =~7'b1110000;
        4'd8: d7s2 =~7'b1111111;
        4'd9: d7s2 =~7'b1111011;
        4'd0: d7s2 =~7'b1111110;
        default: d7s2 = ~7'b1111110;
    endcase

    end


    always_comb begin : tabla_de_prioridad_para_d3

    case (d3)
                    //ABCDEFG++
        4'd1: d7s3 =~7'b0110000;
        4'd2: d7s3 =~7'b1101101;
        4'd3: d7s3 =~7'b1111001;
        4'd4: d7s3 =~7'b0110011;
        4'd5: d7s3 =~7'b1011011;
        4'd6: d7s3 =~7'b1011111;
        4'd7: d7s3 =~7'b1110000;
        4'd8: d7s3 =~7'b1111111;
        4'd9: d7s3 =~7'b1111011;
        4'd0: d7s3 =~7'b1111110;
        default: d7s3 =~7'b1111110;
    endcase

    end

endmodule

module control(
    input  logic clk,
    input  logic rst,
    output logic [7:0] count
);
    logic [25:0] buffer;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            buffer <= 26'd0;
            count  <= 8'd0;
        end
        else if (buffer == 9) begin
            buffer <= 26'd0;
            count  <= count + 1;
        end
        else begin
            buffer <= buffer + 1;
        end
    end

endmodule

module repetidor(
    input logic clk,
    input logic rst,
    input logic [6:0] d7s1,
    input logic [6:0] d7s2,
    input logic [6:0] d7s3, 
    output logic [2:0] transistor,
    output logic [6:0] d7sp
);
    logic [1:0] contador;
    logic [25:0] buffer; 

    always_ff @(posedge clk or negedge rst) begin

        if (!rst) begin
        transistor <= 3'b000;
        d7sp <= 7'b0000001;
        contador <= 2'd0;
        buffer <= 26'd0;   
        end

        else if (buffer == 3) begin

            buffer <= 0;
            case (contador)
            2'd0:begin
                transistor <= 3'b110;
                d7sp <= d7s1;
                contador <= 2'd1;
            end
            2'd1:begin
                transistor <= 3'b101;
                d7sp <= d7s2;
                contador <= 2'd2;
            end
            2'd2:begin
                transistor <= 3'b011;
                d7sp <= d7s3;
                contador <= 2'd0;
            end            
            endcase            
        end
        
        else begin
        buffer <= buffer + 1;
        end
    end
endmodule


module D7S(
    input logic clk,
    input logic rst,
    output logic [2:0] transistor,
    output logic [6:0] d7sp
    );
   
    logic [7:0] middle_count;
    logic [3:0] middle_d1;
    logic [3:0] middle_d2;
    logic [3:0] middle_d3;
    logic [6:0] middle_d7s1;
    logic [6:0] middle_d7s2;
    logic [6:0] middle_d7s3;

    control control1(
        .clk(clk),
        .rst(rst),
        .count(middle_count)
    );

    BCD BCD1(
        .dec(middle_count),
        .d1(middle_d1),
        .d2(middle_d2),
        .d3(middle_d3)
    );

    tabla tabla1(
        .d1(middle_d1),
        .d2(middle_d2),
        .d3(middle_d3),
        .d7s1(middle_d7s1),
        .d7s2(middle_d7s2),
        .d7s3(middle_d7s3)
    );

    repetidor repetidor1 (
        .clk(clk),
        .rst(rst),
        .d7s1(middle_d7s1),
        .d7s2(middle_d7s2),
        .d7s3(middle_d7s3),
        .d7sp(d7sp),
        .transistor(transistor)
    );

endmodule




