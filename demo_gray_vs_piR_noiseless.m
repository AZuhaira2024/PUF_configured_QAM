function demo_gray_vs_piR_noiseless(M, R_bin, style, showArrows)
% demo_gray_vs_piR_noiseless(M, R_bin, style, showArrows)
%   M          : 16, 64, 256 (square QAM)
%   R_bin      : char string of bits, e.g., '101100...'
%   style      : '0000_at_-3-1i'  or  'standard'   (axis labeling convention)
%   showArrows : true/false to draw arrows from Gray -> π_R
%
% Example:
%   demo_gray_vs_piR_noiseless(16, '10011011100101100101010101010101', '0000_at_-3-1i', true)

if nargin < 3, style = 'standard'; end
if nargin < 4, showArrows = true; end

assert(ismember(M,[16 64 256]), 'Use M in {16,64,256}.');
k = log2(M);

% --- 1) Build Gray-coded constellation (choose your axis convention) ---
[QAM_gray, Labels_gray] = build_gray_qam_style(M, style);

% --- 2) Build point permutation from R (labels unchanged) ---
seed = seed_from_bits(R_bin(:)');
rng(double(seed),'twister');
perm_idx = randperm(M);
QAM_perm = QAM_gray(perm_idx);      % shuffle POINTS
Labels_perm = Labels_gray;          % keep Gray labels as-is

% --- 3) Plot side-by-side ---
figure('Color','w','Position',[80 80 1100 430]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');

% Left: Standard Gray-coded constellation
nexttile;
scatter(real(QAM_gray), imag(QAM_gray), 110, 'o','LineWidth',1.2); hold on;
for i = 1:M
    text(real(QAM_gray(i))+0.18, imag(QAM_gray(i)), Labels_gray{i}, 'FontSize',9);
end
grid on; axis equal; xlabel('I'); ylabel('Q');
title(sprintf('Standard Gray %d-QAM', M), 'Interpreter','none');

% Right: After π_R (points permuted, labels unchanged)
nexttile;
scatter(real(QAM_perm), imag(QAM_perm), 110, 'o','LineWidth',1.2,'MarkerEdgeColor','r'); hold on;
for i = 1:M
    text(real(QAM_perm(i))+0.18, imag(QAM_perm(i)), Labels_perm{i}, 'FontSize',9);
end
if showArrows
    for i = 1:M
        plot([real(QAM_gray(i)) real(QAM_perm(i))], ...
             [imag(QAM_gray(i)) imag(QAM_perm(i))], ...
             'Color',[0.6 0.6 0.6], 'LineWidth',0.6);
    end
end
grid on; axis equal; xlabel('I'); ylabel('Q');
title('After \pi_R (point permutation), labels unchanged', 'Interpreter','tex');

% --- 4) Print a couple of example mappings ---
idx_0000 = find(strcmp(Labels_gray,'0000'),1);
if ~isempty(idx_0000)
    fprintf('Label 0000 moved: %+.0f%+0.0fi  ->  %+.0f%+0.0fi\n', ...
        real(QAM_gray(idx_0000)), imag(QAM_gray(idx_0000)), ...
        real(QAM_perm(idx_0000)), imag(QAM_perm(idx_0000)));
end
idx_1111 = find(strcmp(Labels_gray,'1111'),1);
if ~isempty(idx_1111)
    fprintf('Label 1111 moved: %+.0f%+0.0fi  ->  %+.0f%+0.0fi\n', ...
        real(QAM_gray(idx_1111)), imag(QAM_gray(idx_1111)), ...
        real(QAM_perm(idx_1111)), imag(QAM_perm(idx_1111)));
end
fprintf('k = %d bits/symbol, seed = %u\n', k, seed);

end

% ---------- helpers ----------
function [QAM, Labels] = build_gray_qam_style(M, style)
m = sqrt(M); assert(mod(m,1)==0,'square QAM only');
% Gray codes on axis
axis_codes = dec2bin(bitxor((0:m-1), floor((0:m-1)/2)), log2(m));

% Coordinate grids
I_vals = -(m-1):2:(m-1);     % left -> right
Q_vals_top2bot = (m-1):-2:-(m-1);  % top -> bottom
Q_vals_bot2top = fliplr(Q_vals_top2bot);

% Choose label placement convention
switch lower(style)
    case '0000_at_-3-1i'
        % I bits: left->right = Gray order
        % Q bits: bottom->top = Gray order  (so 0000 is at left, just below center)
        Q_scan = 'bottom2top';
    otherwise
        % "standard" here = top->bottom = Gray order
        Q_scan = 'top2bottom';
end

QAM = zeros(M,1); Labels = cell(M,1); idx=1;
switch Q_scan
    case 'top2bottom'
        for q=1:m
            for i=1:m
                I = I_vals(i); Q = Q_vals_top2bot(q);
                QAM(idx) = I + 1j*Q;
                Labels{idx} = [axis_codes(i,:) axis_codes(q,:)]; % [Ibits Qbits]
                idx = idx + 1;
            end
        end
    case 'bottom2top'
        for q=1:m
            for i=1:m
                I = I_vals(i); Q = Q_vals_bot2top(q);
                QAM(idx) = I + 1j*Q;
                Labels{idx} = [axis_codes(i,:) axis_codes(q,:)]; % [Ibits Qbits]
                idx = idx + 1;
            end
        end
end
end

function seed = seed_from_bits(bits_char)
% Fold an arbitrary-length bitstring into a uint32 seed
b = bits_char - '0';
acc = uint32(0);
for i=1:numel(b)
    acc = uint32(mod(double(acc)*2 + b(i), 2^32));
end
seed = double(acc);
end
