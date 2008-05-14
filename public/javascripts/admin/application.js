// Place your sequent-admin specific javascript code here...
// All public-side code/styles/images will be in the folders:
//  {RAILS_ROOT}/public/themes/{THEME_NAME}/* 


// OnPreLoad... Or something to that effect anyway.
// It's based on the document.readyState
$(document).ready(function(){
	
	// Quick links selectbox...
	$('#quick-links').change(function(){
		if(this.selectedIndex > 0)
			location.href = this[this.selectedIndex].value;
	})
	
	$('#quick-links').selectedIndex = 0;

	// Focus the TITLE field, if it exists
	$('INPUT.title').each(function(){ this.focus(); this.select(); })

	// Highlighting for DELETE
	$('BUTTON.delete-icon').hover(function() {
			$(this).parents('TR').addClass('delete-highlight');
		}, function() {
			$(this).parents('TR').removeClass('delete-highlight');		
	})
	
	// Highlighting for APPROVE
	$('BUTTON.approve-icon').hover(function() {
			$(this).parents('TR').addClass('approve-highlight');
		}, function() {
			$(this).parents('TR').removeClass('approve-highlight');		
	})

	// Highlighting for EDIT
	$("TABLE.grid A").hover(function() {
			$(this).parents('TR').addClass('highlight');
		}, function() {
			$(this).parents('TR').removeClass('highlight');		
	})

	// Highlighting from the CALENDAR
	$('.specialDay A').hover(function(){
		$('TR#'+ this.id).addClass('highlight');
	}, function(){
		$('TR#'+ this.id).removeClass('highlight');		
	});
	
	$('FORM').submit(function(){
		$('.button-group').addClass("submitting");
		$('.button-group').html("<div>Saving...</div>");
	})

});

// Used by all attachment panels...
// There's an associated helper as well: attachment_panel
var AttachmentController = {
  rows: 0,
  template: null,
  init: function() {
    // Attachment row template
    this.template = $('#attachment-template').html();
    // Remove it from the dom, 'cause we don't want to submit it to the server...
    $('#attachment-template').remove();
    // Before the form submits, update the attachment rows...
    $('FORM').submit(function(){
      $('#attachment-list .attachment-row').addClass('submitting');
      $('.attachment-row.last-row').remove();
      return true;
    })
    // Create first row
    this.add_row();
  },
  add_row: function() {
    $('#attachment-list').append( this.template );
    this.rows++;
  },
  remove: function(button) {
    var row = $(button).parents('DIV.attachment-row');
    if(!row.hasClass('last-row')) {
      row.remove();
      this.rows--;
      if(this.rows == 0) {
        this.add_row();
      }      
    }
  },
	mark_as_removed: function(button) {
    var row = $(button).parents('DIV.attachment-row');
		if( $(row).hasClass('removed') ) {
			$(row).find('.hidden-field').remove();
			$(row).removeClass('removed');
			$(button).attr('title', 'Remove this attachment')
		} else {
			$(row).append('<input class="hidden-field" type="hidden" name="removed_attachments[]" value="'+ $(row).id() +'"/>');
			$(row).addClass('removed');
			$(button).attr('title', 'Undo attachment removal')
		}
	},
  changed: function(input) {
    var row = $(input).parents('DIV.attachment-row');
    if( row.hasClass('last-row') ) {
      row.removeClass('last-row')
      this.add_row();
    }
    try {
      var filename = $(input).val();
      if(filename) {
        var sep = this.is_windows() ? '\\' : '/';
        var segs = filename.split(sep);
				var filename = segs[segs.length -1].replace(/[^\w\.\-]/g,'_');
        $(row).find('.filename').html( filename );
      }
    } catch(meh) { }
  },
  hover: function(anchor,over) {
    if(over) {
      $(anchor).parents('DIV.attachment-row').addClass('highlight')
    } else {
      $(anchor).parents('DIV.attachment-row').removeClass('highlight')
    }
  },
  is_windows: function() {
    return navigator.userAgent.toLowerCase().indexOf('win') != -1;
  }
}