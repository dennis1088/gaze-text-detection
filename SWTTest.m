% Read in image
im = imread('text b on w.jpg');
%figure, imshow(im), title('Original Image');

% Convert image to gray scale
im = im2double(rgb2gray(im));
%figure, imshow(im), title('Black and White Image');

% Find edges using canny edge dector
edgeMap = edge(im, 'canny');
%figure, imshow(edgeMap), title('Edges Using Canny');

% Get all edge pixel postitions
[edgePointRows, edgePointCols] = find(edgeMap);

% Find gradient horizontal and vertical gradient
sobelMask = fspecial('sobel');
dx = imfilter(im,sobelMask);
dy = imfilter(im,sobelMask');
%figure, imshow(dx, []), title('Horizontal Gradient Image');
%figure, imshow(dy, []), title('Vertical Gradient Image');

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
maxStrokeWidth = 300;

step = 1;
initialX = 106;
initialY = 224;
isStroke = 0;
initialTheta = theta(initialX,initialY);
sizeOfRay = 0;
pointOfRayX = zeros(maxStrokeWidth,1);
pointOfRayY = zeros(maxStrokeWidth,1);

% Record first point of the ray
pointOfRayX(sizeOfRay+1) = initialX;
pointOfRayY(sizeOfRay+1) = initialY;

sizeOfRay = sizeOfRay + 1;

% Follow the ray
while step < maxStrokeWidth
    nextX = round(initialX + cos(initialTheta) * step);
    nextY = round(initialY + sin(initialTheta) * step);
    
    step = step + 1;
    
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
        end
        
        break
    end
end

% Edge pixel is part of stroke
if isStroke
    
    % Calculate stoke width
    strokeWidth = sqrt((nextX - initialX)^2 + (nextY - initialY)^2);
    
    % Iterate all ray points and populate with stroke width
    for j=1:sizeOfRay
        swtMap(pointOfRayX(j),pointOfRayY(j)) = strokeWidth;
    end
end