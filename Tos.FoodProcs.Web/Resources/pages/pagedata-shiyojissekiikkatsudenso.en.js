    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Actual Use Transmission (to SAP)" },
        // 作成条件
        dt_from: { text: "From:" },
        dt_to: { text: "To:" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "Date Range of Allocated data (to SAP)" },

        // 画面メッセージ
        dateCheck: { text: MS0019 },
        noTargetData: { text: MS0037 },
        existsDensoChu: { text: MS0749 },

        // 項目名の幅
        each_lang_width: { number: 100 }
    });
    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        dt_from: {
            rules: {
                required: "Transmission start date",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "Transmission end date",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
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
