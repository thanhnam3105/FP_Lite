;(function($){
/**
 * jqGrid English Translation
 * Tony Tomov tony@trirand.com
 * http://trirand.com/blog/ 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = $.jgrid || {};
$.extend($.jgrid,{
	defaults : {
		recordtext: "Xem {0} - {1} của {2}",
        emptyrecords: "Không có record nào.",
        loadtext: "Đang tải...",
        pgtext : "Trang {0} của {1}"
	},
	search : {
		caption: "Tìm kiếm...",
        Find: "Tìm thấy",
        Reset: "Làm lại",
        odata : ['bằng', 'không bằng', 'nhỏ hơn', 'nhỏ hơn hoặc bằng','lớn hơn','lớn hơn hoặc bằng', 'bắt đầu bằng','không bắt đầu bằng','thuộc','không thuộc','kết thúc bằng','không kết thúc bằng ','chứa','không chứa'],
        groupOps: [ { op: "AND", text: "tất cả" }, { op: "OR",  text: "một trong những" } ],
        matchText: " khớp",
        rulesText: " quy tắc"
	},
	edit : {
		addCaption: "Thêm record",
        editCaption: "Sửa record",
        bSubmit: "Gửi",
        bCancel: "Hủy",
        bClose: "Đóng",
        saveData: "Dữ liệu đã thay đổi. Bạn có lưu không?",
        bYes : "Có",
        bNo : "Không",
        bExit : "Hủy",
		msg: {
			required:"Trường dữ liệu bắt buộc",
            number:"Vui lòng nhập số hợp lệ",
            minValue:"giá trị phải lớn hơn hoặc bằng ",
            maxValue:"giá trị phải nhỏ hơn hoặc bằng",
            email: "không phải là e-mail hợp lệ",
            integer: "Vui lòng nhập số nguyên hợp lệ",
            date: "Vui lòng nhập ngày hợp lệ",
            url: "không phải là URL hợp lệ. URL phải bắt đầu bằng ('http://' or 'https://')",
            nodefined : " không được định nghĩa!",
            novalue : " bắt buộc trả về giá trị!",
            customarray : "Custom function nên trả về array!",
            customfcheck : "Khi khách hàng kiểm tra thì Custom function nên đang chạy!"			
			
		}
	},
	view : {
		caption: "Xem record",
        bClose: "Đóng"
	},
	del : {
		caption: "Xóa",
        msg: "Xóa record đã chọn?",
        bSubmit: "Xóa",
        bCancel: "Hủy"
	},
	nav : {
		edittext: "",
        edittitle: "Sửa dòng đã chọn",
		addtext:"",
        addtitle: "Thêm dòng mới",
		deltext: "",
        deltitle: "Xóa dòng đã chọn",
		searchtext: "",
        searchtitle: "Tìm thấy record",
		refreshtext: "",
        refreshtitle: "Tải lại lưới",
        alertcap: "Cảnh báo",
        alerttext: "Vui lòng chọn dòng",
		viewtext: "",
        viewtitle: "Xem dòng đã chọn"
	},
	col : {
		caption: "Chọn cột",
        bSubmit: "Gửi",
        bCancel: "Hủy"
	},
	errors : {
		errcap : "Lỗi",
        nourl : "Không URL nào được thiết đặt",
        norecords: "Không record nào được thực thi",
        model : "Chiều dài  colNames khác chiều dài colModel!"
	},
	formatter : {
		integer : {thousandsSeparator: ",", defaultValue: '0'},
		number : {decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, defaultValue: '0.00'},
		currency : {decimalSeparator:".", thousandsSeparator: ",", decimalPlaces: 2, prefix: "", suffix:"", defaultValue: '0.00'},
		date : {
			dayNames:   [
				"CN", "T2", "T3", "T4", "T5", "T6", "T7",
                "chủ nhật", "hai", "ba", "tư", "năm", "sáu", "bảy"
			],
			monthNames: [
				"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
                "Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"
			],
			AmPm : ["am","pm","AM","PM"],
			S: function (j) {return j < 11 || j > 13 ? ['st', 'nd', 'rd', 'th'][Math.min((j - 1) % 10, 3)] : 'th';},
			srcformat: 'Y-m-d',
			newformat: 'n/j/Y',
			masks : {
				// see http://php.net/manual/en/function.date.php for PHP format used in jqGrid
				// and see http://docs.jquery.com/UI/Datepicker/formatDate
				// and https://github.com/jquery/globalize#dates for alternative formats used frequently
				// one can find on https://github.com/jquery/globalize/tree/master/lib/cultures many
				// information about date, time, numbers and currency formats used in different countries
				// one should just convert the information in PHP format
				ISO8601Long:"Y-m-d H:i:s",
				ISO8601Short:"Y-m-d",
				// short date:
				//    n - Numeric representation of a month, without leading zeros
				//    j - Day of the month without leading zeros
				//    Y - A full numeric representation of a year, 4 digits
				// example: 3/1/2012 which means 1 March 2012
				ShortDate: "n/j/Y", // in jQuery UI Datepicker: "M/d/yyyy"
				// long date:
				//    l - A full textual representation of the day of the week
				//    F - A full textual representation of a month
				//    d - Day of the month, 2 digits with leading zeros
				//    Y - A full numeric representation of a year, 4 digits
				LongDate: "l, F d, Y", // in jQuery UI Datepicker: "dddd, MMMM dd, yyyy"
				// long date with long time:
				//    l - A full textual representation of the day of the week
				//    F - A full textual representation of a month
				//    d - Day of the month, 2 digits with leading zeros
				//    Y - A full numeric representation of a year, 4 digits
				//    g - 12-hour format of an hour without leading zeros
				//    i - Minutes with leading zeros
				//    s - Seconds, with leading zeros
				//    A - Uppercase Ante meridiem and Post meridiem (AM or PM)
				FullDateTime: "l, F d, Y g:i:s A", // in jQuery UI Datepicker: "dddd, MMMM dd, yyyy h:mm:ss tt"
				// month day:
				//    F - A full textual representation of a month
				//    d - Day of the month, 2 digits with leading zeros
				MonthDay: "F d", // in jQuery UI Datepicker: "MMMM dd"
				// short time (without seconds)
				//    g - 12-hour format of an hour without leading zeros
				//    i - Minutes with leading zeros
				//    A - Uppercase Ante meridiem and Post meridiem (AM or PM)
				ShortTime: "g:i A", // in jQuery UI Datepicker: "h:mm tt"
				// long time (with seconds)
				//    g - 12-hour format of an hour without leading zeros
				//    i - Minutes with leading zeros
				//    s - Seconds, with leading zeros
				//    A - Uppercase Ante meridiem and Post meridiem (AM or PM)
				LongTime: "g:i:s A", // in jQuery UI Datepicker: "h:mm:ss tt"
				SortableDateTime: "Y-m-d\\TH:i:s",
				UniversalSortableDateTime: "Y-m-d H:i:sO",
				// month with year
				//    Y - A full numeric representation of a year, 4 digits
				//    F - A full textual representation of a month
				YearMonth: "F, Y" // in jQuery UI Datepicker: "MMMM, yyyy"
			},
			reformatAfterEdit : false
		},
		baseLinkUrl: '',
		showAction: '',
		target: '',
		checkbox : {disabled:true},
		idName : 'id'
	}
});
})(jQuery);