(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tạo kế hoạch sản phẩm theo tháng" },
        // 明細
        dt_seizo: { text: "Ngày" },
        dt_seizo_yobi: { text: "Thứ" },
        cd_riyu: { text: "Mã" },
        nm_riyu: { text: "Lý do ngày nghỉ" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên sản phẩm" },
        nm_nisugata: { text: "Kiểu đóng gói" },
        su_seizo_yotei: { text: "Lượng sản xuất" },
        su_seizo_jisseki: { text: "Lượng sản xuất thực tế" },
        no_lot_seihin: { text: "Số lô sản phẩm" },
        batch: { text: "Số mẻ" },
        bairitsu: { text: "Bội suất" },
        check_reflect: { text: "Đối tượng<br>chuyển sang C/S" },
        txt_memo: { text: "Ghi chú" },
        // 検索条件
        dt_hiduke_search: { text: "Tháng" },
        nm_shokuba_search: { text: "Bộ phận SX", tooltip:"Bộ phận sản xuất" },
        nm_line_search: { text: "Dây chuyền" },   
        // 画面で利用するテキスト
        zenLine: { text: "Kiểm tra toàn bộ dây chuyền" },
        gokei: { text: "Tổng kế hoạch sản xuất" },
        //seihinIchiran: { text: "Product list" },
        yasumiIchiran: { text: "Chọn ngày nghỉ" },
        csReflect: { text: "Đổi sang C/S" },
        blank: { text: "" },
        msg_param: { text: "lượng sản xuất của" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        oldDateInputConfirm: { text: MS0151 },
        jissekiDataConfirm: { text: MS0682 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        shikomiDeleteCheck: { text: MS0800 },
        jissekiCheck: { text: MS0801 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        nm_riyu_width: { number: 120 },
        dt_seizo_width: { number: 50 },
        dt_seizo_yobi_width: { number: 80 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 180 },
        nm_nisugata_hyoji_width: { number: 120 },
        su_seizo_yotei_width: { number: 140 },
        su_seizo_jisseki_width: { number: 150 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_seizo_yotei: {
            rules: {
                required: "Lượng sản xuất",
                number: true
            },
            params: {
                custom: ["Lượng sản xuất", 1, 9999999999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                custom: MS0666
            }
        },
        cd_hinmei: {
            rules: {
                required: "Mã",
            },
            messages: {
                required: MS0042
            }
        },
        //nm_hinmei_en: { //製品名en版用
        //    rules: {
        //        required: "Product name"
        //    },
        //    messages: {
        //        required: MS0122
        //    }
        //},
        wt_ko: { // マスタ整合性チェック用
            rules: {
                required: "Trọng lượng của 1 sản phẩm"
            },
            messages: {
                required: MS0122
            }
        },
        su_batch_keikaku: {
            rules: {
                number: true,
                range: [0, 9999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        },
        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "Tháng",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear() + 3, new Date().getMonth() + 1)
            },
            messages: {
                required: MS0004,
                monthstring: MS0247,
                lessmonth: MS0247,
                greatermonth: MS0247
            }
        },
        lineCode: {
            rules: {
                required: "Tên dây chuyền"
            },
            messages: {
                required: MS0004
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        addButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        deleteButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        seihinIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        yasumiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        zenLine: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_hinmei": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        search: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        total: {
            Editor: { enable: false },
            Viewer: { enable: false },
            Warehouse: { visible: false }
        },
        csReflect: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();