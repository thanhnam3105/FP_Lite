
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "入库地点区分主表" },
        kbn_niuke_basho: { text: "入库地点区分" },
        nm_kbn_niuke: { text: "入库地点区分名" },
        flg_niuke: { text: "指定入库地点" },
        flg_henpin: { text: "退货" },
        flg_shukko: { text: "出库" },
        flg_mishiyo: { text: "未使用" },

        cd_create: { text: "登录者" },
        dt_create: { text: "登录日期" },
        dt_update: { text: "更新日期" },
        cd_update: { text: "更新者" },
        ts: { text: "时间戳" },

        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        kbn_niuke_basho_width: { number: 100 },
        nm_kbn_niuke_width: { number: 300 },
        flg_niuke_width: { number: 120 },
        flg_henpin_width: { number: 70 },
        flg_shukko_width: { number: 70 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        kbn_niuke_basho: {
            rules: {
                required: "入库地点区分",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_kbn_niuke: {
            rules: {
                required: "入库地点区分名",
                maxbytelength: 50,
                illegalchara: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                illegalchara: MS0005
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.kbn_niuke_basho": {
            Admin: { enable: true },
            guest: { enable: false },
            manager: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
