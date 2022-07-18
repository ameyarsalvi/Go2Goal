clc
clear

n = 100;

x = linspace(-20,20,n);
y = linspace(-20,20,n);

for i = 1:n
    for j = 1:n
        k(i,j) = (((x(i)-10).^2) + (y(j)-0).^2);
        z1(i,j) = (1./k(i,j)).^0.2;
    end
end

for i = 1:n
    for j = 1:n
        z2(i,j) = -(1./(((x(i)-4).^2 + (y(j)-0).^2)))^0.2;
    end
end

for i = 1:n
    for j = 1:n
        z3(i,j) = -(1./(((x(i)-7).^2 + (y(j)-2).^2)))^0.2;
    end
end

z = (10*z1 +2*z2 +2*z3);


surf(x,y,z)