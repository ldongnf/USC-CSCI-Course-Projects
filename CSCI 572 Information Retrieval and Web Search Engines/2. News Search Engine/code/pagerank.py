import networkx as nx

path = "/Users/admin/Desktop/HW4/data/ABCNewsData/ABCNewsDownloadData/"

G = nx.read_edgelist("edgeList.txt", create_using=nx.DiGraph())
pr = nx.pagerank(G, alpha=0.85, personalization=None, max_iter=30, tol=1e-06, nstart=None, weight='weight',dangling=None
 )

with open("pageranks.txt", "w") as file:
	filter_items = sorted(pr.items(), key=lambda item:item[1], reverse=True)
	for key, value in filter_items:
		file.write("%s%s=%f\n" % (path, key, value))