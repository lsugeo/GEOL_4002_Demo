clear

%
% Make an okada model of displacement due to disolocation on a plane embeded within an
% elastic halfspace, and calculate the modeled line-of-sight displacement for comparison 
% with unwrapped interferograms.
%

%
% Load the interferogram (observations)
%  - depending on which version of this file you downloaded, it might have either name.
%
  filename='S1-GUNW-D-R-071-tops-20190716_20190622-135212-36450N_34472N-PP-7915-v2_0_2.nc';
  % filename='S1-GUNW-D-R-071-tops-20190716_20190622-135200-00119W_00035N-PP-382a-v3_0_1.nc';
  

  D1.x=ncread(filename,'/science/grids/data/longitude');
  D1.y=flipud(ncread(filename,'/science/grids/data/latitude'));
  D1.u=flipud(ncread(filename,'/science/grids/data/unwrappedPhase')'); % unwrapped phase (radians)
  D1.c=flipud(ncread(filename,'/science/grids/data/coherence')');
  D1.m=flipud(ncread(filename,'/science/grids/data/connectedComponents')');
  D1.a=flipud(ncread(filename,'/science/grids/data/amplitude')'); % amplotude (watts)
  D1.L=ncread(filename,'/science/radarMetaData/wavelength'); % wavelength (m)
  D1.w=mod(D1.u,2*pi);

%
% Cut the grids so they focus on our area of interest
%
  %
  % Define the edges of our area of interest
  %
    x1=-118.3; % left edge
    x2=-117.0; % right edge
    y1=35.2;   % bottom edge
    y2=36.3;   % top edge

  %
  % determine the indices of the edges of our area of interest
  %
    [~,D1.ix1]=min(abs(D1.x-x1));
    [~,D1.ix2]=min(abs(D1.x-x2));
    [~,D1.iy1]=min(abs(D1.y-y1));
    [~,D1.iy2]=min(abs(D1.y-y2));

  %
  % make the smaller grids, and put them in the structural array "Observations"
  %  - note that the longitude and latitude vectors ("x" and "y") we make here will be 
  %    used for multiple grids, so we're storing the outside of the structural array.
  %    Same thing goes for the radar wavelenth "L"
  %
    dx=1/3600*3; % 3 arcsecond spacing (recall, 1 degree of lat/lon = 3600 arcseconds)
    dy=1/3600*3; % 3 arcsecond spacing
    x=[x1:dx:x2]'; % take the transpose to make it a single column, rather than a row
    y=[y1:dy:y2]';
    L=D1.L;

    Observations.u=D1.u(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    Observations.c=D1.c(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    Observations.m=D1.m(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    Observations.a=D1.a(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    Observations.w=D1.w(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    
    % make the line of sight displacement
    Observations.LOS=Observations.u*L/(4*pi);

%
% Define the parameters we'll use for our model
% THIS IS PROBABLY THE ONLY THING YOU'LL NEED TO CHANGE TO DO THIS HOMEWORK.
%  - NOTE: these starting values will not fit with the ridgecrest earthquake!
%
  %
  % center location of the fault plane
  %
    x0=-118;
    y0=36;

  %
  % fault/plane orientation info
  %
    STRIKE=85;  % degrees east of north
    DIP=10;     % degress down from horizontal

  %
  % fault/plane dimensions and location
  %
    DEPTH=10;   % center of plane, km below the surface
    LENGTH=40;  % along strike length of plane, km
    WIDTH=18;   % along dip width of plane, km

  %
  % amount and direction of motion on fault/plane
  %
    RAKE=95;    % direction of in-plane hanging wall motion, in deg CCW from strike
    SLIP=8;     % how much in-plane slip (m)
    OPEN=0.0;   % how much opening (+) or closing (-) of the plane (m)

%
% Make the model displacement on the same grid locations as the observations
%  - calculate the east, north, and verticcal displacement
%  - then calculated the associated line-of-sight deformation for both
%    ascending and descending satellite tracks
%
  %
  % make grids that give the location of each pixel in km relative to
  % the center points (x0 and y0) chosen above
  %  - NOTE: 1 degree of latitude = 111.1 km, everywhere.
  %  - NOTE: 1 degree of longitude = 111.1 km at equator, but gets narrower at higher latitudes.
  %    Mathematically, the change in width is accomplished by scaling by the cosine of the latitude.
  %    Our grid is small enough that we can just use a signle representative latitude number for this.
  %
    % the longitude and latitude value of every single pixel
    [xmesh,ymesh]=meshgrid(x,y);

    % the location in relative km of every single pixel
    ymesh_km=(ymesh-y0)*111.1;
    xmesh_km=(xmesh-x0)*111.1*cosd(y0);

  %
  % Use the Okada solutions to determine expected surface displacement
  %  in East, North, and Vertical directions (m)
  %
    [Model.E,Model.N,Model.Z] = okada85(xmesh_km,ymesh_km,DEPTH,STRIKE,DIP,LENGTH,WIDTH,RAKE,SLIP,OPEN);

  %
  % Resolve displacements from East/North/Vertical directions into 
  % line-of-sight direction.
  %  - Note: actual radar geometry varies a bit across the scene,
  %    but using a single number is close enough for our purposes.
  %
    %
    % define radar geometry
    %  - incidence angle is angle from vertical
    %  - heading angle is which wat the satellite is going (different for ascending vs descending)
    %
      IncAngle=39;               % degrees from vertical - ranges from 32 - 46, so this is a good average number
      HeadAngle_ascending=-10;   % ascending flight direction, in deg E of N
      HeadAngle_descending=-170; % descending flight direction, in deg E of N

    %
    % make the unit vector components for the line-of-sight direction
    %  - pointing in the direction from the ground to the satellite
    %
      px_a=-sind(IncAngle)*cosd(HeadAngle_ascending);
      py_a=sind(IncAngle)*sind(HeadAngle_ascending);
      pz_a=cosd(IncAngle);

      px_d=-sind(IncAngle)*cosd(HeadAngle_descending);
      py_d=sind(IncAngle)*sind(HeadAngle_descending);
      pz_d=cosd(IncAngle);

    %
    % calculate line of sight displacements for each direction
    %  - NOTE: displacement in LOS direction is dot product of 3D displacement with LOS unit vector
    %
      Model.LOS_ascending=Model.E*px_a+Model.N*py_a+Model.Z*pz_a;
      Model.LOS_descending=Model.E*px_d+Model.N*py_d+Model.Z*pz_d;

    %
    % for visualization, calculate the wrapped phase associated with each LOS displacement
    %
      Model.w_ascending=mod(Model.LOS_ascending/L*4*pi,2*pi);
      Model.w_descending=mod(Model.LOS_descending/L*4*pi,2*pi);

%
% Compare the observations and the model
%
  %
  % subtract the model predictions from the observations at each point
  %
    CompareMisfit.LOS=Observations.LOS-Model.LOS_descending;

  %
  % for visualization, calculate the wrapped phase associated with difference in LOS displacement
  %
    CompareMisfit.w=mod(CompareMisfit.LOS/L*4*pi,2*pi);

  %
  % Calcualte the RMS value of the misfit, ignoring any NaN points
  %
    CompareMisfit.RMS=rms(CompareMisfit.LOS(:),'omitnan');

%
% Plot the model predictions, in detail
%  - NOTE: I added a line to each plot that ensures it plots
%    with the correct aspect ratio (i.e., the angles are fixed and accurate)
%
  figure(1),clf
    subplot(331),
      imagesc(x,y,Model.E),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled east (m)')
      caxis([-1,1]),
    subplot(332),
      imagesc(x,y,Model.N),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled north (m)')
      caxis([-1,1]),
    subplot(333),
      imagesc(x,y,Model.Z),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled vertical (m)')
      caxis([-1,1]),
    subplot(334),
      imagesc(x,y,Model.w_ascending),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled wrapped phase (ascending)')
    subplot(335),
      imagesc(x,y,Model.LOS_ascending),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled LOS (ascending) (m)')
      caxis([-1,1]),
      hold on,plot(x0,y0,'k*','linewidth',1)
    subplot(337),
      imagesc(x,y,Model.w_descending),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled wrapped phase (descending)')
    subplot(338),
      imagesc(x,y,Model.LOS_descending),
      axis xy,
      set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
      colorbar,
      title('modeled LOS (descending) (m)')
      caxis([-1,1]),
      hold on,plot(x0,y0,'k*','linewidth',1)
    colormap(jet)

%
% Plot the observations, model, and misfit all together
%
  figure(2),clf
  ax(1)=subplot(321);
    imagesc(x,y,Observations.w,'alphadata',~isnan(Observations.w)),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
    colorbar,
    title('observed wrapped phase'),
  ax(2)=subplot(322);
    imagesc(x,y,Observations.LOS,'alphadata',~isnan(Observations.LOS)),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
    colorbar,
    title('observed line of sight displacement (m)'),
    caxis([-1,1])
    hold on,plot(x0,y0,'k*','linewidth',1),
  ax(3)=subplot(323);
    imagesc(x,y,Model.w_descending),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
    colorbar,
    title('modeled descending wrapped phase')
  ax(4)=subplot(324);
    imagesc(x,y,Model.LOS_descending),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
    colorbar,
    title('modeled descending LOS displacement (m)')
    caxis([-1,1])
    hold on,plot(x0,y0,'k*','linewidth',1),
  ax(5)=subplot(325);
    imagesc(x,y,CompareMisfit.w,'alphadata',~isnan(CompareMisfit.w)),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
     colorbar,
    title('difference wrapped phase'),
  ax(6)=subplot(326);
    imagesc(x,y,CompareMisfit.LOS,'alphadata',~isnan(CompareMisfit.LOS)),
    axis xy,
    set(gca,'dataaspectratio',[1/cosd(y0),1,1]),
    colorbar,
    title({'differce LOS displacement (m)';['RMS = ',num2str(CompareMisfit.RMS),' m']}),
    caxis([-1,1])
    hold on,plot(x0,y0,'k*','linewidth',1),
  colormap(jet)
  linkaxes(ax,'xy')



