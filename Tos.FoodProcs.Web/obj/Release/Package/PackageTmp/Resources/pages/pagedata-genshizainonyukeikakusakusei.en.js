    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Auto Make Delivery Plan" },
        // 作成条件
        cd_hinmei: { text: "Item code" },
        nm_hinmri: { text: "Item name" },
        label_all_genshizai: { text: "Make delivery plans for all material" },
        label_genshizai: { text: "Make delivery plans of one item" },
        dt_from: { text: "Calculation start date" },
        dt_to: { text: "Calculation end date" },
        // ボタン
        keisan_start: { text: "Start calculation" },
        // 作成条件の定数
        selectAllGenshizai: { text: "1" },
        selectGenshizai: { text: "2" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "Create condition" },
        // 作成できる納入計画の最大期間：2013/12/17現在：61(開始日含む～末日が62日間)
        maxPeriod: { text: "61" },
        splitDays: { number: 7 },  // 分割する日数
        // 納入日をXX日前にずらしたいという要望があったとき用：2014/01/08時点では0日
        dtNonyuLeadtime: { text: "0" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        startConfirm: { text: MS0221 },
        deleteConfirm: { text: MS0222 },
        allGenshizaiConfirm: { text: MS0679 },
        creatCompletion: { text: MS0192 },
        dateCheck: { text: MS0195 },
        dateCheckPeriod: { text: MS0194 },
        dateCheckFromDate: { text: MS0193 },
        kyujitsuCheck: { text: MS0125 },
        hinmeiCheck: { text: MS0543 },
        notOperate: { text: MS0655 },
        each_lang_width: { number: 150 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Item name code"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_from: {
            rules: {
                required: "First day of fluctuate calculation",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "Last day of fluctuate calculation",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        keisanStart: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        genshizaiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
