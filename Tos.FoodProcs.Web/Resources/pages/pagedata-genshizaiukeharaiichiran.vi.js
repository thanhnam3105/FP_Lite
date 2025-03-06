(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách nhập, xuất nguyên vật liệu" },

        // 検索条件
        dt_hiduke_search: { text: "Ngày" },
        between: { text: "　~　" },
        flg_mishiyobun: { text: "Bao gồm phần không sử dụng" },
        ari_nomi: { text: "Chỉ hiển thị khi có TKTT/TKThT", tooltip: "Chỉ hiển thị khi có tồn kho tính toán hoặc tồn kho thực tế"},
        hinKubun: { text: "Loại SP", tooltip: "Loại sản phẩm"},
        hinBunrui: { text: "Nhóm SP", tooltip: "Nhóm sản phẩm"},
        hinCode: { text: "Mã NVL", tooltip: "Mã nguyên vật liệu"},
        flg_today_jisseki: { text: "Hiển thị lượng thực tế cho NHT" },
        ukeKubun: { text: "Movement division", tooltip: "Hiển thị lượng thực tế cho ngày hiện tại"},

        // グリッド項目
        cd_genshizai: { text: "Mã nguyên vật liệu" },
        nm_genshizai: { text: "Tên nguyên vật liệu" },
        dt_hiduke: { text: "Ngày" },
        kbn_ukeharai: { text: "Xuất nhập kho" },
        su_nyusyukko: { text: "Số lượng xuất nhập kho" },
        no_lot: { text: "Số lô" },
        cd_seihin: { text: "Mã" },
        nm_seihin: { text: "Tên sản phẩm" },
        nm_memo: { text: "Ghi chú" },
        nm_shokuba: { text: "Workplace" },
        nm_line: { text: "Line" },
        //受払区分
        nonyuYotei: { text: "Dự định nhập hàng" },
        nonyuJisseki: { text: "Thực tế nhập hàng" },
        shiyoYotei: { text: "Dự định sử dụng" },
        shiyoJisseki: { text: "Thực tế sử dụng" },
        chosei: { text: "Số lượng điều chỉnh" },
        seizoYotei: { text: "Dự định sản xuất" },
        seizoJisseki: { text: "Thực tế sản xuất" },

        // その他：文言
        startDate: { text: "Ngày bắt đầu" },
        endDate: { text: "Ngày kết thúc" },
         // 開始日～終了日の最大期間日数
        maxPeriod: { text: "184" },
           
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 110 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 205 }
        // ここまで

    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                required: "Ngày bắt đầu",
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
        dt_hiduke_to: {
            rules: {
                required: "Ngày kết thúc",
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
        kbn_hin: {
            rules: {
                required: "Loại sản phẩm"
            },
            messages: {
                required: MS0042
            }
        },
        cd_genshizai: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
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