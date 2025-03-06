(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "配合名マスタ一覧" },
        cd_bunrui: { text: "仕掛品分類コード" },
        nm_bunrui: { text: "仕掛品分類" },
        cd_haigo: { text: "配合コード" },
        nm_haigo: { text: "配合名" },
        nm_haigo_ryaku: { text: "配合名略" },
        ritsu_budomari: { text: "歩留" },
        ritsu_kihon: { text: "基本倍率" },
        wt_kihon: { text: "基本重量" },
        kbn_kanzan: { text: "換算区分" },
        ritsu_hiju: { text: "比重" },
        flg_gassan_shikomi: { text: "仕込合算" },
        shikomi_gassan: { text: "仕込合算あり" },
        wt_saidai_shikomi: { text: "仕込最大重量" },
        flg_shorihin: { text: "調味液" },  // (2014.09.03)処理品 → 調味液
        flg_mishiyo_item: { text: "未使用" },
        cd_line: { text: "ラインコード" },
        nm_line: { text: "ライン名" },
        no_yusen: { text: "優先順位" },
        flg_tenkai: { text: "展開" },
        mishiyo: { text: "未使用表示" },
        flg_shiyo: { text: "あり" },
        flg_mishiyo: { text: "なし" },
        ts: { text: "タイムスタンプ" },
        lineSave: { text: "ライン登録" },
        no_han: { text: "版" },
        dt_from: { text: "有効期間" },
        dt_from_meisai: { text: "有効日付(開始)" },
        dt_from_criteria: { text: "有効日付" },
        notUse: { text: "使用しない場合" },
        dt_create: { text: "登録日" },
        dt_update: { text: "更新日" },
        delHaigo: { text: "配合削除" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 100 },
        cd_haigo_width: { number: 120 },
        nm_haigo_width: { number: 320 },
        nm_haigo_ryaku_width: { number: 180 },
        nm_bunrui_width: { number: 120 },
        ritsu_budomari_width: { number: 70 },
        ritsu_kihon_width: { number: 100 },
        kbn_kanzan_width: { number: 100 },
        ritsu_hiju_width: { number: 80 },
        flg_gassan_shikomi_width: { number: 80 },
        wt_saidai_shikomi_width: { number: 105 },
        flg_shorihin_width: { number: 65 },
        cd_line_width: { number: 105 },
        nm_line_width: { number: 160 },
        no_juni_yusen_width: { number: 80 },
        flg_tenkai_width: { number: 55 },
        flg_mishiyo_width: { number: 65 },
        no_han_width: { number: 30 },
        dt_from_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        nm_haigo: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        dt_from: {
            rules: {
                required: "有効日付",
                maxbytelength: 10,
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(3000, 12 - 1, 31 + 1)
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            NotRole: { visible: false }
        },
        colchange: {
            NotRole: { visible: false }
        },
        add: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        detail: {
            NotRole: { visible: false }
        },
        copy: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        excel: {
            NotRole: { visible: false }
        },
        del: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        recipe: {
            NotRole: { visible: false }
        },
        shikakari: {
            NotRole: { visible: false }
        },
        line: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });
})();
