(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0000: Ví dụ mẫu màn hình cân" },
        beep: { text: "Beep (Kiểm tra gọi ActiveX)" },
        portName: { text: "Lấy tên cổng" },
        portOpen: { text: "Mở" },
        portClose: { text: "Đóng" },
        checkPort: { text: "Kiểm tra khả năng sử dụng" },
        writeLineData: { text: "Ghi" },
        readLineData: { text: "Đọc" },
        readAllData: { text: "Đọc tất cả" },
        getBaudrate: { text: "Lấy tốc độ truyền gửi" },
        setBaudrate: { text: "Thiết lập tốc độ truyền gửi" },
        getByteSize: { text: "Lấy data bit" },
        setByteSize: { text: "Thiết lập data bit" },
        getParity: { text: "Lấy parity" },
        setParity: { text: "Thiết lập parity" },
        getStopBit: { text: "Lấy stop bit" },
        setStopBit: { text: "Thiết lập stop bit" },
        getTimeout: { text: "Lấy timeout đọc dữ liệu" },
        setTimeout: { text: "Thiết lập timeout đọc dữ liệu" },
        startLoop: { text: "Bắt đầu đọc liên tục" },
        stopLoop: { text: "Dừng đọc liên tục" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        methodReturn: 
        {
	        "0" : "0:Kết thúc bình thường" , 
	        "-1": "-1:Quá thời gian chờ",
	        "-2": "-2:Tham số sai" , 
	        "-3": "-3:Đã mở port" , 
	        "-4": "-4:Mở port thất bại" , 
	        "-5": "-5:Chưa mở port" , 
	        "-6": "-6:Đóng port thất bại" , 
	        "-7": "-7:Ghi dữ liệu thất bại" , 
	        "-8": "-8:Đọc dữ liệu thất bại" , 
	        "-9": "-9:Vượt dung lượng dữ liệu (>65536Bytes)" , 
	        "-10": "-10:Lỗi chuyển Unicode" , 
	        "-11": "-11:Thiết lập timeout thất bại" , 
	        "-12": "-12:Thất bại ở bước xóa dữ liệu chưa xử lý khi khởi tạo."
        },

        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();