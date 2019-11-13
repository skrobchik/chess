close all;
clear;
clc;
knight_moves = [-1 2; 1 2; 2 1; 2 -1; 1 -2; -1 -2; -2 -1; -2 1];
board = [...
    'r' 'n' 'b' 'q' 'k' 'b' 'n' 'r' ;...
    'p' 'p' 'p' 'p' 'p' 'p' 'p' 'p' ;...
    ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ;...
    ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ;...
    ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ;...
    ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ;...
    'p' 'p' 'p' 'p' 'p' 'p' 'p' 'p' ;...
    'r' 'n' 'b' 'q' 'k' 'b' 'n' 'r' ;...
    ];
fig = figure;
hold on;
for i = 1:8
    for j = 1:8
        draw_piece(board(i,j),i,j);
        if board(i,j) == 'n'
            plot(knight_moves(:,1)+j,knight_moves(:,2)+i,'x');
        end
    end
end