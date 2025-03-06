    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        _pageTitle: { text: "Gửi dữ liệu thực tế (tới SAP)" },
        // 作成条件
        dt_from: { text: "Từ:" },
        dt_to: { text: "Đến:" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "Chỉ định phạm vi ngày gửi (tới SAP)" },

        // 画面メッセージ
        dateCheck: { text: MS0019 },
        noTargetData: { text: MS0037 },
        existsDensoChu: { text: MS0749 },

        // 項目名の幅
        each_lang_width: { number: 100 }
    });
    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        dt_from: {
            rules: {
                required: "Ngày bắt đầu",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "Ngày kết thúc",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // 画面制御ルール
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
