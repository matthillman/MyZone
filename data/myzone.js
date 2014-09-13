// Global variables
// The url for grabbing the data
var url = 'http://myzonemoves.com/myzone/mobile/'; // Live
//var url = 'http://localhost/myzonemoves/myzone/mobile/';
// Successful login returns a valid GUID
var GUID = "";
var coachGUID = "";
var activeGUID = "";
var clientGUID = "";
var calGUID = ""; //guid to use when rendering calendar (client or user).
// Error Messages
var emess = '';
var calcount = 0;
// Date formatting
var dateLong = "'<h3>'dddd d'<sup>'S'</sup>' MMMM yyyy'</h3>'";
var dateLongM = "ddd dS MMM yyyy";
var dateShort = "yyyy-MM-dd";
var dateChartL = "d MMM yy";
var dateChartS = "MMM yy";
var dateWk = "hh:mm";
var latesthrh;
var fooddate;
var fooddata;
var curfood;
var chaldata;
var health;
var healthNoDec = ["Visceral Fat", "Basal Metabolic Rate", "Resting HR", "Max HR"];
var HealthNoLink = ["Height", "Max HR", "Waist Circumference", "Bone Mass"];
var calbackground;
var workoutplot;
var db;
var dblogin;
var online;
var dbconection;
var agelimit = true; // true limits access default true
var bodyselect1;
var bodyselect2;
var bodyselect1date;
var bodyselect2date;
var chalguid;
function OfflineUpload() {
    db.transaction(function(tx) {
        tx.executeSql('SELECT * FROM OfflineIMG', [], function(tx, results) {
            if (results.rows.length > 0) {
                var JSONstring = {
                    "fooddate": results.rows.item(0).picDateTime,
                    "image": results.rows.item(0).photo,
                    "GUID": results.rows.item(0).picGUID
                };
                $.post(url + '/postfood.php', JSONstring, function() {
                    OfflineUploadCallback();
                });
            }

        }, null);
    });
}

function OfflineUploadCallback() {
    db.transaction(function(tx) {
        function sqlresponce(tt, result) {
            if (result.rows.length > 0) {
                OfflineUpload();
            }
        }
        tx.executeSql('SELECT * FROM OfflineIMG  LIMIT 0,1', [], function(tx, results) {
            var dbid = results.rows.item(0).id;
            tx.executeSql('DELETE FROM OfflineIMG WHERE id = ' + dbid, [], function() {
                tx.executeSql('SELECT * FROM OfflineIMG', [], sqlresponce, function(e) {
                    onFail(e, 'SELECT * FROM OfflineIMG');
                });
            }, function(e) {
                onFail(e, 'DELETE FROM OfflineIMG WHERE id = ' + dbid);
            });
        });
    });
}

window.addEventListener('devicemotion', function(e) {
// Your code for dealing with the shake event here
// Stop the default behavior from triggering the undo dialog (hopefully)
    e.preventDefault();
});
function onOnline() {

    if (online === false) {
        OfflineUpload();
    }
    online = true;
}

function onOffline() {
    online = false;
}
db = window.openDatabase("myzone", "1.0", "Myzone DB", 5000000);
db.transaction(dbCreateTables, function(e) {
    onFail(e, dbCreateTables);
}, successDB);
function onDeviceReady() {
    pictureSource = navigator.camera.PictureSourceType;
    destinationType = navigator.camera.DestinationType;
    document.addEventListener("online", onOnline, false);
    document.addEventListener("offline", onOffline, false);
}

function successDB() {
}

function dbCreateTables(tx) {
    tx.executeSql('CREATE TABLE IF NOT EXISTS MYZONELogin(id INTEGER PRIMARY KEY AUTOINCREMENT,dbuname,dbupass,guid,agelimit,coachGUID)');
    tx.executeSql('CREATE TABLE IF NOT EXISTS OfflineIMG(id INTEGER PRIMARY KEY AUTOINCREMENT,picDateTime DATE,photo BLOB,picGUID TEXT)');
    OfflineUpload();
}
var calBackground;
var c = -1;
var clientFilter = "";
$(document).ready(function() {
    $(".hammenu").css("opacity", ".8")
    $('#clientFilter').keyup(function() {
        if ($(this).val() != clientFilter) {
            clientFilter = $(this).val().toString().toLowerCase();
            clearTimeout(c);
            c = setTimeout(function() {
                drawClientList();
            }, 500);
        }
    });
    $('.btnCalendar').click(function() {
        cal();
    });
    $('#actlist').change(function() {
        var selectval = $(this).val();
        var rdata = {
            requestType: rtypes.latestmove.id,
            actIndex: selectval,
            hrhIndex: latesthrh
        };
        $('#nmoves').find('.label').empty().append($('#actlist option:selected').text());
    });
    $('#calendar').fullCalendar({
        ignoreTimezone: false,
        theme: true,
        header: {
            left: '',
            center: 'title',
            right: ''
        },
        firstDay: 1,
        height: 300,
        titleFormat: {
            month: 'MMMM yyyy',
            week: 'MMM d[ yyyy]{ "&#8212;"[ MMM] d yyyy}',
            day: 'd MMM yyyy'
        },
        events: function(start, end, callback) {
            var rtype = rtypes.events.id; // Request event data
            if (start.toString() === "Invalid Date") {
// fix invalid date
                start = new Date();
                start.setDate(1);
                start.setMonth(start.getMonth());
                end = new Date();
                end.setMonth(end.getMonth() + 1);
            }

            var rdata = {
                requestType: rtype,
                guid: calGUID,
                startdate: Math.round(start.getTime() / 1000),
                enddate: Math.round(end.getTime() / 1000)
            };
            fccallback = callback;
            getRemoteData('events', rdata, populateEvents /*, true*/);
        },
        dayClick: function(date, allDay, jsEvent, view) {
            $(this).css("background-color", "#93a6dc");
            calBackground = this;
            setTimeout(function() {
                $(calBackground).css("background-color", "#FFF")
            }, 500);
            showMyMovesPage2(this, date, jsEvent, view);
        },
        eventClick: function(event, jsEvent, view) {
            $('#calendar').fullCalendar('select', event.start);
            $('.fc-cell-overlay').css('opacity', 1).css('background-color', '#93a6dc');
            setTimeout(function() {
                $('#calendar').fullCalendar('unselect', event.start);
            }, 500);
            showMyMovesPage(event);
        },
        eventAfterRender: function(event, element, view) {
            $('.noteOffset').hide();
            $('.noteOffset').show();
        },
        eventRender: function(event, element, view) {
            if (view.name === 'month') {
                for (var zone in zones) {
                    if (event.title === "MD") // MYZONE Note
                    {
                        c = '<div class="noteMonth">MD</div>';
                        element.find('span.fc-day-number').prepend(c);
                        element.find('span.fc-event-skin').css('background-color', 'transparent');
                        element.addClass('noteOffset');
                    } else if (event.aveEffort >= zones[zone].limit) {
                        c = '<img class="iconMonth" src="[i]"/>'.replace('[i]', zones[zone].image);
                        element.find('span.fc-event-title').empty().append(c);
                        element.find('span.fc-event-skin').css('background-color', 'transparent');
                        break;
                    }
                }
            } else { // day view
                var daytemplate = '<div id="[id]" class="mymoves ui-widget-header ui-corner-all">';
                daytemplate += '<p class="label">[l]</p>';
                daytemplate += '<p class="value">[v]</p>';
                daytemplate += '</div>';
                var e = "";
                var html = "";
                var zone2;
                for (zone2 in zones) {
                    if (event.effort > zones[zone2].limit) {
                        event.backgroundColor = zones[zone2].start;
                        event.borderColor = 'transparent';
                        html = '<div id="dmymoves" class="moves" align=center>';
                        html += daytemplate.replace('[id]', 'deffort').replace('[l]', 'Effort').replace('[v]', event.effort + '%');
                        html += daytemplate.replace('[id]', 'dpoints').replace('[l]', 'MYZONE Points').replace('[v]', event.points);
                        html += daytemplate.replace('[id]', 'dduration').replace('[l]', 'Duration').replace('[v]', formatTime(event.duration));
                        html += daytemplate.replace('[id]', 'dcalories').replace('[l]', 'Calories Burnt').replace('[v]', event.calories);
                        html += daytemplate.replace('[id]', 'davehr').replace('[l]', 'Average Heart Rate').replace('[v]', event.avehr);
                        html += '</div>';
                        $(element).empty().append(html);
                        break;
                    }
                }
            }
        }
    }).bind('swiperight', function(e, ui) {
        $(this).fullCalendar('prev');
    }).bind('swipeleft', function(e, ui) {
        $(this).fullCalendar('next');
    });
    $(".btnCalendar").click(function() {
        cal();
    });
    $("#date").prepend($.fullCalendar.formatDate(new Date(), dateLong));
    setup();
});
function onBody() {
    document.addEventListener("deviceready", onDeviceReady, false);
}

