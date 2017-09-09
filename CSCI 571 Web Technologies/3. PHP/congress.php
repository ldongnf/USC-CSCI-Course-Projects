<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title>Forecast</title>
    <style type="text/css">
        #container{
            margin-left: auto;
            margin-right: auto;
            width: 900px;
        }
        #formContainer{
            margin:auto;
            text-align: center;
            width: 400px;
            padding-bottom: 5px;
        }

        #formtable{
            text-align: center;
            margin:auto;
            border-collapse: collapse;
        }
        #formtable td{border:none;}
        #resultArea{
            margin:auto;
            width: 800px;
        }

        .resultAreaFirstLevel{
            text-align: center;
            padding-top: 5px;
            margin:auto;
            width: 700px;
            padding-bottom: 10px;
        }
        .resultTableFirstLevel{
            border-collapse: collapse; 
            margin:auto;
            border:1px solid;
            text-align: center;
            width: 600px;
        }
            
        .resultTableFirstLevel td{
            border:1px solid;
            text-align: center
        }

        .resultTableFirstLevel td.nameOfLegislators{
            border:1px solid;
            text-align:left;
            width:250px;
        }
        span{
            //margin-left: 50px;
            width:200px;
            margin-left: 25px;
            margin-right: 25px;
            padding-left: 25px;
        }

        .resultTableFirstLevel th{
            border:1px solid;
            text-align: center;
        }
        .resultAreaSecondLevel{
            border: 1px solid;
            text-align: center;
            padding-top: 20px;
            margin:auto;
            width: 700px;
            padding-bottom: 10px;
        }

        .resultTableSecondLevel{
            border-collapse: collapse; 
            margin:auto;
            width:600px;
            text-align: left;
            border:none;
        }
        .resultTableSecondLevel td{
            border:none;
            padding-left: 20px;
            width: 300px;
        }
        .resultTableSecondLevel td.legislatorsFirstColumn{
            width:200px;
            padding-left: 80px;
        }
        .resultTableSecondLevel td.legislatorsSecondColumn{
            width:400px;
            padding-left: 70px;
        }
    </style>
    <script language="JavaScript"> 
    function changeKey(CongressDB){
        var selectDB = CongressDB.options[CongressDB.selectedIndex].value;
        var keyWord = document.getElementById("keyWordLable");
        var text = "";
        if(selectDB=="Legislators"){
            text = "State/Representative*";
        }
        if(selectDB=="Committees"){
            text = "Committee ID*";
        }
        if(selectDB=="Bills"){
            text = "Bill ID*";
        }
        if(selectDB=="Amendments"){
            text = "Amendment ID*";
        }
        keyWord.innerHTML = text;
    }
    function formValidation(form){
        if(form.congressDB.selectedIndex == 0||form.keyWord.value.trim() == ""){
            var text ="Please enter the following informaton: ";
            if(form.congressDB.selectedIndex == 0){
                text += "Congress Database, ";
            }
            if(form.keyWord.value.trim() == ""){
                text += "Keyword, ";
            }
            alert(text.substring(0,text.length-2)+".");
            return false;
        }
        else{
            return true;
        }
    }
    function resetForm(form){
        //document.location.href="congress.php";
        var node = document.getElementById("resultArea");
        if (node!=null){
            node.innerHTML = "";
        }
        node = document.getElementsByName("congressDB")[0];
        node.innerHTML="<option disabled selected>Select your option</option><option>Legislators</option><option>Committees</option><option>Bills</option><option>Amendments</option>";
        node=document.getElementById(id="keyWordLable");
        node.innerHTML="Keyword*";
        node = document.getElementsByName("chamber");
        var senate = node[0];
        var house = node[1];
        senate.checked = true;
        house.checked = false;
        node = document.getElementById("keyWord");
        node.value = "";
    } 
    function displayDetails(tag){
        var res = tag.getAttribute("href").split(",");
        var name = tag.getAttribute("name");
        var htmlText;
        if(name == "Legislators"){
            htmlText = displayDetailLegislators(res);
        }
        if(name == "Bills"){
            htmlText = displayDetailBills(res);
        }
        var node = document.getElementById("resultArea");
        node.innerHTML = htmlText;
        return false;
    }
    function displayDetailLegislators(valueSet){        
        //"bioguide_id","title","first_name","last_name","term_end", "website", "office","facebook_id","twitter_id"
        if(valueSet.length ==0){
            var htmlText = "The API returned zero results for the request.";
            return htmlText;
        }

        var titles = ["bioguide_id","title","first_name","last_name", "Term Ends On", "website", "Office","facebook_id","twitter_id"];

        for(i = 0; i < valueSet.length;i++){
            if(valueSet[i]==""){
                valueSet[i] ="N.A.";
            }
        }
        
        var htmlText = "<div class='resultAreaSecondLevel'>";
        var fullNameTitle = "";
        var fullName="";
        for(i = 0; i < titles.length; i++){

            if(titles[i] == "bioguide_id"){
                htmlText += "<image src = 'https://theunitedstates.io/images/congress/225x275/"+valueSet[i]+".jpg'>";
                continue;
            }
            if(titles[i] == "website"){
                if (valueSet[i]=="N.A."){
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Website</td><td class='legislatorsSecondColumn'>N.A.</td></tr>";
                }
                else{
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Website</td><td class='legislatorsSecondColumn'><a target='blank' href=\""+valueSet[i]+"\">"+valueSet[i]+"</a></td></tr>";
                }
                continue;
            }
            if(titles[i]== "facebook_id"){
                if (valueSet[i]=="N.A."){
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Facebook</td><td class='legislatorsSecondColumn'>N.A.</td></tr>";
                }
                else{
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Facebook</td><td class='legislatorsSecondColumn'><a target='blank' href=\"https://www.facebook.com/"+valueSet[i]+"\">"+fullName+"</a></td></tr>";
                }
                continue;
            }
            if(titles[i] == "twitter_id"){
                if (valueSet[i]=="N.A."){
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Twitter</td><td class='legislatorsSecondColumn'>N.A.</td></tr>";
                }
                else{
                    htmlText += "<tr><td class='legislatorsFirstColumn'>Twitter</td><td class='legislatorsSecondColumn'><a target='blank' href=\"https://www.twitter.com/"+valueSet[i]+"\">"+fullName+"</a></td></tr>";
                }
                continue;
            }

            if(titles[i] == "title"){
                fullNameTitle += valueSet[i]+" ";
                continue;
            }
            if(titles[i] == "first_name"){
                fullNameTitle += valueSet[i]+" ";
                fullName += valueSet[i]+" ";
                continue;
            }
            if(titles[i] == "last_name"){
                fullNameTitle += valueSet[i]+" ";
                fullName += valueSet[i];
                htmlText += " <table class='resultTableSecondLevel'><tr><td class='legislatorsFirstColumn'>Full Name</td><td class='legislatorsSecondColumn'>"+fullNameTitle+"</td></tr>";
                continue;
            }
            htmlText += "<tr><td class='legislatorsFirstColumn'>"+titles[i]+"</td><td class='legislatorsSecondColumn'>"+valueSet[i]+"</td></tr>";
        }

        htmlText += "</table></div>";
        return htmlText;
    }
    function displayDetailBills(valueSet){        
        //"bill_id","short_title","sponsor.title","sponsor.first_name","sponsor.last_name","introduced_on",
        //"last_version.version_name","last_action_at","last_version.urls.pdf","bill_id","short_title"
        if(valueSet.length ==0){
            var htmlText = "The API returned zero results for the request.";
            return htmlText;
        }
        var titles = ["Bill ID","Bill Title","sponsor.title","sponsor.first_name","sponsor.last_name","Introduced On",
        "last_version.version_name","last_action_at","Bill URL"];
        for(i = 0; i < valueSet.length;i++){
            if(valueSet[i]==""){
                valueSet[i] ="N.A.";
            }
        }
        var htmlText = "<div class = 'resultAreaSecondLevel'><table class='resultTableSecondLevel'>";
        var sponsor = "";
        var lastAction = "";
        var title = "";
        for(i = 0; i < titles.length; i++){

            if(titles[i]=="sponsor.title"){
                 sponsor += valueSet[i] + " ";
                 continue;
            }
            if(titles[i]=="sponsor.first_name"){
                 sponsor += valueSet[i] + " ";
                 continue;
            }
            if(titles[i]=="sponsor.last_name"){
                 sponsor += valueSet[i];
                 htmlText += "<tr><td>Sponsor</td><td>"+ sponsor +"</td></tr>"; 
                 continue;
            }
            if(titles[i]=="last_version.version_name"){
                 lastAction += valueSet[i] + ", ";
                 continue;
            }
            if(titles[i]=="last_action_at"){
                 lastAction += valueSet[i];
                 htmlText += "<tr><td>Last action with date</td><td>"+ lastAction +"</td></tr>"; 
                 continue;
            }
            if(titles[i]=="Bill URL"){
                if(valueSet[i]=="N.A."){
                    htmlText += "<tr><td>Bill URL</td><td>N.A.</td></tr>";
                 continue;
                }
                if(title == "N.A."){
                    title = valueSet[0];
                }
                htmlText += "<tr><td>Bill URL</td><td><a target='blank' href=\""+valueSet[i]+"\">"+title+"</a></td></tr>";
                continue;
            }
            if(titles[i]=="Bill Title"){
                title = valueSet[i];
            }

            htmlText += "<tr><td>"+titles[i]+"</td><td>"+ valueSet[i] +"</td></tr>";  
        }
        htmlText += "</table></div>";
        return htmlText;
    }
    </script>
