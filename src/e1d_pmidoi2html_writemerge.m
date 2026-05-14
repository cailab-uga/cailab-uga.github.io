scriptDir = fileparts(mfilename('fullpath'));
oldDir = pwd;
cd(scriptDir);

addpath(fullfile(scriptDir, 'pmidoi'));
e0_pmidoilist;

preprintHtml = in_loopthrough(AAv(ispreprint), Highlighted);
journalHtml = in_loopthrough(AAv(~ispreprint), Highlighted);

writeFragment('publications.html', preprintHtml, journalHtml);
writeFullPublicationsPage('../publications.html', preprintHtml, journalHtml);

y = ismember(AAv, Highlighted);
selectedHtml = in_loopthrough_simple(AAv(y), Highlighted);
writeSelectedFragment('../selected_publications.html', selectedHtml);
updateIndexPublicationsSection('../index.html', selectedHtml);
cd(oldDir);


function writeFragment(filename, preprintHtml, journalHtml)
    fid = fopen(filename, 'w');
    cleanupObj = onCleanup(@() fclose(fid));

    fprintf(fid, "<h3>Preprints</h3>\n<ol>");
    fprintf(fid, "\n%s\n", preprintHtml);
    fprintf(fid, "</ol>\n");

    fprintf(fid, "<h3>Journal Articles</h3>\n<ol>");
    fprintf(fid, "\n%s\n", journalHtml);
    fprintf(fid, "</ol>\n");
end


function writeSelectedFragment(filename, selectedHtml)
    fid = fopen(filename, 'w');
    cleanupObj = onCleanup(@() fclose(fid));

    fprintf(fid, "<h3>Selected Publications</h3>\n<ol>");
    fprintf(fid, "\n%s\n", selectedHtml);
    fprintf(fid, "</ol>\n");
end


function updateIndexPublicationsSection(filename, selectedHtml)
    if ~exist(filename, 'file')
        return
    end

    content = fileread(filename);
    section = buildIndexPublicationsSection(selectedHtml);
    startMarker = '    <!-- ======= Publications Section ======= -->';
    endMarker = '    </section><!-- End Publications Section -->';
    idxStart = strfind(content, startMarker);
    idxEnd = strfind(content, endMarker);

    if isempty(idxStart) || isempty(idxEnd)
        warning('Publications section marker not found in %s.', filename);
        return
    end

    idxStart = idxStart(1);
    idxEnd = idxEnd(find(idxEnd > idxStart, 1, 'first'));
    if isempty(idxEnd)
        warning('Publications section marker not found in %s.', filename);
        return
    end

    idxEnd = idxEnd + strlength(endMarker) - 1;
    newContent = string(content(1:idxStart-1)) + section + string(content(idxEnd+1:end));

    % Pub-list styles now live in assets/css/style.css — no inline injection needed.

    badgeScript = "  <script defer src=""https://badge.dimensions.ai/badge.js"" charset=""utf-8""></script>";
    if ~contains(newContent, 'badge.dimensions.ai/badge.js')
        newContent = replace(newContent, "  <!-- Vendor JS Files -->" + newline, ...
            "  <!-- Vendor JS Files -->" + newline + badgeScript + newline);
    end

    fid = fopen(filename, 'w');
    cleanupObj = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', newContent);
end


function section = buildIndexPublicationsSection(selectedHtml)
    section = [
"    <!-- ======= Publications Section ======= -->"
"    <section id=""publications"" class=""pricing"">"
"      <div class=""container"">"
""
"        <div class=""section-title"">"
"          <span>Publications</span>"
"          <h2>Publications</h2>"
"          <p>Highlighted papers and preprints. <a href=""publications.html"">View full list of publications &rarr;</a></p>"
"        </div>"
""
"        <ol class=""pub-list highlighted-publications"" style=""font-size:15px; line-height:1.65; padding-left:1.4rem;"">"
indentHtml(selectedHtml, 10)
"        </ol>"
""
"      </div>"
"    </section><!-- End Publications Section -->"
];
    section = join(section, newline);
end


