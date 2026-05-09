% Example usage:
doi = '10.1002/0471142301';
doi = '10.1093/bib/bbad342';
doi = '10.1038/s41534-023-00740-6';
doi = '10.1093/biomet/asad052'

%doiToCitation(doi);


%function doiToCitation(doi)
    % Construct the DOI URL
    doiURL = ['https://doi.org/', doi];
    
%    try
        % Send an HTTP GET request to the DOI URL
        response = webread(doiURL);

        c=extractHTMLText(response);

        a=strtrim(strsplit(response,{'\n','/>'}))';
        a(strlength(a)==0)=[];   
        
        a{contains(a,'<meta name="citation_author" content="')}
        a{contains(a,'<meta name="citation_journal_title" content="')}
        a{contains(a,'<meta name="citation_journal_abbrev" content="')}
        a{contains(a,'<meta name="citation_title" content="')}
        a{contains(a,'<meta name="citation_volume" content="')}
        a{contains(a,'<meta name="citation_issue" content="')}
        a{contains(a,'<meta name="citation_publication_date" content="')}        

        a{contains(a,'<meta name="citation_year" content="')}
        a{contains(a,'<meta name="citation_online_date" content="')}
        % a{contains(a,'<title>')}

        %idx=find(strcmp(a,'<div class="oxford-citation-text">'));
        %b=a{idx+1};
        %disp(b);
        
%    catch ME
%        fprintf('Error: %s\n', ME.message);
%    end
% end


