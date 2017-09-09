#!/usr/bin/env python
#-*- coding: utf8 -*-
import re
import copy

class Bayesian_Network_Node:
	def __init__(self, name, parents=[], cpt={}):
		self.name = name
		self.parents = parents
		self.children = []
		self.cpt = cpt

	def get_prob(self, value, assignment):
		parents_assignment = tuple([])
		if self.parents:
			parents_assignment = assign_value(self.parents, assignment)
		var_true = self.cpt[tuple(self.parents)][parents_assignment]
		return var_true if value else 1 - var_true

class Bayesian_Network:
	def __init__(self):
		self.roots = []
		self.leaves = []
		self.decision = []
		self.node_map = {}
		self.toplogical_order = []

	def init_decision_nodes(self, envidence):
		for node_name in self.decision:
			node = self.get_node(node_name)
			node.cpt = {():{():float(envidence[node_name])}}

	def add_from_relation(self, relation, cpt={}):
		if '|' not in relation:
			name = relation
			node = Bayesian_Network_Node(name, [], cpt)
			self.node_map[name] = node
			self.roots.append(name)
		else:
			name, parents = map(str.strip, relation.split('|'))	
			parents = map(str.strip, parents.split(' '))
			node = Bayesian_Network_Node(name, parents, cpt)
			self.node_map[name] = node
			for node_name in parents:
				if node_name in self.leaves:
					self.leaves.pop(self.leaves.index(node_name))
				parents_node = self.node_map[node_name]
				parents_node.children.append(name)
		self.leaves.append(name)

	def order_vairables_bottom_up(self, variable_names):
		if not self.toplogical_order:
			self.get_toplogical_order()
		result = [var for var in self.toplogical_order if var in variable_names]

		return result[::-1]

	def get_toplogical_order(self):
		if self.toplogical_order:
			return self.toplogical_order

		temp = copy.deepcopy(self)
		ordering = []
		while temp.roots:
			node_name = temp.roots.pop(0)
			ordering.append(node_name)
			for child in temp.get_node(node_name).children:
				child_node = temp.get_node(child)
				child_node.parents.pop(child_node.parents.index(node_name))
				if not child_node.parents:
					temp.roots.append(child)
		self.toplogical_order = ordering
		return ordering

	def add_from_relations(self, relations):
		for relation in relations:
			self.add_from_relation(relation)

	def get_node(self, variable_name):
		return self.node_map[variable_name]

	def get_prob(self, variable_name, value, envidence):
		return self.get_node(variable_name).get_prob(value, envidence)

	def get_related_variables(self, variable_names):
		realted_vars = []
		hidden_vars = []
		explored_vars = []
		
		candidate_vars = variable_names

		while candidate_vars:
			new_candidate_vars = []

			for candidate_variable in candidate_vars:
				if candidate_variable not in explored_vars:
					explored_vars.append(candidate_variable)

					if candidate_variable not in variable_names:
						hidden_vars.append(candidate_variable)
					else:
						realted_vars.append(candidate_variable)
					
					if candidate_variable not in self.roots:
						node = self.node_map[candidate_variable]
						parent_vars = node.parents

						for parent_variable in parent_vars:
							if parent_variable not in explored_vars:
								new_candidate_vars.append(parent_variable)
			candidate_vars = new_candidate_vars

		return realted_vars, hidden_vars

class Factor:
	def __init__(self, variables=[], table={}):
		self.variables = variables
		self.table = table

	def get_prob(self, envidence):
		return self.table[assign_value(self.variables, envidence)]

	def feed_factor(self, target_name, envidence, bayesian_network):
		node = bayesian_network.get_node(target_name)
		variables = [var for var in [target_name] + node.parents if var not in envidence]
		
		table = {}
		for assigment in generate_assignments(variables, envidence):
			key = assign_value(variables, assigment)
			table[key] = node.get_prob(assigment[target_name], assigment)

		self.variables = variables
		self.table = table

	def pointwise_product(self, other_factor, bayesian_network):
		variables = list(set(self.variables) | set(other_factor.variables))
		table = {}

		for assignment in generate_assignments(variables, {}):
			table[assign_value(variables, assignment)] = self.get_prob(assignment) * other_factor.get_prob(assignment)
		return Factor(variables, table)

	def eliminate_by_sum_out(self, target, bayesian_network):
		variables = [var for var in self.variables if var != target]
		table = {}
		for assignment in generate_assignments(variables, {}):
			table[assign_value(variables, assignment)] = sum([self.get_prob(dict(assignment.items()+{target:label}.items())) for label in [True, False]])
		return Factor(variables, table)

	def normalize(self):
		total = sum([self.table[assignment] for assignment in self.table])
		if total != 1.0:
			for assignment in self.table:
				 self.table[assignment] = self.table[assignment] / total
		return self

def generate_queries(raw_queries):
	queries = []
	for line in raw_queries:
		if line:
			data = line[:-1]
			query_type, variables = data.split('(')
			
			pieces = variables.split('|')
			children_vars = pieces[0]
			parent_vars = ""
			if len(pieces) > 1:
				parent_vars = pieces[1]

			children_nodes = children_vars.split(',')
			parent_nodes = parent_vars.split(',')

			children_dict = {}
			for node in children_nodes:
				if node:
					if query_type in ["P", "EU"]:
						node_name, prob = map(str.strip, node.split('='))
						if prob == "+":
							children_dict[node_name] = True
						else:
							children_dict[node_name] = False
					else:
						node_name = node.strip()
						children_dict[node_name] = None

			parent_dict = {}
			for node in parent_nodes:
				if node:
					node_name, prob = map(str.strip, node.split('='))

					if prob == "+":
						parent_dict[node_name] = True
					else:
						parent_dict[node_name] = False

			queries.append((query_type, children_dict, parent_dict))
	return queries

