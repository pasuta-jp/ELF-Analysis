 %LLSデータ処理
 %LLSデータまとめをExcelに保存
%まずCellをTableに変換
T = cell2table(EN_ELF_box,...
    'VariableNames',{'Event Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'Miri Second' 'LLS Lightning Location (lon[°])' 'LLS Lightning Location (lat[°])' 'LLS Lingtning Direction [°]' 'LLS-ELF Direction [°]' 'Qds It [Ckm]' 'Ip2[kA]' 'ELF Direcion Aft Correcton [°]' 'Ip[kA]' 'Map Check' 'Qds Ex[Ckm]' 'Qds Im[Ckm]' 'Qds SR[Ckm]' 'Qds It iCMC[Ckm]' 'Distance[km]' 'Eventtime' 'Var23' 'Lag' 'Mean H' 'Std H' 'Peak H' 'Group Velocity' 'ratio' 'Time' 'Thetah' 'pol2' 'LLS/ELF pol check' 'EN Hod pol Check' 'LLS TYPE'});
%Excelで保存
filename = 'testdata.xlsx';
writetable(T,filename)

%図のプロット用にCellを通常配列に変換する
 %LLS_TYPEだけ文字型なので別の配列に分離
  for i=1:length(EN_ELF_box)
LLS_TYPE{i,1}=EN_ELF_box{i,36};
end
LLS_TYPE=cell2mat(LLS_TYPE);
%数値データを通常の配列に変換
for i=1:length(EN_ELF_box)
    for j=1:35
EN_ELF_box2{i,j}=EN_ELF_box{i,j};
    end
end
EN_ELF_box=EN_ELF_box2;
EN_ELF_box=cell2mat(EN_ELF_box);



%到来方位誤差補正
EN_theta = EN_ELF_box(:,11);
           EN_delta_theta = EN_ELF_box(:,12);
           
           %pfit = polyfit(EN_theta, EN_delta_theta,2);
           f= fit(EN_theta, EN_delta_theta,'sin2');
           
           % a_keisuu = sprintf('%02d', pfit(1,1));
           % b_keisuu = sprintf('%02d', pfit(1,2));
%            keisuu = 'a = %02d, b = %02d';
%            a_keisuu = pfit(1,1);
%            b_keisuu = pfit(1,2);
%            str = sprintf(keisuu,a_keisuu,b_keisuu);
          % theta_span = -180:1:180;
          
         % theta_span = 0:1:360;
        %   pfit_line = polyval(pfit,theta_span);
           spacial_plot_1=plot(EN_theta, EN_delta_theta, '.');
           hold on
           spacial_plot_2=plot(f);
           hold on
          %  xlim([-180 180])
          xlim([0 360])
          % ylim([-20 20])
          ylim([-30 30])
           title('Correction of Δθ at UMP');
           %title('Histogram of Δθ at' loc_name);
           xlabel('θ (EN)[°]');
           ylabel('Δθ (ELF-EN)[°]');
           % xticks([-180:180]);
           %yticks([-10:10]);
           %legend('θ (EN)_Δθ (ELF-EN)','Approximate line');
           legend([spacial_plot_1 spacial_plot_2],{'θ (EN)_Δθ (ELF-EN)','Approximate line'},'fontsize',7)
          % annotation('textarrow',theta_span,pfit_line,'String',str);
          % annotation('textarrow',theta_span,pfit_line,'String','a=, b=');
           grid on

%マラッカ海峡のみの雷をリスト化
 count=0;
 malacca=[];
for i=1:numel(EN_ELF_box1(:,1))
       if (EN_ELF_box1(i,9)>95 && EN_ELF_box1(i,9)<102) && (EN_ELF_box1(i,10)>0 && EN_ELF_box1(i,10)<8)
           count=count+1;
           malacca(count,:)=EN_ELF_box1(i,:);
       end
end
%タイ北部のみの雷をリスト化
count=0;
 tai=[];
for i=1:numel(EN_ELF_box1(:,1))
       if (EN_ELF_box1(i,9)>100 && EN_ELF_box1(i,9)<110) && (EN_ELF_box1(i,10)>10 && EN_ELF_box1(i,10)<15)
           count=count+1;
           tai(count,:)=EN_ELF_box1(i,:);
       end
end

%%%雨季・乾季まとめたEN_ELF_box1を作成%%%
% x:20180620, y:20180621 z:20180622
% a:20181120, b:20181121 c:20181122
% EN_ELF_box1w(winter) EN_ELF_box1s(smmer)

numx=numel(x(:,1));
numy=numel(y(:,1));
numz=numel(z(:,1));
numa=numel(a(:,1));
numb=numel(b(:,1));
numc=numel(c(:,1));
EN_ELF_box1s=[];
EN_ELF_box1w=[];
count=0;
    EN_ELF_box1s(1:numx,:)=x(:,:);
    EN_ELF_box1s(numel(EN_ELF_box1s(:,1))+1:numel(EN_ELF_box1s(:,1))+numy,:)=y(:,:);
    EN_ELF_box1s(numel(EN_ELF_box1s(:,1))+1:numel(EN_ELF_box1s(:,1))+numz,:)=z(:,:);
    
    EN_ELF_box1w(1:numa,:)=a(:,:);
    EN_ELF_box1w(numel(EN_ELF_box1w(:,1))+1:numel(EN_ELF_box1w(:,1))+numb,:)=b(:,:);
    EN_ELF_box1w(numel(EN_ELF_box1w(:,1))+1:numel(EN_ELF_box1w(:,1))+numc,:)=c(:,:);
writematrix(EN_ELF_box1s,'EN_ELF_box1s.xls');
writematrix(EN_ELF_box1w,'EN_ELF_box1w.xls');

%Qdsの非常に大きなイベントを精査するためにイベントnumberをメモ
 count=0;
 Q=22 ;%Qds Im=20, Qds It iCMC=22
 numcheck=[];
for i=1:numel(EN_ELF_box1(:,1))
       if abs(EN_ELF_box1(i,Q))>1000
           count=count+1;
           numcheck(count,1)=EN_ELF_box1(i,1);
       end
end


%σの値を決めてリストに格納
sigmaELF=1;
 count=0;
 EN_ELF_box1=[];
for i=1:numel(EN_ELF_box(:,1))
       if EN_ELF_box(i,37)>EN_ELF_box(i,38)+sigmaELF*EN_ELF_box(i,39)
           count=count+1;
           EN_ELF_box1(count,:)=EN_ELF_box(i,:);
       end
end

%極性別のリストを作成
 countplus=0;
 countminus=0;
 Plus_box=[];
 Minus_box=[];
for i=1:numel(EN_ELF_box1w(:,1))
    if EN_ELF_box1w(i,19)==0
        continue
    end
       if EN_ELF_box1w(i,19)>0
           countplus=countplus+1;
           Plus_box(countplus,:)=EN_ELF_box1w(i,:);
       elseif EN_ELF_box1w(i,19)<0
           countminus=countminus+1;
           Minus_box(countminus,:)=EN_ELF_box1w(i,:);
       end       
end

% UQ LQ 中央値
 
quantile(Plus_box(:,21),[0.25 0.50 0.75])
quantile(Plus_box(:,19),[0.25 0.50 0.75])
quantile(Minus_box(:,21),[0.25 0.50 0.75])
quantile(Minus_box(:,19),[0.25 0.50 0.75])


%Qdsの閾値ごとにリストを作成
Q=21; %可変　 %iCMC = 22, Im = 20 東電　Im 20 iCMC 21
threshold_p=750; %可変　50 100 200 500 1000 東電750 1000 冬だけ300 400
threshold_m=880; %可変　50 100 200 500 1000 東電2200 冬だけ880
cp=0;
cn=0;
event_boxplus=[];
event_boxminus=[];
for i=1:numel(Plus_box(:,1))
if Plus_box(i,Q)>threshold_p
    cp=cp+1;
     event_boxplus(cp,:)=Plus_box(i,:);
end
end
for i=1:numel(Minus_box(:,1))
if abs(Minus_box(i,Q))>threshold_m
    cn=cn+1;
     event_boxminus(cn,:)=Minus_box(i,:);
end

end




%UMP
lat_OBS = 3.546819;
    lon_OBS = 103.427;
    %KL
    lat_OBS_KL = 3.151873;
    lon_OBS_KL = 101.7085;
      % UMP表示範囲
    lat_min = 0;     % 緯度の最小値
    lat_max = 15;     % 緯度の最大値
    lon_min = 95;    % 経度の最小値
    lon_max = 110;    % 経度の最大値
    
    %RKB
     lat_min = 34.0;       %緯度最小
    lat_max = 38.5;     %緯度最大
    lon_min = 137.5;    %経度最小
    lon_max = 142;    %経度最大
    %%% RKBの緯度経度
    lat_OBS = 43.27;
    lon_OBS = 143.43;
    
    loc_name = 'RKB';
    TYPE = 'LLS';

%%%%%%%%%%%% Ipk histogram %%%%%%%%%%%%%%%%
        S = std(EN_ELF_box(:,14)); %Δθの標準偏差
  M = mean(EN_ELF_box(:,14)); %Δθの平均値
          % subplot(3,1,1);
           %delta_theta_hist = histogram(EN_ELF_box(:,12),40);
           histogram(EN_ELF_box(:,14),50);
           title('Histogram of Ipk at UMP');
           %title('Histogram of Δθ at' loc_name);
           xlabel('Ipk [kA]');
           ylabel('Frequency ');
          % xticks([-10:10]);
           %xlim([-20 20]);
           xline(M,'r','Average');
           xline(S,'g','σ');
           xline(2*S,'g','2σ');
            xline(-S,'g','σ');
           xline(-2*S,'g','2σ');
           grid on
           
           %%% Ipk-Qds %%%%
        Ip_range=0;
           for i=1:40    %Ipのレンジの配列を作る（10 20 30 ・・・200）
               t=i*10;
               Ip_range(1,i+1)=t;
           end
           
         
            Qds_median_list_plus=[]; % 0,10,20,...<Ipk<10,20,30,...を満たすイベントのQdsをリスト化して中央値を計算
           for i=1:numel(Ip_range(1,:))-1
               k=0;
                Qds_list=[];
           for j=1:numel(Plus_box(:,1))
               if Ip_range(1,i)<abs(Plus_box(j,14)) && Ip_range(1,i+1)>abs(Plus_box(j,14))
                   k=k+1;
                   Qds_list(1,k)=Plus_box(j,20);
               end
           end
           if numel(Qds_list)==0
               continue
           end
           Qds_median_list_plus(1,i)=median( Qds_list(1,:),2);
           end
           
           Qds_median_list_minus=[]; % 0,10,20,...<Ipk<10,20,30,...を満たすイベントのQdsをリスト化して中央値を計算
           for i=1:numel(Ip_range(1,:))-1
               k=0;
                Qds_list=[];
           for j=1:numel(Minus_box(:,1))
               if Ip_range(1,i)<abs(Minus_box(j,14)) && Ip_range(1,i+1)>abs(Minus_box(j,14))
                   k=k+1;
                   Qds_list(1,k)=Minus_box(j,20);
               end
           end
           if numel(Qds_list)==0
               continue
           end
           Qds_median_list_minus(1,i)=median( Qds_list(1,:),2);
           end
           
            Ipk_plot_plus=plot(Plus_box(:,14),Plus_box(:,20),'r.');%Qds_Im Plus
           % xlim([0 100]);
            hold on
             Ipk_plot_minus=plot(Minus_box(:,14),Minus_box(:,20),'b.');%Qds_Im minus
            % xlim([-100 0]);
            hold on
            Median_plot_plus=plot(Ip_range(1,1:numel(Qds_median_list_plus(1,:))),Qds_median_list_plus(1,:),'k--o','MarkerFaceColor','k');
            hold on
            Median_plot_minus=plot(-Ip_range(1,1:numel(Qds_median_list_minus(1,:))),Qds_median_list_minus(1,:),'k--o','MarkerFaceColor','k');
            hold on
            
            
            xlim([-400 400]);
           ylim([-300 300]);
%              pfit = polyfit(Plus_box(:,14),Plus_box(:,20),1);%Plus 最小二乗直線
%           theta_span = -300:1:300;
%          %theta_span = Plus_box(:,14);
%            pfit_line = polyval(pfit,theta_span);
%           Ipk_fit_plus=plot(pfit_line);
%           hold on
%           
%            pfit = polyfit(abs(Minus_box(:,14)),Minus_box(:,20),1);%minus 最小二乗直線
%          theta_span = -300:1:300;
%          %theta_span = Minus_box(:,14);
%            pfit_line = polyval(pfit,theta_span);
%           Ipk_fit_minus=plot(pfit_line);
%           hold on
          
%            Ipk_plot3=plot(EN_ELF_box(:,14),EN_ELF_box(:,13),'b.');%Qds_It
%            hold on
%            Ipk_plot4=plot(EN_ELF_box(:,14),EN_ELF_box(:,22),'k.');%Qds_It_iCMC
%            hold on
           
    title('Ipk Qds Im correlation 2018/11/20～22 ');
    
    ylabel('Qds[Ckm]');
    xlabel('Ipk [kA]');
     legend([Ipk_plot_plus Ipk_plot_minus Median_plot_plus],{'Positive', 'Negative', 'Median'},'fontsize',7)
   % legend([Ipk_plot_plus Ipk_plot_minus Ipk_fit_plus Ipk_fit_minus],{'Positive', 'Negative', 'Approximate line','Approximate line'},'fontsize',7)
   % legend([Ipk_plot Ipk_plot2 Ipk_plot3 Ipk_plot4],{'Qds_Ex', 'Qds_Im', 'Qds_It', 'Qds_It_iCMC'},'fontsize',7)
    
    grid on
    
    %correlaion Qds virsus Ip
    soukanplus=corr2(Minus_box(:,14),Minus_box(:,20));
     soukanminus=corr2(Plus_box(:,14),Plus_box(:,20));
     
     
    %%% Qds_rate
   
    Qds_rate1=EN_ELF_box(:,19);
    Qds_rate2=EN_ELF_box(:,20);
    Qds_rate3=EN_ELF_box(:,13);
    Qds_rate4=EN_ELF_box(:,22);
     Qcountplus=0;
     Qcountminus=0;
    for i=1:size(Qds_rate1(:,1))
        if Qds_rate1(i,1)>=0
            Qcountplus=Qcountplus+1;
            Qds_rate1_plus(Qcountplus,1)=Qds_rate1(i,1);
        elseif Qds_rate1(i,1)<0
            Qcountminus=Qcountminus+1;
            Qds_rate1_minus(Qcountminus,1)=Qds_rate1(i,1);
        end
    end
    
         Qcountplus=0;
     Qcountminus=0;
    for i=1:size(Qds_rate2(:,1))
        if Qds_rate2(i,1)>=0
            Qcountplus=Qcountplus+1;
            Qds_rate2_plus(Qcountplus,1)=Qds_rate2(i,1);
        elseif Qds_rate1(i,1)<0
            Qcountminus=Qcountminus+1;
            Qds_rate2_minus(Qcountminus,1)=Qds_rate2(i,1);
        end
    end
    
          Qcountplus=0;
     Qcountminus=0;
    for i=1:size(Qds_rate3(:,1))
        if Qds_rate3(i,1)>=0
            Qcountplus=Qcountplus+1;
            Qds_rate3_plus(Qcountplus,1)=Qds_rate3(i,1);
        elseif Qds_rate3(i,1)<0
            Qcountminus=Qcountminus+1;
            Qds_rate3_minus(Qcountminus,1)=Qds_rate3(i,1);
        end
    end
    
          Qcountplus=0;
     Qcountminus=0;
    for i=1:size(Qds_rate4(:,1))
        if Qds_rate4(i,1)>=0
            Qcountplus=Qcountplus+1;
            Qds_rate4_plus(Qcountplus,1)=Qds_rate4(i,1);
        elseif Qds_rate4(i,1)<0
            Qcountminus=Qcountminus+1;
            Qds_rate4_minus(Qcountminus,1)=Qds_rate4(i,1);
        end
    end
    
%     Qds_rate1=sort(Qds_rate1);
%     Qds_rate2=sort(Qds_rate2);
%     Qds_rate3=sort(Qds_rate3);
%     Qds_rate4=sort(Qds_rate4);
%    Q1= cdfplot(Qds_rate1);
%     hold on
%     Q2= cdfplot(Qds_rate2);
%      hold on
%     Q3=  cdfplot(Qds_rate3);
%       hold on
%     Q4=   cdfplot(Qds_rate4);
%        hold on
 ecdf(Qds_rate1_plus);
     hold on
      x=-4000:0;
     %minusplot=1- cdf('Normal',Qds_rate1_minus,x);
ecdf(Qds_rate1_minus,'Function','survivor');
    % Q1=plot(x,minusplot);
      hold on
    xlim([-4000 4000])
     ylabel('Cumlative ratio');
    xlabel('Qds [Ckm]');
     legend('Plus', 'Minus')
%     legend([Q1 Q2 Q3 Q4],{'Qds_Ex', 'Qds_Im', 'Qds_It', 'Qds_It_iCMC'},'fontsize',7)
    
    
    grid on
    


           
    %%%%%%%%%%%% Ipk_Distance %%%%%%%%%%%%%%%%%
    Ipk_plot=plot(EN_ELF_box(:,23)/1000,EN_ELF_box(:,14),'o');
    title('Ipk_distance');
    
    xlabel('Distance (ELF) [km]');
    ylabel('Ipk [kA]');
    
    legend([Ipk_plot],{'Ipk-Distance'},'fontsize',7)
    
    grid on
  %%%%%%%%%%%%%%%%%%%% Δθの分布（ヒストグラム）%%%%%%%%%%%%%%%%%%%%%%%%%
  S = std(EN_ELF_box(:,12)); %Δθの標準偏差
  M = mean(EN_ELF_box(:,12)); %Δθの平均値
          % subplot(3,1,1);
           %delta_theta_hist = histogram(EN_ELF_box(:,12),40);
           histogram(EN_ELF_box(:,12),20);
           title('Histogram of Δθ at UMP');
           %title('Histogram of Δθ at' loc_name);
           xlabel('Δθ(ELF-EN) [°]');
           ylabel('Frequency ');
          % xticks([-10:10]);
           xlim([-20 20]);
           xline(M,'r','Average');
           xline(S,'g','σ');
           xline(2*S,'g','2σ');
            xline(-S,'g','σ');
           xline(-2*S,'g','2σ');
           grid on
 %%%%%%%%%%%%%% Δθの補正直線（最小二乗法） %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %  subplot(3,1,2);
           EN_theta = EN_ELF_box(:,11);
           EN_delta_theta = EN_ELF_box(:,12);
           
           %pfit = polyfit(EN_theta, EN_delta_theta,2);
           f= fit(EN_theta, EN_delta_theta,'sin2');
           
           % a_keisuu = sprintf('%02d', pfit(1,1));
           % b_keisuu = sprintf('%02d', pfit(1,2));
%            keisuu = 'a = %02d, b = %02d';
%            a_keisuu = pfit(1,1);
%            b_keisuu = pfit(1,2);
%            str = sprintf(keisuu,a_keisuu,b_keisuu);
          % theta_span = -180:1:180;
     
         % theta_span = 0:1:360;
        %   pfit_line = polyval(pfit,theta_span);
           spacial_plot_1=plot(EN_theta, EN_delta_theta, '.');
           hold on
           spacial_plot_2=plot(f);
           hold on
          %  xlim([-180 180])
          xlim([0 360])
          % ylim([-20 20])
          ylim([-20 20])
           title('Correction of Δθ at UMP');
           %title('Histogram of Δθ at' loc_name);
           xlabel('θ (EN)[°]');
           ylabel('Δθ (ELF-EN)[°]');
           % xticks([-180:180]);
           %yticks([-10:10]);
           %legend('θ (EN)_Δθ (ELF-EN)','Approximate line');
           legend([spacial_plot_1 spacial_plot_2],{'θ (EN)_Δθ (ELF-EN)','Approximate line'},'fontsize',7)
          % annotation('textarrow',theta_span,pfit_line,'String',str);
          % annotation('textarrow',theta_span,pfit_line,'String','a=, b=');
           grid on
              %%%%% save figure %%%%%%%%%%%%%%%%%%
%          saveas( gcf, [figsave_dir '\' YY MM DD '_' loc_name], 'png');


%%%%%%%%%%%%%%%%% ELF/ENの雷イベントの空間分布 %%%%%%%%%%%%%%%%%%%%%%%%%%
      %極性区別なし
% for tt = 1:numel(EN_ELF_box2(:,1))
% if EN_ELF_box2(tt,10) <(lat_max-5)
%         [rad,~,a21]=m_idist(lon_OBS,lat_OBS,EN_ELF_box2(tt,9),EN_ELF_box2(tt,10),'wgs84');  
%         if  EN_ELF_box2(tt,17) ==1
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,EN_ELF_box2(tt,15),rad,'wgs84');
%         elseif EN_ELF_box2(tt,17) == 2 && (0<=EN_ELF_box2(tt,15) && EN_ELF_box2(tt,15)<=90)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,EN_ELF_box2(tt,15)+180,rad,'wgs84');
%         elseif EN_ELF_box2(tt,17) == 2 && (270<=EN_ELF_box2(tt,15) && EN_ELF_box2(tt,15)<=360)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,EN_ELF_box2(tt,15)-180,rad,'wgs84');
%         end
% end
%         
% 
%         MMlon_box(tt,1) = MMlon;
%         MMlat_box(tt,1) = MMlat;
% end
       
%極性別
%正極性
MMlon_boxplus = [];
MMlat_boxplus = [];
MMlon_boxminus = [];
MMlat_boxminus = [];
for tt = 1:numel(event_boxplus(:,1))
        %ELFの座標でプロット
%         [rad,~,a21]=m_idist(lon_OBS,lat_OBS,event_boxplus(tt,9),event_boxplus(tt,10),'wgs84');  
%         if  event_boxplus(tt,17) ==1
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15),rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (0<=event_boxplus(tt,15) && event_boxplus(tt,15)<=90)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)+180,rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (270<=event_boxplus(tt,15) && event_boxplus(tt,15)<=360)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)-180,rad,'wgs84');
%         end
%         MMlon_boxplus(tt,1) = MMlon;
%         MMlat_boxplus(tt,1) = MMlat;
        MMlon_boxplus(tt,1) = event_boxplus(tt,9);
        MMlat_boxplus(tt,1) = event_boxplus(tt,10);
