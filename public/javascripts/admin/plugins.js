/* jquery plugins... */


// This should be called on TABLE tags. It will generate a totals row and, based on the table's CSS classname or of the TD's classnames.
//
//  <table class="def-x-x-$s"> 
// 
// That would define a table that ignores the first two columns, and SUMs up the last one. It will also prefix the summed value with a dollar-sign.
//
// Supports SUM (class: sum, or class-def: s) and AVG (class: avg, or class-def: a)
jQuery.fn.handleCalcs = function( options ) {
	// TODO: Add support for options.header_row???
	this.each(function() { try {
		var table = this;
		var colData = [];
		var colCount = 0;
		// This parse the grid column types from the classname
		$.each(table.className.split(' '), function() {
			if( this.substring(0,3) == 'def') {
				var defs = this.split('-'); 
				defs.shift(); // we don't need the 'defs' prefix
				$.each(defs, function(i){
					if(/s/.test(this))
						colData.push( { 
							type:'sum', 
							idx: i, 
							value:0, 
							rows:0, 
							prefix:  (this.indexOf('s') == 0) ? '' : this.replace('s', ''),
							postfix: (this.indexOf('s') == 0) ? this.replace('s', '') : '',
							calc: function(){ return this.value; }  
						})
					else if(/a/.test(this))
						colData.push( { 
							type:'avg',
							idx: i, 
							value:0, 
							rows:0, 
							prefix:  (this.indexOf('a') == 0) ? '' : this.replace('a', ''),
							postfix: (this.indexOf('a') == 0) ? this.replace('a', '') : '',
							calc: function(){ return this.value/this.rows; }
						 })
						
					colCount++;
				});
				return; // Out of classDefs loop
			}
		});
		
		// If there are no calc'd columns... Then we're done.
		if( colData.length > 0 ) {
			// Create the 'totals' row
			var html = '<tr id="generated-totals">';
			for( var i=0; i<colCount; i++)
				html += $.replace('<td id="col-${i}" class="number-col">&nbsp;</td>', {i:i});
			html += '</tr>';
			($(table).find('tbody') || $(table)).append(html);
			
			// Calc the table... Start by looping over all the rows
			$(table).find('tr').each(function(){
				var tr = $(this);
				// For each column def
				$.each(colData, function() {
					var colDef = this;
					$(tr).find('td:eq('+ colDef.idx +')').each(function(){
						$(this).addClass('number-col');
						var num = parseFloat( $(this).text().replace(/[^0-9\,\.\-]/gi, '') );
						if(num) {
							colDef.value += num;
							colDef.rows++;
						}
						else {
							$(this).attr('title', "Error: Couldn't parse the cell value as a number.")
							$(this).addClass('invalid-number')							
						}
						return this;
					});
				})
			});
			
			// Populate the totals row
			$.each(colData, function() {
				var colDef = this;
				$(table).find('td#col-'+ colDef.idx).html(colDef.prefix + colDef.calc() + colDef.postfix);
			});
		}		
	} catch(meh) {} });
};
// Need for handleCalcs()
jQuery.fn.hasClass = function(c) {
	return $.className.has(this[0],c);
}

// Use on <input type="text" /> fields...
// Sets type="search" for safari. Set's the default value for 
// the rest of the browsers. When the control get's focus, if
// the search label is the value, this it's cleared out and the
// text's color is set to gray. When it loses focus, if the 
// control's value == "" then it's set back to the search label
// and the color is set to gray.
jQuery.fn.actsAsSearchBox = function(default_label, options) {
	var defLabel = default_label || "Search";
	if($.browser.safari) {
		$(this).attr({ 
			type:        'search', 
			placeholder: defLabel, 
			autosave:    'true', 
			results:     '10' 
		});
	} else {
		// Initial state
		$(this).attr("value", defLabel);
		$(this).css('color', 'gray');				

		$(this).focus(function(e){
			if(this.value == defLabel) {
				this.value = "";
				$(this).css('color', 'black');
			}
		});
		$(this).blur(function(e){
			if(this.value == "") {
				this.value = defLabel;
				$(this).css('color', 'gray');				
			}
		});		
	}
};

// For use on TEXTAREAS to allow them to submit a form when
// ENTER and the control, alt, or meta key is pressed.
jQuery.fn.enterSubmitsForm = function() {
  return this.each(function() {
    // only attach the handler if it's an element that
    // references a form
    if(this.form != undefined) {
      $(this).keydown(function(e){
        if( e.keyCode == 13 && (e.metaKey || e.ctrlKey || e.altKey)) {
          // find the form's submit button
          var btns = jQuery(this.form).find('input[@type=submit]');
          // if it's found, fake a mouse click
          if(btns.length > 0)
            btns[0].click();
          // otherwise, if an onsubmit handler is defined, call it
          else if( typeof this.form.onsubmit == "function")
            this.form.onsubmit(e);
          // if none of the above, just submit() the form
          else
            this.form.submit(e);
          // Return false so that the ENTER isn't added to the TEXTAREA's value
          return false;
        }
      });
    }
  });
};

