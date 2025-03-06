    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tính toán tồn kho" },
        // 作成条件
        cd_hinmei: { text: "Mã nguyên vật liệu" },
        nm_hinmri: { text: "Tên nguyên vật liệu" },
        label_all_genshizai: { text: "Tính toán tồn kho của tất cả nguyên vật liệu" },
        label_genshizai: { text: "Tính toán tồn kho của nguyên vật liệu có mã ở bên dưới" },
        dt_from: { text: "Ngày bắt đầu tính tồn kho" },
        dt_to: { text: "Ngày kết thúc tính tồn kho" },
        // ボタン
        keisan_start: { text: "Bắt đầu tính tồn kho" },
        // 作成条件の定数
        selectAllGenshizai: { text: "1" },
        selectGenshizai: { text: "2" },
        // 隠し項目など
        between: { text: "~" },
        selectCriteria: { text: "Điều kiện tính toán" },
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
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Mã nguyên vật liệu"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        dt_from: {
            rules: {
                required: "Ngày bắt đầu tính tồn kho",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        dt_to: {
            rules: {
                required: "Ngày kết thúc tính tồn kho",
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
    App.ui.pagedata.operation("vi", {
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