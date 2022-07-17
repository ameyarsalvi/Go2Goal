function R = reward_func(x,y,x_g,y_g)

    k = (((x-x_g).^2) + (y-y_g).^2);
    z1 = (1./k).^0.2;

    z2 = -(1./(((x-4).^2 + (y-0).^2)))^0.2;

    z3 = -(1./(((x-7).^2 + (y-2).^2)))^0.2;

    R = (z1 +z2 +z3);
end
