// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// NOTICE!! DO NOT USE ANY OF THIS JAVASCRIPT
// IT'S ALL JUST JUNK FOR OUR DOCS!
// ++++++++++++++++++++++++++++++++++++++++++

!function ($) {

    $(function(){

        var $window = $(window)

        // Disable certain links in docs
        $('section [href^=#]').click(function (e) {
            e.preventDefault()
        })

        // side bar
        setTimeout(function () {
            $('.duplicate_sidenav').affix({
                offset: {
                    top: function () { return $window.width() <= 980 ? 290 : 210 }
                    , bottom: 270
                }
            })
        }, 100)

    })

}(window.jQuery)
