(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách sử dụng bán thành phẩm" },
        //dt_shikomi_search: { text: "Produce date" },
        dt_shikomi_search: { text: "Ngày sản xuất"},
        shikakariCode: { text: "Mã" },
        shikakariName: { text: "Tên" },
        shikakariSearch: { text: "Chọn bán thành phẩm" },
        //明細項目
        //flg_keikaku: { text: "Determinatiion" },
        flg_keikaku: { text: "Duyệt" },
        //dt_shikomi: { text: "Produce date" },
        dt_shikomi: { text: "Ngày sản xuất" },
        //nm_shokuba_shikomi: { text: "Produce workplace" },
        nm_shokuba_shikomi: { text: "Bộ phận SX" },
        //nm_line_shikomi: { text: "Produce line" },
        nm_line_shikomi: { text: "Dây chuyền sản xuất" },
        //wt_shikomi_keikaku: { text: "Produce quantity" },
        wt_shikomi_keikaku: { text: "Lượng sản xuất" },		
        no_lot_shikakari: { text: "Số lô" },
        flg_label: { text: "In nhãn<br>(chẵn)" },
        flg_label_hasu: { text: "In nhãn<br>(lẻ)" },
        dt_seihin_seizo: { text: "Ngày sản xuất<br>sản phẩm" },
        nm_shokuba_seizo: { text: "Bộ phận SX sản phẩm" },
        nm_line_seizo: { text: "Dây chuyền sản xuất<br>sản phẩm" },
        cd_hinmei: { text: "Mã sản phẩm" },
        nm_hinmei: { text: "Tên sản phẩm" },
        su_seizo_yotei: { text: "Lượng sản xuất<br>sản phẩm" },
        no_lot_seihin: { text: "Số lô sản phẩm" },
        cd_shikakari_hin: { text: "Mã BTP cha" },
        nm_haigo: { text: "Tên BTP cha" },
        //wt_shikomi_oya: { text: "Parent semi-finished item produce amount" },
        wt_shikomi_oya: { text: "Lượng sản xuất BTP cha" },
        no_lot_shikakari_oya: { text: "Lô BTP cha" },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_shikomi_search: {
            rules: {
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

        shikakariCode: {
            rules: {
                required: "Mã",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "Mã"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。

        // TODO: ここまで
    });

    //// ページデータ -- End
})();