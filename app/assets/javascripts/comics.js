var ajax_wait = false;
var curr_episode;
var curr_page;
var pages;
var next_episode;
var prev_episode;
var is_navigatable = false;
var is_prev_navigatable = false;
var is_next_navigatable = true;
var first_non_tbc;
var last_non_tbc;
var next_mission;

// load a specific episode,
function load_episode_info(id, load_first_page) {
    if (ajax_wait) {
        return;
    }
    start_loading();

    $.ajax({
        method: 'get',
        url: id + '/info',
        dataType: 'json',
        success: function(data) {
            curr_episode = data.current;
            if (data.pages.length > 0) {
                pages = data.pages;
            } else {
                pages = [];
                pages[0] = {
                    url: $('.sidebar-course-logo').attr('src'),
                    tbc: false
                }
            }
            next_episode = data.next;
            prev_episode = data.prev;
            next_mission = data.next_mission;
            load_pages(pages);
            update_view(load_first_page);
        }
    });
    ajax_wait = true;
}


function start_loading() {
    $('#current-image').css('opacity', 0.2);
    $('#loading-indicator').css('opacity', 1);
    is_navigatable = false;
}

function finish_loading() {
    $('#current-image').css('opacity', 1);
    $('#loading-indicator').css('opacity', 0);
    is_navigatable = true;
}

function disable_next() {
    $('#next_btn').click(function(e) {
        next_page();
        e.preventDefault();
    });

    $('#prev_btn').click(function(e) {
        prev_page();
        e.preventDefault();
    });
}

// loads each page into memory
function load_pages(pages) {
    var page_count = pages.length;
    console.log(page_count);
    if (pages === 0) {
        finish_loading();
    }
    first_non_tbc = null;
    last_non_tbc = null;
    $(pages).each(function(index){
        var x = $('<img/>');
        x[0].src = this.url;
        var that = this;
        x.on('load', function(){
            page_count --;
            if (page_count === 0) {
                finish_loading();
            }
        });
        if (first_non_tbc === null && !this.tbc) {
            first_non_tbc = index;
        }
        if (!this.tbc) {
            last_non_tbc = index;
        }

    });
    ajax_wait = false;
}

function update_view(load_first_page) {
    $('#current-episode-title').text(curr_episode.episode + '. ' + curr_episode.name);
    if (load_first_page) {
        curr_page = first_non_tbc;
    } else {
        curr_page = last_non_tbc;
    }
    $('#current-image').attr('src', pages[curr_page].url);
    update_navigation_buttons();
}

function next_page() {
    if (!is_navigatable || !is_next_navigatable) {
        return;
    }
    curr_page ++;
    if (curr_page < pages.length) {
        if (!pages[curr_page].tbc || !next_episode) {
            $('#current-image').attr('src', pages[curr_page].url);
            update_navigation_buttons();
        } else {
            next_page();
        }
    } else {
        load_episode_info(next_episode.id, true);
    }
}

function prev_page() {
    if (!is_navigatable || !is_prev_navigatable) {
        return;
    }
    curr_page --;
    if (curr_page >= 0) {
        $('#current-image').attr('src', pages[curr_page].url);
        update_navigation_buttons();
    } else {
        load_episode_info(prev_episode.id, false);
    }
}

function update_navigation_buttons() {
    if (!prev_episode && curr_page <= first_non_tbc) {
        is_prev_navigatable = false;
        $('#prev_btn').addClass('disabled-navigator');
    } else {
        is_prev_navigatable = true;
        $('#prev_btn').removeClass('disabled-navigator');
    }

    if (!next_episode && curr_page >= last_non_tbc) {
        is_next_navigatable = false;
        $('#next_btn').addClass('disabled-navigator');
        if (next_mission) {
            var redirect = confirm('Do you want to start ' + next_mission.title + ' now?');
            if (redirect) {
                window.location.href = next_mission.url;
            }
        }
    } else {
        is_next_navigatable = true;
        $('#next_btn').removeClass('disabled-navigator');
    }
}