// List of approved request formats
var rtypes = {
    login: {
        id: 1,
        data: null
    },
    stats: {
        id: 2,
        data: null
    },
    profile: {
        id: 3,
        data: null
    },
    gpoints: {
        id: 4,
        data: null
    },
    health: {
        id: 5,
        data: null
    },
    challenges: {
        id: 6,
        data: null
    },
    events: {
        id: 7,
        data: null
    },
    summary: {
        id: 8,
        data: null
    },
    notes: {
        id: 9,
        data: null
    },
    workout: {
        id: 10,
        data: null
    },
    latestmove: {
        id: 11,
        data: null
    },
    food: {
        id: 12,
        data: null
    },
    foodnotes: {
        id: 13,
        data: null
    },
    bodyimages: {
        id: 14,
        data: null
    }
};
function mobback(pagename, modify) {
    if (typeof modify !== 'undefined') {
        $.mobile.changePage($(pagename), modify);
    } else {
        $.mobile.changePage($(pagename), {
            transition: "slide"
        });
    }
}

function onFail(errorcode, msg) {

    navigator.notification.alert("Error: " + errorcode + "\n" + msg, // message

            function() {
            }, // callback
            'Error Handler', // title
            'Close');
}

function dropfix(field) {

    $("#".field).addClass("outline");
    $("#".field).removeClass("outline");
}

// List of colour zones
var zones = {
    zone5: {
        start: '#c41a1c',
        stop: '#f0544d',
        text: '#ffffff',
        limit: 90,
        image: 'istatic/images/90c.png'
    },
    zone4: {
        start: '#efd500',
        stop: '#fff45f',
        text: '#000000',
        limit: 80,
        image: 'istatic/images/80c.png'
    },
    zone3: {
        start: '#006931',
        stop: '#69963e',
        text: '#ffffff',
        limit: 70,
        image: 'istatic/images/70c.png'
    },
    zone2: {
        start: '#314489',
        stop: '#0070b5',
        text: '#ffffff',
        limit: 60,
        image: 'istatic/images/60c.png'
    },
    zone1: {
        start: '#606265',
        stop: '#a0a2a4',
        text: '#ffffff',
        limit: 50,
        image: 'istatic/images/50c.png'
    },
    zone0: {
        start: '#ABABAB',
        stop: '#DBDBDB',
        text: '#ffffff',
        limit: 0,
        image: 'istatic/images/-50c.png'
    } /* Catch all for below 50% */
};
// List of colour zones
var graphzones = {
    zone5: {
        start: '#c41a1c',
        stop: '#c41a1c',
        limit: 90
    },
    zone4: {
        start: '#efd500',
        stop: '#efd500',
        limit: 80
    },
    zone3: {
        start: '#006931',
        stop: '#006931',
        limit: 70
    },
    zone2: {
        start: '#314489',
        stop: '#314489',
        limit: 60
    },
    zone1: {
        start: '#606265',
        stop: '#606265',
        limit: 50
    },
    zone0: {
        start: '#ABABAB',
        stop: '#ABABAB',
        limit: 0
    } /* Catch all for below 50% */
};
var fccallback = null; // For fullCalendar use only

var lastToday = new Date().getDate() - 1;
function cal() {
    var d = new Date().getDate();
    if (d != lastToday) {
        lastToday = d;
        $('#calendar').fullCalendar('next');
        $('#calendar').fullCalendar('prev');
    }

    if (calGUID !== activeGUID) {
        calGUID = activeGUID;
        $('#calendar').fullCalendar('removeEvents');
        $('#calendar').fullCalendar('refetchEvents');
    }

    if (activeGUID == GUID) {
        $("#myclientsButton").hide();
        $("#challengesButton").show();
    } else {
        $("#myclientsButton").show();
        $("#challengesButton").hide();
    }

    $('#calendar').show("fast", function() {
        $('#calendar').fullCalendar('render');
    });
}

function splashImage(isPressed) {

    $('#splashimg').attr('src', 'istatic/images/Red-Button-' + (isPressed ? 'Down' : 'Up') + '.png');
}

function closepopup() {

    var popouts = $('.popout');
    if (popouts.length) {
        $('.popout').fadeOut(400, function() {
            $(this).remove();
        });
        return false;
    }
}

function popErrorMessage(errorMessage) {

    splashImage(false);
    $("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all popout'><h1>" + errorMessage + "</h1></div>").css({
        "display": "block",
        "opacity": 0.96,
        "top": $(window).scrollTop() + 100
    }).appendTo('body');
    setTimeout(closepopup, 2000);
}

function getRemoteData(rtype, rdata, loadFn, errorFn, cache) {
    if (rtypes[rtype].data !== null && cache) {
        loadFn(rtypes[rtype].data);
    } else {
        $.getJSON(url, rdata, function(data) {
            if (data !== null) {
                var returnval;
                if (data.Error === "") {
                    rtypes[rtype].data = data;
                    loadFn(data);
                    returnval = true;
                } else { // error
                    emess = data.Error;
                    popErrorMessage(emess);
                    if (errorFn) {
                        errorFn(emess);
                    }
                    returnval = false;
                }
                return returnval;
            }
        });
    }
}

function dayitem(id) {

    curfood = id;
    if (typeof fooddata[id] === 'undefined') {
        $("#foodimg").attr("src", "istatic/images/placeholder.jpg");
        $(".foodtime").empty().html("Empty");
    } else {
        $("#foodimg").attr("src", url + "../foodshots/" + fooddata[id].foodImgName + ".jpg");
        $(".foodtime").empty().html(fooddata[id].foodTime);
    }
}

function roundno(number, decplace) {
    var returnval;
    if (parseInt(number, 0) !== 0) {
        var units = number.match(/[a-z]+/g);
        var amt = parseFloat(number).toFixed(decplace);
        if (units !== null) {
            amt += units;
        }
        returnval = amt;
    } else {
        returnval = "-";
    }
    return returnval;
}

function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
}

function populateEvents(xdata) {
    var data = xdata.dates;
    var events = $.merge($.merge([], data.events), []);
    //var events = $.merge([], data['events']);
    fccallback(events);
    cal();
}

function weblink(url, title) {
    $(".webtitle").html(title);
    //$.mobile.changePage($('#web'));
    $("#webframe").empty().html("<iframe src='" + url + "' width='100%' height='100%'><iframe>").dialog();
    $.mobile.changePage($('#moves'), {
        transition: "slide"
    });
}

function populateWorkout(data) {
    var values = data.chart;
    $("#workoutpage").empty();
    var plot = $.plot($("#workoutpage"), [{
            data: values.effort0,
            color: "#BBB"
        }, {
            data: values.effort1,
            color: "#75777a"
        }, {
            data: values.effort2,
            color: "#3b54a5"
        }, {
            data: values.effort3,
            color: "#0c8b44"
        }, {
            data: values.effort4,
            color: "#fff200"
        }, {
            data: values.effort5,
            color: "#ed2024"
        }], {
        series: {
            bars: {
                show: true,
                barWidth: (60 * 1000) * 0.8,
                lineWidth: 1,
                fill: 0.9
            }
        },
        xaxis: {
            mode: "time",
            timeformat: "%H:%M",
            minTickSize: [10, "minute"]
        },
        grid: {
            hoverable: true,
            clickable: false
        },
        yaxis: {
            min: 0,
            max: 100,
            zoomRange: [100, 100],
            // Prevent vertical axis zoom
            panRange: [100, 100], // Prevent vertical axis pan,
            tickFormatter: function(val, axis) {
                return val + "%";
            }
        },
        zoom: {
            interactive: true
        },
        pan: {
            interactive: false
        }
    });
}

function showWorkout(data) {
    $.mobile.changePage($('#myworkout'), {
        transition: "slide"
    });
    // Request data for this screen
    if (data.mobstart === undefined) { //dddddddddddddddd
        if (data.start.getMonth) {
            data.mobstart = $.fullCalendar.formatDate(data.start, dateShort) + " 00:00"; //data.start;
            data.mobend = $.fullCalendar.formatDate(data.start, dateShort) + " 23:59"; //data.start;
        } else {
            data.mobstart = data.start; //data.start;
            data.mobend = data.end; //data.start;
        }
    } else {
        data.mobstart = $.fullCalendar.formatDate($.fullCalendar.parseDate(data.mobstart), dateShort) + " 00:00"; //data.start;
        data.mobend = $.fullCalendar.formatDate($.fullCalendar.parseDate(data.mobstart), dateShort) + " 23:59"; //data.start;
    }
    $('#status').empty().append("<p>Loading ...</p>");
    var rdata = {
        requestType: rtypes.workout.id,
        guid: activeGUID,
        start: data.mobstart,
        end: data.mobend
    };
    getRemoteData('workout', rdata, populateWorkout);
}

