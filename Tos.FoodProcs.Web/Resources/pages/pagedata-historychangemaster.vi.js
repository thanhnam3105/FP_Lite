(function () {
    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Danh sách lịch sử thay đổi" },

        // 検索条件
        dt_from: { text: "Ngày bắt đầu" },
        dt_to: { text: "Ngày kết thúc" },
        between: { text: "　～　" },
        DataPartition: { text: "Phân loại dữ liệu" },
        ProcessingDivision: { text: "Phân loại xử lý" },
        dt_update_from: { text: "Ngày bắt đầu cập nhật" },
        dt_update_to: { text: "Ngày kết thúc cập nhật" },
        name: { text: "Người phụ trách" },
        hinCode: { text: "Mã sản phẩm" },

        // グリッド項目
        kbn_data: { text: "Phân loại dữ liệu" },
        kbn_shori: { text: "Phân loại xử lý" },
        dt_hizuke: { text: "Ngày" },
        cd_hinmei: { text: "Mã sản phẩm" },
        nm_seihin: { text: "Tên sản phẩm" },
        su_henko: { text: "Số lượng sau khi thay đổi" },
        su_henko_hasu: { text: "Số lượng sau khi thay đổi (lẻ)" },
        tr_lot: { text: "Lô" },
        dt_henko: { text: "Ngày cập nhật" },
        cd_henko: { text: "Mã người phụ trách" },
        nm_henko: { text: "Tên người phụ trách" },
        biko: { text: "Ghi chú" },       

        nm_riyu: { text: "Lý do điều chỉnh" },
        genka_busho: { text: "Bộ phận phát sinh chi phí" },

        // その他：文言
        startDate: { text: "Ngày bắt đầu" },
        endDate: { text: "Ngày kết thúc" },

        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "62" },

        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 70 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 195 }
        // ここまで

    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)

            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_hiduke_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        cd_nm_tanto: {
            rules: {
                maxbytelength: 50
            },
            params: {
                custom: "Người phụ trách"
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("vi", {
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
