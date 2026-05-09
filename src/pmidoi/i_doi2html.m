function [s]=i_doi2html(s_doi,ishighlighted)

if nargin<2, ishighlighted=false; end

options = weboptions('Timeout', 50);
options = weboptions( ...
    'UserAgent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36', ...
    'Timeout',30);

     a=webread(sprintf('https://doi.org/%s',s_doi), options);
     a=strtrim(strsplit(a,{'\n','/>'}))';
     a(strlength(a)==0)=[];
     a=a(contains(a, "<meta "));
        % a{contains(a,'<meta name="citation_author" content="')}
        % a{contains(a,'<meta name="citation_journal_title" content="')}
        % a{contains(a,'<meta name="citation_journal_abbrev" content="')}
        % a{contains(a,'<meta name="citation_title" content="')}
        % a{contains(a,'<meta name="citation_volume" content="')}
        % a{contains(a,'<meta name="citation_issue" content="')}
        % a{contains(a,'<meta name="citation_publication_date" content="')}        

    
    if ishighlighted
        s="<li class=""highlighted"">";
    else
        s="<li>";
    end    
    
    s_au = e_metacontentext(a,'citation_author');
    [s_au] = e_authornamemod(s_au);
    %s_au
    if length(s_au)==1
        s=sprintf("%s%s.\n",s,s_au);
    else
        sx=sprintf("%s, ",s_au(1:end-1));
        sx=sprintf("%s%s",sx,s_au(end));
        s=sprintf("%s%s.\n",s,sx);        
    end

    s_ti=e_metacontentext(a,'citation_title');

    s_j=e_metacontentext(a,'citation_journal_abbrev');
    s_j=strrep(s_j,'.','');
    if isempty(s_j)
       s_j=e_metacontentext(a,'citation_journal_title');
       if isempty(s_j)
           s_j=e_metacontentext(a,'citation_arxiv_id');
           if ~isempty(s_j)
               s_j = "arXiv";
           end
       end
    end


    s_t=e_metacontentext(a,'citation_publication_date');
    if isempty(s_t)
        s_t=e_metacontentext(a,'citation_online_date');
        if isempty(s_t)
            s_t=e_metacontentext(a,'citation_date');
        end
    end

    s_v=e_metacontentext(a,'citation_volume');
    s_i=e_metacontentext(a,'citation_issue');
    if isempty(s_i)
        s_i=e_metacontentext(a,'citation_arxiv_id');
    end
    s_p1=e_metacontentext(a,'citation_firstpage');
    s_p2=e_metacontentext(a,'citation_lastpage');
    

    s=sprintf("%s<strong>%s.</strong>\n",s,s_ti);

    %s_j
    if ismember(s_j, ["arXiv","bioRxiv"])
        s_j = s_j+" "+"[Preprint]";
    end

    s=sprintf("%s<em><u>%s</u></em>.\n",s,s_j);
    if ~isempty(s_p1)
        if ~isempty(s_i)
            s=sprintf("%s%s;%s(%s)%s-%s.\n",s,s_t,s_v,s_i,s_p1,s_p2);
        else
            s=sprintf("%s%s;%s %s-%s.\n",s,s_t,s_v,s_p1,s_p2);
        end
    else
        if ~isempty(s_i)
            s=sprintf("%s%s;%s(%s).\n",s,s_t,s_v,s_i);
        else
            s=sprintf("%s%s;%s.\n",s,s_t,s_v);
        end
    end
    
    s=sprintf("%sdoi:<a href=""https://doi.org/%s"">%s</a>.",s,s_doi,s_doi);
    %fprintf(fid,"PMID: <a href=""https://pubmed.ncbi.nlm.nih.gov/%s"">%s</a>.</li>\n",s_pmid,s_pmid);
    %s=sprintf("%sPMID: <a href=""https://pubmed.ncbi.nlm.nih.gov/%s"">%s</a>.</li>\n",s,s_pmid,s_pmid);        
    s=sprintf("%s<span class=""__dimensions_badge_embed__"" data-doi=""%s"" data-style=""small_rectangle""></span>",s,s_doi(1));
    s=sprintf("%s</li>\n",s);
end


% function s=e_metacontentext(a,tag)
%     s='';
%     tag=sprintf('<meta name="%s" content="',tag);
%     idx=find(contains(a,tag));
%     if isempty(idx), return; end
%     %length(idx)
%     s=strings(length(idx),1);
%     for k=1:length(idx)
%         b=a{idx(k)};
%         b=b(strfind(b, tag)+strlength(tag):end);
%         b=b(1:strfind(b,'"')-1);
%         s(k)=b;  
%     end
% end


%if ~any(contains(a,ta)
%a{contains(a,'<meta name="citation_journal_title" content="')}
%b(strfind(b, tag)+strlength(tag):end)
%end