</head>
<body>	
    <div id = "container">
        <div id="formContainer">
        <h2>Congress Information Search</h2>
        <form name="congressForm" id="congressForm" action='congress.php' method='post'>
            <table name id="formtable" width = 300px border="1">
                <tr>
                    <td>Congress Database</td>
                    <td>
                    	<?php $selectedDB = isset($_POST["congressDB"])? $_POST["congressDB"]:"";?>
                        <select name="congressDB" onchange="return changeKey(this.form.congressDB)">
                            <option name= "default" disabled <?php if ($selectedDB =="") echo "selected";?>>Select your option</option>
                            <option <?php if ($selectedDB =="Legislators") echo "selected";?>>Legislators</option>
                            <option <?php if ($selectedDB =="Committees") echo "selected";?>>Committees</option>
                            <option <?php if ($selectedDB =="Bills") echo "selected";?>>Bills</option>
                            <option <?php if ($selectedDB =="Amendments") echo "selected";?>>Amendments</option>
                        </select>
                    </td>
                </tr>
                <tr><td>Chamber</td>
                    <td>
                    	<?php $selectedChamber = isset($_POST["chamber"])? $_POST["chamber"]:"";?>
    	                <input type="radio" name="chamber" value="Senate" 
    	                <?php if($selectedChamber == "Senate" || $selectedChamber =="") echo"checked";?>
    	                >Senate
    	                <input type="radio" name="chamber" value="House"  
    	                <?php if($selectedChamber == "House") echo"checked";?>
    	                >House
                    </td>
                </tr>
                <tr>
                    <td id="keyWordLable"><?php 
                    	if ($selectedDB ==""){
                    		echo "Keyword*";
                    	}
                    	if ($selectedDB =="Legislators"){
                    		echo "State/Representative*";
                    	}
                    	if ($selectedDB =="Committees"){
                    		echo "Committee ID*";
                    	}
                    	if ($selectedDB =="Bills"){
                    		echo "Bill ID*";
                    	}
                    	if ($selectedDB =="Amendments"){
                    		echo "Amendment ID*";
                    	}
                    ?></td><td><input name="keyWord" id="keyWord" type="text" 
                    value="<?php echo isset($_POST["keyWord"])?$_POST["keyWord"]:""; ?>"></td>
                </tr>
                <tr><td></td>
                    <td><input type="submit" name="sumbit" value="Search" onclick="return formValidation(this.form)">
                        <input type="button" value="Clear" onclick="resetForm(this.form)">
                    </td></tr>
                <tr><td colspan='2'><a target="blank" href ="http://sunlightfoundation.com/">Powered by Sunlight Foundation</a><br></td></tr>
            </table>
        </form>
        </div>
        <br>
    	<?php
            #generate the result html
            function generateHTML($keyWordsReferenceCollections){
                $congressDB = strtolower($_POST["congressDB"]);
                $chamber = strtolower($_POST["chamber"]);
                $keyWord = $_POST["keyWord"]; 

                $resCollection = getDataSet($congressDB,$chamber,$keyWord);
                $url = $resCollection[0];
                $dataSet = $resCollection[1];

                $keyWordsReference = $keyWordsReferenceCollections[$congressDB][0];
                $tableHeaderReference = $keyWordsReferenceCollections[$congressDB][1];
                #echo '<pre>'; print_r($dataSet); echo '</pre>';

                $metaData = getMetaData($dataSet, $keyWordsReference);
                #echo '<pre>'; print_r($metaData); echo '</pre>';  
                return createResult($metaData,$tableHeaderReference);
            }
        
            function getDataSet($congressDB,$chamber,$keyWord,$url = ""){            
                #myapi
                $APIKEY = "e1f0f61aca6448379c4c8d13fe92f08e";
                #unitedstates
                $UnitedStates = $GLOBALS["UnitedStates"];

                if($url == ""){
                    $url = "http://congress.api.sunlightfoundation.com/";
                    $keyWord = trim($keyWord);
                    if($congressDB == "legislators"){
                        if(isset($UnitedStates[strtolower($keyWord)])){
                            $state = $UnitedStates[strtolower($keyWord)];
                            $url .= "$congressDB?chamber=$chamber&state=$state";
                        }
                        else{
                            $nospace = str_replace(' ', '', $keyWord);
                            if($nospace!=$keyWord){
                                $keyWord = ucwords($keyWord); 
                                $url .= "$congressDB?chamber=$chamber&aliases=".rawurlencode($keyWord);
                            }
                            else{
                                $url .= "$congressDB?chamber=$chamber&query=".rawurlencode($keyWord);
                            }
                        }
                    }
                    
                    if($congressDB == "committees"){
                        $url .= "$congressDB?committee_id=".rawurlencode(strtoupper($keyWord))."&chamber=$chamber";
                    }
                    
                    if($congressDB == "bills"){
                        $url .= "$congressDB?bill_id=".rawurlencode(strtolower($keyWord))."&chamber=$chamber";
                    }
                    
                    if($congressDB == "amendments"){
                        $url .= "$congressDB?amendment_id=".rawurlencode(strtolower($keyWord))."&chamber=$chamber";
                    }
                    $url .="&apikey=$APIKEY";
                }
                #get data & decode jason  
                $json = file_get_contents($url);
                $result = json_decode($json,true);

                $dataSet = $result['results'];
                return array($url,$dataSet);
            }

        	function getMetaData($dataSet, $keyWordsReference){
                $metaData = array();
                if(count($dataSet)==0){
                	return $metaData;
                }

                $header = array();
                foreach($keyWordsReference as  $sourceKey => $targetKeys){
                	$header[$sourceKey] = $sourceKey;
                }
                $metaData[] = $header;

                foreach($dataSet as $data){
                    $unit = array();
                    foreach($keyWordsReference as $sourceKey => $targetKeys){
                    	$resString = "";
    	                foreach ($targetKeys as $oneKeys) {
                            $keys = explode('.', $oneKeys);#not using rex
                            $value = $data;
                            $symbol = true;

                            foreach($keys as $key){
                                if(isset($value[$key])){
                                    $value = $value[$key];
                                }
                                else{
                                    $value = "";
                                }
                                if($key == "version_name"){
                                    $symbol = false;
                                }
                            }
                            if($sourceKey == "detail"){
                                $resString .= $value.",";
                            }
                            else
                            {
                               if($symbol){
                                    $resString .= $value." ";
                                }
                                else{
                                    $resString .= $value.", ";
                                } 
                            }
    	                	#$resString .= $data[$oneKeys]." ";
    	                }
    	                $resString = substr($resString, 0,strlen($resString)-1);
    	                $unit[$sourceKey] = $resString;
                    }
                    $metaData[] = $unit;
                }
                return $metaData;
            }

        	function createResult($metaData, $tableHeaderReference){
                #extract data based on requirement
                $UnitedStates = array_flip($GLOBALS["UnitedStates"]);

        		$APIKEY = "e1f0f61aca6448379c4c8d13fe92f08e";
                $htmlText = "<div id = 'resultArea'><div class = 'resultAreaFirstLevel'>";
        		if(count($metaData)==0){
        			$htmlText .= "The API returned zero results for the request.</div>";
        			return $htmlText;
        		}
        		$htmlText .= "<table class='resultTableFirstLevel'>";
                foreach($metaData as $index => $md){
                    $htmlText .= "<tr>";
                    foreach($tableHeaderReference as $sourceKey => $targetKey){
                    	if($index == "header"){
                    		$htmlText .= "<th>$targetKey</th>";
                    	}
                    	else{
                            if($md[$sourceKey]==""){
                                $md[$sourceKey]="N.A.";
                            }

                    		if($sourceKey == "detail"){
                                $newURL = "";
                                if(strtolower($_POST["congressDB"])=="legislators")
                                {
                                    $newURL = "$md[$sourceKey]";
                                }
                                if(strtolower($_POST["congressDB"])=="bills"){
                                    $newURL = "$md[$sourceKey]";
                                }
                                $htmlText .= "<td><a name ='".$_POST["congressDB"]."' href='".$newURL."' onclick='displayDetails(this);return false;'>View Details</a></td>";
                                continue;
                    		}
                            if($sourceKey == "name"){
                                $htmlText .= "<td class='nameOfLegislators'><span>$md[$sourceKey]</span></td>";
                                continue;
                            }
                            if($sourceKey == "state"){
                                $value = $md[$sourceKey];
                                $value = ucwords($UnitedStates[$value]);
                                $htmlText .= "<td>$value </td>";
                                continue;
                            }                    		
                            else{
                    			$htmlText .= "<td>$md[$sourceKey]</td>";
                    		}
                    	}
                    }
                    $htmlText .= "</tr>";
                }
                $htmlText .= "</table></div></div>";
                return $htmlText;
            }

            function generateKeyWordsReferenceCollections(){   
                $keyWordsReference["legislators"] = array("name"=>array("first_name","last_name"),
                                                "state"=>array("state"),
                                                "chamber"=>array("chamber"),
                                                "detail"=>array("bioguide_id","title","first_name","last_name",
                                                    "term_end", "website", "office","facebook_id","twitter_id"
                                                    )
                                                );
                $keyWordsReference["committees"] = array("committeeID" =>array("committee_id"),
                                                        "committeeName"=>array("name"),
                                                        "chamber"=>array("chamber")
                                                    );
                $keyWordsReference["bills"] = array("billID" =>array("bill_id"),
                                                    "shortTitle"=>array("short_title"),
                                                    "chamber"=>array("chamber"),
                                                    "detail"=>array("bill_id","short_title",
                                                        "sponsor.title","sponsor.first_name","sponsor.last_name","introduced_on",
                                                        "last_version.version_name","last_action_at","last_version.urls.pdf")
                                                    );
                $keyWordsReference["amendments"] = array("amendmentID" =>array("amendment_id"),
                                                    "amendmentType"=>array("amendment_type"),
                                                    "chamber"=>array("chamber"),
                                                    "introduceOn"=>array("introduced_on")
                                                    );

                $keyWordsReference["legislatorsDetail"] = array("image" =>array("bioguide_id"),
                                                    "name"=>array("title","first_name","last_name"),
                                                    "termends"=>array("term_end"),
                                                    "website"=>array("website"),
                                                    "office"=>array("office"),
                                                    "facebook"=>array("facebook_id"),
                                                    "twitter"=>array("twitter_id")
                                                    );
                $keyWordsReference["billsDetail"] = array("billID" =>array("bill_id"),
                                                    "shortTitle"=>array("short_title"),
                                                    "sponsor"=>array("sponsor.title","sponsor.first_name","sponsor.last_name"),
                                                    "introduceOn"=>array("introduced_on"),
                                                    "lastActionWithDate"=>array("last_version.version_name","last_action_at"),
                                                    "billUrl"=>array("last_version.urls.pdf"),
                                                    "billID" =>array("bill_id"),
                                                    "urlTitle"=>array("short_title")
                                                    );

                $tableHeaderReference["legislators"] = array("name"=>"Name",
                                                    "state"=>"State",
                                                    "chamber"=>"Chamber",
                                                    "detail"=>"Detail"
                                                    );
                $tableHeaderReference["committees"] = array("committeeID" =>"Committee Id",
                                                        "committeeName"=>"Committee Name",
                                                        "chamber"=>"Chamber"
                                                    );
                $tableHeaderReference["bills"] = array("billID"=>"Bill ID",
                                                    "shortTitle"=>"Short Title",
                                                    "chamber"=>"Chamber",
                                                    "detail"=>"Detail"
                                                    );
                $tableHeaderReference["amendments"] = array("amendmentID" =>"Amendment ID",
                                                    "amendmentType"=>"Amendment Type",
                                                    "chamber"=>"Chamber",
                                                    "introduceOn"=>"Introduce on"
                                                    );
                /*Only used in Php repost
                $tableHeaderReference["legislatorsDetail"] = array("image" =>"Image",
                                                    "name"=>"Full Name",
                                                    "termends"=>"Term Ends on",
                                                    "website"=>"Website",
                                                    "office"=>"Office",
                                                    "facebook"=>"Facebook",
                                                    "twitter"=>"Twitter"
                                                    );
                $tableHeaderReference["billsDetail"] = array("billID" =>"Bil ID",
                                                    "shortTitle"=>"Bill Title", 
                                                    "sponsor"=>"Sponsor",
                                                    "introduceOn"=>"Introduced On",
                                                    "lastActionWithDate"=>"Last action with date",
                                                    "billUrl"=>"Bill URL",
                                                    "urlTitle"=>"URL Title"
                                                    );
                */

                $keyWordsReferenceCollections = array();   
                $keyWordsReferenceCollections["legislators"] = array($keyWordsReference["legislators"],
                                                                $tableHeaderReference["legislators"]);
                $keyWordsReferenceCollections["committees"] = array($keyWordsReference["committees"],
                                                                $tableHeaderReference["committees"]);
                $keyWordsReferenceCollections["bills"] = array($keyWordsReference["bills"],
                                                                $tableHeaderReference["bills"]);
                $keyWordsReferenceCollections["amendments"] = array($keyWordsReference["amendments"],
                                                                $tableHeaderReference["amendments"]);
                 /*Only used in Php repost
                $keyWordsReferenceCollections["legislatorsDetail"] = array($keyWordsReference["legislatorsDetail"],
                                                                $tableHeaderReference["legislatorsDetail"]);
                $keyWordsReferenceCollections["billsDetail"] = array($keyWordsReference["billsDetail"],
                                                                $tableHeaderReference["billsDetail"]);
                */
                return $keyWordsReferenceCollections;
            }

            function portal(){
                $keyWordsReferenceCollections = generateKeyWordsReferenceCollections();
                $formElements = array("congressDB","chamber","keyWord");
                if(isset($_POST['sumbit'])){
                    #double chech the form whether is empty
                    foreach($formElements as $key){
                        if (!$_POST[$key])
                        {
                            die();
                        }
                    }
                    echo generateHTML($keyWordsReferenceCollections); 
                }
            }
            $GLOBALS["UnitedStates"] = array( 'alabama' => 'AL', 'alaska' => 'AK', 'arizona' => 'AZ', 'arkansas' => 'AR',
                     'california' => 'CA',  'colorado' => 'CO', 'connecticut'   => 'CT', 'delaware' => 'DE',
                     'district of columbia'=> 'DC', 'florida'   => 'FL', 'georgia'  => 'GA',  'hawaii'  => 'HI',
                     'idaho'    => 'ID',  'illinois' => 'IL', 'indiana' => 'IN',  'iowa' => 'IA','kansas'   => 'KS', 
                     'kentucky' => 'KY', 'louisiana' => 'LA',  'maine' => 'ME', 'maryland' => 'MD',  'massachusetts'=> 'MA',
                     'michigan' => 'MI',  'minnesota'   => 'MN', 'mississippi'  => 'MS', 'missouri'=> 'MO',
                     'montana'  => 'MT', 'mebraska' => 'NE', 'nevada'   => 'NV', 'new hampshire'=> 'NH',
                     'new jersey' => 'NJ', 'new mexico'=> 'NM', 'new york' => 'NY', 'north carolina'=> 'NC',
                     'north dakota'=> 'ND', 'ohio' => 'OH', 'oklahoma' => 'OK', 'oregon'    => 'OR',
                     'pennsylvania'=> 'PA', 'rhode island'=> 'RI', 'south carolina'=> 'SC', 'south dakota'=> 'SD',
                     'tennessee' => 'TN', 'texas' => 'TX', 'utah' => 'UT', 'vermont' => 'VT',
                     'virginia' => 'VA', 'washington'   => 'WA', 'west virginia'=> 'WV', 'wisconsin' => 'WI','wyoming'  => 'WY');
            portal();
        ?>
    </div> 
</body>
</html>