% ESTIMATE_DEGRADATION_FUNC Estimate the degradation function of an image.
%
%   Y = ESTIMATE_DEGRADATION_FUNC(gs, fs, m, n) estimates the degradation function of
%   an image with size m-by-n.  An observed subimage gs and a reconstructed subimage fs
%   are used in the estimation.
%
function H = estimate_degradation_func(gs, fs, sizeX, sizeY)

Gs = fft2(gs);
Fs = fft2(fs);
Hs = Gs./Fs;
H = imresize(Hs,[sizeX,sizeY],'bilinear');

% H is the estimated degradation function in Fourier domain, size of H is
% [sizeY,sizeX].
if (size(H,1) ~= sizeX) | (size(H,2) ~= sizeY)
    error('Size of H is incorrect.');
end