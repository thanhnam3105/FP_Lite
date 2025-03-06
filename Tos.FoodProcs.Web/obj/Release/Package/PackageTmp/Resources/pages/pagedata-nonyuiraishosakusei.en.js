    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Make Delivery Request Sheets" },
        // 作成条件
        dt_sakusei_kaishi: { text: "Making start date" },
        select_torihiki: { text: "Select vendor" },
        select_hinmei: { text: "Select item name" },
        select_all_print: { text: "Print all" },
        select_torihiki_hinmei: { text: "Select vendor/product" },
        yotei_nashi: { text: "Output no plan item also" },
        bunruigoto: { text: "Change page by group" },
        nohinsaki: { text: "Instruct other delivery destination" },
        comment: { text: "Comment" },
        // ボタン
        nohinsakiIchiran: { text: "Delivery destination" },
        teikeibunIchiran: { text: "Set phrase list" },
        // 隠し項目など
        comment_area: { text: "Comment input section" },
        selectCriteria: { text: "Output condition" },
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
        reqMsgNohinsaki: { text: "Delivery destination, when check box is ON" },
        reqMsgComment: { text: "Comment, when check box is ON" }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_sakusei_kaishi: {
            rules: {
                required: "Making start date",
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
    App.ui.pagedata.operation("en", {
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
