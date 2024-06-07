function output = test_UAVcontroller(clienttakeoff, clientparams, subpose, paramNames, params)

    % % set parameters for all the gains
    % % then you'll have to switch to a ROS service
    % for i=1:length(params)
    %     set(ptree,paramNames(i), params(i));
    % end
    %% Pause
    % Check the pause flag
    first_time = 1;
    while evalin('base', 'pauseFlag')
        if first_time == 1
            disp("*** Set take-off parameters ***");
            set_takeoff(clientparams);
            first_time = 0;
            disp("*** Press Resume after take off ***");
        end
        pause(0.1);
    end


    %% set parameters with ROS service
    % you will need to create the message first, taking the necessary
    % variables from the paramNames string array and related values from
    % params (similar to what I did with the set above)
    % then you simply have to call the service (as done below)
    request_params = rosmessage(clientparams);
    response_params = call(clientparams,request_params,'Timeout',3);
    response_params = set_values_se3(response_params, params(1), params(2),...
        params(3), params(4), params(5), params(6), params(7), params(8),...
        params(9), params(10), params(11));
    response_params = call(clientparams,response_params,'Timeout',3);

    disp("****************************");
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

    %% send command to take-off with ROS service
%     clienttakeoffreq = rosmessage(clienttakeoff); % create an empty request message for take-off service
%     feedbackclient = call(clienttakeoff,clienttakeoffreq,"Timeout",3);

    % get real output by subscribing to topic and turned data into a matrix, with X, Y, and Z values
    % per column, with each row being a subsequent sample
    output = [];
    for i=1:1500 % you can manipulate this number of samples depending on the frequency of the published pose
        msgpose = receive(subpose,1);
        output = [output; msgpose.Pose.Pose.Position.X,...
            msgpose.Pose.Pose.Position.Y, msgpose.Pose.Pose.Position.Z];
    end
    


