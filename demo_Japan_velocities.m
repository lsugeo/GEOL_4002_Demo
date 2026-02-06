clear % ALWAYS start your script be clearing the memory cache


%
% Download the data directly from the source 
% (note the station name and reference frame in the URL)
%
  websave('J175.OK.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/OK/J175.OK.tenv3');













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
