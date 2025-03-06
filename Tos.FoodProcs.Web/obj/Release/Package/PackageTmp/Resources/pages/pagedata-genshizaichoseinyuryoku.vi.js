(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Điều chỉnh nguyên vật liệu" },
        // 検索条件
        dt_chosei_hassei: { text: "Ngày phát sinh ĐC", tooltip: "Ngày phát sinh điều chỉnh"},
        // 明細
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên nguyên vật liệu" },
        nm_kbn_hin: { text: "Loại<br>sản phẩm" },
        nm_nisugata: { text: "Quy cách<br>đóng gói" },
        tani_shiyo: { text: "Đơn vị<br>sử dụng" },
        su_chosei: { text: "Lượng<br>điều chỉnh" },
        nm_riyu: { text: "Lý do điều chỉnh" },
        biko: { text: "Ghi chú" },
        cd_seihin: { text: "Mã sản phẩm" },
        nm_seihin: { text: "Tên sản phẩm" },
        cd_update: { text: "Mã người cập nhật" },
        nm_update: { text: "Người cập nhật" },
        dt_update: { text: "Ngày cập nhật" },
        genka_busho: { text: "Cost generation<br>department" },
        cd_soko: { text: "Warehouse" },
        no_lot_seihin: { text: "Lot No." },
        excelIkatsu: { text: "EXCEL(Period Select)" },
        // 隠し項目
        no_seq: { text: "Số thứ tự" },
        kbn_hin: { text: "Loại sản phẩm" },
        cd_riyu: { text: "Mã lý do" },
        flg_mishiyo: { text: "Cờ báo ngừng sử dụng (sản phẩm)" },
        anbun_no_seq: { text: "Use result and plan and proportional division SEQ No" },
        // 品名セレクタ呼び出し用
        //hinmeiDlgParam_seihin: { text: "4" },
        //hinmeiDlgParam_genshizai: { text: "6" },
        //hinmeiDlgParam_genryo: { text: "7" },
        //hinmeiDlgParam_shizai: { text: "8" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        excelChangeMeisai: { text: MS0560 },
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        changeCondition: { text: MS0299 },
        limitOver: { text: MS0011 },
        notExistsData: { text: MS0037 },
        rangeOver: { text: MS0778 },
        noInputHinmeiCode: { text: MS0042 },
        noDisplayDialog: { text: MS0831 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 170 },
        nm_kbn_hin_width: { number: 60 },
        nm_nisugata_width: { number: 80 },
        tani_shiyo_width: { number: 80 },
        su_chosei_width: { number: 100 },
        nm_riyu_width: { number: 120 },
        biko_width: { number: 150 },
        nm_genka_width: { number: 150 },
        nm_soko_width: { number: 150 },
        cd_seihin_width: { number: 100 },
        nm_seihin_width: { number: 150 },
        nm_update_width: { number: 100 },
        dt_update_width: { number: 90 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "Mã",
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0160
            }
        },
        su_chosei: {
            rules: {
                required: "Lượng điều chỉnh",
                //      number: true,
                range: [-999999.999999, 999999.999999]
            },
            messages: {
                required: MS0042,
                //      number: MS0441,
                range: MS0009
            }
        },
        nm_riyu: {
            rules: {
                required: "Lý do điều chỉnh"
            },
            messages: {
                required: MS0042
            }
        },
        biko: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0160
            }
        },
        // 検索条件
        dt_chosei_hassei: {
            rules: {
                required: "Ngày phát sinh điều chỉnh",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        no_lot_seihin: {
            rules: {
            },
            messages: {
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        excel: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        save: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        add: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        del: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        hinmeiIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        seihinIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        shikakariZanIchiran: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();