!function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0], p = /^http:/.test(d.location) ? 'http' : 'https';
    if (!d.getElementById(id)) {
        js = d.createElement(s);
        js.id = id;
        js.src = p + '://platform.twitter.com/widgets.js';
        fjs.parentNode.insertBefore(js, fjs);
    }
}(document, 'script', 'twitter-wjs')

function populateMoves(xdata) {
    var tmpl = '<img src="istatic/images/[i]" />';
    var msg = "<h2>[i]</h2>";
    var data = xdata.moves;
    var time = data.start;
    if (typeof data.start.getMonth !== 'function') {
        time = time.split(" ");
    }
    if (time.length === 2) {
        time = time[1];
        time = time.split(":");
        time = time[0] + ":" + time[1];
    } else {
        time = data.startTime;
    }
    $('#workout').find('.label').empty().append('Workout Graph');
    $('#twitface').find('.label').empty();
    $('#twitface').find('.value').empty();
    if (GUID == activeGUID) {
        $('#twitface').find('.label').empty().append(tmpl.replace('[l]', data.facebook).replace('[i]', 'facebook.gif'));
        $('#twitface').find('.label').click(function() {
            var ref = window.open(encodeURI(data.facebook), '_blank', 'location=yes,closebuttoncaption=MYZONE');
        });
        $('#twitface').find('.value').empty().append(tmpl.replace('[l]', data.twitter).replace('[i]', 'twitter.png'));
        $('#twitface').find('.value').click(function() {
            var ref = window.open(encodeURI(data.twitter).replace("2523", "23"), '_blank', 'location=yes,closebuttoncaption=MYZONE');
        });
    }
    $('#belt').find('.label').empty().append('Belt Number');
    $('#start').find('.label').empty().append(data.startDate);
    $('#start').find('.value').empty().append(time);
    if (typeof (data.actclass) === 'undefined') {
        $('#nmoves').find('.label').empty().append('Number Of Moves');
    } else {
        $('#nmoves').find('.label').empty().append(data.actclass);
    }
    $('#effort').find('.label').empty().append('Average Effort');
    $('#points').find('.label').empty().append('MEPs');
    $('#duration').find('.label').empty().append('Duration');
    $('#tzTarget').find('.label').empty().append('Target Zone');
    $('#tzDuration').find('.label').empty().append('Target Zone Duration');
    $('#calories').find('.label').empty().append('Calories Burnt');
    $('#avehr').find('.label').empty().append('Average Heart Rate');
    $('#maxhr').find('.label').empty().append('Max Heart Rate');
    $('#peakhr').find('.label').empty().append('Peak Heart Rate');
    if (typeof xdata.actlist !== "undefined") {
        latesthrh = data.hrhid;
        var i;
        for (i in xdata.actlist.dropname) {
            $("#actlist").append($("<option></option>").attr("value", xdata.actlist.dropid[i]).text(xdata.actlist.dropname[i]));
            if (xdata.actlist.dropname[i] === data.actclass) {
                $("#actbox").show();
                $("#actlist option[value='" + xdata.actlist.dropid[i] + "']").attr('selected', 'selected');
            }

        }
    } else {
        $("#actbox").hide();
    }
    dropfix("actlist");
    $('#workout').unbind('click');
    $('#workout').click(function() {
        showWorkout(data);
    });
    if (typeof data.aveEffort === 'undefined') {
        $('#nmoves').find('.value').empty().append('-');
        $('#belt').find('.value').empty().append('-');
        $('#effort').find('.value').empty().append('-');
        $('#points').find('.value').empty().append('-');
        $('#tzTarget').find('.value').empty().append('-');
        $('#tzDuration').find('.value').empty().append('-');
        $('#duration').find('.value').empty().append('-');
        $('#calories').find('.value').empty().append('-');
        $('#avehr').find('.value').empty().append('-');
        $('#maxhr').find('.value').empty().append('-');
        $('#peakhr').find('.value').empty().append('-');
        $('#zone0').empty().append(msg.replace('[i]', '-'));
        $('#zone1').empty().append(msg.replace('[i]', '-'));
        $('#zone2').empty().append(msg.replace('[i]', '-'));
        $('#zone3').empty().append(msg.replace('[i]', '-'));
        $('#zone4').empty().append(msg.replace('[i]', '-'));
        $('#zone5').empty().append(msg.replace('[i]', '-'));
        zoneGradient(0, '.moveGradient');
    } else {
        if (typeof (data['actclass']) === 'undefined') {
            $('#nmoves').find('.value').empty().append(data.moves);
        } else {
            $('#nmoves').find('.value').empty();
        }
        $('#belt').find('.value').empty().append(data.belt);
        $('#effort').find('.value').empty().append(Math.floor(data.aveEffort) + '%');
        $('#points').find('.value').empty().append(data['points']);
        $('#tzTarget').find('.value').empty().append(data['tzMin'] + "% - " + data['tzMax'] + "%");
        $('#tzDuration').find('.value').empty().append(formatTime(data['tzDuration']));
        $('#duration').find('.value').empty().append(formatTime(data['duration']));
        $('#calories').find('.value').empty().append(data['calories']);
        $('#peakhr').find('.value').empty().append(data['peakHR']);
        $('#avehr').find('.value').empty().append(data['aveHr']);
        $('#maxhr').find('.value').empty().append(data['maxHR']);
        $('#zone0').empty().append(msg.replace('[i]', formatTime(data['zone0'])));
        $('#zone1').empty().append(msg.replace('[i]', formatTime(data['zone1'])));
        $('#zone2').empty().append(msg.replace('[i]', formatTime(data['zone2'])));
        $('#zone3').empty().append(msg.replace('[i]', formatTime(data['zone3'])));
        $('#zone4').empty().append(msg.replace('[i]', formatTime(data['zone4'])));
        $('#zone5').empty().append(msg.replace('[i]', formatTime(data['zone5'])));
        zoneGradient(data['aveEffort'], '.moveGradient');
    }

}

function showMyMovesPage(myevent) {
    $.mobile.changePage($('#moves'), {
        transition: "slide"
    });
    //calbackground.css("background-color", "transparent");
    if (myevent.title === "MD") {
        $('#moves h1').text("No moves today");
    } else {
        $('#moves h1').text(myevent.title);
    }
    myevent.startDate = $.fullCalendar.formatDate(myevent.start, dateLongM);
    var data = {
        'moves': myevent
    };
    populateMoves(data);
}

function showMyMovesPage2(me, mydate, jsEvent, view) {
    var moves = $('#calendar').fullCalendar('clientEvents');
    var move = null;
    var m;
    for (m in moves) {
        var d1 = $.fullCalendar.formatDate(moves[m].start, dateShort);
        var d2 = $.fullCalendar.formatDate(mydate, dateShort);
        if (move === null && // Only pick the first move
                d1 === d2) // For the date selected
        {
            move = moves[m];
        }
    }
// At this point we will have on of three situations:-
//  1)  A move for the date selected (also have a note for same date, but don't care about that yet)
//      This should display the move data for the date.
//  2)  A note without a move.
//  3)  Nothing.
//
    if (move === null || move === "") { // Create an empty move to show for this date

    } else {
        showMyMovesPage(move);
    }
}


// Wait until all is loaded before executing

//jQuery Mobile initialisation
$(document).bind("touchmove", function(e) {
    var target = $(e.target);
    if (!target.add(target.parents()).hasClass('scrollable')) {
        return false;
    }


}).bind('mobileinit', function() {

    $(window).click(closepopup);
});
// Setup the login screen and hide the content screen
function setup() {

    // Initialise the stats
    // Format is stat@suffix@label@format
    // Set up Home screen buttons
    $("#radio").buttonset();
    $("#moves").live("load", function() {
        fixpos();
    });
    $("#btngoals").button().click(function() {
        showGoalsPage();
    });
    $("#btnhealth").button().click(function() {
        showHealthSummaryPage();
    });
    $("#btncomps").button().click(function() {
        showChallengePage();
    });
    rememberAutoLogin();
}

