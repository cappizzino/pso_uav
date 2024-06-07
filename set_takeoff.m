function output = set_takeoff(clientparams)
    request_params = rosmessage(clientparams);
    response_params = call(clientparams,request_params,'Timeout',3);

    params_takeoff = readmatrix('takeoff.txt');

    request_params = set_values(response_params, params_takeoff(1),...
        params_takeoff(2),params_takeoff(3),params_takeoff(4),...
        params_takeoff(5),params_takeoff(6),params_takeoff(7),...
        params_takeoff(8),params_takeoff(9),params_takeoff(10),...
        params_takeoff(11),params_takeoff(12),params_takeoff(13));

    response_params = call(clientparams,request_params,'Timeout',3);

    fprintf('kiwxy: %5.4f \n', response_params.Config.Doubles(1).Value);
    fprintf('kibxy: %5.4f \n', response_params.Config.Doubles(2).Value);
    fprintf('kq_roll_pitch: %5.4f \n', response_params.Config.Doubles(5).Value);
    fprintf('kq_yaw: %5.4f \n', response_params.Config.Doubles(6).Value);
    
    fprintf('kw_rp: %5.4f \n', response_params.Config.Doubles(7).Value);
    fprintf('kw_y: %5.4f \n', response_params.Config.Doubles(8).Value);
    
    fprintf('pos_pid_p: %5.4f \n', response_params.Config.Doubles(9).Value);
    fprintf('pos_pid_d: %5.4f \n', response_params.Config.Doubles(10).Value);
    fprintf('pos_pid_i: %5.4f \n', response_params.Config.Doubles(11).Value);
    
    fprintf('hdg_pid_p: %5.4f \n', response_params.Config.Doubles(12).Value);
    fprintf('hdg_pid_d: %5.4f \n', response_params.Config.Doubles(13).Value);
    fprintf('hdg_pid_i: %5.4f \n', response_params.Config.Doubles(14).Value);

    fprintf('km: %5.4f \n', response_params.Config.Doubles(15).Value);

    output = response_params;