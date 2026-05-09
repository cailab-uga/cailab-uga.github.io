addpath('pmidoi\');
e0_pmidoilist;

fid=fopen('publications.html','w');

S1 = in_loopthrough(AAv(ispreprint), Highlighted);
fprintf(fid,"<h3>Preprints</h3>\n<ol>");
fprintf(fid,"\n%s\n", S1);
fprintf(fid,"</ol>\n");

S2 = in_loopthrough(AAv(~ispreprint), Highlighted);
fprintf(fid,"<h3>Journal Articles</h3>\n<ol>");
fprintf(fid,"\n%s\n", S2);
fprintf(fid,"</ol>\n");
fclose(fid);
% copyfile("publications.html","../publications.html");


fid=fopen('../publications.html','w');
S1 = in_loopthrough_simple(AAv(ispreprint), Highlighted);
fprintf(fid,"<h3>Preprints</h3>\n<ol>");
fprintf(fid,"\n%s\n", S1);
fprintf(fid,"</ol>\n");
S2 = in_loopthrough_simple(AAv(~ispreprint), Highlighted);
fprintf(fid,"<h3>Journal Articles</h3>\n<ol>");
fprintf(fid,"\n%s\n", S2);
fprintf(fid,"</ol>\n");
fclose(fid);


fid=fopen('../selected_publications.html','w');
y=ismember(AAv,Highlighted);
S1 = in_loopthrough_simple(AAv(y), Highlighted);
fprintf(fid,"<h3>Selected Publications</h3>\n<ol>");
fprintf(fid,"\n%s\n", S1);
fprintf(fid,"</ol>\n");
fclose(fid);


    function [s] = in_loopthrough_simple(AAv, Highlighted)
        s = "";
        for k=1:length(AAv)
            fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));
            
            if exist(fname,"file")
                ishighlighted = ismember(AAv(k), Highlighted);
                if ishighlighted
                    try
                        if contains(AAv(k),'/')
                            s1=i_doi2html(AAv(k), false);
                        else
                            s1=i_pmid2html(AAv(k), false);
                        end    
                           s = s + s1;
                    catch ME
                        AAv(k)
                    end
                else
                    fileContent = fileread(fname);
                    s = s + string(fileContent);
                end
            end
        end    
    end


    function [s] = in_loopthrough(AAv, Highlighted)
        wavefilev = matlab.lang.makeValidName(AAv);
        for k=1:length(AAv)
            fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));
            ishighlighted = ismember(AAv(k), Highlighted);
            if ishighlighted || ~exist(fname,"file") || exist(sprintf('../wav/%s.wav', wavefilev(k)),'file')
                pause(1)
                ishighlighted = ismember(AAv(k), Highlighted);
                try
                    if contains(AAv(k),'/')
                        s1=i_doi2html(AAv(k),ishighlighted);
                    else
                        s1=i_pmid2html(AAv(k),ishighlighted);
                    end
    
                   if exist(sprintf('../wav/%s.wav', wavefilev(k)),'file')
                       s2 = sprintf("<audio controls src=""wav/%s.wav"" style=""height: 30px;""></audio>", wavefilev(k));
                       s3 = insertBeforeLi(s1, s2);
    
                       % assignin("base","s1",s1)
                       % assignin("base","s2",s2)
                       % assignin("base","s3",s3)
                       % pause
                       writelines(s3, fname);
                   else
                       writelines(s1, fname);
                   end
                catch ME
                    % warning(ME.identifier, '%s', ME.message);
                    AAv(k)
                end
            end
        end
        s = "";
        for k=1:length(AAv)
            fname = fullfile("paperhtml", matlab.lang.makeValidName(AAv(k)));
            if exist(fname,"file")
                fileContent = fileread(fname);
                s = s + string(fileContent);
            end
        end
    
    end
    
    
    
    function result = insertBeforeLi(inputStr, insertStr)
        % Check if the input string ends with "</li>"
        inputStr = strtrim(inputStr);
        if endsWith(inputStr, '</li>')
            % Insert the specified string before the closing "</li>" tag
            result = strrep(inputStr, "</li>", insertStr +"</li>");
        else
            % Return the original string if it doesn't end with "</li>"
            result = inputStr;
        end
    end
    

