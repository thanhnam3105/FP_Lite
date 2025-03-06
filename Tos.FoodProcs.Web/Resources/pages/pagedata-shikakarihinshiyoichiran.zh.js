(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "半成品使用一览" },
        dt_shikomi_search: { text: "投放日" },
        shikakariCode: { text: "半成品编号" },
        shikakariName: { text: "半成品名" },
        shikakariSearch: { text: "半成品一览" },
        //明細項目
        flg_keikaku: { text: "确定" },
        dt_shikomi: { text: "投放日" },
        nm_shokuba_shikomi: { text: "投放车间" },
        nm_line_shikomi: { text: "投放生产线" },
        wt_shikomi_keikaku: { text: "投放量" },
        //no_lot_shikakari: { text: "批量" },
        no_lot_shikakari: { text: "批号" },
        flg_label: { text: "标签发行" },
        //flg_label_hasu: { text: "标签发行(零数)" },
        flg_label_hasu: { text: "标签发行(零头数)" },
        dt_seihin_seizo: { text: "产品生产日" },
        nm_shokuba_seizo: { text: "产品生产车间" },
        nm_line_seizo: { text: "产品生产线" },
        cd_hinmei: { text: "产品编号" },
        nm_hinmei: { text: "产品名" },
        su_seizo_yotei: { text: "生产量" },
        //no_lot_seihin: { text: "产品批量" },
        no_lot_seihin: { text: "产品批号" },
        cd_shikakari_hin: { text: "主要半成品编号" },
        nm_haigo: { text: "主要半成品名" },
        wt_shikomi_oya: { text: "主要半成品投放量" },
        //no_lot_shikakari_oya: { text: "主要半成品批量" },
        no_lot_shikakari_oya: { text: "主要半成品批号" },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
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

        dt_shikomi_search: {
            rules: {
                required: "生产日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },

        shikakariCode: {
            rules: {
                required: "半成品编号",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "半成品编号"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
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
