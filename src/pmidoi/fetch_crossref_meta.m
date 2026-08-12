function a = fetch_crossref_meta(s_doi)
% FETCH_CROSSREF_META  Fetch DOI metadata from the Crossref REST API and return
% it as <meta name="citation_*" content="..."> lines, so the result can be
% consumed by get_meta_content exactly like scraped publisher HTML.
%
% Used as a fallback in fetch_doi_html when the publisher page blocks webread
% (e.g. pubs.aip.org returns HTTP 403 to non-browser clients).

    options = weboptions( ...
        'UserAgent','cailab-uga.github.io (mailto:jcai@tamu.edu)', ...
        'ContentType','text', ...
        'Timeout',30);

    raw = webread(sprintf('https://api.crossref.org/works/%s', s_doi), options);
    m = getfield(jsondecode(raw), 'message');

    a = {};

    % --- authors: emit as "Family, Given" to match publisher meta tags ---
    if isfield(m,'author')
        au = m.author;
        for k = 1:numel(au)
            if iscell(au), p = au{k}; else, p = au(k); end
            if isfield(p,'family') && ~isempty(p.family)
                nm = string(p.family);
                if isfield(p,'given') && ~isempty(p.given)
                    nm = nm + ", " + string(p.given);
                end
            elseif isfield(p,'name')          % consortium / group author
                nm = string(p.name);
            else
                continue
            end
            a{end+1,1} = in_meta('citation_author', nm); %#ok<AGROW>
        end
    end

    a = [a; in_field(m, 'title', 'citation_title')];

    % Preprints (type "posted-content") carry no container-title; the server
    % name lives in institution/group-title instead (bioRxiv, medRxiv, ...).
    j = in_field(m, 'container_title', 'citation_journal_title');
    if isempty(j) && isfield(m,'institution') && ~isempty(m.institution)
        inst = m.institution;
        if iscell(inst), inst = inst{1}; end
        if isstruct(inst) && isfield(inst,'name')
            j = {in_meta('citation_journal_title', string(inst(1).name))};
        end
    end
    if isempty(j)
        j = in_field(m, 'group_title', 'citation_journal_title');
    end
    a = [a; j];

    a = [a; in_field(m, 'short_container_title', 'citation_journal_abbrev')];
    a = [a; in_field(m, 'volume',                'citation_volume')];
    a = [a; in_field(m, 'issue',                 'citation_issue')];

    % --- pages: "551-572", or an article number for article-based journals ---
    if isfield(m,'page') && ~isempty(m.page)
        pg = strsplit(string(m.page), '-');
        a{end+1,1} = in_meta('citation_firstpage', pg(1));
        if numel(pg) > 1
            a{end+1,1} = in_meta('citation_lastpage', pg(end));
        end
    elseif isfield(m,'article_number') && ~isempty(m.article_number)
        a{end+1,1} = in_meta('citation_firstpage', string(m.article_number));
    end

    % --- date: earliest known, formatted YYYY/MM/DD like the meta tags ---
    d = in_dateparts(m);
    if ~isempty(d)
        a{end+1,1} = in_meta('citation_publication_date', d);
    end
end


function s = in_meta(tag, val)
    val = strtrim(string(val));
    val = strrep(val, '"', '''');       % get_meta_content splits on the quote
    s = char(sprintf('<meta name="%s" content="%s">', tag, val));
end


function c = in_field(m, fld, tag)
    c = {};
    if ~isfield(m, fld) || isempty(m.(fld)), return; end
    v = m.(fld);
    if iscell(v), v = v{1}; end
    v = string(v);
    if strlength(strtrim(v(1))) == 0, return; end
    c = {in_meta(tag, v(1))};
end


function s = in_dateparts(m)
    s = "";
    for fld = ["published","issued","published_online","published_print","created"]
        if ~isfield(m, fld) || ~isfield(m.(fld), 'date_parts'), continue; end
        dp = m.(fld).date_parts;
        if iscell(dp), dp = dp{1}; end
        dp = dp(:)';
        dp(isnan(dp)) = [];
        if isempty(dp), continue; end
        s = strjoin(compose("%02d", dp), "/");
        s = regexprep(s, '^0+', '');    % year must not be zero-padded
        return
    end
end
