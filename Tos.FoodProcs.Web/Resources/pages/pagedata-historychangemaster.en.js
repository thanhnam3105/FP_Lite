(function () {
    var lang = App.ui.pagedata.lang("en", {
        _pageTitle: { text: "Change History List" },

        // 検索条件
        dt_from: { text: "Date (start)" },
        dt_to: { text: "Date (end)" },
        between: { text: "　～　" },
        DataPartition: { text: "Data partition" },
        ProcessingDivision: { text: "Processing division" },
        dt_update_from: { text: "Update date (start)" },
        dt_update_to: { text: "Update date (end)" },
        name: { text: "Person in charge" },
        hinCode: { text: "Product code" },

        // グリッド項目
        kbn_data: { text: "Data partition" },
        kbn_shori: { text: "Processing division" },
        dt_hizuke: { text: "Date" },
        cd_hinmei: { text: "Product code" },
        nm_seihin: { text: "Product name" },
        su_henko: { text: "Number of cases after change" },
        su_henko_hasu: { text: "Fraction after change" },
        tr_lot: { text: "Lot NO" },
        dt_henko: { text: "Update date / time" },
        cd_henko: { text: "Contact ID" },
        nm_henko: { text: "Person in charge" },
        biko: { text: "Notes" },       

        nm_riyu: { text: "Reason of adjustment" },
        genka_busho: { text: "Cost generation department" },

        // その他：文言
        startDate: { text: "Start date" },
        endDate: { text: "End date" },

        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "62" },

        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 70 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 195 }
        // ここまで

    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)

            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_hiduke_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        cd_nm_tanto: {
            rules: {
                maxbytelength: 50
            },
            params: {
                custom: "Name"
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Product code"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0037
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
