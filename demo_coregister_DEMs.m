clear

%
% Load the before and after DEMs that are not yet co-registered
% (don't have the same spatial extent)
% 
% NOTE: we made a handy function for this!
%

  filename1='WabashRiver_2013_ground.tif';
  filename2='WabashRiver_2017_ground.tif';

  [x1,y1,z1]=load_one_DEM(filename1);
  [x2,y2,z2]=load_one_DEM(filename2);

%
% Demonstrate the problem: why we need to co-register the DEMs
%  - make a figure with one point per pixel to help visualize
%    the difference in extents
%  - NOTE: this is really inefficient, and you won't normally
%    do this!  This is just for this demo.
%
  [X1,Y1]=meshgrid(x1,y1);
  [X2,Y2]=meshgrid(x2,y2);

  figure(1)
  clf
  plot(X1(:),Y1(:),'.')
  hold on
  plot(X2(:),Y2(:),'o')










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Definitions Start Here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [x,y,a]=load_one_DEM(filename)
    %load the file
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

    % flip the image upside down so that it is a proper map
    a=flipud(a);
  end