end
%負極性
for tt = 1:numel(event_boxminus(:,1))
%ELFの座標でプロット
%         [rad,~,a21]=m_idist(lon_OBS,lat_OBS,event_boxminus(tt,9),event_boxminus(tt,10),'wgs84');  
%         if  event_boxminus(tt,17) ==1
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxminus(tt,15),rad,'wgs84');
%         elseif event_boxminus(tt,17) == 2 && (0<=event_boxminus(tt,15) && event_boxminus(tt,15)<=90)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxminus(tt,15)+180,rad,'wgs84');
%         elseif event_boxminus(tt,17) == 2 && (270<=event_boxminus(tt,15) && event_boxminus(tt,15)<=360)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxminus(tt,15)-180,rad,'wgs84');
%         end
%         MMlon_boxminus(tt,1) = MMlon;
%         MMlat_boxminus(tt,1) = MMlat;
        MMlon_boxminus(tt,1) = event_boxminus(tt,9);
        MMlat_boxminus(tt,1) = event_boxminus(tt,10);

end
   
 
        m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]); %map data
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]); %coast plot
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[120:10:150]); %grid plot
        hold on
      %ENと比較するとき
%m_plot_1=m_plot( EN_ELF_box2(:,9), EN_ELF_box2(:,10),'x','color','r'); % EN detected location
      
    %極性区別しないとき
      % m_plot_2= m_plot(MMlon_box(:,1),MMlat_box(:,1),'o','color','b'); % ELF detected location
       
       %極性別
       m_plot_plus= m_plot(MMlon_boxplus(:,1),MMlat_boxplus(:,1),'.','color','r'); % ELF detected location
      
       m_plot_minus= m_plot(MMlon_boxminus(:,1),MMlat_boxminus(:,1),'.','color','b'); % ELF detected location
       
       %UMP
       m_plot_3= m_plot(lon_OBS,lat_OBS,'o', 'MarkerFaceColor','black','MarkerSize',10);
       %KL
