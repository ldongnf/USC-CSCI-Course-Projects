<?php
    if($_GET['auto']=="autocomplete"){
        if(isset($_REQUEST['query'])){
            $url = "http://localhost:8983/solr/myexample/suggest?wt=json&q=".urlencode($_REQUEST['query']);
            $json =file_get_contents($url);
            echo $json; 
        }
    }
?>