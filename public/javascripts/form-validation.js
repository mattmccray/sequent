function g( id, f) { 
	return (f || document).getElementById(id);
}

function notempty(id) { 
	return (g(id).value != ""); 
}

function vF(f) {
  var valid = (
		notempty('comment_author') && 
		notempty('comment_email') && 
		notempty('comment_body')
	);
  
	if(!valid) { 
		alert('Please fill in your name, email, and a comment.') 
	} else { 
		if( g('comment_remember') && g('comment_remember').checked ) { 
			sF(); 
		} 
	}
  return valid;
}

function sF() {
  document.cookie = "author_info="+ g('comment_author').value +"|"+ g('comment_email').value +"|"+ g('comment_url').value +', path=/';
}

function lF() {
  var s = document.cookie;
  if(s.indexOf('author_info') >= 0) {
    args = s.split(',')[0].split('=')[1].split('|')
    g('comment_author').value =  args[0]; g('comment_email').value = args[1]; g('comment_url').value = args[2];
  }
}