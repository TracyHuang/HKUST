% ASSERT_GRAYSCALE_IMAGE Assert if the given image is a grayscale image.
%
%   ASSERT_GRAYSCALE_IMAGE(X) asserts if the image X is a grayscale image.
%   Assertion is done based on the number of channels found in the image.
%   A grayscale image should have 1 channel.
%
function assert_grayscale_image(Im)

if size(Im,3) ~= 1
    error('Invalid number of channels, only 1-channel is supported');
end