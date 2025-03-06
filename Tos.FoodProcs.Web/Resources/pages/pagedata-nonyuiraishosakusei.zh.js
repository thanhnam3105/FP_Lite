(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "入库委托书制作" },
        // 作成条件
        dt_sakusei_kaishi: { text: "作成开始日" },
        select_torihiki: { text: "厂商选择" },
        select_hinmei: { text: "品名选择" },
        select_all_print: { text: "打印全部件数" },
        select_torihiki_hinmei: { text: "厂商／品名选择" },
        yotei_nashi: { text: "输出无预定的商品品目" },
        bunruigoto: { text: "按每一类换页" },
        nohinsaki: { text: "入库地　代替地点制定" },
        comment: { text: "注释" },
        // ボタン
        nohinsakiIchiran: { text: "入库地一览" },
        teikeibunIchiran: { text: "定型文一览" },
        // 隠し項目など
        comment_area: { text: "注释输入一栏" },
        selectCriteria: { text: "出力输出条件" },
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
        reqMsgNohinsaki: { text: "复选框ON时入库地" },
        reqMsgComment: { text: "复选框ON时注释" }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_sakusei_kaishi: {
            rules: {
                required: "作成开始日",
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
    App.ui.pagedata.operation("zh", {
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
