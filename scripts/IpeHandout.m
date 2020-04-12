%IPEHANDOUT   Creates PDF handout from IPE file.
%
%   IPEHANDOUT(PathName) Creates PDF handouts of IPE files specified by
%   PathName as PathName_handout. If PathName is omitted, a dialog box is
%   opened for selecting the files.
%
% Author: Jurgen van Zundert
% Date:   August 2017

function [] = IpeHandout(PathName)

%% Parse inputs
switch nargin
    case 0
        [FileNames,PathName] = uigetfile('*.pdf','MultiSelect','on');
        FileNames = cellstr(FileNames);
    case 1
        % Check for missing delimiter
        if ~strcmp(PathName(end),filesep)
            PathName(end+1) = filesep;
        end
        % Find all .pdf-files in PathName
        files = dir([PathName,'*.pdf']);
        FileNames = cell(1,length(files));
        for n = 1:length(files)
            FileNames{n} = files(n).name;
        end
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


%% Loop through files
for n = 1:length(FileNames)
    FileName_src = FileNames{n};
    
    % Append _handout to file name
    FileName_des = strrep(FileName_src,'.','_handout.');
    
    % Create handout
    dos(['"',IpePath,'ipetoipe" -pdf -markedview "',PathName,FileName_src,'" "',PathName,FileName_des,'"']);
end