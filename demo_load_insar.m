clear

filename='S1-GUNW-A-R-064-tops-20190710_20190628-015013-36885N_35006N-PP-a1b9-v2_0_2.nc';

% ncdisp(filename); % list the components include in the file

x=ncread(filename,'/science/grids/data/longitude');
y=ncread(filename,'/science/grids/data/latitude');
A=ncread(filename,'/science/grids/data/amplitude')'; % take the transpose to make array oriented correctly
