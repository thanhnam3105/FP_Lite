(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0000:Scale Screen Sample" },
        beep: { text: "Beep(ActiveX calling test)" },
        portName: { text: "Get port name" },
        portOpen: { text: "Open" },
        portClose: { text: "Close" },
        checkPort: { text: "Available check" },
        writeLineData: { text: "Write in" },
        readLineData: { text: "Read in" },
        readAllData: { text: "Read all" },
        getBaudrate: { text: "Get communication speed" },
        setBaudrate: { text: "Set communication speed" },
        getByteSize: { text: "Get data bit" },
        setByteSize: { text: "Set data bit" },
        getParity: { text: "Get parity" },
        setParity: { text: "Set parity" },
        getStopBit: { text: "Get stop bit" },
        setStopBit: { text: "Set stop bit" },
        getTimeout: { text: "Get read timeout" },
        setTimeout: { text: "Set read timeout" },
        startLoop: { text: "Start sequence reading" },
        stopLoop: { text: "Stop sequence reading" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        methodReturn: 
        {
	        "0" : "0:Normal termination" , 
	        "-1": "-1:Time out" , 
	        "-2": "-2:Invalid parameter" , 
	        "-3": "-3:The port is open" , 
	        "-4": "-4:Failed to open the port" , 
	        "-5": "-5:The port not open" , 
	        "-6": "-6:Failed to close the port" , 
	        "-7": "-7:Failed to write" , 
	        "-8": "-8:Failed to read" , 
	        "-9": "-9:Exceed the data amount（>65536Bytes）" , 
	        "-10": "-10:Unicode convert error" , 
	        "-11": "-11:Failed to set time out" , 
	        "-12": "-12:Failed to delete unprocessed data at initialization"
        },

        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
