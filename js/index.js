// Focus & Set Version
$('.console-input').focus();
var ver = "3.5";
$('#ver').html(ver);

// Force Lowercase Input
$('.console-input').keyup(function() {
  //this.value = this.value.toLowerCase();
});

// Force Cursor to End
$('.console-input').keydown(function() {
  this.value = this.value;
});
$('.console-input').click(function() {
  this.value = this.value;
});

// Output to Console
function output(print) {
  var cmd = $('.console-input').val();
  if(cmd==""){cmd="<span style='opacity:0;'>...</span>";}
  $("#outputs").append("<span class='output-cmd-pre'>User ></span><span class='output-cmd'>" + cmd + "</span>");

  $.each(print, function(index, value) {
    cmd = "Site";
    cmd += " >";
    if (value == "") {
      value = "&nbsp;";
    }
    $("#outputs").append("<span class='output-text-pre'>" + cmd + "</span><span class='output-text'>" + value + "</span>");
  });
  
  $('.console-input').val("");
  //$('.console-input').focus();
  $("html, body").animate({
    scrollTop: $(document).height()
  }, 300);
}

// Break Value
var newLine = "<br/> &nbsp;";

// User Commands
var cmds = {
  
  "/reset": function() {
    window.location.replace(location.href);
  },

  "/say": function(a) {
    output([a]);
  },

  "/ping": function() {
    output(['Pong!']);
  },

  "/pong": function() {
    output(['Use /ping']);
  },

  "/alert": function(a) {
    alert(a);
    output([]);
  },

  "/geturl": function(a) {
    var print = [];
    print.push("GETURL > URL request sent");
    $.ajax({
      url: a,
      type: 'GET',
      success: function(data) { 
        print.push("GETURL > Begin return ouput");
        print.push(data.replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/(?:\r\n|\r|\n)/g, '<br />').replace(/\t/g, '&nbsp;&nbsp;'));
        print.push("GETURL > End return ouput")
        output(print);
      },
      error: function(data, status, error)  {
        print.push("GETURL > Unable to load URL");
        output(print);
      }
    });
  },
  
  "/js": function(str) {
    var print = [];
    print.push("JS > Input Run");
    try {
      (new Function(str))();
      print.push("JS > Code Executed Successfully");
    } catch(err) {
      print.push("JS > Code Error: " + err.message);
    }
    output(print);
  },

  "/clear": function() {
    $("#outputs").html("");
  },

  "/help": function() {

    var print = ["Commands:", ""];
    print = $.merge(print, Object.keys(cmds));

    output(print);
  },

  "/about": function() {

    var print = [
      "About Me:",
      "",
      "Hi I'm Matt!",
      "I'm a web designer / developer and a theatre techie.",
      "",
      "I am a front end web designer, learning web developer and a keen theatre technician. I do web design and teching theatre productions. Rarely I attempt a normal life."
    ];

    output(print);
  },

  "/web": function() {

    var print = [
      "Websites:",
      "",
      "I do a lot of web design, some for clients, some purely because I'm bored.",
      "My client work can be seen on the <a href='//www.unreal-designs.co.uk/portfolio' target='_blank'>Unreal Designs Portfolio</a>, and the more random stuff is on my <a href='//dev.mattcowley.co.uk/' target='_blank'>Dev Server</a> (some client stuff is listed on here to).",
      "",
      "From June 2012 to August 2015 I worked self employed as a Website Designer, then August of 2015, I started up Unreal Designs, where I now work with a fabulous team as Head Website Designer.",
      "To find out more about Unreal Designs, click <a href='//www.unreal-designs.co.uk/' target='_blank'>here</a>."
    ];

    output(print);
  },

  "/theatre": function() {

    var print = [
      "Theatre:",
      "",
      "Theatre is my hobby that I enjoy and I am extremely passionate about it.",
      "I work at Young Theatre, working on most of the productions, and I am part of SLST at RGS, teching the school shows every year and other events such as concerts.",
      "",
      "The current production(s) that I am working on are " + "<span>Dasiy Pulls it Off @ YT</span> as Production Manager" + " &amp; " + "<span>Alice in Wonderland and Through the Looking Glass @ RGS</span> as Assistant Stage Manager" + ".",
      "To find out more about YT, click <a href='//www.youngtheatre.org.uk/' target='_blank'>here</a>, and to find out more about RGS &amp; SLST, click <a href='//rgshw.com/326/activities/the-arts/drama' target='_blank'>here</a>."
    ];

    output(print);
  },

  "/productions": function() {

    var print = [
      "Productions &amp; Events:",
      "",
      "I do a lot of work in theatre, to find out more use '/theatre'.",
      "This is a list of all the events and productions I've worked on.",
      "",
      "[Palmera Show Team - Guest LOP] [Live lighting w/ TUI - August 2013]",
      "[Palmera Show Team - Guest LOP] [Live lighting w/ TUI - August 2014]",
      "[Pronoun (NT Connections) - LOP] [Young Theatre - Feburary 2014]",
      "[Domby Dom - LOP] [Young Theatre - Feburary 2013]",
      "[Whinne the Pooh - LOP] [Young Theatre - May 2014]",
      "[Alladin Panto - StageLX] [Young Theatre - December 2014]",
      "[BlinkFM Live (2) - LOP / LD] [Live lighting w/ BlinkFM - March 2015]",
      "[Carousel - StageLX] [SLST @ RGS - March 2015]",
      "[Merchant of Venice - SOP] [Young Theatre - April 2015]",
      "[Burnham Trophy - Crew & Technical Liaison] [Young Theatre (Internal Festival) - July 2015]",
      "[Award - Best Technical Presentation] [Hut 3 - YT Burnham Trophy - July 2015]",
      "[Snow White Panto - StageLX] [Young Theatre - December 2015]",
      "[Eclipse (NT Connections) - LOP] [Young Theatre - February 2016]",
      "[Home Free - LOP] [Young Theatre - February 2016]",
      "[Alice in Wonderland - ASM] [SLST @ RGS - March 2016]",
      "[Daisy Pulls It Off - PM / DSM] [Young Theatre - April 2016]",
      "",
      "[LOP] [Lighting Operator]",
      "[LD] [Lighting Designer]",
      "[SOP] [Sound Operator]",
      "[StageLX] [Stage Electrics]",
      "[SM] [Stage Manager]",
      "[DSM] [Deputy Stage Manager]",
      "[ASM] [Assistant Stage Manager]",
      "[PM] [Production Manager]"
    ];
    $.each(print, function(index, value) {
      print[index] = value.replace("[", "[<span>").replace("]", "</span>]");
    });

    output(print);
  },

  "/contact": function() {

    var print = [
      "Contact Me:",
      "",
      "Email: <span>me@mattcowley.co.uk</span>",
      "Twitter: <span>@MattIPv4</span>",
      "Skype: <span>matthew_cowley1</span>",
      "Codepen: <span>@MattCowley</span>"
    ];

    output(print);
  },

};

