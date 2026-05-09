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
        
        % Check for author line (FAU -)
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
            current_author_affiliations{end+1} = affiliation;
        end
        
        % i = i + 1;
    end
    
    % Don't forget the last author's affiliations
    if ~isempty(current_author_affiliations)
        affiliations{author_count} = current_author_affiliations;
    end
    
    % Display results
    fprintf('\n=== EXTRACTED AUTHORS AND AFFILIATIONS ===\n\n');
    
    for i = 1:length(authors)
        fprintf('Author %d: %s\n', i, authors{i});
        if i <= length(affiliations) && ~isempty(affiliations{i})
            fprintf('Affiliations:\n');
            for j = 1:length(affiliations{i})
                fprintf('  - %s\n', affiliations{i}{j});
            end
        else
            fprintf('  (No affiliations found)\n');
        end
        fprintf('\n');
    end
    
    fprintf('Total authors found: %d\n\n', length(authors));

