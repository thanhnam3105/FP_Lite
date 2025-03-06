(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Warning List" },
        // 検索条件
        dt_target: { text: "Start date" },
        dt_target_to: { text: "End date" },
        kbn_hin: { text: "Item type" },
        hin_bunrui: { text: "Item group" },
        kurabasho: { text: "Issued location" },
        hinmei: { text: "Item name" },
        keikoku_min: { text: "Warning list" },
        keikoku_max: { text: "Warning maximum inventory" },
        zenZaiko_tojitsuShiyo: { text: "Inventory of yesterday - Usage of today" },
        allGenshizai: { text: "All the materials are displayed" },
        considersLeadtime: { text: "A delivery lead time is considered" },
        between: { text: "　～　" },
        // 一覧
        dt_hizuke: { text: "Date/Month" },
        dt_hizukeUS: { text: "Month/Date" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        nm_nisugata_hyoji: { text: "Packing style" },
        tani_shiyo: { text: "Usage unit" },
        su_zaiko: { text: "Inventory" },
        su_zaiko_min: { text: "Minimum<br>inventory" },
        su_zaiko_max: { text: "Maximum<br>inventory" },
        nm_torihiki: { text: "Vendor" },
        // ボタン
        hendohyo: { text: "Fluctuation table" },
        zaiko_update: { text: "Calculate inventory" },
        // 隠し項目など
        dt_hizuke_full: { text: "Date/Month/Year" },
        // 計算在庫作成時の作成できる最大期間日数
        maxPeriod: { text: "184" },
        //maxPeriod: { text: "32" },  // TODO：レスポンス問題が解決するまでは32日間
        splitDays: { number: 7 },  // 分割する日数
        // TODO: ここまで
        listDateFormat: { text: "Date/Month" },   // 明細．日付のフォーマット
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        limitOver: { text: MS0011 },
        startConfirm: { text: MS0695 },
        allGenshizaiConfirm: { text: MS0679 },
        creatCompletion: { text: MS0696 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 150 },
        item_list_left_width: { number: 450 },
        dt_hizuke_width: { number: 90 },
        zenZaiko_tojitsuShiyo_width: { number: 270 },
        keikoku_max_width: { number: 180 },
        allGenshizai_width: { number: 200 },
        cd_hinmei_width: { number: 90 },
        nm_hinmei_width: { number: 250 },
        nm_nisugata_hyoji_width: { number: 159 },
        tani_shiyo_width: { number: 90 },
        su_zaiko_width: { number: 110 },
        su_zaiko_min_width: { number: 110 },
        su_zaiko_max_width: { number: 110 },
        nm_torihiki_width: { number: 200 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_target: {
            rules: {
                required: "Date",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_target_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinmei: {
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
        keisanzaikoUpdate: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        },
        hendohyo: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
