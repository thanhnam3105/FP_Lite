(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master vật liệu sử dụng" },
        cd_hinmei: { text: "Mã sản phẩm" },
        nm_hinmei: { text: "Tên sản phẩm" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        nm_han: { text: "Phiên bản" },
        nm_shinki_han: { text: "Phiên bản mới" },
        _meisaiTitle: { text: "Thay đổi vật liệu sử dụng" },
        notUse: { text: "Trường hợp không sử dụng" },
        flg_mishiyo: { text: "Không sử dụng" },
        dt_from: { text: "Ngày hiệu lực" },
        cd_shizai: { text: "Mã vật liệu" },
        nm_shizai: { text: "Tên vật liệu" },
        nm_tani_shiyo: { text: "Đơn vị sử dụng" },
        su_shiyo: { text: "Số lượng sử dụng" },
        delete_shizai: { text: "Xóa sử dụng vật liệu" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                required: "Mã sản phẩm",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        cd_shizai: {
            rules: {
                required: "Mã vật liệu",
                alphanum: true,
                maxbytelength: 14,
                custom: true
            },
            params: {
                custom: "Mã vật liệu"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                maxbytelength: MS0012,
                custom: MS0049
            }
        },
        su_shiyo: {
            rules: {
                required: "Số lượng sử dụng",
                pointlength: [6, 6, false],
                range: [0, 999999.999999]
            },
            messages: {
                required: MS0042,
                pointlength: MS0440,
                range: MS0450
            }
        },
        dt_from: {
            rules: {
                custom: true
            },
            messages: {
                custom: MS0666
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("vi", {
        // 有効日付専用バリデーション
        dt_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 50, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        shinkiHan: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
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
        shizai: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        delete_shizai: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();