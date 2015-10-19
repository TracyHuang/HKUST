% GRAD_MAG_IMAGE Compute a gradient magnitude image of the given image.
%
%   Y = GRAD_MAG_IMAGE(X) computes a gradient magnitude image of the image X.
%   Computation is based on the formula given in the lecture notes on image 
%   enhancement in spatial domain, pp.83.  The intensity values of the pixels 
%   that are out of the image boundary are treated as zeros.
%
%   REMINDER: The gradient magnitude image return should be in uint8 type.
%
function GMIm = grad_mag_image(Im)

assert_grayscale_image(Im);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO 1: 
% Compute the gradient magnitude image.
% GMIm = ?;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GMIm = zeros(size(Im));
max_x = size(GMIm, 1);
max_y = size(GMIm, 2);
    for i = 1:max_x
        for j = 1:max_y
            %z1 
            if ((i > 1) && (j > 1))
               z1 = Im(i - 1, j - 1);
            else
                z1 = 0;
            end
            z1 = double(z1);
            %z2
            if i > 1
                z2 = Im(i - 1, j);
            else
                z2 = 0;
            end
            z2 = double(z2);
            %z3
            if ((i > 1) && (j < max_y))
                z3 = Im(i - 1, j + 1);
            else
                z3 = 0;
            end
            z3 = double(z3);
            %z4
            if j > 1
                z4 = Im(i, j - 1);
            else
                z4 = 0;
            end
            z4 = double(z4);
            %z6
            if j < max_y
                z6 = Im(i, j + 1);
            else
                z6 = 0;
            end
            z6 = double(z6);
            %z7
            if ((i < max_x) && (j > 1))
                z7 = Im(i + 1, j - 1);
            else
                z7 = 0;
            end
            z7 = double(z7);
            %z8
            if i < max_x
                z8 = Im(i + 1, j);
            else
                z8 = 0;
            end
            z8 = double(z8);
            %z9
            if ((i < max_x) && (j < max_y))
                z9 = Im(i + 1, j + 1);
            else
                z9 = 0;
            end
            z9 = double(z9);
            GMIm(i, j) = abs(z7 + 2 * z8 + z9 - z1 - 2 * z2 - z3) + abs(z3 + 2 * z6 + z9 - z1 - 2 * z4 - z7);
        end
    end
GMIm = uint8(GMIm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert_uint8_image(GMIm);
end