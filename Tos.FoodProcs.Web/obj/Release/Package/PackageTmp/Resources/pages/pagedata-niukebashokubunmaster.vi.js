
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master phân loại nơi nhận hàng" },
        kbn_niuke_basho: { text: "Mã" },
        nm_kbn_niuke: { text: "Tên" },
        flg_niuke: { text: "Được phép<br>nhập hàng" },
        flg_henpin: { text: "Được phép<br>trả hàng" },
        flg_shukko: { text: "Được phép<br>xuất kho" },
        flg_mishiyo: { text: "Không<br>sử dụng" },

        cd_create: { text: "Người đăng ký" },
        dt_create: { text: "Ngày đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        cd_update: { text: "Người cập nhật" },
        ts: { text: "Time stamp" },

        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        kbn_niuke_basho_width: { number: 100 },
        nm_kbn_niuke_width: { number: 300 },
        flg_niuke_width: { number: 120 },
        flg_henpin_width: { number: 70 },
        flg_shukko_width: { number: 70 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        kbn_niuke_basho: {
            rules: {
                required: "Mã",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0012
            }
        },
        nm_kbn_niuke: {
            rules: {
                required: "Tên",
                maxbytelength: 50,
                illegalchara: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                illegalchara: MS0005
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
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
        },
        "grid:itemGrid.kbn_niuke_basho": {
            Admin: { enable: true },
            guest: { enable: false },
            manager: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
