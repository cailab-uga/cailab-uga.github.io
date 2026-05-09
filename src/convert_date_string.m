function formatted_date = convert_date_string(date_str)
    % Convert date strings from 'YYYY MMM' or 'YYYY MMM D' format to 'MM/D/YYYY'
    % Input: date_str - string in format '2023 Dec' or '2025 Jun 3'
    % Output: formatted_date - string in format 'MM/D/YYYY'
    
    if isempty(date_str)
        formatted_date = '';
        return;
    end
    
    % Define month abbreviations mapping
    month_map = containers.Map(...
        {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}, ...
        {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12});
    
    % Split the input string
    parts = strsplit(strtrim(date_str), ' ');
    
    if length(parts) < 2
        error('Invalid date format. Expected "YYYY MMM" or "YYYY MMM D"');
    end
    
    % Extract components
    year_str = parts{1};
    month_str = parts{2};
    
    % Check if day is provided
    if length(parts) >= 3
        day_str = parts{3};
        day = str2double(day_str);
    else
        day = 1; % Default to 1st day of month
    end
    
    % Convert year
    year = str2double(year_str);
    if isnan(year) || year < 1000 || year > 9999
        error('Invalid year: %s', year_str);
    end
    
    % Convert month
    if isKey(month_map, month_str)
        month = month_map(month_str);
    else
        error('Invalid month abbreviation: %s', month_str);
    end
    
    % Validate day
    if isnan(day) || day < 1 || day > 31
        error('Invalid day: %s', day_str);
    end
    
    % Format as MM/D/YYYY
    formatted_date = sprintf('%d/%d/%d', month, day, year);
end

% Test function with examples
function test_date_converter()
    fprintf('Testing date converter function:\n\n');
    
    % Test cases
    test_cases = {'2023 Dec', '2025 Jun 3', '2024 Jan', '2023 Feb 15', ...
                  '2025 Mar 31', '2022 Jul 4', '2024 Nov 25'};
    
    for i = 1:length(test_cases)
        try
            result = convert_date_string(test_cases{i});
            fprintf('Input: %-12s -> Output: %s\n', test_cases{i}, result);
        catch ME
            fprintf('Input: %-12s -> Error: %s\n', test_cases{i}, ME.message);
        end
    end
    
    fprintf('\n');
end

% Batch conversion function for cell arrays
function formatted_dates = convert_date_array(date_strings)
    % Convert an array of date strings
    % Input: date_strings - cell array of date strings
    % Output: formatted_dates - cell array of formatted dates
    
    formatted_dates = cell(size(date_strings));
    
    for i = 1:length(date_strings)
        try
            formatted_dates{i} = convert_date_string(date_strings{i});
        catch
            formatted_dates{i} = 'Invalid Date';
        end
    end
end

% Example usage:
% Run the test function to see examples
% test_date_converter();

% Single conversion examples:
% result1 = convert_date_string('2023 Dec');      % Returns '12/1/2023'
% result2 = convert_date_string('2025 Jun 3');    % Returns '6/3/2025'

% Batch conversion example:
% dates = {'2023 Dec', '2025 Jun 3', '2024 Mar 15'};
% converted = convert_date_array(dates);
