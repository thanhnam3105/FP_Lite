(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Calendar Master" },
        yy_nendo: { text: "Year" },
        dt_nendo_start: { text: "New year start month" },
        kojoKyujitsu: { text: "Set plant holiday" },
        ippanKyujitsu: { text: "Set public holiday" },
        kyujitsu: { text: "Holiday" },
        kaijo: { text: "Release" },
        yobi: { text: "Day of the week" },
        dt_yobi_1: { text: "Jan" },
        dt_yobi_2: { text: "Feb" },
        dt_yobi_3: { text: "Mar" },
        dt_yobi_4: { text: "Apr" },
        dt_yobi_5: { text: "May" },
        dt_yobi_6: { text: "Jun" },
        dt_yobi_7: { text: "Jul" },
        dt_yobi_8: { text: "Aug" },
        dt_yobi_9: { text: "Sep" },
        dt_yobi_10: { text: "Oct" },
        dt_yobi_11: { text: "Nov" },
        dt_yobi_12: { text: "Dec" },
        dt_1: { text: "January" },
        dt_2: { text: "February" },
        dt_3: { text: "March" },
        dt_4: { text: "April" },
        dt_5: { text: "May" },
        dt_6: { text: "June" },
        dt_7: { text: "July" },
        dt_8: { text: "August" },
        dt_9: { text: "September" },
        dt_10: { text: "October" },
        dt_11: { text: "November" },
        dt_12: { text: "December" },
        flg_kyujitsu: { text: "Holiday flag" },
        flg_shukujitsu: { text: "National holiday flag" },
        memo_1: { text: "※Factory holiday setting sets the date on which the plant is not running." },
        memo_2: { text: "※General holiday setting sets the holiday in general." },
        ts: { text: "Time stamp" },
        cd_create: { text: "Registrant" },
        dt_create: { text: "Registration date" },
        // TODO: ここまで

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        saveConfirm: { text: MS0064 },
        findConfirm: { text: MS0065 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "Master type",
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "Formula code",
                alphanum: true,
                maxbytelength: 14
            },
            messages: {
                required: MS0004,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_line: {
            rules: {
                required: "Line code",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        no_yusen: {
            rules: {
                required: "Order",
                digits: true,
                range: [1, 99],
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                digits: MS0005,
                range: MS0009,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: false }
        },
        settei: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