m_plot_4= m_plot(lon_OBS_KL,lat_OBS_KL,'p', 'MarkerFaceColor','yellow','MarkerSize',10);
      
       
      %極性区別なし
%legend([m_plot_1 m_plot_2 m_plot_3 m_plot_4],{TYPE,'ELF',loc_name,'KL'},'fontsize',7)]);
         %極性別
  legend([m_plot_plus m_plot_minus m_plot_3 m_plot_4],{'Positive','Negative',loc_name,'KL'},'fontsize',7);
         hold on
        title('UMP Lightning location 2018/06/20～22 (Qds Im>50 C km)');
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
        
        
        
        
        %sigma
        x=1:10;
y=[67.8 75.7 77.1 79.4 85.1 87.8 89.2 86.3 89.2 89.4];
plot(x,y);
ylim([0 100])
grid on
 title('ENTLNとHodogramの極性一致率');
    ylabel('極性一致率[%]');
    xlabel('n (空間条件；Δθ>平均＋n*σ)');
    
    
    
    
    %EN map用
    countplus=0;
 countminus=0;
 Plus_box=[];
 Minus_box=[];
for i=1:numel(list(:,1))
       if list(i,10)>=0
           countplus=countplus+1;
           Plus_box(countplus,:)=list(i,:);
       elseif list(i,10)<0
           countminus=countminus+1;
           Minus_box(countminus,:)=list(i,:);
       end       
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]); %map data
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]); %coast plot
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[80:10:120]); %grid plot
        hold on