function rememberAutoLogin() {
    online = navigator.onLine;
    function result(tx, res) {
        if (res.rows.length > 0) {
            GUID = res.rows.item(0).guid;
            agelimit = (res.rows.item(0).agelimit === 'true');
            coachGUID = res.rows.item(0).coachGUID;
            if (coachGUID.toString() === "null") {
                $('#myClients').hide();
            } else {
                $('#myClients').show();
            }

            $('#loginFooter').hide();
            $('#MyzoneLogo').hide();
            splashImage(false);
            $.mobile.changePage($('#home'));
        } else {
            $('#splash').show();
        }
    }

    function query(tx) {
        tx.executeSql("SELECT * FROM MYZONELogin", [], result);
    }
    db.transaction(query);
}

function forgetLoginDetails() {

    updatedbuser("", "");
    email = null;
    pword = null;
}

function serverLogin(email, pword) {
    var rtype = rtypes.login.id; // Request login
    if (email == undefined) {
        email = $('#email').val();
    }
    if (pword == undefined) {
        pword = $('#pword').val();
    }

    var rdata = {
        requestType: rtype,
        email: email,
        password: $.md5(pword)
    };
    getRemoteData('login', rdata, processLogin, function() {
        updatedbuser(email, ""); //on error
    });
}

function updatedbuser(user, pass) {
    function result(tx, ret) {
        var qstring;
        if (user === "" && pass === "") {
            tx.executeSql('DROP TABLE IF EXISTS MYZONELogin');
            tx.executeSql('CREATE TABLE IF NOT EXISTS MYZONELogin(id INTEGER PRIMARY KEY AUTOINCREMENT,dbuname,dbupass,guid,agelimit,coachGUID)');
        } else if (ret.rows.length > 0) {
            tx.executeSql('DROP TABLE IF EXISTS MYZONELogin');
            tx.executeSql('CREATE TABLE IF NOT EXISTS MYZONELogin(id INTEGER PRIMARY KEY AUTOINCREMENT,dbuname,dbupass,guid,agelimit,coachGUID)');
            qstring = 'INSERT INTO MYZONELogin (dbuname,dbupass,guid,agelimit,coachGUID) VALUES ("' + user + '","' + pass + '","' + GUID + '","' + agelimit + '","' + coachGUID + '")';
        } else {

            qstring = 'INSERT INTO MYZONELogin (dbuname,dbupass,guid,agelimit,coachGUID) VALUES ("' + user + '","' + pass + '","' + GUID + '","' + agelimit + '","' + coachGUID + '")';
        }

        function responce(rx) {
            rx.executeSql(qstring, [], function() {
            }, function() {
            });
        }
        db.transaction(responce);
    }

    function checkuser(rt) {
        rt.executeSql("SELECT * FROM MYZONELogin", [], result, function(e) {
            onFail(e, "SELECT * FROM MYZONELogin");
        });
    }

    db.transaction(checkuser);
}

function processLogin(data) {
    var persist = $('#persist').val();
    var email = $('#email').val();
    var pword = $('#pword').val();
    if (persist === "on") { // Valid login, so remember details
        updatedbuser(email, pword);
    } else {
        updatedbuser("", "");
    }

    GUID = data.GUID;
    agelimit = data.agelimit;
    coachGUID = data.coachGUID;
    if (coachGUID.toString() === "null") {
        $('#myClients').hide();
    } else {
        $('#myClients').show();
    }
    $('#loginFooter').hide();
    $('#MyzoneLogo').hide();
    splashImage(false);
    $.mobile.changePage($('#home'), {
        transition: "slide"
    });
}

$('#splash').live('pageshow', function() {
    $('#MyzoneLogo').show();
    $('#splashFooter').show();
    $('#logoButton').mousedown(function() {
        splashImage(true);
    });
});
function fillLogin() {
    function fillLoginResult(tx, res) {
        if (res.rows.length > 0) {
            $('#email').val(res.rows.item(0).dbuname);
            $('#pword').val(res.rows.item(0).dbupass);
            if (res.rows.item(0).dbuname.length > 0) {
                $('#persist').val('on').slider('refresh');
            }
        }
    }

    function queryDB(tx) {
        tx.executeSql('SELECT * FROM MYZONELogin', [], fillLoginResult, function(e) {
            onFail(e, "SELECT * FROM MYZONELogin");
        });
    }
    db.transaction(queryDB);
}
$('#login').live('pageshow', function() {
    splashImage(false);
    $('#MyzoneLogo').hide();
    $('#splashFooter').hide();
    $('#loginFooter').show();
    fillLogin();
    if ($('#email').val()) {
        $('#persist').val('on').slider('refresh');
    }
});
$('#food').live('pageshow', function() {
    getFoodList();
});
$('#home').live('pageshow', function() {
    if (!GUID) {
        $.mobile.changePage($('#login'), {
            transition: "slide"
        });
        return;
    } else {
        activeGUID = GUID;
    }
    resetToLoginUser();
    //console.log("#home - " + GUID + " | " + activeGUID);
    if (agelimit === false) {
        $(".HomeBodyshotButton").attr("href", "#bodyshotmain");
    } else if (agelimit === true) {
        $(".HomeBodyshotButton").attr("href", "");
    }

// Request data for this screen
    var range = 38; // full month + 1 week.
    var rdate = $.fullCalendar.formatDate(new Date(), dateShort);
    var rdata = {
        requestType: rtypes.stats.id,
        guid: activeGUID,
        enddate: rdate,
        days: range
    };
    if (window.innerHeight < 500) {
        $(".iconscale").css("height", "45pt");
    }

    $('#htimebar').css('position', 'relative');
    $('#htimebar').css('top', '10pt');
});
$('#myClients').live('pageshow', function() {
    resetToLoginUser();
    getCoachList();
});
function populateStats(xdata) {

    // Now populate selected stats
}

function resetToLoginUser() {
    activeGUID = GUID;
    $("#myclientsBodyimageButton").hide();
    $('.btnFood').css("opacity", "1");
    $('.btnFood').removeAttr('disabled');
    $('.btnFood').attr('href', '#food');
    $('#myclientsOutcomesButton').css("opacity", "1");
    $('#myclientsOutcomesButton').attr("href", "#healthsummary");
    $('#bodyshowpic').css("opacity", "1");
    $('#bodyshowpic').parent().removeAttr('disabled');
    $('#bodyshowpic').parent().attr('href', '#bodyshotselect');
    $('#bodytakepic').css("opacity", "1");
    $('#bodytakepic').parent().removeAttr('disabled');
    $("#bodytakepic").unbind("click").click(function() {
        take_bodyshot_pic();
    });
    $(".clientName").html("");
    $(".hammenu").hide();
}

function zoneGradient(aveEffort, selector) {
    var zone;
    for (zone in zones) {
        if (aveEffort >= zones[zone].limit) {
            $(selector || '.gradient').gradient(zones[zone].start, zones[zone].stop, zones[zone].text);
            return;
        }
    }
}

$.fn.gradient = function(start, stop, fg) {
    this.css('background-image', '-webkit-gradient(linear, left top, left bottom, from(' + start + '), to(' + stop + '))').css('background-image', '-webkit-linear-gradient(top, ' + start + ', ' + stop + ')').css('background-image', '-moz-linear-gradient(top, ' + start + ', ' + stop + ')').css('background-image', '-ms-linear-gradient(top, ' + start + ', ' + stop + ')').css('background-image', '-o-linear-gradient(top, ' + start + ', ' + stop + ')').css('background-image', 'linear-gradient(top, ' + start + ', ' + stop + ')').css('color', fg);
};
function fixpos(from) {
    if (from == "button") {
        $("#mymoves").css("padding-bottom", "200px");
    } else {
        $("#mymoves").css("padding-bottom", "100px");
    }
}

function footerfixer(selectorid, footerid) {
    var version = parseInt(device.version.replace(/\./g, ''));
    if (version < 230)
    {
        var posfix = $(footerid).offset();
        $(selectorid).bind("change", function() {
            $(footerid).offset({
                top: posfix.top,
                left: posfix.left
            });
            event.stopImmediatePropagation();
        });
        $(selectorid).bind("blur", function() {
            $(footerid).offset({
                top: posfix.top,
                left: posfix.left
            });
            event.stopImmediatePropagation();
        });
    }
}

$('#challenges').live('pageshow', refreshChallenges);
$('#mycomps').live('change', refreshChallenges);
function refreshChallenges() {
    $('.challenges').hide();
    // Request data for this screen
    $('#status').empty().append("<p>Loading ...</p>");
    var range = 365;
    var rdate = $.fullCalendar.formatDate(new Date(), dateShort);
    var rdata = {
        requestType: rtypes['challenges']['id'],
        guid: GUID,
        startdate: rdate,
        days: range
    };
    getRemoteData('challenges', rdata, populateCompetition);
    $('.challenges').show();
}

