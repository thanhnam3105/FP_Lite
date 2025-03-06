(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0000:秤画面标样" },
        beep: { text: "Beep(ActiveX调用考试)" },
        portName: { text: "端口名读取" },
        portOpen: { text: "开" },
        //portClose: { text: "闭关" },
        portClose: { text: "关闭" },
        checkPort: { text: "使用可能确认" },
        writeLineData: { text: "行记入" },
        readLineData: { text: "行读入" },
        readAllData: { text: "全体读入" },
        getBaudrate: { text: "通信速度读取" },
        setBaudrate: { text: "通信速度设定" },
        getByteSize: { text: "数据bit读取" },
        setByteSize: { text: "数据bit设定" },
        getParity: { text: "parity取得" },
        setParity: { text: "parity设定" },
        getStopBit: { text: "stop bit取得" },
        setStopBit: { text: "stop bit设定" },
        getTimeout: { text: "读入暂停读取" },
        setTimeout: { text: "读入暂停设定" },
        startLoop: { text: "连续读入开始" },
        stopLoop: { text: "连续读入停止" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        methodReturn: 
        {
	        "0" : "0:正常结束" , 
	        "-1": "-1:暂停" , 
	        "-2": "-2:参数不正确" , 
	        "-3": "-3:已启动端口" , 
	        "-4": "-4:启动端口失败" , 
	        "-5": "-5:端口未启动" , 
	        //"-6": "-6:端口闭关失敗" , 
	        "-6": "-6:端口关闭失敗" , 
	        "-7": "-7:记入失败" , 
	        "-8": "-8:读入失败" , 
	        "-9": "-9:超过了数据量（>65536Bytes）" , 
	        "-10": "-10:Unicode变换错误" , 
	        "-11": "-11:暂停设定失败" , 
	        "-12": "-12:初始化时未处理数据删除失败"
        },

        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
