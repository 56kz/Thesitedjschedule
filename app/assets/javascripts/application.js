// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery
//= require moment/moment
//= require daterangepicker/daterangepicker
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .



document.addEventListener("turbolinks:load", function () {

    //turbolinks load wrapper

    var Calendar = FullCalendar.Calendar;

    var calendarEl = document.getElementById('calendar');

    // initialize the external events
    // -----------------------------------------------------------------

    // initialize the calendar
    // -----------------------------------------------------------------
    var calendar = new Calendar(calendarEl, {
        plugins: ['interaction', 'dayGrid', 'timeGrid'],
        defaultView: 'timeGridWeek',
        titleFormat: { year: 'numeric', month: '2-digit', day: '2-digit' },
        locale: 'es-us',
        height: 720,
        minTime: '08:00:00', /* calendar start Timing */
        maxTime: '22:00:00',  /* calendar end Timing */
        timeFormat: 'h(:mm)a',
        themeSystem: 'standalone',
        eventOverlap: false,
        header: {
            right: 'prev,next today',
            center: 'title',
            left: 'addEventButton,saveEventButton,month,agendaWeek,agendaDay,listMonth'
        },
        customButtons: {
            addEventButton: {
                text: 'Programar',
                color: 'blue',
                click: function () {

                    dateStr = $('.datepicker-here').val()
                    time_range = $('#time-picker').val()
                    inicio = 0
                    fin = 0

                    var CurrentDate = moment(new Date()).format("DD-MM-YYYY");
                    GivenDate = moment(dateStr).format("DD-MM-YYYY");

                    if(GivenDate < CurrentDate){
                        Swal.fire({
                            icon: 'error',
                            title: 'Oops...',
                            text: 'No puedes programar en una fecha pasada.'
                        })
                    }else{
                        
                        switch (time_range) {
                            case '8:00 am 10:00 am':
                                inicio = '08';
                                fin = '10';
                                break;
                            case '10:00 am 12:00 pm':
                                inicio = '10';
                                fin = '12';
                                break;
                            case '12:00 pm 02:00 pm':
                                inicio = '12';
                                fin = '14';
                                break;
                            case '2:00 pm 4:00 pm':
                                inicio = '14';
                                fin = '16';
                                break;
                            case '4:00 pm 6:00 pm':
                                inicio = '16';
                                fin = '18';
                                break;
                            case '6:00 pm 8:00 pm':
                                inicio = '18';
                                fin = '20';
                                break;
                            case '8:00 pm 10:00 pm':
                                inicio = '20';
                                fin = '22';
                                break;
                        }
    
                        var date = new Date(dateStr + 'T' + inicio + ':00:00'); // will be in local time
                        var end = new Date(dateStr + 'T' + fin + ':00:00'); // will be in local time
    
                        const date_m = moment(date);
                        const dow = date_m.day();
                        var sabado=false
    
                        if (dow==6 && (inicio=='08' || inicio=='20')){
                            sabado=true
                        }
    
                        var color = get_color(dow);
    
                        event = {
                            title: '(Nuevo) Clase en Cabina ' + $('#roow_id').val(),
                            start: date,
                            end: end,
                            overlap: false,
                            backgroundColor: color,
                            borderColor: color
                        }
    
                        if (!isNaN(date.valueOf()) && !isOverlapping(event) && !sabado) { // valid?
                            calendar.addEvent(event);
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Oops...',
                                text: 'Fecha invalida o no está disponible.'
                            })
                        }
                    }
                }
            },
            saveEventButton: {
                text: 'Guardar',
                click:  function () {

                    //Get all server events to avoid duplicate schedules

                    var all_events = calendar.getEvents();
                    var completed = 0
                    var for_save = 0
                    var error_save=0

                    for (i in all_events) {
                        let title = all_events[i].title
                        if (title.indexOf("(Nuevo)") !== -1) {
                            for_save += 1
                        }
                    }

                    $.ajaxSetup({
                        async: false
                     });

                    for (i in all_events) {
                        
                        let title = all_events[i].title

                        if (title.indexOf("(Nuevo)") !== -1) {
                            let date_m = moment(all_events[i].start);
                            let date_event = date_m.format("DD/MM/YYYY")
                            let start = date_m.format("HH")

                            data = "suscription_id=" + $('#suscription_id').val()
                                + "&schedule_id=1"
                                + "&start_hour=" + start
                                + "&reserve_date=" + date_event
                                + "&room=" + $('#roow_id').val()

                            $.ajax({
                                type: "GET",
                                url: '/rooms/' + $('#roow_id').val() + '/schedules/new',
                                data: data,
                                success:function(data, textStatus, xhr){
                                    if(data.status_code=="0"){
                                        error_save+=1
                                    }
                                }
                            });
                        }
                    }

                    if (for_save == completed) {
                        Swal.fire({
                            icon: 'info',
                            title: '...',
                            text: 'No se encontraron clases por guardar.',
                        })
                    }
                    if (error_save >0) {
                        Swal.fire({
                            icon: 'info',
                            title: '...',
                            text: 'No fue posible guardar todos los eventos.',
                        })
                    }else{
                        Swal.fire({
                            icon: 'success',
                            title: '¡Bien hecho!',
                            text: 'Se guardó la programación.',
                        })

                    }
                    
                    var eventos_local = calendar.getEvents();

                    for (i in eventos_local){
                        calendar.getEventById(eventos_local[i].id).remove();
                    }

                    load_server_events();
                }
                
            }
        },
        eventOverlap: false,
        backgroundColor: 'blue',
        editable: false,
        droppable: false, // this allows things to be dropped onto the calendar
        /*businessHours: {
          dow: [ 1, 2, 3, 4, 5], 
          start: '08:00',
          end: '22:00', 
        },*/
        drop: function (info) {
            //info.draggedEl.parentNode.removeChild(info.draggedEl);
        },
        eventClick: function (event, element) {

        }
    });

    calendar.render();

    $('.fc-saveEventButton-button').addClass("btn-success");

    $(".hour-btn").click(function () {
        val = $(this).text();
        $("#time-picker").val(val);
    });

    var disabledDays = [0];

    $(document).ready(function () {
        $dd_picker = $('#date-pick');

        $dd_picker.datepicker({
            onSelect: function (formattedDate, date, inst) {
                inst.hide();
            },
            onRenderCell: function (date, cellType) {
                if (cellType == 'day') {
                    var day = date.getDay(),
                        isDisabled = disabledDays.indexOf(day) != -1;
                    return {
                        disabled: isDisabled
                    }
                }
            }
        });

        load_server_events();

    });

    function load_server_events() {

        $.ajax({
            type: "GET",
            url: '/rooms/' + $('#roow_id').val() + '/schedules.json',
            success: function (data, textStatus, xhr) {
                for (i in data) {

                    var s_date = data[i].reserve_date;
                    var s_inicio = Right('0' + data[i].start_hour, 2);
                    var s_fin = Right('0' + (data[i].start_hour + 2), 2);
                    var sucrip_id=data[i].suscription_id

                    var date = new Date(s_date + 'T' + s_inicio + ':00:00'); // will be in local time
                    var end = new Date(s_date + 'T' + s_fin + ':00:00'); // will be in local time

                    const date_m = moment(date);
                    const dow = date_m.day();

                    if (sucrip_id!=$('#suscription_id').val()){
                        var color = '#708090'
                        title= 'Cabina Ocupada'
                    }else{
                        var color = get_color(dow);
                        title= 'Clase en Cabina ' + $('#roow_id').val()
                    }

                    event = {
                        title: title,
                        start: date,
                        end: end,
                        overlap: false,
                        backgroundColor: color,
                        borderColor: color
                    }

                    if (!isOverlapping(event)) {
                        calendar.addEvent(event);
                    }


                }
            }
        });
    }

    function get_color(dow) {
        var color = "";

        switch (dow) {
            case 1:
                color = '#6495ED';
                break;
            case 2:
                color = '#8A2BE2';
                break;
            case 3:
                color = '#DC143C';
                break;
            case 4:
                color = '#FF8C00';
                break;
            case 5:
                color = '#20B2AA';
                break;
            case 6:
                color = '#5F9EA0';
                break;
        }
        return color
    }

    function Right(str, n) {
        if (n <= 0)
            return "";
        else if (n > String(str).length)
            return str;
        else {
            var iLen = String(str).length;
            return String(str).substring(iLen, iLen - n);
        }
    }

    function isOverlapping(event) {
        // "calendar" on line below should ref the element on which fc has been called 
        var array = calendar.getEvents();

        for (i in array) {
            if (event.end > array[i].start && event.start < array[i].end) {
                return true;
            }
        }
        return false;
    }

    //finish turbolinks load wrapper

})