function writeFullPublicationsPage(filename, preprintHtml, journalHtml)
    fid = fopen(filename, 'w');
    cleanupObj = onCleanup(@() fclose(fid));

    fprintf(fid, "%s", fullPageHeader());
    fprintf(fid, "        <!-- PREPRINTS -->\n");
    fprintf(fid, "        <div class=""pub-section"">\n");
    fprintf(fid, "          <h3>Preprints</h3>\n");
    fprintf(fid, "          <ol class=""pub-list"">\n");
    fprintf(fid, "%s\n", indentHtml(preprintHtml, 12));
    fprintf(fid, "          </ol>\n");
    fprintf(fid, "        </div>\n\n");

    fprintf(fid, "        <!-- JOURNAL ARTICLES -->\n");
    fprintf(fid, "        <div class=""pub-section"">\n");
    fprintf(fid, "          <h3>Journal Articles</h3>\n");
    fprintf(fid, "          <ol class=""pub-list"">\n");
    fprintf(fid, "%s\n", indentHtml(journalHtml, 12));
    fprintf(fid, "          </ol>\n");
    fprintf(fid, "        </div>\n");
    fprintf(fid, "%s", fullPageFooter());
end


function s = fullPageHeader()
    s = [
"<!DOCTYPE html>"
"<html lang=""en"">"
"<head>"
"  <meta charset=""utf-8"">"
"  <meta content=""width=device-width, initial-scale=1.0"" name=""viewport"">"
"  <title>Publications &mdash; Cai Lab</title>"
"  <meta content=""Full publication list of the Cai Lab at the University of Georgia"" name=""description"">"
"  <meta content=""publications, single cell, RNA-seq, quantum computing, bioinformatics, UGA"" name=""keywords"">"
"  <link href=""assets/img/favicon.png"" rel=""icon"">"
"  <link href=""assets/img/apple-touch-icon.png"" rel=""apple-touch-icon"">"
"  <!-- Google Fonts -->"
"  <link rel=""preconnect"" href=""https://fonts.googleapis.com"">"
"  <link rel=""preconnect"" href=""https://fonts.gstatic.com"" crossorigin>"
"  <link href=""https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300;0,400;0,600;0,700;1,300;1,400;1,600;1,700&family=Raleway:wght@300;400;500;600;700&family=Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,500;1,600;1,700&display=swap"" rel=""stylesheet"">"
"  <link href=""assets/vendor/aos/aos.css"" rel=""stylesheet"">"
"  <link href=""assets/vendor/bootstrap/css/bootstrap.min.css"" rel=""stylesheet"">"
"  <link href=""https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"" rel=""stylesheet"">"
"  <link href=""assets/vendor/boxicons/css/boxicons.min.css"" rel=""stylesheet"">"
"  <link href=""assets/vendor/glightbox/css/glightbox.min.css"" rel=""stylesheet"">"
"  <link href=""assets/vendor/swiper/swiper-bundle.min.css"" rel=""stylesheet"">"
"  <link href=""assets/css/style.css"" rel=""stylesheet"">"
"  <!-- Pub-list and pub-section styles are in assets/css/style.css -->"
"</head>"
"<body>"
"  <section id=""topbar"" class=""d-flex align-items-center"">"
"    <div class=""container d-flex justify-content-center justify-content-md-between"">"
"      <div class=""contact-info d-flex align-items-center"">"
"        <span class=""pulse""></span>Biochemistry &amp; Molecular Biology · Bioinformatics · UGA"
"      </div>"
"      <div class=""social-links d-none d-md-block"">"
"        <a href=""https://x.com/jamescai"" class=""twitter"" target=""_blank""><i class=""bi bi-twitter-x""></i></a>"
"        <a href=""https://github.com/cailab-uga"" class=""facebook"" target=""_blank""><i class=""bi bi-github""></i></a>"
"        <a href=""https://scholar.google.com/citations?hl=en&user=CI853QwAAAAJ&view_op=list_works&sortby=pubdate"" class=""instagram"" target=""_blank""><i class=""bi bi-google""></i></a>"
"        <a href=""https://www.youtube.com/@cailab-tamu"" class=""linkedin"" target=""_blank""><i class=""bi bi-youtube""></i></a>"
"      </div>"
"    </div>"
"  </section>"
"  <header id=""header"" class=""d-flex align-items-center"">"
"    <div class=""container d-flex align-items-center justify-content-between"">"
"      <h1 class=""logo""><a href=""index.html""><span style=""color:#BA0C2F;font-family:ui-monospace,'SF Mono',Menlo,Consolas,monospace;"">&lt;</span><span style=""font-family:Raleway,'Helvetica Neue',Arial,sans-serif;""> Cai Lab </span><span style=""color:#BA0C2F;font-family:ui-monospace,'SF Mono',Menlo,Consolas,monospace;"">/&gt;</span></a></h1>"
"      <nav id=""navbar"" class=""navbar"">"
"        <ul>"
"          <li><a class=""nav-link"" href=""index.html#about"">About</a></li>"
"          <li><a class=""nav-link"" href=""index.html#news"">News</a></li>"
"          <li><a class=""nav-link"" href=""index.html#research"">Research</a></li>"
"          <li><a class=""nav-link active"" href=""index.html#publications"">Publications</a></li>"
"          <li><a class=""nav-link"" href=""index.html#team"">Team</a></li>"
"          <li><a class=""nav-link"" href=""index.html#contact"">Contact</a></li>"
"        </ul>"
"        <i class=""bi bi-list mobile-nav-toggle""></i>"
"      </nav>"
"    </div>"
"  </header>"
""
"  <main id=""main"">"
"    <section id=""breadcrumbs"" class=""breadcrumbs"">"
"      <div class=""container"">"
"        <ol><li><a href=""index.html"">Home</a></li><li>Publications</li></ol>"
"        <h2>Publications</h2>"
"      </div>"
"    </section>"
""
"    <section class=""inner-page"">"
"      <div class=""container"">"
""
];
    s = join(s, newline) + newline;
