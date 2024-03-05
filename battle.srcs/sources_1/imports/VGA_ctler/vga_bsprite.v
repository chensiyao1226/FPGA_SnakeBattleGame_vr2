module vga_bsprite (
        input clk,
        input clr,
        input [9:0] hc,
        input [9:0] vc,
        input [11:0] data,
        //input [7:0] sw,
        input [4:0] key,
        input vga_en,
        output [15:0] rom_addr, //  
        output reg [3:0] RED, // 红色
        output reg [3:0] GRN, // 绿色
        output reg [3:0] BLU,  // 蓝色
        output reg [15:0] data_out
);

parameter hbp     = 10'b0010010000; // 行显示后沿， 144?128+16?  横坐标起始坐标
parameter vbp     = 10'b0000011111; // 场显示后沿， 31?2+29?  纵坐标起始坐标
parameter W = 18,Wb=100;
parameter H = 18,Hb=50;


reg [3:0] dir=2;//0右 改为12个方向
reg [5:0] ang=0;
//dir 更新
reg [9:0] bodyx[0:20];
reg [9:0] bodyy[0:20];//  相应根据此显示
//reg sprion



reg spriteon;//RGB未用
reg head,body;//head标记用于在碰撞时区分
reg Bclk=1'b1;
reg [25:0] clkCount=0;
reg [4:0] i,l=2;
reg death=0;
reg [5:0] dx[0:11];
reg [5:0] dy[0:11];
reg [2:0] lc=0;//1撞到对方身体 2吃到苹果
reg Llock=0;

//
reg spriteon2,head2,body2;
reg [4:0] l2=2;
reg [9:0] bodyx2[0:20];
reg [9:0] bodyy2[0:20];
reg [5:0] ang2=6;
reg [3:0] dir2=2;
reg death2=0;
reg [2:0] lc2=0;//1撞到对方身体 2吃到苹果
reg Llock2=0;


reg [9:0] appx=200,appy=200;
reg [9:0] blkx[0:5];
reg [9:0] blky[0:5];
reg appon=0,blkon=0;
reg apprefresh=0,blkrefresh=0,bonrefresh=1;
reg [2:0] coldir=4;
reg colLock=0;
reg blkleft=0,blktop=0,blkright=0,blkbottom=0;//标记blk上下左右墙壁
reg plu=0;

reg bonon=0;
reg [9:0] bonx [0:24];
reg [9:0] bony [0:24];
reg bon_appear [0:24];
reg [5:0] bon_id=0;
reg [2:0] grade_up=0,grade_up2=0;
reg [6:0] grade=0,grade2=0;

reg start=0;
//
reg [2:0] coldir2=4;
reg colLock2=0;
reg blkleft2=0,blktop2=0,blkright2=0,blkbottom2=0;//标记blk上下左右墙壁
reg plu2=0;
reg on;


always @(posedge clk) begin
        if(clkCount >= 3000000) begin//if(clkCount == 24999999) begin
                clkCount <= 0;
                Bclk <= ~Bclk;///oneUSClk=50*clk
        end
        else begin
                clkCount <= clkCount + 1'b1;
        end
end


always @(posedge clk) begin
    grade=grade+grade_up;   //实际上苹果6分 小方块2分
    grade2=grade2+grade_up2;
    if(lc)
        if(grade>4)
            grade=grade-4;
        else
            grade=0;
    if(lc2)
        if(grade2>4)
            grade2=grade2-4;
        else
            grade2=0;
            
    data_out=(grade<<8)|grade2;
end



always @(posedge Bclk) begin
    if(key[4]) begin
        start=~start;
        on=1;
    end
    else
        on=0;
end

