function new_states = car_like_rob(prev_states,V,w) 

    kinematicModel = bicycleKinematics;
    kinematicModel.WheelBase = 0.256;
    kinematicModel.MaxSteeringAngle = 0.5236;

    initialState = prev_states;

    tspan = 0:0.001:0.01;

    inputs = [V w];
    [t,y] = ode45(@(t,y)derivative(kinematicModel,y,inputs),tspan,initialState);
    
    new_states = y(end,:);
    
end
