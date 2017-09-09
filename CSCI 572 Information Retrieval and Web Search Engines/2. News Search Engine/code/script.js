$(document).ready(function(){
  $("#q").autocomplete({
     source:function(request, response){
        var query = request.term.trim().toLowerCase();
        var words = query.split(" ");
        var curr_word = words[words.length-1];
        var res = '';
        for(i = 0; i < words.length-1; i++){
           res += words[i] + " ";
        }
        $.ajax({
           url: "./portal.php",
           dataType: "json",
           data: {
              query: curr_word,
              auto:"autocomplete"   
           },
           success: function( data ) {
              var objs = data['suggest']['suggest'];
              key = Object.keys(objs)[0];

              var candidates = data['suggest']['suggest'][key]['suggestions'];
              var suggestions = new Array();
              var index = 0;
              var filter = new RegExp('[0-9:_\.{}#@]');
              for(j = 0; j < candidates.length; j++){
                 var word = candidates[j].term;

                 if(!filter.test(word)){
                   suggestions[index++] = word; 
                 }
              }
              response(
                 $.map(suggestions,function(item){
                       return{
                         label: res + item,
                         value: res + item
                       }
                 }
              ));
           },
           error:function(error){
              console.log(error);
           }
        });
     }
  });
});