def generate_bayesian_network(raw_tables):
	bayesian_network = Bayesian_Network()
	for line in raw_tables:
		table = line.strip('\n').split('\n')
		relation = table[0]

		if '|' in relation:
			curr_var, parents_var = map(str.strip, relation.split('|'))
			parents_var = map(str.strip, parents_var.split(' '))

			cpt = {}
			truth = {}
			for row in table[1:]: 
				items = row.split(' ')
				prob = float(items[0])

				assignment = [item == "+" for item in items[1:]]
				
				truth[tuple(assignment)] = prob

			cpt[tuple(parents_var)] = truth
		else:
			cpt = {}
			if table[1] == 'decision':
				cpt[()]= {():1.0}
				bayesian_network.decision.append(relation)
			else:
				cpt[()] = {():float(table[1])}	
		bayesian_network.add_from_relation(relation, cpt)

	return bayesian_network

def generate_untility(raw_untility, bayesian_network):
	untility = {}
	title = raw_untility[1]

	if '|' in title:
		curr_var, parents_var = map(str.strip, title.split('|'))
		parents_var = map(str.strip, parents_var.split(' '))

		truth = {}
		for line in raw_untility[2:]:
			if line:
				items = line.split(' ')
				value = int(items[0])
				assignment = [item == "+" for item in items[1:]]
				

				truth[tuple(assignment)] = value
		untility[tuple(parents_var)] = truth

	bayesian_network.add_from_relation(title, untility)
	return untility

def init_problem(file_path):
	with open(file_path) as file:
		raw_text = file.read()
		raw_text = re.sub('\r', '', raw_text)
		raw_data = raw_text.split("******")
		raw_queries = raw_data[0]
		raw_tables = raw_data[1]

		queries = generate_queries(raw_queries.split('\n'))
		bayesian_network = generate_bayesian_network(raw_tables.split("***"))
		untility = []

		if len(raw_data) > 2:
			raw_untility = raw_data[2]
			untility = generate_untility(raw_untility.split('\n'), bayesian_network)
	return [queries, bayesian_network, untility]

def assign_value(variables, assignment):
	return tuple([assignment[var] for var in variables])

def generate_assignments(variables, envidence):
	if not variables:
		return [envidence]
	else:
		current_var, rest = variables[0], variables[1:]
		assignments = []
		for pre_assignment in generate_assignments(rest, envidence):
			assignments.append(dict(pre_assignment.items() + {current_var:True}.items()))
			assignments.append(dict(pre_assignment.items() + {current_var:False}.items()))
		return assignments

def pointwise_product(factors, bayesian_network):
    return reduce(lambda x, y: x.pointwise_product(y, bayesian_network), factors)

def eliminate_by_sum_out(target, factors, bayesian_network):
	result, var_factors = [], []
	for factor in factors:
		if target in factor.variables:
			var_factors.append(factor)
		else:
			result.append(factor)
	result.append(pointwise_product(var_factors, bayesian_network).eliminate_by_sum_out(target, bayesian_network))
	return result

def eliminate_ask(targets, envidence, bayesian_network):
	realted_vars, hidden_vars = bayesian_network.get_related_variables(targets.keys() + envidence.keys())
	ordered_vars = bayesian_network.order_vairables_bottom_up(realted_vars+hidden_vars)

	factors = []

	for var in ordered_vars:
		factor = Factor()
		factor.feed_factor(var, envidence, bayesian_network)
		factors.append(factor)

		if var in hidden_vars:
			factors = eliminate_by_sum_out(var, factors, bayesian_network)

	res_factor = pointwise_product(factors, bayesian_network).normalize()

	return res_factor

def solver(file_path):
	queries, bayesian_network, untility = init_problem(file_path)
	answer = []
	for query in queries:
		query_type, targets, envidence = query

		if query_type == "P":
			if bayesian_network.decision:
				bayesian_network.init_decision_nodes(dict(targets.items() + envidence.items()))
			factor = eliminate_ask(targets, envidence, bayesian_network)
			res = round(factor.get_prob(targets), 2)
			answer.append("%.2f"%res)

		elif query_type == "EU":
			query_type, targets, envidence = query

			targets = dict({'utility':True}.items() + targets.items())
			bayesian_network.init_decision_nodes(dict(targets.items() + envidence.items()))
			factor = eliminate_ask(targets, envidence, bayesian_network)
			res = int(round(factor.get_prob(targets),0))
			answer.append(str(res))
		
		else:
			query_type, targets, envidence = query
			targets_assignment = generate_assignments(['utility'] + targets.keys(), {})

			result = {}
			for sub_target in targets_assignment:
				bayesian_network.init_decision_nodes(sub_target)
				
				factor = eliminate_ask(sub_target, envidence, bayesian_network)
				result[tuple(sub_target.items())] = factor.get_prob(sub_target)

			res = list(max(result.items(), key=lambda item: item[1]))
			res[1] = int(round(res[1], 0))
			assignment = res[0]

			t_f = []
			for variable in assignment:
				if variable[0] == 'utility':
					continue
				if variable[1] == True:
					t_f.append("+")
				else:
					t_f.append("-")
			str_tf = " ".join(t_f) + " " + str(int(round(res[1], 0)))

			answer.append(str_tf)
	
	with open("output.txt","w") as file:
		for line in answer:
			file.write(str(line) + '\n')
	"""
	with open(re.sub("in", "out", file_path),"w") as file:
		for line in answer:
			file.write(str(line) + '\n')
	"""

solver("input.txt")

"""
for i in xrange(1,13):
	solver("./cases/input%s.txt"%str(i).rjust(2,'0'))
"""