%極性別
       m_plot_plus= m_plot(Plus_box(:,8),Plus_box(:,7),'.','color','r'); % ELF detected location
      
      % m_plot_minus= m_plot(Minus_box(:,8),Minus_box(:,7),'.','color','b'); % ELF detected location
       
       %UMP
       m_plot_3= m_plot(lon_OBS,lat_OBS,'o', 'MarkerFaceColor','black','MarkerSize',10);
       %KL
m_plot_4= m_plot(lon_OBS_KL,lat_OBS_KL,'p', 'MarkerFaceColor','yellow','MarkerSize',10);
      
       
      %極性区別なし
%legend([m_plot_1 m_plot_2 m_plot_3 m_plot_4],{TYPE,'ELF',loc_name,'KL'},'fontsize',7)]);
         %極性別
  legend([m_plot_plus m_plot_3 m_plot_4],{'Positive',loc_name,'KL'},'fontsize',7);
         hold on
        title('UMP Lightning location 2018/11/20 ');
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
        
        %Qds ImとQds It iCMCの精度比較
        plot(Plus_boxs(:,20),Plus_boxs(:,22),'r.');
        hold on
        plot(Minus_boxs(:,20),Minus_boxs(:,22),'b.');
        hold on
        xlim([-2000 2000])
        ylim([-2000 2000])
         title('Accuracy of Qds Im - Qds It iCMC (dry season) ');
    ylabel('Qds It iCMC[Ckm]');
    xlabel('Qds Im [Ckm]');
    grid on
    
     soukanplus=corr2(Minus_box(:,14),Minus_box(:,20));
     soukanminus=corr2(Plus_box(:,14),Plus_box(:,20));
     
     %Qds ImとQds It iCMCの精度比較2(ヒストグラム)
     
     histogram((EN_ELF_box1s(:,22)./EN_ELF_box1s(:,20)).*100,5000);
     xlim([0 1000])
         title('Ratio of Qds It iCMC to Qds Im (dry season) ');
    ylabel('Count');
    xlabel('Qds It iCMC / Qds Im [%]');
    grid on
    
    
    %%% 1時間ごとのENの落雷数のヒストグラムとQdsの中央値(Im)とIp(EN)の中央値の折れ線グラフ
    %まずイベント数とIpのリストを作る
    %リスト読み込んで．．．
    time=[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23];
    event_num=[];
    Ip_median_plus=[];
    Ip_median_minus=[];
    for i=1:numel(time(1,:))
        x=0;
        k=0;
        m=0;
        Ip_list_plus=[];
        Ip_list_minus=[];
    for j=1:numel(list(:,4))
        if list(j,4)==time(1,i)
            x=x+1;
            if list(j,10)>0
            k=k+1;
            Ip_list_plus(1,k)=abs(list(j,10)/1000);
            elseif list(j,10)<0
                m=m+1;
            Ip_list_minus(1,m)=abs(list(j,10)/1000);
        end
        end
    end
    if numel(Ip_list_plus(1,:))==0 || numel(Ip_list_minus(1,:))==0
        continue
    end
     event_num(1,i)=x;
    Ip_median_plus(1,i)=median(Ip_list_plus(1,:),2);
    Ip_median_minus(1,i)=median(Ip_list_minus(1,:),2);
    end
    
    %%% Qdsのリストを作る
        time=[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23];
    
    Qds_median_plus=[];
    Qds_median_minus=[];
    for i=1:numel(time(1,:))
    
        k=0;
        m=0;
        Qds_list_plus=[];
        Qds_list_minus=[];
    for j=1:numel(EN_ELF_box1s(:,20))
        if list(j,5)==time(1,i)

            if EN_ELF_box1s(j,20)>0
            k=k+1;
            Qds_list_plus(1,k)=abs(EN_ELF_box1s(j,20));
            elseif EN_ELF_box1s(j,20)<0
                m=m+1;
            Qds_list_minus(1,m)=abs(EN_ELF_box1s(j,20));
        end
        end
    end
    if numel(Qds_list_plus(1,:))==0 || numel(Qds_list_minus(1,:))==0
        continue
    end

    Qds_median_plus(1,i)=median(Qds_list_plus(1,:),2);
    Qds_median_minus(1,i)=median(Qds_list_minus(1,:),2);
    end
    
        
    
    %%%Qdsの中央値の折れ線
    title('Median for Qds-Ip, event num in each hour (dry seasons)')
    xlabel('Time (UT)');
    
   yyaxis left
   %%%イベント数のヒストグラムをプロット
    eventbar=bar(time,event_num/100,'FaceColor','#EDB120');
    hold on
    
    Qds_plus_line=plot(time,Qds_median_plus,'r--o');
    hold on
    Qds_minus_line=plot(time,Qds_median_minus,'b--o')
    hold on
      
    ylabel('Qds Im [Ckm]');
    %%%Ipkの中央値の折れ線
    yyaxis right
    ylim([0 120])
    ylabel('Ip [kA]');
    Ip_plus_line=plot(time,Ip_median_plus,'r-o','MarkerFaceColor','r');
    hold on
    Ip_minus_line=plot(time,Ip_median_minus,'b-o','MarkerFaceColor','b')
    hold on
    legend([Qds_plus_line Qds_minus_line Ip_plus_line Ip_minus_line eventbar],{'Median for Qds Im (+)','Median for Qds Im (-)','Median for Ip (+)','Median for Qds Im (-)','Event Number'},'fontsize',7,'Location','SouthEast');
  
    grid on

    
