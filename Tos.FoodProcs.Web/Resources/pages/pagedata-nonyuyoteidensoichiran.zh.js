(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "入库预定传送一览" },

        // ヘッダー、検索条件項目
        to: { text: "　～　" },
        dateDensoSt: { text: "传送日(开始)" },
        dateDensoEn: { text: "传送日(结束)" },
        dateNonyuSt: { text: "入库日期(开始)" },
        dateNonyuEn: { text: "入库日期(结束)" },
        codeHinmei: { text: "品名编号" },
        noNonyu: { text: "入库号码" },

        // 明細項目
        dt_denso: { text: "传送日期" },
        dt_nonyu: { text: "入库日期" },
        kbn_denso: { text: "SAP传送区分" },
        no_nonyu: { text: "入库号码" },
        cd_hinmei: { text: "品名编号" },
        nm_hinmei: { text: "品名" },
        cd_torihiki: { text: "厂商编号" },
        nm_torihiki: { text: "厂商名" },
        su_nonyu: { text: "入库数量" },
        cd_tani: { text: "入库单位编号" },
        nm_tani: { text: "入库单位" },
        kbn_nyuko: { text: "入库区分" },

        // その他、定数定義、固定文言、隠し項目など
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "查找条件中任意一个" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        kbn_denso_width: { number: 80 },
        su_nonyu_width: { number: 110 },
        kin_arari_width: { number: 110 },
        each_lang_width: { number: 100 }
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "传送日期(开始)",
                datestring: "传送日期(开始)",
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
                required: "传送日期(结束)",
                datestring: "传送日期(结束)",
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
                required: "入库日期(开始)",
                datestring: "入库日期(开始)",
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
                required: "入库日期(结束)",
                datestring: "入库日期(结束)",
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
                custom: "品名编号"
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
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
