(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "年历主表" },
        yy_nendo: { text: "年度" },
        dt_nendo_start: { text: "年度开始月" },
        kojoKyujitsu: { text: "工厂假日设定" },
        ippanKyujitsu: { text: "一般假日设定" },
        kyujitsu: { text: "假日" },
        kaijo: { text: "取消" },
        yobi: { text: "星期" },
        dt_yobi_1: { text: "1月" },
        dt_yobi_2: { text: "2月" },
        dt_yobi_3: { text: "3月" },
        dt_yobi_4: { text: "4月" },
        dt_yobi_5: { text: "5月" },
        dt_yobi_6: { text: "6月" },
        dt_yobi_7: { text: "7月" },
        dt_yobi_8: { text: "8月" },
        dt_yobi_9: { text: "9月" },
        dt_yobi_10: { text: "10月" },
        dt_yobi_11: { text: "11月" },
        dt_yobi_12: { text: "12月" },
        dt_1: { text: "1月" },
        dt_2: { text: "2月" },
        dt_3: { text: "3月" },
        dt_4: { text: "4月" },
        dt_5: { text: "5月" },
        dt_6: { text: "6月" },
        dt_7: { text: "7月" },
        dt_8: { text: "8月" },
        dt_9: { text: "9月" },
        dt_10: { text: "10月" },
        dt_11: { text: "11月" },
        dt_12: { text: "12月" }, 
        flg_kyujitsu: { text: "假日标志" },
        flg_shukujitsu: { text: "节日标记" },
        memo_1: { text: "※工厂暇日设定设定工厂不开动的日期。（反映入库计划作成）" },
        memo_2: { text: "※一般假日设定设定普通的假日。" },
        ts: { text: "时间标记" },
        cd_create: { text: "登录者" },
        dt_create: { text: "登录日期" },
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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        masterKubun: {
            rules: {
                required: "主表区分",
            },
            messages: {
                required: MS0004
            }
        },
        haigoCode: {
            rules: {
                required: "配料编号",
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
                required: "生产线编号",
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
                required: "顺序",
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
    App.ui.pagedata.operation("zh", {
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
