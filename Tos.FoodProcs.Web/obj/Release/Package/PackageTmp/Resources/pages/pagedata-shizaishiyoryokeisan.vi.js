(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tính toán lượng sử dụng vật liệu" },
        // 明細
        nm_bunrui: { text: "Loại" },
        cd_hinmei: { text: "Mã vật liệu" },
        nm_hinmei: { text: "Tên vật liệu" },
        nm_tani: { text: "Đơn vị <br>sử dụng" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        su_shiyo_sum: { text: "Lượng dự định sử dụng" },
        wt_shiyo_zan: { text: "Lượng tồn hôm trước" },
        qty_hitsuyo: { text: "Lượng cần thiết <br>(Đơn vị sử dụng)" },
        qty_hitsuyoNonyu: { text: "Lượng cần thiết <br>(Đơn vị nhập)" },
        qty_hitsuyoNonyuHasu: { text: "Lượng cần thiết (lẻ) <br>(Đơn vị nhập)" },
        nm_torihiki_ryaku: { text: "Maker name" },
        zan_hiduke: { text: "Ngày tồn" },
        dt_hiduke: { text: "Ngày đăng ký" },
        // 検索条件
        dt_hiduke_search: { text: "Ngày" },
        searchConfirm: { text: MS0065 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0038 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: {text: MS0560}
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                required: "Lượng tồn hôm trước",
                range: [0, 999999.999],
                number: true
            },
            messages: {
                required: MS0042,
                range: MS0450,
                number: MS0441
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
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();