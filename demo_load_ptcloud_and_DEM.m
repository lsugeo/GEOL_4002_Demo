clear
tic

%
% Load pointcloud data from a *.las or *.laz file
%  - this requires the "lidar" toolbox
%
  filename='jacksonsquare_points.laz'; % This one is 1 M points, and the renderer is slow...
  lasreader=lasFileReader(filename);
  ptcloud=readPointCloud(lasreader);





%
% Now try the DEM
%  - this requires the "mapping" toolbox
%
  filename='jacksonsquare_output.tin.tif';
  [a,r]=readgeoraster(filename);

  