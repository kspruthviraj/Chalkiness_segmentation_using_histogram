clear
close all
tic; % Start timer.
captionFontSize = 14;

%% Load the file
fullFileName = '\Images\Rice01.png';

%% Convert RGB2Grayscale
originalImage = imread(fullFileName);
originalImage = rgb2gray(originalImage);
subplot(2, 4, 1);
imshow(originalImage);

%% Explore the image/data using histogram:
[pixelCount, grayLevels] = imhist(originalImage);

subplot(2, 4, 2);
bar(pixelCount);
xlim([0 grayLevels(end)]); % Scale x axis manually.
grid on;

thresholdValue = 90; % Choose the threshold value in roder to mask out the background noise.

% Show the threshold as a vertical red bar on the histogram.
hold on;
maxYValue = ylim;
line([thresholdValue, thresholdValue], maxYValue, 'Color', 'r');
annotationText = sprintf('Thresholded at %d gray levels', thresholdValue);
text(double(thresholdValue + 5), double(0.5 * maxYValue(2)), annotationText, 'FontSize', 10, 'Color', [0 .5 0]);
text(double(thresholdValue - 70), double(0.94 * maxYValue(2)), 'Background', 'FontSize', 10, 'Color', [0 0 .5]);
text(double(thresholdValue + 50), double(0.94 * maxYValue(2)), 'Foreground', 'FontSize', 10, 'Color', [0 0 .5]);

%% Get and show binary image
binaryImage = originalImage > thresholdValue;
binaryImage = imfill(binaryImage, 'holes');
% Display the binary image.
subplot(2, 4, 3);
imshow(binaryImage); 
title('Binary Image', 'FontSize', captionFontSize); 

%% Maskout the background noise

MaskedImage = originalImage;
MaskedImage(~binaryImage) = 0;
subplot(2, 4, 4);
imshow(MaskedImage); 
title('Masked Image', 'FontSize', captionFontSize); 
%% Get the centroid, mean intensity, permieter of the whole seed etc
blobMeasurements = regionprops(binaryImage, originalImage, 'all');




%% Calculate the chalkiness by first exploring the histogram

[pixelCount_1, grayLevels_1] = imhist(MaskedImage);
% % subplot(2, 3, 5);
% % bar(pixelCount_1);
% % xlim([0 grayLevels_1(end)]); % Scale x axis manually.
% % grid on;
thresholdValue_1 = 180; %% Choose the threshold that segments the chalkiness
binary_MaskedImage = MaskedImage > thresholdValue_1; 
binary_MaskedImage = imfill(binary_MaskedImage, 'holes');

% % % Show the threshold as a vertical red bar on the histogram.
% % hold on;
% % maxYValue_1 = ylim;
% % line([thresholdValue_1, thresholdValue_1], maxYValue_1, 'Color', 'r');
% % annotationText = sprintf('Thresholded at %d gray levels', thresholdValue_1);
% % text(double(thresholdValue_1 + 5), double(0.5 * maxYValue_1(2)), annotationText, 'FontSize', 10, 'Color', [0 .5 0]);
% % text(double(thresholdValue_1 - 70), double(0.94 * maxYValue_1(2)), 'Background', 'FontSize', 10, 'Color', [0 0 .5]);
% % text(double(thresholdValue_1 + 50), double(0.94 * maxYValue_1(2)), 'Foreground', 'FontSize', 10, 'Color', [0 0 .5]);

%% Display the binary Masked  image.
subplot(2, 4, 5);
imshow(binary_MaskedImage); 
title('Binary Masked Image', 'FontSize', captionFontSize); 

%% Get the centroid, mean intensity, permieter of the chlky area
blobMeasurements_subblobs = regionprops(binary_MaskedImage, originalImage, 'all');

% Plot the borders of all the seeds on the original grayscale image using the coordinates returned by bwboundaries.
subplot(2, 4, 6);
imshow(originalImage);
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
hold on;

boundaries = bwboundaries(binaryImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end

boundaries_Masked = bwboundaries(binary_MaskedImage);
numberOfBoundaries_Masked = size(boundaries_Masked, 1);
for k = 1 : numberOfBoundaries_Masked
	thisBoundary_Masked = boundaries_Masked{k};
	plot(thisBoundary_Masked(:,2), thisBoundary_Masked(:,1), 'b', 'LineWidth', 2);
end

hold off;

%% Overlay the chalky area on the original image
subplot(2, 4, 7);
imshow(labeloverlay(originalImage,binary_MaskedImage))
title('Chalkiness')

%% Chalkiness
Sum_Subblobs_Perimeter = sum([blobMeasurements_subblobs(1:end).Perimeter]);
Sum_Blobs_Perimeter = sum([blobMeasurements(1:end).Perimeter]);

Percentage_Chalkiness=(Sum_Subblobs_Perimeter/Sum_Blobs_Perimeter)*100;

if Percentage_Chalkiness<10
fprintf('<strong> This belongs to category 1 </strong>\n')
elseif (Percentage_Chalkiness>10)&&(Percentage_Chalkiness<25)
fprintf('<strong> This belongs to category 2 </strong>\n')
elseif (Percentage_Chalkiness>25)&&(Percentage_Chalkiness<50)
fprintf('<strong> This belongs to category 3 </strong>\n')
elseif (Percentage_Chalkiness>50)&&(Percentage_Chalkiness<75)
fprintf('<strong> This belongs to category 4 </strong>\n')
elseif (Percentage_Chalkiness>75)&&(Percentage_Chalkiness<100)
fprintf('<strong> This belongs to category 5 </strong>\n')
end

toc

