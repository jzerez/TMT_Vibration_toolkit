load('2014-05-15 111309_ALL_DATA.mat')

% Perform PSD on the .txt accel information
Fs = 1/cum_dt;
L = length(cum_volts);
f = (0:L/2)*(Fs/L);
mags = fftshift(abs(fft(cum_volts(2, round(length(cum_volts)/2):end))));
mags = mags.^2;
clf;

loglog(PSD(1, :), PSD(2, :))
hold on
[x, ff] = pwelch(cum_volts(2, :), rectwin(2000), [], length(cum_volts), Fs);
loglog(ff, x*1000)
figure
loglog(

legend('PSD from ASD', 'PSD from txt')