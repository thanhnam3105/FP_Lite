(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "仕掛品使用一覧"},
        dt_shikomi_search: { text: "仕込日" },
        shikakariCode: { text: "仕掛品コード" },
        shikakariName: { text: "仕掛品名" },
        shikakariSearch: { text: "仕掛品一覧" },
        //明細項目
        flg_keikaku: { text: "確定" },
        dt_shikomi: { text: "仕込日" },
        nm_shokuba_shikomi: { text: "仕込職場" },
        nm_line_shikomi: { text: "仕込ライン" },
        wt_shikomi_keikaku: { text: "仕込量" },
        no_lot_shikakari: { text: "ロット" },
        flg_label: { text: "ラベル発行" },
        flg_label_hasu: { text: "ラベル発行(端数)" },
        dt_seihin_seizo: { text: "製品製造日" },
        nm_shokuba_seizo: { text: "製品製造職場" },
        nm_line_seizo: { text: "製品製造ライン" },
        cd_hinmei: { text: "製品コード" },
        nm_hinmei: { text: "製品名" },
        su_seizo_yotei: { text: "製造量" },
        no_lot_seihin: { text: "製品ロット" },
        cd_shikakari_hin: { text: "親仕掛品コード" },
        nm_haigo: { text: "親仕掛品名" },
        wt_shikomi_oya: { text: "親仕掛品仕込量" },
        no_lot_shikakari_oya: { text: "親仕掛品ロット" },
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

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        dt_shikomi_search: {
            rules: {
                required: "製造日",
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
                required: "仕掛品コード",
                alphanum: true,
                maxbytelength: 14,
				custom: true
            },
            params: {
                custom: "仕掛品コード"
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
    App.ui.pagedata.operation("ja", {
    // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
