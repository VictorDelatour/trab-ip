function [ mask ] = get_mask( v_bone_12, t_bone_12,v_bonetot,t_bonetot, X_Cube,Y_Cube,Z_Cube )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to export: mask!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rayon=3;

 
 [a1 b1 c1]= size(X_Cube);     
    IN_mesh=zeros(a1*c1,b1);
    [X_direction,index_a,index_c]=unique(Y_Cube(:));

    MIN =min(v_bone_12(:,1));
    MAX=max(v_bone_12(:,1));
    for i=1:length(X_direction)
     if X_direction(i)>=MIN && X_direction(i)<=MAX
              contour = getContour(v_bonetot,t_bonetot,[1 0 0],X_direction(i));
                            %figure, plot(contour{1}(:,2),contour{1}(:,3));
        if length(contour)>=2
                 IN_mesh(:,i)=inpolygon(X_Cube(index_c==i),Z_Cube(index_c==i),contour{1}(:,2),contour{1}(:,3))+inpolygon(X_Cube(index_c==i),Z_Cube(index_c==i),contour{2}(:,2),contour{2}(:,3));
              
        elseif length(contour)== 1
                  %size(inpolygon(Y_Cube(index_c==i),Z_Cube(index_c==i),contour{1}(:,1),contour{1}(:,3)))
                  IN_mesh(:,i)=inpolygon(X_Cube(index_c==i),Z_Cube(index_c==i),contour{1}(:,2),contour{1}(:,3));
        end
        clear contour
     end
     
    end




IN_mesh_logical= logical(IN_mesh);
mask=zeros(a1,b1,c1);
mt=zeros(a1,c1);
for i=1:a1
  mt(:)=IN_mesh_logical(:,i);
  mask(:,i,:)=mt;
end

mask=permute(mask,[1 2 3]);


end

