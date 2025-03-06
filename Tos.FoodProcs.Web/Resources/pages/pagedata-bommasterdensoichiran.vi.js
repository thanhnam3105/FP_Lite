(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "BOMマスタ伝送一覧" },

        // ヘッダー、検索条件項目
        to: { text: "～　" },
        dateDensoSt: { text: "Transmission date(from)" },
        dateDensoEn: { text: "Transmission date(to)" },
        codeSeihin: { text: "Product code" },
        codeHaigo: { text: "Formula code" },
        codeHinmei: { text: "Item code" },

        // 明細項目
        dt_denso: { text: "Transmission date" },
        kbn_denso: { text: "SAP transmission type" },
        cd_seihin: { text: "Product code" },
        nm_seihin: { text: "Product name" },
        dt_from: { text: "Valid start date" },
        su_kihon: { text: "Base quantity" },
        cd_hinmei: { text: "Item code" },
        nm_hinmei: { text: "Item name" },
        su_hinmoku: { text: "Item quantity" },
        cd_tani: { text: "Unit" },
        su_kaiso: { text: "Hierarchy" },
        cd_haigo: { text: "Formula code" },
        nm_haigo: { text: "Formula name" },
        no_kotei: { text: "Process" },
        //no_tonyu: { text: "Putting order" },
        //no_tonyu: { text: "Order" },
        no_tonyu: { text: "Recipe order" },

        // その他、定数定義、固定文言、隠し項目など
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        overSearchNumber: { text: MS0568 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        kbn_denso_width: { number: 165 },
        su_hinmoku_width: { number: 120 },
        no_kotei_width: { number: 75 },
        su_kihon_width: { number: 120 },
        su_kaiso_width: { number: 85 },
        dt_from_width: { number: 120 },
        lang_item_denso: { number: 160 },
        lang_denso_tbl: { number: 670 },
        each_lang_width: { number: 100 }
    });

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "Transmission date(from)",
                datestring: "Transmission date(from)",
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
                required: "Transmission date(to)",
                datestring: "Transmission date(to)",
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
                custom: "Product code"
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
                custom: "Item code"
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
                custom: "Formula code"
            },
            messages: {
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
