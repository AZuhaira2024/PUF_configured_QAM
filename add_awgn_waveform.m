function y = add_awgn_waveform(x, SNR_dB)
% Add real AWGN to time-domain waveform (for plotting only)
    Px = mean(x.^2);
    SNR = 10^(SNR_dB/10);
    sigma2 = Px / SNR;
    y = x + sqrt(sigma2)*randn(size(x));
end