%%        %%%%%%%%%%%%%%%%%　東電用　%%%%%%%%%%%%%%%%%%%%
        %Excel未出力の場合はここから
        T = cell2table(EN_ELF_box,...
            'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'LLS_Lightning_Location_Lon' 'LLS_Lightning_Location_Lat' 'LLS_Lingtning_Direction' 'LLS_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'LLS_pol_equal_ELF_transient_pol_if_equal_1' 'LLS_pol_equal_Hodogram_pol_if_equal_1' 'LLS_TYPE'});
        filename = '202009.xlsx';
        writetable(T,filename);
        %Excelデータを読み込んで
        data={};
        data_pre=readcell('202009.xlsx');
        data=data_pre(2:length(data_pre),:);
        sigmaELF=2;
        count=0;
        data_comp={};
        for i=1:length(data)
            % 2σと10°以内の条件を満たすイベントのみで再構成して
            if data{i,28}>data{i,26}+sigmaELF*data{i,27} & data{i,15} <= 10 & data{i,35} == '*AALG'
                count=count+1;
                data_comp(count,:)=data(i,:);
            end
        end
%CellをTableに変換
T = cell2table(data_comp,...
    'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'LLS_Lightning_Location_Lon' 'LLS_Lightning_Location_Lat' 'LLS_Lingtning_Direction' 'LLS_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'LLS_pol_equal_ELF_transient_pol_if_equal_1' 'LLS_pol_equal_Hodogram_pol_if_equal_1' 'LLS_TYPE'});
