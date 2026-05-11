clear

%
% Load the two scenes
%  - these cover approximately the same location, but different times
%  - both are descending: remember, ascending and descending scenes must be treated separately.
%
  filenameD1='S1-GUNW-D-R-071-tops-20190716_20190622-135212-36450N_34472N-PP-7915-v2_0_2.nc';
  filenameD2='S1-GUNW-D-R-071-tops-20190728_20190704-135213-36450N_34472N-PP-9181-v2_0_2.nc';

  % ncdisp(filenameD2) % full info on file contents
  % ncdisp(filenameD2,'/','min') % shorter info on file contents

  D1.x=ncread(filenameD1,'/science/grids/data/longitude');
  D1.y=flipud(ncread(filenameD1,'/science/grids/data/latitude'));
  D1.u=flipud(ncread(filenameD1,'/science/grids/data/unwrappedPhase')'); % unwrapped phase (radians)
  D1.c=flipud(ncread(filenameD1,'/science/grids/data/coherence')');
  D1.m=flipud(ncread(filenameD1,'/science/grids/data/connectedComponents')');
  D1.a=flipud(ncread(filenameD1,'/science/grids/data/amplitude')'); % amplotude (watts)
  D1.L=ncread(filenameD1,'/science/radarMetaData/wavelength'); % wavelength (m)

  D2.x=ncread(filenameD2,'/science/grids/data/longitude');
  D2.y=flipud(ncread(filenameD2,'/science/grids/data/latitude'));
  D2.u=flipud(ncread(filenameD2,'/science/grids/data/unwrappedPhase')'); % unwrapped phase (radians)
  D2.c=flipud(ncread(filenameD2,'/science/grids/data/coherence')');
  D2.m=flipud(ncread(filenameD2,'/science/grids/data/connectedComponents')');
  D2.a=flipud(ncread(filenameD2,'/science/grids/data/amplitude')');
  D2.L=ncread(filenameD2,'/science/radarMetaData/wavelength'); % wavelength (m)
  
  % wavelength is always the same, so let's just give it it's own variable name.
  L=ncread(filenameD2,'/science/radarMetaData/wavelength'); % wavelength (m)

  %
  % re-wrap the phase for each scene
  %
    D1.w=mod(D1.u,2*pi);
    D2.w=mod(D2.u,2*pi);

%
% Plot the individual scenes together
%   - plot both the wrapped and unwrapped (differences are more obvious in wrapped)
%   - Can you see the differences between the scenes caused by atmosphere/troposphere?
%
  figure(1),clf
  ax(1)=subplot(2,2,1);
    imagesc(D1.x,D1.y,D1.w,'alphadata',~isnan(D1.u)),axis xy,colorbar,title('2019-06-22 to 2019-07-16')
  ax(2)=subplot(2,2,2);
    imagesc(D2.x,D2.y,D2.w,'alphadata',~isnan(D2.u)),axis xy, colorbar,title('2019-07-04 to 2019-07-28')
  ax(3)=subplot(2,2,3);
    imagesc(D1.x,D1.y,D1.u,'alphadata',~isnan(D1.w)),axis xy,colorbar,title('2019-06-22 to 2019-07-16')
  ax(4)=subplot(2,2,4);
    imagesc(D2.x,D2.y,D2.u,'alphadata',~isnan(D2.w)),axis xy, colorbar,title('2019-07-04 to 2019-07-28')
  
  linkaxes(ax,'xy')
  colormap(jet)

%
% Make the grids the same size, so we can do math with them.
%  - this time, we'll define a smaller grid and cut both scenes to those bounds
%
  %
  % define the edges of the new smaller-than-both-originals grid
  %  - just pick good values from looking at the map
  %
    x1=-118.5; % left edge
    x2=-116.5; % right edge
    y1=35.3;   % bottom edge
    y2=36.2;   % top edge

  %
  % define the new x and y vectors we'll need for the new grid
  %
    dx=1/3600*3; % 3 arcsecond spacing (recall, 1 degree of lat/lon = 3600 arcseconds)
    dy=1/3600*3; % 3 arcsecond spacing


    D1_smaller.x=[x1:dx:(x2+dx/2)]'; % take the transpose to make it a single column, rather than a row
    D1_smaller.y=[y1:dy:(y2+dy/2)]';

    % second new grid has the same dimensions
    D2_smaller.x=D1_smaller.x;
    D2_smaller.y=D1_smaller.y;

  %
  % Figure out which point in old grid corresponds to each point in new grid.
  %  - this is similar to what we did before when merging two slightly overlapping
  %    grids into a new larger grid.
  %
    [~,D1.ix1]=min(abs(D1.x-x1));
    [~,D1.ix2]=min(abs(D1.x-x2));
    [~,D1.iy1]=min(abs(D1.y-y1));
    [~,D1.iy2]=min(abs(D1.y-y2));

    [~,D2.ix1]=min(abs(D2.x-x1));
    [~,D2.ix2]=min(abs(D2.x-x2));
    [~,D2.iy1]=min(abs(D2.y-y1));
    [~,D2.iy2]=min(abs(D2.y-y2));

  %
  % Cut the original grids to make the smaller ones,
  % using the indices we figured out above
  %  - make smaller versions of all the grids we'll want
  %  - BONUS: make smaller versions of coherence and connected components
  %
    D1_smaller.w=D1.w(D1.iy1:D1.iy2,D1.ix1:D1.ix2);
    D1_smaller.u=D1.u(D1.iy1:D1.iy2,D1.ix1:D1.ix2);

    D2_smaller.w=D2.w(D2.iy1:D2.iy2,D2.ix1:D2.ix2);
    D2_smaller.u=D2.u(D2.iy1:D2.iy2,D2.ix1:D2.ix2);

  %
  % plot the new smaller grids to make sure they make sense
  %  - BONUS: use coherence and connected components to mask out the incoherent areas of each
  %
    figure(2),clf
    ax2(1)=subplot(2,2,1);
      imagesc(D1_smaller.x,D1_smaller.y,D1_smaller.w,'alphadata',~isnan(D1_smaller.u)),axis xy,colorbar,title('2019-06-22 to 2019-07-16')
    ax2(2)=subplot(2,2,2);
      imagesc(D2_smaller.x,D2_smaller.y,D2_smaller.w,'alphadata',~isnan(D2_smaller.u)),axis xy, colorbar,title('2019-07-04 to 2019-07-28')
    ax2(3)=subplot(2,2,3);
      imagesc(D1_smaller.x,D1_smaller.y,D1_smaller.u,'alphadata',~isnan(D1_smaller.w)),axis xy,colorbar,title('2019-06-22 to 2019-07-16')
    ax2(4)=subplot(2,2,4);
      imagesc(D2_smaller.x,D2_smaller.y,D2_smaller.u,'alphadata',~isnan(D2_smaller.w)),axis xy, colorbar,title('2019-07-04 to 2019-07-28')
    
    linkaxes(ax2,'xy')
    colormap(jet)

%
% HOMEWORK STARTS HERE:
%  1) "stack" the unwrapped phase, aka take the average of the two grids
%     1a) it's simplest to just do the arithmatic, i.e. add them and divide by two
%     1b) re-wrap the new average phase, just because it's easier to see the differences that way
%     1c) Plot the stacked grid in unwrapped and wrapped phase... (how) does it look different from
%         the original individual interferograms?
%
%  2) BONUS: subtract the new "average" phase from each original individual interferogram.
%     This should allow you to see the isolated impact of all the non-deformation parts
%     (mostly atmosphere/troposphere, maybe some ionosphere, maybe other deformation during that time)
%     2a) again, it's simplest to just do the arithmatic, i.e. mean grid minus original grid
%     2b) be sure to plot the resulting grids, and think about what they look like
%         (might want to also re-wrap them, but might not need to.)
%