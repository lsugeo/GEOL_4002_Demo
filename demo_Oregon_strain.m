clear % ALWAYS start your script be clearing the memory cache


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (down)load GNSS data, calculate horizontal velocities
%   - this part we've already done lots of times before
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Download all the data we'll use
  %
    % websave('P395.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P395.NA.tenv3');
    % websave('P396.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P396.NA.tenv3');
    % websave('P404.NA.tenv3','https://geodesy.unr.edu/gps_timeseries/IGS20/tenv3/NA/P404.NA.tenv3');

  %
  % Load and parse all the GNSS sites using a nifty for loop!
  %
    stationlist={'P395','P396','P404'};

    for k=1:3
      [T{k},X{k},Y{k},xlocation(k),ylocation(k)]=load_and_parse_one_GNSS(stationlist{k});
      [vx(k),vy(k)]=fit_velocity_one_GNSS(T{k},X{k},Y{k});
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
  % Make the time series figure
  %
    figure(1)
    clf

    for k=1:3
      subplot(211)
      plot(T{k},X{k}-X{k}(1))
      hold on
      ylabel('eastings (m)')

      subplot(212)
      plot(T{k},Y{k}-Y{k}(1))
      hold on
      ylabel('northings (m)')
    end

  %
  % plot stations and velocities on map
  %
    figure(2)
    clf
    plot(coast_lon,coast_lat)
    hold on
    quiver(xlocation,ylocation,vx,vy)
    xlim([-126,-121])
    ylim([44,50])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the strain between these 3 stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % make the "data" vector of velocities
  %
    d=[vx(1);vy(1);vx(2);vy(2);vx(3);vy(3)];
    % d=[vx(1),vy(1),vx(2),vy(2),vx(3),vy(3)];

  %
  % calculate the centroid of the triangle and dx dy values
  %
    [XUTM,YUTM]=ll2utm(ylocation,xlocation);
    xcentroid=mean(XUTM);
    ycentroid=mean(YUTM);

    dx=XUTM-xcentroid;
    dy=YUTM-ycentroid;

  %
  % make the G matrix
  %
    G = [1, 0, dx(1), dy(1),     0, -dy(1);...
         0, 1,     0, dx(1), dy(1),  dx(1);...
         1, 0, dx(2), dy(2),     0, -dy(2);...
         0, 1,     0, dx(2), dy(2),  dx(2);...
         1, 0, dx(3), dy(3),     0, -dy(3);...
         0, 1,     0, dx(3), dy(3),  dx(3)];

  %
  % calculate m!
  %
    m=G\d;

  %
  % make the Cartesian strain tensor
  %
    Exx=m(3);
    Exy=m(4);
    Eyy=m(5);

    Etensor=[Exx,Exy;Exy,Eyy];

  %
  % find the eigen values and eigen vectors
  % (the principal strains and their principal axes)
  %
    [eigenvectors,eigenvalues] = eig(Etensor);

    E1=eigenvalues(1,1);
    E2=eigenvalues(2,2);

    a1=eigenvectors(1,1);
    b1=eigenvectors(2,1);
    a2=eigenvectors(1,2);
    b2=eigenvectors(2,2);

    figure(3)
    clf
    quiver(0,0,a1*E1,b1*E1,'ShowArrowHead','off','Alignment','center')
    hold on
    quiver(0,0,a2*E2,b2*E2,'ShowArrowHead','off','Alignment','center')
    axis equal
    % plot(dx,dy,'^')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION DEFINITIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function [t,x,y,xlocation,ylocation]=load_and_parse_one_GNSS(stationname)
    filename=[stationname,'.NA.tenv3'];

    fid=fopen(filename);
    C=textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1);
    fclose(fid);  

    t=C{3};
    x=C{9};
    y=C{11};

    xlocation=C{22}(1);
    ylocation=C{21}(1);
  end

  function [vx,vy]=fit_velocity_one_GNSS(t,x,y)
    % find the actualy horizontal velocity components
    % don't bother calculting residuals because we don't need them for strain

    P=polyfit(t,x,1);
    vx=P(1); % KEEP UNITS AS m/yr ... since we'll be doing math with these...

    P=polyfit(t,y,1);
    vy=P(1); % KEEP UNITS AS m/yr ... since we'll be doing math with these...
  end


