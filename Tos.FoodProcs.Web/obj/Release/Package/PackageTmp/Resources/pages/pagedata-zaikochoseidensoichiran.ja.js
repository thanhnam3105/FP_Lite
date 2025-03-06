(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "在庫調整伝送一覧" },

        // ヘッダー項目
        to: { text: "～" },
        dateDensoSt: { text: "伝送日(開始)" },
        dateDensoEn: { text: "伝送日(終了)" },
        dateTenkiSt: { text: "転記日(開始)" },
        dateTenkiEn: { text: "転記日(終了)" },
        codeHinmei: { text: "品名コード" },
        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },

        //明細項目
        dt_denso: { text: "伝送日時" },
        kbn_denso_SAP: { text: "SAP伝送区分" },
        dt_tenki: { text: "転記日" },
        cd_soko: { text: "倉庫コード" },
        nm_soko: { text: "倉庫名" },
        cd_genka_center: { text: "原価センターコード" },
        nm_genka_center: { text: "原価センター名" },
        cd_riyu: { text: "理由コード" },
        nm_riyu: { text: "理由名" },
        cd_hinmei: { text: "品名コード" },
        nm_hinmei: { text: "品名" },
        su_chosei: { text: "調整数" },
        cd_tani: { text: "単位コード" },
        nm_tani: { text: "単位名" },
        dt_denpyo: { text: "伝票日" },
        kbn_ido: { text: "移動区分" },

        //明細幅
        dt_denso_width: { number: 145 },
        kbn_denso_SAP_width: { number: 100 },
        dt_tenki_width: { number: 100 },
        cd_soko_width: { number: 100 },
        nm_soko_width: { number: 100 },
        cd_genka_center_width: { number: 120 },
        nm_genka_center_width: { number: 120 },
        cd_riyu_width: { number: 90 },
        nm_riyu_width: { number: 100 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 130 },
        su_chosei_width: { number: 100 },
        cd_tani_width: { number: 90 },
        nm_tani_width: { number: 80 },
        dt_denpyo_width: { number: 100 },
        kbn_ido_width: { number: 80 },

        //伝送区分名
        kbn_add: { text: "新規" },
        kbn_upd: { text: "更新" },
        kbn_del: { text: "削除" },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "検索条件のいずれか1つ" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },


        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { text: "8em" },

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
        dt_tenki_start: {
            rules: {
                required: "転記日(開始)",
                datestring: "転記日(開始)",
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
        dt_tenki_end: {
            rules: {
                required: "転記日(終了)",
                datestring: "転記日(終了)",
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
        cd_hinmei: {
            rules: {
                alphanum: true,
                custom: true
            },
            params: {
                custom: "品名コード"
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
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
