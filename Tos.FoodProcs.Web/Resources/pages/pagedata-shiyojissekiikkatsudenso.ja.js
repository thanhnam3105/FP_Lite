    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        _pageTitle: { text: "使用実績一括伝送" },
        // 作成条件
        dt_from: { text: "伝送開始日" },
        dt_to: { text: "伝送終了日" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "使用実績伝送一括指示" },

        // 画面メッセージ
        dateCheck: { text: MS0019 },
        noTargetData: { text: MS0037 },
        existsDensoChu: { text: MS0749 },

        // 項目名の幅
        each_lang_width: { number: 100 }
    });
    App.ui.pagedata.validation("ja", {
        // バリデーションルールとバリデーションメッセージ
        dt_from: {
            rules: {
                required: "伝送開始日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "伝送終了日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
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
