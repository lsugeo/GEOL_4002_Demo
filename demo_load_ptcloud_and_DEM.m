clear
tic

%
% Load pointcloud data from a *.las or *.laz file
%  - this requires the "lidar" toolbox
%
  filename='jacksonsquare_points.laz'; % This one is 1 M points, and the renderer is slow...
  lasreader=lasFileReader(filename);
  ptcloud=readPointCloud(lasreader);

  px=ptcloud.Location(:,1);
  py=ptcloud.Location(:,2);
  pz=ptcloud.Location(:,3);

  figure(1)
  clf
  plot3(px,py,pz,'.')
  grid

  figure(2)
  clf
  scatter(px,py,5,pz)
  colorbar

  figure(3)
  clf
  scatter3(x,y,z,5,z)
  colorbar

  figure(4)
  clf
  pcshow(ptcloud)

%
% Now try the DEM
%  - this requires the "mapping" toolbox
%
  filename='jacksonsquare_output.tin.tif';
  [a,r]=readgeoraster(filename);

  % Make the x and y vectors for the DEM grid
  x1=r.XWorldLimits(1);
  x2=r.XWorldLimits(2);
  dx=r.CellExtentInWorldX;
  x=(x1+dx/2):dx:(x2-dx/2);

  y1=r.YWorldLimits(1);
  y2=r.YWorldLimits(2);
  dy=r.CellExtentInWorldY;
  y=(y1+dy/2):dy:(y2-dy/2);

  % find all the pseudo-NaNs and make them actual NaNs
  iNaNs=find(a==-9999);
  a(iNaNs)=NaN;

  figure(5)
  clf
  imagesc(x,y,a)
  colorbar

  % The image is still upside down, but we'll fix that next time!

  