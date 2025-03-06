(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0000:秤画面サンプル" },
        beep: { text: "Beep(ActiveX呼び出しテスト)" },
        portName: { text: "ポート名取得" },
        portOpen: { text: "オープン" },
        portClose: { text: "クローズ" },
        checkPort: { text: "使用可能チェック" },
        writeLineData: { text: "行書き込み" },
        readLineData: { text: "行読み込み" },
        readAllData: { text: "全体読み込み" },
        getBaudrate: { text: "通信速度取得" },
        setBaudrate: { text: "通信速度設定" },
        getByteSize: { text: "データビット取得" },
        setByteSize: { text: "データビット設定" },
        getParity: { text: "パリティ取得" },
        setParity: { text: "パリティ設定" },
        getStopBit: { text: "ストップビット取得" },
        setStopBit: { text: "ストップビット設定" },
        getTimeout: { text: "読み込みタイムアウト取得" },
        setTimeout: { text: "読み込みタイムアウト設定" },
        startLoop: { text: "連続読み込み開始" },
        stopLoop: { text: "連続読み込み停止" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        methodReturn: 
        {
	        "0" : "0:正常終了" , 
	        "-1": "-1:タイムアウト" , 
	        "-2": "-2:パラメータ不正" , 
	        "-3": "-3:ポートオープン済" , 
	        "-4": "-4:ポートオープン失敗" , 
	        "-5": "-5:ポート未オープン" , 
	        "-6": "-6:ポートクローズ失敗" , 
	        "-7": "-7:書き込み失敗" , 
	        "-8": "-8:読み込み失敗" , 
	        "-9": "-9:データ量超過（>65536Bytes）" , 
	        "-10": "-10:Unicode変換エラー" , 
	        "-11": "-11:タイムアウト設定失敗" , 
	        "-12": "-12:初期化時未処理データ消去失敗"
        },

        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
