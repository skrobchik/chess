function [] = set_piece(board, coords, val)
board(coords(1),coords(2)) = {val};
end