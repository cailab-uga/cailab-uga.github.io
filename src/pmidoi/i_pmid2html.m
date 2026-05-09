function [s]=i_pmid2html(pmid,ishighlighted)

if nargin<2, ishighlighted=false; end
    options = weboptions('Timeout', 50);

    if ischar(pmid) || isstring(pmid)
        a=webread(sprintf('https://pubmed.ncbi.nlm.nih.gov/%s/?format=pubmed',pmid), options);
    elseif isnumeric(pmid)
        a=webread(sprintf('https://pubmed.ncbi.nlm.nih.gov/%d/?format=pubmed',pmid), options);
    else
        error('PMID data type is unsupported.');
    end
    b=extractHTMLText(a);
    % c=strtrim(string(strsplit(b,'\n')'));
    c=string(strsplit(b,'\n')');
    s_pmid=c(startsWith(c,'PMID'));
    
    s_so=c(startsWith(c,'SO'));
    if find(startsWith(c,'SO'))<length(c)
        %fprintf('--->%d\n',AAv(k));
        s_so=strcat(s_so, " ", c(end));
    end

    s_au=c(startsWith(c,'AU '));
    s_ti=c(startsWith(c,'TI'));

    if strcmp(extractBefore(c(find(startsWith(c,'TI'))+1),2)," ")
        s_ti=strcat(s_ti,strtrim(c(find(startsWith(c,'TI'))+1)));
    end

    if strcmp(extractBefore(c(find(startsWith(c,'TI'))+2),2)," ")
        s_ti=strcat(s_ti," ",strtrim(c(find(startsWith(c,'TI'))+2)));
    end
    s_ti = strrep(s_ti, "  "," ");
    
    s_ti=strtrim(extractAfter(s_ti,5));
    s_pmid=strtrim(extractAfter(s_pmid,6));
    s_so=strtrim(extractAfter(s_so,6));
    s_au=strtrim(extractAfter(s_au,6));
    s_j=extractBefore(s_so,'.');
    s_t = strtrim(extractBefore(extractAfter(s_so,'.'),'.'));
    

    
%     s_d = extractAfter(s_so,'doi: ');
%     s_d=extractBefore(s_d,strlength(s_d));
    
    s_doi=c(contains(c,"[doi]"));
    if ~isempty(s_doi)
        s_doi=strtrim(extractAfter(s_doi,6));
        s_doi=strrep(s_doi," [doi]","");
    end


    if ishighlighted
        s="<li class=""highlighted"">";
    else
        s="<li>";
    end    

    if length(s_au)==1
        s=sprintf("%s%s.\n",s,s_au);
    else
        sx=sprintf("%s, ",s_au(1:end-1));
        sx=sprintf("%s%s",sx,s_au(end));
        s=sprintf("%s%s.\n",s,sx);
    end

    s=sprintf("%s<strong>%s</strong>\n",s,s_ti);
    s=sprintf("%s<em><u>%s</u></em>.\n",s,s_j);
    s=sprintf("%s%s.\n",s,s_t);

    if ~isempty(s_doi)
        s=sprintf("%sdoi: <a href=""https://doi.org/%s"">%s</a>.\n",s,s_doi(1),s_doi(1));
    end

    %fprintf(fid,"PMID: <a href=""https://pubmed.ncbi.nlm.nih.gov/%s"">%s</a>.</li>\n",s_pmid,s_pmid);

    
    s=sprintf("%sPMID: <a href=""https://pubmed.ncbi.nlm.nih.gov/%s"">%s</a>.",s,s_pmid,s_pmid);
    
    if ~isempty(s_doi)        
        s=sprintf("%s<span class=""__dimensions_badge_embed__"" data-doi=""%s"" data-style=""small_rectangle""></span>",s,s_doi(1));
    else
        s=sprintf("%s",s);
    end
    s=sprintf("%s</li>\n",s);
end
