function output = test_UAVcontroller(clienttakeoff, clientparams, subpose, paramNames, params)

    % % set parameters for all the gains
    % % then you'll have to switch to a ROS service
    % for i=1:length(params)
    %     set(ptree,paramNames(i), params(i));
    % end
    
    %% set parameters with ROS service
    % you will need to create the message first, taking the necessary
    % variables from the paramNames string array and related values from
    % params (similar to what I did with the set above)
    % then you simply have to call the service (as done below)
    request_params = rosmessage(clientparams);
    response_params = call(clientparams,request_params,'Timeout',3);
    response_params = set_values(response_params, params(1), params(2),...
        params(3), params(4), params(5));
    response_params = call(clientparams,response_params,'Timeout',3);

    fprintf('kiwxy: %5.3f \n', response_params.Config.Doubles(1).Value);
    fprintf('kibxy: %5.3f \n', response_params.Config.Doubles(2).Value);
    fprintf('kq_roll_pitch: %5.3f \n', response_params.Config.Doubles(5).Value);
    fprintf('kq_yaw: %5.3f \n', response_params.Config.Doubles(6).Value);
    fprintf('km: %5.3f \n', response_params.Config.Doubles(7).Value);

    %% send command to take-off with ROS service
%     clienttakeoffreq = rosmessage(clienttakeoff); % create an empty request message for take-off service
%     feedbackclient = call(clienttakeoff,clienttakeoffreq,"Timeout",3);

    % get real output by subscribing to topic and turned data into a matrix, with X, Y, and Z values
    % per column, with each row being a subsequent sample
    output = [];
    for i=1:1000 % you can manipulate this number of samples depending on the frequency of the published pose
        msgpose = receive(subpose,1);
        output = [output; msgpose.Pose.Pose.Position.X,...
            msgpose.Pose.Pose.Position.Y, msgpose.Pose.Pose.Position.Z];
    end
    


