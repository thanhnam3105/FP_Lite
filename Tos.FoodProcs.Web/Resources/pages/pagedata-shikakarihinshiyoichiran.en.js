(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Semi-Finished Item Usage List" },
        //dt_shikomi_search: { text: "Produce date" },
        dt_shikomi_search: { text: "Production date" },
        shikakariCode: { text: "Code" },
        shikakariName: { text: "Name" },
        shikakariSearch: { text: "Semi-finished item list" },
        //明細項目
        //flg_keikaku: { text: "Determinatiion" },
        flg_keikaku: { text: "Determination" },
        //dt_shikomi: { text: "Produce date" },
        dt_shikomi: { text: "Production date" },
        //nm_shokuba_shikomi: { text: "Produce workplace" },
        nm_shokuba_shikomi: { text: "Production workplace" },
        //nm_line_shikomi: { text: "Produce line" },
        nm_line_shikomi: { text: "Production line" },
        //wt_shikomi_keikaku: { text: "Produce quantity" },
        wt_shikomi_keikaku: { text: "Production quantity" },
        no_lot_shikakari: { text: "Lot" },
        flg_label: { text: "Label issuance" },
        flg_label_hasu: { text: "Label issuance(fraction)" },
        dt_seihin_seizo: { text: "Product manufacture date" },
        nm_shokuba_seizo: { text: "Product manufacture workplace" },
        nm_line_seizo: { text: "Product manufacture line" },
        cd_hinmei: { text: "Product code" },
        nm_hinmei: { text: "Product name" },
        su_seizo_yotei: { text: "Product quantity" },
        no_lot_seihin: { text: "Product lot" },
        cd_shikakari_hin: { text: "Parent semi-finished item code" },
        nm_haigo: { text: "Parent semi-finished item name" },
        //wt_shikomi_oya: { text: "Parent semi-finished item produce amount" },
        wt_shikomi_oya: { text: "Parent semi-finished item production amount" },
        no_lot_shikakari_oya: { text: "Parent semi-finished item lot" },
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

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_shikomi_search: {
            rules: {
                required: "Manufacture date",
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
                required: "Progressing item code",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "Progressing item code"
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
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
