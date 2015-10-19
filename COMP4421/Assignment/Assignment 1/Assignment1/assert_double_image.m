% ASSERT_UINT8_IMAGE Assert if the given image is in type uint8.
%
%   ASSERT_UINT8_IMAGE(X) asserts if the image X is in type uint8.
%   Assertion is done based on the type of each image pixel.
%
function assert_double_image(Im)

if ~isa(Im,'double')
    error('Invalid image type, only double is supported');
end