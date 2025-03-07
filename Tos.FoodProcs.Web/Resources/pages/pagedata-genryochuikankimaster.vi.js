(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master nguyên liệu chú ý cảnh báo" },
        //検索条件
        kbn_hin: { text: "Loại" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        kbn_chui_kanki: { text: "Loại cảnh báo" },
        chuiIchiran: { text: "Chọn nhóm cảnh báo" },
        
        //明細
        cd_chui_kanki: { text: "Mã nhóm" },
        nm_chui_kanki: { text: "Tên nhóm" },
        no_juni_yusen: { text: "Thứ tự" },
        flg_chui_kanki_hyoji: { text: "Hiển thị cảnh báo" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        ts: { text: "Timestamp" },
        dt_create: { text: "Ngày tạo" },
        cd_create: { text: "Người tạo" },

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
        flg_chui_kanki_hyoji_width: { number: 100 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        cd_chui_kanki: {
            rules: {
                required: "Mã nhóm",
                alphanum: true,
                maxlength: 10
            },
            
            params: {
                custom: "Mã nhóm"
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
                required: "Mã",
                alphanum: true,
                maxlength: 14
            },
            params: {
                custom: "Mã"
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
    App.ui.pagedata.operation("vi", {
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