function populateCompetition(data) {
    var p = $('#mycomps').get(0).options.length;
    var sel = $('#mycomps').val();
    if (sel == "None") {
        for (var c in data['challenges']) {
            var f = data['challenges'][c]['description'] + " (" + data['challenges'][c]['value'] + ")";
            $("#mycomps").get(0).options[c] = new Option(f.replace("()", ""), c);
        }
        $('#mycomps').selectmenu('refresh');
    }

    $('#myfriends').empty();
    var s = $("#mycomps").val();
    if (data['challenges'].length > 0) {
        chaldata = data['challenges'][s]['participants'];
        var tp = '<li class="challist"><p class="label">[p]</p><p class="value">[s]</span></li>';
        for (i in chaldata) {
            $('#myfriends').append(tp.replace('[p]', chaldata[i]['name']).replace('[s]', chaldata[i]['score']));
        }
        $('#myfriends').append("<br>");
    }
    $('#myfriends').listview('refresh');
}
$('#mycomps').change(function() {
    var s = $("#mycomps").val();
    if (data['challenges'].length > 0) {
        chaldata = data['challenges'][s]['participants'];
        var tp = '<li class="challist"><p class="label">[p]</p><p class="value">[s]</span></li>';
        $('.myfriends').empty();
        for (i in chaldata) {
            $('#myfriends').html(tp.replace('[p]', chaldata[i]['name']).replace('[s]', chaldata[i]['score']));
        }
        $('#myfriends').html("<br>");
    }
    $('#myfriends').listview('refresh');
});
$('#settings').live('pageshow', function() {
    $('#status').empty().append("<p>Loading ...</p>");
    var rdate = $.fullCalendar.formatDate(new Date(), dateShort);
    var rdata = {
        requestType: rtypes['profile']['id'],
        guid: GUID
    };
    getRemoteData('profile', rdata, populateSettings);
    getCoachPermissions();
});
function fetchprofile() {

    // Request data for this screen
    $('#status').empty().append("<p>Loading ...</p>");
    var rdate = $.fullCalendar.formatDate(new Date(), dateShort);
    var rdata = {
        requestType: rtypes['profile']['id'],
        guid: GUID
    };
    getRemoteData('profile', rdata, populateSettings);
}

$('#healthsummary').live('pageshow', function() {
// Request data for this screen
    $('#mysummary').empty();
    $('#status').empty().append("<p>Loading ...</p>");
    var rdata = {
        requestType: rtypes['summary']['id'],
        guid: activeGUID
    };
    getRemoteData('summary', rdata, populateHealthSummaryPage);
    $('.mysummary').show();
});
function populateHealthSummaryPage(data) {
    // with links
    // var tp = '<li class="botom-border-list" style="height:42px;background-position:0px 1px; font-size:11pt;padding-top:6px"><a href="#health" style="padding-top:10px"  onclick="setHealthChartType(\'[i]\');">[i] <span style="float:right; padding-right:15pt;">[d]</span></a></li>';
    // var tp2 = '<li style="height:42px;background-position:0px 1px; font-size:11pt;padding-bottom:-2px;padding-top:6px"><a href="#health" onclick="setHealthChartType(\'[i]\');" style="padding-top:10px" >[i] <span style="float:right; padding-right:15pt;">[d]</span></a></li>';
    // without links
    var tp3 = '<li  style="height:23px;background-position:0px -3px;padding-bottom:10px; font-size:11pt" class="botom-border-list">[i] <span style="float:right; padding-right:15pt;">[d]</span></li>';
    var tp4 = '<li  style="height:23px;background-position:0px -3px;padding-bottom:10px; font-size:11pt">[i] <span style="float:right; padding-right:15pt;">[d]</span></li>';
    $('#mysummary').empty();
    var n = 0;
    for (i in data) {
        if (i != "Error") {
            var di;
            if (i == "Blood Pressure") {
                di = data[i];
            } else if ($.inArray(i, healthNoDec) != -1) {
                di = roundno(data[i], 0);
            } else {
                di = roundno(data[i], 1);
            }
            if (i == "Body Fat%") {
                di = di + "%";
            }
            if (i == "Basal Metabolic Rate") {
                di = di + "Kcal";
            }
            if (di == "NaN" || i == "Belt ID") {
                di = data[i];
            }
            if (i != "Resting HR") {
                $('#mysummary').append(tp3.replace(/\[i\]/g, i).replace(/\[d\]/g, (data[i] === null) ? '-' : di));
            } else {
                $('#mysummary').append(tp4.replace(/\[i\]/g, i).replace(/\[d\]/g, (data[i] === null) ? '-' : di));
            }
        }

        $('#mysummary').listview('refresh');
    }
}

function populateSettings(data) {
    $('#setName').find('.label').empty().append('Name: ');
    $('#setName').find('.value').empty().append(data['nickname']);
    $('#setBelt').find('.label').empty().append('Belt ID: ');
    $('#setBelt').find('.value').empty().append(data['beltId']);
    $('#setEmail').find('.label').empty().append('Email: ');
    $('#setEmail').find('.value').empty().append(data['email']);
    $('#setAge').find('.label').empty().append('Age: ');
    $('#setAge').find('.value').empty().append(data['age']);
    $('#setDOB').find('.label').empty().append('DOB: ');
    $('#setDOB').find('.value').empty().append(data['dob']);
    $('#setGender').find('.label').empty().append('Gender: ');
    $('#setGender').find('.value').empty().append(data['gender']);
    $('#setWeight').find('.label').empty().append('Weight: ');
    $('#setWeight').find('.value').empty().append(data['weight']);
    $('#setMaxHr').find('.label').empty().append('Max HR: ');
    $('#setMaxHr').find('.value').empty().append(data['maxHr']);
}

// Support functions
function selectButton(divclass, divelem, prefix) {
    $('.' + divclass).each(function() {
        var btnimg = $(this).attr('src');
        $(this).attr('src', btnimg.replace('Blue', 'Grey'));
    });
    $('#' + divelem).addClass('selected');
    $('#' + divelem).attr('src', 'static/images/' + prefix + '-Blue.png');
}

// Formats seconds into minutes and seconds
function formatTime(duration) {
    if (isNaN(duration)) {
        return duration;
    }

    var m = ('00' + Math.floor(duration / 60)).slice(-2);
    var s = ('00' + duration % 60).slice(-2);
    return "[m]:[s]".replace("[m]", m).replace("[s]", s);
}

// Load stats as configured
function loadStat(stat, data) {
// Now populate selected stats
    var items = localStorage.getItem(stat).split('@');
    var index = items[0];
    var suffix = items[1];
    var label = items[2];
    var fmt = items[3];
    var value = (isNaN(data[index])) ? data[index] : Math.floor(data[index]);
    switch (fmt[0]) {
        case 'D':
            value = addCommas(value);
            break;
        default:
            break;
    }

    $(stat).find('.value').empty().append(value + suffix);
    $(stat).find('.label').empty().append(label);
}


function take_pic() {
    if (typeof navigator.camera !== "undefined") {
        var quality;
        var width;
        var height;
        if (isapple) {
            quality = 20;
            height = 280;
            width = 300;
        } else // android
        {
            height = 500;
            width = 500;
            quality = 75;
        }
        navigator.camera.getPicture(onPhotoDataSuccess, onPicFail, {
            quality: quality, // apple quality higher than android equalise
            allowEdit: true,
            targetWidth: width,
            targetHeight: height,
            sourceType: Camera.PictureSourceType.CAMERA,
            encodingType: Camera.EncodingType.JPEG,
            limit: 1,
            destinationType: Camera.DestinationType.DATA_URL
        });
    } else {
// for web app and unsupported
        navigator.notification.alert("Unsupported Camera");
        var date = new Date();
        fooddate = date;
        var monthfix = date.getMonth() + 1;
        datestring = date.getFullYear() + "-" + monthfix + "-" + date.getDate();
        $(".fooddate").html($.fullCalendar.formatDate(date, "ddd dS MMM yyyy"));
        curfood = -2;
        getfood(datestring);
    }
}

function showfoodday() {
    $.mobile.changePage($('#fooditem'), {
        transition: "slide"
    });
}

