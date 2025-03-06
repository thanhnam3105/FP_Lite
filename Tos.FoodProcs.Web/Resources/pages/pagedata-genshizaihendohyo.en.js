(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Material Inventory Table" },
        dt_keikaku_nonyu: { text: "Last date of delivery plan automatically make" },
        // 明細
        cd_hinmei: { text: "Item code" },
        dt_hizuke: { text: "Date/Month" },
        dt_yobi: { text: "Day" },
        flg_kyujitsu: { text: "Holiday" },
        flg_shukujitsu: { text: "Holiday" },
        su_nonyu_yotei: { text: "Delivery plan" },
        su_nonyu_jisseki: { text: "Actual delivery" },
        su_shiyo_yotei: { text: "Usage plan" },
        su_shiyo_jisseki: { text: "Actual usage" },
        su_seizo_yotei: { text: "Manufacture plan" },
        su_seizo_jisseki: { text: "Actual Manufacture" },
        su_chosei: { text: "Adjustment" },
        su_keisanzaiko: { text: "Calculate inventory" },
        su_jitsuzaiko: { text: "Actual inventory" },
        su_kurikoshi_zan: { text: "Carrying inventory" },
        ts: { text: "Time stamp" },
        cd_toroku: { text: "Registrant" },
        dt_toroku: { text: "Registration date" },
        su_ko: { text: "Quantities of one product(kg)" },
        su_iri: { text: "Contained number" },
        cd_tani: { text: "Unit code"},
        // 検索条件
        hizuke: { text: "Date" },
        hinCode: { text: "Item code" },
        hinName: { text: "Item name" },
        nisugata: { text: "Packing style" },
        hacchuLotSize: { text: "Order lot size" },
        nonyuLeadTime: { text: "Delivery lead time" },
        saiteiZaiko: { text: "Minimum inventory" },
        biko: { text: "Notes" },
        shiyoTani: { text: "Usage unit" },
        konyusakiCode: { text: "Vendor code" },
        konyusakiName: { text: "Vendor name" },
        // その他画面項目
        kurikoshiZaiko: { text: "Carrying inventory" },
        kurikoshiZan: { text: "Carrying inventory" },
        nonyuYoteiGokei: { text: "Total of delivery plan" },
        nonyuJissekiGokei: { text: "Total of actual delivery" },
        seizoYoteiGokei: { text: "Total of manufacture plan" },
        seizoJissekiGokei: { text: "Total of actual manufacture" },
        shiyoYoteiGokei: { text: "Total of usage plan" },
        shiyoJissekiGokei: { text: "Total of usage result" },
        choseiGokei: { text: "Total number of adjustment" },
        shiyoIchiran: { text: "Usage list" },
        between: { text: "　～　" },
        total: { text: "Total" },
        // その他：文言
        startDate: { text: "Start date" },
        endDate: { text: "End date" },
        choseiData: { text: "Adjustment data" },
        zaikoData: { text: "inventory data" },
        initChoseiKey: { text: "Reason、Cost department、Warehouse" },
        initZaikoKey: { text: "Warehouse" },
        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "186" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        initErr: { text: MS0736 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 90 },
        dt_yobi_width: { number: 90 },
        su_nonyu_yotei_width: { number: 125 },
        su_nonyu_jisseki_width: { number: 125 },
        su_shiyo_yotei_width: { number: 125 },
        su_shiyo_jisseki_width: { number: 125 },
        su_chosei_width: { number: 130 },
        su_keisanzaiko_width: { number: 130 },
        su_jitsuzaiko_width: { number: 130 },
        total_width: { number: 130 }
        // TODO: ここまで
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_nonyu_yotei: {
            rules: {
                number: MS0441,
//                pointlength: [6, 2, true],
//                range: [0, 999999.99]
                pointlength: [6, 3, true],
                range: [0, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_chosei: {
            rules: {
                number: MS0441,
//                pointlength: [6, 6, true],
//                range: [-999999.999999, 999999.999999]
                pointlength: [6, 3, true],
                range: [-999999.999, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_jitsuzaiko: {
            rules: {
                number: MS0441,
//                pointlength: [8, 6, true],
//                range: [0, 99999999.999999]
                pointlength: [8, 3, true],
                range: [0, 99999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        // 検索条件
        hizuke: {
            rules: {
                required: "Opening day",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hizuke_to: {
            rules: {
                required: "End date",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinCode: {
            rules: {
                required: "Item code",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Item code"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
