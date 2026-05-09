function s = e_metacontentext(a,tag)
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