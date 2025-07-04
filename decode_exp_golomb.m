fid = fopen('encoded_data.bin', 'rb');
if fid == -1
    error('Failed to open encoded_data.bin');
end

decoded_residuals = []; % Array to store decoded residuals
serial_no = 1;         % Serial number for display

data = fread(fid, 'uint16'); % Read binary file as 16-bit values
fclose(fid);

% Decode each value
for i = 1:length(data)
    y = data(i); % Extract the encoded value
    if mod(y, 2) == 0
        x = y / 2;  % Positive residual
    else
        x = -((y + 1) / 2); % Negative residual
    end
    decoded_residuals = [decoded_residuals; x];
    fprintf('%d: %d\n', serial_no, x); % Display with serial number
    serial_no = serial_no + 1;
end

% Save the decoded values to a text file
fid_out = fopen('decoded_residuals.txt', 'w');
for i = 1:length(decoded_residuals)
    fprintf(fid_out, '%d\n', decoded_residuals(i));
end
fclose(fid_out);

disp('Decoding complete. Results saved in decoded_residuals.txt');