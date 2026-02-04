clear % ALWAYS start your script be clearing the memory cache


%
% Download the data directly from the source 
% (note the station name and reference frame in the URL)
%
% If you have UNIX tools intalled, try downloading using the "curl" command.
% Or use MATLAB's native websave commmand.
% Or just downloaded from the NGL website by right-click SaveAs 
% (if downloaded from website, be careful about the filename extension).
%
  % !curl https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/1LSU.NA.tenv3 > 1LSU.NA.tenv3
  % websave('1LSU.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/1LSU.NA.tenv3');

%
% Download all the data we'll use
%
  websave('P403.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P403.NA.tenv3');
  websave('P395.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P395.NA.tenv3');
  websave('P396.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P396.NA.tenv3');
  websave('P404.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P404.NA.tenv3');

%
% Load and Parse the GNSS data for P403
%
  fid=fopen('P403.NA.tenv3');
  C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
  fclose(fid);  

  t1=C{3};
  x1=C{9};

  xlocation1=C{22}(1);
  ylocation1=C{21}(1);

%
% Load and Parse the GNSS data for P395
%
  fid=fopen('P395.NA.tenv3');
  C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
  fclose(fid);  

  t2=C{3};
  x2=C{9};

  xlocation2=C{22}(1);
  ylocation2=C{21}(1);

%
% Load and Parse the GNSS data for P396
%
  fid=fopen('P396.NA.tenv3');
  C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
  fclose(fid);  

  t3=C{3};
  x3=C{9};

  xlocation3=C{22}(1);
  ylocation3=C{21}(1);

%
% Load and Parse the GNSS data for P404
%
  fid=fopen('P404.NA.tenv3');
  C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
  fclose(fid);  

  t4=C{3};
  x4=C{9};

  xlocation4=C{22}(1);
  ylocation4=C{21}(1);

%
% Load and Parse the map data
%
  fid=fopen('coastfile.xy');
  C=textscan(fid,'%f %f','headerlines',0);
  fclose(fid);  

  coast_lon=C{1};
  coast_lat=C{2};

%
% Plot the data for P403
%
  figure(1)
  clf
  subplot(2,1,1)
  plot(t1,x1,'.')

%
% fit a line to the data for P403
%
  P1=polyfit(t1,x1,1);
  vx1=P1(1)*1000 % convert from m/y to mm/y

  xline1=polyval(P1,t1);

  % Karen quick cheat to make a fake vy:
  vy1=vx1/2;


%
% plot the line on the existing figure for P403
%
  hold on
  plot(t1,xline1)

%
% calculate the residuals for P403
%
  xresidual1=x1-xline1;

%
% plot the residuals for P403
%
  subplot(2,1,2)
  plot(t1,xresidual1,'.')

%
% plot a map for P403
%
  figure(2)
  clf
  plot(coast_lon,coast_lat)

%
% plot a velocity vector on our map
%
  hold on
  quiver(xlocation1,ylocation1,vx1,vy1)

%
% Plot the data for P395
%
  figure(3)
  clf
  subplot(2,1,1)
  plot(t2,x2,'.')
  title('P395')

%
% fit a line to the data for P395
%
  P2=polyfit(t2,x2,1);
  vx2=P2(1)*1000 % convert from m/y to mm/y

  xline2=polyval(P2,t2);

  % Karen quick cheat to make a fake vy:
  vy2=vx2/2;


%
% plot the line on the existing figure for P395
%
  hold on
  plot(t2,xline2)

%
% calculate the residuals for P395
%
  xresidual2=x2-xline2;

%
% plot the residuals for P395
%
  subplot(2,1,2)
  plot(t2,xresidual2,'.')

%
% Plot the data for P396
%
  figure(4)
  clf
  subplot(2,1,1)
  plot(t3,x3,'.')
  title('P396')

%
% fit a line to the data for P396
%
  P3=polyfit(t3,x3,1);
  vx3=P3(1)*1000 % convert from m/y to mm/y

  xline3=polyval(P3,t3);

  % Karen quick cheat to make a fake vy:
  vy3=vx3/2;


%
% plot the line on the existing figure for P396
%
  hold on
  plot(t3,xline3)

%
% calculate the residuals for P396
%
  xresidual3=x3-xline3;

%
% plot the residuals for P396
%
  subplot(2,1,2)
  plot(t3,xresidual3,'.')

%
% Plot the data for P404
%
  figure(5)
  clf
  subplot(2,1,1)
  plot(t4,x4,'.')
  title('P404')

%
% fit a line to the data for P404
%
  P4=polyfit(t4,x4,1);
  vx4=P4(1)*1000 % convert from m/y to mm/y

  xline4=polyval(P4,t4);

  % Karen quick cheat to make a fake vy:
  vy4=vx4/2;


%
% plot the line on the existing figure for P404
%
  hold on
  plot(t4,xline4)

%
% calculate the residuals for P404
%
  xresidual4=x4-xline4;

%
% plot the residuals for P404
%
  subplot(2,1,2)
  plot(t4,xresidual4,'.')

%
% plot a map for all the velocities
%
  figure(6)
  clf
  plot(coast_lon,coast_lat)

%
% make arrays of the locations and velocity components
% so they can all be plotted with a single quiver command
%
  xlocation_all=[xlocation1;xlocation2;xlocation3;xlocation4];
  ylocation_all=[ylocation1;ylocation2;ylocation3;ylocation4];
  vx_all=[vx1;vx2;vx3;vx4];
  vy_all=[vy1;vy2;vy3;vy4];

%
% plot a velocity vector on our map
%
  hold on
  quiver(xlocation_all,ylocation_all,vx_all,vy_all)
  xlim([-126,-121])
  ylim([44,50])
