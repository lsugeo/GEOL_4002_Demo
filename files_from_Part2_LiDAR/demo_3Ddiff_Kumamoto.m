clear
fprintf([datestr(now),'\n']) % keep track of total time

%
% !!!! THESE DATA FILES ARE TOO BIG TO GO ON GITHUB !!!!
% You'll need to download Kumamoto_examples.zip from moodle,
% and uncompress ("extract") the files in order to use them.
% Adjust the "filename" parameters below if you need to.
%

%
% Read in point cloud data
%  - this takes ~15 seconds on Karen's computer
%
  tic % start the timer for loading the data
  filename='Kumamoto_example/comp_points_before.laz'; % This one is 6 M points
  lasreader=lasFileReader(filename);
  ptcloud=readPointCloud(lasreader);
  pre_xyz=ptcloud.Location;
  Npre=ptcloud.Count;


  filename='Kumamoto_example/ref_points_after.laz'; % This one is 10 M points
  lasreader=lasFileReader(filename);
  ptcloud=readPointCloud(lasreader);
  post_xyz=ptcloud.Location;
  Npost=ptcloud.Count;


  pre_x=pre_xyz(:,1);
  pre_y=pre_xyz(:,2);
  pre_z=pre_xyz(:,3);

  post_x=post_xyz(:,1);
  post_y=post_xyz(:,2);
  post_z=post_xyz(:,3);
  toc % stop the timer for loading the data

%
% visualize the point clouds
%  - tip: for a quicker, less memory intensive ways to view these,
%    don't plot them all, just pick a random subset!
%
  isubset_pre=randi(Npre,10000,1); % pick 10,000 points to plot from the before data
  isubset_post=randi(Npost,10000,1); % pick 10,000 points to plot from the after data

  figure(1),clf,
  scatter3(pre_x(isubset_pre),pre_y(isubset_pre),pre_z(isubset_pre),5,'k','filled'),
  hold on,
  scatter3(post_x(isubset_post),post_y(isubset_post),post_z(isubset_post),5,'r','filled')
  legend({'before','after'})
  title(['plotting 10,000 points out of ',num2str(Npre),'/',num2str(Npost)])

%
% set parameters for the differencing windows
% With this set of paraemeters, the entire thing took ~40 seconds to run on Karen's computer
%
  grd=200; % Grid spacing in meters; make equal to sz if time allows 
  sz=25;   % Differencing window size in meters
  margin=5; % Additional dimension of post-earthquake window. Must be larger than the expect surface displacement

%
% Find the "core points" in the centers of the grid cells where we want to independently
% calculate the displacemene between the two point clouds
%
  grid_x_points=[min(pre_x+grd/2):grd:max(pre_x)]; % defines the center of the grid points in 1D each
  grid_y_points=[min(pre_y+grd/2):grd:max(pre_y)];

  [core_x,core_y]=meshgrid(grid_x_points,grid_y_points); % make the center of each of the grid cells

  core_x=core_x(:); % make the grid cell centers into a single list of points
  core_y=core_y(:);


%
% ACTUAL CALCULATIONS START HERE
% loop over grid sections to perform ICP
%
  for i=1:length(core_x)
    %
    % This is the center of the grid point in question
    %
      x0=core_x(i);
      y0=core_y(i);
     
    %
    % find the set of points that are within the specified window size
    % around the core point. (the after gets a slightly larger window)
    %
      ib=find(pre_x>x0-sz/2&pre_x<x0+sz/2&pre_y>y0-sz/2&pre_y<y0+sz/2);
      
      sz_a=sz+2*margin;
      ia=find(post_x>x0-sz_a/2&post_x<x0+sz_a/2&post_y>y0-sz_a/2&post_y<y0+sz_a/2);

    %
    % shift (0,0,0) to lie at the center of the grid 
    %
      xmean=mean(pre_x(ib));
      ymean=mean(pre_y(ib));
      zmean=mean(pre_z(ib));

    %
    % get the before and after datasets in the right format:
    %
      clear q_before p_after % clear these out before each run, because each set of points is a different length
      q_before(1,:)=pre_x(ib)-xmean;
      q_before(2,:)=pre_y(ib)-ymean;
      q_before(3,:)=pre_z(ib)-zmean;

      p_after(1,:)=post_x(ia)-xmean;
      p_after(2,:)=post_y(ia)-ymean;
      p_after(3,:)=post_z(ia)-zmean;

    %
    % Perform the actual iterative closest point differencing
    % (requires icp.m file)
    %
    % Usage: [TR, TT, ER, t] = icp(p_after,q_before,'Minimize','plane');
    % Output:
    %  - TR: Rotation
    %  - TT: Displacement 
    %  - ER: RMS error after each rotation
    %  - t: Calculations time per interation 
    % (we mostly just care about displacement)
    %
      [~,translation] = icp(p_after,q_before,'Minimize','plane');

    %
    % store the results in a simple way: single Nx5 array
    %
      results(i,:) =[core_x(i) core_y(i) translation'];
  
  %
  % Optionally, plot the results for each grid cell, one at a time
  %  - the "pause" below will pause after the figure is made,
  %    and won't continue until you press any key.
  %  - This is useful to check your understanding, but unhelpful
  %    once you're ready to calculate the entire grid.
  %    Comment/Uncomment these lines as needed!
  %
    % figure(2),clf,
    %   scatter3(q_before(1,:),q_before(2,:),q_before(3,:),5,'k','filled')          
    %   hold on
    %   scatter3(p_after(1,:),p_after(2,:),p_after(3,:),5,'r','filled')

    %   i_subset=randi(length(q_before),40,1); % just plot arrows at at few of them
    %   quiver3(q_before(1,i_subset)',q_before(2,i_subset)',q_before(3,i_subset)',...
    %           translation(1)*ones(size(i_subset)),translation(2)*ones(size(i_subset)),translation(3)*ones(size(i_subset)),...
    %           0,'b','linewidth',1),

    %   legend('before','after','change')
    %   title({['grid cell centered at ',num2str(core_x(i)),', ',num2str(core_y(i))];...
    %     ['displacement ',num2str(translation(1),'%0.2f'),' m N, ',num2str(translation(2),'%0.2f'),' m E, ',num2str(translation(3),'%0.2f'),' m up, ']})
    % pause

%
% End of loop over the grid
%
  end

%
% plot differencing results 
%
  figure(3),clf
  quiver(results(:,1),results(:,2),results(:,3),results(:,4),'k','LineWidth',1);
  hold on 
  scatter(results(:,1),results(:,2),45,results(:,5),'filled');
  axis equal,
  colorbar,
  caxis([-1,1]),
  colormap(cpolar)


fprintf([datestr(now),'\n']) % keep track of total time