always @(posedge Bclk) begin
    if (!clr) begin

       bodyx[2]<=60;
       bodyx[1]<=80;
       bodyx[0]<=100;
        bodyy[0]<=40;
        bodyy[1]<=40;
        bodyy[2]<=40;
        
        dx[0]=20;
        dx[1]=17;
        dx[2]=10;
        dx[3]=0;
        dx[4]=10;
        dx[5]=17;
        dx[6]=20;
        dx[7]=17;
        dx[8]=10;
        dx[9]=0;
        dx[10]=10;
        dx[11]=17;
        
        dy[0]=0;
        dy[1]=10;
        dy[2]=17;
        dy[3]=20;
        dy[4]=17;
        dy[5]=10;
        dy[6]=0;
        dy[7]=10;
        dy[8]=17;
        dy[9]=20;
        dy[10]=17;
        dy[11]=10;
        
        blkx[0]=200;
        blkx[1]=300;
        blkx[2]=400;
        blkx[3]=500;
        blkx[4]=200;
        blkx[5]=50;
        
        blky[0]=400;
        blky[1]=300;
        blky[2]=200;
        blky[3]=350;
        blky[4]=150;
        blky[5]=320;
        
        for(i=0;i<=5;i=i+1)begin
               bonx[4*i]=blkx[i]-W;
               bony[4*i]=blky[i]+H;
               bonx[4*i+1]=blkx[i]+Wb;
               bony[4*i+1]=blky[i]+H;
               bonx[4*i+2]=blkx[i]+Wb/2;
               bony[4*i+2]=blky[i]-H;
               bonx[4*i+3]=blkx[i]+Wb/3;
               bony[4*i+3]=blky[i]+Hb;
               bonx[4*i+4]=blkx[i]+Wb*2/3;
               bony[4*i+4]=blky[i]+Hb;
        end
       
       
    end
    else if(death) begin
        for(i=20;i>0;i=i-1) begin
                bodyx[i]<=0;
                bodyy[i]<=0;
        end
    end
    else begin
        if(start)begin
            for(i=20;i>0;i=i-1) begin
                bodyx[i]<=bodyx[i-1];
                bodyy[i]<=bodyy[i-1];
            end
        
    //碰撞的ang改变需要当即 否则要过两个Bclk才能变方向
          
          if(!colLock)begin
               case(coldir)
                   0: begin
                      if(ang<3||ang>9) begin
                          if(ang<4)
                               ang=6-ang;
                          else if(ang>8)
                               ang=18-ang;
                          colLock=1;
                      end
                   end
                   1: begin 
                      if(ang>6&&ang<12) begin
                          ang=12-ang;
                          colLock=1;
                      end
                   end
                   2: begin 
                      if(ang>3&&ang<9) begin
                          if(ang>6)
                               ang=18-ang;
                          else if(ang<=6)
                               ang=6-ang;
                          colLock=1;
                      end
                   end
                   3: begin 
                      if(ang>0&&ang<6) begin
                          ang=12-ang;
                          colLock=1;
                      end
                   end
                   default:begin
                   end
                   endcase
             end
             else
                    if(Bclk)
                        colLock=0;//一个Bclk之后解锁碰撞   
                   
                   case(dir)
                         0: begin 
                            if(ang<11)
                              ang=ang+1;
                            else
                              ang=0;
                         end//y[0]不变
                         1: begin 
                             if(ang>0)
                                 ang=ang-1;
                               else
                                 ang=11;
                         end
                         2: begin 
                             ang=ang;
                         end
                         default:begin
                         end
                     endcase
    
    
            if(ang>3 && ang<9)
                bodyx[0]=bodyx[0]-dx[ang];
            else
                bodyx[0]=bodyx[0]+dx[ang];
                
            if(ang>6)
                bodyy[0]=bodyy[0]+dy[ang];
            else
                bodyy[0]=bodyy[0]-dy[ang];
         end
    end
end

///
always @(posedge Bclk) begin
    if (!clr) begin

       bodyx2[2]<=540;
       bodyx2[1]<=520;
       bodyx2[0]<=500;
        bodyy2[0]<=40;
        bodyy2[1]<=40;
        bodyy2[2]<=40;
        
    end
    else if(death2) begin
        for(i=20;i>0;i=i-1) begin
                bodyx2[i]<=0;
                bodyy2[i]<=0;
        end
    end
    else begin
      if(start)begin
        for(i=20;i>0;i=i-1) begin
            bodyx2[i]<=bodyx2[i-1];
            bodyy2[i]<=bodyy2[i-1];
        end
    
