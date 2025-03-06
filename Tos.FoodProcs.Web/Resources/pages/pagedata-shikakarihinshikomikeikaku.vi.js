(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Kế hoạch sản xuất bán thành phẩm" },
        // 明細
        flg_print: { text: "In ấn" },
        flg_kakutei: { text: "Duyệt" },
        nm_line: { text: "Dây chuyền" },
        cd_hinmei: { text: "Mã bán thành phẩm" },
        nm_hinmei: { text: "Tên bán thành phẩm" },
        nm_uchiwake: { text: "Phân loại" },
        nm_tani: { text: "Đơn vị<br>sử dụng" },
        wt_hitsuyo: { text: "Lượng cần thiết" },
        wt_shikomi: { text: "Lượng sản xuất" },
        nm_ritsu_bai: { text: "Bội suất" },
        nm_su_batch: { text: "Số lượng mẻ SX" },
        nm_seiki: { text: "Chẵn" },
        nm_hasu: { text: "Lẻ" },
        nm_zan_shikakari: { text: "Lượng tồn BTP<br>hiện tại" },
        nm_gokei_label: { text: "Tổng các nhãn" },
        nm_label: { text: "Nhãn" },
        no_lot_shikakarihin: { text: "Bán thành phẩm<br>Số lô" },
        nm_haigo: { text: "Tên công thức" },
        blank: { text: "" },
        nm_shikakari_oya_sub: { text: "Số lô BTP cha" },
        nm_seihin_sub: { text: "Số lô sản phẩm" },

        // 検索条件
        dt_hiduke_search: { text: "Ngày" },
        nm_shokuba_search: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        nm_line_search: { text: "Dây chuyền" },
        flg_kakutei_search: { text: "Duyệt" },
        flg_mikakutei_search: { text: "Chưa duyệt" },
        rd_shikomi_search: { text: "Nơi sản xuất" },
        rd_shiyo_search: { text: "Nơi sử dụng" },

        // ボタン
        btn_print_select: { text: "Chọn in" },
        btn_label_kobetsu: { text: "In nhãn" },
        btn_label_chomieki: { text: "In nhãn dung dịch gia vị" },
        btn_itiran_line: { text: "Danh sách dây chuyền" },
        btn_insatsu_sentaku: { text: "Chọn in" },
        // その他
        btn_label_message: { text: "Màn hình in nhãn" },

        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        noRowChecked: { text: MS0056 },
        someRowChecked: { text: MS0059 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        labelprintCheck: { text: MS0048 },
        noChomiData: { text: MS0122 },
        checkShikomi: { text: MS0150 },
        zeroShikomi: { text: MS0124 },
        zeroHaigo: { text: MS0704 },
        shikomiUpdateCheck: { text: MS0799 },
        jissekiCheck: { text: MS0801 },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        flg_shikomi_width: { number: 120 },
        uchiwake_width: { number: 70 },
        wt_zan_shikakari_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shikomi_keikaku: {
            rules: {
                required: "Lượng sản xuất theo kế hoạch",
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
        ritsu_keikaku: {
            rules: {
                required: "Bội suất theo kế hoạch",
                number: true,
                range: [0, 99.99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        ritsu_keikaku_hasu: {
            rules: {
                required: "Số bội suất (lẻ) theo kế hoạch",
                number: true,
                range: [0, 99.99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        su_batch_keikaku: {
            rules: {
                required: "Số mẻ sản xuất theo kế hoạch",
                number: true,
                range: [0, 9999]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },
        su_batch_keikaku_hasu: {
            rules: {
                required: "Số mẻ sản xuất (lẻ) theo kế hoạch",
                number: true,
                range: [0, 1]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                range: MS0450
            }
        },

        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "Ngày",
                datestring: true
            },
            messages: {
                required: MS0004,
                datestring: MS0247
            }
        },
        //lineCode: {
        //    rules: {
        //        required: true
        //    },
        //    messages: {
        //        required: MS0004
        //    }
        //}
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        check: {
            Warehouse: { visible: false }
        },
        save: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        //---------------------------------------------------------
        //2019/07/24 trinh.bd Task #14029
        //------------------------START----------------------------
        //insatsu_sentaku: {
        //    Warehouse: { visible: false }
        //},
        //label_kobetsu: {
        //    Warehouse: { visible: false }
        //},
        //------------------------END------------------------------
        label_chomieki: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        zenlabel: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        kobetsulabel: {
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();