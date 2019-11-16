function [b] = is_in_bounds(coords)
%IS_IN_BOUNDS Summary of this function goes here
%   Detailed explanation goes here
i = coords(1);
j = coords(2);
b = true;
if i > 8 || i < 1 || j > 8 || j < 1
    b = false;
end
end

