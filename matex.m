function matex
%
% script that computes analysis results and writes them to a formatted tex
% file for loading into a manuscript
%
% Emily Cooper, Stanford, 2014


% set up and perform simulated data analysis

dat.numSamples     = 100;                                      % number of data points in each condition
dat.conditionNames = {'Control','Test'};                       % name of each condition
resultsCond1      	= rand(1,dat.numSamples);                  % control data
resultsCond2     	= rand(1,dat.numSamples) + 0.1;            % test data
dat.means         	= mean([resultsCond1 ; resultsCond2],2);   % mean of each condition
[~,dat.p,dat.ci,~]  = ttest(resultsCond1,resultsCond2);        % paired t-test between two conditions


% save analysis information and results to the tex file

fileName           = 'variables.tex';                      % file name
fid                 = fopen(fileName,'w');                 % open for writing, NOTE: overwrite any existing file with the same name
decimals            = 2;                                    % number of significant digits in numeric data
fields              = fieldnames(dat);                      % data fields to write as variables


for x = 1:numel(fields)                                     % for each field in data structure

    [formatStr,varName,varVal] = ...                     % get formating string, names, and values - and perform any rounding
        formatVariable(dat,fields,x,decimals);
    
    % handle single or list of variables
    
    for y = 1:numel(dat.(fields{x}))
        
        vv = varVal(y);                                    % grab individual value
        
        if iscell(vv)                                       % remove cell formatting if needed
            vv = cell2mat(vv);
        end

        writeVariable(fid,varName{y},vv,formatStr);      % add to variables file
        
    end
end

fclose(fid);                                                % close the file



function [formatStr,varName,varVal] = formatVariable(dat,fields,x,dec)
%
% reformat data for latex variable, return formatting, variable name, and
% values


% format numeric or string data

if(isnumeric(dat.(fields{x})))     
    
    formatStr  = '%g';                                         % compact fixed-point notation
    varVal     = round(dat.(fields{x}).*(10^dec))./(10^dec);   % round values to significant digits
    
else
    
    formatStr  = '%s';                                         % string format
    varVal     = dat.(fields{x});                              % no rounding, of course
    
end


% generate flags for multiple values

if numel(varVal) > 1
    
    for y = 1:numel(varVal)                                    % for each unique value
        varName{y} = [fields{x} char(y-1+'A')];                % give it a numbered flag
    end
    
else
    
    varName{1} = fields{x};                                    % don't add flag to single values
    
end




function writeVariable(fid,varName,val,format)
%
% append a single line with the given value/format into the tex file

fprintf(fid, '%s', ['\newcommand{\' varName '}{']);
fprintf(fid, format, val);
fprintf(fid, '%s','}');
fprintf(fid, '\n');



