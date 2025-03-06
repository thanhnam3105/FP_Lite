(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        ///// 画面項目名
        _pageTitle: { text: "分类主表" },
        hinKubun: { text: "商品区分" },
        bunruiCode: { text: "编号" },
        bunruiName: { text: "原料分类名" },
        mishiyoFlag: { text: "未使用" },
        createCode: { text: "登录者" },
        createDate: { text: "登录日期和时间" },
        ts: { text: "时间标记" },

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

    App.ui.pagedata.validation("zh", {
        ///// バリデーションルール
        hinKubun: {
            rules: {
                required: "商品区分"
            },
            messages: {
                required: MS0004
            }
        },
        cd_bunrui: {
            rules: {
                required: "分类编号",
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
                required: "原料分类名",
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
    App.ui.pagedata.operation("zh", {
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
