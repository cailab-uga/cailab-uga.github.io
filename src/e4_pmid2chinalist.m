addpath('pmidoi\');
e0_pmidoilist;

fname = 'paperlist_with_china.html';
writelines("<ol>", fname);

S_AU=[];

d = dictionary;
d2 = dictionary;

for k=1:49 %length(AAv)   %Year 2020-Present
    pause(1)
    AAv(k)
    try
    if contains(AAv(k),'/')
        a=webread(sprintf('https://doi.org/%s',AAv(k)));
        a=strtrim(strsplit(a,{'\n','/>'}))';
        a(strlength(a)==0)=[];
        s_au=aaa(a,'citation_author');
        S_AU=[S_AU; s_au];
    else    
        a = webread(sprintf('https://pubmed.ncbi.nlm.nih.gov/%s/?format=pubmed',AAv(k)));
        b = extractHTMLText(a);
        c = string(strsplit(b,'\n')');

        [d, yes] = aaa_parse_au2(c, d);
        d2 = add_date(c, d2);

        s_au=c(startsWith(c,'FAU '));
        % s_au = c(startsWith(c,'AU '));
        s_au = strtrim(extractAfter(s_au, 6));
        S_AU = [S_AU; s_au];

        if yes
            if contains(AAv(k),'/')
                s1=i_doi2html(AAv(k), false);
            else
                s1=i_pmid2html(AAv(k), false);
            end 
            writelines(s1, fname, WriteMode="append");
        end
    end

    catch ME
        disp(ME.message);
    end
end

writelines("</ol>", fname, WriteMode="append");


function s=aaa(a,tag)
    s='';
    tag=sprintf('<meta name="%s" content="',tag);
    idx=find(contains(a,tag));
    if isempty(idx), return; end
    %length(idx)
    s=strings(length(idx),1);
    for k=1:length(idx)
        b=a{idx(k)};
        b=b(strfind(b, tag)+strlength(tag):end);
        b=b(1:strfind(b,'"')-1);
        s(k)=b;  
    end
end