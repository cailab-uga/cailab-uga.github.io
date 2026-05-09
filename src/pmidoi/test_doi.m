% Example usage:
doi = '10.1002/0471142301';
doi='10.1093/bib/bbad342';
%doi='10.1038/s41534-023-00740-6';
%doiToCitation(doi);


%function doiToCitation(doi)
    % Construct the DOI URL
    doiURL = ['https://doi.org/', doi];
    
%    try
        % Send an HTTP GET request to the DOI URL
        response = webread(doiURL);
        
        % Extract citation information from the response
        titleStart = strfind(response, '<title>');
        titleEnd = strfind(response, '</title>');
        
        if ~isempty(titleStart) && ~isempty(titleEnd)
            title = response(titleStart(1) + 7:titleEnd(1) - 1);
        else
            title = 'Unknown Title';
        end
        
        authorStart = strfind(response, '<meta name="citation_author" content="');
        authorEnd = strfind(response, '">');
        
        if ~isempty(authorStart) && ~isempty(authorEnd)
            author = response(authorStart(1) + 34:authorEnd(1) - 1);
        else
            author = 'Unknown Author';
        end
        
        yearStart = strfind(response, '<meta name="citation_year" content="');
        yearEnd = strfind(response, '">');
        
        if ~isempty(yearStart) && ~isempty(yearEnd)
            year = response(yearStart(1) + 32:yearEnd(1) - 1);
        else
            year = 'Unknown Year';
        end
        
        % Create the citation
        citation = sprintf('%s (%s). %s. DOI: %s', author, year, title, doi);
        disp('APA Citation:');
        disp(citation);
        
 %   catch ME
 %       fprintf('Error: %s\n', ME.message);
 %   end
%end


