clear; close all; clc;

%֡����ʱ��������꣬�����ǣ�����ǣ������
[n,time,x,y,z,pitch,yaw,roll] = textread('/Users/gaoyi/Desktop/SlamData.txt','%n %n %f %f %f %f %f %f');

figure;
subplot(2,3,1);
plot(n,x,'^r');
grid on;
xlabel('��n�θ���');
ylabel('��������λ��');

subplot(2,3,2);
plot(n,y,'-g');
grid on;
xlabel('��n�θ���');
ylabel('���·���λ��');

subplot(2,3,3);
plot(n,z,'xb');
grid on;
xlabel('��n�θ���');
ylabel('�ϱ�����λ��');

subplot(2,3,4);
plot(n,pitch,'+y');
grid on;
xlabel('��n�θ���');
ylabel('������');

subplot(2,3,5);
plot(n,yaw,'.k');
grid on;
xlabel('��n�θ���');
ylabel('�����');

subplot(2,3,6);
plot(n,roll,'*m');
grid on;
xlabel('��n�θ���');
ylabel('�����');

