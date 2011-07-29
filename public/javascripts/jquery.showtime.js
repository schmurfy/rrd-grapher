/*
* jQuery.showTime
* http://plugins.jquery.com/project/showTime
*
* Converts seconds to Hours, Minutes and Seconds with configurable 
* dividers (":","h", ...). 
*
* Usage:
* input: <p class=".secs">345</p>
* jQuery('.secs').showTime();
* output: <p class=".secs">5:45</p>
*
* input: <p class=".secs">345</p>
* jQuery('.secs').showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } );
* output: <p class=".secs">5m 45s</p>
*
* @author Martin Fischer
* @date 21-02-2011
* @param int time in seconds
* @version 0.2
*/
jQuery.fn.showTime = function(settings){
    var conf = {        
        div_hours: ":",
        div_minutes: ":",
        div_seconds: "",
        show_null: false
    };
       
    if (settings) {
       $.extend(conf, settings);
    }  // END if    
    
    if(typeof settings === "object" || !settings) {    
        return this.each(function() { 
            var status = jQuery(this).data('showtime');
            var time = parseInt(jQuery(this).text());
            if( typeof time === "number" && !isNaN(time) && status != "done" ) {
                var hours   = Math.floor(time / 3600);
                    time    = time - hours * 3600;
                var minutes = Math.floor(time / 60);
                var seconds = time - minutes * 60;
                var div = conf.show_divider_empty_follower;
                var h = conf.div_hours;
                var m = conf.div_minutes;
                var s = conf.div_seconds;
                  
                var timestring  = (hours > 0) ? hours + "" + h  : "";                
                    if (hours > 0) {
                        timestring += (minutes < 10) ? "0"+minutes+m : minutes + "" + m ;
                    } else {
                        timestring += (minutes > 0) ? minutes + "" + m : "";               
                    } 
                    if (minutes > 0) {
                        timestring += (seconds < 10) ? "0"+seconds + s : seconds + "" + s;
                    } else {
                        timestring += (seconds > 0) ? seconds + "" + s : "";               
                    }   
               jQuery(this).html(timestring).data('showtime','done');
            } // END if
        }); // END each            
    } // END if       
}; // END jQuery.showTime
