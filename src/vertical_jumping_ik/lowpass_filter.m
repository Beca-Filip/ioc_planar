function x_filt = lowpass_filter(x_brut, f_ech, f_cutoff, order)

% LOW FILTER BUTTERWORTH

% x_brut = signal brut
% f_ech = fr?quence d'?chantillonage du signal en Hz
% f_cutoff = fr?quence de coupure du signal en Hz
% order = ordre du filtre
[lin col]=size(x_brut);

x_filt=nan(lin,col);

if lin<col
    
    for i=1:lin
        [B_filt, A_filt] = butter(order, (2 .* f_cutoff ./ f_ech), 'low');
        x_filt(i,:) = filtfilt(B_filt, A_filt, x_brut(i,:));
    end
else
    for i=1:col
        [B_filt, A_filt] = butter(order, (2 .* f_cutoff ./ f_ech), 'low');
        x_filt(:,i) = filtfilt(B_filt, A_filt, x_brut(:,i));
    end
end
return