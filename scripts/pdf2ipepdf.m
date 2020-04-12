%PDF2IPEPDF   Converts .pdf to IPE-editable .pdf.
%
%   PDF2IPEPDF(PathName) Converts the .pdf file specified by PathName OR
%   all .pdf files in directory PathName to IPE-editable .pdf files.
%   If PathName is omitted, a dialog box is opened for selecting the files.

% Author: Jurgen van Zundert
% Date:   August 2017

function [] = pdf2ipepdf(PathName)

%% Parse inputs
switch nargin
    case 0 % Use interface to select .pdf files
        [FileNames,PathName] = uigetfile('*.pdf','MultiSelect','on');
        if isequal(FileNames,0)
            warning('No files were selected.');
            return
        end
        FileNames = cellstr(FileNames);
    case 1
        if isdir(PathName) % Select all .pdf files in PathName
            % Check for missing delimiter
            if ~strcmp(PathName(end),filesep)
                PathName(end+1) = filesep;
            end
            % Find all .pdf-files in PathName
            files = dir([PathName,'*.pdf']);
            if isempty(files)
                disp('No files were converted.');
                return
            end
            FileNames = cell(1,length(files));
            for n = 1:length(files)
                FileNames{n} = files(n).name;
            end
            
        else % Select .pdf file specified by PathName
            [PathName_tmp,FileName,ext] = fileparts(PathName);
            FileNames = {[FileName,ext]};
            if isempty(PathName_tmp)
                PathName = [pwd,filesep];
            else
                PathName = [PathName_tmp,filesep];
            end
        end
end

%% Conversion options
mergelevel = questdlg({'Text merging level IPE';'   0 = none';'   1 = moderate';'   2 = aggressive'},'Merging text','0','1','2','1');
if isempty(mergelevel)
    warning('No PDF files were converted.');
    return
end


%% Check IPE path
% R2016b and later
% IpeFolders = [dir('C:\Program Files\ipe*'); dir('C:\Program Files (x86)\ipe*')];
% IpePath = [IpeFolders(end).folder,filesep,IpeFolders(end).name,'\bin\'];

% R2016a and earlier
IpePath= 'C:\Program Files\ipe-7.2.7\bin\';

if ~exist(IpePath,'dir')
    disp(IpePath);
    error('Incorrect path to IPE');
end


%% Predefined colors
xcolColorNames = {'white', 'black', 'red', 'green', 'blue', ...
    'brown', 'lime', 'orange', 'pink', ...
    'purple', 'teal', 'violet', ...
    'darkgray', 'gray', 'lightgray'};
xcolColorSpecs = {[1,1,1], [0,0,0], [1,0,0], [0,1,0], [0,0,1], ...
    [0.75,0.5,0.25], [0.75,1,0], [1,0.5,0], [1,0.75,0.75], ...
    [0.75,0,0.25], [0,0.5,0.5], [0.5,0,0.5], ...
    [0.25,0.25,0.25], [0.5,0.5,0.5], [0.75,0.75,0.75]};

MatlabColorNames = {'mblue','mred','morange','mpurple','mgreen','mcyan','mbrown'};
MatlabColorSpecs = {[0.000,0.447,0.741],[0.850,0.325,0.098],[0.929,0.694,0.125],[0.494,0.184,0.556],[0.466,0.674,0.188],[0.301,0.745,0.933],[0.635,0.078,0.184]};

colorNames = [xcolColorNames, MatlabColorNames];
colorSpecs = [xcolColorSpecs, MatlabColorSpecs];


%% Loop through files
for n = 1:length(FileNames)
    FileName = FileNames{n};
    [~,name] = fileparts(FileName);
    
    % Convert PDF to IPE
    dos(['(cd /d ',IpePath,' && pdftoipe -merge ',mergelevel,' -math "',PathName,FileName,'")']);  %-literal or -math
    
    % Set predefined colors
    fid  = fopen([PathName,name,'.ipe'],'r');
    f = fread(fid,'*char')';
    fclose(fid);
    
    ndig = 2; % number of digits precision for matching colors
    OrgStrFull = regexp(f,'stroke=".*?"','match');
    for m = 1:length(OrgStrFull)
        OrgStr = OrgStrFull{m};
        ColorStr = OrgStr(9:end-1);
        color = round(str2num(ColorStr)*10^ndig)/10^ndig; %#ok<ST2NM>
        if ~isempty(color)
            [~,idx] = ismember(round(cell2mat(colorSpecs.')*10^ndig)/10^ndig,color,'rows');
            if any(idx)
                f = strrep(f,OrgStr,['stroke="',colorNames{logical(idx)},'"']);
            end
        end
    end
    
    fid = fopen([PathName,name,'.ipe'],'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    
    % Convert IPE to PDF
    dos(['(cd /d ',IpePath,' && ipetoipe -pdf "',PathName,name,'.ipe" >nul)']);
    
    % Delete IPE-file
    delete([PathName,name,'.ipe']);
end