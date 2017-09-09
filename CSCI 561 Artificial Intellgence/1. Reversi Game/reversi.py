#!/usr/bin/env python
#-*- coding: utf8 -*-
import copy
import sys

class GameTreeNode:	
	weight = [
		[99, -8, 8, 6, 6, 8, -8, 99], 
		[-8, -24, -4, -3, -3, -4, -24, -8],
		[8, -4, 7, 4, 4, 7, -4, 8],
		[6, -3, 4, 0, 0, 4, -3, 6],
		[6, -3, 4, 0, 0, 4, -3, 6],
		[8, -4, 7, 4, 4, 7, -4, 8],
		[-8, -24, -4, -3, -3, -4, -24, -8],
		[99, -8, 8, 6, 6, 8, -8, 99]
		]

	def __init__(self, depth, move, board, curr_player, root_player):
		self.depth = depth
		self.move = move
		self.board = board
		self.curr_player = curr_player
		self.root_player = root_player
		self.eval = -sys.maxint if depth % 2 == 0 else sys.maxint
		self.children = []

	def display_eval(self):
		if self.eval == sys.maxint:
			return "Infinity"
		elif self.eval == -sys.maxint:
			return "-Infinity"
		else:
			return str(self.eval)

	def display_move(self):
		if self.move == [-1, -1]:
			return "root"
		elif self.move == [-2, -2]:
			return "pass"
		else:
			return chr(ord('a') + self.move[1]) + str(self.move[0] + 1)

	def evaluation(self):
		val = 0
		for i in xrange(8):
			for j in xrange(8):
				val += self.board[i][j] * self.weight[i][j]
		self.eval = val * self.root_player

def dispaly(num):
	if num == sys.maxint:
		return "Infinity"
	elif num == -sys.maxint:
		return "-Infinity"
	else:
		return str(num)

def get_current_piece(fname):
	board = []
	with open(fname, "rb") as input_file:
		curr_player = 1 if input_file.readline().splitlines()[0] == 'X' else -1
		search_depth = int(input_file.readline().splitlines()[0])
		for line in input_file:
			curr_line = []
			for tile in line:		
				if tile == "O":
					curr_line.append(-1)
				if tile == "X":
					curr_line.append(1)
				if tile == "*":
					curr_line.append(0)
			board.append(curr_line)
	return [curr_player, search_depth, board]

def get_possible_moves(curr_player, board):
	directions = [[-1, -1], [0, -1], [+1, -1], [-1, 0], [+1, 0], [-1, +1], [0, +1], [+1, +1]]
	possible_move = {} #{(2, 3):[[2, 7], [3, 4]], [2, 5]:[[], []]}
	for i in xrange(8):
		for j in xrange(8):
			if board[i][j] == 0:
				for direction in directions:
					row, col = i + direction[0], j + direction[1]
					if row >= 0 and row < 8 and col >= 0 and col < 8 and board[row][col] == - curr_player:
						end = follow_direction(i, j, curr_player, direction, board)
						if end:
							if (i, j) in possible_move:
								possible_move[(i, j)].append([end, direction])
							else:
								possible_move[(i, j)] = [[end, direction]]
	return possible_move

def follow_direction(row, col, curr_player, direction, board):
	x, y = row + direction[0], col + direction[1]
	while x >= 0 and x < 8 and y >= 0 and y < 8 and board[x][y] == - curr_player:
		x += direction[0]
		y += direction[1]
	if x >= 0 and x < 8 and y >= 0 and y < 8 and board[x][y] == curr_player:
		return [x, y]
	else:
		return None

def choose_next_move(next_move , infos, curr_player, board):
	for end_direction in infos:
		x, y = next_move[0], next_move[1]
		end, direction = end_direction[0], end_direction[1]
		end_x, end_y = end[0], end[1]
		while x != end_x or y != end_y:
			board[x][y] = curr_player
			x += direction[0]
			y += direction[1]
	return board

def generate_children(game_tree_node):
	possible_move = get_possible_moves(game_tree_node.curr_player, game_tree_node.board)
	children_nodes = []
	if possible_move:
		for next_move in sorted(possible_move.keys()):
			new_board = choose_next_move(next_move, possible_move[next_move], game_tree_node.curr_player, copy.deepcopy(game_tree_node.board))
			node =  GameTreeNode(game_tree_node.depth+1, next_move, new_board, -game_tree_node.curr_player, game_tree_node.root_player)
			children_nodes.append(node)
	else:
		new_board = copy.deepcopy(game_tree_node.board)
		node =  GameTreeNode(game_tree_node.depth+1, [-2, -2], new_board, -game_tree_node.curr_player, game_tree_node.root_player)
		children_nodes.append(node)
	return children_nodes
		

def game_tree(fname):
	# move [-1, -1] root [-2, -2] pass
	buff = []
	[root_player,search_depth, board] = get_current_piece(fname)
	root = GameTreeNode(0, [-1, -1], board, root_player, root_player)
	buff.append("Node,Depth,Value,Alpha,Beta")
	generate_game_tree(root, search_depth, True, -sys.maxint, sys.maxint, root.curr_player, buff)
	with open("output.txt","w") as f:
		for child in root.children:
			if root.eval == child.eval:
				for row in child.board:
					line = ""
					for col in row:
						if col == 0:
							line += "*"
						if col == -1:
							line += "O"
						if col == 1:
							line += "X"
					f.writelines(line+'\n')
				break
		for lines in buff[:-1]:
			f.write(lines+'\n')
		f.write(buff[-1])

def generate_game_tree(root, depth, continue_generate, alpha, beta, player, buff):
	if root and depth > 0 and continue_generate:
		buff.append(root.display_move()+","+str(root.depth)+","+root.display_eval()+","+dispaly(alpha)+","+dispaly(beta))
		children_nodes = generate_children(root)
		for child in children_nodes:
			if child.move == root.move:
				generate_game_tree(child, depth-1, False, alpha, beta, player, buff)
			else:
				generate_game_tree(child, depth-1, True, alpha, beta, player, buff)
			if root.curr_player == player: #max
				root.eval = max(root.eval, child.eval)
				root.children.append(child)
				if root.eval >= beta:
					buff.append(root.display_move()+","+str(root.depth)+","+root.display_eval()+","+dispaly(alpha)+","+dispaly(beta))
					break
				alpha = max(alpha, root.eval)
			else:
				root.eval = min(root.eval, child.eval)
				root.children.append(child)
				if root.eval <= alpha:
					buff.append(root.display_move()+","+str(root.depth)+","+root.display_eval()+","+dispaly(alpha)+","+dispaly(beta))
					break
				beta = min(beta, root.eval)
			buff.append(root.display_move()+","+str(root.depth)+","+root.display_eval()+","+dispaly(alpha)+","+dispaly(beta))
	else:
		root.evaluation()
		buff.append(root.display_move()+","+str(root.depth)+","+root.display_eval()+","+dispaly(alpha)+","+dispaly(beta))

game_tree("input.txt")