%Excelで再度保存 (累積分布，メッシュマップ用)
filename = '202009re.xlsx';
writetable(T,filename);

%空間分布用
data_box=cell2mat(data_comp(:,1:34));
EN_ELF_box1w=[];
EN_ELF_box1w=data_box;

%空間分布整理後
%% 正極
MMlon_boxplus = [];
MMlat_boxplus = [];
MMlon_boxminus = [];
MMlat_boxminus = [];
for tt = 1:numel(event_boxplus(:,1))
        %ELFの座標でプロット
%         [rad,~,a21]=m_idist(lon_OBS,lat_OBS,event_boxplus(tt,9),event_boxplus(tt,10),'wgs84');  
%         if  event_boxplus(tt,17) ==1
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15),rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (0<=event_boxplus(tt,15) && event_boxplus(tt,15)<=90)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)+180,rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (270<=event_boxplus(tt,15) && event_boxplus(tt,15)<=360)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)-180,rad,'wgs84');
%         end
%         MMlon_boxplus(tt,1) = MMlon;
%         MMlat_boxplus(tt,1) = MMlat;
        MMlon_boxplus(tt,1) = event_boxplus(tt,12);
        MMlat_boxplus(tt,1) = event_boxplus(tt,13);
end
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]); %map data
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]); %coast plot
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[138:2:142]); %grid plot
        hold on