end


function s = fullPageFooter()
    s = [
""
"      </div>"
"    </section>"
"  </main>"
""
"  <footer id=""footer"">"
"    <div class=""footer-top"">"
"      <div class=""container"">"
"        <div class=""row"">"
"          <div class=""col-lg-4 col-md-6"">"
"            <div class=""footer-info"">"
"              <h3>Cai Lab at UGA</h3>"
"              <p>"
"                Department of Biochemistry and Molecular Biology<br>"
"                University of Georgia<br>"
"                Athens, GA 30602, USA<br><br>"
"                <strong>Email:</strong> jcai@uga.edu<br>"
"              </p>"
"              <div class=""social-links mt-3"">"
"                <a href=""https://x.com/jamescai"" class=""twitter"" target=""_blank""><i class=""bi bi-twitter-x""></i></a>"
"                <a href=""https://github.com/cailab-uga"" class=""facebook"" target=""_blank""><i class=""bx bxl-github""></i></a>"
"                <a href=""https://scholar.google.com/citations?hl=en&user=CI853QwAAAAJ&view_op=list_works&sortby=pubdate"" class=""instagram"" target=""_blank""><i class=""bx bxl-google""></i></a>"
"                <a href=""https://www.youtube.com/@cailab-tamu"" class=""linkedin"" target=""_blank""><i class=""bx bxl-youtube""></i></a>"
"              </div>"
"            </div>"
"          </div>"
""
"          <div class=""col-lg-2 col-md-6 footer-links"">"
"            <h4>Navigation</h4>"
"            <ul>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#about"">About</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#news"">News</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#research"">Research</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#publications"">Publications</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#team"">Team</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""index.html#contact"">Contact</a></li>"
"            </ul>"
"          </div>"
""
"          <div class=""col-lg-2 col-md-6 footer-links"">"
"            <h4>Software</h4>"
"            <ul>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""https://scgeatool.github.io/"" target=""_blank"">scGEAToolbox</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""https://github.com/cailab-uga/scTenifoldNet"" target=""_blank"">scTenifoldNet</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""https://github.com/cailab-uga/scTenifoldKnk"" target=""_blank"">scTenifoldKnk</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""https://github.com/cailab-uga/scTenifoldXct"" target=""_blank"">scTenifoldXct</a></li>"
"              <li><i class=""bx bx-chevron-right""></i> <a href=""https://github.com/cailab-uga"" target=""_blank"">All on GitHub</a></li>"
"            </ul>"
"          </div>"
"        </div>"
"      </div>"
"    </div>"
""
"    <div class=""container"">"
"      <div class=""copyright"">"
"        &copy; Copyright <strong><span>Cai Lab</span></strong>. All Rights Reserved"
"      </div>"
"      <div class=""credits"">"
"        Designed by <a href=""https://bootstrapmade.com/"">BootstrapMade</a>"
"      </div>"
"    </div>"
"  </footer>"
""
"  <a href=""#"" class=""back-to-top d-flex align-items-center justify-content-center""><i class=""bi bi-arrow-up-short""></i></a>"
"  <div id=""preloader""></div>"
""
"  <script defer src=""https://badge.dimensions.ai/badge.js"" charset=""utf-8""></script>"
"  <script defer src=""assets/vendor/aos/aos.js""></script>"
"  <script defer src=""assets/vendor/bootstrap/js/bootstrap.bundle.min.js""></script>"
"  <script defer src=""assets/vendor/glightbox/js/glightbox.min.js""></script>"
"  <script defer src=""assets/vendor/isotope-layout/isotope.pkgd.min.js""></script>"
"  <script defer src=""assets/vendor/swiper/swiper-bundle.min.js""></script>"
"  <script defer src=""assets/vendor/php-email-form/validate.js""></script>"
"  <script defer src=""assets/js/main.js""></script>"
""
"</body>"
"</html>"
];
    s = newline + join(s, newline) + newline;
