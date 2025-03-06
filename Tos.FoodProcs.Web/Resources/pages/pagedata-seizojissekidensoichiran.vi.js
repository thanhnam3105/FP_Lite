(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Manufacture Planning Transmission List" },

        // ヘッダー項目
        to: { text: "～" },
        dateDensoSt: { text: "Transmission date(from)" },
        dateDensoEn: { text: "Transmission date(to)" },
        dateSeizoSt: { text: "Manufacture date(from)" },
        dateSeizoEn: { text: "Manufacture date(to)" },
        codeHinmei: { text: "Product code" },
        SeihinLot: { text: "Product lot No" },
        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },
        // 明細項目
        dt_denso: { text: "Transmission date" },
        kbn_denso_SAP: { text: "SAP transmission type" },
        dt_seizo: { text: "Manufacture date" },
        cd_hinmei: { text: "Product code" },
        nm_hinmei: { text: "Product name" },
        no_lot_seihin: { text: "Product lot No" },
        su_seizo_keikaku: { text: "Product plan quantity" },
        cd_tani: { text: "Unit code" },
        nm_tani: { text: "Unit name" },
        no_lot_hyoji: { text: "External Lot No." },
        // 明細幅
        dt_denso_width: { number: 140 },
        kbn_denso_sap_width: { number: 150 },
        dt_seizo_width: { number: 120 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 160 },
        no_lot_seihin_width: { number: 140 },
        su_seizo_keikaku_width: { number: 150 },
        cd_tani_width: { number: 100 },
        nm_tani_width: { number: 100 },
        // 伝送区分名
        kbn_add: { text: "add" },
        kbn_upd: { text: "update" },
        kbn_del: { text: "delete" },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "One of the search condition" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },


        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { text: "8em" }

        // TODO: 画面の仕様に応じて以下の列幅を変更してください。

        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "Transmission date(from)",
                datestring: "Transmission date(from)",
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
                required: "Transmission date(to)",
                datestring: "Transmission date(to)",
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
                required: "Manufacture date(from)",
                datestring: "Manufacture date(from)",
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
                required: "Manufacture date(to)",
                datestring: "Manufacture date(to)",
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
                custom: "Product code"
            },
            messages: {
                alphanum: MS0439,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
