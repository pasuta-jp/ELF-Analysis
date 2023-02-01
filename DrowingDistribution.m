%To plot 対数正規累積分布関数 が　直線になるようなY軸を設定したプロット。
%sc_lognormal_dist_20160930 family
%(x, p) ?> x’= f^-1 (p)のあと、ln (x’) をpに対応する値とする。
%p= f(x)に乗っている値は　直線になるはず。
%v2 to add loading real data.
%V04: Rev. for Akama

% Refined by DrowingDistribution.m by AKAMA


%See:
%K. Berger, R. B. Anderson, and H. Kroninger : “ Parameters of lightning flashes ”, Electra, 80, pp.23?37, (1975-7) 

close all;

ddir = 'C:\Users\Akama\Desktop\UNIV\RESEARCH\ANALYSES\MATLAB\DATA\' ;% Data directory
%% 比較するデータをいくつ用意するか決定　%%
nn=6;

%% 比較するデータを格納（データに応じて変数を変更して）%%
%   p3{1}=fpuki;
%   x3{1}=xpuki;
%   p3{2}=fpkanki; 
%   x3{2}=xpkanki;
   p3{1}=fpmalaccauki;
   x3{1}=xpmalaccauki;
   p3{2}=fpmalaccakanki; 
   x3{2}=xpmalaccakanki;
   p3{3}=fptaiuki;
   x3{3}=xptaiuki;
   p3{4}=fptaikanki; 
   x3{4}=xptaikanki;
  p3{5}=fpotheruki;
  x3{5}=xpotheruki;
  p3{6}=fpotherkanki; 
  x3{6}=xpotherkanki;




%対数正規累積分布関数に乗っている分布
xx = (1:0.1:100000) ;% x range (before log)
mu=5.7; 0 % Mean  - *value after log (x)
sigma=0.45; 1%Standard deviation after log(x)

yy =1-logncdf(xx,mu,sigma);



%Y軸：p　の補正：対数正規累積分布逆関数　を使う。 yのpに対応する値  をy2とする。
mu2=mu ;%
sigma2 =sigma ;%
P=yy;
y2 = logninv(P,mu2,sigma2);
%y軸ラベルの設定
p2= [0.1 1,5,10,20,30,50,70,80,90,95,99, 99.9]./100 ;% probability values to make y tick label
s=logninv(p2,mu2,sigma2);
s2=log(s);



%Y-asis setting for data plot
% (x - before taking log, P3 - 0~1 'x100 %')

for i=1:nn
P3 = 1-p3{i};
y3{i} = logninv(P3,mu2,sigma2);
end


%plot
figure
%% 直線を引いて比較したいとき用（mu,sigmaを変更して調整）　%%
%semilogx(xx, log(y2)); % xy軸は対数表示: 対数正規累積分布関数
%additiona plot
%hold on
%for i=1:2

%% プロット（iの値はプロットするデータ数に合わせて変更）　%%
i=1; %positives
semilogx(x3{i}, log(y3{i}),'r');
hold on
i=2; %negatives
semilogx(x3{i}, log(y3{i}),'m');
hold on
  i=3; 
  semilogx(x3{i}, log(y3{i}),'b');
  hold on
  i=4; 
  semilogx(x3{i}, log(y3{i}),'c');
  hold on
 i=5; 
 semilogx(x3{i}, log(y3{i}),'g');
 hold on
 i=6; 
 semilogx(x3{i}, log(y3{i}),'y');
 hold on
%end
title('Ipk (Positive, Malacca - Thailand - Other area)')
xlabel('Ipk [kA]')
ylabel('Cumulative frecuency [%]')
grid
%hold off
%xlim ([])
ylim ([s2(1) s2(end)])
xlim([0 400])

str={'0.1','1','5','10','20','30','50','70','80','90','95','99','99.9'};
set(gca,'FontName','Normal','ytick',s2,'yticklabel',str)

legend('rainy season (Malacca) (743)','dry season (Malacca) (2741)','rainy season (Thailand) (2)','dry season (Thailand) (80)','rainy season (Others) (222)','dry season (Others) (389)','Location','northeast')
%Plus
%legend('rainy season (967)','dry season (3210)','rainy season (Malacca) (743)','dry season (Malacca) (2741)','rainy season (Thailand) (2)','dry season (Thailand) (80)','rainy season (Others) (222)','dry season (Others) (389)','Location','southwest')
%Minus
%legend('rainy season (8196)','dry season (16636)','rainy season (Malacca) (6347)','dry season (Malacca) (12176)','rainy season (Thailand) (68)','dry season (Thailand) (2686)','rainy season (Others) (1781)','dry season (Others) (1774)','Location','southwest')

%legend('lognormal cumulative distribution function','Positive','Negative')
%set(gca,'FontName','ytick',s2,'yticklabel',str)

