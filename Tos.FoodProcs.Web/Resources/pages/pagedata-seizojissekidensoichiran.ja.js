(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "製造実績伝送一覧" },

        // ヘッダー項目
        to: { text: "～" },
        dateDensoSt: { text: "伝送日(開始)" },
        dateDensoEn: { text: "伝送日(終了)" },
        dateSeizoSt: { text: "製造日(開始)" },
        dateSeizoEn: { text: "製造日(終了)" },
        codeHinmei: { text: "製品コード" },
        SeihinLot: { text: "製品ロットNo" },
        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },
        // 明細項目
        dt_denso: { text: "伝送日時" },
        kbn_denso_SAP: { text: "SAP伝送区分" },
        dt_seizo: { text: "製造日" },
        cd_hinmei: { text: "製品コード" },
        nm_hinmei: { text: "製品名" },
        no_lot_seihin: { text: "製品ロット番号" },
        su_seizo_jisseki: { text: "製造実績数" },
        cd_tani: { text: "単位コード" },
        nm_tani: { text: "単位名" },
        no_lot_hyoji: { text: "表示ロットNo" },
        // 明細幅
        dt_denso_width: { number: 145 },
        kbn_denso_sap_width: { number: 100 },
        dt_seizo_width: { number: 100 },
        cd_hinmei_width: { number: 120 },
        nm_hinmei_width: { number: 160 },
        no_lot_seihin_width: { number: 140 },
        su_seizo_jisseki_width: { number: 120 },
        cd_tani_width: { number: 100 },
        nm_tani_width: { number: 100 },
        // 伝送区分名
        kbn_add: { text: "新規" },
        kbn_upd: { text: "更新" },
        kbn_del: { text: "削除" },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "検索条件のいずれか1つ" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },

        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { text: "8em" }

        // TODO: 画面の仕様に応じて以下の列幅を変更してください。

        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "伝送日(開始)",
                datestring: "伝送日(開始)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
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
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_seizo_start: {
            rules: {
                required: "製造日(開始)",
                datestring: "製造日(開始)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_seizo_end: {
            rules: {
                required: "製造日(終了)",
                datestring: "製造日(終了)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
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
                alphanum: true,
                custom: true
            },
            params: {
                custom: "製品コード"
            },
            messages: {
                alphanum: MS0439,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("ja", {
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