//碰撞的ang改变需要当即 否则要过两个Bclk才能变方向
      
      if(!colLock2)begin
           case(coldir2)
              0: begin
                 if(ang2<3||ang2>9) begin
                     if(ang2<4)
                          ang2=6-ang2;
                     else if(ang2>8)
                          ang2=18-ang2;
                     colLock2=1;
                 end
              end
              1: begin 
                 if(ang2>6&&ang2<12) begin
                     ang2=12-ang2;
                     colLock2=1;
                 end
              end
              2: begin 
                 if(ang2>3&&ang2<9) begin
                     if(ang2>6)
                          ang2=18-ang2;
                     else if(ang2<=6)
                          ang2=6-ang2;
                     colLock2=1;
                 end
              end
              3: begin 
                 if(ang2>0&&ang2<6) begin
                     ang2=12-ang2;
                     colLock2=1;
                 end
              end
              default:begin
              end
              endcase
         end
         else
                if(Bclk)
                    colLock2=0;//一个Bclk之后解锁碰撞   
               
               case(dir2)
                     0: begin 
                        if(ang2<11)
                          ang2=ang2+1;
                        else
                          ang2=0;
                     end//y[0]不变
                     1: begin 
                         if(ang2>0)
                             ang2=ang2-1;
                           else
                             ang2=11;
                     end
                     2: begin 
                         ang2=ang2;
                     end
                     default:begin
                     end
                 endcase


        if(ang2>3 && ang2<9)
            bodyx2[0]=bodyx2[0]-dx[ang2];
        else
            bodyx2[0]=bodyx2[0]+dx[ang2];
            
        if(ang2>6)
            bodyy2[0]=bodyy2[0]+dy[ang2];
        else
            bodyy2[0]=bodyy2[0]-dy[ang2];
      end
    end
end


always @ (posedge clk) begin
        if (death)
            dir=4;
        else begin
            if (key[1]) begin //左
                dir=0;
            end
            else if (key[0]) begin //右
                dir=1;
            end
            else
               dir=2;//保持
        end
    
end
///
always @ (posedge clk) begin
        if (death2)
            dir2=4;
        else begin
            if (key[3]) begin //左
                dir2=0;
            end
            else if (key[2]) begin //右
                dir2=1;
            end
            else
               dir2=2;//保持
        end
    
end





always @ (posedge clk) begin
    spriteon = 1'b0;
    head=0;
    body=0;
    if(!death)
        if ((hc >= bodyx[0] + hbp) && (hc < bodyx[0] + hbp + W) && (vc < bodyy[0] + vbp + H) && (vc >= bodyy[0] + vbp))//在图片显示范围内
        begin
            spriteon = 1'b1; 
            head = 1'b1;
        end
        else begin
            for(i=1;i<=20;i=i+1)
                if(l>=i)
                    if ((hc >= bodyx[i] + hbp) && (hc < bodyx[i] + hbp + W) && (vc < bodyy[i] + vbp + H) && (vc >= bodyy[i] + vbp))//在图片显示范围内
                    begin    
                        spriteon = 1'b1; 
                        body=1;
                    end     
        end
    else
        spriteon = 1'b0;
end

///

always @ (posedge clk) begin
    spriteon2 = 1'b0;
    head2=0;
    body2=0;
    if(!death2)
        if ((hc >= bodyx2[0] + hbp) && (hc < bodyx2[0] + hbp + W) && (vc < bodyy2[0] + vbp + H) && (vc >= bodyy2[0] + vbp))//在图片显示范围内
        begin
            spriteon2 = 1'b1; 
            head2 = 1'b1;
        end
        else begin
            for(i=1;i<=20;i=i+1)
                if(l2>=i)
                    if ((hc >= bodyx2[i] + hbp) && (hc < bodyx2[i] + hbp + W) && (vc < bodyy2[i] + vbp + H) && (vc >= bodyy2[i] + vbp))//在图片显示范围内
                    begin    
                        spriteon2 = 1'b1; 
                        body2=1;
                    end 
        end
      else
        spriteon2 = 1'b0;
end

         

