clear

%
% Load the map data
%
  caldera=load('Caldera.Main640ka.xy');
  dome_ML=load('MallardLakeDome.xy');
  dome_SC=load('SourCreekDome.xy');
  YLake_1=load('Shoreline.YLake.xy');
  YLake_2=load('Shoreline.Dot.xy');
  YLake_3=load('Shoreline.Frank.xy');
  YLake_4=load('Shoreline.Stevenson.xy');
  YNP_outline=load('YNPoutline.xy');
  YNP_roads=load('YNProads.xy');
  river_Yellowstone=load('YNPyellstriver.xy');
  river_Firehole=load('FireholeRiver.xy');

%
% Plots map stuff
%
  figure(1),clf
  plot(caldera(:,1),caldera(:,2),'--'),hold on
  plot(dome_ML(:,1),dome_ML(:,2),':'),
  plot(dome_SC(:,1),dome_SC(:,2),':'),
  plot(YLake_1(:,1),YLake_1(:,2),'b'),
  plot(YLake_2(:,1),YLake_2(:,2),'k'),
  plot(YLake_3(:,1),YLake_3(:,2),'k'),
  plot(YLake_4(:,1),YLake_4(:,2),'k'),
  plot(YNP_outline(:,1),YNP_outline(:,2),'k'),
  plot(YNP_roads(:,1),YNP_roads(:,2),'r'),
  plot(river_Yellowstone(:,1),river_Yellowstone(:,2),'b'),
  plot(river_Firehole(:,1),river_Firehole(:,2),'b'),
