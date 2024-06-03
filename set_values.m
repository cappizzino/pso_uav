function output = set_values(response_params, kiwxy, kibxy, kq_roll_pitch, kq_yaw,...
    kw_rp, kw_y, pos_pid_p, pos_pid_d, pos_pid_i,...
    hdg_pid_p, hdg_pid_d, hdg_pid_i, km)

    response_params.Config.Doubles(1).Value = kiwxy;
    response_params.Config.Doubles(2).Value = kibxy;
    response_params.Config.Doubles(5).Value = kq_roll_pitch;
    response_params.Config.Doubles(6).Value = kq_yaw;

    response_params.Config.Doubles(7).Value = kw_rp;
    response_params.Config.Doubles(8).Value = kw_y;

    response_params.Config.Doubles(9).Value = pos_pid_p;
    response_params.Config.Doubles(10).Value = pos_pid_d;
    response_params.Config.Doubles(11).Value = pos_pid_i;

    response_params.Config.Doubles(12).Value = hdg_pid_p;
    response_params.Config.Doubles(13).Value = hdg_pid_d;
    response_params.Config.Doubles(14).Value = hdg_pid_i;

    response_params.Config.Doubles(15).Value = km;

output = response_params;