% This file is not used for anything within the project. It was developed
% as a test in order to determine the orientation of an accelerometer based
% off of gravity. 

% Jonathan Zerez
% 6/25/19
close all


X = flip(X);
Y = flip(Y);
Z = flip(Z);
accel = [X;Y;Z];

global_accel = zeros(size(accel));

yaw_rot = @(d) [cosd(d), -sind(d), 0;...
                sind(d),  cosd(d), 0;...
                0,       0,       1];
pitch_rot = @(d) [cosd(d), 0, sind(d);...
                  0,       1,        0;...
                  -sind(d), 0,  cosd(d)];
for i = 1:length(accel)
    
    yaw_deg = acosd(dot(unit([X(i); Y(i); 0]), [0;1;0]));
    pitch_deg = acosd(dot(unit([X(i); 0; Z(i)]), [1;0;0]));

    global_accel(:, i) = pitch_rot(pitch_deg) * (accel(:, i));
    global_accel(:, i) = yaw_rot(yaw_deg) * global_accel(:, i);
    
end
subplot(2,2,1)

plot(t, X);
hold on
plot(t, Y);
plot(t, Z);
title('local')
legend('x', 'y', 'z')

subplot(2,2,2);
hold on
plot(t, global_accel(1, :));
plot(t, global_accel(2, :));
plot(t, global_accel(3, :));
title('global')
legend('x', 'y', 'z')


Fs = 100;
L = length(t);
f = (-L/2:L/2-1)*(Fs/L);
f= f([round(length(f)/2): length(f)]);

xfreq = fftshift(abs(fft(accel(1, :))));
yfreq = fftshift(abs(fft(accel(2, :))));
zfreq = fftshift(abs(fft(accel(3, :))));

xfreq = xfreq([round(length(xfreq)/2):length(xfreq)]);
yfreq = yfreq([round(length(yfreq)/2):length(yfreq)]);
zfreq = zfreq([round(length(zfreq)/2):length(zfreq)]);

subplot(2,2,3)
semilogy(f, xfreq);
hold on
plot(f, yfreq);
plot(f, zfreq);
title('global FFT')
legend('x', 'y', 'z')

subplot(2,2,4)
loglog(f, xfreq.^2);
hold on
semilogy(f, yfreq.^2);
semilogy(f, zfreq.^2);
title('Global Power Spectrum Density (fft^2)')
legend('x', 'y', 'z')

figure
hold off
RMS = sqrt(xfreq.^2 + yfreq.^2 + zfreq.^2);
RCI = fliplr(sqrt(-cumtrapz(fliplr(f), fliplr(RMS))));
loglog(f, RCI)
title('Reverse Integral (fft^2)');

figure
subplot(2, 1, 1)
for i=1:3
    [accPSD(:,i),w]=pwelch(detrend(global_accel(i,:)),L,[],L,Fs);
end
loglog(w, accPSD(:, 1))
hold on
loglog(w, accPSD(:, 2))
loglog(w, accPSD(:, 3))
RMS = sqrt(accPSD(:, 1).^2 + accPSD(:, 2).^2 + accPSD(:, 3).^2);
loglog(w, RMS);
title('PSD (pwelch)')

subplot(2, 1, 2)
RCI = flipud(sqrt(-cumtrapz(fliplr(f), flipud(RMS))));
loglog(f, RCI)
title('RCI (pwelch)') 

function res = unit(vec)
    res = vec / norm(vec);
end

function P1 = calc_fft(vec, L)
    Y = fft(vec);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
end

function res = flip(data)
    if size(data, 1) > 1
        res = data';
    else
        res = data;
    end
    
end