end


function s = indentHtml(html, numberOfSpaces)
    html = strtrim(html);
    if html == ""
        s = "";
        return
    end

    lines = splitlines(html);
    prefix = string(repmat(' ', 1, numberOfSpaces));
    s = join(prefix + lines, newline);
end


function [s] = in_loopthrough_simple(AAv, Highlighted)
    s = "";
    for k = 1:length(AAv)
        fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));

        if exist(fname, "file")
            fileContent = fileread(fname);
            s = s + normalizePublicationHtml(string(fileContent));
        else
            try
                if contains(AAv(k), '/')
                    s1 = i_doi2html(AAv(k), ismember(AAv(k), Highlighted));
                else
                    s1 = i_pmid2html(AAv(k), ismember(AAv(k), Highlighted));
                end
                s1 = normalizePublicationHtml(s1);
                writelines(s1, fname);
                s = s + s1;
            catch ME
                warning(ME.identifier, '%s', ME.message);
                disp(AAv(k));
                s1 = fallbackPublicationHtml(AAv(k), ismember(AAv(k), Highlighted));
                writelines(s1, fname);
                s = s + s1;
            end
        end
    end
end


function [s] = in_loopthrough(AAv, Highlighted)
    wavefilev = matlab.lang.makeValidName(AAv);
    for k = 1:length(AAv)
        fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));
        ishighlighted = ismember(AAv(k), Highlighted);
        hasAudio = exist(sprintf('../wav/%s.wav', wavefilev(k)), 'file');

        if ishighlighted || ~exist(fname, "file") || hasAudio
            pause(1)
            try
                if contains(AAv(k), '/')
                    s1 = i_doi2html(AAv(k), ishighlighted);
                else
                    s1 = i_pmid2html(AAv(k), ishighlighted);
                end

                if hasAudio
                    s2 = sprintf("<audio controls src=""wav/%s.wav"" style=""height: 30px;""></audio>", wavefilev(k));
                    s1 = insertBeforeLi(s1, s2);
                end
                writelines(normalizePublicationHtml(s1), fname);
            catch ME
                warning(ME.identifier, '%s', ME.message);
                disp(AAv(k));
                s1 = fallbackPublicationHtml(AAv(k), ishighlighted);
                writelines(s1, fname);
            end
        end
    end

    s = "";
    for k = 1:length(AAv)
        fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));
        if exist(fname, "file")
            fileContent = fileread(fname);
            s = s + normalizePublicationHtml(string(fileContent));
        end
    end
end


function result = insertBeforeLi(inputStr, insertStr)
    inputStr = strtrim(inputStr);
    if endsWith(inputStr, '</li>')
        result = strrep(inputStr, "</li>", insertStr + "</li>");
    else
        result = inputStr;
    end
end


function s = normalizePublicationHtml(s)
    s = string(s);
    s = replace(s, "</a>.<span class=""__dimensions_badge_embed__""", "</a><span class=""__dimensions_badge_embed__""");
    s = regexprep(s, '</span>\.\s*PMID:', '</span> PMID:');
    s = regexprep(s, '</span>\.</li>', '</span></li>');
end


function s = fallbackPublicationHtml(id, ishighlighted)
    id = string(id);
    if ishighlighted
        s = "<li class=""highlighted"">";
    else
        s = "<li>";
    end

    if contains(id, '/')
        s = sprintf('%s<strong>Metadata unavailable for DOI %s.</strong>\n', s, id);
        s = sprintf('%sdoi: <a href="https://doi.org/%s">%s</a>', s, id, id);
        s = sprintf('%s<span class="__dimensions_badge_embed__" data-doi="%s" data-style="small_rectangle"></span></li>\n', s, id);
    else
        s = sprintf('%s<strong>Metadata unavailable for PMID %s.</strong>\n', s, id);
        s = sprintf('%sPMID: <a href="https://pubmed.ncbi.nlm.nih.gov/%s">%s</a></li>\n', s, id, id);
    end

    s = string(s);
end
