%% ELF Single Station Method -> ELF_Single_Station.m By Akama Shunsuke
%% Modified Ver. 2021/02/17 latest: 2021/05/20
%% Input: LLS/JTLN/WWLLN/ENTLN is accepted
%% ELF Station; RKB/KOZ/TRU/UMP
%% Need to check Hφ Usage: Hns and Hew/ Hns only / Hew only
%% Decide Analysis Period: from yyyy/mm/dd to yyyy/mm/dd

%% ELFデータスロット：DATA\1908\~~~~~.012のようなフォルダ構造にする（332行目付近参照）
%% 2019年→'\19', 2020年→'\20'に変更する必要あり(177行目)
%% LLS：DATA\2020\08\~~~~.datのようなフォルダ構造にする必要あり (177行目) ENも同様
%% 落雷標定情報によってEN_ELF_box(解析データ格納box)の中身を変える必要あり(1043行目)
%% 1117行目，EN_ELF_boxのパラメータ数に応じて変更
%% ELF3点重心法でやる場合はMMlon,MMlatを.matファイルの保存内容に加える(1126,1290,1353行目付近)
clear all
close all;
fclose('all');
%% パス追加
figsave_dir = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\RESULTS\';%イベントシート・解析用matファイルの保存先
%longfilename = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\RESULTS\'; % save position
%addpath('C:\Users\hobara-laboratory\Desktop\MATLAB\研究\解析\DEVELOP\m_map\');

%% データのある場所のパスを追加
% WWLLN_file_name = 'C:\Users\hirai\Desktop\DATA\WWLLN\2019\AE2019';
EN_file_name = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\DATA\ENTLN\';
ELF_data_name = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\DATA\ELF\';
LLS_file_name = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\DATA\LLS\';
%%%%%%%%%%%%%%%%% Akama add %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LLS_file_name=['C:\Users\Hobara\Desktop\TEPCO\DATA\LLS_DATA\LLS_20190804b.txt']; %一つずつ処理用


%% データの準備
Data_Type = input('比較対象を選択(WWLLN:1,EN:2,LLS:3): ');
START = input('開始[年/月/日]: ','s');
END = input('終了[年/月/日]: ','s');
LOC = input('ELF観測点を選択(ump:1,TRU:2,KOZ:3,RKB:4)：');
H_usage = input('使用できる水平方向磁場成分を選択(Hns/Hew:1,Hns:2,Hew:3): ');
BROKEN=input('Voltage波形が壊れていて，かつ係数の補正は完了していますか(YES:1,NO:0)：');
%type = input('台風15or19号？: ');
STA_DT = datetime(START ,'InputFormat','yyyy/MM/dd');
END_DT = datetime(END,'InputFormat','yyyy/MM/dd');

smpf=4000;
cutofffreq=200;
%% ELF観測点の選択
if LOC == 1
    loc_name = 'UMP';
    % UMP表示範囲
    lat_min = 10;     % 緯度の最小値
    lat_max = 20;     % 緯度の最大値
    lon_min = 110;    % 経度の最小値
    lon_max = 120;    % 経度の最大値
    %%% UMP観測点の緯度経度
    lat_OBS = 3.546819;
    lon_OBS = 103.427;
    dataname_path = '.ump';
elseif LOC==2
    loc_name = 'TRU';
    % 日本国内
    lat_min = 10;     % 緯度の最小値
    lat_max = 20;     % 緯度の最大値
    lon_min = 110;    % 経度の最小値
    lon_max = 120;    % 経度の最大値
    %%% 垂水の緯度経度
    lat_OBS = 31.49;
    lon_OBS = 130.70;
    dataname_path = '.uec';
elseif LOC==3
    loc_name = 'KOZ';
    % 日本国内
    lat_min = 30;     % 緯度の最小値
    lat_max = 50;     % 緯度の最大値
    lon_min = 120;    % 経度の最小値
    lon_max = 150;    % 経度の最大値
    %%% KOZの緯度経度
    lat_OBS = 34.131;
    lon_OBS = 139.915;
    dataname_path = '.koz';
elseif LOC==4
    loc_name = 'RKB';
    % 日本国内
     lat_min = 30;     % 緯度の最小値
    lat_max = 50;     % 緯度の最大値
    lon_min = 120;    % 経度の最小値
    lon_max = 150;    % 経度の最大値
    %%% RKBの緯度経度
    lat_OBS = 43.27;
    lon_OBS = 143.43;
    dataname_path = '.012';
end
p = 0;
Q_ds_irai = [];
Q_ds_comp = [];
EN_ELF_box = {};
event_count=0;
EN_list=[];
%ELF_Dir_box = [];
%Delta_theta_box = [];
mapday=0;

%% 落雷標定データ1日ごとに解析
for date = STA_DT : caldays(1) : END_DT 
    pp = 0;
    Qds_list = [];
    list = [];
    Day_check=0;
%% WWLLNデータ読み込み
    if Data_Type == 1
        % WWLLNデータの読み込み
        list = load([WWLLN_file_name Mon_str(str2num(datestr(date,'mm'))) Day_str(str2num(datestr(date,'dd'))) '.mat']);
        list = list.data;
    end
%% ENTLNデータ読み込み
    if Data_Type == 2
        % JTLNデータの読み込み
        EN_file_name_1 = [EN_file_name datestr(date,'yyyy') '\' datestr(date,'mm') '\LtgFlashPortions' datestr(date,'yyyymmdd') '.csv'];
        fileID = fopen(EN_file_name_1);
        
        %if EN day-data is not exist, continue
        if fileID==-1
            continue
        end
        
        if exist(EN_file_name_1) ~= 0
            data_text = textscan(fileID,'%*s %*s %*s %*s %s %s %s %*s %s %s %*[^\n]',1,'Delimiter',',');
            data = textscan(fileID,'%*f %*q %*q %*q %q %f %f %*f %f %f %*[^\n]','Delimiter',',','HeaderLines',1);
            fclose('all');
            count = 0;
            C={};
            for i=1:size(data{1},1)
                if data{2}(i)>=(lat_min) & data{2}(i)<=(lat_max) & data{3}(i)>=(lon_min) & data{3}(i)<= (lon_max)
                    count = count +1;
                    C(count,:) = [data{1}(i), data{2}(i), data{3}(i), data{4}(i), data{5}(i)];
                end
            end
        end
        DDD={};
        DDD_1={};
        DDD_2={};
        DDD = split(C(:,1),"T");
        DDD_1 = split(DDD(:,1),"-");
        DDD_2 = split(DDD(:,2),":");
        % EN読みだしたファイルのフォーマット整理
        for num =1:length(DDD)
             if (C{num,3}<lon_min)||(C{num,3}>lon_max)||( C{num,2}<lat_min)||( C{num,2}>lat_max)
            continue
             end
 if C{num,4} == 1
                continue
           end
            list(num,1) = str2num(DDD_1{num,1}); 						% Copy Data for softing and checking, doesnt affect original data
            list(num,2) = str2num(DDD_1{num,2}); 						% Var equal variable
            list(num,3) = str2num(DDD_1{num,3});
            list(num,4) = str2num(DDD_2{num,1});
            list(num,5)= str2num(DDD_2{num,2});
            list(num,6) = str2double(DDD_2{num,3});
            list(num,7) = C{num,2};               % latitude
            list(num,8) = C{num,3};               % longitude
            list(num,9) = C{num,4};               % StrokeType
            list(num,10) = C{num,5};              % Amplitude
        end
        countcount=0;
        listpost=[];
         for zerocheck=1:size(list(:,1))
        if list(zerocheck,1)==0
            continue
        %elseif list(zerocheck,1)~=0 & (list(zerocheck,4)==7 || list(zerocheck,4)==8)
        elseif list(zerocheck,1)~=0 
            countcount=countcount+1;
            listpost(countcount,:)=list(zerocheck,:);
       end
         end
    list=[];
    list=listpost;
   listkai=listcorrect(list);
   list=[];
   list=listkai;
    end
%% LLSデータ読み込み
    % Need to add as like ENTLN read
    if Data_Type == 3
        LLS_file_name_1 = [LLS_file_name datestr(date,'yyyy') '\' datestr(date,'mm') '\20' datestr(date,'mmdd') '.dat'];
         %if EN day-data is not exist, continue
       
        fid=fopen(LLS_file_name_1);
         %if EN day-data is not exist, continue
        if fid==-1
            continue
        end
        if exist(LLS_file_name_1) ~= 0
        list1=fscanf(fid,'%s %s %2d/%2d/%2d %2d:%2d:%2d.%7d %s %f %s %f %4s %f%s %s %d %d %d %d',[33 Inf]);
        list1=list1';
         fclose('all');
        % LLS 読みだしたファイルのフォーマット整理
        list(:,1)=list1(:,8); %yy
        list(:,2:3)=list1(:,6:7); %mmdd
        list(:,4:6)=list1(:,9:11); %hhmmss
        list(:,7)=list1(:,12)/10000; %ms.000
        list(:,8)=list1(:,17); %lat
        list(:,9)=list1(:,22); %lon
        list(:,10)=list1(:,27); %Ip
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    %% Qdsの導出用
    %%% 特定時間用 %%%%%%%
%     EN_select_box=[];
%     listnum_count=0;
%     for listnum=1:size(list,1)
%         if list(listnum,4)==6 %好きな時間だけ読む
%             listnum_count=listnum_count+1;
%              EN_select_box(listnum_count,:)=list(listnum,:);
%         end
%     end
%     list=EN_select_box;
    %%%%%%%%%%%%%%%%%%%%%%%
        % EN_ELF_box = zeros(size(list,1),35);
   %  for number=1:size(list,1) %普段用
%% 落雷標定情報１イベントごとに解析    
   %for number = 23865:23970 % 特定イベントで出力確認(時短)
  for number=1:size(list,1)% 本解析用
       Map_check=0;%到来方位推定のif文対応
       
        if Data_Type == 2
        yy=list(number,1)-2000; %年
        mm=list(number,2); %月
        dd=list(number,3); %日
        th=list(number,4); %時
        tm=list(number,5); %分
        ts=floor(list(number,6)); %秒
        tms=list(number,6)*1000-ts*1000; %ミリ秒
        tns=list(number,6)*1000000000-ts*1000000000; %ナノ秒
        lat=list(number,7);  % ENの緯度
        lon=list(number,8);  % ENの経度
        end
        if Data_Type == 1
            % WWLLNで測定されたエネルギー
            Ene=list(number,11);
        end
        if Data_Type == 2
            % ENで測定されたエネルギー
            Stroke=list(number,9);
            Cur=list(number,10);
            %イベントシート用
            LLS_TYPE = 'not LLS';
        end
 %% LLS
        if Data_Type == 3
            LLS_TYPE =  char (list1(number,1:5)); % LLS (TEPCO), Performance
            %G:対地放電
            %C:雲放電
            %Lは精度良し　⇒４局以上で観測
            %F:精度良くないー観測点少ない？　⇒観測が３局以下
            %L：近距離（信頼性があり　かつ　134-144/32-42の範囲内）
            %D：遠距離（信頼性があり　かつ　134-144/32-42の範囲外）
            
            yy_LT=list(number,1); %年 >20200801 LT
            mm_LT=list(number,2); %月 >20200801 LT
            dd_LT=list(number,3); %日 >20200801 LT
            th_LT=list(number,4); %時 >20200801 LT
            tm=list(number,5); %分
            ts=list(number,6); %秒
            tms=list(number,7); %ミリ秒
            tns=tms*10^6; %ナノ秒
            
            %LTからUTへ変換   ---> 20200801 CK  > Need revision for the case of dd=0
            yy_LT=yy_LT+2000;
            dtime = datetime([yy_LT mm_LT dd_LT th_LT tm ts],'TimeZone','local');
            %タイムゾーンの変更
            dtime.TimeZone = '+00:00';
            
            yy= year(dtime) - 2000;
            mm=month(dtime);
            dd=day(dtime);
            th=hour(dtime);
            
            lat=list(number,8);
            lon=list(number,9);
            Ip=list(number,10);        
            %     YY = sprintf('%02d', yy);
            % 	MM= sprintf('%02d', mm);
            % 	DD  = sprintf('%02d', dd);
            %
            % 	TH = sprintf('%02d', th);
            % 	TM  = sprintf('%02d', tm);
            % 	TS  = sprintf('%02d', ts);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%         if (lon<lon_min)||(lon>lon_max)||(lat<lat_min)||(lat>lat_max)
%             disp('解析対象外');
%             continue
%         end        
        YY = sprintf('%02d', yy);
        MM= sprintf('%02d', mm);
        DD  = sprintf('%02d', dd);
        
        TH = sprintf('%02d', th);
        TM  = sprintf('%02d', tm);
        TS  = sprintf('%02d', ts);
        
        if(str2num(TM)>=0 && str2num(TM)<10)
            TM_1 = '00';
        end
        if(str2num(TM)>=10 && str2num(TM)<20)
            TM_1 = '10';
        end
        if(str2num(TM)>=20 && str2num(TM)<30)
            TM_1 = '20';
        end
        if(str2num(TM)>=30 && str2num(TM)<40)
            TM_1 = '30';
        end
        if(str2num(TM)>=40 && str2num(TM)<50)
            TM_1 = '40';
        end
        if(str2num(TM)>=50 && str2num(TM)<60)
            TM_1 = '50';
        end
        
        
%% 解析用にENTLN/LLS/WWLLNのデータを保存しておく
       if exist([figsave_dir 'LLS\20' YY],'dir')==0
            mkdir([figsave_dir 'LLS\20' YY])
        end
        if exist([figsave_dir 'LLS\20' YY '\' MM],'dir')==0
            mkdir([figsave_dir 'LLS\20' YY '\' MM])
        end
        if exist([figsave_dir 'LLS\20' YY '\' MM '\' DD],'dir')==0
            mkdir([figsave_dir 'LLS\20' YY '\' MM '\' DD])
        end
     
     save([figsave_dir 'LLS\20' YY '\' MM '\' DD '\' YY MM DD '.mat'],'list');
        
        
        
%% ELFデータスロットの読み出し
        %%%%%%%%%%%%% ELFの読み込みは開始～終了期間を決めて１日単位 (ファイルは10minごと) %%%%%%%%%%%%%%%%%%%%
        %         ELF_dir=[ELF_data_name '\20' YY '\' MM '\' DD '\']; %yyyy/mm/dd
        ELF_dir=[ELF_data_name YY MM '\']; %yyyy/mm/dd
        ELF_folder=[ELF_data_name YY MM];
        
        %check to exist folder
        if exist(ELF_folder,'dir') ~=7
            continue
        end
        
        ELF_file_name=['f' YY MM DD TH TM_1 dataname_path];
        file_R=[ELF_dir ELF_file_name];
        
        if isfile(file_R)~=1 %ファイル存在しなかったら次
%             disp('データなし');
            continue
        end
%         disp('データ取得');
        tm_nine = [09 19 29 39 49 59];
        tm_zero = [0 10 20 30 40 50];
        fftsizeE=1024;
        fftsize=1000;
        sf=4000;
        f=sf*(1:(fftsize))/fftsize;
        
        ITDS2 = It_integral_forELF2; % iCMC計算用 2019/10/16
        ITDS = It_integral_forELF;
        %Hns用
        Hns_ITDS = It_integral_forELF;
        Hns_ITDS2 = It_integral_forELF2;
        %Hew用
        Hew_ITDS = It_integral_forELF;
        Hew_ITDS2 = It_integral_forELF2;
%% ここからイベント
        
        %         for number = 251
        
        Qds_Ex=zeros(length(list(:,1)),10);
        Qds_Im=zeros(length(list(:,1)),10);
        index=zeros(length(list(:,1)),10);
        pa2=zeros(length(list(:,1)),1);
        
        eventtime=ut2ms([th tm ts tms]);  %%%% ut2msという関数で落雷イベントタイムをミリ秒にしている
        
        
        NNNN = [TH ':' TM ':' TS];
        %%%%%%%%%%%%%%%%
        
        name=[num2str(yy),num2str(mm,'%02d'),num2str(dd,'%02d'),'-',num2str(th,'%02d'),...
            num2str(tm,'%02d'),num2str(ts,'%02d'),'-',num2str(tns,'%06d')];  %%%% 最後の図の導出に使う名前
        
%% ここからELFトランジェント%%%%%%% ここに松井さんの作った関数
        S_HOUR   = sprintf('%02d',th);
        S_MINUTE = num2str(tm);
        if tm < 10
            S_MINUTE = ['0' S_MINUTE];
        end
        
        %%%%%% 暫定的に、とりあえずイベントを増やすのに邪魔なので切る
        tm_member1 = find(ismember(tm_nine,tm)==1);
        tm_member2 = find(ismember(tm_zero,tm)==1);
        if isempty(tm_member2) == 0 && ts < 2
            continue
        elseif isempty(tm_member1) == 0 && ts > 57
            continue
            
        end

%%        
        evtime = 3600*th + 60*tm + ts;  %%%% 落雷イベント時刻を秒に直す
        format long
        
        START_TIME = '2';  %%%% イベント時刻から±2秒とってる。
        END_TIME = '2';
        
        s_time = str2num(START_TIME);
        e_time = str2num(END_TIME);
        
        %             if ts < 5                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%自作部分
        %                 s_time = ts;
        %             elseif th == 23 && tm == 59 && 55 <= ts                         %%%発生時刻が日にち境界±5s以内のとき
        %                 e_time = 60 - ts;
        %             end
        
        start_time = evtime - s_time;   %%%% 落雷イベント発生時刻から±2秒
        end_time = evtime + e_time;
        
        if start_time <= 0  %%%% スタートタイムが0時0分を下回るとダメ
            continue
            
        end
        if end_time >= 86400  %%%% エンドタイムが24時0分を超えるとダメ
            continue
            
        end
        
        if start_time <= 0  %%%% スタートタイムが0時0分を下回るとダメ
            continue
            
        end
        
        if start_time<(3600*str2double(ELF_file_name(8:9)) + 60*str2double(ELF_file_name(10:11)))  %%%% スタートタイムがファイルの先頭の秒数を下回るとダメ
            continue
            
        end
        
%% ELFバイナリデータ読み込み
if BROKEN ==0
        [B,time] = process_kai08_func(file_R,ELF_file_name, start_time, end_time);
end
if BROKEN == 1
      [B,time] = process_kai08_func_verRKU_error(file_R,ELF_file_name, start_time, end_time);
end
        %         [B,time] = process_kai04_func([ELF_dir ELF_file_name]);
        
        %         if str2num(Gain{1,1}) > 0
        %             disp('Gain見直した方がいい');
        %         end
        
        %%%% need to check gain by ELF data header %%%%%
%         if LOC==4
%                     B = B/32;  %%%% 陸別はゲイン32倍にしてる。
%         end
%% B=2.5Vに係数補正
%           Sens= 0.4 ; % Sens= 0,4 [V/nT] = 400 mV/nT -> B=5*(V [V])  [nT]
%             B = B./Sens ;   % Transform to nT from logger out [V]
        B = B .* 2.5;
        
        tsec=[1:length(B)].*0.00025+start_time;
        Ez(1,1:length(B)) = 99999; %ダミー
        
        %%%% ELFデータから求めたデータを変数に格納 & それを少し計算していくつか値を出す %%%%
        Bns=B(1,:)';%B:North and south component in nT
        Bew=B(2,:)';%B:East and west component in nT
        %         Ez=Ez(:)';%Ez-component
        Ez=Ez(1,:)';%Ez-component
        
        Mu0 = 4*pi*1e-7;
        ez = Ez;
        
        hns = Bns/Mu0*1e-9 - nanmean(Bns/Mu0*1e-9);
        hew = Bew/Mu0*1e-9 - nanmean(Bew/Mu0*1e-9);
        t = tsec;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ↑ELF%%%%%%%%%%%%%%%%%%
        
%% ノッチフィルタ 
        if LOC == 2
        ez=func_notch_westjp_00(ez,sf,1000);
        hns=func_notch_westjp_00(hns,sf,1000);
        hew=func_notch_westjp_00(hew,sf,1000);
        else
            ez=func_notch_eastjp_00(ez,sf,1000);
        hns=func_notch_eastjp_00(hns,sf,1000);
        hew=func_notch_eastjp_00(hew,sf,1000);
        end
        peak_B = B;
        peak_H = B/(4*0.0000001*pi)*0.000000001*1000000;
        %%%% 対象のトランジェントタイムを決めていく
        elftime = (t*1e3)';
        ind=find(elftime==floor(eventtime));
        %         [B,A] = butter(5,cutofffreq/(smpf/2),'low'); % low pass filter is performed by butterworth.
        %         ez=filtfilt(B,A,ez);
        %         hns=filtfilt(B,A,hns);
        %         hew=filtfilt(B,A,hew);
        Mean_ez = mean(ez);
        Std_ez = std(ez);
        %if need Ez, USE THIS
       % ez = ez-Mean_ez;
       
%% ステーションによってはHns/Hewが逆になっているので変更
%         hns=hns-mean(hns);
%         hew=hew-mean(hew);
        
        if LOC==1 %UMP
        hew=-hew;
        elseif LOC==4 %RKB
            hns=-hns;
        end
        
%% ダミートランジェント用に係数をつける
%         hns=5*hns;
%         hew=0.1*hew;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%         hns=hns-mean(hns);
%         hew=hew-mean(hew);
        
        HH = sqrt(hns.^2 + hew.^2);
        Mean_HH = mean(HH);
        Std_HH = std(HH);
        
%% 判定範囲（ELFトランジェントがイベント時刻からどれだけの範囲にあると仮定するか）%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hani = 40;  %%%%% ここで範囲決める　4000なら1秒,400なら0.1秒(100ms)…（0.00025倍）
        Elftime = elftime(ind-hani:ind+hani);
        fff = find(HH(ind-hani:ind+hani)==max(HH(ind:ind+hani))); %%HH(ind-hani:ind+hani)っていう(hani*2+1)×1の配列のうちのfff番目がHHの最大ということ
        %%%% max(HH(ind:ind+hani))はイベント時刻よりELFトランジェントが必ず後にあることを仮定している
        %%%% max(HH(ind-hani:ind+hani))にすればイベント時刻の前後両方で判定を行う。イベント時刻が曖昧な場合はこちらがいいかも
        if isempty(fff) == 1
            continue
        end
        ind2 = Elftime(fff);
%%
        
        aaa = find(elftime(ind-4000:ind+4000)==ind2);
        if isempty(aaa) == 1
            continue
        end
        
        ind = ind-4000+aaa;
        index(number,1) = ind;
        target = elftime(ind);
        
        time = elftime(ind-fftsize/2:ind+fftsize/2-1);
        
        Peak_HH = HH(ind);
%% S/N比で閾値を設定
%          if Peak_HH < Mean_HH + 2*Std_HH
%             continue
%         end
        
%% ELFデータを加工
        %%%% 計算に使う範囲を切り出す
        ezt = ez(ind-fftsizeE/2:ind+fftsizeE/2-1);
        hnst = hns(ind-fftsize/2:ind+fftsize/2-1);
        hewt = hew(ind-fftsize/2:ind+fftsize/2-1);
        %%%% I(t)ds積分用のデータを切り出す（前後500 ms） %%%%%%%%%%%
        pre = 500;
        last = 500;
        hns_It = hns(ind-(4*pre):ind+(4*last)-1);
        hew_It = hew(ind-(4*pre):ind+(4*last)-1);
                % fftsize2 = length(hew_It);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%hamming window%%%
        % Han=[];
        mi = 1:fftsizeE;
        Han = 0.54 - 0.46*cos(2*pi*mi/fftsizeE);
        mi = 1:fftsize;
        Han2 = 0.54 - 0.46*cos(2*pi*mi/fftsize);
        %%%%%%%%%%%%%%%%%%%%
        %         Std_ez = std(ez);
        %
        % 			HH = sqrt(hns.^2 + hew.^2);
        % 			Mean_HH = mean(HH);
        % 			Std_HH = std(HH);
        [h_hour, minute, second, msec] = ms2ut(Elftime(fff));
        %%%%%%%%%%%%%%%
%% ENTLN/LLS/WWLLNによる到来方位
        [rad,Dir,a21]=m_idist(lon_OBS,lat_OBS,lon,lat,'wgs84');   %座標
        %rad/1000000;
        aaa=(3.141592653589793238462643)/20000000*rad;
        %%%%%%%%%%%%%%%%%%%%%%%%%%
%% ELFトランジェントによる到来方位        
        X1=hew(ind-10:ind+10).*10^6;
        Y1=hns(ind-10:ind+10).*10^6;
        
        fitResults1 = polyfit(X1, Y1, 1);
        thetah=decround((-atand(fitResults1(1))),3); 
%% 到来方位の補正関数の適用
        % 陸別は空電到来方向によって推定誤差に偏りが出る。θと⊿θの回帰直線のa,bで補正する。
        %             fitt = [-0.977792518,23.39865018];
        %             fitt = [0.141879464,0.579269663]; %村井さん補正
        %             fitt = [2.34733659,-20.6351653]; %補正
        %             fitt = [0.083395066,10.97429076]; %補正20180812
       %  fitt = [0.249716109, 6.283911653]; %補正20180812 newrange
        
        %%%%%%%%%%% Akama add: ホドグラムによる伝搬方向ベクトルkと本来の雷到来方向の角度誤差の補正 %%%%%%%%%%
        %%%%%%%%%%% 到来角θとΔθの回帰直線のa,bを決定次第補正 %%%%%%%%%
        if LOC == 1 %UMP
            % continue
            %fitt = [0, 0];
            hosei = 19.28*sin(Dir*0.03452+0.1246)+10.88*sin(Dir*0.0005622-0.2014)+3.929*sin(Dir*0.06916+0.06821);
           % hosei =0;
            %hosei=0;
        end
        if LOC == 2 %TRU
            fitt = [0.0028, 8.9793];
            hosei=thetah*fitt(1) + fitt(2);
        end
        if LOC == 3 %KOZ
            fitt = [0, 0];
            hosei=thetah*fitt(1) + fitt(2);
        end
        if LOC == 4 %RKB
        %    fitt = [0.083395066,10.97429076]; %補正20180812
       %   fitt = [0, 0];
           % hosei = thetah*fitt(1) + fitt(2); %θhの補正量
           fitt = [0.249716109, 6.283911653]; 
         %  hosei=Dir*fitt(1) + fitt(2);
         hosei=thetah*fitt(1) + fitt(2);
        end
        
        % hosei=0;
       % thetah_hosei = thetah - hosei; %補正後のθh(ELF方位)
         %%%%%% 
%% 到来方位補正後の⊿θの計算
    %%%%%%%%%%%%%%%%%%%%%%% Dirはy軸から時計回り角 360°まで正数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                         %%%%%%%%%%%%%%%%%%%%%%% thetahはy軸から±90°%%%%%%
   %%%%%%%% 角度によって到来角を場合分け、M_plot用の判別(Map_check)も追加 %%%
  %%%%% 
   
    if  thetah < 0 %%% thetah_hoseiをy軸時計回り360°表記に変更
           thetah=360+thetah;
    end
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
      %%% ENとELFが角度差90°以内かつy軸（>0）を跨いでいる場合の例外処理 %%%
if(( 0<Dir && Dir<90) && (270<=thetah && thetah<=360)) && (((360-thetah) + Dir)<=90)
     
            %thetah_hosei2=thetah - hosei+360;
    Delta_theta = -((360-thetah-hosei) + Dir); %%dig:EN->ELF
   Map_check = 1;
   %-360
  
elseif ((270<Dir && Dir<360) && (0<=thetah && thetah<=90)) && ((thetah + (360-Dir))<=90)
     %thetah_hosei3=thetah - hosei-360;
    Delta_theta = thetah-hosei + (360-Dir); %%dig:EN->ELF
     Map_check = 1;
     %360
end

   %%% ELFの到来方向がENから遠い方を参照している場合にENに近い方の角度を参照 %%%
      if abs(thetah-Dir)>90 && Map_check==0
          if 270<=thetah && thetah<=360
              %thetah_hosei=thetah_hosei-180;
              if Dir<(thetah-180)
                   thetah_hosei4=thetah - hosei;
                  Delta_theta = abs(thetah_hosei4-180 - Dir);%%dig:EN->ELF
                  Map_check = 2;
                  %180
              elseif Dir>=(thetah-180)
                  thetah_hosei5=thetah - hosei;
                  Delta_theta = -abs(thetah_hosei5-180 - Dir);%%dig:EN->ELF
                  Map_check = 2;
                  %-180
              end
          elseif 0<=thetah && thetah<=90
              %thetah_hosei=thetah_hosei+180;
              if Dir<(thetah+180)
                  thetah_hosei6=thetah - hosei;
                  Delta_theta = abs(thetah_hosei6+180 - Dir);%%dig:EN->ELF
                  Map_check = 2;
                  %180
              elseif Dir>=(thetah+180)
                   thetah_hosei7=thetah - hosei;
                  Delta_theta = -abs(thetah_hosei7+180 - Dir);%%dig:EN->ELF
                  Map_check = 2;
                  %-180
              end
          end
          
              
        % Delta_theta = abs(180-abs(thetah_hosei - Dir));
      %  Map_check = 2;
      elseif abs(thetah-Dir)<=90    %%% 上記以外で何も問題がない場合  %%%%%
          if Dir<thetah
              % thetah_hosei5=thetah_hosei5-180;
           Delta_theta = abs(thetah - hosei - Dir);%%dig:EN->ELF
           Map_check = 1;
           %0
          elseif Dir>=thetah
               %thetah_hosei5=thetah_hosei5-180;
           Delta_theta = -abs(thetah - hosei - Dir);%%dig:EN->ELF
          Map_check = 1;
          %0
          end
      end
%                if abs(Delta_theta)>10
%                    continue
%                end
%                if rad/1000>=500 & abs(Delta_theta)>5
%                    continue
%                end

%% 到来方位角誤差の値を閾値にする
%  if abs(Delta_theta)>90
%                    continue
%                 end
          thetah_hosei=thetah-hosei;
         
        %%%I(f)ds %%%  
%% 球面三角法
        %経度0～360(東回り),緯度－90～90
        %%%%%%%%% Akama add: BB lon/lat_OSB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        b=90-lat;
        c=90-lat_OBS;
        A=lon-lon_OBS;
        a=acos(cosd(b)*cosd(c)+sind(b)*sind(c)*cosd(A));
 %% Hodogramリサージュからの到来方位
        %  kakudo=atand(hns(ind)/hew(ind));  %%%%%%% x軸から±90°%%%%
       % Hの最大値で判定していたのでHの波形でフィッティングさせる%%
         hodo_X1=hew(ind-10:ind+10).*10^6;
        hodo_Y1=hns(ind-10:ind+10).*10^6;
       % hodo_maxscale=max(max(abs(hodo_X1))*1.5,max(abs(hodo_Y1))*1.5);
       % hodo_xplot = linspace(-hodo_maxscale, hodo_maxscale);
        hodo_fitResults1 = polyfit(hodo_X1, hodo_Y1, 1);
        kakudo=atand(hodo_fitResults1(1,1));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BB is NE theta from north %
        BB=atand(sind(A)/(cosd(lat_OBS)*tand(lat)-sind(lat_OBS)*cosd(A)));
        %         kakudo2=BB+90;
        %%%%%%%%%%%%%%%
%% 45°を閾値として到来方位に応じてHns/Hewを切り替え
  %% Hewns_It, hh_t; 選択したHns/Hew
        if H_usage == 1
%Hodogramのリサージュ曲線の傾きがx軸から±90°表記なので、
% abs（ホドグラムの傾き）>=45°のとき到来方向は必ず45°~135°もしくは225°~315°にあるためHnsを使用
kakudo_hantei=abs(kakudo);
if kakudo_hantei >= 45
   % hh = hns;
    H_Choice='Hns';
    hewns_It = hns_It;
    hh_t = hnst;

elseif kakudo_hantei < 45
    % hh = hew;
     H_Choice='Hew';
     hewns_It = hew_It;
     hh_t = hewt;

end

%% Hの片成分のデータが使えない時は到来角に関わらず使える方のHのみを用いる
        elseif H_usage == 2
            H_Choice='Hns';
            hewns_It = hns_It;
            hh_t = hnst;
          
       elseif H_usage == 3
           H_Choice='Hew';
            hewns_It = hew_It;
            hh_t = hewt;
        end
        fftsize2 = length(hewns_It);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% 到来方位角によるHns/Hewの選択に関わらず，Hns/HewそれぞれのQdsを導出する
       %Hns
        Hns_hewns_It = hns_It;
        Hns_hh_t = hnst;
        fftsize2Hns = length(Hns_hewns_It);
       %Hew
        Hew_hewns_It = hew_It;
        Hew_hh_t = hewt;
        fftsize2Hew = length(Hew_hewns_It);
        
        
%% H(t) -> H(f) -> I(f)ds -> I(t)ds
        %% Hの射影
        %% 到来方位角により選択したHns/hewでの処理
        if kakudo_hantei>=45
         ht=hh_t(1:end)/abs(cosd(kakudo+90));
         ht_ns=hnst(1:end)/abs(cosd(kakudo+90));
           ht_ew=hewt(1:end)/abs(cosd(kakudo+90));
         ht2=hewns_It/abs(cosd(kakudo+90));
         
        %% 到来方位に関わらずHns/Hewで同じ処理
       %Hns
          Hns_ht=Hns_hh_t(1:end)/abs(cosd(kakudo+90));
          Hns_ht2=Hns_hewns_It/abs(cosd(kakudo+90));
       %Hew
          Hew_ht=Hew_hh_t(1:end)/abs(cosd(kakudo+90));
          Hew_ht2=Hew_hewns_It/abs(cosd(kakudo+90));
         
        elseif kakudo_hantei<45
            ht=hh_t(1:end)/abs(sind(kakudo+90));
             ht_ns=hnst(1:end)/abs(sind(kakudo+90));
          ht_ew=hewt(1:end)/abs(sind(kakudo+90));
            ht2=hewns_It/abs(sind(kakudo+90));
            
        %% 到来方位に関わらずHns/Hewで同じ処理
       %Hns
          Hns_ht=Hns_hh_t(1:end)/abs(sind(kakudo+90));
          Hns_ht2=Hns_hewns_It/abs(sind(kakudo+90));
       %Hew
          Hew_ht=Hew_hh_t(1:end)/abs(sind(kakudo+90));
          Hew_ht2=Hew_hewns_It/abs(sind(kakudo+90));
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 到来方位角により選択したHns/Hewでの処理
        h=fft(ht.*Han2')*(1/sf);
        h2=fft(ht2)*(1/sf);
        sf2=sf;
        %I(f)ds
        ifds=h2ifds_10(h,a,fftsize,sf2);  %%%% Impulsive, Exponentia用
        ifds2=h2ifds_10(h2,a,fftsize2,sf2); %%%% I(t)ds Integral用
        %I(t)ds
        [itds,~,TT]=if2it_2(ifds2,sf,fftsize2,pre,last);
        itds_a=itds;
        ITDS2 = ITDS2.It_integral_koba(itds,TT,eventtime,pre,last); % iCMC計算追加 2019/10/16
        Qds_Algo2 = ITDS2.iCMC;
        ITDS = ITDS.It_integral_koba(itds,TT,eventtime,pre,last);
        Qds_Algo = ITDS.eventQds;
       
        %% 到来方位角に関わらずHns/Hewで同じ処理
        %%%%%% Hns %%%%%
        Hns_h=fft(Hns_ht.*Han2')*(1/sf);
        Hns_h2=fft(Hns_ht2)*(1/sf);
        Hns_sf2=sf;
        %I(f)ds
        Hns_ifds=h2ifds_10(Hns_h,a,fftsize,Hns_sf2);  %%%% Impulsive, Exponentia用
        Hns_ifds2=h2ifds_10(Hns_h2,a,fftsize2Hns,Hns_sf2); %%%% I(t)ds Integral用
        %I(t)ds
        [Hns_itds,~,Hns_TT]=if2it_2(Hns_ifds2,sf,fftsize2Hns,pre,last);
        Hns_itds_a=Hns_itds;
        Hns_ITDS2 = Hns_ITDS2.It_integral_koba(Hns_itds,Hns_TT,eventtime,pre,last); % iCMC計算追加 2019/10/16
        Hns_Qds_Algo2 = Hns_ITDS2.iCMC;
        Hns_ITDS = Hns_ITDS.It_integral_koba(Hns_itds,Hns_TT,eventtime,pre,last);
        Hns_Qds_Algo = Hns_ITDS.eventQds;
        
        %%%%% Hew %%%%%
       Hew_h=fft(Hew_ht.*Han2')*(1/sf);
        Hew_h2=fft(Hew_ht2)*(1/sf);
        Hew_sf2=sf;
        %I(f)ds
        Hew_ifds=h2ifds_10(Hew_h,a,fftsize,sf2);  %%%% Impulsive, Exponentia用
        Hew_ifds2=h2ifds_10(Hew_h2,a,fftsize2Hew,Hew_sf2); %%%% I(t)ds Integral用
        %I(t)ds
        [Hew_itds,~,Hew_TT]=if2it_2(Hew_ifds2,sf,fftsize2Hew,pre,last);
        Hew_itds_a=Hew_itds;
        Hew_ITDS2 = Hew_ITDS2.It_integral_koba(Hew_itds,Hew_TT,eventtime,pre,last); % iCMC計算追加 2019/10/16
        Hew_Qds_Algo2 = Hew_ITDS2.iCMC;
        Hew_ITDS = Hew_ITDS.It_integral_koba(Hew_itds,Hew_TT,eventtime,pre,last);
        Hew_Qds_Algo = Hew_ITDS.eventQds;
%% 極性判別
%% ①　ELF帯トランジェントからの極性判別
%%%%%% BBはENの方位角で北から±90° 
%%%%（180°逆になることもあるが）ENがどんな方角を見ていてもトランジェントピークの符号逆転させればよい
         hf=length(ht)/2;
         hf_ns=length(ht_ns)/2;
         hf_ew=length(ht_ew)/2;
                 nsp=ht(hf)-(ht(hf-5)+ht(hf+5))/2;
                 nsp_ns=ht_ns(hf_ns)-(ht_ns(hf_ns-5)+ht_ns(hf_ns+5))/2;
                  nsp_ew=ht_ew(hf_ew)-(ht_ew(hf_ew-5)+ht_ew(hf_ew+5))/2;
                     if nsp>0
                         pol2=-1;
                    else
                         pol2=1;
                     end
                     if nsp_ns>0
                         pol_ns=-1;
                    else
                         pol_ns=1;
                     end
                     if nsp_ew>0
                         pol_ew=-1;
                    else
                         pol_ew=1;
                     end
              %%% ENとELFが角度差90°以内かつy軸（>0）を跨いでいる場合の例外処理 %%%
        if(( 0<Dir && Dir<90) && (270<=thetah && thetah<=360)) && (((360-thetah) + Dir)<=90)
            thetah_pol= thetah;
        elseif ((270<Dir && Dir<360) && (0<=thetah && thetah<=90)) && ((thetah + (360-Dir))<=90)
            thetah_pol= thetah;
        else  thetah_pol= thetah;
        end
        %%% ELFの到来方向がENから遠い方を参照している場合にENに近い方の角度を参照 %%%
        if abs(thetah-Dir)>90
            if 270<=thetah && thetah<=360
                    thetah_pol= thetah-180;
            elseif 0<=thetah && thetah<=90
                if Dir<(thetah+180)
                    thetah_pol= thetah+180;
                end
                else thetah_pol= thetah;
            end
        elseif abs(thetah-Dir)<=90    %%% 上記以外で何も問題がない場合  %%%%
                thetah_pol= thetah; 
        else thetah_pol= thetah;
        end
%% ②　Hodogramからの極性判別
       if  (pol_ns <=0 & pol_ew<=0)  & (90<=thetah_pol & thetah_pol<=180)
           pol3=1;
       elseif (pol_ns <=0 & pol_ew<=0)  & (270<=thetah_pol & thetah_pol<=360)
           pol3=-1;
       elseif (pol_ns >=0 & pol_ew>=0)  & (90<=thetah_pol & thetah_pol<180)
           pol3=-1;
     elseif (pol_ns >=0 & pol_ew>=0)  & (270<=thetah_pol & thetah_pol<=360)
         pol3=1;
          elseif (pol_ns >=0 & pol_ew<=0)  & (0<=thetah_pol & thetah_pol<=90)
         pol3=-1;
         elseif (pol_ns >=0 & pol_ew<=0)  & (180<=thetah_pol & thetah_pol<=270)
     pol3=1;
      elseif (pol_ns <=0 & pol_ew>=0)  & (0<=thetah_pol & thetah_pol<=90)
          pol3=1;
           elseif (pol_ns <=0 & pol_ew>=0)  & (180<=thetah_pol & thetah_pol<=270)
          pol3=-1;
       end
%% ③　WWLLN/LLS/ENTLNのIpによる極性判定
        if Data_Type == 1
            if Ene < 0
                pol = -1;
            else
                pol = 1;
            end
        end
        if Data_Type == 2
            if Cur < 0
                pol = -1;
            elseif Cur > 0
                
                pol = 1;
            end
        end
        if Data_Type == 3
            if Ip < 0
                pol = -1;
            elseif Ip >0
                pol = 1;
            
       % LLSのIpが0.00 kA のイベントはHodogramからの極性にする
        elseif Ip==0
            pol = pol3;
            end
        end
%%%%%%%%% WWLLN/LLS/ENTLNのIpによる極性とELFトランジェント波形から推定した極性が一致するのか判定するカウンター作成 %%%%
        if pol==pol2
            pol_equal=1; %一致してたら1
        else
            pol_equal=0;
        end
%%%%%%%% Hodogramから推定した極性とELFトランジェント波形から推定した極性が一致するのか判定するカウンター作成 %%%%
        if pol==pol3
            pol_equal2=1; %一致してたら1
        else
            pol_equal2=0;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%% peak amp %%%
        hphi=sqrt(hewt.^2+hnst.^2);
        hpa=decround(max(hphi*10^6),3);
        
        %% Qds_EX
        %% 到来方位角により選択したHns/Hewで計算
        x = f(f<55).^2;
        y = 1./(abs(ifds(f<55)).^2);
        %%% 変な部分を取り除く %%%
        mn = mean(y);
        nn = std(y);
        out = find(y>(mn + nn));
        yyy = [y(1:out-1) y(out+1:end)];
        xx = [x(1:out-1) x(out+1:end)];
        P = polyfit(xx,yyy,1);
        ppp = polyval(P,xx);
        b = P(2);
        m = P(1);
        tau = (1/(2*pi))*sqrt(m/b);
        %%%%%%%%%%%%%%%%%%%%%%%%
        Qds_Ex = (1/sqrt(b))*pol/1000;
        Qds_Ex = pol*abs(Qds_Ex);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
     %% Qds Im, Qds iCMC ←到来方位角により選択したHと，Hns/Hew両方で計算
        %%%%高調波の部分を0に%%%%
        f1=(50:50:sf/2)-8;
        f2=(50:50:sf/2)+8;
        ll=length(f1);
        for l=1:ll
            h(f>f1(l) & f<f2(l))=0;
        end
        
        dfreqIFDS   = 4000/fftsize; %%修正
        CntIfdsFreqMin = 1;
        CntIfdsFreqMax = floor(30/dfreqIFDS);
        %選択したHns/Hew
        Qds_SR = pol*mean( abs(ifds(2:CntIfdsFreqMax)) )/1e3;
        Qds_Ip = pol*abs( ifds(2) )/1e3;
        Qds_Ip2= pol*abs( mean(ifds(1:9)) )/1e3;
        Qds_It = pol*Qds_Algo;
        Qds_It_iCMC = pol*Qds_Algo2; % iCMC 2019/10/16
        hphi=sqrt(hewt.^2+hnst.^2);
        Qds_Im=Qds_Ip;
        
        %Hns
        Hns_Qds_Ip = pol*abs( Hns_ifds(2) )/1e3;
        Hns_Qds_Im=Hns_Qds_Ip;
        Hns_Qds_It_iCMC = pol*Hns_Qds_Algo2;
        %Hew
        Hew_Qds_Ip = pol*abs( Hew_ifds(2) )/1e3;
        Hew_Qds_Im=Hew_Qds_Ip;
        Hew_Qds_It_iCMC = pol*Hew_Qds_Algo2;
        %% 群速度・位相速度
        group_velocity = rad/(Elftime(fff)/1000 - eventtime/1000);
        ratio = group_velocity/(3*10^8);
%%%%%%%%%%%%%%%%%%%%%%% Dirはy軸から時計回り角 360°まで正数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% thetahはy軸から±90°%%%%%%
        Lag = Elftime(fff) - eventtime;
        Time = 0; %10分毎の計算に要する時間
        flag = 0;    
        if Data_Type == 1
            Q_dsds=table(number,yy,mm,dd,th,tm,ts,tms,lat,lon,Ene,Qds_Ex,Qds_Im,Qds_SR,Qds_It,Qds_It_iCMC,Dir,thetah_hosei,...
                Delta_theta,rad,eventtime,Elftime(fff),Lag,Mean_HH,Std_HH,Peak_HH,flag,group_velocity,ratio,Time,thetah);
        end
        if Data_Type == 2
            Q_dsds=table(number,yy,mm,dd,th,tm,ts,tms,lat,lon,Stroke,Cur,Qds_Ex,Qds_Im,Qds_SR,Qds_It,Qds_It_iCMC,Dir,thetah_hosei,...
                Delta_theta,rad,eventtime,Elftime(fff),Lag,Mean_HH,Std_HH,Peak_HH,flag,group_velocity,ratio,Time,thetah);
        end
        if Data_Type == 3
            Q_dsds=table(number,yy,mm,dd,th,tm,ts,tms,lat,lon,Ip,Qds_Ex,Qds_Im,Qds_SR,Qds_It,Qds_It_iCMC,Dir,thetah_hosei,...
                Delta_theta,rad,eventtime,Elftime(fff),Lag,Mean_HH,Std_HH,Peak_HH,flag,group_velocity,ratio,Time,thetah);
        end
%% イベントシート作成用  
% イベントシート作成時刻
        dtt =  datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM');
%落雷標定情報のタイプ
        if Data_Type == 1
            Ipk = 0000;
            TYPE = 'WWLLN';
        elseif Data_Type == 2
            Ipk = Cur;
            TYPE = 'EN';
        elseif Data_Type == 3
            Ipk = Ip;
            TYPE = 'LLS';
        end
 %ENTLNの時だけIpを[kA]単位に変換
        if Data_Type==2
        Ipk = Ipk/1000;
        end
%% 解析に必要な全てのデータをCell配列にまとめる

       event_count=event_count +1; %雷イベントがあったらカウント＋１
       
       EN_ELF_box{event_count,1} =table2array(Q_dsds(1,1));%event number
       EN_ELF_box{event_count,2} =table2array(Q_dsds(1,2));%yy
       EN_ELF_box{event_count,3} =table2array(Q_dsds(1,3));%mm
       EN_ELF_box{event_count,4} =table2array(Q_dsds(1,4));%dd
       EN_ELF_box{event_count,5} =table2array(Q_dsds(1,5));%th
       EN_ELF_box{event_count,6} =table2array(Q_dsds(1,6));%tm
       EN_ELF_box{event_count,7} =table2array(Q_dsds(1,7));%ts 
       EN_ELF_box{event_count,8} =table2array(Q_dsds(1,8));%tms
       EN_ELF_box{event_count,9} = table2array(Q_dsds(1,22));%transient time
       EN_ELF_box{event_count,10} = table2array(Q_dsds(1,21));%eventtime
       EN_ELF_box{event_count,11} = table2array(Q_dsds(1,23));%トランジェントとイベント時刻のLag
       EN_ELF_box{event_count,12} = table2array(Q_dsds(1,10)); %ENTLN/LLS/WWLLN Lightning location lon
       EN_ELF_box{event_count,13} = table2array(Q_dsds(1,9)); %ENTLN/LLS/WWLLN Lightning location lat
       EN_ELF_box{event_count,14} = table2array(Q_dsds(1,17) );%ENTLN/LLS/WWLLN digree
       EN_ELF_box{event_count,15} = table2array(Q_dsds(1,19)); %ELF-ENTLN/LLS/WWLLN digree
       EN_ELF_box{event_count,16} = table2array(Q_dsds(1,31));%Thetah
       EN_ELF_box{event_count,17} = table2array(Q_dsds(1,18)); %ELF hosei digree
       EN_ELF_box{event_count,18} = table2array(Q_dsds(1,20))/1000;%rad(distance)
       % EN_ELF_box{event_count,17} = Map_check;
       % EN Only!↓
        %EN_ELF_box{event_count,19} =  table2array(Q_dsds(1,11));%IC=1/CG=0
       % EN_ELF_box{event_count,18} =  table2array(Q_dsds(1,12));%Qds_Ex
       % EN_ELF_box{event_count,13} = table2array(Q_dsds(1,15)); %Qds_It
       % EN_ELF_box{event_count,20} = table2array(Q_dsds(1,14));%Qds_SR
       EN_ELF_box{event_count,19} = Ipk; %Ipk
       EN_ELF_box{event_count,20} = table2array(Q_dsds(1,13));%選択したQds_Im
       EN_ELF_box{event_count,21} = table2array(Q_dsds(1,16));%選択したQds_It_iCMC
       EN_ELF_box{event_count,22} = Hns_Qds_Im;%HnsのQds_Im
       EN_ELF_box{event_count,23} = Hew_Qds_Im;%HewのQds_Im
       EN_ELF_box{event_count,24} = Hns_Qds_It_iCMC;%HnsのQds_It_iCMC
       EN_ELF_box{event_count,25} = Hew_Qds_It_iCMC;%HewのQds_It_iCMC
       EN_ELF_box{event_count,26} = table2array(Q_dsds(1,24));%Mean_HH
       EN_ELF_box{event_count,27} = table2array(Q_dsds(1,25));%Std_HH
       EN_ELF_box{event_count,28} = table2array(Q_dsds(1,26));%Peak_HH
       EN_ELF_box{event_count,29} = table2array(Q_dsds(1,28));%Group_velocity
       EN_ELF_box{event_count,30} = table2array(Q_dsds(1,29));%ratio    
       EN_ELF_box{event_count,31} = pol2;%ELF pol
       EN_ELF_box{event_count,32} = pol3;%Hod pol
       EN_ELF_box{event_count,33} = pol_equal; %ENTLN/LLS/WWLLNとELFで極性一致してるか
       EN_ELF_box{event_count,34} = pol_equal2; %ENTLN/LLS/WWLLNとhodogramで極性一致してるか
       %LLS Only!↓
       EN_ELF_box{event_count,35} = LLS_TYPE;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1日分のデータを解析し終わるごとに.matファイルを作成→バックアップ用・エラーへの対処のため
        if Day_check ==2 & numel(Day_box(1,:))==2
     Day_box(1,1)=Day_box(1,2);
     Day_check=1;
 end
 Day_check=Day_check+1;
 Day_box(1,Day_check)=dd;
 if numel(Day_box(1,:))==2
 if Day_box(1,1)~=Day_box(1,2)
     if exist([figsave_dir 'ELF\20' YY],'dir')==0
            mkdir([figsave_dir 'ELF\20' YY])
        end
        if exist([figsave_dir 'ELF\20' YY '\' MM],'dir')==0
            mkdir([figsave_dir 'ELF\20' YY '\' MM])
        end
        if exist([figsave_dir 'ELF\20' YY '\' MM '\' DD],'dir')==0
            mkdir([figsave_dir 'ELF\20' YY '\' MM '\' DD])
        end 
        %日付が変わって1つ目のイベントでそれまでの全てのイベントをバックアップ保存
     save([figsave_dir 'ELF\20' YY '\' MM '\' DD '\' YY MM DD 'total.mat'],'EN_ELF_box');
        %日付が変わって1つ目のイベントを計算したタイミングでその前日の全てのイベントをExcelで保存
        excelbox={};
        excelcount=0;
        for totalnum=1:length(EN_ELF_box)
            if EN_ELF_box{totalnum,4}==dd-1
                excelcount=excelcount+1;
                for excellinenum=1:35
                excelbox{excelcount,excellinenum}=EN_ELF_box{totalnum,excellinenum};
                end
            end
        end
        if isempty(excelbox)~=1 && event_count~=0
            %まずCellをTableに変換
            if Data_Type ==2
                T = cell2table(excelbox,...
                'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'EN_Lightning_Location_Lon' 'EN_Lightning_Location_Lat' 'EN_Lingtning_Direction' 'EN_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'IC_1_CG_0' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'EN_pol_equal_ELF_transient_pol_if_equal_1' 'EN_pol_equal_Hodogram_pol_if_equal_1'});
            end
            if Data_Type ==3
            T = cell2table(excelbox,...
                'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'LLS_Lightning_Location_Lon' 'LLS_Lightning_Location_Lat' 'LLS_Lingtning_Direction' 'LLS_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'LLS_pol_equal_ELF_transient_pol_if_equal_1' 'LLS_pol_equal_Hodogram_pol_if_equal_1' 'LLS_TYPE'});
            end
            %Excelで保存
            DD2=sprintf('%02d', dd-1);
            writetable(T,[figsave_dir 'ELF\20' YY '\' MM '\' DD2 '\' YY MM DD2 '.xlsx']);
       
           end        
 end  
 end

%% イベントシート作成の際に良いイベントのみを見たい場合は各閾値を設定　
%% (大量に画像が生成されてPCの容量が圧迫するのを抑えられる)
%           if Peak_HH < Mean_HH + 2*Std_HH
%              continue
%          end
% 
%  if abs(Delta_theta)>10
%      continue
%  end
%% イベントシートを作成
        graph=figure('visible','off');
        set(gcf,'PaperType','A5','PaperOrientation','landscape','PaperPositionMode','auto','defaultAxesFontName','Times New Roman','Position',[1 1 1200 900]);

        subplot(4,3,1);
        plot(elftime(ind-250:ind+250),ez(ind-250:ind+250));
        xtime_super(elftime(ind-250:ind+250));       %%%%%% xtimeを改変したxtime_super(目盛の間隔変えたやつ,別にプログラムがある)使ってる
        %             plot(elftime(ind-800:ind+800),ez(ind-800:ind+800)); % 範囲拡大用
        % 			xtime_super(elftime(ind-800:ind+800));
        ylabel('E_z [V/m]','FontName','Times New Roman');
        vline(eventtime,'m');
        vline(ind2)
        grid on
        
        subplot(4,3,[4,5]); %拡大用
        %             subplot(3,3,4);
        % 			plot(elftime(ind-250:ind+250),hns(ind-250:ind+250).*10^6);
        % 			xtime_super(elftime(ind-250:ind+250));
        plot(elftime(ind-500:ind+500),hns(ind-500:ind+500).*10^6);
        xtime_super(elftime(ind-500:ind+500));
        % 			plot(elftime(ind-800:ind+800),hns(ind-800:ind+800).*10^6); %拡大用
        % 			xtime_super(elftime(ind-800:ind+800));
        ylabel('H_N_S [\muA/m]','FontName','Times New Roman');
        vline(eventtime,'m');
        vline(ind2)
        % 積分範囲追加 2019/10/16
        vline(ITDS.startTime,'g');
        vline(ITDS.endTime,'g');
        vline(ITDS2.startTime,'k');
        vline(ITDS2.endTime,'k');
        grid on
        
        subplot(4,3,[7,8]); %拡大用
        %             subplot(3,3,7);
        % 			plot(elftime(ind-250:ind+250),hew(ind-250:ind+250).*10^6);
        % 			xtime_super(elftime(ind-250:ind+250));
        plot(elftime(ind-500:ind+500),hew(ind-500:ind+500).*10^6);
        xtime_super(elftime(ind-500:ind+500));
        % 			plot(elftime(ind-800:ind+800),hew(ind-800:ind+800).*10^6); %拡大用
        % 			xtime_super(elftime(ind-800:ind+800));
        ylabel('H_E_W [\muA/m]','FontName','Times New Roman');
        xlabel('time [UT]','FontName','Times New Roman');
        vline(eventtime,'m');
        vline(ind2)
        % 積分範囲追加 2019/10/16
        vline(ITDS.startTime,'g');
        vline(ITDS.endTime,'g');
        vline(ITDS2.startTime,'k');
        vline(ITDS2.endTime,'k');
        grid on
        
        % I(t)ds追加 2019/10/16
        subplot(4,3,[10,11]);
        plot(elftime(ind-500:ind+500),abs(itds(1500:2500)./1000000));
        xtime_super(elftime(ind-500:ind+500));
        ylabel('I(t)ds [kA\cdotkm]','FontName','Times New Roman');
        xlabel('time [UT]','FontName','Times New Roman');
       v_l_1 = vline(eventtime,'m');
        v_l_2 = vline(ind2);
        % 積分範囲追加 2019/10/16
        v_l_3 = vline(ITDS.startTime,'g');
        vline(ITDS.endTime,'g');
        v_l_4 = vline(ITDS2.startTime,'k');
        vline(ITDS2.endTime,'k');
        hold on
        lgd = legend([v_l_1 v_l_2 v_l_3 v_l_4],{'Event time','ELF Triger','Qds-It','Qds-It.CMC'},'fontsize',7,'NumColumns',2,'Location','northwest');
        grid on
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        X1=hew(ind-10:ind+10).*10^6;
        Y1=hns(ind-10:ind+10).*10^6;
        
        % 			subplot(2,3,2);
        subplot(4,3,2);
        maxscale=max(max(abs(X1))*1.5,max(abs(Y1))*1.5);
        % Find x values for plotting the fit based on xlim
        xplot1 = linspace(-maxscale, maxscale);
        % 多項式 (次数 = 1) に対する係数を検出
        fitResults1 = polyfit(X1, Y1, 1);
        yplot1 = polyval(fitResults1, xplot1);
        yplot2=-(xplot1/fitResults1(1));
        % 			thetah=decround((-atand(fitResults1(1))),3);
        plot(xplot1,yplot1,'k');
        hold on;
        plot(xplot1,yplot2,'k','LineWidth',2);
        plot(X1,Y1,'b');
        axis([-maxscale maxscale -maxscale maxscale]);
        axis square;
        % 作成 xlabel
        xlabel('H_E_W [\muA/m]','FontName','Times New Roman');
        % 作成 ylabel
        ylabel('H_N_S [\muA/m]','FontName','Times New Roman');
        grid on
        
        group_velocity = rad/(Elftime(fff)/1000 - eventtime/1000);
        ratio = group_velocity/(3*10^8);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %番号,年,月,日,時,分,秒,ミリ秒,Qds_Ex,Qds_Im,H peak
        %amplitude,方位角(JLDn),方位角(リサージュ),落雷の緯度,落雷の経度,母子里からの距離,落雷発生時刻,トランジェントの時間,群速度,比率
        
        tau1(number) = tau';
        %
        %         lon=-180:180;
        %         lat=atan(tan(60*pi/180)*cos((lon-30)*pi/180))*180/pi;
        
        [rad,B,a21]=m_idist(lon_OBS,lat_OBS,lon,lat,'wgs84');      % UMPの座標
        Mlat = [lat;lat_OBS];
        Mlon = [lon;lon_OBS];
        %[MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei+180,rad,'wgs84');
        if Map_check == 1
        [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei,rad,'wgs84');
%         elseif Map_check == 2 && 0<= thetah_hosei<=90
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei+180,rad,'wgs84');
%         elseif Map_check == 2 && 270<= thetah_hosei<=360
%         [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei-180,rad,'wgs84');
elseif Map_check == 2 && (0<= thetah && thetah<=90)
        [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei+180,rad,'wgs84');
        elseif Map_check == 2 && (270<=thetah && thetah<=360)
        [MMlon,MMlat,a211] = m_fdist(lon_OBS,lat_OBS,thetah_hosei-180,rad,'wgs84');
        end
        MMMlat = [MMlat;lat_OBS];
        MMMlon = [MMlon;lon_OBS];
        hold on
        subplot(2,3,3);
        m_proj('miller','lon',[lon_min-10 lon_max+10],'lat',[lat_min-10 lat_max+10]);
        %       m_proj('miller','lon',[120 155],'lat',[18 48]);
        % 			m_proj('miller','lon',[127 148],'lat',[29 47]);
        m_coast('patch',[.7 1 .7],'edgecolor',[0 .6 0]);
        m_grid('linestyle','none','box','fancy','tickdir','out','xtick',[120:10:150]);
        m_line(Mlon,Mlat,'color','r');
        m_line(MMMlon,MMMlat,'color','b');
        hold on
       p_l_1 = m_plot(lon,lat,'.','color','r');
        hold on
        p_l_2 = m_plot(MMlon,MMlat,'.','color','b');
        % 			m_plot(142.2,44.2,'.','color','r');
        p_l_3 = m_plot(lon_OBS,lat_OBS,'x','color','k');
        hold on
        legend([p_l_1 p_l_2  p_l_3],{TYPE,'ELF',loc_name},'fontsize',7)
        hold on
        xlabel('Longitude [\circ]','FontName','Times New Roman','fontsize',12);
        ylabel('Latitude [\circ]','FontName','Times New Roman','fontsize',12);
        %anonotation [0.3,0.11,0.25,0.2]
        
%% ELF3点による重心法に使うためにELFによる落雷標定座標を保存しておく
%  EN_ELF_box{event_count,36} = MMlon;
%  EN_ELF_box{event_count,37} = MMlat;
%% イベントシート用にthetahとthetah_hoseiの角度表記を正しい値に変更
        %%% ENとELFが角度差90°以内かつy軸（>0）を跨いでいる場合の例外処理 %%%
        if(( 0<Dir && Dir<90) && (270<=thetah && thetah<=360)) && (((360-thetah) + Dir)<=90)
            thetah= thetah;
            thetah_hosei=thetah_hosei;
        elseif ((270<Dir && Dir<360) && (0<=thetah && thetah<=90)) && ((thetah + (360-Dir))<=90)
            thetah= thetah;
            thetah_hosei=thetah_hosei;
        end
        %%% ELFの到来方向がENから遠い方を参照している場合にENに近い方の角度を参照 %%%
        if abs(thetah-Dir)>90
            if 270<=thetah && thetah<=360
                    thetah= thetah-180;
                    thetah_hosei=thetah_hosei-180;
                
            elseif 0<=thetah && thetah<=90
                if Dir<(thetah+180)
                    thetah= thetah+180;
                    thetah_hosei=thetah_hosei+180;
                end
            end
        elseif abs(thetah-Dir)<=90    %%% 上記以外で何も問題がない場合  %%%%
                thetah= thetah;
                thetah_hosei=thetah_hosei;     
        end
%% イベントシートに記載するデータ
        annotation('textbox',[0.68 0.11 0.25 0.46],'String',{['EN Date: ,',num2str(yy),'/',num2str(mm,'%02d'),'/',num2str(dd,'%02d')],...
            ['Time (UT),',num2str(th,'%02d'),':',num2str(tm,'%02d'),':',num2str(ts,'%02d'),':',num2str(tns,'%09d')],...
            ['Lightning Loc (EN): Long.' num2str(lon,'%7.3f') ,' Lat. ', num2str(lat,'%7.3f')],...
            ['TYPE= ', TYPE,',LLS-TYPE= ', LLS_TYPE],[ 'Ip=', num2str(Ipk,'%+6.2f'),' [kA]',',ELFpol=',num2str(pol2),',Hodpol=',num2str(pol3)],['Hns/Hew Choice:', H_Choice],...
            ['\thetah (EN) [\circ] ,',num2str(B)],['Distance from Lightning to ELF Station [km]: ',num2str(rad/1000)],...
            ['\Delta\theta (ELF - EN) [\circ] ,',num2str(Delta_theta)],['ratio (Vg/c) : ',num2str(group_velocity/(3*10^8)), '  CG(0),IC(1) : ','0']},...
            'FitBoxToText','off','HorizontalAlignment','right','FontName','Times New Roman','LineStyle','none','Fontsize',10);
        annotation('textbox',[0.68 0.11 0.25 0.25],'String',{['\thetah (ELF Aft. Correction.) [\circ] ,',num2str(thetah_hosei)],['\thetah (ELF Hod. Bfr.Correction.) [\circ]: ',num2str(thetah)],['Qds-Ex[Ckm] ,',num2str(pol*abs(Qds_Ex))],...
            ['Qds-Im[Ckm] ,',num2str(pol*abs(Qds_Im))],['Qds-SR[Ckm] ,',num2str(pol*abs(Qds_SR))],['Qds-It[Ckm] ,',num2str(pol*abs(Qds_It))],['Qds-It IntegrationTime[ms] ,',num2str(ITDS.endTime-ITDS.startTime)],...
            ['Qds-It_iCMC(100ms)[Ckm] ,',num2str(pol*abs(Qds_It_iCMC))],...
            ['H_p_e_a_k [\muA/m] ,',num2str(hpa)],...
            ['ELF transient time ,',num2str(h_hour,'%02d'),':',num2str(minute,'%02d'),':',num2str(second,'%02d'),':',num2str(msec*10^6,'%09d')],...
           ['Eventsheet Generated: ' dtt],...
            [' by ' mfilename],},...
        'FitBoxToText','off','HorizontalAlignment','right','FontName','Times New Roman','LineStyle','none','Fontsize',10);
        if not(exist([figsave_dir '\20' YY],'dir'))
            mkdir([figsave_dir '\20' YY])
        end
        if not(exist([figsave_dir '\20' YY '\' MM],'dir'))
            mkdir([figsave_dir '\20' YY '\' MM])
        end
        if not(exist([figsave_dir '\20' YY '\' MM '\' DD],'dir'))
            mkdir([figsave_dir '\20' YY '\' MM '\' DD])
        end
        figsave_dir_1 = [figsave_dir '\20' YY '\' MM '\' DD];
%% 図の保存
        saveas(graph, [figsave_dir_1 '\' num2str(number) '_' YY MM DD '_' TH TM TS], 'png');
close all
     end
end
%% 全ての解析が終わったらExcelファイルに解析結果のまとめを出力して保存
if event_count~=0
    
%まずCellをTableに変換
if Data_Type ==2
    T = cell2table(excelbox,...
        'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'EN_Lightning_Location_Lon' 'EN_Lightning_Location_Lat' 'EN_Lingtning_Direction' 'EN_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'IC_1_CG_0' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'EN_pol_equal_ELF_transient_pol_if_equal_1' 'EN_pol_equal_Hodogram_pol_if_equal_1'});
end
if Data_Type ==3
    T = cell2table(excelbox,...
        'VariableNames',{'Event_Number' 'Year' 'Month' 'Day' 'Hour' 'Minutes' 'Second' 'MilliSec' 'ELFTransient_Time_SecOfDay' 'Event_Time' 'Timelag_btw_ltgevent_time_to_ELFtransient_time_ms' 'LLS_Lightning_Location_Lon' 'LLS_Lightning_Location_Lat' 'LLS_Lingtning_Direction' 'LLS_ELF_Angle_difference' 'ELF_Direcion_Bfr_Correcton' 'ELF_Direcion_Aft_Correcton' 'Distance_km' 'Ip_kA' 'Qds_Im_selected_Ckm' 'Qds_It_iCMC_selected_Ckm' 'Qds_Im_Hns_Ckm' 'Qds_Im_Hew_Ckm' 'Qds_It_iCMC_Hns_Ckm' 'Qds_It_iCMC_Hew_Ckm' 'Mean_H' 'Std_H' 'Peak_H' 'Group_Velocity' 'Ratio_Vg_over_c' 'pol_from_ELF_transient' 'pol_from_Hodogram' 'LLS_pol_equal_ELF_transient_pol_if_equal_1' 'LLS_pol_equal_Hodogram_pol_if_equal_1' 'LLS_TYPE'});
end
%Excelで保存
filename = '20200703.xlsx';
writetable(T,filename);
end