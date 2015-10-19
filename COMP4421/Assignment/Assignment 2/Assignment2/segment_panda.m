% SEGMENT_PANDA contains the implementation of the main routine for Assignment 2. 
% This routine reads a image, which contains four intensity classes.
% The routine employs the Expectation-maximization method to estimate the parameters
% of the four intensity classes with a mixture of four Gaussian distributions, and
% segment the image with minimum error thresholds.
%  
function segment_panda() 

% Define convergence threshold.
threshold = 0.01;

% Read the panda image and convert the color image into grayscale image.
Im = imread('panda.jpg');
Im = rgb2gray(Im);
% Build a histgoram of the image, it is for the sake of
% parameter estimations and visualization.
Hist = imhist(Im,256)';

%
% The Expectation-maximization algorithm.
%

% Initialize the paramters.
Weight = zeros(4,1);
Mu = zeros(4,1);
Sigma = zeros(4,1);
Weight(1) = 0.35;
Weight(2) = 0.25;
Weight(3) = 0.25;
Weight(4) = 0.15;
Mu(1) = 5.0;
Mu(2) = 60.0;
Mu(3) = 90.0;
Mu(4) = 230.0;
Sigma(1) = 1.0;
Sigma(2) = 10.0;
Sigma(3) = 10.0;
Sigma(4) = 20.0;

N = size(Im, 1) * size(Im, 2);
Ppost = zeros(4, 256);   % P(j|Zn)
Pzn = zeros(256);        % P(Zn)
temp = 0.0;
MuUp = 0.0;
MuDown = 0.0;
SigmaUp = 0.0;
SigmaDown = 0.0;
WeightUp = 0.0;



itn = 1;
while(1)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TODO_1: Estimate the expected posterior probabilities.
	% frirst calculate P(Zn)
    
    for i = 1 : 256  % we are sure that intensity is from 1 to 256
        temp = 0;
        for j = 1 : 4
            temp = temp + normpdf(double(i), Mu(j), Sigma(j)) * Weight(j);
        end
        Pzn(i) = temp;
    end
    
    % second calculate Ppost
    for i = 1 : 4
        for j = 1 : 256
            Ppost(i, j) = normpdf(double(j), Mu(i), Sigma(i)) * Weight(i) / Pzn(j);
        end
    end
    
    
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
	% Allocate spaces for the parameters estimated.
	NewWeight = zeros(4,1);
	NewMu = zeros(4,1);
	NewSigma = zeros(4,1);
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TODO_2: Estimate the parameters.

    for i = 1 : 4
        MuUp = 0.0;
        MuDown = 0.0;
        SigmaUp = 0.0;
        SigmaDown = 0.0;
        WeightUp = 0.0;
        for j = 1 : 256
           MuUp = MuUp + Ppost(i, j) * double(j) * double(Hist(j)) ;
           MuDown = MuDown + Ppost(i, j) * double(Hist(j));
        end
        NewMu(i) = double(MuUp) / double(MuDown);
        for j = 1 : 256
           SigmaUp = SigmaUp + Ppost(i, j) * ((double(j) - NewMu(i)) ^ 2) * double(Hist(j));
           SigmaDown = SigmaDown + Ppost(i, j) * double(Hist(j));
        end
        NewSigma(i) = sqrt( double(SigmaUp) / double(SigmaDown) );
        for j = 1 : 256
            WeightUp = WeightUp + double(Ppost(i, j)) * double(Hist(j));
        end
        NewWeight(i) = double(WeightUp) / N;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    % Check if convergence is reached.
	DiffWeight = abs(NewWeight-Weight)./Weight;
	DiffMu = abs(NewMu-Mu)./Mu;
	DiffSigma = abs(NewSigma-Sigma)./Sigma;
	
	if (max(DiffWeight) < threshold) & (max(DiffMu) < threshold) & (max(DiffSigma) < threshold)
        break;
	end
	
	% Update the parameters.
	Weight = NewWeight;
	Mu = NewMu;
	Sigma = NewSigma;
    
    disp(['Iteration #' num2str(itn)]);
    disp([' Weight: ' num2str(Weight(1)) ' ' num2str(Weight(2)) ' ' num2str(Weight(3)) ' ' num2str(Weight(4))]);
    disp([' Mu: ' num2str(Mu(1)) ' ' num2str(Mu(2)) ' ' num2str(Mu(3)) ' ' num2str(Mu(4))]);
    disp([' Sigma: ' num2str(Sigma(1)) ' ' num2str(Sigma(2)) ' ' num2str(Sigma(3)) ' ' num2str(Sigma(4))]);
    itn = itn + 1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO_3(a): Compute minimum error threshold between the first and the second
% Gaussian distributions.
%
FirstThreshold = InterSect(Mu(1), Sigma(1), Mu(2), Sigma(2), Weight(1), Weight(2));
 
% TODO_3(b): Compute minimum error threshold between the second and the third
% Gaussian distributions.
%
SecondThreshold = InterSect(Mu(2), Sigma(2), Mu(3), Sigma(3), Weight(2), Weight(3));

% TODO_3(c): Compute minimum error threshold between the third and the fourth
% Gaussian distributions.
%
ThirdThreshold = InterSect(Mu(3), Sigma(3), Mu(4), Sigma(4), Weight(3), Weight(4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show the segmentation results.
figure;
subplot(2,3,1);imshow(Im);title('Panda');
subplot(2,3,3);imshow(Im<=FirstThreshold);title('First Intensity Class');
subplot(2,3,4);imshow(Im>FirstThreshold & Im<SecondThreshold);title('Second Intensity Class');
subplot(2,3,5);imshow(Im>SecondThreshold & Im<ThirdThreshold);title('Third Intensity Class');
subplot(2,3,6);imshow(Im>=ThirdThreshold);title('Fourth Intensity Class');
Params = zeros(12,1);
Params(1) = Weight(1);
Params(2) = Mu(1);
Params(3) = Sigma(1);
Params(4) = Weight(2);
Params(5) = Mu(2);
Params(6) = Sigma(2);
Params(7) = Weight(3);
Params(8) = Mu(3);
Params(9) = Sigma(3);
Params(10) = Weight(4);
Params(11) = Mu(4);
Params(12) = Sigma(4);
subplot(2,3,2);ggg(Params,Hist);

end

function intersect = InterSect(mu1, sigma1, mu2, sigma2, weight1, weight2)

x0 = [mu1, mu2];
intersect = fzero(@(x) weight1 * normpdf(x, mu1, sigma1) - weight2 * normpdf(x, mu2, sigma2), x0);

end