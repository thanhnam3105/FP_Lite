(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Formula Master" },
        cd_bunrui: { text: "Group code" },
        nm_bunrui: { text: "Group" },
        cd_haigo: { text: "Formula code" },
        nm_haigo: { text: "Formula name" },
        nm_haigo_ryaku: { text: "Short name of<br>formula name" },
        ritsu_budomari: { text: "Yield" },
        ritsu_kihon: { text: "Basic<br>magnification" },
        wt_kihon: { text: "Basic<br>weight" },
        kbn_kanzan: { text: "Convert<br>type" },
        ritsu_hiju: { text: "Gravity" },
        flg_gassan_shikomi: { text: "Total<br>produce" },
        shikomi_gassan: { text: "Total produce<br>exist" },
        wt_saidai_shikomi: { text: "Maximum weight<br>of produce" },
        flg_shorihin: { text: "Liquid<br>seasoning" },    // Processing<br>product (2014.09.03)処理品 → 調味液
        flg_mishiyo_item: { text: "Unused" },
        cd_line: { text: "Line code" },
        nm_line: { text: "Line name" },
        no_yusen: { text: "Order of<br>priority" },
        flg_tenkai: { text: "Development" },
        mishiyo: { text: "Display unused" },
        flg_shiyo: { text: "Yes" },
        flg_mishiyo: { text: "No" },
        ts: { text: "Time stamp" },
        lineSave: { text: "Register line" },
        no_han: { text: "Version" },
        dt_from: { text: "Term of validity" },
        dt_from_meisai: { text: "Valid date<br>(start)" },
        dt_from_criteria: { text: "Valid date" },
        notUse: { text: "When not usage" },
        dt_create: { text: "Registration date" },
        dt_update: { text: "Update date" },
        delHaigo: { text: "Delete formula" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 180 },
        cd_haigo_width: { number: 120 },
        nm_haigo_width: { number: 320 },
        nm_haigo_ryaku_width: { number: 180 },
        nm_bunrui_width: { number: 190 },
        ritsu_budomari_width: { number: 60 },
        ritsu_kihon_width: { number: 120 },
        kbn_kanzan_width: { number: 80 },
        ritsu_hiju_width: { number: 80 },
        flg_gassan_shikomi_width: { number: 80 },
        wt_saidai_shikomi_width: { number: 120 },
        flg_shorihin_width: { number: 100 },
        cd_line_width: { number: 80 },
        nm_line_width: { number: 160 },
        no_juni_yusen_width: { number: 80 },
        flg_tenkai_width: { number: 110 },
        flg_mishiyo_width: { number: 70 },
        no_han_width: { number: 50 },
        dt_from_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
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
                required: "Valid date",
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
    App.ui.pagedata.operation("en", {
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
