% ARITHMETIC_MEAN_FILTER Filter a noisy image with an arithmetic mean filter.
%
%   Y = ARITHMETIC_MEAN_FILTER(X) filters a noisy image X with an arithmetic mean filter.
%   A 3-by-3 window is used in the filtering process.
%
function Im = arithmetic_mean_filter(NoisyIm)

% Check if the noisy image is grayscale and of uint8 datatype.
assert_grayscale_image(NoisyIm);
assert_uint8_image(NoisyIm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 3:
% Filter the noisy image with arithmetic mean filter.  Use a 3x3 window to
% filter the image.
%
% Im = ?
Im = zeros(size(NoisyIm));
max_x = size(NoisyIm, 1);
max_y = size(NoisyIm, 2);
    for i = 1:max_x
        for j = 1:max_y
            %z1 
            if ((i > 1) && (j > 1))
               z1 = NoisyIm(i - 1, j - 1);
            else
                z1 = 0;
            end
            z1 = double(z1);
            %z2
            if i > 1
                z2 = NoisyIm(i - 1, j);
            else
                z2 = 0;
            end
            z2 = double(z2);
            %z3
            if ((i > 1) && (j < max_y))
                z3 = NoisyIm(i - 1, j + 1);
            else
                z3 = 0;
            end
            z3 = double(z3);
            %z4
            if j > 1
                z4 = NoisyIm(i, j - 1);
            else
                z4 = 0;
            end
            z4 = double(z4);
            %z5
            z5 = double(NoisyIm(i, j));
            %z6
            if j < max_y
                z6 = NoisyIm(i, j + 1);
            else
                z6 = 0;
            end
            z6 = double(z6);
            %z7
            if ((i < max_x) && (j > 1))
                z7 = NoisyIm(i + 1, j - 1);
            else
                z7 = 0;
            end
            z7 = double(z7);
            %z8
            if i < max_x
                z8 = NoisyIm(i + 1, j);
            else
                z8 = 0;
            end
            z8 = double(z8);
            %z9
            if ((i < max_x) && (j < max_y))
                z9 = NoisyIm(i + 1, j + 1);
            else
                z9 = 0;
            end
            z9 = double(z9);
            Im(i, j) = double(z1 + z2 + z3 + z4 + z5 + z6 + z7 + z8 + z9) / 9.0;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rescale the grayscale values of the filtered image to 0-255 and convert
% the image to uint8 datatype.
Im = (Im-min(Im(:)))./(max(Im(:))-min(Im(:))).*255;
Im = uint8(Im);

end