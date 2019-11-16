function [piece] = get_piece(board, coords)
%GET_PIECE Summary of this function goes here
%   Detailed explanation goes here
cell = board(coords(1), coords(2));
piece = cell{1};
end

