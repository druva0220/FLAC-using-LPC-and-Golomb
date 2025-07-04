clc; clear; close all;

% Load audio file (modify file name as needed)
[audio_data, fs] = audioread('audio.wav');

% Convert to mono if stereo
if size(audio_data, 2) > 1
    audio_data = mean(audio_data, 2);
end

% Define LPC order (10 as per your Verilog requirement)
order = 10;

% Compute autocorrelation
N = length(audio_data);
r = zeros(order+1, 1);
for k = 0:order
    r(k+1) = sum(audio_data(1:N-k) .* audio_data(k+1:N));
end

% Levinson-Durbin recursion (manual implementation)
a = zeros(order+1, 1);
e = r(1);
a(1) = 1;

for i = 1:order
    lambda = -sum(a(1:i) .* flip(r(2:i+1))) / e;
    a(2:i+1) = a(2:i+1) + lambda * flip(a(1:i));
    e = e * (1 - lambda^2);
end

% Extract final LPC coefficients
lpc_coeffs = a(2:end); 

% Scale coefficients for Verilog compatibility (scaling factor = 2^4)
lpc_coeffs_scaled = round(lpc_coeffs * (2^4));

% Display the LPC coefficients
disp('LPC Coefficients (Scaled for Verilog):');
disp(lpc_coeffs_scaled');

