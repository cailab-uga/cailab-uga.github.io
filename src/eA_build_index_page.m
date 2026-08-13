fid=fopen('news_source.txt','r');
a=textscan(fid,'%s','Delimiter','\n');
a=a{1};
fclose(fid);
a=a(cellfun(@length, a)>0);

%{
    fid=fopen('news_aa.html','w');
    fprintf(fid, '\t\t\t\t<p>\n\t\t\t\t\t<dl>\n\n');
    t=-1;
    for k=1:length(a)
        t=-1*t;
        if t>0
            fprintf(fid, '\t\t\t\t\t<dt>%s</dt>\n', string(datetime(a{k},'Format','MM/dd/uuuu', ...
                'InputFormat','MM/dd/uuuu')));
        else
            fprintf(fid, '\t\t\t\t\t<dd>%s</dd>\n\n', a{k});
        end
    end
    fprintf(fid, '\t\t\t\t\t</dl>\t\t\t\t</p>');
    fclose(fid);
%}

%                 <tr><td style="white-space:nowrap; color:#6b6b6b; font-size:13px; padding-top:12px;">Apr 13, 2026</td><td style="padding-top:12px;"><strong>Shreyan Gupta</strong> receives the Dr. James E. Womack Award for the 2025–2026 academic year.</td></tr>

fid=fopen('uga_news.html','w');
t=-1;

for k=1:length(a)
    t=-1*t;
    if t>0
        ak = a{k};
    else
        fprintf(fid, '<tr><td style="white-space:nowrap; color:#6b6b6b; font-size:13px; padding-top:12px;">%s</td><td style="padding-top:12px;">%s</td></tr>\n', ...
            string(datetime(ak,'Format','MMM dd, uuuu', ...
            'InputFormat','MM/dd/uuuu')), a{k});
    end
end
fclose(fid);


C0=i_readtxt('uga_index_template.html');
C1=i_readtxt('uga_news.html');
C2=i_readtxt('uga_people.html');

i1=find(strcmp('<<<1>>>',C0));
C0=[C0(1:i1-1); C1; C0(i1+1:end)];

i2=find(strcmp('<<<2>>>',C0));
C0=[C0(1:i2-1); C2; C0(i2+1:end)];

%i3=find(strcmp('<<<3>>>',C0));
%C0=[C0(1:i3-1); C3; C0(i3+1:end)];

writecell(C0,'../index.html','FileType','text','QuoteStrings','none');


function C=i_readtxt(filename)
    fileID = fopen(filename);
    C=textscan(fileID,'%s','Delimiter','\n','whitespace', '');
    %C=textscan(fileID,'%s','Delimiter','\n');
    C=C{1};
    fclose(fileID);
end

