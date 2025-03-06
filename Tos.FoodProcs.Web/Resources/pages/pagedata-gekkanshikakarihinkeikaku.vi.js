(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Kế hoạch sản xuất bán thành phẩm theo tháng" },
        // 明細
        dt_hitsuyo: { text: "Ngày cần" },
        dt_hitusyo_yobi: { text: "Thứ" },
        //dt_shikomi: { text: "Produce date" },
        dt_shikomi: { text: "Ngày sản xuất" },
        nm_hinmei: { text: "Tên bán thành phẩm cha" },
        cd_shikakari: { text: "Mã bán thành phẩm" },
        nm_shikakarihin: { text: "Tên bán thành phẩm" },
        kbn_gassan: { text: "Loại<br>tính gộp" },
        tan_shiyo: { text: "Đơn vị<br>sử dụng" },
        wt_hituyo: { text: "Lượng cần thiết" },
        wt_shikomi: { text: "Lượng sản xuất" },
        cd_line: { text: "Mã dây chuyền" },
        nm_line: { text: "Tên dây chuyền" },
        no_lot_seihin: { text: "Lô sản phẩm" },
        no_lot_oya: { text: "Lô bán thành phẩm cha" },
        no_lot_shikakari: { text: "Lô bán thành phẩm" },
        // 検索条件
        dt_hiduke_search: { text: "Ngày" },
        dt_hiduke_start: { text: " Ngày (bắt đầu)" },
        dt_hiduke_end: { text: " Ngày (kết thúc)" },
        nm_shokuba_search: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        cd_hinmei_search: { text: "Mã BTP", tooltip: "Mã bán thành phẩm" },
        nm_hinmei_search: { text: "Tên BTP", tooltip: "Tên bán thành phẩm" },
        rd_lotNashi: { text: "Tất cả" },
        rd_lotSeihin: { text: "Sản phẩm" },
        rd_lotOya: { text: "BTP cha", tooltip: "Bán thành phẩm cha" },
        rd_lotShikakari: { text: "BTP", tooltip: "Bán thành phẩm" },
        no_lot_search: { text: "Lô" },
        // 画面で利用するテキスト
        seihinIchiran: { text: "Danh sách bán thành phẩm" },
        lineIchiran: { text: "Danh sách dây chuyền" },
        namisen: { text: "～" },
        blank: { text: "" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        dateInputConfirm: { text: MS0151 },
        lotDeleteConfirm: { text: MS0565 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        notSeihinLotDelCheck: { text: MS0569 },
        inputDateError: { text: MS0019 },
        shikomiUpdateCheck: { text: MS0799 },
        shikomiDeleteCheck: { text: MS0800 },
        jissekiCheck: { text: MS0801 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hitsuyo_tukihi_width: { number: 100 },
        dt_hitsuyo_yobi_width: { number: 140 },
        dt_seizo_width: { number: 100 },
        nm_haigo_width: { number: 150 },
        cd_hinmei_width: { number: 140 },
        nm_shikakari_width: { number: 140 },
        nm_gassan_kbn_width: { number: 50 },
        nm_tani_width: { number: 50 },
        wt_hitsuyo_width: { number: 100 },
        wt_shikomi_keikaku_width: { number: 110 },
        cd_line_width: { number: 100 },
        nm_line_width: { number: 120 },
        no_lot_shikakari_width: { number: 120 },
        no_lot_shikakari_oya_width: { number: 150 },
        no_lot_seihin_width: { number: 120 },
        each_lang_width: { number: 90 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 明細/コード
        dt_seizo: {
            rules: {
                //required: "Manufacture date",
                required: "Ngày sản xuất",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        cd_hinmei: {
            rules: {
                required: "Mã bán thành phẩm",
                maxbytelength: 14,
                alphanum: true
            },
            //params: {
            //    custom: "Progressing product code"
            //},
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
                //custom: MS0049,
                //custom_no_entry: "There is an imperfection in the master."
            }
        },
        wt_shikomi_keikaku: {
            rules: {
                required: "Lượng sản xuất",
                number: true,
                //range: [0, 999999.999999]
                range: [0, 999999.999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        cd_line: {
            rules: {
                required: "Mã dây chuyền",
                alphanum: true,
                maxbytelength: 14
            },
            params: {
                custom: "Mã dây chuyền"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0042
            }
        },
        isYukoHaigoCode: {
            rules: {
            },
            params: {
                custom: "Mã BTP có hiệu lực"
            },
            messages: {
                custom: MS0049
            }
        },
        // 検索条件
        dt_hiduke_search_from: {
            rules: {
                required: "Ngày bắt đầu",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_hiduke_search_to: {
            rules: {
                required: "Ngày kết thúc",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        no_lot_search: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        cd_hinmei_search: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: false
            },
            params: {
                custom: "Mã bán thành phẩm"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        addButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        deleteButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }

        },
        seihinIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        lineIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_hinmei": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.cd_line": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        "grid:itemGrid.dt_seizo": {
            Editor: { enable: false },
            Viewer: { enable: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();