clear; close all; clc;

%帧数，时间戳，坐标，俯仰角，航向角，横滚角
[n,time,x,y,z,pitch,yaw,roll] = textread('/Users/gaoyi/Desktop/SlamData.txt','%n %n %f %f %f %f %f %f');

figure;
subplot(2,3,1);
plot(n,x,'^r');
grid on;
xlabel('第n次更新');
ylabel('东西方向位置');

subplot(2,3,2);
plot(n,y,'-g');
grid on;
xlabel('第n次更新');
ylabel('上下方向位置');

subplot(2,3,3);
plot(n,z,'xb');
grid on;
xlabel('第n次更新');
ylabel('南北方向位置');

subplot(2,3,4);
plot(n,pitch,'+y');
grid on;
xlabel('第n次更新');
ylabel('俯仰角');

subplot(2,3,5);
plot(n,yaw,'.k');
grid on;
xlabel('第n次更新');
ylabel('航向角');

subplot(2,3,6);
plot(n,roll,'*m');
grid on;
xlabel('第n次更新');
ylabel('横滚角');

