function [board] = move_piece(board,start_coords,end_coords)
%MOVE Summary of this function goes here
%   Detailed explanation goes here
set_piece(board,end_coords,get_piece(board,start_coords));
set_piece(board,start_coords,{});
end

