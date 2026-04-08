clear

%
% Load the two scenes
%
  filenameS='S1-GUNW-D-R-021-tops-20230210_20230129-033504-00035E_00035N-PP-8473-v2_0_6.nc';
  filenameN='S1-GUNW-D-R-021-tops-20230210_20230129-033440-00036E_00037N-PP-c92c-v2_0_6.nc';

  % ncdisp(filename); % copied this to output_ncdisp.txt
  % ncdisp(filename,'/','min'); % shorter format 

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

