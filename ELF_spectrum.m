%% �V���K�[�g�`�ϑ��p�v���O���� modified ->�t�B���^��g�`�̒ǉ�, 2020/06/04 �R�����g�ǉ� YH
% 1.���g�`
% 2.�t�B���^(east,westnotch filtering�o��)��g�`
% 3.���g���X�y�N�g��(y���ΐ��X�P�[��)
% �ȏ�3��figure���쐬����v���O����
%
%�ړI:elf�g�`�ϑ��p�V���K�[(IME-516DL)�f�[�^�̔g�`���m�F���邱��
%���C���v���O����:show_raw_filterd_stimeseries20200604b.m
%�ȈՎd�l:�@UMP�d�l�ɂ��Ă��܂��B
% 1.���g�`
% 2.�t�B���^(east,westnotch filtering�o��)��g�`�Q�����Â�
% �ȏ�4��figure���쐬����v���O����
%�g����
%1.�v���O�������s��A�ǂ݂����t�@�C����I���i�t�@�C����ungzip���Ă������Ɓj
%2.�\��������b���̓���(�t�@�C����10���t�@�C���ł��邱�Ƃ��A60*10�b�����̐��̐��j
%3.�\��������`�����l���̓��́i1 or 2�j

 
clear all
close all

%dir_in = 'D:\�f�X�N�g�b�v\MATLAB\����\���\��̓f�[�^\';
%dir_out= 'D:\�f�X�N�g�b�v\MATLAB\����\���\��͌���\0915\';
savedir = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\RESULTS\check\';
keisiki = 'png';

%% Input
% Fs = input('Fs��I�����Ă�������[1:4kHz/2:125Hz]:');
% DAYS = input('���t����͂��Ă�������[�N/��/��]: ','s');

display('�ǂ݂����t�@�C���̑I��:') %e.g. f1903311130.ump 
[fname,pathstr] = uigetfile('*.***', 'Choose a data-file'); 
[pathstr,fname,ext]=fileparts([pathstr,fname]);

% load_sec = input('�\������b���̓���:');
load_sec = 14;% 7min> 420

S_HOUR = fname(8:9);
S_MINUTE = fname(10:11);
S_SECOND = '345';  % �\��������b���̊J�n�b
s_hour = str2double(S_HOUR);
s_minute = str2double(S_MINUTE);
s_second = str2double(S_SECOND);

e_hour = s_hour;
e_minute = s_minute+floor(load_sec/60);
e_second = s_second+mod(load_sec,60);

s_time_sec = 3600*s_hour + 60*s_minute; %�J�n����(sec)
e_time_sec = 3600*e_hour + 60*e_minute + e_second; %�I������(sec)
time_sec = 3600*s_hour + 60*str2double([S_MINUTE(1) '0']); %�ǂގ����̒���(sec)

% ch = input('�\������`�����l���̑I��[1/2]:');
%% To read binary

Sec=e_time_sec - time_sec;
Sec2=e_time_sec - s_time_sec;
HEADER_LEN=128;%header
AD_LEN=10;%5chx2byte
DATA_LEN=4000; %16bitx5chx4kHz

% if Fs == 1
%filename = [pathstr '\' fname ext];
filename = [pathstr '/' fname ext] %For MAC 20200604
l = length(filename);
tf = strcmp(filename(l-2:l),'uec');   %�t�@�C���̊g���q�ɂ���Ċϑ��_�̖��O�t�� ����012, UMP:ump or 012
station=filename(l-2:l)
% 
if tf == 1
    basho = 'uec';
else
    basho = 'OTHER';
end

% basho = '����';
Leco=4000;
% elseif Fs == 2 
% filename = [dir_in 'F' YEAR(3:4) MONTH DAY S_HOUR S_MINUTE(1) '0a.uec'];
% Leco=125;
% end

fa = zeros(6,Leco*(Sec2));
time = zeros(1,Leco*(Sec2));
B = zeros(2,Leco*(Sec2));

% Read the contents back into an array
fid = fopen(filename)

%fid2 = fopen('time.txt','wt');
count2 = 0;
k=0;
for j = 0:(Sec-1)
    if j >= s_time_sec - time_sec
        k=count2*Leco;
        count2 = count2+1;
    end
    [F_nums,count] = fread(fid, 128);%'		% read the first 128 bytes ('%FREAD')

    %fprintf(fid2,'%s\n',F_nums);

        for i = 1:Leco       
            F_Data = fread(fid, 10);%'		% read the first 10 bytes ('%FREAD')
            fa(1,i+k) = j+(i-1)/4000;
            time(1,i+k) = fa(1,i+k);
            fa(2,i+k) = byte2ad16(F_Data(1),F_Data(2));%CH1
          %  B(1,i+k) = fa(2,i+k); %CH1
           B(1,i+k) = fa(2,i+k)./80; %CH1
           %B(1,i+k) = (fa(2,i+k)-(20/21)).*(21/500);
            fa(3,i+k) = byte2ad16(F_Data(3),F_Data(4));%CH2
            %B(2,i+k) = fa(3,i+k); %CH2
            B(2,i+k) = fa(3,i+k)./80; %CH2
            %B(2,i+k) = (fa(3,i+k)-(27/38)).*(19/925); 
            fa(4,i+k) = byte2ad16(F_Data(5),F_Data(6));%CH3
            fa(5,i+k) = byte2ad16(F_Data(7),F_Data(8));%CH4
            fa(6,i+k) = byte2ad16(F_Data(9),F_Data(10));%CH5
        end
        %%%%%%%%%% �w�莞���ȊO��clear %%%%%%%%%%%%
        if j < s_time_sec - time_sec
%         if j < 400
            disp('check');
        clear fa
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

B = B(:,:).*2^(-16).*20; %1LSB��2^(-16)*20��305��V

fclose(fid);
%fclose(fid2);

%% To plot figures
%%%%%%%%%%%%%%%%%%%% �g�` %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- ���g�` --%
subplot(2,2,1)
    plot(fa(1,1+Leco*s_second:end-Leco*10),B(1,1+Leco*s_second:end-Leco*10) , '-b');
    % ylim([-0.5 0.5]);
     yticks(-0.5:0.1:0.5);
    title('TRU 2020/07/03 15:55:45~49(ch1)Bns');
    xlabel('Time [s]','FontSize',10);
    ylabel('Voltage[V]','FontSize',10);
    grid on
    
subplot(2,2,2)
    plot(fa(1,1+Leco*s_second:end-Leco*10),B(2,1+Leco*s_second:end-Leco*10) , '-b');
    %ylim([-0.5 0.5]);
    yticks(-0.5:0.05:0.5);
    title('TRU 2020/07/03 15:55:45~49(ch2)Bew');
    xlabel('Time [s]','FontSize',10);
    ylabel('Voltage[V]','FontSize',10);
    grid on

%-- �t�B���^��g�` --%
   filterd1 = func_notch_westjp_00(B(1,:),Leco,1000);
   filterd2 = func_notch_westjp_00(B(2,:),Leco,1000);
%    filterd2 = func_notch_49_5Hz(B(2,:),Leco,1000);
%    filterd2 = func_notch_50_5(B(2,:),Leco,1000);
   
   
   subplot(2,2,3) 
    plot(fa(1,1+Leco*s_second:end-Leco*10),filterd1(1,1+Leco*s_second:end-Leco*10) , '-b');
 title('TRU 2020/07/03 15:55:45~49(ch1)Bns');
 xlabel('Time [s]','FontSize',10);
ylabel('Voltage[V]','FontSize',10);
 grid on
 
 subplot(2,2,4) 
  plot(fa(1,1+Leco*s_second:end-Leco*10),filterd2(1,1+Leco*s_second:end-Leco*10) , '-b');
    title('TRU 2020/07/03 15:55:45~49 (ch2)Bew');
    xlabel('Time [s]','FontSize',10);
ylabel('Voltage[V]','FontSize',10);
    grid on
  saveas(gcf,[savedir 'ELF_waveform_filterAdd'],keisiki);
%Dynamic Spectrum---------------------------------------------

%%%% ���[�f�[�^ %%%%%%%%%%%%%
  subplot(2,2,1) 
   spectrogram(B(1,1+Leco*s_second:end-Leco*10),20000,18000,20000,'yaxis');
   title('spectrogram Bns raw 201903/31 11:50~10 min');
   ax.TitleFontSizeMultiplier = 0.1;
  xlabel('Time [s]');
   ylabel('Frequency [Hz]');
  yticks([0:0.01:0.05]);
     ylim([0.02 0.04]);
     colormap(jet);
   c = colorbar;
c.Label.String = 'Power/Frequency [dB/Hz]';
    caxis([-50 50]);
 

   subplot(2,2,2) 
    spectrogram(B(2,1+Leco*s_second:end-Leco*10),20000,18000,20000,'yaxis');
       title('TRU spectrogram Bew raw 2020/09/16 00:00~10 min');
       ax.TitleFontSizeMultiplier = 0.1;
     xlabel('Time  [s]');
   ylabel('Frequency [Hz]');
     yticks([0:0.01:0.05]);
     ylim([0.02 0.04]);
     colormap(jet);
      c = colorbar;
c.Label.String = 'Power/Frequency [dB/Hz]';
    caxis([-50 50]);

%%%%%%%%% �t�B���^�� %%%%%%%%%%%%%%%%%%
  subplot(2,2,3) 
   spectrogram(filterd1(1,1+Leco*s_second:end-Leco*10),20000,18000,20000,'yaxis');
      title('TRU spectrogram Bns filtered 2020/09/16 00:00~10 mi');
      ax.TitleFontSizeMultiplier = 0.1;
  xlabel('Time [s]');
   ylabel('Frequency [Hz]');
  yticks([0:0.01:0.05]);
     ylim([0.02 0.04]);
     colormap(jet);
   c = colorbar;
c.Label.String = 'Power/Frequency [dB/Hz]';
    caxis([-50 50]);
 

   subplot(2,2,4) 
    spectrogram(filterd2(1,1+Leco*s_second:end-Leco*10),20000,18000,20000,'yaxis');
       title('TRU spectrogram Bew filtered 2020/09/16 00:00~10 mi');
       ax.TitleFontSizeMultiplier = 0.1;
   xlabel('Time  [s]');
   ylabel('Frequency [Hz]');
     yticks([0:0.01:0.05]);
     ylim([0.02 0.04]);
     colormap(jet);
      c = colorbar;
c.Label.String = 'Power/Frequency [dB/Hz]';
    caxis([-50 50]);
  saveas(gcf,[savedir 'ELF_spectrogram_filterAdd'],keisiki);
%Power Spectrum---------------------------------------------
%%%%% ���[�f�[�^ %%%%%%%%%%%%%%%%%
subplot(2,2,1) 
periodogram(B(1,1+Leco*s_second:end-Leco*10),[],40000);
title('TRU PSD Bns_raw');
xlabel('Frequency [Hz]');
ylabel('PSD [dB/Hz])');
%dim = [.2 .5 .3 .4];
%str = 'frequency resolution:0.1';
%annotation('textbox',dim,'String',str,'FitBoxToText','on');
    %xlim([0.0225 0.0275]);
     xlim([0.0275 0.0325]);
       ylim([-20 50]);
       xline(0.025,'--r',{'50 Hz'});

subplot(2,2,2) 
periodogram(B(2,1+Leco*s_second:end-Leco*10),[],40000);
title('TRU PSD Bew_raw');
xlabel('Frequency [Hz]');
ylabel('PSD [dB/Hz])');
% dim = [.2 .5 .3 .3];
% str = 'frequency resolution:0.1';
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
 %   xlim([0.0225 0.0275]);
  xlim([0.0275 0.0325]);
       ylim([-20 50]);
       xline(0.025,'--r',{'50 Hz'});
%%%%% �t�B���^��@%%%%%%%%%%%%%%%%
subplot(2,2,3) 
periodogram(filterd1(1,1+Leco*s_second:end-Leco*10),[],40000);
title('TRU PSD Bns_filtered');
xlabel('Frequency [Hz]');
ylabel('PSD [dB/Hz])');
% dim = [.2 .5 .3 .3];
% str = 'frequency resolution:0.1';
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
 %  xlim([0.0225 0.0275]);
  xlim([0.0275 0.0325]);
      ylim([-20 50]);
   xline(0.025,'--r',{'50 Hz'});

subplot(2,2,4) 
periodogram(filterd2(1,1+Leco*s_second:end-Leco*10),[],40000);
title('TRU PSD Bew_filtered');
xlabel('Frequency [Hz]');
ylabel('PSD [dB/Hz])');
% dim = [.2 .5 .3 .3];
% str = 'frequency resolution:0.1';
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
   %xlim([0.0225 0.0275]);
   xlim([0.0275 0.0325]);
   ylim([-20 50]);
   xline(0.025,'--r',{'50 Hz'});
  
 saveas(gcf,[savedir 'ELF_PSD_filterAdd'],keisiki);
  

%---------------------------------------------------------------------


