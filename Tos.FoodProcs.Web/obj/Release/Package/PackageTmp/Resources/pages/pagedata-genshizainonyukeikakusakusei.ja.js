    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材納入計画作成" },
        // 作成条件
        cd_hinmei: { text: "品名コード" },
        nm_hinmri: { text: "品名" },
        label_all_genshizai: { text: "全原資材について納入計画を作成する" },
        label_genshizai: { text: "以下の品名コードの原資材について納入計画を作成する" },
        dt_from: { text: "変動計算初日" },
        dt_to: { text: "変動計算末日" },
        // ボタン
        keisan_start: { text: "変動計算開始" },
        // 作成条件の定数
        selectAllGenshizai: { text: "1" },
        selectGenshizai: { text: "2" },
        // 隠し項目など
        between: { text: "～　" },
        selectCriteria: { text: "作成条件" },
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
        each_lang_width: { number: 100 }
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
                required: "変動計算初日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "変動計算末日",
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
