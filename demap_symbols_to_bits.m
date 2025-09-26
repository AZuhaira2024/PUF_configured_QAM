function [bits, decided_syms] = demap_symbols_to_bits(rx_symbols, constMap)
    dists = abs(rx_symbols(:) - constMap.QAMSymbols(:).'); 
    [~, idx] = min(dists, [], 2);

    ainv = modinv(constMap.a, constMap.M);
    gray_idxs = mod(ainv * (idx-1 - constMap.b), constMap.M);

    bin_idxs = gray2bin(gray_idxs);  % <--- Convert Gray back to binary
    bits = de2bi_custom(bin_idxs, constMap.k, 'left-msb').';
    bits = bits(:);

    decided_syms = constMap.QAMSymbols(idx);
end
