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
  % websave('P403.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P403.NA.tenv3');
  % websave('P395.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P395.NA.tenv3');
  % websave('P396.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P396.NA.tenv3');
  % websave('P404.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P404.NA.tenv3');

% %
% % Load and parse all the GNSS sites
% %
%   [t1,x1,xlocation1,ylocation1]=load_and_parse_one_GNSS('P403');
%   [t2,x2,xlocation2,ylocation2]=load_and_parse_one_GNSS('P395');
%   [t3,x3,xlocation3,ylocation3]=load_and_parse_one_GNSS('P396');
%   [t4,x4,xlocation4,ylocation4]=load_and_parse_one_GNSS('P404');

% %
% % find velocities of all the GNSS sites:
% %
%   [vx1,vy1,xline1]=fit_velocity_one_GNSS(t1,x1);
%   [vx2,vy2,xline2]=fit_velocity_one_GNSS(t2,x2);
%   [vx3,vy3,xline3]=fit_velocity_one_GNSS(t3,x3);
%   [vx4,vy4,xline4]=fit_velocity_one_GNSS(t4,x4);

% %
% % Load and parse all the GNSS sites
% %
%   [T{1},X{1},xlocation(1),ylocation(1)]=load_and_parse_one_GNSS('P403');
%   [T{2},X{2},xlocation(2),ylocation(2)]=load_and_parse_one_GNSS('P395');
%   [T{3},X{3},xlocation(3),ylocation(3)]=load_and_parse_one_GNSS('P396');
%   [T{4},X{4},xlocation(4),ylocation(4)]=load_and_parse_one_GNSS('P404');

%
% Load and parse all the GNSS sites using a nifty for loop!
%
  stationlist={'P403','P395','P396','P404'};

  for k=1:4
    [T{k},X{k},xlocation(k),ylocation(k)]=load_and_parse_one_GNSS(stationlist{k});
    [vx(k),vy(k),XLINE{k}]=fit_velocity_one_GNSS(T{k},X{k});
    XRESIDUAL{k}=X{k}-XLINE{k};
  end

%
% plot all the data on a single figure together
%
  figure(11)
  clf

  for k=1:4
    subplot(211)
    plot(T{k},X{k}-X{k}(1))
    hold on

    subplot(212)
    plot(T{k},XRESIDUAL{k})
    hold on
  end

%
% Load and Parse the map data
%
  fid=fopen('coastfile.xy');
  C=textscan(fid,'%f %f','headerlines',0);
  fclose(fid);  

  coast_lon=C{1};
  coast_lat=C{2};


%
% plot a map for everything!
%
  figure(2)
  clf
  plot(coast_lon,coast_lat)
  xlim([-126,-121])
  ylim([44,50])

%
% plot a velocity vector on our map
%
  hold on
  quiver(xlocation,ylocation,vx,vy)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION DEFINITIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function [t,x,xlocation,ylocation]=load_and_parse_one_GNSS(stationname)
    filename=[stationname,'.NA.tenv3'];

    fid=fopen(filename);
    C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);  

    t=C{3};
    x=C{9};

    xlocation=C{22}(1);
    ylocation=C{21}(1);
  end

  function [vx,vy,xline]=fit_velocity_one_GNSS(t,x)
    P=polyfit(t,x,1);
    vx=P(1)*1000; % convert from m/y to mm/y

    xline=polyval(P,t);

    % Karen quick cheat to make a fake vy:
    vy=vx/2;
  end


