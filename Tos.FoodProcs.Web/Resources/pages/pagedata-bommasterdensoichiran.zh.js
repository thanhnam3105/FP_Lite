(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "BOM主表传送一览" },

        // ヘッダー、検索条件項目
        to: { text: "～　" },
        dateDensoSt: { text: "传送日(开始)" },
        dateDensoEn: { text: "传送日(结束)" },
        codeSeihin: { text: "产品编号" },
        codeHaigo: { text: "配料编号" },
        codeHinmei: { text: "品名编号" },

        // 明細項目
        dt_denso: { text: "传送日期和时间" },
        kbn_denso: { text: "传送区分" },
        cd_seihin: { text: "产品编号" },
        nm_seihin: { text: "产品名" },
        dt_from: { text: "有效日期(开始)" },
        su_kihon: { text: "基本数量" },
        cd_hinmei: { text: "品名编号" },
        nm_hinmei: { text: "品名" },
        su_hinmoku: { text: "品目数量" },
        cd_tani: { text: "数量单位" },
        su_kaiso: { text: "阶层" },
        cd_haigo: { text: "配料编号" },
        nm_haigo: { text: "配料名" },
        no_kotei: { text: "工程编码" },
        no_tonyu: { text: "投入号" },

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

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "传送日(开始)",
                datestring: "传送日(开始)",
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
                required: "传送日(结束)",
                datestring: "传送日(结束)",
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
                custom: "产品编号"
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
                custom: "品名编号"
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
                custom: "配料编号"
            },
            messages: {
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
