close all; clear all; clc;
rosshutdown();
%% connect to the ROS network (if it is under a different IP, do not forget to add the IP)
rosinit();

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
clientparams = rossvcclient("/uav1/control_manager/mpc_controller/set_parameters","DataFormat","struct");
request_params = rosmessage(clientparams);
response_params = call(clientparams,request_params,'Timeout',3);

fprintf('kiwxy: %5.3f \n', response_params.Config.Doubles(1).Value);
fprintf('kibxy: %5.3f \n', response_params.Config.Doubles(2).Value);
fprintf('kq_roll_pitch: %5.3f \n', response_params.Config.Doubles(5).Value);
fprintf('kq_yaw: %5.3f \n', response_params.Config.Doubles(6).Value);
fprintf('km: %5.3f \n', response_params.Config.Doubles(7).Value);

%% create subscriber for getting the groundtruth pose (controller)
subpose = rossubscriber("/uav1/estimation_manager/gps_garmin/odom","DataFormat","struct");

%% define number of parameters (gains) and related names to be optimised (update these according to the ROS params you need to change)
npar = 5;
paramNames = ["kiwxy", "kibxy", "kq_roll_pitch", "kq_yaw", "km"];
paramValues = [response_params.Config.Doubles(1).Value,...
    response_params.Config.Doubles(2).Value,...
    response_params.Config.Doubles(5).Value,...
    response_params.Config.Doubles(6).Value,...
    response_params.Config.Doubles(7).Value];

%% define search space for each gain. Here I am doing it for all the gains the same, though it is likely that you will need to create individual thresholds for each different gain
xmin = 0.2*paramValues;
xmax = 1.5*paramValues;

%% define desired output. To make it easier, for now, I consider the take-off situation with static x,y and z.
desired_output = [0, 0, 1.65];

%% run PSO
clienttakeoff = "";
population = 5;
iterations = 1;

t0 = datetime('now');

[xbest,fit] = pso(clienttakeoff, clientparams, subpose, paramNames,...
    desired_output, npar, xmin, xmax, 'min', population, iterations);

tf = datetime('now');

disp("Start: ");
disp(t0);

disp("End: ");
disp(tf);

duration = tf - t0;
disp("Duration: ");
disp(duration);


%% shutdown the connection with the ROS network
rosshutdown();

%% Callback functions
function pauseButtonCallback(~, ~)
    assignin('base', 'pauseFlag', true);
end

function resumeButtonCallback(~, ~)
    assignin('base', 'pauseFlag', false);
end