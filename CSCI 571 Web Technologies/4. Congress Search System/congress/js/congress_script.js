var UnitedStates={"AL":"Alabama","AK":"Alaska","AS":"American Samoa","AZ":"Arizona","AR":"Arkansas","CA":"California","CO":"Colorado","CT":"Connecticut","DE":"Delaware","DC":"District Of Columbia","FM":"Federated States Of Micronesia","FL":"Florida","GA":"Georgia","GU":"Guam","HI":"Hawaii","ID":"Idaho","IL":"Illinois","IN":"Indiana","IA":"Iowa","KS":"Kansas","KY":"Kentucky","LA":"Louisiana","ME":"Maine","MH":"Marshall Islands","MD":"Maryland","MA":"Massachusetts","MI":"Michigan","MN":"Minnesota","MS":"Mississippi","MO":"Missouri","MT":"Montana","NE":"Nebraska","NV":"Nevada","NH":"New Hampshire","NJ":"New Jersey","NM":"New Mexico","NY":"New York","NC":"North Carolina","ND":"North Dakota","MP":"Northern Mariana Islands","OH":"Ohio","OK":"Oklahoma","OR":"Oregon","PW":"Palau","PA":"Pennsylvania","PR":"Puerto Rico","RI":"Rhode Island","SC":"South Carolina","SD":"South Dakota","TN":"Tennessee","TX":"Texas","UT":"Utah","VT":"Vermont","VI":"Virgin Islands","VA":"Virginia","WA":"Washington","WV":"West Virginia","WI":"Wisconsin","WY":"Wyoming"};$("#menu-toggle").click(function(e){e.preventDefault();$("#wrapper").toggleClass("toggled")});var app=angular.module('angularTable',['angularUtils.directives.dirPagination']);app.service('myService',function(){});app.filter('capitalize',function(){return function(input){var out=input;if(angular.isString(out)){var out=input.substring(0,1).toUpperCase()+input.substring(1)}
return out}})
app.filter('upperCase',function(){return function(input){var out=input;if(angular.isString(out)){out=input.toUpperCase()}
return out}})
app.filter('partyFullName',function(){return function(input){var out=input;if(angular.isString(out)){if(input=='D'){out='Democrat'}
if(input=='R'){out='Republican'}
if(input=='I'){out='Indepedent'}}
return out}})
app.filter('isNull',function(){return function(input){if(angular.isString(input)){return input}
return 'N.A'}})
app.controller('mainController',function($scope,$http,$window){$scope.order=['state','last_name'];$scope.tabName='state';$scope.legislatorsType='Legislators By States';$scope.filterExp='';$scope.billType='Active Bills';$scope.DBName='legislators';$scope.UnitedStates=[{id:'',name:"All States"},{id:'AK',name:"Alaska"},{id:'AS',name:"American Samoa"},{id:'AL',name:"Alabama"},{id:'AR',name:"Arkansas"},{id:'AZ',name:"Arizona"},{id:'CA',name:"California"},{id:'CO',name:"Colorado"},{id:'CT',name:"Connecticut"},{id:'DC',name:"District of Columbia"},{id:'DE',name:"Delaware"},{id:'FL',name:"Florida"},{id:'GA',name:"Georgia"},{id:'GU',name:"Guam"},{id:'HI',name:"Hawaii"},{id:'IA',name:"Iowa"},{id:'ID',name:"Idaho"},{id:'IL',name:"Illinois"},{id:'IN',name:"Indiana"},{id:'KS',name:"Kansas"},{id:'KY',name:"Kentucky"},{id:'LA',name:"Louisiana"},{id:'MA',name:"Massachusetts"},{id:'MD',name:"Maryland"},{id:'ME',name:"Maine"},{id:'MI',name:"Michigan"},{id:'MN',name:"Minnesota"},{id:'MO',name:"Missouri"},{id:'MS',name:"Mississippi"},{id:'MT',name:"Montana"},{id:'NC',name:"North Carolina"},{id:'ND',name:"North Dakota"},{id:'MP',name:"Northern Mariana Islands"},{id:'NE',name:"Nebraska"},{id:'NH',name:"New Hampshire"},{id:'NJ',name:"New Jersey"},{id:'NM',name:"New Mexico"},{id:'NV',name:"Nevada"},{id:'NY',name:"New York"},{id:'OH',name:"Ohio"},{id:'OK',name:"Oklahoma"},{id:'OR',name:"Oregon"},{id:'PA',name:"Pennsylvania"},{id:'PR',name:"Puerto Rico"},{id:'RI',name:"Rhode Island"},{id:'SC',name:"South Carolina"},{id:'SD',name:"South Dakota"},{id:'TN',name:"Tennessee"},{id:'TX',name:"Texas"},{id:'UT',name:"Utah"},{id:'VA',name:"Virginia"},{id:'VT',name:"Vermont"},{id:"VI",name:"Virgin Islands"},{id:'WA',name:"Washington"},{id:'WI',name:"Wisconsin"},{id:'WV',name:"West Virginia"},{id:'WY',name:"Wyoming"}]
$scope.favoriteLegislators=window.localStorage.favoriteLegislators;$scope.favoriteLegislators=angular.fromJson($scope.favoriteLegislators);$scope.favoriteBills=window.localStorage.favoriteBills;$scope.favoriteBills=angular.fromJson($scope.favoriteBills);$scope.starColor='white';$scope.favoriteCommittees=window.localStorage.favoriteCommittees;$scope.favoriteCommittees=angular.fromJson($scope.favoriteCommittees);if($scope.DBCategory==null){$scope.DBCategory='legislators'}
$http({method:'GET',url:"backup.php",params:{"congressDB":"Legislators"}}).success(function(response){var dataSet=response.results;angular.forEach(dataSet,function(value,key){if(value.district==null){value.district="N.A"}
else{value.district="District "+value.district}
if(value.state){value.fullState=UnitedStates[value.state]}
if(value.chamber){value.chamber=value.chamber.substring(0,1).toUpperCase()+value.chamber.substring(1)}
if(value.party){value.party=value.party.toUpperCase()}})
window.localStorage.congressDB=angular.toJson(dataSet);$scope.congress=dataSet});$http({method:'GET',url:"backup.php",params:{"congressDB":"BillsActive"}}).success(function(response){var dataSet=response.results;window.localStorage.Bills=angular.toJson(dataSet);$scope.bills=dataSet;$scope.billFilterExp=function(item){return item.history.active}});$http({method:'GET',url:"backup.php",params:{"congressDB":"BillsNew"}}).success(function(response){var formerdata=angular.fromJson(window.localStorage.Bills);var dataSet=response.results;angular.forEach(dataSet,function(value,key){if(value){formerdata.push(value)}});window.localStorage.Bills=angular.toJson(formerdata);$scope.bills=formerdata;$scope.billFilterExp=function(item){return item.history.active}});$http({method:'GET',url:"backup.php",params:{"congressDB":"Committees"}}).success(function(response){var dataSet=response.results;window.localStorage.Committees=angular.toJson(dataSet);$scope.committees=dataSet;$scope.committeeType="House";$scope.committeeFilterExp={'chamber':'house'}});$scope.setDBName=function(item){$scope.DBName=item;$scope.tabName='state';$scope.filterExp='state';$scope.order=['state','last_name'];$scope.DBCategory='legislators';$scope.billFilterExp=function(item){return item.history.active};$scope.committeeFilterExp={'chamber':'house'}}
$scope.confirmDBName=function(name){if(name==$scope.DBName){return!0}
else{return!1}}
$scope.changedValue=function(item){if(item.name=="All States"){$scope.filterExp=""}
else{$scope.filterExp={'fullState':item.name}}}
$scope.setTabName=function(keyname){$scope.tabName=keyname;$scope.filterExp=keyname;if(keyname=='state'){$scope.order=['state','last_name'];$scope.legislatorsType='Legislators By States'}
else{if(keyname=='house'){$scope.legislatorsType='Legislators By House'}
if(keyname=='senate'){$scope.legislatorsType='Legislators By Senate'}
$scope.order=['last_name']}}
$scope.confirmTabName=function(name){if(name==$scope.tabName){return!0}
else{return!1}}
$scope.setImage=function(keyname){if(angular.isString(keyname)){if(keyname.substring(0,1)=="S"||keyname.substring(0,1)=="s"){return keyname.substring(0,1).toLowerCase()+".svg"}
else{if(keyname.substring(0,1)=="J"||keyname.substring(0,1)=="j"){return "s.svg"}
return keyname.substring(0,1).toLowerCase()+".png"}}}
$scope.setCurrentID=function(legislatorID){var metaData=window.localStorage.congressDB;metaData=angular.fromJson(metaData);angular.forEach(metaData,function(value,key){if(value.bioguide_id==legislatorID){$scope.currentLegislator=value}});$http({method:'GET',url:"backup.php",params:{"LegislatorsCommittees":legislatorID}}).success(function(response){$scope.relatedCommittees=response.results});$http({method:'GET',url:"backup.php",params:{"LegislatorsBills":legislatorID}}).success(function(response){$scope.relatedBills=response.results})}
$scope.setStarColor=function(congressDB,keyword){$scope.starColor='white';if(congressDB=='legislators'){angular.forEach($scope.favoriteLegislators,function(value,key){if(value.bioguide_id==keyword){$scope.starColor='#ffff4b'}})}
if(congressDB=='bills'){angular.forEach($scope.favoriteBills,function(value,key){if(value.bill_id==keyword){$scope.starColor='#ffff4b'}})}
if(congressDB=='committees'){angular.forEach($scope.favoriteCommittees,function(value,key){if(value.committee_id==keyword){$scope.starColor='#ffff4b'}})}
return $scope.starColor}
$scope.setFavorite=function(DBName,id){if(DBName=='legislators'){var temp=$window.localStorage.favoriteLegislators
if(!temp){temp=[]}
else{var temp=angular.fromJson(temp)}
var isExist=0;angular.forEach(temp,function(value,key){if(value.bioguide_id==$scope.currentLegislator.bioguide_id){isExist=1;$scope.removeFavoriteItem('legislators',value.bioguide_id)}});if(!isExist){temp.push($scope.currentLegislator);isExist=0;$window.localStorage.favoriteLegislators=angular.toJson(temp);$scope.favoriteLegislators=window.localStorage.favoriteLegislators;$scope.favoriteLegislators=angular.fromJson($scope.favoriteLegislators)}}
if(DBName=='bills'){var temp=$window.localStorage.favoriteBills
if(!temp){temp=[]}
else{var temp=angular.fromJson(temp)}
var isExist=0;angular.forEach(temp,function(value,key){if(value.bill_id==$scope.currentBill.bill_id){isExist=1;$scope.removeFavoriteItem('bills',value.bill_id)}});if(!isExist){temp.push($scope.currentBill);isExist=0;$window.localStorage.favoriteBills=angular.toJson(temp);$scope.favoriteBills=window.localStorage.favoriteBills;$scope.favoriteBills=angular.fromJson($scope.favoriteBills)}}
if(DBName=='committees'){var temp=$window.localStorage.favoriteCommittees
if(!temp){temp=[]}
else{var temp=angular.fromJson(temp)}
var isExist=0;angular.forEach(temp,function(value,key){if(value.committee_id==id){isExist=1;console.log($scope.favoriteCommittees);$scope.removeFavoriteItem('committees',value.committee_id);console.log($scope.favoriteCommittees)}});if(!isExist){var metaData=window.localStorage.Committees;metaData=angular.fromJson(metaData);angular.forEach(metaData,function(value,key){if(value.committee_id==id){$scope.currentCommittee=value}});temp.push($scope.currentCommittee);isExist=0;$window.localStorage.favoriteCommittees=angular.toJson(temp);$scope.favoriteCommittees=window.localStorage.favoriteCommittees;$scope.favoriteCommittees=angular.fromJson($scope.favoriteCommittees)}}}
$scope.removeFavoriteItem=function(itemType,itemID){if(itemType=='legislators'){angular.forEach($scope.favoriteLegislators,function(value,key){if(value.bioguide_id==itemID){$scope.favoriteLegislators.splice(key,1);$window.localStorage.favoriteLegislators=angular.toJson($scope.favoriteLegislators)}})}
if(itemType=='bills'){angular.forEach($scope.favoriteBills,function(value,key){if(value.bill_id==itemID){$scope.favoriteBills.splice(key,1);$window.localStorage.favoriteBills=angular.toJson($scope.favoriteBills)}})}
if(itemType=='committees'){angular.forEach($scope.favoriteCommittees,function(value,key){if(value.committee_id==itemID){$scope.favoriteCommittees.splice(key,1);$window.localStorage.favoriteCommittees=angular.toJson($scope.favoriteCommittees);console.log("in the remove func:",$window.localStorage.favoriteCommittees)}})}}
$scope.setProgressBar=function(currentLegislator){if(currentLegislator){var start=new Date(currentLegislator.term_start);var end=new Date(currentLegislator.term_end);var now=new Date();var percent=(((now-start)/(end-start))*100).toFixed()+"%";return percent}
return '0%'}
$scope.setBillCategory=function(keyname){if(keyname=='activeBills'){$scope.billType='Active Bills'
$scope.billFilterExp=function(item){return item.history.active}}
if(keyname=='newBills'){$scope.billType='New Bills'
$scope.billFilterExp=function(item){return!item.history.active}}}
$scope.setCurrentBill=function(billID){var metaData=window.localStorage.Bills;metaData=angular.fromJson(metaData);angular.forEach(metaData,function(value,key){if(value.bill_id==billID){$scope.currentBill=value}})}
$scope.setCommitteeName=function(keyname){$scope.committeeType=keyname;if(keyname=='House'){$scope.committeeFilterExp={'chamber':'house'}}
if(keyname=='Senate'){$scope.committeeFilterExp={'chamber':'senate'}}
if(keyname=='Joint'){$scope.committeeFilterExp={'chamber':'joint'}}}
$scope.confirmChamberName=function(name){if(name==$scope.committeeType){return!0}
else{return!1}}
$scope.setDBCategory=function(item){$scope.DBCategory=item}
$scope.confirmDBCategory=function(name){if(name==$scope.DBCategory){return!0}
else{return!1}}})