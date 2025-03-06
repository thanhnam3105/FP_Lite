    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "納入依頼書作成" },
        // 作成条件
        dt_sakusei_kaishi: { text: "作成開始日" },
        select_torihiki: { text: "取引先選択" },
        select_hinmei: { text: "品名選択" },
        select_all_print: { text: "全件印刷" },
        select_torihiki_hinmei: { text: "取引先／品名選択" },
        yotei_nashi: { text: "予定なしの品目も出力する" },
        bunruigoto: { text: "分類毎に改頁する" },
        nohinsaki: { text: "納品先　代替場所指定" },
        comment: { text: "コメント" },
        // ボタン
        nohinsakiIchiran: { text: "納品先一覧" },
        teikeibunIchiran: { text: "定型文一覧" },
        // 隠し項目など
        comment_area: { text: "コメント入力欄" },
        selectCriteria: { text: "出力条件" },
        // PDF：ページ上限数：2013.12.26時点100枚
        pageMaximums: { text: "100" },
        // PDF：確認ダイアログを表示する条件ページ数：2013.12.26時点10枚
        pageCautions: { text: "10" },
        // 出力条件の定数
        selectTorihiki: { text: "1" },
        selectHinmei: { text: "2" },
        selectAllPrint: { text: "3" },
        selectToriHin: { text: "4" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        printConfirm: { text: MS0223 },
        pageCautionsOverConfirm: { text: MS0654 },
        pageMaximumsOver: { text: MS0680 },
        selectRequired: { text: MS0042 },
        selectNone: { text: MS0044 },
        notOperate: { text: MS0655 },
        reqMsgNohinsaki: { text: "チェックボックスON時は納品先" },
        reqMsgComment: { text: "チェックボックスON時はコメント" }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_sakusei_kaishi: {
            rules: {
                required: "作成開始日",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        comment_area: {
            rules: {
                maxbytelength: 100
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        select: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        nohinsakiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        teikeibunIchiran: {
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
