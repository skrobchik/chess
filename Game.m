classdef Game
    properties
        Board
        GameState
        Figure
        MoveIndicator
        SelectedPieceCoord
    end
    
    methods
        function obj = Game()
            obj.Board = Game.new_board();
            obj.GameState = struct(...
                'WhiteARookMove', false,...
                'BlackARookMove', false,...
                'WhiteHRookMove', false,...
                'BlackHRookMove', false,...
                'WhiteKingMove', false,...
                'BlackKingMove', false,...
                'WhiteEnPassant', false,...
                'BlackEnPassant', false);
            obj.Figure = figure;
            pseudo_x = [1 2];
            pseudo_y = [1 2];
            obj.MoveIndicator = plot(pseudo_x, pseudo_y, 'o');
            obj.MoveIndicator.XData = [];
            obj.MoveIndicator.YData = [];
            obj.SelectedPieceCoord = [];
            obj.Figure.WindowButtonDownFcn = {@Game.board_click, obj};
        end
        
        function [piece] = get_piece(self, coords)
            cell = self.Board(coords(1), coords(2));
            piece = cell{1};
        end
        
        function [] = set_piece(self, coords, val)
            self.Board(coords(1),coords(2)) = {val};
        end
        
        function [] = move_piece(self, start_coords, end_coords)
            %MOVE Summary of this function goes here
            %   Detailed explanation goes here
            self.set_piece(end_coords, self.get_piece(start_coords));
            self.set_piece(start_coords, {});
        end
        
        function [moves] = get_piece_moves(self, coords)
            moves = [];
            piece = self.get_piece(coords);
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
                if (piece.Color == 'w' && coords(1) == 2) || (piece.Color == 'b' && coords(1) == 7)
                    moves = [moves; front_coords + [walk_direction 0]];
                end
                moves = [moves; front_coords];
                eat_coords = [coords + [walk_direction -1]; coords + [walk_direction 1]];
                for i = 1:size(eat_coords,1)
                    eat_piece = self.get_piece(eat_coords);
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
            moves = [moves; self.expand_moves_in_move_directions(coords, move_directions)];
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
                if ~Game.is_in_bounds(move)
                    continue;
                end
                target = self.get_piece(move);
                if ~isempty(target)
                    if target.Color == color
                        continue;
                    end
                end
                filtered_moves = [filtered_moves; move];
            end
            moves = filtered_moves;
        end
        
        function [moves] = get_piece_legal_moves(self, coords)
            moves = self.get_piece_moves(coords);
            filtered_moves = [];
            for i = 1:size(moves,1)
                move = moves(i,:);
                self.move_piece(coords, move);
                posible_eat_piece = self.get_piece(move);
                is_checked = self.is_king_checked(color);
                self.move_piece(move, coords);
                self.set_piece(move, posible_eat_piece);
                if is_checked
                    continue;
                end
                filtered_moves = [filtered_moves; move];
            end
            moves = filtered_moves;
        end
        
        function [] = draw_board(self)
            hold on;
            for i = 1:8
                for j = 1:8
                    coords = [i j];
                    
                    draw_piece(self, coords);
                end
            end
        end
        
        function [l] = draw_piece(self, coords )
            figure(self.Figure);
            piece = self.get_piece(coords);
            if isempty(piece)
                return
            end
            p = [];
            piece_type = piece.PieceType;
            switch piece_type
                case 'p'
                    p = [0,-0.950;0,-0.9;0.4,-0.350;0.3,-0.250;0.3,-0.1;0.4,0;0.550,0;0.650,-0.1;0.650,-0.250;0.550,-0.350;0.950,-0.9;0.950,-0.950;0,-0.950];
                case 'r'
                    p = [0,-0.950;0,-0.8;0.3,-0.8;0.3,-0.250;0,-0.250;0,0;0.150,0;0.150,-0.1;0.4,-0.1;0.4,0;0.550,0;0.550,-0.1;0.8,-0.1;0.8,0;0.950,0;0.950,-0.250;0.650,-0.250;0.650,-0.8;0.950,-0.8;0.950,-0.950;0,-0.950];
                case 'b'
                    p = [0,-0.950;0.4,-0.550;0.350,-0.4;0.350,-0.150;0.450,0;0.5,0;0.6,-0.150;0.6,-0.250;0.5,-0.250;0.6,-0.250;0.6,-0.4;0.550,-0.550;0.4,-0.550;0.550,-0.550;0.950,-0.950;0,-0.950];
                case 'n'
                    p = [0,-0.950;0.05,-0.8;0.250,-0.8;0.550,-0.250;0.150,-0.3;0.150,-0.150;0.4,0;0.5,0;0.5,-0.150;0.5,0;0.8,0;0.850,-0.05;0.850,-0.8;0.250,-0.8;0.9,-0.8;0.950,-0.950;0,-0.950];
                case 'k'
                    p = [0,-0.950;0.4,-0.5;0.3,-0.4;0.4,-0.3;0.450,-0.3;0.450,-0.150;0.350,-0.150;0.350,-0.1;0.450,-0.1;0.450,0;0.5,0;0.5,-0.1;0.6,-0.1;0.6,-0.150;0.5,-0.150;0.5,-0.3;0.450,-0.3;0.550,-0.3;0.650,-0.4;0.550,-0.5;0.4,-0.5;0.550,-0.5;0.950,-0.950;0,-0.950];
                case 'q'
                    p = [0,-0.950;0.350,-0.750;0.450,-0.750;0.450,-0.350;0.4,-0.350;0.350,-0.3;0.4,-0.250;0.4,-0.2;0.350,-0.150;0.350,-0.1;0.450,0;0.5,0;0.6,-0.1;0.6,-0.150;0.550,-0.2;0.550,-0.250;0.6,-0.3;0.550,-0.350;0.450,-0.350;0.5,-0.350;0.5,-0.750;0.950,-0.950;0,-0.950];
            end
            p = p + coords * [0 1; 1 0] + [-0.5 0.5];
            l = plot(p(:,1),p(:,2));
            l.Color = [0 0 0];
            l.LineJoin = 'round';
            l.LineWidth = 1;
        end
        
        function [moves] = expand_moves_in_move_directions(self, coords, move_directions)
            moves = [];
            for i = 1:size(move_directions,1)
                walk_coord = coords;
                while true
                    walk_coord = walk_coord + move_directions(i,:);
                    if ~Game.is_in_bounds(walk_coord)
                        break
                    end
                    if ~isempty(self.get_piece(walk_coord))
                        break
                    end
                    moves = [moves; walk_coord];
                end
            end
        end
        
        function [is_checked] = is_king_checked(self, color)
            is_checked = true;
            opp_color = Game.opposite_color(color);
            king_pos = [];
            for i = 1:8
                for j = 1:8
                    piece = self.get_piece([i j]);
                    if isempty(piece)
                        continue
                    end
                    if piece.PieceType == 'k' && piece.Color == color
                        king_pos = [i j];
                        break;
                    end
                end
            end
            for i = 1:8
                for j = 1:8
                    piece = self.get_piece([i j]);
                    if isempty(piece)
                        continue
                    end
                    if piece.Color == opp_color
                        moves = self.get_piece_legal_moves([i j]);
                        for k = 1:length(moves)
                            if moves(k) == king_pos
                                return;
                            end
                        end
                    end
                end
            end
            is_checked = false;
        end
    end
    
    methods(Static)
        function [board] = new_board()
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
        end
        
        function [opp_color] = opposite_color(color)
            opp_color = 'b';
            if color == 'b'
                opp_color = 'w';
            end
        end
        
        function [b] = is_in_bounds(coords)
            i = coords(1);
            j = coords(2);
            b = true;
            if i > 8 || i < 1 || j > 8 || j < 1
                b = false;
            end
        end
        
        function board_click(~, ~, self)
            mouse_pos = get(0,'PointerLocation');
            fig = self.Figure;
            fig_pos = fig.Position;
            axes = fig.Children;
            axes.Units = 'Pixels';
            axes_pos = axes.Position;
            axes_width = 9/8*(axes_pos(3) - axes_pos(1));
            axes_height = 9/8*(axes_pos(4) - axes_pos(2)); % I have no clue why coords are off :/
            relative_mouse_pos = mouse_pos - axes_pos(1:2) - fig_pos(1:2);
            mouse_coord = round(8*[relative_mouse_pos(2)/axes_height, relative_mouse_pos(1)/axes_width]);
            
            if isempty(self.SelectedPieceCoord)
                moves = self.get_piece_moves(mouse_coord);
                if isempty(moves)
                    return
                end
                l = self.MoveIndicator;
                l.XData = moves(:,2);
                l.YData = moves(:,1);
                self.SelectedPieceCoord = mouse_coord;
            else
                moves = self.get_piece_moves(self.SelectedPieceCoord);
                self.MoveIndicator.XData = [];
                self.MoveIndicator.YData = [];
                for i = 1:length(moves)
                    if mouse_coord == moves(i)
                        self.move_piece(self.SelectedPieceCoord, mouse_coord);
                        self.SelectedPieceCoord = [];
                        return;
                    end
                end
                moves = self.get_piece_moves(mouse_coord);
                if isempty(moves)
                    return
                end
                l = self.MoveIndicator;
                l.XData = moves(:,2);
                l.YData = moves(:,1);
                self.SelectedPieceCoord = mouse_coord;
            end
                        
        end
        
    end
end
