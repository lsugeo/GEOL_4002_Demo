clear

%
% load the interferogram data from the netcdf file
%
  filename='S1-GUNW-A-R-064-tops-20190710_20190628-015013-36885N_35006N-PP-a1b9-v2_0_2.nc';

  % ncdisp(filename) % this would list the components included in the file

  x=ncread(filename,'/science/grids/data/longitude');
  y=ncread(filename,'/science/grids/data/latitude');
  A=ncread(filename,'/science/grids/data/amplitude')'; % take the transpose to make array oriented correctly
  C=ncread(filename,'/science/grids/data/coherence')'; % take the transpose to make array oriented correctly
  U=ncread(filename,'/science/grids/data/unwrappedPhase')'; % take the transpose to make array oriented correctly

  % make the wrapped phase array from the Unwrapped phase array
  % (i.e., divide by 2*pi but just keep the remainder)
  W=mod(U,2*pi);

%
% Plot the various interferogram components we want to see
%
  % Amplitude
  figure(1)
  clf
  imagesc(x,y,A)
  axis xy
  colorbar
  caxis([0,10000])
  colormap(gray)

  % Coherence
  figure(2)
  clf
  imagesc(x,y,C)
  axis xy
  colorbar
  caxis([0,1])

  % Unwrapped Phase and Wrapped Phase,
  % masking out the low coherence areas
  figure(3)
  clf

  ax(1)=subplot(221);
  imagesc(x,y,U)
  axis xy
  colorbar

  ax(2)=subplot(222);
  h=imagesc(x,y,W); % "h" is the handle for the image, so we can adjust it on a later line
  set(h,'AlphaData',C>0.5) % set the transparency of the image based on if it fits the Coherence threshold criteria
  axis xy
  colorbar

  ax(3)=subplot(223);
  imagesc(x,y,C)
  axis xy
  colorbar
  caxis([0,1])

  ax(4)=subplot(224);
  h2=imagesc(x,y,U);
  set(h2,'AlphaData',C>0.5)
  axis xy
  colorbar
  
  colormap(jet)
  linkaxes(ax,'xy')
