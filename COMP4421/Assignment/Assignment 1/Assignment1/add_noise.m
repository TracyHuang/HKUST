% ADD_NOISE Add noise to an image.
%
%   Y = ADD_NOISE(X,N) adds noise N to an image X.
%
function NoisyIm = add_noise(Im, Noise)

assert_uint8_image(Im);
Im = double(Im);

% Add the noise to the image, rescale the grayscale value of the noisy
% image to 0-255.
NoisyIm = Im+Noise;
NoisyIm = (NoisyIm-min(NoisyIm(:)))./(max(NoisyIm(:))-min(NoisyIm(:))).*255;

NoisyIm = uint8(NoisyIm);