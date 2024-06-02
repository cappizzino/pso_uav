function err = rmse(predictions, targets, elements)
    % RMSE Calculate the root mean square error between predictions and targets
    % 
    % err = rmse(predictions, targets)
    %   predictions - Vector or matrix of predicted values
    %   targets - Vector or matrix of actual values
    %   err - Root mean square error

    % Ensure predictions and targets are of the same size
    if ~isequal(size(predictions), size(targets))
        error('Predictions and targets must be of the same size');
    end

    % Compute the mean squared error
    mse = mean((predictions - targets).^2, elements);

    % Take the square root to get RMSE
    err = sqrt(mse);
end