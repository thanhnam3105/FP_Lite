(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Material Movement History" },

        // 検索条件
        dt_hiduke_search: { text: "Date" },
        between: { text: "　～　" },
        flg_mishiyobun: { text: "Include unused" },
        ari_nomi: { text: "Inventory exist only" },
        hinKubun: { text: "Item division" },
        hinBunrui: { text: "Group" },
        hinCode: { text: "Material code" },
        flg_today_jisseki: { text: "Display as a result at same day" },
        ukeKubun: { text: "Movement division" },

        // グリッド項目
        cd_genshizai: { text: "Material code" },
        nm_genshizai: { text: "Material name" },
        dt_hiduke: { text: "Date" },
        kbn_ukeharai: { text: "Movement type" },
        su_nyusyukko: { text: "Quantities" },
        no_lot: { text: "Lot No." },
        cd_seihin: { text: "Code" },
        nm_seihin: { text: "Item name" },
        nm_memo: { text: "Memo" },
        nm_shokuba: { text: "Workplace" },
        nm_line: { text: "Line" },
        //受払区分
        nonyuYotei: { text: "Delivery plan" },
        nonyuJisseki: { text: "Actual receiving" },
        shiyoYotei: { text: "Usage plan" },
        shiyoJisseki: { text: "Actual usage" },
        chosei: { text: "Adjustment" },
        seizoYotei: { text: "Manufacture plan" },
        seizoJisseki: { text: "Actual Manufacture" },

        // その他：文言
        startDate: { text: "Start date" },
        endDate: { text: "Finish date" },
         // 開始日～終了日の最大期間日数
        maxPeriod: { text: "184" },
           
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 110 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 205 }
        // ここまで

    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                required: "Start date",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
                
            },

            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247 
            }
        },
        dt_hiduke_to: {
            rules: {
                required: "Finish date",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        kbn_hin: {
            rules: {
                required: "Item division"
            },
            messages: {
                required: MS0042
            }
        },
        cd_genshizai: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
