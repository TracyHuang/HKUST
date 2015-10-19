% COMP4421_ASSIGN1 COMP4421 assignment 1 main routine.
%
function comp4421_assign1()

ImFileName = 'snoopy.tif';

% Read the grayscale image, check if it is a grayscale image of uint8
% datatype.
Im = imread(ImFileName);
assert_grayscale_image(Im);
assert_uint8_image(Im);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 1:
% Build gradient magnitude image.
% Please fill in code in "grad_mag_image.m" to accomplish function
% grad_mag_image
GMIm = grad_mag_image(Im);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the image size.
[sizeX sizeY] = size(Im);

sigma = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 2:
% Generate additive Gaussian noise with the given sigma.
% You are required to complete the implementation in gen_gauss_noise.m.
GaussNoise = gen_gauss_noise(sizeX,sizeY,sigma);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add Gaussian noise to the image.
GaussIm = add_noise(Im,GaussNoise);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 3:
% Filter the noisy image with arithmetic mean filter.
% You need to complete the implementation in arithmetic_mean_filter.m.
ArithIm = arithmetic_mean_filter(GaussIm);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Estimate the degradation function by image observation, suppose we use the
% observed subimage gs and the undegraded subimage fs for the estimation.
gs = GaussIm(158:226,164:241);
fs = Im(158:226,164:241);
H = estimate_degradation_func(gs,fs,sizeX,sizeY);

Sn = conj(fft2(GaussNoise)).*fft2(GaussNoise);
Sf = conj(fft2(Im)).*fft2(Im);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 4:
% Filter the noisy image with Wiener filter, suppose we know the power
% spectra of the noise Sn and the undegraded image Sf.
% You are required to complete the implementation in wiener_filter_1.m.
WienerIm1 = wiener_filter_1(GaussIm,H,Sn,Sf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 5:
% Filter the noisy image with Wiener filter, suppose we DO NOT know the power
% spectra of the noise Sn and the undegraded image Sf.  We use a
% constant K to estimate the ratio of Sn to Sf.
% You are required to complete the implementation in wiener_filter_2.m.
K = 0.01;
WienerIm2 = wiener_filter_2(GaussIm,H,K);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
subplot(2,3,1);imshow(Im);title('Original Image');
subplot(2,3,2);imshow(GMIm);title('Gradient magnitude image');
subplot(2,3,3);imshow(GaussNoise,[min(GaussNoise(:)) max(GaussNoise(:))]);title('Gaussian Noise');
subplot(2,3,4);imshow(ArithIm);title('Arithmetic Mean Filtered');
subplot(2,3,5);imshow(WienerIm1);title('Wiener Filtered 1');
subplot(2,3,6);imshow(WienerIm2);title('Wiener Filtered 2');
disp('Done.');