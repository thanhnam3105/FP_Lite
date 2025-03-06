    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
      //  _pageTitle: { text: "使用实际一次性传送" },
        _pageTitle: { text: "使用实际统括传送" },
        // 作成条件
        dt_from: { text: "传送开始日" },
        dt_to: { text: "传送结束日" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "使用实际传送一次性指示" },

        // 画面メッセージ
        dateCheck: { text: MS0019 },
        noTargetData: { text: MS0037 },
        existsDensoChu: { text: MS0749 },

        // 項目名の幅
        each_lang_width: { number: 100 }
    });
    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        dt_from: {
            rules: {
                required: "传送开始日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "传送结束日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
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
