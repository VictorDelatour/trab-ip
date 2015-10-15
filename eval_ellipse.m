function [r_min, r_max, theta] = eval_ellipse(coef)
% http://math.stackexchange.com/questions/616645/determining-the-major-minor-axes-of-an-ellipse-from-general-form

a = coef(1); b = coef(2); c = coef(3); d = coef(4); e = coef(5); f = coef(6);

x_d = (b*e-2*c*d)/(4*a*c-b^2);
delta = sqrt((2*b*e-4*c*d)^2+4*(4*a*c-b^2)*(e^2-4*c*f))/(2*(4*a*c-b^2));

x_l = x_d - delta + 1e-16;
% y_l = roots([c, b*x_l + e, a * x_l.^2 + d * x_l + f]);

x_r = x_d + delta - 1e-16;
% y_r = roots([c, b*x_r + e, a * x_r.^2 + d * x_r + f]);

xv = linspace(x_l+1e-5, x_r-1e-5, 201);

q = 64 * (f*(4*a*c-b^2) - (a*e^2-b*d*e-c*d^2)) / ((4*a*c-b^2)^2);
s = .25*sqrt(abs(q)*sqrt(b^2+(a-c)^2));
r_max = 1/8*sqrt(2*abs(q)*sqrt(b^2+(a-c)^2)-2*q*(a+c));
r_min = sqrt(r_max^2-s^2);

if q*(a-c) == 0
    if qb == 0
        theta = 0;
    elseif qb > 0
        theta = .25*pi;
    else
        theta = .75*pi;
    end
elseif q*(a-c)>0
    theta = .5*atan(b/(a-c));
    if q*b < 0
        theta = theta + pi;
    end
else
    theta = .5 * (atan(b/(a-c))+pi);
end

A = c;
B = b * xv + e;
C = a * xv.^2 + d * xv + f;

yv = zeros(numel(xv),2);

for i = 1:numel(xv)
    yv(i,:) = roots([A, B(i), C(i)]);
end
% 
% figure(1)
% plot([xv, xv], yv(:), 'or')
% waitforbuttonpress;
% close all

end