(function () {
    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "原価一覧" },

        // ヘッダー項目
        dt_seizo: { text: "年月" },
        nm_shokuba: { text: "職場" },
        nm_line: { text: "ライン" },
        nm_bunrui: { text: "分類" },
        cd_seihin: { text: "製品コード" },
        tanka_settei: { text: "単価設定" },
        tanaoroshi_tanka: { text: "棚卸単価" },
        nonyu_tanka: { text: "納入単価" },
        master_tanka: { text: "単価未設定は品名マスタ単価を使用" },

        // 明細項目
        nm_seihin: { text: "製品名" },
        nm_nisugata: { text: "荷姿" },
        su_seizo_cs: { text: "製造数（C/S）" },
        tan_cs: { text: "C/S単価" },
        kin_kingaku: { text: "金額" },
        kin_genryo: { text: "原料費" },
        kin_shizai: { text: "資材費" },
        kei_zairyo: { text: "材料費計" },
        kin_roumu: { text: "労務費" },
        kin_kei: { text: "経費" },
        kei_keihi: { text: "経費計" },
        kin_genka: { text: "原価" },
        kin_arari: { text: "粗利" },

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

    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "製品コード"
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
