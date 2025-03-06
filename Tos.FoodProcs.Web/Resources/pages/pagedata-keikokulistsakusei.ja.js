    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "警告リスト作成" },
        // 検索条件
        dt_target: { text: "開始日" },
        dt_target_to: { text: "終了日" },
        kbn_hin: { text: "品区分" },
        hin_bunrui: { text: "品分類" },
        kurabasho: { text: "庫場所" },
        hinmei: { text: "品名" },
        keikoku_min: { text: "警告リスト" },
        keikoku_max: { text: "最大在庫も警告" },
        zenZaiko_tojitsuShiyo: { text: "前日在庫－当日使用" },
        allGenshizai: { text: "全ての原資材を表示" },
        considersLeadtime: { text: "納入リードタイムを加味する" },
        between: { text: "　～　" },
        // 一覧
        dt_hizuke: { text: "月/日" },
        dt_hizukeUS: { text: "日/月" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "名称" },
        nm_nisugata_hyoji: { text: "荷姿" },
        tani_shiyo: { text: "使用単位" },
        su_zaiko: { text: "在庫" },
        su_zaiko_min: { text: "最低在庫" },
        su_zaiko_max: { text: "最大在庫" },
        nm_torihiki: { text: "仕入先名" },
        // ボタン
        hendohyo: { text: "変動表" },
        zaiko_update: { text: "計算在庫更新" },
        // 隠し項目など
        dt_hizuke_full: { text: "年/月/日" },
        // 計算在庫作成時の作成できる最大期間日数
        maxPeriod: { text: "184" },
        //maxPeriod: { text: "32" },  // TODO：レスポンス問題が解決するまでは32日間
        splitDays: { number: 7 },  // 分割する日数
        // TODO: ここまで
        listDateFormat: { text: "m/d" },   // 明細．日付のフォーマット
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        limitOver: { text: MS0011 },
        startConfirm: { text: MS0695 },
        allGenshizaiConfirm: { text: MS0679 },
        creatCompletion: { text: MS0696 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 90 },
        item_list_left_width: { number: 350 },
        dt_hizuke_width: { number: 70 },
        zenZaiko_tojitsuShiyo_width: { number: 160 },
        keikoku_max_width: { number: 120 },
        allGenshizai_width: { number: 120 },
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
    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_target: {
            rules: {
                required: "日付",
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
    App.ui.pagedata.operation("ja", {
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
