/*!
* for Internet Explorer 6.
*
* http://www.archway.co.jp
* Copyright (c) Archway Inc. All rights reserved.
*/
(function (global, $) {

    var html5tags = ['header', 'section', 'article', 'footer'];

    (function (tags) {

        var i;
        for (i = 0; i < tags.length; i++) {
            document.createElement(tags[i]);
        }

    })(html5tags);


    var ltIE6 = (typeof window.addEventListener === 'undefined' &&
                 typeof document.documentElement.style.maxHeight === 'undefined');

    if (!ltIE6) {

        var originalhide = $.fn.hide
            , originalshow = $.fn.show;

        $.fn.hide = function () {
            var self = $(this);
            self.find('select').css('visibility', 'hidden');
            return originalhide.apply(self, arguments);
        };

        $.fn.show = function () {
            var self = $(this);
            self.find('select').css('visibility', '');
            return originalshow.apply(self, arguments);
        };

        try {
            document.execCommand('BackgroundImaeCache', false, true);
        }
        catch (exception) {
        }


        return;
    }




} (this, jQuery));
