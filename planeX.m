function []=planeX()
T=200;
N_VIP=ceil(T*0.45);
N=T-N_VIP;

M_A=2;
M_VIP=1;
M_B=5;

% A_VIP服务台
X_A_VIP=zeros(N_VIP,5);
Y_VIP=zeros(M_VIP,1);
Z_VIP=zeros(M_VIP,N_VIP);

% 到达A_VIP服务台时间间隔服从泊松分布
lam_VIP=12.9565;
time_arrive_A_VIP=zeros(1,N_VIP);
time_arrive_A_VIP(1)=0;

for i=2:N_VIP
    time_arrive_A_VIP(i)=ceil(poissrnd(lam_VIP))+time_arrive_A_VIP(i-1);
    X_A_VIP(i,1)=time_arrive_A_VIP(i);
end

% A_VIP服务台服务时间间隔服从负指数分布
u=1/11.3125;
time_check_A_VIP=zeros(1,N_VIP);
for i=1:N_VIP
    time_check_A_VIP(i)=ceil(exprnd(1/u));
    X_A_VIP(i,2)=time_check_A_VIP(i);
end

% A_VIP服务台检查
for i=1:N_VIP
    if time_arrive_A_VIP(i)>=max(Y_VIP)
        X_A_VIP(i,3)=0;
        Y_VIP(1,1)=time_arrive_A_VIP(i)+time_check_A_VIP(i);
        Z_VIP(1,i)=time_check_A_VIP(i);
    elseif time_arrive_A_VIP(i)<min(Y_VIP)
        [m,~]=find(Y_VIP==min(Y_VIP));
        Y_VIP(m(1),1)=min(Y_VIP)+time_check_A_VIP(i);
        X_A_VIP(i,3)=min(Y_VIP)-time_arrive_A_VIP(i);
        Z_VIP(m(1),i)=time_check_A_VIP(i);
    else
        [m,~]=find(Y_VIP==min(Y_VIP));
        Y_VIP(m(1),1)=time_arrive_A_VIP(i)+time_check_A_VIP(i);
        X_A_VIP(i,3)=0;
        Z_VIP(m(1),i)=time_check_A_VIP(i);
    end
    X_A_VIP(i,4)=X_A_VIP(i,1)+X_A_VIP(i,2)+X_A_VIP(i,3);
    X_A_VIP(i,5)=1;
end

time_wait_TAL_A_VIP=0;
for i=1:N_VIP
    time_wait_TAL_A_VIP=time_wait_TAL_A_VIP+X_A_VIP(i,3);
end
disp(time_wait_TAL_A_VIP/N_VIP);
disp(N/X_A_VIP(N_VIP,4)*60);

figure(1)
i=1:N_VIP;
subplot(2,1,1);
plot(i,X_A_VIP(i,3));
subplot(2,1,2);
bar(i,X_A_VIP(i,3),'white');
axis([0 N_VIP 0 100]);


% A服务台
X_A=zeros(N,5);
Y=zeros(M_A,1);
Z=zeros(M_A,N);

% 到达A服务台时间间隔服从泊松分布
lam=9.193;
time_arrive_A=zeros(1,N);
time_arrive_A(1)=0;

for i=2:N
    time_arrive_A(i)=ceil(poissrnd(lam))+time_arrive_A(i-1);
    X_A(i,1)=time_arrive_A(i);
end


% A服务台服务时间间隔服从负指数分布
u=1/11.3125;
time_check_A=zeros(1,N);
for i=1:N
    time_check_A(i)=ceil(exprnd(1/u));
    X_A(i,2)=time_check_A(i);
end

% for i=1:M
%     Y(i,1)=time_arrive(i)+time_check(i);
% end

% A服务台检查
for i=1:N
    if time_arrive_A(i)>=max(Y)
        X_A(i,3)=0;
        Y(1,1)=time_arrive_A(i)+time_check_A(i);
        Z(1,i)=time_check_A(i);
    elseif time_arrive_A(i)<min(Y)
        [m,~]=find(Y==min(Y));
        Y(m(1),1)=min(Y)+time_check_A(i);
        X_A(i,3)=min(Y)-time_arrive_A(i);
        Z(m(1),i)=time_check_A(i);
    else
        [m,~]=find(Y==min(Y));
        Y(m(1),1)=time_arrive_A(i)+time_check_A(i);
        X_A(i,3)=0;
        Z(m(1),i)=time_check_A(i);
    end
    X_A(i,4)=X_A(i,1)+X_A(i,2)+X_A(i,3);
end

time_wait_TAL_A=0;
for i=1:N
    time_wait_TAL_A=time_wait_TAL_A+X_A(i,3);
end
disp(time_wait_TAL_A/N);
disp(N/X_A(N,4)*60);

figure(2)
i=1:N;
subplot(2,1,1);
plot(i,X_A(i,3));
subplot(2,1,2);
bar(i,X_A(i,3),'white');
axis([0 N 0 100]);

% 拼合旅客
X=[X_A;X_A_VIP];
for i=1:T
    j=1;
    while j<=T
        if X(i,4)>=X(j,4)
            j=j+1;
        else
            X([i j],:)=X([j i],:);
        end
    end
end

% B服务台
X_B=zeros(N,3);
Y_B=zeros(M_B,1);
Z_B=zeros(M_B,N);

% 到达B服务台时间
time_arrive_B=zeros(1,N);
for i=1:T
    time_arrive_B(i)=X(i,1)+X(i,2)+X(i,3);
    X_B(i,1)=time_arrive_B(i);
end

% B服务台服务时间间隔服从负指数分布
u=1/28.6207;
time_check_B=zeros(1,N);
for i=1:T
    if X(i,5)==1
        time_check_B(i)=ceil(exprnd(1/u-10));
    else
        time_check_B(i)=ceil(exprnd(1/u));
    end
    X_B(i,2)=time_check_B(i);
end

% B服务台检查
for i=1:T
    if time_arrive_B(i)>=max(Y_B)
        X_B(i,3)=0;
        Y_B(1,1)=time_arrive_B(i)+time_check_B(i);
        Z_B(1,i)=time_check_B(i);
    elseif time_arrive_B(i)<min(Y_B)
        [m,~]=find(Y_B==min(Y_B));
        Y_B(m(1),1)=min(Y_B)+time_check_B(i);
        X_B(i,3)=min(Y_B)-time_arrive_B(i);
        Z_B(m(1),i)=time_check_B(i);
    else
        [m,~]=find(Y_B==min(Y_B));
        Y_B(m(1),1)=time_arrive_B(i)+time_check_B(i);
        X_B(i,3)=0;
        Z_B(m(1),i)=time_check_B(i);
    end
end

figure(3)
i=1:T;
subplot(2,1,1);
plot(i,X_B(i,3),'red');
subplot(2,1,2);
bar(i,X_B(i,3),'white');
axis([0 T 0 100]);

time_wait_TAL_B=0;
for i=1:T
    time_wait_TAL_B=time_wait_TAL_B+X_B(i,3);
end
disp(time_wait_TAL_B/N);
disp(N/X(T,4)*60);
