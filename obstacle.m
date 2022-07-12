X = [4;7];
Y = [0;2];
centers = [X Y];
radii = [1;1];

figure
viscircles(centers,radii,'Color','k')
hold on
plot(0,0,'*')
hold on
plot(10,0,'*')
