%% Define characteristics of input bin wave

% Ramping style 
% How do we progress from different frequencies? 'lin', 'exp', or 'none'
ramp_style = 'none';

% Frequency Range (Hz)
min_f = 440;
max_f = 1600;


% Number of frequency bins (#)
num_f = 2;

% Total time (s)
t = 10;

% Ramp time. 
% How much time do we spend ramping between frequencies?
ramp_time = 10;

% framerate (#/s)
f_rate = 44100;
%% Create signal
all_fs = linspace(min_f, max_f, num_f);
if strcmp(ramp_style, 'none')
    f_time = t / num_f;
else
    f_time = (t - ((num_f - 1) * ramp_time)) / num_f;
end
num_f_samples = round(f_time * f_rate);
f_cum = (ones([num_f_samples, 1]) * all_fs)';

num_ramp_samples = round(ramp_time * f_rate);
ramp_cum = (ones([num_ramp_samples, 1]) * ones([1, num_f - 1]))';

if strcmp(ramp_style, 'none')
    f_func = reshape(f_cum', [1, numel(f_cum)]);
else
    if strcmp(ramp_style, 'lin')
        for r = 1:(num_f - 1)
            ramp_cum(r, :) = linspace(all_fs(r), all_fs(r+1), num_ramp_samples);
        end
    elseif strcmp(ramp_style, 'exp')
        for r = 1:(num_f - 1)
            ramp_cum(r, :) = logspace(log10(all_fs(r)), log10(all_fs(r+1)), num_ramp_samples);
        end
    else
        error(message('invalid ramp type. Must be lin, exp, or none'));
    end
    f_func = zeros([1, numel(ramp_cum) + numel(f_cum)]);
    f_func(1:num_f_samples) = f_cum(1, :);
    f_cum = f_cum(2:end, :);
    for i = 1:(num_f - 1)
        ind = find(f_func == 0);
        start = ind(1);
        r_end = ind(1)+num_ramp_samples-1;
        
        f_func(start:r_end) = ramp_cum(i, :);
        f_func(r_end+1:r_end+num_f_samples) = f_cum(i, :);
    end
end
close all
figure
plot(f_func)
figure
dphi = f_func * 2 * pi / f_rate;
signal = cumtrapz(dphi);
plot(sin(signal))
figure
spectrogram(sin(signal), 'yaxis')
