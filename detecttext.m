function [ final ] = detecttext( imName )
%DETECTTEXT Summary of this function goes here
%   Detailed explanation goes here

image = imread(imName);
swtMap = swt(image,-1);
[swtLabel numCC] = swtlabel(swtMap);
final = extractletters(swtMap, swtLabel, numCC);

end

