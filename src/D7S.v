//======================
// BCD: dec (8-bit) -> 3 dígitos BCD (d3 d2 d1)
//======================
module BCD(
    input  [7:0] dec,
    output reg [3:0] d1,
    output reg [3:0] d2,
    output reg [3:0] d3
);

    reg        carry;
    reg  [7:0] dato;
    reg [11:0] cadena;

    integer i;

    always @(*) begin : dectobcd
        d1   = 4'd0;
        d2   = 4'd0;
        d3   = 4'd0;
        dato = dec;

        for (i = 0; i < 8; i = i + 1) begin
            if (d1 >= 4'd5) d1 = d1 + 4'd3;
            if (d2 >= 4'd5) d2 = d2 + 4'd3;
            if (d3 >= 4'd5) d3 = d3 + 4'd3;

            cadena = {d3, d2, d1};   // 12 bits
            carry  = dato[7];
            dato   = dato << 1;
            cadena = cadena << 1;
            cadena[0] = carry;

            d1 = cadena[3:0];
            d2 = cadena[7:4];
            d3 = cadena[11:8];
        end
    end

endmodule


//======================
// tabla: BCD -> 7 segmentos (activos en bajo por el ~)
//======================
module tabla(
    input  [3:0] d1,
    input  [3:0] d2,
    input  [3:0] d3,
    output reg [6:0] d7s1,
    output reg [6:0] d7s2,
    output reg [6:0] d7s3
);

    always @(*) begin : tabla_de_prioridad_para_d1
        case (d1)
            // ABCDEFG
            4'd1: d7s1 = ~7'b0110000;
            4'd2: d7s1 = ~7'b1101101;
            4'd3: d7s1 = ~7'b1111001;
            4'd4: d7s1 = ~7'b0110011;
            4'd5: d7s1 = ~7'b1011011;
            4'd6: d7s1 = ~7'b1011111;
            4'd7: d7s1 = ~7'b1110000;
            4'd8: d7s1 = ~7'b1111111;
            4'd9: d7s1 = ~7'b1111011;
            4'd0: d7s1 = ~7'b1111110;
            default: d7s1 = ~7'b1111110;
        endcase
    end

    always @(*) begin : tabla_de_prioridad_para_d2
        case (d2)
            // ABCDEFG
            4'd1: d7s2 = ~7'b0110000;
            4'd2: d7s2 = ~7'b1101101;
            4'd3: d7s2 = ~7'b1111001;
            4'd4: d7s2 = ~7'b0110011;
            4'd5: d7s2 = ~7'b1011011;
            4'd6: d7s2 = ~7'b1011111;
            4'd7: d7s2 = ~7'b1110000;
            4'd8: d7s2 = ~7'b1111111;
            4'd9: d7s2 = ~7'b1111011;
            4'd0: d7s2 = ~7'b1111110;
            default: d7s2 = ~7'b1111110;
        endcase
    end

    always @(*) begin : tabla_de_prioridad_para_d3
        case (d3)
            // ABCDEFG
            4'd1: d7s3 = ~7'b0110000;
            4'd2: d7s3 = ~7'b1101101;
            4'd3: d7s3 = ~7'b1111001;
            4'd4: d7s3 = ~7'b0110011;
            4'd5: d7s3 = ~7'b1011011;
            4'd6: d7s3 = ~7'b1011111;
            4'd7: d7s3 = ~7'b1110000;
            4'd8: d7s3 = ~7'b1111111;
            4'd9: d7s3 = ~7'b1111011;
            4'd0: d7s3 = ~7'b1111110;
            default: d7s3 = ~7'b1111110;
        endcase
    end

endmodule


//======================
// control: contador con divisor (buffer)
//======================
module control(
    input  clk,
    input  rst,
    output reg [7:0] count
);
    reg [25:0] buffer;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            buffer <= 26'd0;
            count  <= 8'd0;
        end
        else if (buffer == 26'd9) begin
            buffer <= 26'd0;
            count  <= count + 8'd1;
        end
        else begin
            buffer <= buffer + 26'd1;
        end
    end

endmodule


//======================
// repetidor: multiplexa 3 displays
//======================
module repetidor(
    input  clk,
    input  rst,
    input  [6:0] d7s1,
    input  [6:0] d7s2,
    input  [6:0] d7s3,
    output reg [2:0] transistor,
    output reg [6:0] d7sp
);
    reg [1:0]  contador;
    reg [25:0] buffer;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            transistor <= 3'b000;
            d7sp       <= 7'b0000001;
            contador   <= 2'd0;
            buffer     <= 26'd0;
        end
        else if (buffer == 26'd3) begin
            buffer <= 26'd0;
            case (contador)
                2'd0: begin
                    transistor <= 3'b110;
                    d7sp       <= d7s1;
                    contador   <= 2'd1;
                end
                2'd1: begin
                    transistor <= 3'b101;
                    d7sp       <= d7s2;
                    contador   <= 2'd2;
                end
                2'd2: begin
                    transistor <= 3'b011;
                    d7sp       <= d7s3;
                    contador   <= 2'd0;
                end
                default: begin
                    transistor <= 3'b000;
                    d7sp       <= 7'b0000001;
                    contador   <= 2'd0;
                end
            endcase
        end
        else begin
            buffer <= buffer + 26'd1;
        end
    end

endmodule


//======================
// Top: D7S
//======================
module D7S(
    input  clk,
    input  rst,
    output [2:0] transistor,
    output [6:0] d7sp
);

    wire [7:0] middle_count;
    wire [3:0] middle_d1;
    wire [3:0] middle_d2;
    wire [3:0] middle_d3;
    wire [6:0] middle_d7s1;
    wire [6:0] middle_d7s2;
    wire [6:0] middle_d7s3;

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
        .d7s3(middle_d7s3)   // <-- corregido
    );

    repetidor repetidor1(
        .clk(clk),
        .rst(rst),
        .d7s1(middle_d7s1),
        .d7s2(middle_d7s2),
        .d7s3(middle_d7s3),
        .transistor(transistor),
        .d7sp(d7sp)
    );

endmodule
