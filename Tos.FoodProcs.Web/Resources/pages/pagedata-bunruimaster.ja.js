(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        ///// 画面項目名
        _pageTitle: { text: "分類マスタ"},
        hinKubun: { text: "品区分" },
        bunruiCode: { text: "コード" },
        bunruiName: { text: "原料分類名" },
        mishiyoFlag: { text: "未使用" },
        createCode: { text: "登録者" },
        createDate: { text: "登録日時" },
        ts: { text: "タイムスタンプ" },

        ///// 画面メッセージ
        noRecords: { text: MS0442 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        searchConfirm: { text: MS0065 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        overSearchCount: { text: MS0624 },

        ///// 画面項目の列幅
        cd_bunrui_width: { number: 120 },
        nm_bunrui_width: { number: 450 },
        flg_mishiyo_width: { number: 65 }
    });

    App.ui.pagedata.validation("ja", {
        ///// バリデーションルール
        hinKubun: {
            rules: {
                required: "品区分"
            },
            messages: {
                required: MS0004
            }
        },
        cd_bunrui: {
            rules: {
                required: "分類コード",
                alphanum: true,
                maxbytelength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_bunrui: {
            rules: {
                required: "原料分類名",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        ///// 画面制御ルール
        search: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
