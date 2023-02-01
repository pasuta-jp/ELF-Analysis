% 垂水のファイルからデータを読み出す関数
% もともと、ファイルの頭からバイナリデータを全部読んでいくプログラムだった。
% 高速化のため必要な部分まで読み飛ばす部分を追記（2017/05/03　村井）
% ヘッダよりGainの読み取りを行うプログラム追加→一旦コメントアウト
%陸別の波形が壊れている期間の解析用に，波形に係数をかけてゲインを調整する（2021/04/12 赤間）


function [B, time] = process_kai08_func(file,filename, start_time, end_time)
%% To read binary

display('loading New Logger file...');

s_time_sec = start_time;
e_time_sec = end_time + 1; % Qds導出オリジナルプログラムの方でend_time+1秒間読んでいるのでそれに合わせた
time_sec = 3600*str2double(filename(8:9)) + 60*str2double(filename(10:11)); % ファイルの先頭の秒数

Sec=e_time_sec - time_sec; % ファイルの先頭からエンドタイムまでの秒数
Sec22 = start_time - time_sec; % ファイルの先頭からスタートタイムまでの秒数
% Sec2=e_time_sec;
HEADER_LEN=128;%header
AD_LEN=10;%5chx2byte
DATA_LEN=4000; %16bitx5chx4kHz

% if Fs == 1
Leco=4000;
% elseif Fs == 2
% Leco=125;
% end

fa = zeros(3,Leco*(Sec22-Sec));
time = zeros(1,Leco*(Sec22-Sec));
B = zeros(2,Leco*(Sec22-Sec));
% E = zeros(1,Leco*(Sec));

% Read the contents back into an array
fid = fopen(file);

fid2 = fopen('time.txt','wt');
count2 = 0;

%%%% 欲しい時間のデータまでバイナリデータを読み飛ばす
%%%% Sec22は欲しい時間の頭部分。
%%%% 一秒間のデータは、最初 128 bytes + 1sample 10bytes * 4000 samples
%%%% で構成されてるっぽい。村井PCのメモリの関係上変な式になっている
fread(fid, 128*Sec22);%'		% read the first 128 bytes ('%FREAD')
for i = 1:Leco
    fread(fid,10*Sec22);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gainの読み取り
% headers{1} = fgetl(fid);
% newStr = extractBetween(headers{1},72,80);
% Gain = strsplit(newStr{1},',');


%%%% 欲しい時間からのデータを読んで変数に格納する
for j = Sec22:(Sec-1)
    if j >= s_time_sec - time_sec
        %     if j >= s_time_sec
        k=count2*Leco;
        count2 = count2+1;
        
        [F_nums,count] = fread(fid, 128);%'		% read the first 128 bytes ('%FREAD')
        
        fprintf(fid2,'%s\n',F_nums);
        
        for i = 1:Leco
            F_Data = fread(fid, 10);%'		% read the first 10 bytes ('%FREAD')
            fa(1,i+k) = j+(i-1)/4000;
            time(1,i+k) = fa(1,i+k);
            
            if isempty(F_Data)==1
                display('最初の10bytesのデータなし...')
                continue
            end
            
            fa(2,i+k) = byte2ad16(F_Data(1),F_Data(2));%CH1
          %  B(1,i+k) = (fa(2,i+k)-(20/21)).*(21/500); %CH1
             B(1,i+k) = fa(2,i+k)./80;
            
            fa(3,i+k) = byte2ad16(F_Data(3),F_Data(4));%CH2
           % B(2,i+k) = (fa(3,i+k)-(27/38)).*(19/925); %CH2
            B(2,i+k) =  fa(3,i+k)./80; %CH2
            fa(4,i+k) = byte2ad16(F_Data(5),F_Data(6));%CH3
            fa(5,i+k) = byte2ad16(F_Data(7),F_Data(8));%CH4
            fa(6,i+k) = byte2ad16(F_Data(9),F_Data(10));%CH5
        end
    end
end

B = B(:,:).*2^(-16).*20; %1LSBは2^(-16)*20≒305μV
% E = E.*2^(-16).*20;


fclose(fid);
fclose(fid2);

display('finished.')