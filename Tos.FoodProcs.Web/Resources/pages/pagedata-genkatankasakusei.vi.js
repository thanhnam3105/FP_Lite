    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        /////// 画面項目のテキスト
        _pageTitle: { text: "Tính đơn giá" },

        // 作成条件
        dt_keisan: { text: "Năm tháng" },
        kbn_hin: { text: "Loại sản phẩm" },
        nm_bunrui: { text: "Phân loại" },
        cd_hinmei: { text: "Mã sản phẩm" },

        // ボタン
        sakusei_start: { text: "Tính đơn giá" },

        // 隠し項目など
        selectCriteria: { text: "Điều kiện tính toán" },

        // 原価単価の最大値(桁溢れの算術オーバー対策用)：DB値に合わせて整数8桁、小数4桁
        maxGenkaTanka: { text: "99999999.9999" },

        /////// 画面メッセージ
        startConfirm: { text: MS0723 },
        deleteConfirm: { text: MS0722 },
        creatCompletion: { text: MS0724 }
    });
    App.ui.pagedata.validation("vi", {
        // バリデーションルールとバリデーションメッセージ
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_keisan: {
            rules: {
                required: "Năm tháng",
                monthstring: true,
                lessmonth: new Date(1974, 12 - 1),
                greatermonth: new Date(new Date().getFullYear()+3, new Date().getMonth()+1)
            },
            messages: {
                required: MS0042,
                monthstring: MS0247,
                lessmonth: MS0247,
                greatermonth: MS0247
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // 画面制御ルール
        sakuseiStart: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        hinmeiIchiran: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();