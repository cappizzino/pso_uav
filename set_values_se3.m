function output = set_values_se3(response_params, kpxy, kvxy, kaxy, kiwxy,...
    kibxy, kpz, kvz, kaz, kq_roll_pitch, kq_yaw, km)

    response_params.Config.Doubles(1).Value = kpxy;
    response_params.Config.Doubles(2).Value = kvxy;
    response_params.Config.Doubles(3).Value = kaxy;
    response_params.Config.Doubles(4).Value = kiwxy;
    response_params.Config.Doubles(5).Value = kibxy;
    response_params.Config.Doubles(8).Value = kpz;
    response_params.Config.Doubles(9).Value = kvz;
    response_params.Config.Doubles(10).Value = kaz;
    response_params.Config.Doubles(11).Value = kq_roll_pitch;
    response_params.Config.Doubles(12).Value = kq_yaw;
    response_params.Config.Doubles(13).Value = km;
    
output = response_params;