# News Search Engine

Steps:
1. 	use Tika to generate big.txt
2. 	config Solr for autocomplete suggestion
3. 	use query and ajax to handle autocomplete
	(https://www.devbridge.com/sourcery/components/jquery-autocomplete/)
4. 	use SpellCorrector.php provided by homework to deal with spell errors
5. 	use simple_html_dom(http://simplehtmldom.sourceforge.net/) 
	to parse the dom tree if target html to generate snnipet

Appendix:
engine.php: main portal for get solr response
portal.php: deal with the same origin issue for autocomplete
sccript.js: autocomplete code
Snippet.php: generate snippet
SpellCorrector.php: the php version of Norvig’s Algorithm
simple_html_dom.php: the source file of simple html dom used to parse dom tree