<?
require_once 'simple_html_dom.php';

function generate_snippet($html_file_path, $keyword){
	$GLOBALS['symbol'] = True;
	$GLOBALS['First'] = "";
	$GLOBALS['Buffer'] = "";
	$html = file_get_html($html_file_path);
	if($html == false){
		return "";
	}
	$body = $html->find("body", 0);
	iter_find_item($body, $keyword);
	
	if($GLOBALS['First'] != ""){
		$result = $GLOBALS['First'];
	}
	else{
		$result = $GLOBALS['Buffer'];
	}
	return trim($result);
}

function iter_find_item(simple_html_dom_node $node, $keyword){
	if($node && $GLOBALS['symbol']){
		foreach($node->find("*") as $elem){
			iter_find_item($elem, $keyword);
			$content = $elem->innertext();
			$illegal = "<>{/";
			if(false === strpbrk($content, $illegal) && $GLOBALS['symbol']){
				if (strpos(strtolower($content), strtolower($keyword)) !== false) {
					if($GLOBALS['symbol'] and $content){
						$temp = $content;
						if(strlen($temp) > 150){
							$temp = substr ($temp, 0, 150);
							$temp = trim($temp)."...";
						}
						if(strlen($keyword) != strlen(trim($content))){
							$GLOBALS['First'] = $temp;
							$GLOBALS['symbol'] = False;
						}
						if(!$GLOBALS['Buffer']){
							$GLOBALS['Buffer'] = $content;
						}
						return;
					}
				}		
			}
			if(!$GLOBALS['symbol']){
				return;
			}
		}
	}
}

	echo generate_snippet("ABCNewsDownloadData/1afc0a4c-91e9-4c88-a4c9-61cffe46adda.html","desktop");
?>