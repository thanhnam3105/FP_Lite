
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "单位设定主表" },
        cd_tani: { text: "单位编号" },
        nm_tani: { text: "单位名" },
        flg_kinshi: { text: "禁止" },
        flg_mishiyo: { text: "未使用" },
        dt_create: { text: "登录日期" },
        cd_create: { text: "登录者" },
        dt_update: { text: "更新日期" },
        cd_update: { text: "更新者" },
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

        cd_tani: {
            rules: {
                required: "单位编号",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_tani: {
            rules: {
                required: "单位",
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
    // 権限設定
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        colchange: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
    //// ページデータ -- End
})();