always @(posedge clk) begin //吃苹果碰撞
    
    if (spriteon == 1 && appon == 1)begin
        apprefresh=1;
        plu=1;
        bonrefresh=1;
    end
    else if(spriteon2 == 1 && appon == 1)begin
        apprefresh=1;
        plu2=1;
        bonrefresh=1;
    end
    else if(blkon == 1 && appon == 1)begin
        apprefresh=1;
    end
    else begin
        apprefresh=0;
        plu=0;
        plu2=0;
        bonrefresh=0;
    end
    if(!clr)
            bonrefresh=1;
end


always @(posedge clk) begin //blk碰撞
    if (head == 1 && blkleft == 1)
        coldir=0;
    else if (head == 1 && blktop == 1)
        coldir=1;
    else if (head == 1 && blkright == 1)
        coldir=2;
    else if (head == 1 && blkbottom == 1)
        coldir=3;
    else
        if(colLock)
            coldir=4;
end

///
always @(posedge clk) begin //blk碰撞
    if (head2 == 1 && blkleft == 1)
        coldir2=0;
    else if (head2 == 1 && blktop == 1)
        coldir2=1;
    else if (head2 == 1 && blkright == 1)
        coldir2=2;
    else if (head2 == 1 && blkbottom == 1)
        coldir2=3;
    else
        if(colLock2)
            coldir2=4;
end







reg [9:0] rand_num1;//列随机数
reg [8:0] rand_num2;//行随机数
always@(posedge clk)//生成随机数
begin
    if(!clr) begin
        rand_num1 <=10'b0101111111;    /*load the initial value when load is active*/
        rand_num2 <=9'b011111011;
    end
    else if(apprefresh)
        begin
            rand_num1[0] <= rand_num1[9];
            rand_num1[1] <= rand_num1[0];
            rand_num1[2] <= rand_num1[1];
            rand_num1[3] <= rand_num1[2];
            rand_num1[4] <= rand_num1[3]^rand_num1[7];
            rand_num1[5] <= rand_num1[4]^rand_num1[7];
            rand_num1[6] <= rand_num1[5]^rand_num1[7];
            rand_num1[7] <= rand_num1[6];
            rand_num1[8] <= rand_num1[7];
            rand_num1[9] <= rand_num1[8];
            
            rand_num2[0] <= rand_num2[8];
            rand_num2[1] <= rand_num2[0];
            rand_num2[2] <= rand_num2[1];
            rand_num2[3] <= rand_num2[2];
            rand_num2[4] <= rand_num2[3]^rand_num2[7];
            rand_num2[5] <= rand_num2[4]^rand_num2[7];
            rand_num2[6] <= rand_num2[5]^rand_num2[7];
            rand_num2[7] <= rand_num2[6];
            rand_num2[8] <= rand_num2[7];
            if(rand_num1>600)
                rand_num1=rand_num1-500;
            if(rand_num2>460)
                rand_num2=rand_num2-300;
        end
            
end



always @(posedge clk) begin
    if (spriteon == 1'b1 && vga_en == 1'b0) 
        death=1;
        
    if (spriteon2 == 1'b1 && vga_en == 1'b0) 
        death2=1;
        
    if (head==1 && body2==1)
        lc=1; 
    else if(plu)
        lc=2;  
    else
        lc=0;      
        
    if (head2==1 && body==1)
        lc2=1;
    else if(plu2)
        lc2=2;     
    else
        lc2=0;
        
        
    if(head==1 && bonon==1)begin
        bon_appear[bon_id]=0;
        grade_up=1;
    end
    else if(plu)begin
        grade_up=2;
        bon_appear[bon_id]=bon_appear[bon_id];
    end
    else begin
        grade_up=0;
        bon_appear[bon_id]=bon_appear[bon_id];
    end
        
    if(head2==1 && bonon==1)begin
        bon_appear[bon_id]=0;
       grade_up2=1;
   end
   else if(plu2)begin
       grade_up2=2;
       bon_appear[bon_id]=bon_appear[bon_id];
   end
   else begin
       grade_up2=0;
       bon_appear[bon_id]=bon_appear[bon_id];
   end
        
        
    if(apprefresh)begin
        appx=rand_num1;
        appy=rand_num2;
    end
    
     if(bonrefresh||on)
           for(i=0;i<=24;i=i+1)
               bon_appear[i]=1;
   