// String replacement util. Usage:
//   $.replace("My name is ${name}", {name:'Matt'});
jQuery.replace = function(format, data) {
  for(prop in data)
    format = format.replace(new RegExp("\\$\\{"+ prop +"\\}", 'gi'), data[prop])
  return format;
};


// CSS Browser Selector   v0.2.3 : http://rafael.adm.br/css_browser_selector
(function() {
	var 
		ua = navigator.userAgent.toLowerCase(),
		is = function(t){ return ua.indexOf(t) != -1; },
		h = document.getElementsByTagName('html')[0],
		b = (!(/opera|webtv/i.test(ua)) && /msie (\d)/.test(ua)) ? ((is('mac') ? 'ieMac ' : '') + 'ie ie' + RegExp.$1)
			: is('gecko/') ? 'gecko' : is('opera') ? 'opera' : is('konqueror') ? 'konqueror' : is('applewebkit/') ? 'webkit safari' : is('mozilla/') ? 'gecko' : '',
		os = (is('x11') || is('linux')) ? ' linux' : is('mac') ? ' mac' : is('win') ? ' win' : '';
	var c = b+os+' js'; c = c.replace('noscript', '');
	h.className += h.className?' '+c:c;
})();

/*
 *
 * Copyright (c) 2006 Sam Collett (http://www.texotela.co.uk)
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 */
 
/*
 * Allows only valid characters to be entered into input boxes.
 * Note: does not validate that the final text is a valid number
 * (that could be done by another script, or server-side)
 *
 * @name     numeric
 * @param    decimal      Decimal separator (e.g. '.' or ',' - default is '.')
 * @param    callback     A function that runs if the number is not valid (fires onblur)
 * @author   Sam Collett (http://www.texotela.co.uk)
 * @example  $(".numeric").numeric();
 * @example  $(".numeric").numeric(",");
 * @example  $(".numeric").numeric(null, callback);
 *
 */
jQuery.fn.numeric = function(decimal, callback)
{
	decimal = decimal || ".";
	callback = typeof callback == "function" ? callback : function(){};
	this.keypress(
		function(e)
		{
			var key = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;
			// allow enter/return key (only when in an input box)
			if(key == 13 && this.nodeName.toLowerCase() == "input")
			{
				return true;
			}
			else if(key == 13)
			{
				return false;
			}
			var allow = false;
			// allow Ctrl+A
			if((e.ctrlKey && key == 97 /* firefox */) || (e.ctrlKey && key == 65) /* opera */) return true;
			// allow Ctrl+X (cut)
			if((e.ctrlKey && key == 120 /* firefox */) || (e.ctrlKey && key == 88) /* opera */) return true;
			// allow Ctrl+C (copy)
			if((e.ctrlKey && key == 99 /* firefox */) || (e.ctrlKey && key == 67) /* opera */) return true;
			// allow Ctrl+Z (undo)
			if((e.ctrlKey && key == 122 /* firefox */) || (e.ctrlKey && key == 90) /* opera */) return true;
			// allow or deny Ctrl+V (paste), Shift+Ins
			if((e.ctrlKey && key == 118 /* firefox */) || (e.ctrlKey && key == 86) /* opera */
			|| (e.shiftKey && key == 45)) return true;
			// if a number was not pressed
			if(key < 48 || key > 57)
			{
				/* '-' only allowed at start */
				if(key == 45 && this.value.length == 0) return true;
				/* only one decimal separator allowed */
				if(key == decimal.charCodeAt(0) && this.value.indexOf(decimal) != -1)
				{
					allow = false;
				}
				// check for other keys that have special purposes
				if(
					key != 8 /* backspace */ &&
					key != 9 /* tab */ &&
					key != 13 /* enter */ &&
					key != 35 /* end */ &&
					key != 36 /* home */ &&
					key != 37 /* left */ &&
					key != 39 /* right */ &&
					key != 46 /* del */
				)
				{
					allow = false;
				}
				else
				{
					// for detecting special keys (listed above)
					// IE does not support 'charCode' and ignores them in keypress anyway
					if(typeof e.charCode != "undefined")
					{
						// special keys have 'keyCode' and 'which' the same (e.g. backspace)
						if(e.keyCode == e.which && e.which != 0)
						{
							allow = true;
						}
						// or keyCode != 0 and 'charCode'/'which' = 0
						else if(e.keyCode != 0 && e.charCode == 0 && e.which == 0)
						{
							allow = true;
						}
					}
				}
				// if key pressed is the decimal and it is not already in the field
				if(key == decimal.charCodeAt(0) && this.value.indexOf(decimal) == -1)
				{
					allow = true;
				}
			}
			else
			{
				allow = true;
			}
			return allow;
		}
	)
	.blur(
		function()
		{
			var val = jQuery(this).val();
			if(val != "")
			{
				var re = new RegExp("^\\d+$|\\d*" + decimal + "\\d+");
				if(!re.exec(val))
				{
					callback.apply(this);
				}
			}
		}
	)
	return this;
}
