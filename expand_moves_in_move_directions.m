function [moves] = expand_moves_in_move_directions(board, coords, move_directions)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
moves = [];
for i = 1:size(move_directions,1)
    walk_coord = coords;
    while true
        walk_coord = walk_coord + move_directions(i,:);
        if ~is_in_bounds(walk_coord)
            break
        end
        if ~isempty(get_piece(board,walk_coord))
            break
        end
        moves = [moves; walk_coord];
    end
end
end

