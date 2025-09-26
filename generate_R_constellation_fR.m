function constMap = generate_R_constellation_fR(R_bin, M)
    % Generate base square QAM (natural Gray order)
    m = sqrt(M);
    if mod(m,1) ~= 0
        error('M must be a perfect square (16, 64, 256, etc.)');
    end
    re = -(m-1):2:(m-1);
    [X,Y] = meshgrid(re, re);
    stdQAM = X(:) + 1i*Y(:);

    % Normalize average symbol energy
    stdQAM = stdQAM / rms(stdQAM);

    k = log2(M);

    % --- Derive (a,b) from PUF response ---
    Rnum = double(R_bin - '0');
    seed = sum(Rnum);
    a = 1 + mod(seed, M-1);
    while gcd(a,M) ~= 1
        a = mod(a+1, M);
    end
    b = mod(sum(Rnum(1:round(end/2))), M);

    % Permutation
    perm = mod((a*(0:M-1) + b), M) + 1;

    % Bit labels (binary count, left-msb)
    bitLabels = de2bi_custom(0:M-1, k, 'left-msb');

    % Apply same permutation to symbols and labels
    constMap.QAMSymbols = stdQAM(perm);
    constMap.BitLabels  = bitLabels(perm, :);

    % Store parameters
    constMap.k = k;
    constMap.M = M;
    constMap.a = a;
    constMap.b = b;
end

