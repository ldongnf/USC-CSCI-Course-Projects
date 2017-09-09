#!/usr/bin/env python
#-*- coding: utf8 -*-
import random
import time

class Clause:
	def __init__(self):
		self.clauses = {}
		self.counter = {}

	def __eq__(self, other):
		return self.clauses.items() == other.clauses.items()
	
	# Default Function
	# Add item
	def add(self, clauses):
		for clause in sorted(clauses):
			index = self.clauses.get(len(clause),{})
			index[tuple(clause)] = None
			self.clauses[len(clause)] = index
			for term in clause:
				self.counter[tuple(term)] = self.counter.get(tuple(term), 0) + 1

	# Reset Clause
	def reset(self):
		self.clauses = {}
		self.counter = {}

	# Generate
	def generate_counter(self):
		self.counter = {}
		for group in self.clauses.values():
			for clause in group:
				for term in clause:
					self.counter[term] = self.counter.get(term, 0) + 1
	
	def merge_clauses(self, target):
		# {1:{2:1},2:{((1,2),(3,4)):2}}
		# merge_clauses
		for key in target.clauses:
			self.clauses[key] = dict(self.clauses.get(key,{}).items() + target.clauses[key].items())
		self.generate_counter()

	def generate_whole_clauses(self):
		temp = []
		for clause in self.clauses.values():
			temp += clause.keys()
		return temp

	def generate_partial_clauses(self, keys):
		temp = []
		for key in keys:
			clause = self.clauses.get(key,[])
			if clause:
				temp += self.clauses[key].keys()
		return temp
	
	# Print
	def print_clauses(self):
		for index in sorted(self.clauses):
			print "clauses key length: ", index
			for clause in sorted(self.clauses[index]):
				str_term = ""
				for term in clause:
					negation = term[2]
					if negation:
						str_term += " "
					else:
						str_term += "~"
					str_term += "X%d%d"%(term[0], term[1])
					str_term += " V "
				str_term = str_term[:-3]
				print str_term

	def print_counter(self):
		for key in sorted(self.counter):
			str_literal = ""
			if key[2]:
				str_literal += " "
			else:
				str_literal += "~"
			str_literal += "X%d%d"%(key[0], key[1])
			print str_literal, self.counter[key]

	def print_length(self):
		for key in self.clauses:
			print key, len(self.clauses[key])

	# CNF
	# Generate_CNF
	def generate_from_file(self, fname):
		with open(fname, "r") as f:
			[no_people, no_table] = map(int, f.readline().split(' '))
			self.generate_Default(no_people, no_table)
			for line in f:
				[guest_x, guest_y, relation] = line.rstrip().split(' ')
				self.generate_Relation(int(guest_x), int(guest_y), relation, no_table)
		if not self.clauses:
			return False
		self.generate_counter()
	
	def generate_Default(self, no_people, no_table):
		terms_only_one_table = [[(guest, x, False), (guest, y, False)] for guest in xrange(1, no_people + 1) for x in xrange(1, no_table) for y in xrange(x + 1, no_table + 1)]
		self.add(terms_only_one_table)

		terms_choose_one_table = [[(guest, table, True) for table in xrange(1, no_table + 1)] for guest in xrange(1, no_people + 1)]
		self.add(terms_choose_one_table)

	def generate_Relation(self, x, y, relation, no_table):
		if relation == "E":
			for i in xrange(1, no_table + 1):
				self.add([[(x, i, False), (y, i, False)]])
		if relation == "F":
			for i in xrange(1, no_table + 1):
				self.add([[(x, i, False), (y, i, True)]])
				self.add([[(x, i, True), (y, i, False)]])
	
	# DPLL
	# Unit_clause_rule
	def unit_clause_rule(self):
		self.counter = {}
		# remove the clause containing the unit literal
		# remove negated literal from clauses
		one_term_clauses = self.clauses.get(1,{})
		
		while one_term_clauses:
			if one_term_clauses:
				for clause in one_term_clauses:
					term = clause[0]
					if not self.remove_literals(term):
						return False
			one_term_clauses = self.clauses.get(1,{})
		self.generate_counter()

	def remove_literals(self, term):
		neg_term = list(term)
		neg_term[2] = not neg_term[2]
		neg_term = tuple(neg_term)

		new_clauses = Clause()

		for length_index in self.clauses:
			clauses = self.clauses[length_index]
			for key in clauses:
				if term not in key:
					# check whether negated in the key
					if neg_term in key:
						temp = list(key)
						temp.pop(key.index(neg_term))
						if not temp:
							#print "empty"
							return False
						new_clauses.add([temp])
					else:
						new_clauses.add([key])
		self.clauses = new_clauses.clauses
		return True

	# Pure_symbol_rule
	def pure_symbol_rule(self):
		while True:
			count = 0
			for key in self.counter:
				if self.counter[key] == 1:
					count += 1
					self.remove_unit_literal(key)
			self.counter = {}
			self.generate_counter()
			if count == 0:
				break

	def remove_unit_literal(self, term):
		new_clauses = Clause()
		for length_index in self.clauses:
			clauses = self.clauses[length_index]
			for key in clauses:
				if term not in key:
					new_clauses.add([key])
		self.clauses = new_clauses.clauses
		return True

	def resolution(self):
		timeout = time.time() + 60 * 2
		length = 0

		while True:
			one_term_clauses = self.clauses.get(1, [])
			if one_term_clauses:
				#print "UNIT_CLAUSE_RULE"
				if self.unit_clause_rule() == False:
					return False

				#print "PURE_SYMBOL_RULE"
				self.pure_symbol_rule()
				if not self.clauses:
					return True
				
			else:
				buff = self.generate_partial_clauses([2])
				curr_length = len(self.generate_partial_clauses([2]))
				
				#self.print_length()

				if curr_length <= length:
					return True
				length = curr_length
				
				for i in xrange(len(buff) - 1):
					for j in xrange(i + 1, len(buff)):
						#print time.time()
						if time.time() > timeout:
							return True
						resolvents = self.pl_resolve(buff[i], buff[j])
						if not all(resolvents):
							return False
						for res in resolvents:
							res = self.cut_off_tautologies(res)
							if res:
								self.add([res])

	def pl_resolve(self, clause1, clause2):
		complementary = []
	 	for term in clause1:
	 		#print term
	 		temp = (term[0], term[1], not term[2])
	 		if temp in clause2:
	 			complementary.append(term)
	 	#print complementary

	 	if complementary:
	 		new_clauses = []
	 		for term in complementary:
	 			temp = list(clause1[:] + clause2[:])
		 		#print "temp",temp
		 		temp.pop(temp.index(term))
		 		temp.pop(temp.index((term[0], term[1], not term[2])))
		 		new_clauses.append(tuple(temp))
		 		#print "after temp",new_clauses
		 		#print 	
		 	return new_clauses
		else:
		 	return [clause1, clause2]

	def cut_off_tautologies(self, clause):
		if len(clause) <= 1:
			return clause

		new_clause = []
		if len(clause) >= 2:
			for term in clause:
				temp = (term[0], term[1], not term[2])
				if term not in new_clause:
					if temp in new_clause:
						new_clause.pop(new_clause.index(temp))
						new_clause = []
						break
					else:
						new_clause.append(term)
		return tuple(sorted(new_clause))	
	
	
