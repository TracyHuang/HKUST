% WIENER_FILTER_1 Filter a noisy image with Wiener filter, suppose we know the power
% spectra of the noise and the undegraded image.
%
%   Y = WIENER_FILTER_1(X,H,Sn,Sf) filters a noisy image X with Wiener filter. H defines
%   the degradation function, Sn defines the power spectrum of the noise image and Sf
%   defines the power spectrum of the undegraded image.
%
function Im = wiener_filter_1(NoisyIm, H, Sn, Sf)

% Check if the noisy image is grayscale and of uint8 datatype.
assert_grayscale_image(NoisyIm);
assert_uint8_image(NoisyIm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 4:
% Filter the noisy image with Wiener filter, suppose we know the power
% spectra of the noise (Sn) and the undegraded image (Sf).
%
% Im = ?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = zeros(size(NoisyIm));
G = fft2(NoisyIm);
for i = 1:size(NoisyIm, 1)
    for j = 1:size(NoisyIm, 2)
        F(i, j) = (conj(H(i, j)) * Sf(i, j)) / (Sf(i, j) * (norm(H(i, j)) ^ 2) + Sn(i, j)) * G(i, j);
    end
end
Im = ifft2(F);


% Convert the image to uint8 datatype.
Im = uint8(Im);

end
