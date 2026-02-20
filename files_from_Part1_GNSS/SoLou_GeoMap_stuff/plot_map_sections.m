clear

geo_Hol_river=load('Alluvium_Holocene.xy');
geo_Plio=load('CitronelleWillis_Pliocene.xy');
geo_Hol_coast=load('Coastal_Holocene.xy');
geo_Pleist_E=load('Terraces_Pleistocene_East.xy');
geo_Pleist_W=load('Terraces_Pleistocene_West.xy');

marsh=load('approximate_marsh.xy');

% Plots them as lines

figure(1),clf
plot(geo_Hol_river(:,1),geo_Hol_river(:,2)),hold on
plot(geo_Hol_coast(:,1),geo_Hol_coast(:,2)),
plot(geo_Pleist_W(:,1),geo_Pleist_W(:,2)),
plot(geo_Pleist_E(:,1),geo_Pleist_E(:,2)),
plot(geo_Plio(:,1),geo_Plio(:,2)),
plot(marsh(:,1),marsh(:,2)),

% plots them as filled in shapes 
% - you can change the colors and transparencies using 
%   options for "fill" command, or you can change them in inkscape
%
figure(2),clf
fill(geo_Hol_river(:,1),geo_Hol_river(:,2),'g'),hold on
fill(geo_Hol_coast(:,1),geo_Hol_coast(:,2),'c'),
fill(geo_Pleist_W(:,1),geo_Pleist_W(:,2),'y'),
fill(geo_Pleist_E(:,1),geo_Pleist_E(:,2),'y'),
fill(geo_Plio(:,1),geo_Plio(:,2),'r'),

figure(3),clf
fill(marsh(:,1),marsh(:,2),'k','facealpha',0.3), % plots the marshes a bit transparent
