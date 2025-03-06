(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách sử dụng nguyên vật liệu và bán thành phẩm" },
        // 検索条件
        kbn_hin: { text: "Loại sản phẩm" },
        bunrui: { text: "Loại" },
        name: { text: "Tên" },
        // グリッド項目
        kubun: { text: "Phân loại" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        cd_shikakari: { text: "Mã bán thành phẩm" },
        nm_shikakari: { text: "Tên bán thành phẩm" },
        wt_haigo: { text: "Formula<br>weight" },
        su_shiyo: { text: "Usage<br>quantity" },
        no_han: { text: "Version" },
        cd_seihin: { text: "Mã sản phẩm" },
        nm_seihin: { text: "Tên sản phẩm" },
        dt_saishu_shikomi_yotei: { text: "Ngày dự định chuẩn bị <br>cuối cùng" },   // エキサイト翻訳：The date of the scheduled last preparation
        dt_saishu_shikomi: { text: "Ngày chuẩn bị cuối cùng" },   // The last preparation day
        dt_saishu_seizo_yotei: { text: "Ngày dự định sản xuất <br>cuối cùng" },
        dt_saishu_seizo: { text: "Ngày sản xuất cuối cùng" },
        mishiyo: { text: "Không <br>sử dụng" },
        shiyo: { text: "Sử dụng" },
        dt_from: { text: "Valid date" },
        // メッセージ
        //noRecords: { text: MS0442 },
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 150 },
        each_lang_width: { number: 90 }
        // ここまで

    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        kbn_hin: {
            rules: {
                required: "Loại sản phẩm"
            },
            messages: {
                required: MS0042
            }
        },
        dt_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(3000, 13 - 1, 31)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("vi", {
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        excel: {
            Warehouse: { visible: false }
        }
        //add: {
        //    Viewer: { visible: false }
        //}
    });

})();