//******  SIMPLIFIED CHINESE  ******
jQuery(function ($) {
    $.datepicker.regional['zh'] = {
        closeText: "关闭",
        prevText: "&#x3c;上月",
        nextText: "下月&#x3e;",
        currentText: "今天",
        monthNames: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        monthNamesShort: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        dayNames: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
        dayNamesShort: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
        //dayNamesMin: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"],
        dayNamesMin: ["日", "一", "二", "三", "四", "五", "六"],
        weekHeader: "周",
        dateFormat: 'yy/mm/dd',
        firstDay: 0,
        isRTL: false,
        showMonthAfterYear: true,
        yearSuffix: "年"
    };
    $.datepicker.setDefaults($.datepicker.regional['zh']);
});