m_plot_plus= m_plot(MMlon_boxplus(:,1),MMlat_boxplus(:,1),'.','color','r'); % ELF detected location
m_plot_3= m_plot(lon_OBS,lat_OBS,'o', 'MarkerFaceColor','black','MarkerSize',5);
legend([m_plot_plus m_plot_3],{'Positive',loc_name},'fontsize',7);
         hold on
        title('2020年09月の落雷空間分布<正極性>(Qds > 750 Ckm)');
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
        
        
        %% 負極
MMlon_boxplus = [];
MMlat_boxplus = [];
MMlon_boxminus = [];
MMlat_boxminus = [];
for tt = 1:numel(event_boxminus(:,1))
        %ELFの座標でプロット
%         [rad,~,a21]=m_idist(lon_OBS,lat_OBS,event_boxplus(tt,9),event_boxplus(tt,10),'wgs84');  
%         if  event_boxplus(tt,17) ==1
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15),rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (0<=event_boxplus(tt,15) && event_boxplus(tt,15)<=90)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)+180,rad,'wgs84');
%         elseif event_boxplus(tt,17) == 2 && (270<=event_boxplus(tt,15) && event_boxplus(tt,15)<=360)
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,event_boxplus(tt,15)-180,rad,'wgs84');
%         end
%         MMlon_boxplus(tt,1) = MMlon;
%         MMlat_boxplus(tt,1) = MMlat;
        MMlon_boxminus(tt,1) = event_boxminus(tt,12);
        MMlat_boxminus(tt,1) = event_boxminus(tt,13);
end
m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]); %map data
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]); %coast plot
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[138:2:142]); %grid plot
        hold on
m_plot_minus= m_plot(MMlon_boxminus(:,1),MMlat_boxminus(:,1),'.','color','b'); % ELF detected location
m_plot_3= m_plot(lon_OBS,lat_OBS,'o', 'MarkerFaceColor','black','MarkerSize',5);
legend([m_plot_minus m_plot_3],{'Negative',loc_name},'fontsize',7);
         hold on
        title('2020年09月の落雷空間分布<負極性>(Qds > 880 Ckm)');
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
        
 %% 3点重心法のプロット
 
 % イベントの番号を指定
 num = 1;
 TYPE='LLS';
 loc_name_tru='TRU';
 loc_name_rkb='RKB';
 loc_name_koz='KOZ';
 
 lat_min = 30;     % 緯度の最小値
 lat_max = 50;     % 緯度の最大値
 lon_min = 120;    % 経度の最小値
 lon_max = 150;    % 経度の最大値
 
 lat_OBS_tru = 31.49;
 lon_OBS_tru = 130.70;
 lat_OBS_rkb = 43.27;
 lon_OBS_rkb = 143.43;
 lat_OBS_koz = 34.131;
 lon_OBS_koz = 139.915;
 
 tru_pre=readcell('3way_tru.xlsx');
 tru={};
 tru=tru_pre(2:length(tru_pre(:,1)),:);
 
 lon = tru{num,12};
 lat = tru{num,13};
 
 Mlat_tru = [lat;lat_OBS_tru];
 Mlon_tru = [lon;lon_OBS_tru];
 Mlat_rkb = [lat;lat_OBS_rkb];
 Mlon_rkb = [lon;lon_OBS_rkb];
 Mlat_koz = [lat;lat_OBS_koz];
 Mlon_koz = [lon;lon_OBS_koz];
 
 
%   MMlat_tru = tru{num,37};
%   MMlon_tru = tru{num,36};
%  MMMlat_tru = [MMlat_tru;lat_OBS_tru];
%  MMMlon_tru = [MMlon_tru;lon_OBS_tru];
 
 rkb_pre=readcell('3way_rkb.xlsx');
 rkb={};
 rkb=rkb_pre(2:length(rkb_pre(:,1)),:);
%  MMlat_rkb = rkb{num,37};
%  MMlon_rkb = rkb{num,36};
%  MMMlat_rkb = [MMlat_rkb;lat_OBS_rkb];
%  MMMlon_rkb = [MMlon_rkb;lon_OBS_rkb];
 
 koz_pre=readcell('3way_koz.xlsx');
 koz={};
 koz=koz_pre(2:length(koz_pre(:,1)),:);
