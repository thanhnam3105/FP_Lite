(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Delivery Schedule Transmission List" },

        // ヘッダー、検索条件項目
        to: { text: "　～　" },
        dateDensoSt: { text: "Transmission date(From)" },
        dateDensoEn: { text: "Transmission date(To)" },
        dateNonyuSt: { text: "Delivery date(From)" },
        dateNonyuEn: { text: "Delivery date(To)" },
        codeHinmei: { text: "Item code" },
        noNonyu: { text: "Delivery number" },

        // 明細項目
        dt_denso: { text: "Transmission date" },
        dt_nonyu: { text: "Delivery date" },
        kbn_denso: { text: "SAP Transmission<br>division" },
        no_nonyu: { text: "Delivery number" },
        cd_hinmei: { text: "Item code" },
        nm_hinmei: { text: "Item name" },
        cd_torihiki: { text: "Vendor code" },
        nm_torihiki: { text: "Vendor name" },
        su_nonyu: { text: "Delivery plan" },
        cd_tani: { text: "Delivery<br>unit code" },
        nm_tani: { text: "Delivery<br>unit" },
        kbn_nyuko: { text: "Warehousing<br>division" },

        // その他、定数定義、固定文言、隠し項目など
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "One of the search condition" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        kbn_denso_width: { number: 80 },
        su_nonyu_width: { number: 110 },
        kin_arari_width: { number: 110 },
        each_lang_width: { number: 160 }
    });

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "Transmission date(From)",
                datestring: "Transmission date(From)",
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
                required: "Transmission date(To)",
                datestring: "Transmission date(To)",
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
                required: "Delivery date(From)",
                datestring: "Delivery date(From)",
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
                required: "Delivery date(To)",
                datestring: "Delivery date(To)",
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
                custom: "Item code"
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
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