// Output Branding
$('.console-input').val("Loading...");
$.get("https://cdn.unreal-designs.co.uk/cont/consoleTitle/?Matt&Cowley&small=Console%20Site%20v" + ver + "%20Ready%20for%20use...", function(data) {
  output(data.replace(/ /g, '&nbsp;').split("\n"));
});

// Get User Command
$('.console-input').on('keypress', function(event) {
  if (event.which === 13) {
    var str = $(this).val();
    var data = str.split(' '); data.shift(); data = data.join(' ');
    var cmd = str.split(' ')[0];
    
    if (typeof cmds[cmd] == 'function') {
      if(cmds[cmd].length > 0) {
        cmds[cmd](data);
      } else {
        cmds[cmd]();
      }
    // } else if ( (str.slice(0, str.indexOf('(')) === 'function' && str.slice(-1) === '}') || typeof eval(str.slice(0, str.indexOf('('))) === 'function') {
    //   var print = [];
    //   print.push("JS Direct Code Input Run");
    //   if(str.slice(0, str.indexOf('(')) === 'function') { str = str.replace('function(){', '').slice(0, -1); }
    //   try {
    //     (new Function(str))();
    //   } catch(err) {
    //     print.push("JS Direct Code Error: " + err.message);
    //   }
    //   output(print);
    } else {
      output(["Command not found: '" + cmd + "'", "Use '/help' for list of commands."]);
    }
    $(this).val("");
  }
});

// Particles BG
particlesJS('particles-js', {
  'particles': {
    'number': {
      'value': 50
    },
    'color': {
      'value': '#ffffff'
    },
    'shape': {
      'type': 'triangle',
      'polygon': {
        'nb_sides': 5
      }
    },
    'opacity': {
      'value': 0.06,
      'random': false
    },
    'size': {
      'value': 11,
      'random': true
    },
    'line_linked': {
      'enable': true,
      'distance': 150,
      'color': '#ffffff',
      'opacity': 0.4,
      'width': 1
    },
    'move': {
      'enable': true,
      'speed': 4,
      'direction': 'none',
      'random': false,
      'straight': false,
      'out_mode': 'out',
      'bounce': false
    }
  },
  'interactivity': {
    'detect_on': 'canvas',
    'events': {
      'onhover': {
        'enable': false
      },
      'onclick': {
        'enable': true,
        'mode': 'push'
      },
      'resize': true
    },
    'modes': {
      'push': {
        'particles_nb': 4
      }
    }
  },
  'retina_detect': true
}, function() {

});