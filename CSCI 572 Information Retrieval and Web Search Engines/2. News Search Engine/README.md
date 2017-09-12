# News Search Engine

Steps:
1. Indexed ABCNews  articles with Solr.
2. Computed PageRank using map-reduce in hadoop on GAE.
3. Provided Autocompletion and Spell Correction (https://www.devbridge.com/sourcery/components/jquery-autocomplete/)
4. use SpellCorrector.php provided by homework to deal with spell errors
5. Generated Snippets for preview (http://simplehtmldom.sourceforge.net/) 

Appendix:
engine.php: main portal for get solr response
portal.php: deal with the same origin issue for autocomplete
sccript.js: autocomplete code
Snippet.php: generate snippet
SpellCorrector.php: the php version of Norvig’s Algorithm
simple_html_dom.php: the source file of simple html dom used to parse dom tree
