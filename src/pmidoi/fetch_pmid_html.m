function [s] = fetch_pmid_html(pmid, ishighlighted)
% FETCH_PMID_HTML  Build an <li> publication entry from a PubMed record.
%
% Uses NCBI E-utilities (efetch) rather than scraping
% https://pubmed.ncbi.nlm.nih.gov/<pmid>/?format=pubmed -- that page now
% requires cookies/JS and returns a "Cookies must be enabled" stub, which
% used to surface as a cryptic "Array indices must be positive integers"
% error from the downstream parsing.

    if nargin < 2, ishighlighted = false; end

    if isnumeric(pmid)
        pmid = string(pmid);
    elseif ischar(pmid) || isstring(pmid)
        pmid = string(pmid);
    else
        error('fetch_pmid_html:badInput', 'PMID data type is unsupported.');
    end
    pmid = strtrim(pmid);

    options = weboptions('Timeout', 50, 'ContentType', 'text');
    raw = webread('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi', ...
        'db', 'pubmed', 'id', pmid, 'retmode', 'text', 'rettype', 'medline', ...
        'tool', 'cailab-uga-site', 'email', 'jcai@uga.edu', options);
    raw = string(raw);

    if strlength(strtrim(raw)) == 0 || contains(raw, "<ERROR>")
        error('fetch_pmid_html:noRecord', ...
            'No PubMed record returned for PMID %s.', pmid);
    end

    [tags, vals] = parseMedlineRecord(raw);

    s_pmid = medlineField(tags, vals, "PMID");
    s_au   = medlineField(tags, vals, "AU");
    s_ti   = medlineField(tags, vals, "TI");
    s_so   = medlineField(tags, vals, "SO");

    if isempty(s_ti) || isempty(s_so) || isempty(s_pmid)
        error('fetch_pmid_html:unparsable', ...
            'PubMed response for PMID %s has no TI/SO/PMID field.', pmid);
    end

    s_pmid = s_pmid(1);
    s_ti   = strtrim(s_ti(1));
    s_so   = strtrim(s_so(1));

    % Journal / issue-date halves of the SO line.
    s_j = strtrim(extractBefore(s_so, '.'));
    rest = extractAfter(s_so, '.');
    if contains(rest, ' doi:')
        s_t = strtrim(extractBefore(rest, ' doi:'));
    elseif contains(rest, '.')
        s_t = strtrim(extractBefore(rest, '.'));
    else
        s_t = strtrim(rest);
    end
    s_t = regexprep(s_t, '\.$', '');

    % DOI lives on an LID/AID line tagged "[doi]".
    s_doi = vals(contains(vals, "[doi]"));
    if ~isempty(s_doi)
        s_doi = strtrim(erase(s_doi(1), "[doi]"));
    end

    if ishighlighted
        s = "<li class=""highlighted"">";
    else
        s = "<li>";
    end

    if isempty(s_au)
        s = sprintf("%s\n", s);
    elseif numel(s_au) == 1
        s = sprintf("%s%s.\n", s, s_au);
    else
        sx = sprintf("%s, ", s_au(1:end-1));
        sx = sprintf("%s%s", sx, s_au(end));
        s = sprintf("%s%s.\n", s, sx);
    end

    s = sprintf("%s<strong>%s</strong>\n", s, s_ti);
    s = sprintf("%s<em><u>%s</u></em>.\n", s, s_j);
    s = sprintf("%s%s.\n", s, s_t);

    if ~isempty(s_doi)
        s = sprintf("%sdoi: <a href=""https://doi.org/%s"">%s</a>.\n", s, s_doi, s_doi);
    end

    s = sprintf("%sPMID: <a href=""https://pubmed.ncbi.nlm.nih.gov/%s"">%s</a>.", s, s_pmid, s_pmid);

    if ~isempty(s_doi)
        s = sprintf("%s<span class=""__dimensions_badge_embed__"" data-doi=""%s"" data-style=""small_rectangle""></span>", s, s_doi);
    end
    s = sprintf("%s</li>\n", s);
end


function [tags, vals] = parseMedlineRecord(raw)
% Split MEDLINE-tagged text into parallel tag/value arrays, unfolding the
% indented continuation lines that wrap long fields.
    lines = erase(splitlines(raw), char(13));
    tags = strings(0, 1);
    vals = strings(0, 1);
    for i = 1:numel(lines)
        ln = lines(i);
        if strlength(strtrim(ln)) == 0, continue; end
        tok = regexp(ln, '^([A-Z]{2,4})\s*-\s(.*)$', 'tokens', 'once');
        if ~isempty(tok)
            tags(end+1, 1) = string(tok{1}); %#ok<AGROW>
            vals(end+1, 1) = strtrim(string(tok{2})); %#ok<AGROW>
        elseif ~isempty(tags)
            vals(end) = strtrim(vals(end)) + " " + strtrim(ln);
        end
    end
end


function v = medlineField(tags, vals, tag)
    v = vals(tags == tag);
end
