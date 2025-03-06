(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面項目
        _pageTitle: { text: "Master nhắc nhở lưu ý" },
        //検索条件
        kbn_chui_kanki: { text: "Loại nhắc nhở lưu ý" },
        //明細
        cd_chui_kanki: { text: "Mã" },
        nm_chui_kanki: { text: "Tên" },
        flg_mishiyo: { text: "Không<br>sử dụng" },
        ts: { text: "timestamp" },
        // 画面メッセージ
        addRecordMax: { text: MS0052 },
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        searchBefore: { text: MS0621 },
        rangeDuplicat: { text: MS0501 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        changeCondition: { text: MS0299 },
        unloadWithoutSave: { text: MS0066 },
        overSearchCount: { text: MS0624 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_chui_kanki_width: { number: 100 },
        nm_chui_kanki_width: { number: 350 },
        flg_mishiyo_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        cd_chui_kanki: {
            rules: {
                required: "Mã",
                maxbytelength: 10,
                alphanum: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        nm_chui_kanki: {
            rules: {
                required: "Tên",
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

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // 画面制御ルール(権限)
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
        save: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();