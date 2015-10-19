% ASSERT_UINT8_IMAGE Assert if the given image is in type uint8.
%
%   ASSERT_UINT8_IMAGE(X) asserts if the image X is in type uint8.
%   Assertion is done based on the type of each image pixel.
%
function assert_uint8_image(Im)

if ~isa(Im,'uint8')
    error('Invalid image type, only uint8 is supported');
end