function [fig] = draw_board(board, gamestate)
%DRAW_BOARD Summary of this function goes here
%   Detailed explanation goes here
fig = figure;
hold on;
for i = 1:8
    for j = 1:8
        coords = [i j];
        piece = get_piece(board, coords);
        draw_piece(piece, coords);
        moves = get_piece_moves(board, gamestate, coords);
        if ~isempty(moves)
            disp(moves);
            plot(moves(:,2), moves(:,1), 'x');
        end
    end
end
end

