if (typeof twilio == "undefined") { var twilio = {}; } twilio.realm = "prod"; $(function(){$('.iso-select').selectBox();$('.iso-select').change(function(){addIsoClass(this);});function addIsoClass(dropdown){var $this=$(dropdown);var control=$this.data('selectBox-control');if(!control){return true;}
var classes=control.attr('class').split(/ /);classes=$.map(classes,function(c){return(c.indexOf('-iso-value')==-1?c:null);});classes.push($this.val().toLowerCase()+'-iso-value');control.attr('class',classes.join(' '));}
$('select.iso-select').each(function(){addIsoClass(this);});});