
function [x,y,z] = MNI2space(xMNI,yMNI,zMNI)
    x = xMNI/2 + 46;
    y = 108*(yMNI + 126)/216 +1;
    z=90*(zMNI + 72)/180 +1;
end   