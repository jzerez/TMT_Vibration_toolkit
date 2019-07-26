close all
[y, Fs] = audioread('Windows Background.wav');

y = mean(y, 2);

L = length(y);
f = (-L/2:L/2-1)*(Fs/L);


xfreq = fftshift(abs(fft(y)/L))*2*pi;

figure
semilogy(f((L/2):end), xfreq((L/2):end))