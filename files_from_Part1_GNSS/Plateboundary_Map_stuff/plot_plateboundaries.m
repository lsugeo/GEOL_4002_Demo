clear

%
% Load the map data
%
  plates=load('boundaries_Bird_2002.xy');
  lon_plates=plates(:,1);
  lat_plates=plates(:,2);

%
% Plots map stuff
%
  figure(1),clf
  plot(lon_plates,lat_plates,'k')
