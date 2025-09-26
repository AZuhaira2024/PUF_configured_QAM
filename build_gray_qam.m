function [QAM_gray, BitLabels_gray] = build_gray_qam(M)
% Build square Gray-coded QAM constellation (points + bit labels)
m = sqrt(M);  assert(mod(m,1)==0,'Non-square QAM not supported');

% Gray codes for axis
grayCode = @(n) bitxor((0:(n-1)), floor((0:(n-1))/2));
axis_labels = arrayfun(@(x) dec2bin(x, log2(m)), grayCode(m), 'UniformOutput', false);

QAM_gray       = zeros(M,1);
BitLabels_gray = cell(M,1);
idx = 1;
for q = 1:m
    for i = 1:m
        I = -(m-1) + 2*(i-1);
        Q =  (m-1) - 2*(q-1);
        QAM_gray(idx)       = I + 1j*Q;
        BitLabels_gray{idx} = [axis_labels{i} axis_labels{q}];
        idx = idx + 1;
    end
end
end
