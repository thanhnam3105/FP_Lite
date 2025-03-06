
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Báo cáo sản xuất bán thành phẩm hằng ngày" },

        // 【最小値】 日付
        minDate: { text: "2000/01/01" },
        // 【最大値】 日付
        maxDate: { text: "3000/12/31" },
        // 【値】 1日
        oneDay: { text: 86400000 },
        timeNewFormat: { text: "H:i" },
        dt_diff: { text: 31 },
        month_diff: { text: 6 },

        shokuba: { text: "Bộ phận SX" },
        line: { text: "Dây chuyền" },
        flg_jisseki: { text: "Duyệt" },
        cd_shikakari_hin: { text: "Mã" },
        nm_haigo: { text: "Tên bán thành phẩm" },
        cd_line: { text: "Mã dây chuyền" },
        nm_line: { text: "Tên dây chuyền" },
        nm_tani: { text: "Đơn vị <br>sử dụng" },
        wt_shikomi_keikaku: { text: "Lượng SX (kế hoạch)" },
        wt_shikomi_jisseki: { text: "Lượng SX" },       
        ritsu_jisseki: { text: "Bội suất" },
        ritsu_jisseki_hasu: { text: "Bội suất (lẻ)" },
        su_batch_jisseki: { text: "Số mẻ SX" },
        su_batch_jisseki_hasu: { text: "Số mẻ SX (lẻ)" },
        wt_zaiko_jisseki: { text: "Lượng sử dụng còn lại" },
        wt_shikomi_zan: { text: "Lượng tồn ngày hiện tại" },
        no_lot_shikakari: { text: "Số lô" },
        dt_seizo: { text: "Ngày sản xuất" },
        dt_seizo_start: { text: "Ngày sản xuất (từ)" },
        dt_seizo_end: { text: "Ngày sản xuất (đến)" },
        between: { text: "～" },
        wt_haigo_gokei: { text: "Tổng trọng lượng công thức" },
        wt_hitsuyo: { text: "Lượng cần thiết" },
        cd_shokuba: { text: "" },
        shikomi: { text: "Lượng sản xuất" },
        seizoJissekiSentaku: { text: "Phân bổ thực tế SX" },
        densoJotai: { text: "Trạng thái gửi" },
        flg_toroku: { text: "Đăng ký" },
        kbn_toroku_jotai: { text: "Trạng thái đăng ký" },
        msg_kakuteiData: { text: "dữ liệu đã duyệt" },
        denso_jokyo: { text: "Trạng thái gửi" },
        mi_sakusei: { text: "Chưa tạo" },
        mi_denso: { text: "Chưa gửi" },
        denso_machi: { text: "Chờ gửi" },
        denso_zumi: { text: "Đã gửi" },
        toroku_jokyo: { text: "Trạng thái đăng ký" },
        mi_toroku: { text: "Chưa đăng ký" },
        ichibu_mi_toroku: { text: "Đang chờ" },
        toroku_sumi: { text: "Đã đăng ký" },
        lotToroku: { text: "Chi tiết lô NL" },
        lotTorokuZenbu: { text: "Chọn/Bỏ chọn đăng ký" },

        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },

        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        deleteConfirm: { text: MS0752 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 60 },        
        densoJotai_width: { number: 170 },
        wt_shikomi_keikaku_width: { number: 120 },
        flg_toroku_width: { number: 60 },
        nm_toroku_jotai: { number: 120 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        dateDiffError: { text: MS0686 }        
    });

    App.ui.pagedata.validation("vi", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件/製造日（開始）
        con_dt_seizo_from: {
            rules: {
                required: "Ngày sản xuất (từ)",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 検索条件/製造日（終了）
        con_dt_seizo_to: {
            rules: {
                required: "Ngày sản xuất (đến)",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 仕掛品
        cd_shikakari_hin: {
            rules: {
                required: "Mã",
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        // ラインコード
        cd_line: {
            rules: {
                required: "Mã dây chuyền",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        // 倍率
        ritsu_jisseki: {
            rules: {
                required: "Bội suất",
                //pointlength: [6, 6, false],
                pointlength: [6, 2, false],
                //range: [0, 999999.999999],
                range: [0, 999999.99],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Lượng sản xuất", 0, 999999.999]
            },
            messages: {
                required: MS0042,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        },
        // 倍率（端数)
        ritsu_jisseki_hasu: {
            rules: {
                //pointlength: [6, 6, false],
                pointlength: [6, 2, false],
                //range: [0, 999999.999999],
                range: [0, 999999.99],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Lượng sản xuất", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        },
        // Ｂ数
        su_batch_jisseki: {
            rules: {
                required: "Số mẻ SX",
                //pointlength: [6, 6, false],
                digits: [6],
                //range: [0, 999999.999999],
                range: [0, 999999],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Lượng sản xuất", 0, 999999.999]
            },
            messages: {
                required: MS0042,
                //pointlength: MS0440,
                digits:MS0576,
                range: MS0450,
                custom: MS0666
            }
        },
        // Ｂ数(端数)
        su_batch_jisseki_hasu: {
            rules: {
                //pointlength: [6, 6, false],
                digits: [6],
                //range: [0, 999999.999999],
                range: [0, 999999],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Lượng sản xuất", 0, 999999.999]
            },
            messages: {
                //pointlength: MS0440,
                digits: MS0576,
                range: MS0450,
                custom: MS0666
            }
        },
        // 残使用量
        wt_zaiko_jisseki: {
            rules: {
                /*　画面上に残使用量の項目が無いため、コメントアウト
                //pointlength: [6, 6, false],
                pointlength: [6, 3, false],
                //range: [0, 999999.999999],
                range: [0, 999999.999],
                custom: true
                */
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Lượng sản xuất", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        check: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        hinmei: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        line: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        lotTorokuZenbu: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });
    //// ページデータ -- End
})();