    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "納入依頼書リスト" },
        // ヘッダー
        hachuNo: { text: "発注番号：" },
        renrakusaki: { text: "連絡先：" },
        renrakusaki_tel: { text: "TEL" },
        renrakusaki_fax: { text: "FAX" },
        nohinsaki: { text: "納品先：" },
        // 印刷レイアウト選択
        print_layout: { text: "レイアウト：" },
        layout_yoko: { text: "横" },
        layout_tate: { text: "縦" },
        // 検索条件
        dt_sakusei_kaishi: { text: "作成開始日" },
        nm_torihiki: { text: "取引先" },
        torihiki_tani: { text: "(納入数量)" },
        // 一覧
        cd_hinmei: { text: "品名コード" },
        nm_hinmei: { text: "品名" },
        nm_nisugata_hyoji: { text: "荷姿" },
        tani_nonyu: { text: "単位" },
        nm_bunrui: { text: "分類" },
        dt_nonyu: { text: "月/日" },
        su_nonyu: { text: "数量" },
        juryo: { text: "重量(Ｋｇ)" },
        // ボタン
        allPrint: { text: "全印刷" },
        // 隠し項目など
        // TODO: ここまで
        listDateFormat: { text: "m/d（D）" },   // 明細．日付のフォーマット
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
        cd_hinmei_width: { number: 100 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
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
