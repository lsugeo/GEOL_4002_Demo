clear % ALWAYS start your script be clearing the memory cache


%
% Download the data directly from the source 
% (note the station name and reference frame in the URL)
%
% If you have UNIX tools intalled, try downloading using the "curl" command.
% If not, skip this line and just use a file you downloaded from the website 
% by right-click SaveAs (if downloaded from website, be careful about the filename extension).
%
  % !curl https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/1LSU.NA.tenv3 > 1LSU.NA.tenv3

%
% Load and Parse the GNSS data
%
  fid=fopen('P403.NA.tenv3');
  C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
  fclose(fid);  

  t=C{3};
  x=C{9};

  xlocation=C{22}(1);
  ylocation=C{21}(1);

%
% Load and Parse the map data
%
  fid=fopen('coastfile.xy');
  C=textscan(fid,'%f %f','headerlines',0);
  fclose(fid);  

  coast_lon=C{1};
  coast_lat=C{2};

%
% Plot the data
%
  figure(1)
  clf
  subplot(2,1,1)
  plot(t,x,'.')

%
% fit a line to the data
%
  P=polyfit(t,x,1);
  vx=P(1)*1000 % convert from m/y to mm/y

  xline=polyval(P,t);

%
% plot the line on the existing figure
%
  hold on
  plot(t,xline)

%
% calculate the residuals
%
  xresidual=x-xline;

%
% plot the residuals
%
  subplot(2,1,2)
  plot(t,xresidual,'.')

%
% plot a map
%
  figure(2)
  clf
  plot(coast_lon,coast_lat)

  % Karen quick cheat to make a fake vy:
  vy=vx/2;

%
% plot a velocity vector on our map
%
  hold on
  quiver(xlocation,ylocation,vx,vy)



