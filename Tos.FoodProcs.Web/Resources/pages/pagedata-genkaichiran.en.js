(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Cost List" },

        // ヘッダー項目
        dt_seizo: { text: "Years" },
        nm_shokuba: { text: "Workplace" },
        nm_line: { text: "Line" },
        nm_bunrui: { text: "Group" },
        cd_seihin: { text: "Product Code" },
        tanka_settei: { text: "Unit price setup" },
        tanaoroshi_tanka: { text: "Stocktaking unit price" },
        nonyu_tanka: { text: "Delivery unit price" },
        master_tanka: { text: "Unit price un-setting up uses a name-of-article master unit price. " },

        // 明細項目
        nm_seihin: { text: "Product Name" },
        nm_nisugata: { text: "Packing style<br>for display" },
        su_seizo_cs: { text: "Quantities of<br>productions(Delivery unit)" },
        tan_cs: { text: "Delivery unit" },
        kin_kingaku: { text: "Amount of<br>money" },
        kin_genryo: { text: "Raw materials<br>cost" },
        kin_shizai: { text: "Materials<br>expenses" },
        kei_zairyo: { text: "Cost-of-materials<br>meter" },
        kin_roumu: { text: "Labor costs" },
        kin_kei: { text: "Cost" },
        kei_keihi: { text: "Cost meter" },
        kin_genka: { text: "Cost price" },
        kin_arari: { text: "Gross income" },

        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { number: 140 },

        pdfChangeMeisai: { text: MS0048 },
        lineTorokuHinCdError: { text: MS0573 },
        lineTorokuHinKbnError: { text: MS0022 },
        requiredMsg: { text: MS0042 },
        inputValueError: { text: MS0009 },
        navigateError: { text: MS0623 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_seihin_width: { number: 80 },
        nm_seihin_width: { number: 200 },
        nm_nisugata_hyoji_width: { number: 120 },
        su_seizo_width: { number: 120 },
        tan_cs_hyoji_width: { number: 110 },
        kin_kingaku_width: { number: 110 },
        kin_genryo_width: { number: 110 },
        kin_shizai_width: { number: 110 },
        kei_zairyo_width: { number: 120 },
        kin_roumu_width: { number: 110 },
        kin_kei_width: { number: 110 },
        kei_keihi_width: { number: 110 },
        kin_genka_width: { number: 110 },
        kin_arari_width: { number: 110 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Product Code"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_seizo: {
            rules: {
                required: "Years",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear()+3, new Date().getMonth()+1)
            },
            messages: {
                required: MS0042,
                monthstring: MS0247,
                lessmonth: MS0247,
                greatermonth: MS0247
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
