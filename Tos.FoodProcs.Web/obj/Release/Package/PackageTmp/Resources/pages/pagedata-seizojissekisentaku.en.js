(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Manufacturing Performance" },

        // ヘッダー
        //dt_shikomi: { text: "Formula date" },
        dt_shikomi: { text: "Production date" },
        cd_haigo: { text: "Code" },
        nm_haigo: { text: "Formula" },
        no_lot_shikakari: { text: "Lot No." },
        bairitsu: { text: "Magnification" },
        bairitsu_hasu: { text: "Magnification(fraction)" },
        wt_shikomi: { text: "Produce quantity" },
        batch: { text: "Batch quantity" },
        batch_hasu: { text: "Batch quantity(fraction)" },

        // 明細
        kbn_anbun: { text: "Purpose" },
        dt_seizo: { text: "Date" },
        kbn_hin: { text: "Item type" },
        cd_seihin: { text: "Code" },
        nm_seihin: { text: "Name" },
        no_lot_seihin: { text: "Product lot No." },
        wt_shikakari_shiyo: { text: "Usage quantity" },
        chosei_riyu: { text: "Reason of<br>adjustment" },
        genka_busho: { text: "Cost center" },
        soko: { text: "Warehouse" },
        kbn_denso: { text: "Status of allocated data" },
        meisai_gokei: { text: "Details total" },
        gokei_sai: { text: "Total variance" },
        kensuErr: { text: MS0773 },
        shomiErr: { text: MS0774 },
        shiyoErr: { text: MS0778 },
        // その他、固定値
        seizoIchiran: { text: "Manufacturing Search" },

        // 多言語対応用の列幅
        kbn_anbun_width: { number: 120 },
        dt_seizo_width: { number: 100 },
        kbn_hin_width: { number: 90 },
        cd_seihin_width: { number: 120 },
        nm_seihin_width: { number: 250 },
        no_lot_seihin_width: { number: 120 },
        wt_shikakari_shiyo_width: { number: 120 },
        chosei_riyu_width: { number: 150 },
        genka_busho_width: { number: 150 },
        soko_width: { number: 150 },
        kbn_denso_width: { number: 170 },
        each_lang_width: { number: 170 }
    });

    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        dt_shiyo_shikakari: {
            rules: {
                required: "Date",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1)
                //greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247
                //greaterdate: MS0247
            }
        },
        su_shiyo_shikakari: {
            rules: {
                required: "Work in process usage",
                number: true,
                range: [0.001, 999999.999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // 権限による画面制御ルール
        colchange: {
            Quality: { visible: false },
            Warehouse: { visible: false },
            Viewer: { visible: false }
        },
        add: {
            Quality: { visible: false },
            Warehouse: { visible: false },
            Viewer: { visible: false }
        },
        del: {
            Quality: { visible: false },
            Warehouse: { visible: false },
            Viewer: { visible: false }
        },
        seizoDlg: {
            Quality: { visible: false },
            Warehouse: { visible: false },
            Viewer: { visible: false }
        },
        save: {
            Quality: { visible: false },
            Warehouse: { visible: false },
            Viewer: { visible: false }
        }
    });
})();
