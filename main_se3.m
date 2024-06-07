close all; clear all; clc;
rosshutdown();
%% connect to the ROS network (if it is under a different IP, do not forget to add the IP)
rosinit('192.168.8.170')

%% Push button
% hFig = figure('Name', 'Pause Script', 'NumberTitle', 'off');
% pauseButton = uicontrol('Style', 'pushbutton', 'String', 'Pause', ...
%                         'Position', [20, 20, 60, 30], 'Callback', @pauseButtonCallback);
% resumeButton = uicontrol('Style', 'pushbutton', 'String', 'Resume', ...
%                          'Position', [100, 20, 60, 30], 'Callback', @resumeButtonCallback);
% 
% Define the figure size
figureWidth = 200;
figureHeight = 100;

% Create the figure
hFig = figure('Name', 'Pause Script', 'NumberTitle', 'off', ...
              'Position', [100, 100, figureWidth, figureHeight]);

% Define button size and position
buttonWidth = 60;
buttonHeight = 30;
padding = 20;

% Position the Pause button
pauseButton = uicontrol('Style', 'pushbutton', 'String', 'Pause', ...
                        'Position', [padding, padding, buttonWidth, buttonHeight], ...
                        'Callback', @pauseButtonCallback);

% Position the Resume button
resumeButton = uicontrol('Style', 'pushbutton', 'String', 'Resume', ...
                         'Position', [padding*2 + buttonWidth, padding, buttonWidth, buttonHeight], ...
                         'Callback', @resumeButtonCallback);

% Initialize pause flag
pauseFlag = false;
assignin('base', 'pauseFlag', pauseFlag);


%% create service client for take-off
% clienttakeoff = rossvcclient("/takeoff","DataFormat","struct");

%% create service client for arming
% client_arming = rossvcclient("/uav1/hw_api/arming","DataFormat","struct");
% request_arming = rosmessage(client_arming);
% request_arming.Data = true;
% 
% client_offboard = rossvcclient("/uav1/hw_api/offboard","DataFormat","struct");
% request_offboard = rosmessage(client_offboard);
% 
% response_arming = call(client_arming,request_arming,'Timeout',3);
% pause(2)
% response_offboard = call(client_offboard,request_offboard,'Timeout',3);

%% create service client for setting parameters (gains)
clientparams = rossvcclient("/uav6/control_manager/se3_controller/set_parameters","DataFormat","struct");

%% set takeoff parameters
% response_params = set_takeoff(clientparams);
request_params = rosmessage(clientparams);
response_params = call(clientparams,request_params,'Timeout',3);

% request_params = set_values(response_params, params_takeoff(1),...
%     params_takeoff(2),params_takeoff(3),params_takeoff(4),...
%     params_takeoff(5),params_takeoff(6),params_takeoff(7),...
%     params_takeoff(8),params_takeoff(9),params_takeoff(10),...
%     params_takeoff(11),params_takeoff(12),params_takeoff(13));

% response_params = call(clientparams,request_params,'Timeout',3);

fprintf('kpxy: %5.4f \n', response_params.Config.Doubles(1).Value);
fprintf('kvxy: %5.4f \n', response_params.Config.Doubles(2).Value);
fprintf('kaxy: %5.4f \n', response_params.Config.Doubles(3).Value);
fprintf('kiwxy: %5.4f \n', response_params.Config.Doubles(4).Value);
fprintf('kibxy: %5.4f \n', response_params.Config.Doubles(5).Value);
% fprintf('kiwxy_lim: %5.4f \n', response_params.Config.Doubles(6).Value);
% fprintf('kibxy_lim: %5.4f \n', response_params.Config.Doubles(7).Value);
fprintf('kpz: %5.4f \n', response_params.Config.Doubles(8).Value);
fprintf('kvz: %5.4f \n', response_params.Config.Doubles(9).Value);
fprintf('kaz: %5.4f \n', response_params.Config.Doubles(10).Value);
fprintf('kq_roll_pitch: %5.4f \n', response_params.Config.Doubles(11).Value);
fprintf('kq_yaw: %5.4f \n', response_params.Config.Doubles(12).Value);
fprintf('km: %5.4f \n', response_params.Config.Doubles(13).Value);
% fprintf('km_lim: %5.4f \n', response_params.Config.Doubles(14).Value);

%% create subscriber for getting the groundtruth pose (controller)
subpose = rossubscriber("/uav6/estimation_manager/odom_main","DataFormat","struct");

%% define number of parameters (gains) and related names to be optimised (update these according to the ROS params you need to change)
npar = 11;
paramNames = ["kpxy", "kvxy", "kaxy", "kiwxy", "kibxy"...
    "kpz", "kvz", "kaz", "kq_roll_pitch", "kq_yaw", "km"];
paramValues = [response_params.Config.Doubles(1).Value,...
    response_params.Config.Doubles(2).Value,...
    response_params.Config.Doubles(3).Value,...
    response_params.Config.Doubles(4).Value,...
    response_params.Config.Doubles(5).Value,...
    response_params.Config.Doubles(8).Value,...
    response_params.Config.Doubles(9).Value,...
    response_params.Config.Doubles(10).Value,...
    response_params.Config.Doubles(11).Value,...
    response_params.Config.Doubles(12).Value,...
    response_params.Config.Doubles(13).Value];

%% define search space for each gain. Here I am doing it for all the gains the same, though it is likely that you will need to create individual thresholds for each different gain
% paramNames = ["kpxy", "kvxy", "kaxy", "kiwxy", "kibxy"...
%     "kpz", "kvz", "kaz", "kq_roll_pitch", "kq_yaw", "km"];
factor_min = [0.98, 0.98, 0.98, 0.98, 0.98,...
    0.2, 0.2, 0.2, 0.98, 0.98, 0.2];
factor_max = [1.02, 1.02, 1.02, 1.02, 1.02,...
    1.5, 1.5, 1.5, 1.02, 1.02, 1.5];

xmin = factor_min.*paramValues;
xmax = factor_max.*paramValues;

%% define desired output. To make it easier, for now, I consider the take-off situation with static x,y and z.
desired_output = [10.10, 29.85, 1.5];

%% run PSO
clienttakeoff = "";
population = 30;
iterations = 97;

readFile = 0;
t0 = datetime('now');
[xbest,fit] = pso_se3(clienttakeoff, clientparams, subpose, paramNames,...
    desired_output, npar, xmin, xmax, 'min', population, iterations, readFile);
tf = datetime('now');

disp("Start: ");
disp(t0);
disp("End: ");
disp(tf);
duration = tf - t0;
disp("Duration: ");
disp(duration);

%% Close Figure
close;

%% shutdown the connection with the ROS network
rosshutdown();

%% Callback functions
function pauseButtonCallback(~, ~)
    assignin('base', 'pauseFlag', true);
end

function resumeButtonCallback(~, ~)
    assignin('base', 'pauseFlag', false);
end