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
  xlim([35.5,39])
  ylim([35.5,39])

%
% Make the big merged grid for unwrapped phase
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
    B.w(S.iy1:S.iy2,S.ix1:S.ix2)=max(S.w,B.w(S.iy1:S.iy2,S.ix1:S.ix2)); % prioritizes keeping the numbers

  %
  % plot the new big grid to make sure it makes sense
  %
    figure(2),clf,
    subplot(221)
    imagesc(B.x,B.y,B.w),axis xy,colorbar

%
% Try unwrapping your new big wrapped phase grid, using the "unwrap_phase" function
%  Syntax: UnwrappedGrid = unwrap_phase(WrappedGrid)
%
  %
  % do the actual unwrapping (this took ~35 seconds on Karen's computer)
  %
    tic
    B.u = unwrap_phase(B.w);
    toc

  %
  % Plot the unwrapped result (note how it has some issues)
  %
    subplot(222)
    imagesc(B.x,B.y,B.u),axis xy,colorbar
    colormap(jet)

%
% make the incoherent areas NaN
%
  %
  % First need to ake big grids of coherence and connected components
  %
    % coherence: pixel-by-pixel measure of how related before and after phase is
    B.c=zeros(numel(B.y),numel(B.x))*NaN; % make a big empty grid and fill it with NaNs
    B.c(N.iy1:N.iy2,N.ix1:N.ix2)=N.c;
    B.c(S.iy1:S.iy2,S.ix1:S.ix2)=max(S.c,B.c(S.iy1:S.iy2,S.ix1:S.ix2)); % prioritizes keeping the numbers

    % connected components: index ID numbers for patches of grid that were unwrapped coherently by ARIA
    B.m=zeros(numel(B.y),numel(B.x))*NaN; % make a big empty grid and fill it with NaNs
    B.m(N.iy1:N.iy2,N.ix1:N.ix2)=N.m;
    B.m(S.iy1:S.iy2,S.ix1:S.ix2)=max(S.m,B.m(S.iy1:S.iy2,S.ix1:S.ix2)); % prioritizes keeping the numbers

    % make a version of the wrapped phase that has NaNs in the incoherent areas
    B.w_with_nans=B.w; % copy the full wrapped nans grid before we start destroying data points
    B.w_with_nans(find(B.m<1))=NaN;   % This one excludes areas that ARIA couldn't unwrap (too noisy)
    B.w_with_nans(find(B.c<0.3))=NaN; % This one adds a coherence threshold for the other regions (try changing the threshold)

  %
  % plot the new wrapped grid, now with NaNs removed
  %
    subplot(223)
    imagesc(B.x,B.y,B.w_with_nans),axis xy,colorbar

%
% Try unwrapping again!
%
  %
  % actual unwrapping (this took ~24 seconds on Karen's computer)
  %
    tic
    B.u_with_nans = unwrap_phase(B.w_with_nans);
    toc

  %
  % plot the new unwrapped phase
  %
    subplot(224)
    imagesc(B.x,B.y,B.u_with_nans),axis xy,colorbar

%
% Same figure again comparing different unwrapping solutions,
% but plotted all together in a coherent colorscale
%

    figure(3),clf,
    subplot(221)
    imagesc(B.x,B.y,B.w),axis xy,colorbar

    subplot(222)
    imagesc(B.x,B.y,B.u),axis xy,colorbar
    caxis([-300,300])

    subplot(223)
    imagesc(B.x,B.y,B.w_with_nans),axis xy,colorbar

    subplot(224)
    imagesc(B.x,B.y,B.u_with_nans),axis xy,colorbar
    caxis([-300,300])
    colormap(jet)

%
% Now lets make the LOS displacement!
%
  %
  % Do the math
  %
    B.L=N.L; % radar wavelength, from the *.nc file
    % B.LOS=B.u_with_nans*B.L/4/pi; % THese two statements do the same thing!
    B.LOS=B.u_with_nans*B.L/(4*pi);

  %
  % Plot the result
  %  - recall: LOS displacement is positive if the ground moved toward the satellite,
  %    negative if the ground moved away from the satellite
  %
    figure(4),clf,
    imagesc(B.x,B.y,B.LOS),axis xy,colorbar
    colormap(jet)
    caxis([-1.5,1.5])

