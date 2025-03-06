(function () {
    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Hiệu suất sản xuất" },

        // ヘッダー
        //dt_shikomi: { text: "Formula date" },
        dt_shikomi: { text: "Ngày sản xuất" },
        cd_haigo: { text: "Mã công thức" },
        nm_haigo: { text: "Tên công thức" },
        no_lot_shikakari: { text: "Lô" },
        bairitsu: { text: "Bội suất" },
        bairitsu_hasu: { text: "Bội suất (lẻ)" },
        wt_shikomi: { text: "Lượng sản xuất" },
        batch: { text: "Số mẻ SX" },
        batch_hasu: { text: "Số mẻ SX (lẻ)" },

        // 明細
        kbn_anbun: { text: "Mục đích" },
        dt_seizo: { text: "Ngày" },
        kbn_hin: { text: "Loại sản phẩm" },
        cd_seihin: { text: "Mã" },
        nm_seihin: { text: "Tên" },
        no_lot_seihin: { text: "Lô sản phẩm" },
        wt_shikakari_shiyo: { text: "Số lượng sử dụng" },
        chosei_riyu: { text: "Lý do <br>điều chỉnh" },
        genka_busho: { text: "Bộ phận phát sinh <br>chi phí" },
        soko: { text: "Kho" },
        kbn_denso: { text: "Trạng thái phân bổ" },
        meisai_gokei: { text: "Tổng chi tiết" },
        gokei_sai: { text: "Tổng sai số" },
        kensuErr: { text: MS0773 },
        shomiErr: { text: MS0774 },
        shiyoErr: { text: MS0778 },
        // その他、固定値
        seizoIchiran: { text: "Tìm kiếm sản xuất" },

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

    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        dt_shiyo_shikakari: {
            rules: {
                required: "Ngày",
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
                required: "Số lượng sử dụng",
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
    App.ui.pagedata.operation("vi", {
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
