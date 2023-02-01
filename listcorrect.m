function [listkai]=listcorrect(list)
listlkai=[];
numbox1=[];
numbox2=[];
numbox3=[];
numbox4=[];
numbox5=[];
numbox6=[];
numbox7=[];
numbox8=[];
numbox9=[];
numbox10=[];
numbox11=[];
numbox12=[];
numbox13=[];
numbox14=[];
numbox15=[];
numbox16=[];
numbox17=[];
numbox18=[];
numbox19=[];
numbox20=[];
numbox21=[];
numbox22=[];
numbox23=[];
numbox24=[];

    count0=0;
    
    for i=1:size(list(:,1))
    if list(i,4)==0
        count0=count0+1;
       numbox0(1,count0) =i;
    end
    end
     count1=0;
    for i=1:size(list(:,1))
    if list(i,4)==1
        count1=count1+1;
       numbox1(1,count1) =i;
    end
    end
     count2=0;
    for i=1:size(list(:,1))
    if list(i,4)==2
        count2=count2+1;
       numbox2(1,count2) =i;
    end
    end
     count3=0;
    for i=1:size(list(:,1))
    if list(i,4)==3
        count3=count3+1;
       numbox3(1,count3) =i;
    end
    end
        count4=0;
    for i=1:size(list(:,1))
    if list(i,4)==4
        count4=count4+1;
       numbox4(1,count4) =i;
    end
    end
     count5=0;
    for i=1:size(list(:,1))
    if list(i,4)==5
        count5=count5+1;
       numbox5(1,count5) =i;
    end
    end
     count6=0;
    for i=1:size(list(:,1))
    if list(i,4)==6
        count6=count6+1;
       numbox6(1,count6) =i;
    end
    end
     count7=0;
    for i=1:size(list(:,1))
    if list(i,4)==7
        count7=count7+1;
       numbox7(1,count7) =i;
    end
    end
       count8=0;
    for i=1:size(list(:,1))
    if list(i,4)==8
        count8=count8+1;
       numbox8(1,count8) =i;
    end
    end
     count9=0;
    for i=1:size(list(:,1))
    if list(i,4)==9
        count9=count9+1;
       numbox9(1,count9) =i;
    end
    end
    count10=0;
    for i=1:size(list(:,1))
    if list(i,4)==10
        count10=count10+1;
       numbox10(1,count10) =i;
    end
    end
     count11=0;
    for i=1:size(list(:,1))
    if list(i,4)==11
        count11=count11+1;
       numbox11(1,count11) =i;
    end
    end
        count12=0;
    for i=1:size(list(:,1))
    if list(i,4)==12
        count12=count12+1;
       numbox12(1,count12) =i;
    end
    end
     count13=0;
    for i=1:size(list(:,1))
    if list(i,4)==13
        count13=count13+1;
       numbox13(1,count13) =i;
    end
    end
     count14=0;
    for i=1:size(list(:,1))
    if list(i,4)==14
        count14=count14+1;
       numbox14(1,count14) =i;
    end
    end
     count15=0;
    for i=1:size(list(:,1))
    if list(i,4)==15
        count15=count15+1;
       numbox15(1,count15) =i;
    end
    end
        count16=0;
    for i=1:size(list(:,1))
    if list(i,4)==16
        count16=count16+1;
       numbox16(1,count16) =i;
    end
    end
        count17=0;
    for i=1:size(list(:,1))
    if list(i,4)==17
        count17=count17+1;
       numbox17(1,count17) =i;
    end
    end
     count18=0;
    for i=1:size(list(:,1))
    if list(i,4)==18
        count18=count18+1;
       numbox18(1,count18) =i;
    end
    end
     count19=0;
    for i=1:size(list(:,1))
    if list(i,4)==19
        count19=count19+1;
       numbox19(1,count19) =i;
    end
    end
     count20=0;
    for i=1:size(list(:,1))
    if list(i,4)==20
        count20=count20+1;
       numbox20(1,count20) =i;
    end
   end
       count21=0;
    for i=1:size(list(:,1))
    if list(i,4)==21
        count21=count21+1;
       numbox21(1,count21) =i;
    end
    end
     count22=0;
    for i=1:size(list(:,1))
    if list(i,4)==22
        count22=count22+1;
       numbox22(1,count22) =i;
    end
    end
     count23=0;
    for i=1:size(list(:,1))
    if list(i,4)==23
        count23=count23+1;
       numbox23(1,count23) =i;
    end
    end
     count24=0;
    for i=1:size(list(:,1))
    if list(i,4)==24
        count24=count24+1;
       numbox24(1,count24) =i;
    end
    end
    
    listkai(1:count0,:)=list(numbox0,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count1,:)=list(numbox1,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count2,:)=list(numbox2,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count3,:)=list(numbox3,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count4,:)=list(numbox4,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count5,:)=list(numbox5,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count6,:)=list(numbox6,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count7,:)=list(numbox7,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count8,:)=list(numbox8,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count9,:)=list(numbox9,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count10,:)=list(numbox10,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count11,:)=list(numbox11,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count12,:)=list(numbox12,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count13,:)=list(numbox13,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count14,:)=list(numbox14,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count15,:)=list(numbox15,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count16,:)=list(numbox16,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count17,:)=list(numbox17,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count18,:)=list(numbox18,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count19,:)=list(numbox19,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count20,:)=list(numbox20,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count21,:)=list(numbox21,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count22,:)=list(numbox22,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count23,:)=list(numbox23,:);
    listkai(size(listkai(:,1))+1:size(listkai(:,1))+count24,:)=list(numbox24,:);
    
  