function [ swtMap ] = swt( im, searchDirection )
%swt Preforms stoke width transform on input image
%   A novel image operator that seeks to find the value of stroke width
%   for each image pixel.  It's use is meant for the task of text
%   detection in natural images.
%
%   im = RGB input image of size m x n x 3
%   searchDirection = gradient direction is either 1 to detect dark text on light
%   background or -1 to detect light text on dark background.
%
%   swtMap = resulting mapping of stroke withs for image pixels

% Convert image to gray scale
im = im2double(rgb2gray(im));
figure, imshow(im), title('Black and White Image');

% Find edges using canny edge dector
edgeMap = edge(im, 'canny');
figure, imshow(edgeMap), title('Edges Using Canny');

% Get all edge pixel postitions
[edgePointRows, edgePointCols] = find(edgeMap);

% Find gradient horizontal and vertical gradient
sobelMask = fspecial('sobel');
dx = imfilter(im,sobelMask);
dy = imfilter(im,sobelMask');
figure, imshow(dx, []), title('Horizontal Gradient Image');
figure, imshow(dy, []), title('Vertical Gradient Image');

% Initializing matrix of gradient direction
theta = zeros(size(edgeMap,1),size(edgeMap,2));

% Calculating theta, gradient direction, for each pixel on the image.
% ***This can be optimized by using edgePointCols and edgePointRows
% instead.***
for i=1:size(edgeMap,1)
    for j=1:size(edgeMap,2)
        if edgeMap(i,j) == 1
            theta(i,j) = atan2(dy(i,j),dx(i,j));
        end
    end
end

% Getting size of the image
[m,n] = size(edgeMap);

% Initializing Stoke Width array with infinity
swtMap = zeros(m,n);
for i=1:m
    for j=1:n
        swtMap(i,j) = inf;
    end
end

% Set the maximum stroke width, this number is variable for now but must be
% made to be more dynamic in the future
maxStrokeWidth = 350;

% Initialize container for all stoke points found
strokePointsX = zeros(size(edgePointCols));
strokePointsY = zeros(size(strokePointsX));
sizeOfStrokePoints = 0;

% Iterate through all edge points and compute stoke widths
for i=1:size(edgePointRows)
    step = 1;
    initialX = edgePointRows(i);
    initialY = edgePointCols(i);
    isStroke = 0;
    initialTheta = theta(initialX,initialY);
    sizeOfRay = 0;
    pointOfRayX = zeros(maxStrokeWidth,1);
    pointOfRayY = zeros(maxStrokeWidth,1);
    
    % Record first point of the ray
    pointOfRayX(sizeOfRay+1) = initialX;
    pointOfRayY(sizeOfRay+1) = initialY;
    
    % Increase the size of the ray
    sizeOfRay = sizeOfRay + 1;
    
    % Follow the ray
    while step < maxStrokeWidth
        nextX = round(initialX + cos(initialTheta) * searchDirection * step);
        nextY = round(initialY + sin(initialTheta) * searchDirection * step);
        
        step = step + 1;
        
        % Break loop if out of bounds.  For some reason this is really
        % slow.
        if nextX < 1 | nextY < 1 | nextX > m | nextY > n
            break
        end
        
        % Record next point of the ray
        pointOfRayX(sizeOfRay+1) = nextX;
        pointOfRayY(sizeOfRay+1) = nextY;
        
        % Increase size of the ray
        sizeOfRay = sizeOfRay + 1;
        
        % Another edge pixel has been found
        if edgeMap(nextX,nextY)
            
            oppositeTheta = theta(nextX,nextY);
            
            % Gradient direction roughtly opposite
            if abs(abs(initialTheta - oppositeTheta) - pi) < pi/2
                isStroke = 1;
                strokePointsX(sizeOfStrokePoints+1) = initialX;
                strokePointsY(sizeOfStrokePoints+1) = initialY;
                sizeOfStrokePoints = sizeOfStrokePoints + 1;
            end
            
            break
        end
    end
    
    % Edge pixel is part of stroke
    if isStroke
        
        % Calculate stoke width
        strokeWidth = sqrt((nextX - initialX)^2 + (nextY - initialY)^2);
        
        % Iterate all ray points and populate with the minimum stroke width
        for j=1:sizeOfRay
            swtMap(pointOfRayX(j),pointOfRayY(j)) = min(swtMap(pointOfRayX(j),pointOfRayY(j)),strokeWidth);
        end
    end
end

figure, imshow(swtMap, []), title('Stroke Width Transform: First Pass');

% Iterate through all stoke points for a refinement pass.  Refer to figure
% 4b in the paper.

for i=1:sizeOfStrokePoints
    step = 1;
    initialX = strokePointsX(i);
    initialY = strokePointsY(i);
    initialTheta = theta(initialX,initialY);
    sizeOfRay = 0;
    pointOfRayX = zeros(maxStrokeWidth,1);
    pointOfRayY = zeros(maxStrokeWidth,1);
    swtValues = zeros(maxStrokeWidth,1);
    sizeOfSWTValues = 0;
    
    % Record first point of the ray
    pointOfRayX(sizeOfRay+1) = initialX;
    pointOfRayY(sizeOfRay+1) = initialY;
    
    % Increase the size of the ray
    sizeOfRay = sizeOfRay + 1;
    
    % Record the swt value of first stoke point
    swtValues(sizeOfSWTValues+1) = swtMap(initialX,initialY);
    sizeOfSWTValues = sizeOfSWTValues + 1;
    
    % Follow the ray
    while step < maxStrokeWidth
        nextX = round(initialX + cos(initialTheta) * searchDirection * step);
        nextY = round(initialY + sin(initialTheta) * searchDirection * step);
        
        step = step + 1;
        
        % Record next point of the ray
        pointOfRayX(sizeOfRay+1) = nextX;
        pointOfRayY(sizeOfRay+1) = nextY;
        
        % Increase size of the ray
        sizeOfRay = sizeOfRay + 1;
        
        % Record the swt value of next stoke point
        swtValues(sizeOfSWTValues+1) = swtMap(nextX,nextY);
        sizeOfSWTValues = sizeOfSWTValues + 1;
        
        % Another edge pixel has been found
        if edgeMap(nextX,nextY)
            break
        end
    end
    
    % Calculate stoke width as the median value of all swtValues seen.
    strokeWidth = median(swtValues(1:sizeOfSWTValues));
    
    % Iterate all ray points and populate with the minimum stroke width
    for j=1:sizeOfRay
        swtMap(pointOfRayX(j),pointOfRayY(j)) = min(swtMap(pointOfRayX(j),pointOfRayY(j)),strokeWidth);
    end
    
end

figure, imshow(swtMap, []), title('Stroke Width Transform: Second Pass');

end

