(function () {
    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Danh sách nguyên giá" },

        // ヘッダー項目
        dt_seizo: { text: "Tháng năm" },
        nm_shokuba: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        nm_line: { text: "Dây chuyền" },
        nm_bunrui: { text: "Phân loại" },
        cd_seihin: { text: "Mã sản phẩm" },
        tanka_settei: { text: "Thiết lập đơn giá" },
        tanaoroshi_tanka: { text: "Đơn giá kiểm kho" },
        nonyu_tanka: { text: "Đơn giá nhập hàng" },
        master_tanka: { text: "Trường hợp chưa thiết lập đơn giá thì sử dụng đơn giá trong master sản phẩm" },

        // 明細項目
        nm_seihin: { text: "Tên sản phẩm" },
        nm_nisugata: { text: "Quy cách đóng gói" },
        su_seizo_cs: { text: "Số lượng sản xuất (C/S)" },
        tan_cs: { text: "Đơn giá C/S" },
        kin_kingaku: { text: "Số tiền" },
        kin_genryo: { text: "Chi phí nguyên liệu" },
        kin_shizai: { text: "Chi phí vật liệu" },
        kei_zairyo: { text: "Tổng chi phí nguyên vật liệu" },
        kin_roumu: { text: "Chi phí lao động" },
        kin_kei: { text: "Chi phí" },
        kei_keihi: { text: "Tổng chi phí" },
        kin_genka: { text: "Giá gốc" },
        kin_arari: { text: "Lợi nhuận" },

        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { number: 140 },

        pdfChangeMeisai: { text: MS0048 },
        lineTorokuHinCdError: { text: MS0573 },
        lineTorokuHinKbnError: { text: MS0022 },
        requiredMsg: { text: MS0042 },
        inputValueError: { text: MS0009 },
        navigateError: { text: MS0623 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_seihin_width: { number: 85 },
        nm_seihin_width: { number: 200 },
        nm_nisugata_hyoji_width: { number: 120 },
        su_seizo_width: { number: 150 },
        tan_cs_hyoji_width: { number: 110 },
        kin_kingaku_width: { number: 110 },
        kin_genryo_width: { number: 120 },
        kin_shizai_width: { number: 110 },
        kei_zairyo_width: { number: 170 },
        kin_roumu_width: { number: 110 },
        kin_kei_width: { number: 110 },
        kei_keihi_width: { number: 110 },
        kin_genka_width: { number: 110 },
        kin_arari_width: { number: 110 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        cd_seihin: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_seizo: {
            rules: {
                required: "Tháng năm",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear()+3, new Date().getMonth()+1)
            },
            messages: {
                required: MS0042,
                monthstring: MS0247,
                lessmonth: MS0247,
                greatermonth: MS0247
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("vi", {
        search: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();