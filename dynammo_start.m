function dynammo_start(varargin)
%
% Starter file for Project Dyn:Ammo
% [1] All Project files are added to Matlab search path
% [2] Some 3rd party programs are registered into
%     system environment variables:
%         - PDFTk Server (all-purpose manipulator with PDF documents)
%                   !!! You must either have a copy of this free program, or download it
%                       from <https://www.pdflabs.com/tools/pdftk-server/>      
% 
%         - wkhtmltopdf (WebKit, used while transforming HTML report tables into PDF format)
%                   !!! You must either have a copy of this free program, or download it
%                       from <http://wkhtmltopdf.org/>
% 
% Paths to the above 3rd party programs should be saved in dynammo_config() file
% 
% NOTE: X12-ARIMA seasonal adjustment binaries (taken from U.S. Census Bureau) are distributed 
%       along with other Project files (both PC/UNIX versions), no installation needed
% 
% INPUT: [silent mode trigger]
% 

%#<signature>#

% keyboard;

%% Silent mode
silent_mode = 0;
if nargin==1 
    if strcmpi(varargin{1},'silent')
        silent_mode = 1;
    end
end

%% Prevent from heating up multiple times when the Project is already running

testpath = which('envpath.mat');
if ~isempty(testpath)
    if ~silent_mode
        disp(' -> Project Dyn:Ammo already running...');
    end
    return % No need to proceed
end

%% Modify Matlab search path

% Get current Project path
dynpath = which('dynammo_start.m');

% Calling this func. proves that it is on the search path...
% if isempty(dynpath)
%     error('dynammo_start() was not found. Navigate manually to the Project folder..'); 
% end

dynpath = fileparts(dynpath);

% folder = cd;
paths = genpath(dynpath);%genpath_all
if ispc
    path_splitter = ';';%pathsep()
else
    path_splitter = ':';%pathsep()
end
paths = regexp(paths,path_splitter,'split');
paths = paths(:);
 
% Notes
notes = paths(~cellfun(@isempty,regexp(paths,'Notes','match')));
 
% Development notes
paths = paths(cellfun(@isempty,regexp(paths,'Development notes','match')));
 
% Add notes
paths = [paths;notes];
 
% Empty field thrown away
paths(strcmp('',paths))=[];
 
for ii = 1:length(paths)
    addpath(paths{ii});
end

%% Environment variables

% Save previous setup
envpath = getenv('PATH');
save([dynpath filesep 'Utilities' filesep 'envpath'],'envpath');

% Additional paths to external executables
path = dynammo_config(silent_mode);

items = fieldnames(path);
if ~isempty(items)
   for ii = 1:length(items)
       
       % Make sure the correct file separator is used
       % PC: '\'
       % UNIX: '/'
       item_now = regexprep(path.(items{ii}),'(\\|/)',filesep);
       
       % Get rid of trailing separator
       if strcmp(item_now(end),filesep)
           item_now = item_now(1:end-1);
       end
       
       % Correct path names with spaces
       if ispc
           item_spaces = regexp(item_now,filesep,'split');
           spac_trig = 0;
           for jj = 1:length(item_spaces)
               if any(isspace(item_spaces{jj}))
                  %keyboard;
                  item_spaces{jj} = ['\"' item_spaces{jj} '\"'];
                  spac_trig = 1;
               end
           end
           if spac_trig
               item_spaces = strcat(item_spaces,filesep);
               item_now = cat(2,item_spaces{:});
               item_now = item_now(1:end-1);% Yes, needed one more time
           end
       else % unix
           if any(isspace(item_now))
               item_now = ['"' item_now '"']; %#ok<AGROW>
           end
       end
       
       % Add user supplied paths to the environment
           %if ispc
           %    item_now = strrep(item_now,'\\',[filesep filesep filesep]);
           %end
       
       % Not found in the middle
%        if isempty(regexp(envpath,[item_now path_splitter],'once'))
%            %if ispc
%            %   item_now = strrep(item_now,[filesep filesep],filesep);
%            %end
%            if length(envpath) >= length(item_now)
%                % Not found at the end
%                if ~strcmp(envpath(end-length(item_now)+1:end),item_now) 
%                    setenv('PATH', [envpath path_splitter item_now]);
%                    envpath = getenv('PATH');
%                end 
%            else
             if  ii==1 
                if ~strcmp(envpath(end),path_splitter)
                    setenv('PATH', [envpath path_splitter item_now]);
                else
                    setenv('PATH', [envpath item_now]);
                end
             else
                 setenv('PATH', [envpath path_splitter item_now]);
             end
             envpath = getenv('PATH');
%            end
%        end
       
   end %<item>
end

% if ~isempty(varargin)
%     envpath = getenv('PATH');% Needed here fresh!
%     disp(regexp(envpath,';','split')');
% end

end %<eof>
