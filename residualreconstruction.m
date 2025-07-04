% Read residual data
residuals = int32(load('decoded_residuals.txt')); % Ensure residuals are int32
lpc_coeffs = int32([-46,73,-91,90,-73,48,-27,15,-6,1]);

% Initialize past samples
past_samples = zeros(1, 10, 'int32'); 
reconstructed_signal = zeros(length(residuals), 1, 'int32'); 

% Reconstruct samples
for n = 1:length(residuals)
    % Predict the sample value
    predicted = sum(past_samples .* lpc_coeffs);  
    scaled_predicted = bitshift(int32(predicted), -4); % Scaling by 4 (divide by 16)

    % Reconstruct the sample
    reconstructed_sample = residuals(n) + scaled_predicted;

    % Ensure correct 16-bit two's complement conversion
    if reconstructed_sample > 32767
        reconstructed_sample = reconstructed_sample - 65536;
    elseif reconstructed_sample < -32768
        reconstructed_sample = reconstructed_sample + 65536;
    end

    % Store reconstructed sample
    reconstructed_signal(n) = reconstructed_sample;

    % Update past samples
    past_samples = [reconstructed_sample, past_samples(1:9)];
end

% Write reconstructed samples to hex file
fid = fopen('reconstructed.hex', 'w');
for n = 1:length(reconstructed_signal)
    fprintf(fid, '%04X\n', mod(reconstructed_signal(n), 2^16)); 
end
fclose(fid);

disp('Reconstruction complete. Hex file saved as reconstructed.hex.');