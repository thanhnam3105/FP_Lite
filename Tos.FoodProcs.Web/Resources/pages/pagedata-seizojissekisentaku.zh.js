(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "生产实际选择" },

        // ヘッダー
        dt_shikomi: { text: "采购日" },
        cd_haigo: { text: "编号" },
        nm_haigo: { text: "半成品名 " },
        //no_lot_shikakari: { text: "批量编号" },
        no_lot_shikakari: { text: "批号" },
        bairitsu: { text: "倍率" },
        //bairitsu_hasu: { text: "倍率(零数)" },
        bairitsu_hasu: { text: "倍率(零头数)" },
        wt_shikomi: { text: "投放量" },
        batch: { text: "Ｂ数" },
        //batch_hasu: { text: "Ｂ数(零数)" },
        batch_hasu: { text: "Ｂ数(零头数)" },

        // 明細
        kbn_anbun: { text: "使用实际<br>按分区分" },
        dt_seizo: { text: "日期" },
        kbn_hin: { text: "商品区分" },
        cd_seihin: { text: "编号" },
        nm_seihin: { text: "品名" },
        //no_lot_seihin: { text: "制造批量" },
        no_lot_seihin: { text: "制造批号" },
        wt_shikakari_shiyo: { text: "半成品使用量" },
        chosei_riyu: { text: "调整理由" },
        genka_busho: { text: "原价发生部门" },
        soko: { text: "仓库" },
        kbn_denso: { text: "使用实际<br>传送区分" },
        meisai_gokei: { text: "明细合计" },
        gokei_sai: { text: "合计差异" },
        kensuErr: { text: MS0773 },
        shomiErr: { text: MS0774 },
        shiyoErr: { text: MS0778 },
        // その他、固定値
        seizoIchiran: { text: "生产查找" },

        // 多言語対応用の列幅
        kbn_anbun_width: { number: 80 },
        dt_seizo_width: { number: 100 },
        kbn_hin_width: { number: 80 },
        cd_seihin_width: { number: 120 },
        nm_seihin_width: { number: 250 },
        no_lot_seihin_width: { number: 120 },
        wt_shikakari_shiyo_width: { number: 110 },
        chosei_riyu_width: { number: 150 },
        genka_busho_width: { number: 150 },
        soko_width: { number: 150 },
        kbn_denso_width: { number: 80 },
        each_lang_width: { number: 100 }
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        dt_shiyo_shikakari: {
            rules: {
                required: "日期",
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
                required: "半成品使用量",
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
    App.ui.pagedata.operation("zh", {
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