end

always @(posedge clk) begin
    if(!Llock)
        if(lc==1)begin
            if(l>1)
                l=l-1;
            else
                l=l;
            Llock=1;
        end
        else if(lc==2)begin
            l=l+1;
            Llock=1;
        end
        else
            Llock=0;
    else begin
        if(!Bclk)
            Llock=0;
    end
     
     
   if(!Llock2)
        if(lc2==1)begin
            if(l2>1)
                l2=l2-1;
            else
                l2=l2;
            Llock2=1;
        end
        else if(lc2==2)begin
            l2=l2+1;
            Llock2=1;
        end
        else
            Llock2=0;
    else begin
        if(!Bclk)
            Llock2=0;
    end
     /*
    if(!Llock2)
        if(lc2==1)begin
            l2=l2-1;
            Llock2=1;
        end
        else if(lc2==2)begin
            l2=l2+1;
            Llock2=1;
        end
    else begin
        if(Bclk)
            Llock2=0;
    end
    */
                 
end


always @ (posedge clk) begin
    blkon=0;
    blkleft=0;
    blkright=0;
    blktop=0;
    blkbottom=0;
    for(i=0;i<=5;i=i+1)begin
        if((hc >= blkx[i] + hbp) && (hc <= blkx[i] + hbp + Wb) && (vc >= blky[i] + vbp) && (vc <= blky[i] + vbp + Hb))
            blkon=1;
            
        if((hc >= blkx[i] + hbp) && (hc <= blkx[i] + hbp + 10) && (vc >= blky[i] + vbp+10) && (vc <= blky[i] + vbp + Hb-10))
            blkleft=1;
        else if((hc >= blkx[i] + hbp + Wb - 10) && (hc <= blkx[i] + hbp + Wb)  && (vc >= blky[i] + vbp+10) && (vc <= blky[i] + vbp + Hb-10))
            blkright=1;
        else if((vc >= blky[i] + vbp) && (vc <= blky[i] + vbp + 10) && (hc >= blkx[i] + hbp) && (hc <= blkx[i] + hbp + Wb))
            blktop=1;
        else if((vc >= blky[i] + vbp + Hb - 10) && (vc <= blky[i] + vbp + Hb) && (hc >= blkx[i] + hbp) && (hc <= blkx[i] + hbp + Wb))
            blkbottom=1;
    end
end

always @ (posedge clk) begin
    bonon=0;
   
    for(i=0;i<=24;i=i+1)
        if(bon_appear[i])
            if((hc >= bonx[i] + hbp) && (hc <= bonx[i] + hbp + W) && (vc >= bony[i] + vbp) && (vc <= bony[i] + vbp + H))
            begin
                    bonon=1;
                    bon_id=i;
            end
end

always @ (posedge clk) begin
    appon=0;
    if((hc >= appx + hbp) && (hc <= appx + hbp + W) && (vc >= appy + vbp) && (vc <= appy + vbp + H))
        appon=1;
end


// 色彩信号驱动逻辑
always @ (posedge clk)
    if (spriteon == 1'b1 && vga_en == 1'b1) begin
        RED = 4'b0;
        GRN = 4'b0;
        BLU = 4'b1111;
    end
    else if (spriteon2 == 1'b1 && vga_en == 1'b1) begin
       RED = 4'b0;
       GRN = 4'b1111;
       BLU = 4'b0;
    end
    else if (appon == 1'b1 && vga_en == 1'b1) begin
       RED = 4'b1111;
       GRN = 4'b0;
       BLU = 4'b0;
    end
    else if (bonon == 1'b1 && vga_en == 1'b1) begin
      RED = 4'b1000;
      GRN = 4'b0100;
      BLU = 4'b0;
    end
    else if (blkon == 1'b1 && vga_en == 1'b1) begin
       RED = 4'b1100;
       GRN = 4'b1100;
       BLU = 4'b0;
    end
    else begin
        RED = 4'b0;
        GRN = 4'b0;
        BLU = 4'b0;
    end



endmodule
