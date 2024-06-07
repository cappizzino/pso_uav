function [xbest,fit]=pso(clienttakeoff, clientparams, subpose, paramNames,...
    desired_output,npar,xmin,xmax,type,population,iterations, replace_gbest)

% pso - MatLab function for PSO (Particle Swarm Optimization). Limited to
% optimization problems of nine variables but can easily be extended
% many more variables.
%
% xbest = pso(func)
% xbest - solution of the optimization problem. The number of columns
% depends on the input func. size(func,2)=number of xi variables
% func - string containing a mathematic expression. Variables are defined
% as xi. For instance, func='2*x1+3*x2' means that it is an optimization problem of
% two variables.
%
% [xbest,fit] = pso(func)
% fit - returns the optimized value of func using the xbest solution.
%
% [xbest,fit] = pso(func,xmin)
% xmin - minimum value of xi. size(xmin,2)=number of xi variables. Default
% -100.
%
% [xbest,fit] = pso(func,xmin,xmax)
% xmax - maximum value of xi. size(xmax,2)=number of xi variables. Default
% 100.
%
% [xbest,fit] = pso(func,xmin,xmax,type)
% type - minimization 'min' or maximization 'max' of the problem. Default
% 'min'.
%
% [xbest,fit] = pso(func,xmin,xmax,type,population)
% population - number of the swarm population. Default 50.
%
% [xbest,fit] = pso(func,xmin,xmax,type,population,iterations)
% iterations - number of iterations. Default 500.
%
% Example:  xbest = pso('10+5*x1^2-0.8*x2',[-10 -20],[20 40],'min')
%
% Micael S. Couceiro
% v1.0
% 15/11/2010
%
% Original algorithm developed by: 
% Kennedy, J. and Eberhart, R. C. (1995).
% "Particle swarm optimization".
% Proceedings of the IEEE 1995 International Conference on Neural Networks, pp. 1942-1948.


% fun=inline(func);

N_PAR=npar;

if (nargin<6)
    iterations=500;
    if (nargin<5)
        population=50;
        if (nargin<4)
            type='min';
            if (nargin<3)
                xmax=100*ones(1,N_PAR);
                if (nargin<2)
                    xmin=-100*ones(1,N_PAR);
                end
            end
        end
    end
end

N = population;

N_GER = iterations;

PHI1 = 1.5;
PHI2 = 1.5;
W = 1;

v=zeros(N,N_PAR);

X_MAX = xmax;
X_MIN = xmin;

vmin=-(max(xmax)-min(xmin))/(N*5);
vmax=(max(xmax)-min(xmin))/(N*5);

gBest = zeros(1,N_PAR);

if strcmp(type,'min')==1
    gbestvalue = 1000000;
elseif strcmp(type,'max')==1
    gbestvalue = -1000000;
end

gaux = ones(N,1);

xBest=zeros(N,N_PAR);
fitBest=zeros(N,1);

fit = zeros(N,1);
nger=1;
writematrix(nger);

x=initSwarm(N, N_PAR, X_MIN, X_MAX);

if replace_gbest == 1
    gBestFile = readmatrix('gBest.txt');
    x(1,:) = gBestFile
end

disp("****************************");
input('Press ''Enter'' after take off...','s');

for j=1:N
    disp("****************************");
    fprintf('First part: %d of %d \n', j, N);
    start_time_pso = datetime ('now');
    real_output_array = test_UAVcontroller_se3(clienttakeoff, clientparams, subpose, paramNames, x(j,:));
    desired_output_array = desired_output.*ones(size(real_output_array,1),1);
    fit(j) = rmse(desired_output_array, real_output_array, 'all');
    fitBest(j)=fit(j);
    end_time_pso = datetime ('now');
    disp("Duration: ");
    disp(end_time_pso - start_time_pso);
end

if strcmp(type,'min')==1
    [a,b]=min(fit);
elseif strcmp(type,'max')==1
    [a,b]=max(fit);
end

gBest=x(b,:);
gbestvalue = fit(b);

xBest = x;

writematrix(gBest);
writematrix(gbestvalue);

FIT = [];

cntStag = 0;
while(nger<=N_GER)
    i=1;
    start_time_pso = datetime ('now');
    disp("****************************");
    fprintf('N Ger %d of %d \n', nger, N_GER);
    disp("****************************");

    randnum1 = rand ([N, N_PAR]);
    randnum2 = rand ([N, N_PAR]);
    
    v = W.*v + randnum1.*(PHI1.*(xBest-x)) + randnum2.*(PHI2.*(gaux*gBest-x));         %cria uma matriz v com N linhas e 4(nº de ks) colunas
    
    v = ( (v <= vmin).*vmin ) + ( (v > vmin).*v );
    v = ( (v >= vmax).*vmax ) + ( (v < vmax).*v );
    
    x = x+v;
    
    for j = 1:N,
        for k = 1:N_PAR,
            if x(j,k) < X_MIN(k)
                x(j,k) = X_MIN(k);
            elseif x(j,k) > X_MAX(k)
                x(j,k) = X_MAX(k);
            end
        end
    end
    
    while(i<=N)
        if(i==N)
            for j=1:N
                fprintf('Second part: %d \n', j);
                real_output_array = test_UAVcontroller_se3(clienttakeoff, clientparams, subpose, paramNames, x(j,:));
                desired_output_array = desired_output.*ones(size(real_output_array,1),1);
                fit(j) = rmse(desired_output_array, real_output_array, 'all');
                disp("****************************");
                if fit(j) < fitBest(j)
                    fitBest(j) = fit(j);
                    xBest(j,:) = x(j,:);
                end
            end
            
            if strcmp(type,'min')==1
                [a,b]=min(fit);
                if (fit(b) < gbestvalue)
                    gBest=x(b,:);
                    gbestvalue = fit(b);
                    cntStag = 0;
                end
            elseif strcmp(type,'max')==1
                [a,b]=max(fit);
                if (fit(b) > gbestvalue)
                    gBest=x(b,:);
                    gbestvalue = fit(b);
                    cntStag = 0;
                end
            end
            writematrix(gBest);
            writematrix(gbestvalue);
        end
       i=i+1;
    end

    writematrix(nger);
    nger=nger+1;
    FIT = [FIT;gbestvalue];
    figure(1);
    plot(FIT);
    drawnow;
    cntStag = cntStag + 1;
    if cntStag >= 50
        break;
    end
    end_time_pso = datetime ('now');
    disp("Duration: ");
    disp(end_time_pso - start_time_pso);
end
xbest=gBest;
fit=gbestvalue;
% plot(FIT);



function [swarm]=initSwarm(N, N_PAR, V_MIN, V_MAX)
swarm = zeros(N,N_PAR);
for i = 1: N
    for j = 1: N_PAR
        swarm(i,j) = rand(1,1) * ( V_MAX(j)-V_MIN(j) ) + V_MIN(j);
    end
end
