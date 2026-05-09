function [d, yes] = aaa_parse_au2(c, d)

    yes = false;
    lines = c;   
    % Initialize output arrays
    authors = {};
    affiliations = {};
    current_author_affiliations = {};
    author_count = 0;
    
    % i = 1;
    % while i <= length(lines)
    for i = 1:length(lines)        
        %line = lines{i};
        line = char(lines(i,:));
        
         if startsWith(strtrim(line), 'FAU -')
            % If we have collected affiliations for previous author, store them
            if ~isempty(current_author_affiliations)
                affiliations{author_count} = current_author_affiliations;
                current_author_affiliations = {};
            end
            
            % Extract author name (everything after 'FAU - ')
            author_name = strtrim(line(6:end)); % Remove 'FAU - ' prefix
            authors{end+1} = author_name;
            author_count = length(authors);
            
        % Check for affiliation line (AD -)
        elseif startsWith(strtrim(line), 'AD  -')
            % Extract affiliation (everything after 'AD  - ')
            affiliation = strtrim(line(7:end)); % Remove 'AD  - ' prefix
            
            % Check for continuation lines (lines that don't start with known prefixes)
            j = i + 1;
            while j <= length(lines)
                next_line = strtrim(lines{j});
                % Check if next line is a continuation (doesn't start with known prefixes)
                if ~isempty(next_line) && ...
                   ~startsWith(next_line, 'FAU -') && ...
                   ~startsWith(next_line, 'AU  -') && ...
                   ~startsWith(next_line, 'AD  -') && ...
                   ~startsWith(next_line, 'AUID-') && ...
                   ~startsWith(next_line, 'LA  -') && ...
                   ~startsWith(next_line, 'GR  -') && ...
                   ~startsWith(next_line, 'PT  -') && ...
                   ~contains(next_line, '- ') % General check for MEDLINE field format
                    
                    % This is a continuation line
                    affiliation = [affiliation ' ' next_line];
                    j = j + 1;
                else
                    % Not a continuation line, break
                    break;
                end
            end
            
            current_author_affiliations{end+1} = affiliation;
            i = j - 1; % Skip the processed continuation lines
        end
        
        i = i + 1;
    end
    
    % Don't forget the last author's affiliations
    if ~isempty(current_author_affiliations)
        affiliations{author_count} = current_author_affiliations;
    end
    
    % Display results
%    fprintf('\n=== EXTRACTED AUTHORS AND AFFILIATIONS ===\n\n');
    
    for i = 1:length(authors)

        if i <= length(affiliations) && ~isempty(affiliations{i})
            d(authors{i}) = affiliations{i}{1};
            if contains(affiliations{i}{1}, 'China')
                yes = true;
            end
        end

        %{
        % fprintf('Author %d: %s\t', i, authors{i});
        fprintf('%s\t', i, authors{i});
        if i <= length(affiliations) && ~isempty(affiliations{i})
            % fprintf('Affiliations:\n');
            for j = 1:1 % length(affiliations{i})
                % fprintf('  - %s\n', affiliations{i}{j});
                fprintf('%s\n', affiliations{i}{j});
            end
        else
            % fprintf('  (No affiliations found)\n');
            fprintf('\n');
        end
        % fprintf('\n');
        %}
    end    
    % fprintf('Total authors found: %d\n\n', length(authors));

