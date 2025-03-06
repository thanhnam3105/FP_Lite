(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "BOMマスタ伝送一覧" },

        // ヘッダー、検索条件項目
        to: { text: "～　" },
        dateDensoSt: { text: "伝送日(開始)" },
        dateDensoEn: { text: "伝送日(終了)" },
        codeSeihin: { text: "製品コード" },
        codeHaigo: { text: "配合コード" },
        codeHinmei: { text: "品名コード" },

        // 明細項目
        dt_denso: { text: "伝送日時" },
        kbn_denso: { text: "伝送区分" },
        cd_seihin: { text: "製品コード" },
        nm_seihin: { text: "製品名" },
        dt_from: { text: "有効日付(開始)" },
        su_kihon: { text: "基本数量" },
        cd_hinmei: { text: "品名コード" },
        nm_hinmei: { text: "品名" },
        su_hinmoku: { text: "品目数量" },
        cd_tani: { text: "数量単位" },
        su_kaiso: { text: "階層" },
        cd_haigo: { text: "配合コード" },
        nm_haigo: { text: "配合名" },
        no_kotei: { text: "工程番号" },
        no_tonyu: { text: "投入番号" },

        // その他、定数定義、固定文言、隠し項目など
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        overSearchNumber: { text: MS0568 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        kbn_denso_width: { number: 80 },
        su_hinmoku_width: { number: 120 },
        no_kotei_width: { number: 75 },
        su_kihon_width: { number: 100 },
        su_kaiso_width: { number: 60 },
        dt_from_width: { number: 120 },
        lang_item_denso: { number: 100 },
        lang_denso_tbl: { number: 560 },
        each_lang_width: { number: 100 }
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "伝送日(開始)",
                datestring: "伝送日(開始)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1999/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_denso_end: {
            rules: {
                required: "伝送日(終了)",
                datestring: "伝送日(終了)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1999/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "製品コード"
            },
            messages: {
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "品名コード"
            },
            messages: {
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        cd_haigo: {
            rules: {
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "配合コード"
            },
            messages: {
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("ja", {
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
