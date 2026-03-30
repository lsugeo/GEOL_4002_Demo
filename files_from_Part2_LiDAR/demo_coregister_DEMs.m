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
  % [X1,Y1]=meshgrid(x1,y1);
  % [X2,Y2]=meshgrid(x2,y2);

  % figure(1)
  % clf
  % plot(X1(:),Y1(:),'.')
  % hold on
  % plot(X2(:),Y2(:),'o')

%
% Plot the before and after grids
%
  CA=[103,109]; % the color axis extent for these figures

  figure(2)
  clf
  ax(1)=subplot(121);
  imagesc(x1,y1,z1)
  axis xy
  axis equal
  colorbar
  title('before')
  caxis(CA)

  ax(2)=subplot(122);
  imagesc(x2,y2,z2)
  axis xy
  axis equal
  colorbar
  title('after')
  caxis(CA)

  linkaxes(ax,'xy')

%
% determine the extent of the overlap
%
  ytop=min(max(y1),max(y2));

  % made up numbers because Karen is lazy
  ybottom=4184500;
  xleft=404000;
  xright=408000;

%
% find the indices of rows and colums within
% the overlapping region
%
  i1=find(y1<ytop & y1>ybottom);
  j1=find(x1<xright & x1>xleft);

  i2=find(y2<ytop & y2>ybottom);
  j2=find(x2<xright & x2>xleft);

%
% Cut the DEM to the smaller area
%
  z1_smaller=z1(i1,j1);
  z2_smaller=z2(i2,j2);

  x_smaller=x1(j1);
  y_smaller=y1(i1);

%
% Plot the new ones!
% (plowing over the old figure)
%
  figure(2)
  clf
  ax(1)=subplot(121);
  imagesc(x_smaller,y_smaller,z1_smaller)
  axis xy
  axis equal
  colorbar
  title('before - cut to coregistered size')
  caxis(CA)

  ax(2)=subplot(122);
  imagesc(x_smaller,y_smaller,z2_smaller)
  axis xy
  axis equal
  colorbar
  title('after - cut to coregistered size')
  caxis(CA)

  linkaxes(ax,'xy')

%
% Difference the DEMs and plot them
%
  z_difference=z2_smaller-z1_smaller;

  figure(3)
  clf
  ax(3)=subplot(121);
  imagesc(x_smaller,y_smaller,z_difference)
  axis xy
  axis equal
  colorbar
  title('after-before difference')
  colormap(flipud(cpolar)) % flip the colors to match fig 5c
  caxis([-2,2])

  linkaxes(ax,'xy')


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
