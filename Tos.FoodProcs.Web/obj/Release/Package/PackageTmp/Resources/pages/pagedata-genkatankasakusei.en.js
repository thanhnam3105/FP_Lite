    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        /////// 画面項目のテキスト
        _pageTitle: { text: "Cost Unit Price Creation" },

        // 作成条件
        dt_keisan: { text: "Years" },
        kbn_hin: { text: "Item type" },
        nm_bunrui: { text: "Group" },
        cd_hinmei: { text: "Item code" },

        // ボタン
        sakusei_start: { text: "Create start" },

        // 隠し項目など
        selectCriteria: { text: "Calculation conditions" },

        // 原価単価の最大値(桁溢れの算術オーバー対策用)：DB値に合わせて整数8桁、小数4桁
        maxGenkaTanka: { text: "99999999.9999" },

        /////// 画面メッセージ
        startConfirm: { text: MS0723 },
        deleteConfirm: { text: MS0722 },
        creatCompletion: { text: MS0724 }
    });
    App.ui.pagedata.validation("en", {
        // バリデーションルールとバリデーションメッセージ
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Item code"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_keisan: {
            rules: {
                required: "Years",
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
    App.ui.pagedata.operation("en", {
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
