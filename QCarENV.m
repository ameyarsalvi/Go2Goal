classdef QCarENV < rl.env.MATLABEnvironment
    
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Initialize system state [x,dx,theta,dtheta]'
        new_states;
        prev_states = [0,0,0];
        V;
        w;
        Xg = [10,0];
        steps = 1;
        episodes =1;
        Reward;
        
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end

    %% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function self = QCarENV()
            % Initialize Observation settings
            ObservationInfo = rlNumericSpec([4,1]);
            ObservationInfo.Name = 'Observations for Agent';
            ObservationInfo.Description = 'x,y,err_x,err_y';
            
            % Initialize Action settings   
            ActionInfo = rlNumericSpec([2,1],'LowerLimit',[0.1;-0.5] ,'UpperLimit',[5;0.5]);
            ActionInfo.Name = 'Input Velocities';
            ActionInfo.Description = 'V,w';
            
            
            self = self@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
        end

        function [Observation,Reward,IsDone,LoggedSignals] = step(self,Action)
            LoggedSignals = [];
            % Get action
            
            Action = double(Action);
            self.V = Action(1);
            self.w = Action(2);
            
            self.new_states = car_like_rob(self.prev_states,self.V,self.w);
            err_x = sqrt((self.new_states(1) - self.Xg(1)).^2);
            err_y = sqrt((self.new_states(2) - self.Xg(2)).^2);
            
            Observation = [self.new_states(1);self.new_states(2);err_x;err_y];
            
            % Get reward
            Reward = getReward(self);

            % Update system states
            self.prev_states = self.new_states;
            self.steps = self.steps +1;          
            
            % Check terminal condition
            
            b = [self.new_states(1) self.new_states(2)];
            a = [self.Xg(1) self.Xg(2)];
            IsDone = norm(a-b) < 0.01 ||norm(a-b)>30 ;
            self.IsDone = IsDone;

        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(self)
            
            
            self.prev_states = [0,0,0];
            self.steps = 1;
            err_x = sqrt((self.prev_states(1) - self.Xg(1)).^2);
            err_y = sqrt((self.prev_states(2) - self.Xg(2)).^2);
            
            Observation = [self.prev_states(1);self.prev_states(2);err_x;err_y];
            InitialObservation = Observation;
            self.episodes = self.episodes +1;

        end
    end
    %% Optional Methods (set methods' attributes accordingly)
    methods               
        % Reward function
        function Reward = getReward(self)
            
            %{
            if norm([self.new_states(1) self.new_states(2)] -[4 0]) < 1.1
                Reward_Obstacle_1 = -100;
            else
                Reward_Obstacle_1 = 0;
            end
            
            if norm([self.new_states(1) self.new_states(2)]-[7,2]) < 1.1
                Reward_Obstacle_2 = -100;
            else
                Reward_Obstacle_2 = 0;
            end
            
            if norm([self.new_states(1) self.new_states(2)]- [self.Xg(1) self.Xg(2)]) < 0.01
                Reward_Goal = 0;
            else
                Reward_Goal = -1;
            end
            
            reward = Reward_Obstacle_1 + Reward_Obstacle_2 + Reward_Goal ;
            %}
            
            %a = norm([self.new_states(1) self.new_states(2)] -[4 0]).^0.1;
            %b = norm([self.new_states(1) self.new_states(2)]-[7,2]).^0.1;
            %c =(1/norm([self.new_states(1) self.new_states(2)]- [self.Xg(1) self.Xg(2)])).^0.2;
            
            reward = reward_func(self.new_states(1),self.new_states(2),self.Xg(1),self.Xg(2));
            
            self.Reward = reward;
            Reward = self.Reward;
            
        end   
    end
    
    methods (Access = protected)
        end
    end