function onPhotoDataSuccess(imageuri) {
    var image = imageuri;
    var date = new Date();
    var monthfix = date.getMonth() + 1;
    var datestring = date.getFullYear() + "-" + monthfix + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
    var JSONstring = {
        "fooddate": datestring,
        "image": image,
        "GUID": GUID
    };
//	navigator.notification.alert(online ? "Online" : "Offline");
    if (online) {
        $.post(url + '/postfood.php', JSONstring, function(data) {
            getFoodList();
        });
    } else {
        function insertquery(tx) {
            var query = "INSERT INTO OfflineIMG (picDateTime,photo,picGUID) VALUES ('" + datestring + "','" + imageuri + "','" + GUID + "')";
            tx.executeSql(query);
            tx.executeSql('SELECT * FROM OfflineIMG', [], function(tx, results) {
                navigator.notification.alert(results.rows.length + " Images Stored\nimages will be uploaded when next online", // message
                        function() {
                        }, // callback
                        'Offline ImageStore', // title
                        'Close');
            }, function(e) {
                onFail(e, "SELECT * FROM OfflineIMG");
            });
        }
        db.transaction(insertquery, onFail, localstored);
    }
}

function localstored() {

}

function onPicFail(message) {
    navigator.notification.alert("No picture taken.");
}

function foodnavtime(mod, $direct) {
    curfood += mod;
    if (curfood <= -1) {
        curfood = -1;
        foodnav(-1, true);
    } else if (curfood >= fooddata.length) {
        curfood = 0;
        foodnav(1, true);
    } else {
        dayitem(curfood);
    }
}

function backttofoodday() {
    $.mobile.changePage($("#foodday"), {
        transition: "slide",
        reverse: true
    });
    $("#foodlist").empty();
    $.each(fooddata, function(key, value) {
        $("#foodlist").append('<li><a href="#fooditem" onclick="dayitem(' + key + ')">' + fooddata[key].foodTime + '</a></li>\n');
    });
    $('ul#foodlist li:first').remove();
    $("#foodlist").listview('refresh');
}

function foodnotes() {
    var tempevent = {
        start: fooddate,
        page: "foodday"
    };
    showFoodNotes(tempevent);
}

function showFoodNotes(data) {
    $.mobile.changePage($("#foodnotes"), {
        transition: "slide"
    });
    $("#foodbtnSave").parent().hide();
    $('#foodnoteText').keypress(function() {
        $('#foodbtnSave').parent().show();
    });
    rdate = $.fullCalendar.formatDate(data.start, "yyyy-MM-dd");
    var rdata = {
        requestType: rtypes['foodnotes']['id'],
        guid: GUID,
        start: rdate,
        end: rdate
    };
    getRemoteData('foodnotes', rdata, populateFoodNotes);
}

function populateFoodNotes(data) {

    var dateonly = data.date.split(' ');
    var d = dateonly[0].split('-');
    $('#foodnoteDate').empty().append($.fullCalendar.formatDate(new Date(d[0], d[1] - 1, d[2]), dateLong));
    $('#foodnoteDate').attr('date', data.date);
    $('#foodnoteText').val("");
    $('#foodnoteText').val(data["note"]);
    //$('#foodnoteText').click(function () {$("#foodbtnSave").show();})
}

function saveFoodNotes() {
    $("#foodbtnSave").parent().hide();
    var notes = $('#foodnoteText').val();
    if (notes === "") {
        notes = null;
    }
    var rdata = {
        requestType: rtypes.foodnotes.id,
        guid: GUID,
        start: $('#foodnoteDate').attr('date'),
        date: $('#foodnoteDate').attr('date'),
        notes: notes
    };
    getRemoteData('foodnotes', rdata, populateFoodNotes);
}

function onBodyPhotoSuc(imageurl) {
    var date = new Date();
    var monthfix = date.getMonth() + 1;
    var datestring = date.getFullYear() + "-" + monthfix + "-" + date.getDate();
    var JSONstring = {
        "date": datestring,
        "guid": activeGUID,
        "image": imageurl
    };
    $.post(url + 'postbody.php', JSONstring, function(data) {
        var formateddate = $.fullCalendar.formatDate(date, "d MMMM yyyy");
        var datestring = $.fullCalendar.formatDate(date, "yyyy-MM-dd");
        bodyselect1 = datestring;
        bodyselect2 = datestring;
        bodyselect1date = formateddate;
        bodyselect2date = formateddate;
        mobback("#bodyshotcompare");
    });
}

function take_bodyshot_pic() {
    if (typeof navigator.camera !== "undefined") {
        navigator.camera.getPicture(onBodyPhotoSuc, onPicFail, {
            quality: 100,
            targetWidth: 800,
            targetHeight: 400,
            sourceType: Camera.PictureSourceType.CAMERA,
            encodingType: Camera.EncodingType.JPEG,
            limit: 1,
            destinationType: Camera.DestinationType.DATA_URL
        });
    } else {
// for web app and unsuported
        navigator.notification.alert("Unsupported Camera");
    }
}

function bodyselect(data) {
    var bodydates = data.bodydates;
    var bodydatesstring = data.bodydatesstring;
    $("#BodySelect1").empty();
    $("#BodySelect2").empty();
    if (bodydates.length == 0) {
        $("#bodyshotmessage").text("No Bodyshots found");
        $("#bodyformhide").hide();
        $("#BodySelect1").hide();
        $("#BodySelect2").hide();
    } else {
        $("#bodyshotmessage").empty();
        $("#bodyformhide").show();
        $("#BodySelect1").show();
        $("#BodySelect2").show();
    }
    for (var count = 0; count < bodydates.length; count++) {
        if (count == bodydates.length - 1) {
            bodyselect1 = bodydates[count];
            bodyselect2 = bodydates[count];
            bodyselect1date = bodydatesstring[count];
            bodyselect2date = bodydatesstring[count];
            $("#BodySelect1").append('<option selected="selected" value="' + bodydates[count] + '">' + bodydatesstring[count] + '</option>');
            $("#BodySelect2").append('<option selected="selected" value="' + bodydates[count] + '">' + bodydatesstring[count] + '</option>');
        } else {
            $("#BodySelect1").append('<option value="' + bodydates[count] + '">' + bodydatesstring[count] + '</option>');
            $("#BodySelect2").append('<option value="' + bodydates[count] + '">' + bodydatesstring[count] + '</option>');
        }
    }
    $("#BodySelect1").selectmenu('refresh', true);
    $("#BodySelect2").selectmenu('refresh', true);
}
$("#bodyshotselect").live('pageshow', function() {
    $("#BodySelect1").change(function() {
        bodyselect1 = $("#BodySelect1 option:selected").val();
        bodyselect1date = $("#BodySelect1 option:selected").text();
    });
    $("#BodySelect2").change(function() {
        bodyselect2 = $("#BodySelect2 option:selected").val();
        bodyselect2date = $("#BodySelect2 option:selected").text();
    });
    if (online) {
        var rdata = {
            requestType: rtypes.bodyimages.id,
            guid: activeGUID
        };
        getRemoteData('bodyimages', rdata, bodyselect);
    }
});
$("#bodyshotcompare").live('pageshow', function() {
    var urladdon = "";
    var curentdate = new Date();
    if (bodyselect1 == $.fullCalendar.formatDate(curentdate, "yyyy-MM-dd")) {
        urladdon = "?tick=" + curentdate.getTime();
    }
    if (bodyselect1 == bodyselect2) {
        $("#bodyshotCompareBody").empty();
        $("#bodyshotCompareBody").append('<div class="backer-pannel" id="bodyfull" style="width:70%; height:300px; position:absolute; left:15%;"></div>');
        $("#bodyfull").append("<image src='" + url + "../bodyshots/big_" + activeGUID + "_" + bodyselect1 + ".jpg" + urladdon + "' style='height:290px;padding-top:5px'></image>");
        $("#bodyshotCompareBody").append("<br><div style='width:100%;text-align:center;position:absolute;top:310px;font-weight:900;'>" + bodyselect1date + "</div>");
    } else {
        $("#bodyshotCompareBody").empty();
        $("#bodyshotCompareBody").append('<div class="backer-pannel" id="bodyhalfleft" style="width:49.5%; height:300px; position:absolute; left:0px"></div>');
        var url1 = url + "../bodyshots/small_" + activeGUID + "_" + bodyselect1 + ".jpg" + urladdon;
        $("#bodyhalfleft").append("<image src='" + url1 + "' style='height:290px;padding-top:5px'></image>");
        var url2 = url + "../bodyshots/small_" + activeGUID + "_" + bodyselect2 + ".jpg" + urladdon;
        $("#bodyshotCompareBody").append('<div class="backer-pannel" id="bodyhalfright" style="width:49.5%;height:300px; position:absolute; right:0px"></div>');
        $("#bodyhalfright").append("<image src='" + url2 + "' style='height:290px;padding-top:5px'></image>");
        $("#bodyshotCompareBody").append("<br><div style='width:49.5%;text-align:center;position:absolute;top:310px;font-weight:900; left:0px'>" + bodyselect1date + "</div>");
        $("#bodyshotCompareBody").append("<br><div style='width:49.5%;text-align:center;position:absolute;top:310px;font-weight:900;right:0px'>" + bodyselect2date + "</div>");
    }
});

