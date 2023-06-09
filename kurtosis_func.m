% This files calcualtes the kurtosis of a window. n is the number of samples in a window and x is the data.
function kurtosis = kurtosis_func(n, x) % Calculates Kurtosis
    num_sum = sum((x-mean(x)).^4);
    den_sum = sum((x - mean(x)).^2);
    kurtosis_num = (1/n) * num_sum;
    kurtosis_den = ((1/n)*den_sum)^2;
    kurtosis = (kurtosis_num / kurtosis_den) - 3;
    return
end
