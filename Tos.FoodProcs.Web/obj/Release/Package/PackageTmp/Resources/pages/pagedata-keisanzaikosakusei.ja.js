    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "計算在庫作成" },
        // 作成条件
        cd_hinmei: { text: "品名コード" },
        nm_hinmri: { text: "品名" },
        label_all_genshizai: { text: "全原資材について計算在庫を作成する" },
        label_genshizai: { text: "以下の品名コードの原資材について計算在庫を作成する" },
        dt_from: { text: "在庫計算開始日" },
        dt_to: { text: "在庫計算末日" },
        // ボタン
        keisan_start: { text: "在庫計算開始" },
        // 作成条件の定数
        selectAllGenshizai: { text: "1" },
        selectGenshizai: { text: "2" },
        // 隠し項目など
        between: { text: "～" },
        selectCriteria: { text: "作成条件" },
        // 作成できる計算在庫の最大期間：2014/1/23現在：61(開始日含む～末日が62日間)
        maxPeriod: { text: "61" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        startConfirm: { text: MS0695 },
        deleteConfirm: { text: MS0694 },
        allGenshizaiConfirm: { text: MS0679 },
        creatCompletion: { text: MS0696 },
        dateCheck: { text: MS0698 },
        dateCheckPeriod: { text: MS0697 },
        //dateCheckFromDate: { text: MS0193 },
        kyujitsuCheck: { text: MS0125 },
        hinmeiCheck: { text: MS0543 },
        notOperate: { text: MS0655 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "品名コード"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_from: {
            rules: {
                required: "在庫計算開始日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "在庫計算末日",
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
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        keisanStart: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false }
        },
        genshizaiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
