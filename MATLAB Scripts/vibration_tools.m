% Jonathan Zerez, Summer 2019
% The purpose of this script is to take .txt files produced from Peter
% Byrnes' LabView data acquisition software and prepare them for use in
% matlab. It harvests header information, voltage information, and
% timestamps from the files, and saves them as a .mat file for easy use in
% matlab.

path = '../RAW/';
files = dir(path);

dirFlags = [files.isdir];
file_names = {files.name};
file_names = file_names(~dirFlags);
offset = 0;

num_files = length(file_names);

for i = 1:num_files
    tic
    name = file_names{1};
    
    % Collect and filter out corresponding data by looking at matching
    % file prefixes
    underscore_ind = strfind(name, '_');
    if isempty(underscore_ind)
        file_names = file_names(2:end);
        continue
    end
    prefix = name(1:underscore_ind(1));
    disp(prefix)
    
    family_inds = contains(file_names, prefix);
    file_family = file_names(family_inds);
    file_names = file_names(~family_inds);
    
    
    data = [];
    overall_dt = 0;
    for j = 1:length(file_family)
        name = file_family{j};
        suffix = name(end-6:end-4);
        % Extract the PSD information from the ASD file
        if strcmp(suffix, 'ASD')
            PSD = read_asd(path, name);
        else
            % Stitch together .txt files and check continuity with timestamps
            [data_temp, header] = read_txt(path, name);
            if ~isempty(data)
                assert(sum(header.deltaT == overall_dt) == length(overall_dt));
                assert(abs(data_temp(1) - data(1, end)) < (1.1 * overall_dt(1)));
            else
                overall_header = header;
            end
            data = [data, data_temp];
            overall_dt = header.deltaT;
        end
    end
    
    header = overall_header;
    time = data(1, :)';
    data = data(2:end,:)';
    new_file_name = strcat(path, 'mats/', prefix, 'ALL_DATA.mat');
    save(new_file_name, 'header', 'data', 'time', 'PSD');
    
    toc
    % Compare extracted PSD to calculated PSD to ensure consistency
    if isempty(file_names)
        break
    end
end


function PSD = read_asd(path, name)
    extension = name(end-2:end);
    % Change xls to txt if needed
    if strcmp(extension, 'xls')
        new_name = strcat(name(1:end-3), 'txt');
        movefile(strcat(path, name), strcat(path, new_name));
        name = new_name;
    end
    asd_data = fileread(strcat(path,name));
    
    % Find where the data begins
    data_start = find_data_start_ASD(asd_data);
    assert(~isempty(data_start));
    
    % split into lines, and extract data
    asd_data = asd_data(data_start:end);
    lines = splitlines(asd_data);
    lines = lines(2:end);
    PSD = zeros([2, length(lines)]);
    offset = 0;
    for indexk = 1:length(lines)
        line = lines{indexk};
        data = strsplit(line);
        if length(data) > 1
            PSD(:, indexk) = [str2num(data{1}); str2num(data{2})]; 
        else
            offset = offset + 1;
        end
    end
    PSD = PSD(:, 1:end-offset);
end

function ind = find_data_start_ASD(data)
    % look for expressions in the form of -**- OR /**/ where * is wildcard
    date_exprs = ['-(?=..-)';
                  '/(?=../)'];
    for expr = 1:length(date_exprs)
        ind = regexp(data, date_exprs(expr, :));
        if ~isempty(ind)
            ind = ind(1);
            break
        end
    end
end

function ind = find_data_start_TXT(data)
    % look for expressions in the form of -**- OR /**/ where * is wildcard
    inds = strfind(data, 'time');
    assert(~isempty(inds));
    ind = inds(1);
end

function [category, details, category2, details2] = split_details(line)
    start = strsplit(line);
    category2 = []; details2 = [];
    % Check if current line is the start time
    if strcmp(start(1), 't0')
        category = 't0';
        l = strsplit(line, 't0\t');
        details = datenum(strsplit(l{2}, '\t'));
        return
    % Check if current line is delta t
    elseif strcmp(start(1), 'delta')
        category = 'delta t';
        details = str2double(start(3:end));
        return
    else
        ind = strfind(line, ':');
        category = line(1:ind-1);
        line = line(ind+2:end);
    end
    
    % Separate engineers into their own buckets
    if contains(category, 'Engineer')
        % Check to make sure waveforms aren't part of the same line
        if contains(line, 'waveform')
            s = strsplit(line, 'waveform');
            details = strsplit(s{1}, ', ');
            category2 = 'waveform';
            details2 = strsplit(s{2});
            return
        else
            details = strsplit(line, ', ');
        end
    else
        % Separate every other category by pikes (|)
        details = strsplit(line, ' | ');
    end
end

function [vs, header_info] = read_txt(path, name)
    all_data = fileread(strcat(path,name));

    % Find where the data begins
    data_start = find_data_start_TXT(all_data);
    
    % split into lines, and extract data
    header_data = all_data(1:data_start);
    voltage_data = all_data(data_start:end);
    
    header_info = struct();
    header_lines = splitlines(header_data);
    volt_lines = splitlines(voltage_data);
    volt_lines = volt_lines(2:end);
    
    offset = 0;

    for indexi = 1:length(header_lines)
        l = header_lines(indexi);
        [field, value, field2, value2] = split_details(l{1});
        header_info.(genvarname(field)) = value;
        if ~isempty(field2)
            header_info.(genvarname(field2)) = value2;
        end
    end
    disp(['file has ', num2str(length(header_info.deltaT)), ' channels and ', num2str(length(volt_lines)), ' lines'])
    vs = zeros([length(header_info.deltaT) + 1, length(volt_lines)]);
    for indexk = 1:length(volt_lines)
        line = volt_lines{indexk};
        data = strsplit(line);
        if length(data) > 1
            t = datenum(strcat(data{1}, ' ', data{2}));
            vs(:, indexk) = [t; str2double(data(3:end))'];
        else
            offset = offset + 1;
        end
    end
    vs = vs(:, 1:(end-offset));
end