(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "设备主表" },
        shokuba: { text: "车间" },
        cd_setsubi: { text: "编号" },
        nm_setsubi: { text: "设备名" },
        flg_mishiyo: { text: "未使用" },
        cd_create: { text: "登录者" },
        dt_create: { text: "登录日期" },
        ts: { text: "时间标记" },
        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_shokuba: {
            rules: {
                required: "车间"
            },
            messages: {
                required: MS0004
            }
        },
        cd_setsubi: {
            rules: {
                required: "设备编号",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_setsubi: {
            rules: {
                required: "设备名",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
    // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
    // TODO: ここまで
});

//// ページデータ -- End
})();
