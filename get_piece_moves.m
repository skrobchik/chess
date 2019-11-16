function [moves] = get_piece_moves(board, gamestate, coords)
%GET_PIECE_MOVES Returns the moves for a piece
%   Detailed desc.
moves = [];
piece = get_piece(board,coords);
if isempty(piece)
    return;
end
color = piece.Color;
if piece.PieceType == 'n'
    moves = [-1 2; 1 2; 2 1; 2 -1; 1 -2; -1 -2; -2 -1; -2 1];
    for i = 1:size(moves,1)
        moves(i,:) = moves(i,:) + coords;
    end
end
if piece.PieceType == 'p'
    walk_direction = 1;
    if piece.Color == 'b'
        walk_direction = -1;
    end
    front_coords = coords + [walk_direction 0];
    eat_coords = [coords + [walk_direction -1]; coords + [walk_direction 1]];
    if isempty(get_piece(board, front_coords))
        moves = [moves; front_coords];
    end
    for i = 1:size(eat_coords,1)
        eat_piece = get_piece(board, eat_coords);
        if isempty(eat_piece)
            break
        end
        if eat_piece.Color == opposite_color(color)
            moves = [moves; eat_coords(i,:)];
        end
    end
end
rook_move_directions = [0 1; 1 0; 0 -1; -1 0];
bishop_move_directions = [1 1; 1 -1; -1 -1; -1 1];
queen_move_directions = [rook_move_directions; bishop_move_directions];
move_directions = [];
switch piece.PieceType
    case 'r'
        move_directions = rook_move_directions;
    case 'b'
        move_directions = bishop_move_directions;
    case 'q'
        move_directions = queen_move_directions;
end
moves = [moves; expand_moves_in_move_directions(board, coords, move_directions)];
if piece.PieceType == 'k'
    king_moves = zeros(9,2);
    for i = -1:1
        for j = -1:1
            king_moves(i+j+3,1:2) = [i j];
        end
    end
    
end
filtered_moves = [];
for i = 1:size(moves,1)
    move = moves(i,:);
    if ~is_in_bounds(move)
        continue;
    end
    move_board = move_piece(board, coords, move);
    if is_king_checked(move_board, color)
        continue;
    end
    target = get_piece(board, move);
    if ~isempty(target)
        if target.Color == color
            continue;
        end
    end 
    filtered_moves = [filtered_moves; move];
end
moves = filtered_moves;
end
            
            
            
    