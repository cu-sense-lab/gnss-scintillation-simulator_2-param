% Plot a polar frame in the cartesian coordinate
% Borrowed from Dr. Mortion's solution
function [] = skyPlotFrame()
% Plot north-south, east-west lines
axis equal;
line([-1 1], [0, 0]); % Horizontal center line
line([0 0], [-1, 1]); % Vertical center line
hold on;

% Plot rings centered at the observer
for radius = 0:1/9:1
    x = -radius: 0.0001: radius;
    y = sqrt(radius^2-x.^2);
    plot(x, y,'b:','LineWidth', 1); 
    plot(x, -y,'b:', 'LineWidth', 1); 
end

for radius = 0:1/3:1
    x = -radius: 0.0001: radius;
    y = sqrt(radius^2-x.^2);
    plot(x, y,'b','LineWidth', 1); 
    plot(x, -y,'b', 'LineWidth', 1); 
end
hold on;