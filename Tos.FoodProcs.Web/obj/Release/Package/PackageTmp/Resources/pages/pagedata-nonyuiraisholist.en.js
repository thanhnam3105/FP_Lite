(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Print Delivery Request List" },
        // ヘッダー
        hachuNo: { text: "Order number:" },
        renrakusaki: { text: "Contact address:" },
        renrakusaki_tel: { text: "TEL" },
        renrakusaki_fax: { text: "FAX" },
        nohinsaki: { text: "Delivery destination:" },
        // 印刷レイアウト選択
        print_layout: { text: "Layout：" },
        layout_yoko: { text: "Width" },
        layout_tate: { text: "Length" },
        // 検索条件
        dt_sakusei_kaishi: { text: "Making start date" },
        nm_torihiki: { text: "Vendor" },
        torihiki_tani: { text: "(Delivery quantity)" },
        // 一覧
        cd_hinmei: { text: "Item code" },
        nm_hinmei: { text: "Item name" },
        nm_nisugata_hyoji: { text: "Packing style" },
        tani_nonyu: { text: "Unit" },
        nm_bunrui: { text: "Group" },
        dt_nonyu: { text: "Date/Month" },
        su_nonyu: { text: "Quantity" },
        juryo: { text: "Weight" },
        // ボタン
        allPrint: { text: "Print all" },
        // 隠し項目など
        // TODO: ここまで
        listDateFormat: { text: "d/m（D）" },   // 明細．日付のフォーマット
        listDateFormatUS: { text: "m/d（D）" },   // 明細．日付のフォーマット
        hachuSaibanKbn: { text: "12" },  // 発注番号の採番区分
        hachuPrefix: { text: "H" },      // 採番区分のプレフィックス
        // PDF：ページ上限数：2013.12.26時点100枚
        pageMaximums: { text: "100" },
        // PDF：確認ダイアログを表示する条件ページ数：2013.12.26時点10枚
        pageCautions: { text: "10" },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notOperate: { text: MS0655 },
        pageMaximumsOver: { text: MS0680 },
        pageCautionsOverConfirm: { text: MS0654 },
        printConfirm: { text: MS0223 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 120 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        pdf: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        pdfAll: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
