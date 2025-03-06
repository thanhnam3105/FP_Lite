(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Material Alert Master" },
        //検索条件
        kbn_hin: { text: "Item type" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        kbn_chui_kanki: { text: "Warning type" },
        chuiIchiran: { text: "Warning list" },
        
        //明細
        cd_chui_kanki: { text: "Code" },
        nm_chui_kanki: { text: "Name" },
        no_juni_yusen: { text: "Order" },
        flg_chui_kanki_hyoji: { text: "Print" },
        flg_mishiyo: { text: "Unused" },
        ts: { text: "Timestamp" },
        dt_create: { text: "Create time and date" },
        cd_create: { text: "Creator" },

        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        addRecordMax: { text: MS0052 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        searchBefore: { text: MS0621 },
        changeCondition: { text: MS0299 },
        overSearchCount: { text: MS0624 },
        addSelectChui: { text: MS0721 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_chui_kanki_width: { number: 120 },
        nm_chui_kanki_width: { number: 380 },
        no_juni_yusen_width: { number: 70 },
        flg_chui_kanki_hyoji_width: { number: 70 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_chui_kanki: {
            rules: {
                required: "Warning call code",
                alphanum: true,
                maxlength: 10
            },
            
            params: {
                custom: "Warning call code"
            },
            
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        },
        cd_hinmei: {
            rules: {
                required: "Code",
                alphanum: true,
                maxlength: 14
            },
            params: {
                custom: "Code"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012,
                custom: MS0049
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Purchase: { visible: false }
        },
        colchange: {
            Purchase: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        chui: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
