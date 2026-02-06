clear % ALWAYS start your script be clearing the memory cache


%
% Download the data directly from the source 
% (note the station name and reference frame in the URL)
%
  % websave('J175.OK.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/OK/J175.OK.tenv3');

%
% Load the data - be careful what reference frame you choose!
%
  [t,x,xlocation,ylocation]=load_and_parse_one_GNSS('J175','OK');

%
% plot the time series
%
  figure(1)
  clf
  plot(t,x,'.-')
  grid

%
% find all the points that are before the earthquake
%
  i_before=find(t < 2011.186);

%
% sanity check: plot the before points and make sure they're before
%
  hold on
  plot(t(i_before),x(i_before),'.')

%
% Calculate velocity for entire time series, and for just the before part
%  - print the values to the screen so we can read them and check them
%
  [vx,vy]=fit_velocity_one_GNSS(t,x);
  [vx_before,vy_before]=fit_velocity_one_GNSS(t(i_before),x(i_before));

  vx
  vx_before

%
% find the points that we'll use for co-seismic displacement
%
  i_co=find(t>2011.186 & t<2011.190);

  dx=x(i_co(2))-x(i_co(1))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION DEFINITIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function [t,x,xlocation,ylocation]=load_and_parse_one_GNSS(stationname,referenceplate)
    filename=[stationname,'.',referenceplate,'.tenv3'];

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