class SATSolver:
	def __init__(self, fname):
		self.KB = Clause()
		self.KB.generate_from_file(fname)

	# WALK_SAT
	def walk_SAT(self, probability = 0.5, max_filps = 10000):
		model = dict([s, random.choice([True, False])] for s in self.get_symbols(self.KB.generate_whole_clauses()))
		#print model
		for i in xrange(max_filps):
			[satisfied, unsatisfied] = self.judge_clause(self.KB.generate_whole_clauses(), model)
			if not unsatisfied:
				return model
			clause = random.choice(unsatisfied)
			
			if random.random() < probability:
				sym = random.choice(list(self.get_symbols([clause])))
				model[sym] = not model[sym]
			else:
				sym = self.get_symbol_maximize(unsatisfied, model)
				model[sym] = not model[sym]
		return None

	def get_symbol_maximize(self, unsatisfied, model):
		collection = [term for clause in unsatisfied for term in clause]
		#print collection
		max_count = 0
		term = None
		for item in model:
			result = model[item]
			temp = (item[0], item[1], True) if not result else (item[0], item[1], False)
			count = collection.count(temp)		
			if count > max_count:
				max_count = count
				term = temp
		#print max_count,term
		return (term[0], term[1])

	def get_symbols(self, clauses):
		symbol = set()
		for clause in clauses:
			for term in clause:
				symbol.add((term[0], term[1]))
		return symbol

	def judge_clause(self, clauses, model):
		satisfied, unsatisfied = [], []
		for clause in clauses:
			res = False
			for term in clause:
				if term[2]:
					res |= model[(term[0],term[1])] 
				else:
					res |= not model[(term[0],term[1])] 
			if res:
				satisfied.append(clause)
			else:
				unsatisfied.append(clause)
		return satisfied,unsatisfied

	def print_assignment(self, model):
		if not model:
			print "No"
			return
		for item in sorted(model):
			if model[item]:
				print item

def walksat_test():
	print "input1"
	solver = SATSolver("input1.txt")
	solver.generate_assignment(solver.walk_SAT())

	print "input2"
	solver = SATSolver("input2.txt")
	solver.generate_assignment(solver.walk_SAT())

	print "input3"
	solver = SATSolver("input3.txt")
	solver.generate_assignment(solver.walk_SAT())

	print "input4"
	solver = SATSolver("input4.txt")
	solver.generate_assignment(solver.walk_SAT())

	print "input5"
	solver = SATSolver("input5.txt")
	solver.generate_assignment(solver.walk_SAT())

def resolution_test():
	""""""
	print "input1"
	solver = SATSolver("input1.txt")
	print solver.KB.resolution()

	print "input2"
	solver = SATSolver("input2.txt")
	print solver.KB.resolution()
	
	print "input3"
	solver = SATSolver("input3.txt")
	
	#solver.KB.print_clauses()
	print solver.KB.resolution()
	
	""""""
	print "input4"
	solver = SATSolver("input4.txt")
	#solver.KB.print_clauses()
	print solver.KB.resolution()
	
	print "input5"
	solver = SATSolver("input5.txt")
	#solver.KB.print_clauses()
	print solver.KB.resolution()

def generate_result(fname):
	with open("out"+fname[2:],"w") as f:
		c = Clause()
		c.generate_from_file(fname)

		solver = SATSolver(fname)
	
		if c.resolution():
			model =  solver.walk_SAT()
			if not model:
				f.write("no\n")
				return
			f.write("yes\n")
			for item in sorted(model):
				if model[item]:
					f.write("%d %d\n" %(item[0], item[1]))
		else:
			f.write("no\n")

def main():
	for i in xrange(1,9):
		generate_result("input%s.txt"%i)

if __name__== "__main__":
	#walksat_test()
	#resolution_test()

	main()