var clientList = Array;
function getCoachList() {
    if (!online) {
        div = $('<div />').attr('id', 'noconnection').addClass('clientList').html("No Connection");
        $('#clients').html(div);
    } else {
        if ($('.wait').length == 0)
            $('#clients').html('<div class="wait"></div>');
        $.getJSON(url + "myclients.php",
                {guid: coachGUID},
        function(data) {
            clientList = data.data;
            drawClientList();
        });
    }
}

function drawClientList() {
    $('#clientFilter').show();
    var clients = $('#clients');
    clients.empty();
    var x = 0;
    var div;
    for (x = 0; x < clientList.length; x++) {
        if ((clientList[x]['firstname'] + " " + clientList[x]['surname'] + " " + clientList[x]['nickname']).toString().toLowerCase().indexOf(clientFilter) >= 0) {
            div = $('<div />').attr('id', 'client_' + clientList[x]['GUID']).addClass('clientList').html(clientList[x]['firstname'] + " " + clientList[x]['surname'] + " (" + clientList[x]['nickname'] + ")</div>");
            div.data("data", clientList[x]);
            div.click(function() {
                getClientMenu(this);
            });
            clients.append(div);
        }
    }
    clients.append($("<div />").css("height", "40px"));
    var d = $("<div />").addClass("clientList").css("text-align", "center").html("Add Client");
    d.click(function() {
        getGroupList();
    });
    d.appendTo(clients);
}

function getGroupList() {
    $.getJSON(url + "coachclientgroups/",
            {guid: coachGUID},
    function(data) {
        $('#clientFilter').hide();
        var clients = $('#clients');
        clients.empty();

        $("#clientContent").scrollview("scrollTo", 0, 0);
        clients.append("Select Group");
        var x = 0;
        var groups = data.groups;
        var div;
        for (x = 0; x < groups.length; x++) {
            div = $('<div />').attr('id', 'group_' + groups[x]['i']).addClass('clientList').html(groups[x]['name']);
            div.data("i", groups[x]["i"]);
            div.click(function() {
                showAddClient(this);
            });
            div.appendTo(clients);
        }
        clients.append($("<div />").css("height", "40px"));
        clients.append("New Group");
        div = $("<div />").append($("<input />").css("width", "100%").css("outline", "none").attr("id", "newGroup").addClass("ui-input-text ui-body-c ui-corner-all ui-shadow-inset").attr("placeholder", "New Group"));
        div.appendTo(clients);
        var d = $("<div />").addClass("clientList").html("Add");
        d.click(function() {
            var group = $('#newGroup').val();
            addGroup(group);
        });
        d.appendTo(clients);
        clients.append($("<div />").css("height", "40px"));
        d = $("<div />").addClass("clientList").html("Cancel");
        d.click(function() {
            drawClientList();
        });
        d.appendTo(clients);
    });
}

function showAddClient(g) {
    var group = $(g).data("i");
    var clients = $('#clients');
    clients.empty();
    clients.append("Enter Email");
    var input = $("<input />").css("width", "100%").css("outline", "none").attr("id", "newEmail").addClass("ui-input-text ui-body-c ui-corner-all ui-shadow-inset").attr("placeholder", "Email").data("group", group);
    var div = $("<div />").append(input);
    div.appendTo(clients);
    var d = $("<div />").addClass("clientList").html("Ok").attr("id", "okClient").css("text-align", "center");
    d.click(function() {
        var email = $('#newEmail').val();
        getClientDetails(email);
    });
    d.appendTo(clients);
    clients.append("<span id='clientDetails'></span>");
    clients.append($("<div />").css("height", "40px"));
    var d = $("<div />").addClass("clientList").css("text-align", "center").html("Cancel");
    d.click(function() {
        drawClientList();
    });
    d.appendTo(clients);
}

function getClientDetails(email) {
    if (email != "") {
        $("#okClient").slideUp();
        $.get(url + "userfromemail/", {guid: coachGUID, email: email}, function(data) {
            $("#okClient").slideDown();
            if (data) {
                if (data.user) {
                    showAddClientDetails(data.user);
                }
            }
        });
    }
}

function showAddClientDetails(user) {
    var clientDetails = $("#clientDetails");
    clientDetails.empty();
    clientDetails.append($("<div />").css("height", "40px"));
    var d = $("<div />").addClass("clientList").html("Add " + user.name).css("text-align", "center");
    d.click(
            function() {
                var group = $('#newEmail').data("group");
                var email = $('#newEmail').val();
                addClient(group, email);
            }
    )
    clientDetails.append(d);
}

function addClient(group, email) {
    $.post(url + "coachaddclient/",
            {
                group: group,
                email: email,
                guid: coachGUID
            },
    function(data) {
        $('#clients').html('<div class="wait"></div>');
        getClients();
    });
}

function getClients() {
    $.getJSON(url + "myclients.php",
            {
                guid: coachGUID
            },
    function(data) {
        clientList = data.data;
        drawClientList();
    });
}

function addGroup(group) {
    if (group != "") {
        $.post(url + "coachaddgroup/",
                {
                    group: group,
                    guid: coachGUID
                },
        function() {
            getGroupList();
        });
    }
}

function getFoodList() {
    $('.ui-scrollview-view').css("-webkit-transform", "translate3d(0, 0, 0)");
    $('#foodShotList').empty();
    if (activeGUID == GUID) {
        $('#foodShotList').append('<img class="food" id="test_img" alt="Home" width="200" src="istatic/images/Food.png" onclick="take_pic()"/>');
    }

    if (!online) {
        div = $('<div />').attr('id', 'noconnection').addClass('clientList').html("No Connection");
        $('#foodShotList').append(div);
    } else {
        $('#foodShotList').append('<div class="wait"></div>');
        $.getJSON(url + "myclientsfood.php?guid=" + activeGUID, function(data) {
            var a = data.dates;
            $('#foodShotList').data("data", data.data);
            if (activeGUID === GUID) {
                $('#foodShotList').html('<img class="food" id="test_img" alt="Home" width="200" src="istatic/images/Food.png" onclick="take_pic()"/>');
            } else {
                $('#foodShotList').html('<a href="#myClients" data-transition="slide"><img src="istatic/images/myclients.png" width="70%"></a>');
            }
            var x = a.length - 1;
            var div;
            if (a.length == 0) {
                div = $('<div />').attr('id', 'dates_' + x).addClass('clientList').html("No Food Shots!");
                $('#foodShotList').append(div);
            } else {
                var sections;
                var d;
                var displayDate;
                for (x = a.length - 1; x >= 0; x--) {
                    sections = a[x][1].split("-");
                    d = new Date(sections[0], sections[1], sections[2]);
                    displayDate = a[x][0];
                    try {
                        displayDate = navigator.globalization.dateToString(d, null, null, {formatLength: 'long'});
                    } catch (ex) {

                    }

                    div = $('<div />').attr('id', 'dates_' + x).attr('date', a[x][1]).addClass('clientList').html(displayDate).attr('classtime', d.getFullYear().toString() + d.getMonth().toString() + d.getDate().toString());
                    div.click(function() {
                        getClientFoodTimes(this);
                    });
                    $('#foodShotList').append(div);
                }
            }
        });
    }
}

