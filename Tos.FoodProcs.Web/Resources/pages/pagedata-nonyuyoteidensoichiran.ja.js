(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "納入予定伝送一覧" },

        // ヘッダー、検索条件項目
        to: { text: "　～　" },
        dateDensoSt: { text: "伝送日(開始)" },
        dateDensoEn: { text: "伝送日(終了)" },
        dateNonyuSt: { text: "納入日(開始)" },
        dateNonyuEn: { text: "納入日(終了)" },
        codeHinmei: { text: "品名コード" },
        noNonyu: { text: "納入番号" },

        // 明細項目
        dt_denso: { text: "伝送日時" },
        dt_nonyu: { text: "納入日" },
        kbn_denso: { text: "SAP伝送区分" },
        no_nonyu: { text: "納入番号" },
        cd_hinmei: { text: "品名コード" },
        nm_hinmei: { text: "品名" },
        cd_torihiki: { text: "取引先コード" },
        nm_torihiki: { text: "取引先名" },
        su_nonyu: { text: "納入数" },
        cd_tani: { text: "納入単位コード" },
        nm_tani: { text: "納入単位" },
        kbn_nyuko: { text: "入庫区分" },

        // その他、定数定義、固定文言、隠し項目など
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "検索条件のいずれか1つ" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        kbn_denso_width: { number: 80 },
        su_nonyu_width: { number: 110 },
        kin_arari_width: { number: 110 },
        each_lang_width: { number: 100 }
    });

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "伝送日時(開始)",
                datestring: "伝送日時(開始)",
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
                required: "伝送日時(終了)",
                datestring: "伝送日時(終了)",
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
        dt_nonyu_start: {
            rules: {
                required: "納入日(開始)",
                datestring: "納入日(開始)",
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
        dt_nonyu_end: {
            rules: {
                required: "納入日(終了)",
                datestring: "納入日(終了)",
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
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "品名コード"
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012,
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
