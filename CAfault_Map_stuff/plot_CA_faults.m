clear

%
% Load the map data
%
  faults=load('CFM7.0_traces.xy');
  blind_faults=load('CFM7.0_blind.xy');

%
% Plots map stuff
%
  figure(1),clf
  plot(faults(:,1),faults(:,2),'k')
  hold on
  plot(blind_faults(:,1),blind_faults(:,2),'k:')

