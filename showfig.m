function showfig( v,t )
% figure;
h1 = trisurf(t,v(:,1),v(:,2),v(:,3),1,'Marker','.','MarkerSize',15,'LineStyle','none');
colour1 = repmat([0.83 0.82 0.28],length(v),1);
% shading INTERP
set(h1,'facevertexcdata',colour1);
light; material metal; view([1 1 1]);
xlabel('x'); ylabel('y'); zlabel('z');
rotate3d on;
end