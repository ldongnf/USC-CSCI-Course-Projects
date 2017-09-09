#!/usr/bin/env python
#-*- coding: utf8 -*-
import random
import time

def generate_CNF(fname):
	clause = {}
	with open(fname, "r") as f:
		[no_people, no_table] = map(int, f.readline().split(' '))
		clause = generate_Default(no_people, no_table)
		for line in f:
			[guest_x, guest_y, relation] = line.rstrip().split(' ')
			temp = generate_Relation(int(guest_x), int(guest_y), relation, no_table)
			clause = dict(clause.items() + temp.items())
	return [no_people, no_table, clause]

def generate_Default(No_people, No_table):
	clause = {}
	for guest in xrange(1, No_people + 1):
		for x in xrange(1, No_table):
			for y in xrange(x + 1, No_table + 1):
				clause[tuple(sorted([(guest, x, False), (guest, y, False)]))] = None
	temp = {}
	for guest in xrange(1, No_people + 1):
		unit = []
		for table in xrange(1, No_table + 1):
			unit.append((guest, table, True))
		temp[tuple(sorted(unit))] = None
	clause = dict(clause.items() + temp.items())
	return clause

def generate_Relation(x, y, relation, No_table):
	clause = {}
	if relation == "E":
		for i in xrange(1, No_table + 1):
			clause[tuple(sorted([(x, i, False), (y, i, False)]))] = None
	if relation == "F":
		for i in xrange(1, No_table + 1):
			clause[tuple(sorted([(x, i, False), (y, i, True)]))] = None
			clause[tuple(sorted([(x, i, True), (y, i, False)]))] = None
	return clause

def print_clauses(clauses):
	for clause in sorted(clauses):
		str_term = ""
		for term in clause:
			negation = term[2]
			variable = [term[0], term[1]]

			if negation:
				str_term += " "
			else:
				str_term += "~"
			str_term += "X%d%d"%(variable[0], variable[1])
			str_term += " V "
		str_term = str_term[:-3]
		print str_term

# WALKSAT
def walk_SAT(clauses, p = 0.5, max_filps = 10000):
	model = dict([s, random.choice([True, False])] for s in get_symbols(clauses))
	for i in xrange(max_filps):
		[satisfied, unsatisfied] = judge_clause(clauses, model)
		if not unsatisfied:
			return model
		clause = random.choice(unsatisfied)
		
		if random.random() < p:
			sym = random.choice(list(get_symbols([clause])))
			model[sym] = not model[sym]
		else:
			sym = get_symbol_maximize(unsatisfied, model)
			model[sym] = not model[sym]
	return None

def get_symbol_maximize(unsatisfied, model):
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

def get_symbols(clauses):
	symbol = set()
	for clause in clauses:
		for term in clause:
			symbol.add((term[0], term[1]))
	return symbol

def judge_clause(clauses, model):
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
	"""
	print "model",model
	print
	print "sat",satisfied
	print 
	print "un",unsatisfied
	"""
	return satisfied,unsatisfied

def generate_res(model):
	if not model:
		print "No"
		return
	for item in sorted(model):
		if model[item]:
			print item

def walksat_test():
	print "walkSat Test"
	""""""
	print "input1.txt"
	[no_people, no_table, clause] = generate_CNF("input1.txt")
	model =  walk_SAT(clause)
	generate_res(model)

	print "input2.txt"
	[no_people, no_table, clause] = generate_CNF("input2.txt")
	model =  walk_SAT(clause)
	generate_res(model)

	print "input3.txt"
	[no_people, no_table, clause] = generate_CNF("input3.txt")
	model =  walk_SAT(clause)
	generate_res(model)
	
	print "input4.txt"
	[no_people, no_table, clause] = generate_CNF("input4.txt")
	model =  walk_SAT(clause)
	generate_res(model)
	
	
	print "input5.txt"
	[no_people, no_table, clause] = generate_CNF("input5.txt")
	model =  walk_SAT(clause)
	generate_res(model)
	
# PL_RESOLUTION
def cut_off_tautologies(clause):
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

def pl_resolution(clauses):
	new = {}
	timeout = time.time() + 60*2
	while True:
		time.sleep(1)

		keys = clauses.keys()
		for i in xrange(len(keys) - 1):
			for j in xrange(i + 1, len(keys)):
				#print time.time(),timeout
				if time.time() > timeout:
					return True
				resolvents = pl_resolve(keys[i], keys[j])
				if not all(resolvents):
					return False
				
				for res in resolvents:
					res = cut_off_tautologies(res)
					if res and res not in new:
						new[res] = None

		length = len(clauses)
		clauses = dict(clauses.items() + new.items())
		if len(clauses) >= 2000:
			return True
		#print len(clauses)
		if len(clauses) <= length:
			#print 
			#print "final"
			#print_clauses(clauses)	
			return True
		
def pl_resolve(clause1, clause2):
 	complementary = []
 	for term in clause1:
 		#print term
 		temp = (term[0], term[1], not term[2])
 		if temp in clause2:
 			complementary.append(term)

 	if complementary:
 		new_clauses = []
 		for term in complementary:
 			temp = list(clause1[:] + clause2[:])
	 		#print "temp",temp
	 		temp.pop(temp.index(term))
	 		temp.pop(temp.index((term[0], term[1], not term[2])))
	 		new_clauses.append(tuple(temp))
	 		#print "temp",temp 		
	 	return new_clauses
	else:
	 	return [clause1, clause2]

def pl_test():
	print "PL Test"
	
	print "input1.txt"
	[no_people, no_table, clause] = generate_CNF("input1.txt")
	print pl_resolution(clause)

	print "input2.txt"
	[no_people, no_table, clause] = generate_CNF("input2.txt")
	print pl_resolution(clause)
	""""""
	print "input3.txt"
	[no_people, no_table, clause] = generate_CNF("input3.txt")
	print pl_resolution(clause)
	
	print "input4.txt"
	[no_people, no_table, clause] = generate_CNF("input4.txt")
	print pl_resolution(clause)
	
	print "input5.txt"
	[no_people, no_table, clause] = generate_CNF("input5.txt")
	print pl_resolution(clause)
	""""""

def main(fname):
	with open("out"+fname[2:],"w") as f:
		[no_people, no_table, clause] = generate_CNF(fname)
		if pl_resolution(clause):
			model =  walk_SAT(clause)
			#generate_res(model)
			if not model:
				f.wirte("no\n")
				return
			f.write("yes\n")
			for item in sorted(model):
				if model[item]:
					#print item
					f.write("%d %d\n" %(item[0], item[1]))
		else:
			f.write("no\n")
			#print "NO"

if __name__== "__main__":
	#pl_test()
	#walksat_test()
	#for i in xrange(1,6):
		#print "input%s.txt"%i
		#main("input%s.txt"%i)
	main("input.txt")


