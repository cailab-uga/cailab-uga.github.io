function [d] = add_date(c, d)

        s_au=c(startsWith(c,'FAU '));
        % s_au = c(startsWith(c,'AU '));
        s_au = strtrim(extractAfter(s_au, 6));
da=convert_date_string((extractAfter(c(startsWith(c,'DP  -')),6)));

        for k=1:length(s_au)
            d(s_au(k)) = da;
        end
end