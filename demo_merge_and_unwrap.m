clear

%
% Load the two scenes
%  - note, this time we chose to flip the directions of both the latitude values
%    and the grids in the latitude direction.  This is important to make the
%    indexing math below work out properly.
%
  filenameS='S1-GUNW-D-R-021-tops-20230210_20230129-033504-00035E_00035N-PP-8473-v2_0_6.nc';
  filenameN='S1-GUNW-D-R-021-tops-20230210_20230129-033440-00036E_00037N-PP-c92c-v2_0_6.nc';

  % ncdisp(filenameN) % full info on file contents
  % ncdisp(filenameN,'/','min') % shorter info on file contents

  S.x=ncread(filenameS,'/science/grids/data/longitude');
  S.y=flipud(ncread(filenameS,'/science/grids/data/latitude'));
  S.u=flipud(ncread(filenameS,'/science/grids/data/unwrappedPhase')'); % unwrapped phase (radians)
  S.c=flipud(ncread(filenameS,'/science/grids/data/coherence')');
  S.m=flipud(ncread(filenameS,'/science/grids/data/connectedComponents')');
  S.a=flipud(ncread(filenameS,'/science/grids/data/amplitude')'); % amplotude (watts)
  S.L=ncread(filenameS,'/science/radarMetaData/wavelength'); % wavelength (m)

  N.x=ncread(filenameN,'/science/grids/data/longitude');
  N.y=flipud(ncread(filenameN,'/science/grids/data/latitude'));
  N.u=flipud(ncread(filenameN,'/science/grids/data/unwrappedPhase')'); % unwrapped phase (radians)
  N.c=flipud(ncread(filenameN,'/science/grids/data/coherence')');
  N.m=flipud(ncread(filenameN,'/science/grids/data/connectedComponents')');
  N.a=flipud(ncread(filenameN,'/science/grids/data/amplitude')');
  N.L=ncread(filenameN,'/science/radarMetaData/wavelength'); % wavelength (m)

%
% re-wrap the phase for each scene
%
  N.w=mod(N.u,2*pi);
  S.w=mod(S.u,2*pi);

%
% Plot the individual scenes together
% (make the NaNs transparent so you can see both of them)
%
  figure(1),clf
  ax(1)=subplot(1,5,1);
    h=imagesc(N.x,N.y,N.u);set(h,'alphadata',~isnan(N.u)),hold on,
    h=imagesc(S.x,S.y,S.u);set(h,'alphadata',~isnan(S.u)),axis xy,colorbar,title('unwrappedPhase')
    set(ax(1),'colormap',jet)
  ax(2)=subplot(1,5,2);
    h=imagesc(N.x,N.y,N.w);set(h,'alphadata',~isnan(N.w)),hold on,
    h=imagesc(S.x,S.y,S.w);set(h,'alphadata',~isnan(S.w)),axis xy,colorbar,title('wrappedPhase')
    set(ax(2),'colormap',jet)
  ax(3)=subplot(1,5,3);
    h=imagesc(N.x,N.y,N.c);set(h,'alphadata',~isnan(N.c)),hold on,
    h=imagesc(S.x,S.y,S.c);set(h,'alphadata',~isnan(S.c)),axis xy,colorbar,title('coherence'),caxis([0,1])
  ax(4)=subplot(1,5,4);
    h=imagesc(N.x,N.y,N.m);set(h,'alphadata',~isnan(N.m)),hold on,
    h=imagesc(S.x,S.y,S.m);set(h,'alphadata',~isnan(S.m)),axis xy,colorbar,title('connectedComponents')
  ax(5)=subplot(1,5,5);
    h=imagesc(N.x,N.y,N.a);set(h,'alphadata',~isnan(N.a)),hold on,
    h=imagesc(S.x,S.y,S.a);set(h,'alphadata',~isnan(S.a)),axis xy,colorbar,title('amplitude'),caxis([0,1e4])
    set(ax(5),'colormap',gray)

  linkaxes(ax,'xy')

%
% Make the big merged grid!
%
  %
  % figure out the size of the new big grid
  %
    x1=min([N.x;S.x]);
    x2=max([N.x;S.x]);
    y1=min([N.y;S.y]);
    y2=max([N.y;S.y]);

  %
  % make an empty big grid of the right size
  %
    dx=1/3600*3; % 3 arcsecond spacing (recall, 1 degree of lat/lon = 3600 arcseconds)
    dy=1/3600*3; % 3 arcsecond spacing


    B.x=[x1:dx:(x2+dx/2)]'; % take the transpose to make it a single column, rather than a row
    B.y=[y1:dy:(y2+dy/2)]';

    B.w=zeros(numel(B.y),numel(B.x))*NaN; % make a big empty grid and fill it with NaNs

  %
  % Figure out which point in new grid corresponds to each point in old grid.
  % For example:
  %  - take the full set of "big" longitude values
  %  - subtract the edge longitude value from one of the smaller grids
  %  - take the absolute value of the difference, so that the one closest to
  %    zero now has the smallest difference value
  %  - take the minimum of those absolute difference values, but instead of
  %    saving the "minimum value", save the index of the point where the
  %    minimum value occurs
  %
    [~,S.ix1]=min(abs(B.x-S.x(1)));
    [~,S.ix2]=min(abs(B.x-S.x(end)));
    [~,S.iy1]=min(abs(B.y-S.y(1)));
    [~,S.iy2]=min(abs(B.y-S.y(end)));

    [~,N.ix1]=min(abs(B.x-N.x(1)));
    [~,N.ix2]=min(abs(B.x-N.x(end)));
    [~,N.iy1]=min(abs(B.y-N.y(1)));
    [~,N.iy2]=min(abs(B.y-N.y(end)));

  %
  % Fill in the Big grid!
  %  - you should add the South grid on your own
  % BONUS: notice an extra wedge of NaNs where they shouldn't be?
  %    When adding the south data, try taking the maximum value
  %    between the grid that exists in those locations and the
  %    new data you're adding in there
  %
    B.w(N.iy1:N.iy2,N.ix1:N.ix2)=N.w;

  %
  % plot the new big grid to make sure it makes sense
  %
    figure(2),clf,
    imagesc(B.x,B.y,B.w),axis xy,colorbar

  %
  % Try unwrapping your new big wrapped phase grid, using the "unwrap_phase" function
  %  Syntax: UnwrappedGrid = unwrap_phase(WrappedGrid)
  %

  %
  % BONUS BONUS: Try masking some of the data in B.w to make the incoherent data into NaNs.
  %  - actually change the values at those locations to NaNs, 
  %    don't just make them transparent in the figure
  %  - try unwrapping the new array with NaNs again (the unwrapping algorithm will ignore the NaNs)
  %    does the answer make more sense?
  %

  %
  % BONUS BONUS BONUS:
  %  - Once you have unwrapped phase, and you know the wavelength of the radar waves,
  %    (we loaded from the netcdf file), try converting from phase change to
  %    Line of Sight displacement (we have an equation for this in our notes)
  % 

