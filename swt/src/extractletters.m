function [ letters ] = extractletters( swtMap, swtLabel, ccNum )
%LETTERCANDIDATES Summary of this function goes here
%   Detailed explanation goes here

numLetters = 0;
letters = zeros(size(swtLabel));
maxLetterHeight = 300;
minLetterHeight = 10;

for i=1:ccNum
    
    [r,c] = find(swtLabel==i);
    idx = sub2ind(size(swtMap),r,c);
    componentSW = swtMap(idx);
    varianceSW = var(componentSW);
    meanSW = mean(componentSW);
    width = max(c) - min(c);
    height = max(r) - min(r);
    aspectRatio = width/height;
    diameter = sqrt(width^2+height^2);
    medianSW = median(componentSW);
    maxSW = max(componentSW);
    
    % Accepted font heights are between 10px and 300px
    if height>maxLetterHeight | height<minLetterHeight, continue, end
    
    % Reject CC with hight stroke width variance.  The threshold if half
    % the average stroke width of a connected component
    if varianceSW/meanSW > .5, continue, end
    
    % Ratio between the diameter of the connected component and its
    % median stroke width to be a value less than 10
    if diameter/medianSW >= 10, continue, end
    
    % Aspect ratio to be a value between 0.1 and 10
    if aspectRatio < 0.1 && aspectRatio > 10, continue, end
    
    if size(componentSW,1)/maxSW < 5, continue, end
    
    if width > height*2.5, continue, end
    
    
    letters(idx) = 1;
    
    %     if varianceSW <= meanSW*0.5
    %         %if 0.1 <= aspectRatio && aspectRatio <= 10
    %             numLetters = numLetters + 1;
    %             letters(idx) = 1;
    %         %end
    %     end
    
end

end

