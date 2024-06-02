function output = set_values(response_params, kiwxy, kibxy, kq_roll_pitch, kq_yaw, km)

    response_params.Config.Doubles(1).Value = kiwxy;
    response_params.Config.Doubles(2).Value = kibxy;
    response_params.Config.Doubles(5).Value = kq_roll_pitch;
    response_params.Config.Doubles(6).Value = kq_yaw;
    response_params.Config.Doubles(7).Value = km;

output = response_params;