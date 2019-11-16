function [board] = new_board()
%NEW_BOARD Summary of this function goes here
%   Detailed explanation goes here
piece_array = ['r' 'n' 'b' 'q' 'k' 'b' 'n' 'r'];
board = cell(8,8);
for i = 1:8
    for j = 1:8
        if (2 < i) && (i < 7)
            break;
        end
        piece = struct(...
            'PieceType', '',...
            'Color', '');
        if i == 1 || i == 2
            piece.Color = 'w';
        end
        if i == 7 || i == 8
            piece.Color = 'b';
        end
        if i == 1 || i == 8
            piece.PieceType = piece_array(j);
        end
        if i == 2 || i == 7
            piece.PieceType = 'p';
        end
        board(i,j) = {piece};
    end
end