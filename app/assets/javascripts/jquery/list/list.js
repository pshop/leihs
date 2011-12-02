/*
 * List
 *
 * This script sets up functionalities for lists
 *
*/

$(document).ready(function(){
  
  List.setup();
});

var List = new List();

function List() {
  
  this.setup = function() {
    this.setupSearch();
  }
  
  this.setupSearch = function() {
    var search = $(".list .navigation .search input[type=query]");
    
    if($(search).val() != $(search).data("start-text") && $(search).val() != "" && $(search).val() != undefined) $(search).addClass("active");
    
    if($(search).val() == "" || $(search).val() == undefined) $(search).val($(search).data("start_text"));
    
    $(search).focus(function(){
      if(!$(this).data("start_text")) $(this).data("start_text", $(this).val());
      if($(this).val() == $(this).data("start_text")) $(this).val("");
      $('.qtip').qtip('hide').qtip('disable');
    });
    
    $(search).blur(function(){
      if($(this).val() == "") {
        $(this).val($(this).data("start_text"));
        $(this).removeClass("active");
      } else {
        $(this).addClass("active");
      };
      $('.qtip').qtip('enable');
    });
    
    $(search).parents("form").submit(function() {
      $(this).find(".loading").show();
    });
  }
  
  this.remove_line = function(element, color) {
    var parent = $(element).parents(".list");
    $(element).css("background-color", color).fadeOut(400, function(){
      List.subtract(parent);
      $(this).remove();
    });
  }
  
  this.update_reminder = function(element) {
    $(element).find(".reminder .grey").fadeOut(300, function(){
      $(this).siblings(".text").fadeIn(300);
    });
    $(element).find(".reminder .date").fadeOut(300, function(){
      var _text = "Today " + new Date().getHours() + ":" + new Date().getMinutes();
      $(this).html(_text).fadeIn(300);
    });
  }
  
  this.update_lines = function(given_lines, options) {
    var grouped_lines = $("[data-grouped_lines]").data("grouped_lines");
    // merge new options with matching given lines
    $.each(grouped_lines, function(index_gr, linegroup){
      $.each(linegroup, function(date, lines){
        $.each(lines, function(index_ln, line) {
          $.each(given_lines, function(index_gl, given_line_id){
            if(line.id == given_line_id) {
              for (var attrname in options) {
                line[attrname] = options[attrname];
              }
            }
          });
        });
      });
    });
    
    // update dom
    $("[data-grouped_lines]").data("grouped_lines", grouped_lines);
    $(".linegroups").html("");
    $('.linegroups').append($.tmpl("tmpl/linegroup", grouped_lines));
  }
  
  this.subtract = function(list) {
    // subtract badge
    var badge = $(list).prev(".inlinetabs").find(".tab:first .badge");
    var badge_amount = parseInt($(badge).html());
    $(badge).html(badge_amount-1);
    // subtract showmore toggle
    if($(list).find(".toggle").length > 0) {
      var showmore = $(list).find(".toggle");
      var showmore_html =  $(showmore).html();
      var showmore_val = showmore_html.replace(/<\/*.*?>/g, "");
      var showmore_val_num = parseInt(showmore_val.match(/\d*/g));
      var new_showmore_val = showmore_val.replace(showmore_val_num, showmore_val_num-1);
      var new_showmore_html = showmore_html.replace(showmore_val, new_showmore_val);
      $(showmore).html(new_showmore_html);
      // get new line from hidden container
      for (var i = 0; i < 1; i++) {
        var line = $(list).find(".hidden .line:first");
        $(list).find(".hidden").before(line);
      }
      // no more hidden lines to fetch
      if($(list).find(".hidden .line").length == 0){
        $(list).find(".toggle").remove();
        return 0;
      };
    }
  }
}