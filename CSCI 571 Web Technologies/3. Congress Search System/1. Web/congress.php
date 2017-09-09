<?php
if(isset($_GET['congressDB'])){
	if($_GET['congressDB']=="Legislators"){
    $url="http://104.198.0.197:8080/legislators?&per_page=all";
	}
	if($_GET['congressDB']=="BillsActive"){
	    $url="http://104.198.0.197:8080/bills?history.active=true&last_version.urls.pdf__exists=true&per_page=50";
	}
	if($_GET['congressDB']=="BillsNew"){
	    $url="http://104.198.0.197:8080/bills?history.active=false&last_version.urls.pdf__exists=true&per_page=50";
	}
	if($_GET['congressDB']=="Committees"){
	    $url="http://104.198.0.197:8080/committees?&per_page=all";
	}	
}
if(isset($_GET['LegislatorsCommittees'])){
	$bioguide_id = $_GET['LegislatorsCommittees'];
    $url="http://104.198.0.197:8080/committees?member_ids=".$bioguide_id."&per_page=5";
}
if(isset($_GET['LegislatorsBills'])){
	$bioguide_id = $_GET['LegislatorsBills'];
    $url="http://104.198.0.197:8080/bills?sponsor_id=".$bioguide_id."&per_page=5";
}
$json=file_get_contents($url);
echo $json; 
?>

