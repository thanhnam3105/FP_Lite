(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "原价一览" },

        // ヘッダー項目
        dt_seizo: { text: "年月" },
        nm_shokuba: { text: "车间" },
        nm_line: { text: "生产线" },
        nm_bunrui: { text: "分类" },
        cd_seihin: { text: "产品编号" },
        tanka_settei: { text: "单价设定" },
        tanaoroshi_tanka: { text: "库存单价" },
        nonyu_tanka: { text: "入库单价" },
        master_tanka: { text: "单价未设定时,使用品名主表单价" },

        // 明細項目
        nm_seihin: { text: "产品名" },
        nm_nisugata: { text: "包装" },
        su_seizo_cs: { text: "生产数（C/S）" },
        tan_cs: { text: "C/S单价" },
        kin_kingaku: { text: "金额" },
        kin_genryo: { text: "原料费" },
        kin_shizai: { text: "材料费" },
        kei_zairyo: { text: "材料费合计" },
        kin_roumu: { text: "劳务费" },
        kin_kei: { text: "经费" },
        kei_keihi: { text: "经费合计" },
        kin_genka: { text: "原价" },
        kin_arari: { text: "毛利" },

        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { text: "8em" },

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
        su_seizo_width: { number: 110 },
        tan_cs_hyoji_width: { number: 110 },
        kin_kingaku_width: { number: 110 },
        kin_genryo_width: { number: 110 },
        kin_shizai_width: { number: 110 },
        kei_zairyo_width: { number: 110 },
        kin_roumu_width: { number: 110 },
        kin_kei_width: { number: 110 },
        kei_keihi_width: { number: 110 },
        kin_genka_width: { number: 110 },
        kin_arari_width: { number: 110 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "产品编号"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_seizo: {
            rules: {
                required: "年月",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear() + 3, new Date().getMonth() + 1)
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
