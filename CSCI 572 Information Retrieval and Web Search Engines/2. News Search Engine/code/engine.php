<?php
header('Content-Type: text/html; charset=utf-8');
ini_set('memory_limit','-1');
require_once 'SpellCorrector.php';
require_once 'Snippet.php';

// setup the dictionary
$csvFile = file("urls.csv");
$data = [];
foreach ($csvFile as $line) {
	$data[] = str_getcsv($line);
}

$dictionary = array();

foreach($data as $value){
	$file_name = $value[0];
	$dictionary[$file_name] = $value[1];
}



$limit = 10;

$rankAlgorithm = isset($_REQUEST['rankAlgorithm']) ? $_REQUEST['rankAlgorithm'] : "";

$query = isset($_REQUEST['q']) ? $_REQUEST['q'] : false;

$results = false;

$eorror_string = "";

if ($query)
{
	$real_query = $query;

	if(isset($_REQUEST['symbol'])){
		$words = explode(" ", $real_query);
		$corrections = "";
		foreach($words as $word){
			$corrections = $corrections.SpellCorrector::correct($word)." ";
		}

		$corrections = trim($corrections);
		if(strtolower($corrections) != strtolower($real_query)){
			$new_query_url = "engine.php?q=".$query."&rankAlgorithm=".$rankAlgorithm;
			$new_query_url = str_replace(" ", "+", $new_query_url);
			$eorror_string .= "Showing the result for: ".$corrections.".<br>Seach <a href=".$new_query_url.">".$query."</a> instead.<br><br>";
			$query = $corrections;
			$real_query = $query;
		}
	}

	$query = "_text_:" . $query;

	require_once('Apache/Solr/Service.php');
	$solr = new Apache_Solr_Service('localhost', 8983, '/solr/myexample');

	try{
		if($rankAlgorithm == "PageRank"){
			$additionalParameters = array(
				'fl' => array('id','title','description'),
				"sort" => "pageRankFile desc"
			);
		}
		else{
			$additionalParameters = array(
				'fl' => array('id','title','description')
			);
		}

		$query = str_replace(" ", "+", $query);
		$results = $solr->search($query, 0, $limit, $additionalParameters);
	}
	catch (Exception $e){
		die("<html><head><title>SEARCH EXCEPTION</title><body><pre>{$e->__toString()}</pre></body></html>");
	}
}

?>

<html>
	<head>
		<title>News Search Engine</title>
	</head>
	<body>
		<form  accept-charset="utf-8" method="get">
			<label for="q">Search:</label>
			<input id="q" name="q" type="text" value="<?php
				echo htmlspecialchars($real_query, ENT_QUOTES, 'utf-8'); 
			?>"/>

			<input type="radio" name="rankAlgorithm"
			<?php if (isset($rankAlgorithm) && $rankAlgorithm=="Lucene") echo "checked";?>
			value="Lucene" checked>Lucene

			<input type="radio" name="rankAlgorithm"
			<?php if (isset($rankAlgorithm) && $rankAlgorithm=="PageRank") echo "checked";?>
			value="PageRank">PageRank
			<input type="hidden" name="symbol" value="true"/>
			<input type="submit"/>
		</form>

		<?php

		if ($results){
			echo $eorror_string;
			
			$total = (int) $results->response->numFound;
			$start = min(1, $total);
			$end = min($limit, $total);

			echo "<div>Results ".$start." - " .$end." of ".$total.":</div>";
			echo "<ol>";

			foreach ($results->response->docs as $doc)
			{
				echo "<li><table style='border: 1px solid black; text-align: left'>";

				$raw_id = $doc->getField("id")["value"];
				$res_id = end(explode("/", $raw_id));

				$res_url = $dictionary[$res_id];
				echo "<tr><th>ID</th>";
				echo "<td>".$raw_id."</td></tr>";

				echo "<tr><th>URL</th>";
				echo "<td><a target='_blank' href='".$res_url."'>".$res_url."</a><td></tr>";

				$res_title = $doc->getField("title")["value"];
				echo "<tr><th>Title</th>";
				echo "<td><a target='_blank' href='".$res_url."'>".$res_title."</a><td></tr>";

				$res_description = $doc->getField("description")["value"];
				echo "<tr><th>Description</th>";
				echo "<td>".$res_description."</td></tr>";

				$result = generate_snippet("ABCNewsDownloadData/".$res_id, $real_query);
				if($result == ""){
					if(strpos(strtolower($res_description), strtolower($real_query)) !== false){
						$result = $res_description;
					}
				}
				echo "<tr><th>Snippet</th>";
				echo "<td>".$result."</td></tr>";
				echo "</table></li><br>";
			}
			echo "</ol>";
		}

		?>
	</body>
	<script type = "text/javascript" src = "https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
	<link href="http://code.jquery.com/ui/1.10.2/themes/smoothness/jquery-ui.css" rel="Stylesheet"></link>
	<script src="http://code.jquery.com/ui/1.10.2/jquery-ui.js" ></script>
    <script src="./script.js"></script>
</html>