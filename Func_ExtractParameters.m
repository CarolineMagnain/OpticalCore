function Parameters = Func_ExtractParameters(xml_file,path)

foldername = xml_file(1:end-4);
c=textread([path '/' foldername '.xml'],'%s','delimiter','\n');

Key   = 'value="';
Parameters.FolderPath = [path];
Parameters.FolderName = [foldername];
%% Laser Parameters

ll = find(~cellfun(@isempty,strfind(c,'laserWavelength')));
Str = c{ll+1};
Index = strfind(Str, Key);
Parameters.LaserWavelength = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

ll = find(~cellfun(@isempty,strfind(c,'laserPower')));
Str = c{ll+1};
Index = strfind(Str, Key);
Parameters.LaserPower = sscanf(Str(Index(1) + length(Key):end), '%g', 1);



%% PMT Gain

ll = find(~cellfun(@isempty,strfind(c,'pmtGain')));
%Channel 1
Str = c{ll+1};
Index = strfind(Str, Key);
Parameters.PMT_Gain(1) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
%Channel 2
Str = c{ll+2};
Index = strfind(Str, Key);
Parameters.PMT_Gain(2) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
%Channel 3
Str = c{ll+3};
Index = strfind(Str, Key);
Parameters.PMT_Gain(3) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
%Channel 4
Str = c{ll+4};
Index = strfind(Str, Key);
Parameters.PMT_Gain(4) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);


%% Imaging Parameters

ll = find(~cellfun(@isempty,strfind(c,'objectiveLensMag')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.Objective = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

ll = find(~cellfun(@isempty,strfind(c,'opticalZoom')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.OpticalZoom = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

ll = find(~cellfun(@isempty,strfind(c,'pixelsPerLine')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.FOVpixels(1) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
ll = find(~cellfun(@isempty,strfind(c,'linesPerFrame')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.FOVpixels(2) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

ll = find(~cellfun(@isempty,strfind(c,'micronsPerPixel')));
Str = c{ll+1};
Index = strfind(Str, Key);
Parameters.PixelSize(1) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
Str = c{ll+2};
Index = strfind(Str, Key);
Parameters.PixelSize(2) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
Str = c{ll+3};
Index = strfind(Str, Key);
Parameters.PixelSize(3) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

ll = find(~cellfun(@isempty,strfind(c,'framePeriod')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.FramePeriod = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

%% Position

ll = find(~cellfun(@isempty,strfind(c,'positionCurrent')));
Str = c{ll+2};
Index = strfind(Str, Key);
Parameters.Position(1) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
Str = c{ll+5};
Index = strfind(Str, Key);
Parameters.Position(2) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
Str = c{ll+8};
Index = strfind(Str, Key);
Parameters.Position(3) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);

%% Sequence

Key   = 'type="';
ll = find(~cellfun(@isempty,strfind(c,'Sequence')));
Str = c{ll};
Index = strfind(Str, Key);
Parameters.Sequence = sscanf(Str(Index(1) + length(Key):end), '%s', 1);
Key   = 'cycle="';
Str = c{ll};
Index = strfind(Str, Key);
Parameters.Cycle = sscanf(Str(Index(1) + length(Key):end), '%s', 1);
if Parameters.Sequence(end)=='"'
    Parameters.Sequence(end)=[];
end
if Parameters.Cycle(end)=='"'
    Parameters.Cycle(end)=[];
end

ch = find(Parameters.PMT_Gain~=0);

switch Parameters.Sequence
    case  'Single'
        Parameters.NbImages=1;
        for ii=ch
            Parameters.Channel{ii}.name{1} = [foldername '_Cycle' sprintf('%05i',str2num(Parameters.Cycle)) '_Ch' sprintf('%i',ii)...
                '_' sprintf('%06i',1) '.ome.tif'];
        end
    case  'TSeries'
        ll = find(~cellfun(@isempty,strfind(c,'<Frame')));
        Parameters.NbImages=length(ll);
        for ii=ch
            for jj=1:length(ll)
                Parameters.Channel{ii}.name{jj} = [foldername '_Cycle' sprintf('%05i',str2num(Parameters.Cycle)) '_Ch' sprintf('%i',ii)...
                    '_' sprintf('%06i',jj) '.ome.tif'];
            end
        end
        
    case 'ZSeries'
        mm = find(~cellfun(@isempty,strfind(c,'<Frame')));
        Parameters.NbImages=length(mm);
        for ii=ch
            for jj=1:length(mm)
                Parameters.Channel{ii}.name{jj} = [foldername '_Cycle' sprintf('%05i',str2num(Parameters.Cycle)) '_Ch' sprintf('%i',ii)...
                    '_' sprintf('%06i',jj) '.ome.tif'];
            end
        end
        Key   = 'value="';
        
        for ii=1:length(mm)
            
            %laser power
                ll = find(~cellfun(@isempty,strfind(c(mm(ii):end),'laserPower')));
            if isempty(ll)==0
                
                Str = c{ll+1 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.LaserPower(ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
            end
            
            % PMT Gain
            
                ll = find(~cellfun(@isempty,strfind(c(mm(ii):end),'pmtGain')));
            if isempty(ll)==0
                %Channel 1
                Str = c{ll+1 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.PMT_Gain(1,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
                %Channel 2
                Str = c{ll+2 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.PMT_Gain(2,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
                %Channel 3
                Str = c{ll+3 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.PMT_Gain(3,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
                %Channel 4
                Str = c{ll+4 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.PMT_Gain(4,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
            end
            
            % Position
            ll = find(~cellfun(@isempty,strfind(c(mm(ii):end),'positionCurrent')));
            if isempty(ll)==0
                Str = c{ll+2 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.Position(1,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
                Str = c{ll+5 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.Position(2,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
                Str = c{ll+8 + mm(ii)-1};
                Index = strfind(Str, Key);
                Parameters.ZSeries.Position(3,ii) = sscanf(Str(Index(1) + length(Key):end), '%g', 1);
            end
        end
        
        
end


save([path '/Parameters_' foldername '.mat'],'Parameters');

end