%  MMlat_koz = koz{num,37};
%  MMlon_koz = koz{num,36};
%  MMMlat_koz = [MMlat_koz;lat_OBS_koz];
%  MMMlon_koz = [MMlon_koz;lon_OBS_koz];
 hold on
 
 m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]);
 m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]);
 m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[120:10:150]);
 
 theta_h_hosei_tru = tru{num,17};
 theta_h_hosei_rkb = rkb{num,17};
 theta_h_hosei_koz = koz{num,17};

 [lat_rkb_tru_pre,lon_rkb_tru_pre] = gcxgc(lat_OBS_rkb,lon_OBS_rkb,theta_h_hosei_rkb,lat_OBS_tru,lon_OBS_tru,theta_h_hosei_tru);
  [lat_rkb_koz_pre,lon_rkb_koz_pre] = gcxgc(lat_OBS_rkb,lon_OBS_rkb,theta_h_hosei_rkb,lat_OBS_koz,lon_OBS_koz,theta_h_hosei_koz);
   [lat_tru_koz_pre,lon_tru_koz_pre] = gcxgc(lat_OBS_koz,lon_OBS_koz,theta_h_hosei_koz,lat_OBS_tru,lon_OBS_tru,theta_h_hosei_tru);
lat_rkb_tru=lat_rkb_tru_pre(1,lat_rkb_tru_pre>0);
lon_rkb_tru=lon_rkb_tru_pre(1,lon_rkb_tru_pre>0);
lat_rkb_koz=lat_rkb_koz_pre(1,lat_rkb_koz_pre>0);
lon_rkb_koz=lon_rkb_koz_pre(1,lon_rkb_koz_pre>0);
lat_tru_koz=lat_tru_koz_pre(1,lat_tru_koz_pre>0);
lon_tru_koz=lon_tru_koz_pre(1,lon_tru_koz_pre>0);

MMMlat_koz = [lat_rkb_koz;lat_OBS_koz];
MMMlon_koz = [lon_rkb_koz;lon_OBS_koz];
MMMlat_rkb = [lat_rkb_tru;lat_OBS_rkb];
MMMlon_rkb = [lon_rkb_tru;lon_OBS_rkb];
MMMlat_tru = [lat_tru_koz;lat_OBS_tru];
MMMlon_tru = [lon_tru_koz;lon_OBS_tru];
%  m_line(Mlon_tru,Mlat_tru,'color','r');
 m_line(MMMlon_tru,MMMlat_tru,'color','b');
%  m_line(Mlon_rkb,Mlat_rkb,'color','r');
 m_line(MMMlon_rkb,MMMlat_rkb,'color','b');
%  m_line(Mlon_koz,Mlat_koz,'color','r');
 m_line(MMMlon_koz,MMMlat_koz,'color','b');
 
 tri1_lon = [lon_rkb_tru;lon_rkb_koz];
 tri2_lon = [lon_tru_koz;lon_rkb_koz];
 tri3_lon = [lon_rkb_tru;lon_tru_koz];
 tri1_lat = [lat_rkb_tru;lat_rkb_koz];
 tri2_lat = [lat_tru_koz;lat_rkb_koz];
 tri3_lat = [lat_rkb_tru;lat_tru_koz];
 m_line(tri1_lon,tri1_lat,'color','b');
 m_line(tri2_lon,tri2_lat,'color','b');
 m_line(tri3_lon,tri3_lat,'color','b');
 
 hold on
 
 p_l_1 = m_plot(lon,lat,'.','color','r');
 hold on
 
 p_l_2_tru = m_plot(lon_rkb_tru,lat_rkb_tru,'.','color','b');
 p_l_2_rkb = m_plot(lon_rkb_koz,lat_rkb_koz,'.','color','b');
 p_l_2_koz = m_plot(lon_tru_koz,lat_tru_koz,'.','color','b');
 
 p_l_3_tru = m_plot(lon_OBS_tru,lat_OBS_tru,'.','color','k');
 p_l_3_rkb = m_plot(lon_OBS_rkb,lat_OBS_rkb,'.','color','k');
 p_l_3_koz = m_plot(lon_OBS_koz,lat_OBS_koz,'.','color','k');
 
 centerpoint_lon=(lon_rkb_tru+lon_rkb_koz+lon_tru_koz)/3;
 centerpoint_lat=(lat_rkb_tru+lat_rkb_koz+lat_tru_koz)/3;
 p_l_4=m_plot(centerpoint_lon,centerpoint_lat,'.','color','g');
 hold on
 legend([p_l_1 p_l_2_tru  p_l_4 p_l_3_tru p_l_3_rkb p_l_3_koz],{TYPE,'ELF','Center of Gravity',loc_name_tru,loc_name_rkb,loc_name_koz},'fontsize',7)
 hold on
 title(['ELF観測点3点による重心三角形法 (イベント：2020年9月16日' num2str(rkb{num,5},'%02d') ':' num2str(rkb{num,6},'%02d') ':' num2str(rkb{num,7},'%02d') ':' num2str(rkb{num,8},'%06d') ')']);
 xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
 ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
 
 %% LLS描画
  m_proj('miller','lon',[lon_min lon_max],'lat',[lat_min lat_max]); %map data
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]); %coast plot
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick', [120:10:150]); %grid plot
        hold on
       m_plot_1=m_plot(list(:,9),  list(:,8),'o','color','b'); % EN detected location
       m_plot(lon_OBS,lat_OBS,'.','color','r'); % Observation location
         legend(m_plot_1,'LLS','fontsize',7)
         hold on
        title('LLS Lightning location 2020/07/26');
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);