function getClientMenu(div) {
    $(".clientName").html($(div).html());
    $(".hammenu").show();
    $("#myclientsBodyimageButton").show();
    var guid = $(div).data("data")['GUID'];
    clientGUID = guid;
    activeGUID = guid;
    if ($(div).data("data")['mobile'] == null)
        $(div).data("data")['mobile'] = "";
    var mobile = $(div).data("data")['mobile'].toString();
    if (mobile == "") {
        $('.sms').removeAttr('href');
        $('.tel').removeAttr('href');
        $('.sms').hide();
        $('.tel').hide();
    } else {
        $('.sms').attr("href", "sms:" + mobile);
        $('.sms').attr("style", "");
        $('.tel').attr("href", "tel:" + mobile);
        $('.tel').attr("style", "");
    }

    var email = $(div).data("data")['email'].toString();
    $('.email').attr("href", "mailto:" + email);
    cal();
    $.mobile.changePage($("#history"));
    if ($(div).data("data")['foodPicPermission'] == 0) {
        $('.btnFood').css("opacity", "0.2");
        $('.btnFood').attr('disabled', 'disabled');
        $('.btnFood').removeAttr('href');
    } else {
        $('.btnFood').css("opacity", "1");
        $('.btnFood').removeAttr('disabled');
        $('.btnFood').attr('href', '#food');
    }
    if ($(div).data("data")['bodyPicPermission'] == 0) {
        $('#bodyshowpic').css("opacity", "0.2");
        $('#bodyshowpic').parent().attr('disabled', 'disabled');
        $('#bodyshowpic').parent().removeAttr('href');
    } else {
        $('#bodyshowpic').css("opacity", "1");
        $('#bodyshowpic').parent().removeAttr('disabled');
        $('#bodyshowpic').parent().attr('href', '#bodyshotselect');
    }
    if ($(div).data("data")['takeBodyPicPermission'] == 0) {
        $('#bodytakepic').css("opacity", "0.2");
        $('#bodytakepic').parent().attr('disabled', 'disabled');
        $("#bodytakepic").unbind("click").click(function() {
            navigator.notification.alert("Not allowed.");
        });
    } else {
        $('#bodytakepic').css("opacity", "1");
        $('#bodytakepic').parent().removeAttr('disabled');
        $("#bodytakepic").unbind("click").click(function() {
            take_bodyshot_pic();
        });
    }
    if ($(div).data("data")['biometricsPermission'] == 0) {
        $('#myclientsOutcomesButton').css("opacity", "0.2");
        $('#myclientsOutcomesButton').removeAttr("href");
    } else {
        $('#myclientsOutcomesButton').css("opacity", "1");
        $('#myclientsOutcomesButton').attr("href", "#healthsummary");
    }
}

function getClientFoodTimes(div) {
    var data = $('#foodShotList').data("data");
    var sections = $(div).attr('date').split("-");
    var d1 = new Date(sections[0], sections[1], sections[2]);
    var d2;
    var divTime;
    var picName;
    var classTime = d1.getFullYear().toString() + d1.getMonth().toString() + d1.getDate().toString();
    if ($('.c' + classTime).length > 0) {
        $('.c' + classTime).slideUp(function() {
            $(this).remove();
        })
    } else {
        for (x = data.length - 1; x >= 0; x--) {
            sections = data[x]['isoDate'].split("-");
            d2 = new Date(sections[0], sections[1], sections[2], sections[3], sections[4]);
            if (classTime == d2.getFullYear().toString() + d2.getMonth().toString() + d2.getDate().toString()) {
                divTime = $('<div />').attr('id', 'time_' + x).attr('classtime', classTime).css("display", "none").addClass('clientList clientTime c' + classTime).html(padLeft(d2.getHours(), 2, "0") + ":" + padLeft(d2.getMinutes(), 2, "0")).insertAfter($(div)).slideDown();
                divTime.attr("img", data[x]['foodImgName']);
                picName = data[x]['foodImgName'].toString().replace('.', '');
                divTime.attr("picname", picName);
                divTime.click(function() {
                    if ($('#' + $(this).attr('picName')).length == 0) {
                        $('<div />').attr('id', $(this).attr('picName')).addClass('clientFoodPic c' + $(this).attr('classtime')).css("display", "none").css('background-image', 'URL(' + url + "../foodshots/" + $(this).attr('img') + '.jpg)').click(function() {
                            $(this).slideToggle(function() {
                                $(this).remove();
                            });
                        }).insertAfter($(this)).slideToggle();
                    } else {
                        $("#" + $(this).attr('picName')).slideToggle(function() {
                            $(this).remove();
                        });
                    }
                });
            }
        }
    }
}

function getCoachPermissions() {
    $.getJSON(url + "clientcoachlist/", {guid: GUID}, function(data) {
        var cp = $('#coachPermissions');
        var li, p, c, l, divCB, div;
        if (cp) {
            cp.empty();
            if (data) {
                if (data.coaches) {
                    var coaches = data.coaches;
                    if (coaches.length > 0) {
                        li = $("<li />").addClass("setbtn botom-border-list");
                        p = $("<p />").addClass("label").append("Permissions").appendTo(li);
                        li.appendTo(cp);
                        var x = 0;
                        for (x = 0; x < coaches.length; x++) {
                            li = $("<li />").addClass("setbtn botom-border-list").appendTo(cp);

                            p = $("<p />").addClass("label").append(coaches[x].coachName).css("width", "100%");
                            p.data("x", x);
                            p.click(function() {
                                $("#coach_" + $(this).data("x")).slideToggle();
                            });

                            li.append(p);

                            div = $("<div />").css("clear", "both").css("margin-top", "48px").css("padding-bottom", "12px").css("display", "none").attr("id", "coach_" + x);

                            divCB = $('<div />').css("padding", "4px 0");
                            c = $("<input />").attr("type", "checkbox").attr("id", "pFoodPics_" + x).css("margin-right", "1em").appendTo(divCB);
                            if (coaches[x].pFoodPics)
                                c.attr("checked", "checked");
                            l = $("<label />").attr("for", "pFoodPics_" + x).append("Food Pics").appendTo(divCB);
                            divCB.appendTo(div);

                            divCB = $('<div />').css("padding", "4px 0");
                            c = $("<input />").attr("type", "checkbox").attr("id", "pBodyPics_" + x).css("margin-right", "1em").appendTo(divCB);
                            if (coaches[x].pBodyPics)
                                c.attr("checked", "checked");
                            l = $("<label />").attr("for", "pBodyPics_" + x).append("Body Pics").appendTo(divCB);
                            divCB.appendTo(div);

                            divCB = $('<div />').css("padding", "4px 0");
                            c = $("<input />").attr("type", "checkbox").attr("id", "pTakeBodyPics_" + x).css("margin-right", "1em").appendTo(divCB);
                            if (coaches[x].pTakeBodyPics)
                                c.attr("checked", "checked");
                            l = $("<label />").attr("for", "pTakeBodyPics_" + x).append("Take Body Pics").appendTo(divCB);
                            divCB.appendTo(div);

                            divCB = $('<div />').css("padding", "4px 0");
                            c = $("<input />").attr("type", "checkbox").attr("id", "pBiometrics_" + x).css("margin-right", "1em").appendTo(divCB);
                            if (coaches[x].pBiometrics)
                                c.attr("checked", "checked");
                            l = $("<label />").attr("for", "pBiometrics_" + x).append("Biometrics").appendTo(divCB);
                            divCB.appendTo(div);

                            divCB = $('<div />').css("padding", "4px 0");
                            c = $("<input />").attr("type", "checkbox").attr("id", "pMobilePhone_" + x).css("margin-right", "1em").appendTo(divCB);
                            if (coaches[x].pMobilePhone)
                                c.attr("checked", "checked");
                            l = $("<label />").attr("for", "pMobilePhone_" + x).append("Phone Contact").appendTo(divCB);
                            divCB.appendTo(div);
                            div.appendTo(li);
                            p = $("<a />").addClass("value").append("Save").appendTo(div);
                            p.data("x", x);
                            p.data("coachGUID", coaches[x].coachGUID);
                            p.click(function() {
                                savePermission($(this).data('x'), $(this).data('coachGUID'));
                                $(this).hide();
                            });
                        }
                    }
                }
            }
            cp.listview('refresh');
        }
    });
}

function savePermission(x, coachGUID) {
    var pFoodPics = 0;
    if ($('#pFoodPics_' + x).attr("checked"))
        pFoodPics = 1;
    var pBodyPics = 0;
    if ($('#pBodyPics_' + x).attr("checked"))
        pBodyPics = 1;
    var pTakeBodyPics = 0;
    if ($('#pTakeBodyPics_' + x).attr("checked"))
        pTakeBodyPics = 1;
    var pBiometrics = 0;
    if ($('#pBiometrics_' + x).attr("checked"))
        pBiometrics = 1;
    var pMobilePhone = 0;
    if ($('#pMobilePhone_' + x).attr("checked"))
        pMobilePhone = 1;

    $.post(url + "savepermissions/", {
        guid: GUID,
        coachGUID: coachGUID,
        pFoodPics: pFoodPics,
        pBodyPics: pBodyPics,
        pTakeBodyPics: pTakeBodyPics,
        pBiometrics: pBiometrics,
        pMobilePhone: pMobilePhone
    }, function(data) {
        getCoachPermissions();
    });
}

function padLeft(s, n, pad)
{
    s = s.toString();
    t = '';
    if (n > s.length) {
        for (i = 0; i < n - s.length; i++) {
            t += pad;
        }
    }
    return t + s;
}